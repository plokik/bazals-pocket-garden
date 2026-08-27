#!/usr/bin/env python3
"""Extract the approved Phase 148 painted room objects from baked checker atlases.

The source RGB values of every retained pixel are copied byte-for-byte.  This tool
only derives an alpha channel, splits the fixed atlas grid, and trims transparent
space.  It deliberately does not recolour, sharpen, decontaminate, resample, or
otherwise repaint the approved artwork.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageFilter


TOOL_VERSION = 3
DEFAULT_OUTPUT = Path("assets/ui/visual/phase148/player_room")
MANIFEST_NAME = "phase148_painted_room_assets_manifest.json"
ALLOWED_AUTHORED_SEAMS = {
    # The generated plant atlas has an intentional one-pixel row seam here:
    # row-three contact shadows end at y=1137 and the next row's leaf tips start
    # at y=1138.  The locked source hash makes these narrow exceptions stable;
    # every other touched source-cell side remains a hard failure.
    "coleus": ("top",),
}


@dataclass(frozen=True)
class AtlasSpec:
    key: str
    source: Path
    expected_sha256: str
    columns: int
    rows: int
    column_breaks_by_row: tuple[tuple[int, ...], ...]
    row_breaks: tuple[int, ...]
    output_group: str
    names: tuple[str, ...]


ATLASES = (
    AtlasSpec(
        key="plants",
        source=Path(
            "docs/visual-proposals/phase147/"
            "player-room-painted-cartoon-plants-atlas-checker-source-v1.png"
        ),
        expected_sha256="0735BB39144E113228088973DE87B4A4C655D5557391477D54E0BE4513572D24",
        columns=3,
        rows=4,
        column_breaks_by_row=(
            (0, 341, 683, 1024),
            (0, 341, 683, 1024),
            (0, 341, 683, 1024),
            (0, 341, 683, 1024),
        ),
        row_breaks=(0, 426, 798, 1138, 1536),
        output_group="plants",
        names=(
            "orchid",
            "glossy_broadleaf",
            "snake_plant",
            "fern",
            "flowering_begonia",
            "roundleaf_pilea",
            "striped_calathea",
            "lemon_maranta",
            "compact_aglaonema",
            "fittonia",
            "pothos",
            "coleus",
        ),
    ),
    AtlasSpec(
        key="decor",
        source=Path(
            "docs/visual-proposals/phase147/"
            "player-room-painted-cartoon-decor-atlas-checker-source-v1.png"
        ),
        expected_sha256="6E56BD543A7FFB423A1F82D0CE73A317C87C88B7FB9516262F3F5B84F5179C8C",
        columns=3,
        rows=3,
        column_breaks_by_row=(
            (0, 414, 799, 1177),
            (0, 430, 756, 1177),
            (0, 362, 767, 1177),
        ),
        row_breaks=(0, 463, 859, 1336),
        output_group="decor",
        names=(
            "books",
            "herb_jars",
            "fertilizer_bags",
            "botanical_print",
            "table_lamp",
            "nested_pots",
            "watering_can",
            "cat_bed",
            "paired_bowls",
        ),
    ),
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def _cell_bounds(spec: AtlasSpec, width: int, height: int, index: int) -> tuple[int, int, int, int]:
    column = index % spec.columns
    row = index // spec.columns
    column_breaks = spec.column_breaks_by_row[row]
    if len(spec.column_breaks_by_row) != spec.rows or len(column_breaks) != spec.columns + 1:
        raise ValueError(f"{spec.key}: column-break grid shape is invalid")
    if column_breaks[0] != 0 or column_breaks[-1] != width:
        raise ValueError(f"{spec.key}: column breaks do not match atlas width")
    if spec.row_breaks[0] != 0 or spec.row_breaks[-1] != height:
        raise ValueError(f"{spec.key}: row breaks do not match atlas height")
    return (column_breaks[column], spec.row_breaks[row], column_breaks[column + 1], spec.row_breaks[row + 1])


def _edge_connected_background_alpha(rgb: Image.Image) -> Image.Image:
    """Return an inward-feathered alpha mask for the baked checker background.

    The generated checker is light and nearly neutral, while its baked studio
    shadow is warmer but still low-to-moderate chroma. Every candidate component
    touching a cell edge is background, including that studio shadow.
    Large enclosed components made almost entirely from the two checker tones are
    background too; this removes holes inside handles without deleting enclosed
    painted highlights in ceramic, glass, paper, or flowers.  Feathering happens
    only *inside* the retained silhouette, so no pale source-background RGB can
    reappear as a sticker halo over the room's dark wood.
    """

    width, height = rgb.size
    pixels = rgb.load()
    pixel_count = width * height
    candidate = bytearray(pixel_count)

    for y in range(height):
        row_offset = y * width
        for x in range(width):
            red, green, blue = pixels[x, y]
            low = min(red, green, blue)
            chroma = max(red, green, blue) - low
            if low >= 90 and chroma <= 110:
                candidate[row_offset + x] = 1

    visited = bytearray(pixel_count)
    background = bytearray(pixel_count)

    for start in range(pixel_count):
        if not candidate[start] or visited[start]:
            continue
        component: list[int] = []
        queue: deque[int] = deque([start])
        visited[start] = 1
        touches_edge = False
        checker_core = 0
        while queue:
            offset = queue.popleft()
            component.append(offset)
            x = offset % width
            y = offset // width
            red, green, blue = pixels[x, y]
            luminance = (red * 54 + green * 183 + blue * 19) // 256
            chroma = max(red, green, blue) - min(red, green, blue)
            if luminance >= 235 and chroma <= 8:
                checker_core += 1
            touches_edge = touches_edge or x == 0 or y == 0 or x == width - 1 or y == height - 1
            neighbours: list[int] = []
            if x > 0:
                neighbours.append(offset - 1)
            if x + 1 < width:
                neighbours.append(offset + 1)
            if y > 0:
                neighbours.append(offset - width)
            if y + 1 < height:
                neighbours.append(offset + width)
            for neighbour in neighbours:
                if candidate[neighbour] and not visited[neighbour]:
                    visited[neighbour] = 1
                    queue.append(neighbour)

        checker_ratio = checker_core / len(component)
        is_checker_hole = len(component) >= 16 and checker_ratio >= 0.55
        if touches_edge or is_checker_hole:
            for offset in component:
                background[offset] = 1

    hard_alpha = Image.new("L", (width, height), 255)
    hard_bytes = bytearray(0 if is_background else 255 for is_background in background)
    hard_alpha.frombytes(bytes(hard_bytes))
    softened = hard_alpha.filter(ImageFilter.GaussianBlur(0.65))
    softened_bytes = softened.tobytes()
    alpha_bytes = bytearray(pixel_count)
    for offset, is_background in enumerate(background):
        if is_background:
            alpha_bytes[offset] = 0
        else:
            alpha_bytes[offset] = max(96, softened_bytes[offset])

    alpha = Image.new("L", (width, height), 255)
    alpha.frombytes(bytes(alpha_bytes))
    return alpha


def _count_mask_pixels(mask: Image.Image, predicate) -> int:
    return sum(1 for value in mask.getdata() if predicate(value))


def _qa_metrics(rgb: Image.Image, alpha: Image.Image, raw_bbox: tuple[int, int, int, int]) -> dict[str, int | float | list[int]]:
    width, height = rgb.size
    total = width * height
    alpha_values = list(alpha.getdata())
    solid = alpha.point(lambda value: 255 if value >= 128 else 0)
    near_solid = solid.filter(ImageFilter.MaxFilter(31))
    rgb_values = list(rgb.getdata())
    near_values = list(near_solid.getdata())

    checker_residue = 0
    halo_risk = 0
    contact_shadow = 0
    for colour, alpha_value, near_value in zip(rgb_values, alpha_values, near_values):
        red, green, blue = colour
        luminance = (red * 54 + green * 183 + blue * 19) // 256
        chroma = max(red, green, blue) - min(red, green, blue)
        if alpha_value >= 16 and near_value == 0 and luminance >= 225 and chroma <= 18:
            checker_residue += 1
        if 48 <= alpha_value < 128 and luminance >= 210 and chroma <= 18:
            halo_risk += 1
        if 1 <= alpha_value <= 223 and luminance < 232 and chroma <= 42:
            contact_shadow += 1

    outer_alpha = []
    if width and height:
        outer_alpha.extend(alpha.crop((0, 0, width, 1)).getdata())
        outer_alpha.extend(alpha.crop((0, height - 1, width, height)).getdata())
        outer_alpha.extend(alpha.crop((0, 1, 1, max(1, height - 1))).getdata())
        outer_alpha.extend(alpha.crop((width - 1, 1, width, max(1, height - 1))).getdata())

    return {
        "cell_size": [width, height],
        "raw_alpha_bounds": list(raw_bbox),
        "nonzero_alpha_pixels": sum(1 for value in alpha_values if value > 2),
        "solid_alpha_pixels": sum(1 for value in alpha_values if value >= 128),
        "soft_alpha_pixels": sum(1 for value in alpha_values if 2 < value < 253),
        "contact_shadow_pixels": contact_shadow,
        "transparent_ratio": round(sum(1 for value in alpha_values if value <= 2) / total, 6),
        "checker_residue_pixels": checker_residue,
        "checker_residue_ratio": round(checker_residue / total, 8),
        "halo_risk_pixels": halo_risk,
        "halo_risk_ratio": round(halo_risk / total, 8),
        "source_edge_max_alpha": max(outer_alpha, default=0),
    }


def _validate_asset(name: str, metrics: dict[str, int | float | list[int] | list[str]], padding: int) -> list[str]:
    errors: list[str] = []
    width, height = metrics["cell_size"]  # type: ignore[misc]
    left, top, right, bottom = metrics["raw_alpha_bounds"]  # type: ignore[misc]
    if metrics["nonzero_alpha_pixels"] < 1000:
        errors.append(f"{name}: extraction contains too few foreground pixels")
    if metrics["transparent_ratio"] < 0.12:
        errors.append(f"{name}: less than 12% of its atlas cell became transparent")
    if metrics["checker_residue_ratio"] > 0.0005:
        errors.append(f"{name}: checker residue exceeds 0.05%")
    if metrics["halo_risk_ratio"] > 0.001:
        errors.append(f"{name}: bright neutral halo risk exceeds 0.1%")
    touching_sides: set[str] = set()
    if left <= 0:
        touching_sides.add("left")
    if top <= 0:
        touching_sides.add("top")
    if right >= width:
        touching_sides.add("right")
    if bottom >= height:
        touching_sides.add("bottom")
    allowed_sides = set(ALLOWED_AUTHORED_SEAMS.get(name, ()))
    unexpected_sides = touching_sides - allowed_sides
    missing_expected_sides = allowed_sides - touching_sides
    metrics["source_boundary_touch_sides"] = sorted(touching_sides)
    metrics["approved_authored_seam_sides"] = sorted(allowed_sides)
    if unexpected_sides:
        errors.append(
            f"{name}: foreground touches unexpected atlas cell side(s) "
            f"{', '.join(sorted(unexpected_sides))} (possible crop)"
        )
    if missing_expected_sides:
        errors.append(
            f"{name}: locked authored seam changed; expected touch on "
            f"{', '.join(sorted(missing_expected_sides))}"
        )
    if padding < 2:
        errors.append(f"{name}: output padding must be at least two pixels")
    return errors


def _save_rgba(rgb: Image.Image, alpha: Image.Image, raw_bbox: tuple[int, int, int, int], output: Path, padding: int) -> tuple[int, int]:
    rgba = rgb.convert("RGBA")
    rgba.putalpha(alpha)
    trimmed = rgba.crop(raw_bbox)
    canvas = Image.new("RGBA", (trimmed.width + padding * 2, trimmed.height + padding * 2), (0, 0, 0, 0))
    canvas.alpha_composite(trimmed, (padding, padding))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", compress_level=9, optimize=False)
    return canvas.size


def _manifest_rel(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def extract(project_root: Path, output_root: Path, padding: int) -> dict:
    errors: list[str] = []
    assets: list[dict] = []
    sources: list[dict] = []

    for spec in ATLASES:
        source_path = project_root / spec.source
        if not source_path.is_file():
            errors.append(f"missing source atlas: {spec.source.as_posix()}")
            continue
        source_hash = _sha256(source_path)
        if source_hash != spec.expected_sha256:
            errors.append(
                f"source hash mismatch for {spec.source.as_posix()}: "
                f"expected {spec.expected_sha256}, got {source_hash}"
            )
            continue

        with Image.open(source_path) as opened:
            if opened.mode != "RGB":
                errors.append(f"{spec.source.as_posix()}: expected baked RGB source, got {opened.mode}")
                continue
            atlas = opened.copy()

        expected_count = spec.columns * spec.rows
        if len(spec.names) != expected_count:
            errors.append(f"{spec.key}: name count does not match {spec.columns}x{spec.rows} grid")
            continue
        sources.append(
            {
                "key": spec.key,
                "path": spec.source.as_posix(),
                "sha256": source_hash,
                "mode": "RGB",
                "size": list(atlas.size),
                "grid": [spec.columns, spec.rows],
                "column_breaks_by_row": [list(breaks) for breaks in spec.column_breaks_by_row],
                "row_breaks": list(spec.row_breaks),
            }
        )

        for index, asset_name in enumerate(spec.names):
            bounds = _cell_bounds(spec, atlas.width, atlas.height, index)
            cell = atlas.crop(bounds)
            alpha = _edge_connected_background_alpha(cell)
            bbox = alpha.point(lambda value: 255 if value > 2 else 0).getbbox()
            if bbox is None:
                errors.append(f"{asset_name}: no extracted foreground")
                continue
            qa = _qa_metrics(cell, alpha, bbox)
            asset_errors = _validate_asset(asset_name, qa, padding)
            errors.extend(asset_errors)
            if asset_errors:
                continue

            filename = f"room_{spec.output_group[:-1] if spec.output_group.endswith('s') else spec.output_group}_{asset_name}_phase148.png"
            output_path = output_root / spec.output_group / filename
            output_size = _save_rgba(cell, alpha, bbox, output_path, padding)
            with Image.open(output_path) as check:
                output_mode = check.mode
                output_edge_alpha = 0
                if check.mode == "RGBA":
                    saved_alpha = check.getchannel("A")
                    edge_values: list[int] = []
                    edge_values.extend(saved_alpha.crop((0, 0, check.width, 1)).getdata())
                    edge_values.extend(saved_alpha.crop((0, check.height - 1, check.width, check.height)).getdata())
                    edge_values.extend(saved_alpha.crop((0, 1, 1, max(1, check.height - 1))).getdata())
                    edge_values.extend(saved_alpha.crop((check.width - 1, 1, check.width, max(1, check.height - 1))).getdata())
                    output_edge_alpha = max(edge_values, default=0)
            if output_mode != "RGBA" or output_edge_alpha != 0:
                errors.append(f"{asset_name}: saved PNG transparency/padding verification failed")
                output_path.unlink(missing_ok=True)
                continue

            assets.append(
                {
                    "id": asset_name,
                    "group": spec.output_group,
                    "source_index": index,
                    "source_cell_bounds": list(bounds),
                    "source_alpha_bounds": qa["raw_alpha_bounds"],
                    "output": _manifest_rel(output_path, project_root),
                    "output_mode": "RGBA",
                    "output_size": list(output_size),
                    "output_sha256": _sha256(output_path),
                    "padding": padding,
                    "rgb_policy": "retained_nontransparent_source_pixels_are_byte_exact",
                    "qa": qa,
                }
            )

    manifest = {
        "schema": "phase148_painted_room_assets_v1",
        "tool_version": TOOL_VERSION,
        "deterministic": True,
        "source_rgb_mutation": False,
        "alpha_method": "neutral_checker_component_removal_with_inward_only_feather_v3",
        "padding": padding,
        "sources": sources,
        "assets": assets,
        "qa": {
            "status": "PASSED" if not errors and len(assets) == 21 else "FAILED",
            "expected_asset_count": 21,
            "written_asset_count": len(assets),
            "errors": errors,
        },
    }
    return manifest


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--padding", type=int, default=10)
    args = parser.parse_args(list(argv) if argv is not None else None)

    project_root = args.project_root.resolve()
    output_root = args.output if args.output.is_absolute() else project_root / args.output
    allowed_root = (project_root / DEFAULT_OUTPUT).resolve()
    if output_root.resolve() != allowed_root:
        print(f"ERROR: output must be exactly {allowed_root}", file=sys.stderr)
        return 2
    if args.padding < 2 or args.padding > 64:
        print("ERROR: padding must be between 2 and 64 pixels", file=sys.stderr)
        return 2

    output_root.mkdir(parents=True, exist_ok=True)
    manifest = extract(project_root, output_root, args.padding)
    manifest_path = output_root / MANIFEST_NAME
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if manifest["qa"]["status"] != "PASSED":
        # Never leave partially accepted runtime assets behind.  The manifest is
        # retained as exact diagnostic evidence of why extraction was rejected.
        for group in ("plants", "decor"):
            group_path = output_root / group
            if group_path.is_dir():
                shutil.rmtree(group_path)
        print(json.dumps(manifest["qa"], ensure_ascii=False, indent=2), file=sys.stderr)
        return 1

    print(f"PHASE148_EXTRACTION=PASSED")
    print(f"PHASE148_ASSETS={len(manifest['assets'])}")
    print(f"PHASE148_MANIFEST={_manifest_rel(manifest_path, project_root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
