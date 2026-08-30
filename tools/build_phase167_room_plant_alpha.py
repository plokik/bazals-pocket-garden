"""Restore lost petal/leaf alpha from the immutable room atlas, without repainting.

Phase148's broad (110) chroma threshold treated pale pink petals as background.
The plant-only threshold is 48; connectivity still removes the neutral checker
between stems. Original RGB, source coordinates, crop and transparent padding
are retained. Outputs are append-only Phase167 derivatives, never Phase148 PNGs.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


SOURCE = "docs/visual-proposals/phase147/player-room-painted-cartoon-plants-atlas-checker-source-v1.png"
SOURCE_SHA256 = "0735BB39144E113228088973DE87B4A4C655D5557391477D54E0BE4513572D24"
LEGACY_MANIFEST = "assets/ui/visual/phase148/player_room/phase148_painted_room_assets_manifest.json"
OUTPUT = "assets/ui/visual/phase167/player_room"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def foreground_alpha(rgb: Image.Image) -> Image.Image:
    """Same component/edge policy as Phase148; only chroma tolerance is narrowed."""
    colors = np.asarray(rgb, dtype=np.int16)
    height, width = colors.shape[:2]
    chroma = colors.max(axis=2) - colors.min(axis=2)
    # int32 prevents overflow in the fixed-point luminance sum.
    luminance = (colors.astype(np.int32) * np.array([54, 183, 19])).sum(axis=2) // 256
    candidates = ((colors.min(axis=2) >= 90) & (chroma <= 48)).ravel()
    checker = ((luminance >= 235) & (chroma <= 8)).ravel()
    visited = bytearray(width * height)
    background = np.zeros(width * height, dtype=bool)
    for start in np.flatnonzero(candidates):
        start = int(start)
        if visited[start]:
            continue
        visited[start] = 1
        queue = deque([start])
        component: list[int] = []
        edge = False
        checker_count = 0
        while queue:
            offset = queue.popleft()
            component.append(offset)
            x, y = offset % width, offset // width
            checker_count += int(checker[offset])
            edge = edge or x == 0 or y == 0 or x == width - 1 or y == height - 1
            neighbours = []
            if x > 0:
                neighbours.append(offset - 1)
            if x + 1 < width:
                neighbours.append(offset + 1)
            if y > 0:
                neighbours.append(offset - width)
            if y + 1 < height:
                neighbours.append(offset + width)
            for neighbour in neighbours:
                if candidates[neighbour] and not visited[neighbour]:
                    visited[neighbour] = 1
                    queue.append(neighbour)
        if edge or (len(component) >= 16 and checker_count / len(component) >= 0.55):
            background[component] = True
    background = background.reshape(height, width)
    hard = Image.fromarray(np.where(background, 0, 255).astype(np.uint8))
    soft = np.asarray(hard.filter(ImageFilter.GaussianBlur(0.65)))
    return Image.fromarray(np.where(background, 0, np.maximum(96, soft)).astype(np.uint8))


def build(root: Path, check: bool = False) -> dict:
    source_path = root / SOURCE
    assert sha256(source_path) == SOURCE_SHA256, "Immutable plant atlas changed"
    atlas = Image.open(source_path).convert("RGB")
    legacy = json.loads((root / LEGACY_MANIFEST).read_text(encoding="utf-8"))
    records = []
    pending: list[tuple[Path, Image.Image]] = []
    for record in legacy["assets"]:
        if record["group"] != "plants":
            continue
        old_path = root / record["output"]
        assert sha256(old_path) == record["output_sha256"].upper(), f"Historical PNG changed: {old_path}"
        old_image = Image.open(old_path).convert("RGBA")
        old = np.asarray(old_image)
        cell = atlas.crop(record["source_cell_bounds"])
        alpha = foreground_alpha(cell)
        left, top, right, bottom = record["source_alpha_bounds"]
        padding = record["padding"]
        # Keep the old canvas/pivot exactly; restored pixels must not be cropped.
        crop = (left - padding, top - padding, right + padding, bottom + padding)
        source_rgba = cell.convert("RGBA")
        source_rgba.putalpha(alpha)
        output_image = source_rgba.crop(crop)
        result = np.array(output_image)
        assert result.shape == old.shape, f"Canvas moved: {record['id']}"
        # Recovery is additive only, including old antialiased contact shadows.
        result[:, :, 3] = np.maximum(result[:, :, 3], old[:, :, 3])
        # Straight-alpha textures must not keep the baked checker in invisible
        # RGB; Godot's alpha-border import then extends only real painted edges.
        result[result[:, :, 3] == 0, :3] = 0
        visible_old = old[:, :, 3] > 0
        assert np.array_equal(result[:, :, :3][visible_old], old[:, :, :3][visible_old]), "RGB repaint forbidden"
        restored = (old[:, :, 3] == 0) & (result[:, :, 3] > 0)
        rgb32 = result[:, :, :3].astype(np.int32)
        pink = (rgb32[:, :, 0] > 140) & (rgb32[:, :, 2] > 80) & (rgb32[:, :, 0] - rgb32[:, :, 1] >= 25) & (rgb32[:, :, 2] - rgb32[:, :, 1] >= 10)
        # No new distant fragments, checker rectangles, or clipped output edges.
        vicinity = np.asarray(Image.fromarray((visible_old * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(17))) > 0
        assert not np.any(restored & ~vicinity), f"New disconnected halo: {record['id']}"
        border = np.concatenate((result[0, :, 3], result[-1, :, 3], result[:, 0, 3], result[:, -1, 3]))
        assert int(border.max()) == 0, f"Recovery cropped at canvas edge: {record['id']}"
        output_image = Image.fromarray(result)
        output_path = root / OUTPUT / "plants" / f"room_plant_{record['id']}_phase167.png"
        records.append({
            "id": record["id"],
            "source": record["output"],
            "source_sha256": record["output_sha256"],
            "output": output_path.relative_to(root).as_posix(),
            "size": list(output_image.size),
            "restored_pixels": int(restored.sum()),
            "restored_pink_pixels": int((restored & pink).sum()),
            "rgb_byte_exact_to_atlas": True,
            "old_visible_rgb_preserved": True,
            "old_alpha_not_removed": True,
            "new_alpha_within_8px_of_original": True,
            "transparent_canvas_border": True,
        })
        pending.append((output_path, output_image))
    assert len(records) == 12, "Must audit the complete rack"
    # Validate all twelve before writing; never delete or replace legacy assets.
    for (path, output_image), record in zip(pending, records):
        if path.exists():
            current = np.asarray(Image.open(path).convert("RGBA"))
            if not np.array_equal(current, np.asarray(output_image)):
                assert not check, f"Derivative differs from recomputation: {path}"
                output_image.save(path, compress_level=9)
        else:
            assert not check, f"Missing derivative: {path}"
            path.parent.mkdir(parents=True, exist_ok=True)
            output_image.save(path, compress_level=9)
        record["output_sha256"] = sha256(path)
    manifest = {
        "schema": "phase167_room_plant_alpha_v1",
        "status": "PASSED",
        "method": "plant_only_chroma48_connected_background_inward_feather_rgb_unchanged",
        "source_atlas": SOURCE,
        "source_atlas_sha256": SOURCE_SHA256,
        "historical_png_policy": "unchanged_append_only_derivatives",
        "assets": records,
    }
    manifest_path = root / OUTPUT / "phase167_plant_alpha_manifest.json"
    if check:
        assert json.loads(manifest_path.read_text(encoding="utf-8")) == manifest, "Manifest differs from recomputation"
    else:
        contents = json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
        manifest_path.write_text(contents, encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Recompute and verify without writing assets")
    args = parser.parse_args()
    manifest = build(Path(__file__).resolve().parents[1], args.check)
    print("PHASE167_PLANT_ALPHA=PASSED")
    print(f"PHASE167_PLANTS={len(manifest['assets'])}")
    print(f"PHASE167_RESTORED_PINK_PIXELS={sum(a['restored_pink_pixels'] for a in manifest['assets'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
