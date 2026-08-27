#!/usr/bin/env python3
"""Build the append-only Phase 158 object-free room foreground.

Phase 149 source paintings and their geometry stay immutable. The historical
foreground accidentally copied shelf-front pixels from the fully furnished
reference and therefore contained fragments of collectibles. This builder
keeps its alpha mask byte-for-byte and replaces only visible RGB with pixels
from the approved object-free clean plate.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
CLEAN_REL = Path("assets/ui/player_room/player_room_phase149_target_clean_v1.png")
OLD_REL = Path("assets/ui/visual/phase149/player_room/player_room_furniture_foreground_v1.png")
OUTPUT_REL = Path("assets/ui/visual/phase158/player_room/player_room_furniture_foreground_phase158_v2.png")
MANIFEST_REL = Path("assets/ui/visual/phase158/player_room/phase158_room_compositing_manifest.json")
FERN_SOURCE_REL = Path("assets/ui/visual/phase149/player_room/plants/room_plant_fern_phase149.png")
FERN_TEMPLATE_REL = Path("assets/ui/visual/phase148/player_room/plants/room_plant_fern_phase148.png")
FERN_OUTPUT_REL = Path("assets/ui/visual/phase158/player_room/plants/room_plant_fern_phase158_v2.png")
FERN_ENVELOPE_MARGIN = 4
FERN_BOTTOM_RIGHT_CONTOUR_START_Y = 168
FERN_BOTTOM_RIGHT_CONTOUR_OFFSET = -6
CONTENT_SIZE = (853, 1548)
CONTENT_CROP_Y = 137
OCCLUSION_RECTS_FULL = (
    (48, 811, 442, 32),
    (49, 1044, 442, 22),
    (49, 1284, 442, 27),
    (49, 1505, 442, 20),
    (507, 411, 336, 22),
    (508, 607, 335, 23),
    (536, 1207, 277, 24),
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def _build_fern_alpha_cleanup(source: Image.Image, template: Image.Image) -> tuple[Image.Image, dict]:
    source_array = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    template_rgba = template.convert("RGBA")
    bounds = template_rgba.getchannel("A").point(lambda value: 255 if value > 2 else 0).getbbox()
    if bounds is None:
        raise ValueError("fern topology template has no visible alpha")
    trimmed = template_rgba.crop(bounds)
    inset = 4
    resized = trimmed.resize(
        (max(1, source.width - inset * 2), max(1, source.height - inset * 2)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("L", source.size, 0)
    canvas.paste(resized.getchannel("A"), (inset, inset))
    prior = np.asarray(canvas, dtype=np.uint8) > 3
    row_envelope = np.zeros_like(prior, dtype=bool)
    for y in range(source.height):
        xs = np.flatnonzero(prior[y])
        if xs.size:
            left = max(0, int(xs[0]) - FERN_ENVELOPE_MARGIN)
            right = min(source.width, int(xs[-1]) + FERN_ENVELOPE_MARGIN + 1)
            row_envelope[y, left:right] = True
    column_envelope = np.zeros_like(prior, dtype=bool)
    for x in range(source.width):
        ys = np.flatnonzero(prior[:, x])
        if ys.size:
            top = max(0, int(ys[0]) - FERN_ENVELOPE_MARGIN)
            bottom = min(source.height, int(ys[-1]) + FERN_ENVELOPE_MARGIN + 1)
            column_envelope[top:bottom, x] = True

    old_alpha = source_array[:, :, 3].copy()
    keep = (old_alpha > 0) & row_envelope & column_envelope
    # The approved target crop contains a thin shelf-colored contact streak to
    # the right of the fern saucer.  Below the pot body, follow the clean
    # topology contour slightly inside its antialias edge instead of preserving
    # the old +4 px safety margin that admitted that streak.
    for y in range(FERN_BOTTOM_RIGHT_CONTOUR_START_Y, source.height):
        xs = np.flatnonzero(prior[y])
        if xs.size:
            right_contour = max(0, int(xs[-1]) + FERN_BOTTOM_RIGHT_CONTOUR_OFFSET)
            keep[y, right_contour + 1:] = False
    source_array[~keep, 3] = 0
    source_array[source_array[:, :, 3] == 0, :3] = 0
    visible = source_array[:, :, 3] > 0
    original_rgb = np.asarray(source.convert("RGBA"), dtype=np.uint8)[:, :, :3]
    visible_rgb_preserved = bool(
        np.array_equal(source_array[:, :, :3][visible], original_rgb[visible])
    )
    alpha_subset = bool(np.all(source_array[:, :, 3] <= old_alpha))
    removed = int(np.count_nonzero(old_alpha > 0) - np.count_nonzero(visible))
    if not visible_rgb_preserved or not alpha_subset or removed <= 0:
        raise ValueError(
            "fern alpha cleanup invariant failed: "
            f"rgb_preserved={visible_rgb_preserved}, alpha_subset={alpha_subset}, removed={removed}"
        )
    return Image.fromarray(source_array, mode="RGBA"), {
        "policy": "phase148_orthogonal_envelope_margin4_bottom_right_contour_alpha_only_v3",
        "visible_rgb_byte_exact_to_phase149": visible_rgb_preserved,
        "alpha_is_subset_of_phase149": alpha_subset,
        "removed_visible_alpha_pixels": removed,
        "envelope_margin_pixels": FERN_ENVELOPE_MARGIN,
        "bottom_right_contour_start_y": FERN_BOTTOM_RIGHT_CONTOUR_START_Y,
        "bottom_right_contour_offset_pixels": FERN_BOTTOM_RIGHT_CONTOUR_OFFSET,
        "shelf_tail_possible": False,
    }


def main() -> int:
    clean_path = PROJECT_ROOT / CLEAN_REL
    old_path = PROJECT_ROOT / OLD_REL
    output_path = PROJECT_ROOT / OUTPUT_REL
    manifest_path = PROJECT_ROOT / MANIFEST_REL

    with Image.open(clean_path) as opened:
        clean = opened.convert("RGBA")
    with Image.open(old_path) as opened:
        old = opened.convert("RGBA")
    if clean.size != CONTENT_SIZE or old.size != CONTENT_SIZE:
        raise ValueError(
            f"unexpected room layer sizes: clean={clean.size}, old={old.size}, expected={CONTENT_SIZE}"
        )

    clean_array = np.asarray(clean, dtype=np.uint8)
    old_array = np.asarray(old, dtype=np.uint8)
    output_array = np.zeros_like(old_array)
    output_array[:, :, :3] = clean_array[:, :, :3]
    output_array[:, :, 3] = old_array[:, :, 3]
    output_array[output_array[:, :, 3] == 0, :3] = 0

    alpha_equal = bool(np.array_equal(output_array[:, :, 3], old_array[:, :, 3]))
    visible = output_array[:, :, 3] > 0
    visible_rgb_clean = bool(
        np.array_equal(output_array[:, :, :3][visible], clean_array[:, :, :3][visible])
    )
    changed_visible_pixels = int(
        np.count_nonzero(
            np.any(output_array[:, :, :3] != old_array[:, :, :3], axis=2) & visible
        )
    )
    if not alpha_equal or not visible_rgb_clean or changed_visible_pixels <= 0:
        raise ValueError(
            "Phase 158 foreground invariant failed: "
            f"alpha_equal={alpha_equal}, visible_rgb_clean={visible_rgb_clean}, "
            f"changed_visible_pixels={changed_visible_pixels}"
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(output_array, mode="RGBA").save(
        output_path, format="PNG", compress_level=9, optimize=False
    )

    fern_source_path = PROJECT_ROOT / FERN_SOURCE_REL
    fern_template_path = PROJECT_ROOT / FERN_TEMPLATE_REL
    fern_output_path = PROJECT_ROOT / FERN_OUTPUT_REL
    with Image.open(fern_source_path) as opened:
        fern_source = opened.convert("RGBA")
    with Image.open(fern_template_path) as opened:
        fern_template = opened.convert("RGBA")
    fern_output, fern_qa = _build_fern_alpha_cleanup(fern_source, fern_template)
    fern_output_path.parent.mkdir(parents=True, exist_ok=True)
    fern_output.save(fern_output_path, format="PNG", compress_level=9, optimize=False)

    report = {
        "phase": 158,
        "status": "PASSED",
        "policy": "append_only_object_free_foreground_same_alpha_geometry_v2",
        "clean_plate": {"path": CLEAN_REL.as_posix(), "sha256": _sha256(clean_path)},
        "historical_foreground": {
            "path": OLD_REL.as_posix(),
            "sha256": _sha256(old_path),
            "preserved": True,
        },
        "foreground": {
            "output": OUTPUT_REL.as_posix(),
            "sha256": _sha256(output_path),
            "size": list(CONTENT_SIZE),
            "source_rects_full": [list(rect) for rect in OCCLUSION_RECTS_FULL],
            "content_crop_y": CONTENT_CROP_Y,
            "qa": {
                "alpha_geometry_byte_exact_to_phase149": alpha_equal,
                "visible_rgb_byte_exact_to_clean_plate": visible_rgb_clean,
                "changed_visible_pixels_vs_phase149": changed_visible_pixels,
                "baked_collectible_pixels_possible": False,
            },
        },
        "cleaned_assets": [
            {
                "id": "fern",
                "source": FERN_SOURCE_REL.as_posix(),
                "source_sha256": _sha256(fern_source_path),
                "topology_template": FERN_TEMPLATE_REL.as_posix(),
                "topology_template_sha256": _sha256(fern_template_path),
                "output": FERN_OUTPUT_REL.as_posix(),
                "output_sha256": _sha256(fern_output_path),
                "size": list(fern_output.size),
                "qa": fern_qa,
            }
        ],
    }
    manifest_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(f"PHASE158_FOREGROUND={output_path}")
    print(f"PHASE158_FERN={fern_output_path}")
    print(f"PHASE158_CHANGED_VISIBLE_PIXELS={changed_visible_pixels}")
    print("PHASE158_ROOM_COMPOSITING=PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
