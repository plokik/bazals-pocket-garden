#!/usr/bin/env python3
"""Build the approved Phase 150 greenhouse integration sources deterministically.

The user-approved screen is preserved byte-for-byte as an immutable reference.
Only its content band is promoted to a canonical runtime master.  The existing
Phase 130 empty greenhouse is registered as a diagnostic clean donor candidate;
it is deliberately *not* called an approved clean plate because the paintings
do not match closely enough.  Likewise, no standalone RGBA crop is emitted from
the flattened RGB target unless an alpha-safe extraction can be proven.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageOps


TOOL_VERSION = 1
SOURCE_SHA256 = "0595991E42929303CAD1B0D033ABE22B16AA927599BE79BC23A0189E09654637"
SOURCE_SIZE = (864, 1821)
CONTENT_CROP_XYXY = (0, 145, 864, 1689)
CONTENT_SIZE = (864, 1544)

REFERENCE_RELATIVE = Path(
    "docs/visual-proposals/phase150/"
    "user-approved-greenhouse-screen-reference-v1.png"
)
CONTENT_REFERENCE_RELATIVE = Path(
    "docs/visual-proposals/phase150/greenhouse-exact-content-target-v1.png"
)
PHASE130_DONOR_RELATIVE = Path(
    "assets/ui/greenhouse/greenhouse_interior_phase130_two_boxes_v1.png"
)
PHASE130_DONOR_SHA256 = "1CD27B4F32B1C7039FDD3CF2CC8903963F01D44A77DBD223BAC85EDE06DF9321"
PHASE130_DONOR_SIZE = (887, 1774)

OUTPUT_ROOT_RELATIVE = Path("assets/ui/visual/phase150/greenhouse")
CANONICAL_NAME = "greenhouse_phase150_canonical_content_v1.png"
REGISTERED_DONOR_NAME = "greenhouse_phase150_registered_clean_donor_candidate_v1.png"
MANIFEST_NAME = "phase150_greenhouse_manifest.json"
QA_DIR_NAME = "qa"


@dataclass(frozen=True)
class Region:
    region_id: str
    kind: str
    full_bbox: tuple[int, int, int, int]
    full_polygon: tuple[tuple[int, int], ...] = ()


REGIONS = (
    Region("rear_box", "visual_box", (123, 744, 628, 191)),
    Region("front_box", "visual_box", (15, 977, 834, 341)),
    Region("bed_1", "functional_bay", (123, 744, 309, 191), ((150, 764), (414, 764), (413, 855), (127, 855))),
    Region("bed_2", "functional_bay", (432, 744, 319, 191), ((432, 764), (704, 764), (746, 855), (432, 855))),
    Region("bed_3", "functional_bay", (15, 977, 414, 341), ((104, 978), (410, 978), (405, 1196), (22, 1196))),
    Region("bed_4", "functional_bay", (429, 977, 420, 341), ((453, 978), (770, 978), (835, 1196), (430, 1196))),
)

# These are measurement envelopes only.  They are never exported as RGBA
# layers because the approved source is flattened RGB and its background does
# not agree with the available clean donor.
DYNAMIC_CANDIDATES = (
    Region("bed_2_seedlings", "candidate_dynamic_crop", (459, 747, 233, 111)),
    Region("bed_3_tomatoes", "candidate_dynamic_crop", (88, 943, 327, 254)),
    Region("bed_4_eggplants", "candidate_dynamic_crop", (451, 951, 361, 247)),
)

BACKGROUND_EVALUATION_RECTS_CONTENT = (
    (275, 145, 330, 435),
    (0, 300, 140, 280),
    (725, 300, 139, 270),
    (0, 790, 864, 40),
    (0, 1170, 864, 15),
)

CANONICAL_STATE = (
    {"bed_index": 0, "stage": "empty", "selected": True},
    {"bed_index": 1, "stage": "needs_water", "crop_visual": "seedlings", "selected": False},
    {"bed_index": 2, "stage": "growing", "crop_id": "cherry_tomato", "selected": False},
    {"bed_index": 3, "stage": "ready", "crop_id": "garden_eggplant", "selected": False},
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def _relative(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def _verify_image(path: Path, expected_hash: str, expected_size: tuple[int, int]) -> Image.Image:
    if not path.is_file():
        raise FileNotFoundError(path)
    actual_hash = _sha256(path)
    if actual_hash != expected_hash:
        raise ValueError(f"SHA-256 mismatch for {path}: {actual_hash} != {expected_hash}")
    image = Image.open(path)
    image.load()
    if image.size != expected_size:
        raise ValueError(f"size mismatch for {path}: {image.size} != {expected_size}")
    return image.convert("RGB")


def _lock_reference(root: Path, source: Path | None) -> Path:
    destination = root / REFERENCE_RELATIVE
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        _verify_image(destination, SOURCE_SHA256, SOURCE_SIZE)
        if source is not None:
            _verify_image(source, SOURCE_SHA256, SOURCE_SIZE)
        return destination
    if source is None:
        raise FileNotFoundError(
            "immutable Phase150 reference is missing; provide --source for the first run"
        )
    _verify_image(source, SOURCE_SHA256, SOURCE_SIZE)
    shutil.copyfile(source, destination)
    _verify_image(destination, SOURCE_SHA256, SOURCE_SIZE)
    return destination


def _full_to_content_bbox(bbox: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    x, y, width, height = bbox
    return (x - CONTENT_CROP_XYXY[0], y - CONTENT_CROP_XYXY[1], width, height)


def _full_to_content_point(point: tuple[int, int]) -> tuple[int, int]:
    return (point[0] - CONTENT_CROP_XYXY[0], point[1] - CONTENT_CROP_XYXY[1])


def _error_metrics(target: np.ndarray, candidate: np.ndarray, mask: np.ndarray | None = None) -> dict:
    if target.shape != candidate.shape:
        raise ValueError(f"shape mismatch: {target.shape} != {candidate.shape}")
    delta = target.astype(np.float32) - candidate.astype(np.float32)
    if mask is not None:
        if mask.shape != target.shape[:2]:
            raise ValueError("mask shape does not match target")
        values = delta[mask]
    else:
        values = delta.reshape((-1, 3))
    if values.size == 0:
        raise ValueError("metric mask is empty")
    absolute = np.abs(values)
    max_channel = np.max(absolute, axis=1)
    return {
        "sample_pixels": int(values.shape[0]),
        "mean_abs_error": round(float(np.mean(absolute)), 8),
        "rgb_rmse": round(float(np.sqrt(np.mean(np.square(values)))), 8),
        "max_channel_error": int(np.max(max_channel)),
        "ratio_pixels_over_12": round(float(np.mean(max_channel > 12.0)), 8),
        "ratio_pixels_over_24": round(float(np.mean(max_channel > 24.0)), 8),
    }


def _metric_status(metrics: dict) -> str:
    accepted = (
        float(metrics["mean_abs_error"]) <= 8.0
        and float(metrics["rgb_rmse"]) <= 20.0
        and float(metrics["ratio_pixels_over_12"]) <= 0.08
    )
    return "PASSED" if accepted else "FAILED"


def _save_rgb(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(path, format="PNG", optimize=False, compress_level=9)


def _geometry_payload(region: Region) -> dict:
    x, y, width, height = region.full_bbox
    content_bbox = _full_to_content_bbox(region.full_bbox)
    payload = {
        "id": region.region_id,
        "kind": region.kind,
        "full_bbox": [x, y, width, height],
        "content_bbox": list(content_bbox),
        "normalized_content_bbox": [
            round(content_bbox[0] / CONTENT_SIZE[0], 8),
            round(content_bbox[1] / CONTENT_SIZE[1], 8),
            round(content_bbox[2] / CONTENT_SIZE[0], 8),
            round(content_bbox[3] / CONTENT_SIZE[1], 8),
        ],
    }
    if region.full_polygon:
        content_polygon = [_full_to_content_point(point) for point in region.full_polygon]
        payload["full_polygon"] = [list(point) for point in region.full_polygon]
        payload["content_polygon"] = [list(point) for point in content_polygon]
        payload["normalized_content_polygon"] = [
            [round(point[0] / CONTENT_SIZE[0], 8), round(point[1] / CONTENT_SIZE[1], 8)]
            for point in content_polygon
        ]
    return payload


def _draw_geometry_overlay(content: Image.Image, output: Path) -> None:
    overlay = content.copy().convert("RGBA")
    draw = ImageDraw.Draw(overlay, "RGBA")
    colours = {
        "visual_box": (0, 221, 255, 235),
        "functional_bay": (255, 214, 32, 235),
        "candidate_dynamic_crop": (255, 67, 154, 235),
    }
    for region in (*REGIONS, *DYNAMIC_CANDIDATES):
        x, y, width, height = _full_to_content_bbox(region.full_bbox)
        colour = colours[region.kind]
        draw.rectangle((x, y, x + width - 1, y + height - 1), outline=colour, width=4)
        if region.full_polygon:
            polygon = [_full_to_content_point(point) for point in region.full_polygon]
            draw.line([*polygon, polygon[0]], fill=colour, width=4, joint="curve")
        label_width = max(92, 8 * len(region.region_id) + 12)
        draw.rectangle((x, y, min(x + label_width, CONTENT_SIZE[0] - 1), y + 22), fill=(6, 25, 34, 220))
        draw.text((x + 5, y + 4), region.region_id, fill=(255, 255, 255, 255))
    _save_rgb(overlay, output)


def _build(root: Path, source: Path | None) -> dict:
    reference_path = _lock_reference(root, source)
    full_reference = _verify_image(reference_path, SOURCE_SHA256, SOURCE_SIZE)
    content = full_reference.crop(CONTENT_CROP_XYXY).convert("RGB")
    if content.size != CONTENT_SIZE:
        raise AssertionError(f"unexpected content size: {content.size}")

    content_reference_path = root / CONTENT_REFERENCE_RELATIVE
    canonical_path = root / OUTPUT_ROOT_RELATIVE / CANONICAL_NAME
    donor_candidate_path = root / OUTPUT_ROOT_RELATIVE / REGISTERED_DONOR_NAME
    qa_root = root / OUTPUT_ROOT_RELATIVE / QA_DIR_NAME
    manifest_path = root / OUTPUT_ROOT_RELATIVE / MANIFEST_NAME

    _save_rgb(content, content_reference_path)
    canonical_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(content_reference_path, canonical_path)

    phase130_path = root / PHASE130_DONOR_RELATIVE
    phase130 = _verify_image(phase130_path, PHASE130_DONOR_SHA256, PHASE130_DONOR_SIZE)
    donor_candidate = ImageOps.fit(
        phase130,
        CONTENT_SIZE,
        method=Image.Resampling.LANCZOS,
        centering=(0.5, 0.5),
    ).convert("RGB")
    _save_rgb(donor_candidate, donor_candidate_path)

    target_array = np.asarray(content, dtype=np.uint8)
    donor_array = np.asarray(donor_candidate, dtype=np.uint8)
    evaluation_mask = np.zeros(CONTENT_SIZE[::-1], dtype=bool)
    for x, y, width, height in BACKGROUND_EVALUATION_RECTS_CONTENT:
        evaluation_mask[y : y + height, x : x + width] = True
    full_metrics = _error_metrics(target_array, donor_array)
    background_metrics = _error_metrics(target_array, donor_array, evaluation_mask)
    donor_status = _metric_status(background_metrics)

    candidate_metrics = []
    for region in DYNAMIC_CANDIDATES:
        x, y, width, height = _full_to_content_bbox(region.full_bbox)
        patch_metrics = _error_metrics(
            target_array[y : y + height, x : x + width],
            donor_array[y : y + height, x : x + width],
        )
        candidate_metrics.append(
            {
                **_geometry_payload(region),
                "target_vs_registered_donor": patch_metrics,
                "standalone_rgba_emitted": False,
                "qa_status": "FAILED",
                "reason": "flattened RGB target plus failed clean-donor similarity cannot prove an alpha-safe silhouette",
            }
        )

    qa_root.mkdir(parents=True, exist_ok=True)
    geometry_overlay_path = qa_root / "phase150_geometry_overlay.png"
    _draw_geometry_overlay(content, geometry_overlay_path)
    absolute_delta = np.abs(target_array.astype(np.int16) - donor_array.astype(np.int16))
    heat = np.max(absolute_delta, axis=2).astype(np.uint8)
    heat_rgb = np.stack(
        [heat, np.clip(heat.astype(np.int16) * 2, 0, 255).astype(np.uint8), np.zeros_like(heat)],
        axis=2,
    )
    heatmap_path = qa_root / "phase150_registered_donor_difference_heatmap.png"
    _save_rgb(Image.fromarray(heat_rgb, mode="RGB"), heatmap_path)

    content_hash = _sha256(content_reference_path)
    canonical_hash = _sha256(canonical_path)
    donor_hash = _sha256(donor_candidate_path)
    canonical_exact = content_reference_path.read_bytes() == canonical_path.read_bytes()
    manifest = {
        "schema": "phase150_greenhouse_assets_v1",
        "tool_version": TOOL_VERSION,
        "deterministic": True,
        "coordinate_space": {
            "full_screen_size": list(SOURCE_SIZE),
            "content_crop_xyxy": list(CONTENT_CROP_XYXY),
            "content_size": list(CONTENT_SIZE),
            "bbox_format": "x_y_width_height",
            "mapping_policy": "map all runtime geometry through normalized content coordinates",
        },
        "sources": {
            "user_approved_full_reference": {
                "path": _relative(reference_path, root),
                "sha256": SOURCE_SHA256,
                "size": list(SOURCE_SIZE),
                "mode": "RGB",
                "immutable": True,
                "approval": "APPROVED_BY_USER_2026-08-25",
            },
            "content_reference": {
                "path": _relative(content_reference_path, root),
                "sha256": content_hash,
                "size": list(CONTENT_SIZE),
                "mode": "RGB",
                "immutable": True,
            },
            "phase130_clean_donor": {
                "path": _relative(phase130_path, root),
                "sha256": PHASE130_DONOR_SHA256,
                "size": list(PHASE130_DONOR_SIZE),
                "mode": "RGB",
                "immutable": True,
            },
        },
        "canonical_content_master": {
            "output": _relative(canonical_path, root),
            "output_sha256": canonical_hash,
            "mode": "RGB",
            "size": list(CONTENT_SIZE),
            "byte_exact_content_reference_copy": canonical_exact,
            "coverage": {
                "status": "PASSED" if canonical_exact else "FAILED",
                "mean_abs_error": 0.0 if canonical_exact else None,
                "rgb_rmse": 0.0 if canonical_exact else None,
                "max_channel_error": 0 if canonical_exact else None,
                "exact_pixel_ratio": 1.0 if canonical_exact else 0.0,
            },
            "canonical_state": list(CANONICAL_STATE),
            "baked_elements": [
                "location_title_and_subtitle",
                "rack_return_button",
                "reputation_panel",
                "two_raised_growing_boxes",
                "four_bay_number_badges",
                "selected_bed_status_card",
                "five_crop_choice_buttons",
                "bed_2_seedlings",
                "bed_3_tomatoes",
                "bed_4_eggplants",
            ],
        },
        "geometry": {
            "visual_box_count": 2,
            "functional_bay_count": 4,
            "bays_per_box": 2,
            "regions": [_geometry_payload(region) for region in REGIONS],
            "bed_number_badge_centers_full": [[175, 800], [468, 800], [116, 1028], [469, 1028]],
            "bed_number_badge_centers_content": [[175, 655], [468, 655], [116, 883], [469, 883]],
            "soil_baseline_y_full": [855, 855, 1196, 1196],
            "soil_baseline_y_content": [710, 710, 1051, 1051],
        },
        "registered_clean_donor_candidate": {
            "output": _relative(donor_candidate_path, root),
            "output_sha256": donor_hash,
            "mode": "RGB",
            "size": list(CONTENT_SIZE),
            "registration": "PIL_ImageOps.fit_LANCZOS_center_0.5_0.5_to_864x1544",
            "full_frame_metrics": full_metrics,
            "background_evaluation_rects_content": [list(rect) for rect in BACKGROUND_EVALUATION_RECTS_CONTENT],
            "background_evaluation_metrics": background_metrics,
            "qa_thresholds": {
                "mean_abs_error_max": 8.0,
                "rgb_rmse_max": 20.0,
                "ratio_pixels_over_12_max": 0.08,
            },
            "qa_status": donor_status,
            "integration_authorized_as_clean_plate": donor_status == "PASSED",
        },
        "clean_plate": {
            "status": "FAILED",
            "output": None,
            "reason": "the only object-free donor fails target-style and pixel-similarity thresholds; exporting it as the approved clean plate would be misleading",
        },
        "standalone_dynamic_rgba_layers": {
            "status": "FAILED",
            "emitted_count": 0,
            "policy": "do not emit target crops as RGBA unless target background can be removed against a sufficiently matching clean plate",
            "candidates": candidate_metrics,
        },
        "qa_outputs": {
            "geometry_overlay": {
                "path": _relative(geometry_overlay_path, root),
                "sha256": _sha256(geometry_overlay_path),
            },
            "registered_donor_difference_heatmap": {
                "path": _relative(heatmap_path, root),
                "sha256": _sha256(heatmap_path),
            },
        },
    }
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, default=None)
    args = parser.parse_args()
    try:
        manifest = _build(args.root.resolve(), args.source.resolve() if args.source else None)
    except Exception as error:  # deterministic CLI boundary
        print(f"PHASE150_ASSET_BUILD=FAILED: {error}", file=sys.stderr)
        return 1
    canonical = manifest["canonical_content_master"]
    donor = manifest["registered_clean_donor_candidate"]
    print(f"PHASE150_REFERENCE_SHA256={SOURCE_SHA256}")
    print(f"PHASE150_CONTENT_SHA256={canonical['output_sha256']}")
    print(f"PHASE150_CANONICAL_COVERAGE={canonical['coverage']['status']}")
    print(f"PHASE150_CLEAN_PLATE={manifest['clean_plate']['status']}")
    print(f"PHASE150_REGISTERED_DONOR_QA={donor['qa_status']}")
    print(f"PHASE150_DYNAMIC_RGBA={manifest['standalone_dynamic_rgba_layers']['status']}")
    print("PHASE150_ASSET_BUILD=PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
