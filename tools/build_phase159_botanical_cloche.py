#!/usr/bin/env python3
"""Build the approved Phase 159 botanical cloche as a clean RGBA asset.

The source is an immutable RGB painting on a nearly flat magenta plate.  This
builder derives a soft matte deterministically, keeps only the largest central
subject, removes magenta spill from antialiased pixels, and crops the result
with a transparent safety margin.  No source pixels are ever written.
"""

from __future__ import annotations

from collections import deque
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_REL = Path(
    "assets/ui/visual/phase159/source/"
    "botanical_cloche_chroma_source_phase159_v1.png"
)
OUTPUT_REL = Path(
    "assets/ui/visual/phase159/player_room/decor/"
    "botanical_cloche_phase159_v1.png"
)
QA_REL = Path("assets/ui/visual/phase159/phase159_botanical_cloche_qa.json")

BORDER_SAMPLE = 32
TRANSPARENT_DISTANCE = 12.0
OPAQUE_DISTANCE = 168.0
MAGENTA_DOMINANCE_MIN = 12.0
COMPONENT_ALPHA_MIN = 16
EDGE_SUPPORT_DILATIONS = 3
TRANSPARENT_PADDING = 32
FRINGE_ALPHA_MIN = 8
FRINGE_MAGENTA_DOMINANCE = 24


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def _smoothstep(values: np.ndarray) -> np.ndarray:
    clipped = np.clip(values, 0.0, 1.0)
    return clipped * clipped * (3.0 - 2.0 * clipped)


def _estimate_key(rgb: np.ndarray) -> np.ndarray:
    height, width, _channels = rgb.shape
    sample = min(BORDER_SAMPLE, max(1, height // 8), max(1, width // 8))
    border = np.concatenate(
        (
            rgb[:sample, :, :].reshape(-1, 3),
            rgb[-sample:, :, :].reshape(-1, 3),
            rgb[sample:-sample, :sample, :].reshape(-1, 3),
            rgb[sample:-sample, -sample:, :].reshape(-1, 3),
        ),
        axis=0,
    )
    return np.rint(np.median(border, axis=0)).astype(np.uint8)


def _largest_component(mask: np.ndarray) -> tuple[np.ndarray, int, int]:
    """Return the largest 8-connected component and component statistics."""

    height, width = mask.shape
    visited = np.zeros(mask.shape, dtype=bool)
    largest_indices: list[int] = []
    component_count = 0

    for start in np.flatnonzero(mask.reshape(-1)):
        if visited.flat[start]:
            continue
        component_count += 1
        queue: deque[int] = deque((int(start),))
        visited.flat[start] = True
        indices: list[int] = []
        while queue:
            index = queue.popleft()
            indices.append(index)
            y, x = divmod(index, width)
            y0 = max(0, y - 1)
            y1 = min(height - 1, y + 1)
            x0 = max(0, x - 1)
            x1 = min(width - 1, x + 1)
            for neighbour_y in range(y0, y1 + 1):
                row_offset = neighbour_y * width
                for neighbour_x in range(x0, x1 + 1):
                    neighbour = row_offset + neighbour_x
                    if mask.flat[neighbour] and not visited.flat[neighbour]:
                        visited.flat[neighbour] = True
                        queue.append(neighbour)
        if len(indices) > len(largest_indices):
            largest_indices = indices

    largest = np.zeros(mask.shape, dtype=bool)
    if largest_indices:
        largest.flat[np.asarray(largest_indices, dtype=np.int64)] = True
    return largest, len(largest_indices), component_count


def _dilate_eight(mask: np.ndarray) -> np.ndarray:
    padded = np.pad(mask, 1, mode="constant", constant_values=False)
    output = np.zeros_like(mask)
    height, width = mask.shape
    for y_offset in range(3):
        for x_offset in range(3):
            output |= padded[y_offset : y_offset + height, x_offset : x_offset + width]
    return output


def _build_alpha(rgb: np.ndarray, key: np.ndarray) -> tuple[np.ndarray, dict]:
    values = rgb.astype(np.float32)
    key_values = key.astype(np.float32)
    distance = np.max(np.abs(values - key_values), axis=2)
    magenta_dominance = np.minimum(values[:, :, 0], values[:, :, 2]) - values[:, :, 1]
    magenta_family = magenta_dominance >= MAGENTA_DOMINANCE_MIN

    ratio = (distance - TRANSPARENT_DISTANCE) / (
        OPAQUE_DISTANCE - TRANSPARENT_DISTANCE
    )
    keyed_alpha = np.rint(255.0 * _smoothstep(ratio)).astype(np.uint8)
    raw_alpha = np.where(magenta_family, keyed_alpha, 255).astype(np.uint8)

    component_seed = raw_alpha >= COMPONENT_ALPHA_MIN
    largest, largest_size, component_count = _largest_component(component_seed)
    if largest_size == 0:
        raise ValueError("Phase 159 cloche extraction found no foreground component")

    support = largest.copy()
    for _index in range(EDGE_SUPPORT_DILATIONS):
        support = _dilate_eight(support)
    alpha = np.where(support, raw_alpha, 0).astype(np.uint8)

    center_y = rgb.shape[0] // 2
    center_x = rgb.shape[1] // 2
    if not largest[center_y, center_x]:
        raise ValueError("largest extracted component does not contain the image centre")

    return alpha, {
        "estimated_key_rgb": [int(value) for value in key],
        "seed_component_count": int(component_count),
        "largest_component_seed_pixels": int(largest_size),
        "discarded_seed_pixels": int(np.count_nonzero(component_seed) - largest_size),
    }


def _despill(rgb: np.ndarray, alpha: np.ndarray, key: np.ndarray) -> np.ndarray:
    """Recover straight-alpha edge RGB and clamp residual magenta spill."""

    values = rgb.astype(np.float32)
    output = values.copy()
    partial = (alpha > 0) & (alpha < 255)
    if np.any(partial):
        alpha_fraction = np.maximum(alpha.astype(np.float32) / 255.0, 1.0 / 255.0)
        recovered = (
            values - (1.0 - alpha_fraction[:, :, None]) * key.astype(np.float32)
        ) / alpha_fraction[:, :, None]
        recovered = np.clip(recovered, 0.0, 255.0)
        output[partial] = recovered[partial]

        red = output[:, :, 0]
        green = output[:, :, 1]
        blue = output[:, :, 2]
        excess = np.maximum(0.0, np.minimum(red, blue) - green - 6.0)
        # Every partially transparent pixel belongs to the keyed silhouette,
        # not to the opaque painting.  Remove the complete red/blue excess so
        # even nearly opaque antialias samples cannot retain a pink contour.
        correction = np.where(partial, excess, 0.0)
        output[:, :, 0] -= correction
        output[:, :, 2] -= correction
        output[:, :, 1] += correction * 0.12

    output = np.clip(np.rint(output), 0.0, 255.0).astype(np.uint8)
    output[alpha == 0] = 0
    return output


def _crop_with_padding(
    rgb: np.ndarray, alpha: np.ndarray
) -> tuple[np.ndarray, tuple[int, int, int, int]]:
    visible_y, visible_x = np.nonzero(alpha > 0)
    if visible_x.size == 0:
        raise ValueError("Phase 159 cloche extraction produced an empty image")
    left = int(visible_x.min())
    top = int(visible_y.min())
    right = int(visible_x.max()) + 1
    bottom = int(visible_y.max()) + 1

    content_rgb = rgb[top:bottom, left:right]
    content_alpha = alpha[top:bottom, left:right]
    output = np.zeros(
        (
            content_alpha.shape[0] + TRANSPARENT_PADDING * 2,
            content_alpha.shape[1] + TRANSPARENT_PADDING * 2,
            4,
        ),
        dtype=np.uint8,
    )
    y_slice = slice(TRANSPARENT_PADDING, TRANSPARENT_PADDING + content_alpha.shape[0])
    x_slice = slice(TRANSPARENT_PADDING, TRANSPARENT_PADDING + content_alpha.shape[1])
    output[y_slice, x_slice, :3] = content_rgb
    output[y_slice, x_slice, 3] = content_alpha
    return output, (left, top, right, bottom)


def _qa(output: np.ndarray) -> dict:
    alpha = output[:, :, 3]
    rgb = output[:, :, :3]
    zero = alpha == 0
    full = alpha == 255
    partial = (alpha > 0) & (alpha < 255)
    border = np.concatenate((alpha[0, :], alpha[-1, :], alpha[:, 0], alpha[:, -1]))

    dominance = (
        np.minimum(rgb[:, :, 0].astype(np.int16), rgb[:, :, 2].astype(np.int16))
        - rgb[:, :, 1].astype(np.int16)
    )
    fringe = (
        (alpha >= FRINGE_ALPHA_MIN)
        & (alpha < 255)
        & (dominance > FRINGE_MAGENTA_DOMINANCE)
    )
    fringe_pixels = int(np.count_nonzero(fringe))
    visible_pixels = int(np.count_nonzero(alpha))
    fringe_fraction = float(fringe_pixels / max(1, visible_pixels))

    checks = {
        "mode_is_rgba": output.shape[2] == 4,
        "has_fully_transparent_pixels": bool(np.any(zero)),
        "has_fully_opaque_pixels": bool(np.any(full)),
        "has_partial_alpha_pixels": bool(np.any(partial)),
        "border_alpha_is_zero": bool(np.all(border == 0)),
        "transparent_rgb_is_zero": bool(np.all(rgb[zero] == 0)),
        "significant_visible_magenta_fringe_absent": fringe_fraction <= 0.0001,
    }
    failed = [name for name, passed in checks.items() if not passed]
    if failed:
        raise ValueError("Phase 159 cloche QA failed: " + ", ".join(failed))

    return {
        "checks": checks,
        "counts": {
            "total_pixels": int(alpha.size),
            "alpha_zero": int(np.count_nonzero(zero)),
            "alpha_full": int(np.count_nonzero(full)),
            "alpha_partial": int(np.count_nonzero(partial)),
            "visible_pixels": visible_pixels,
            "visible_magenta_fringe_pixels": fringe_pixels,
        },
        "visible_magenta_fringe_fraction": fringe_fraction,
    }


def main() -> int:
    source_path = PROJECT_ROOT / SOURCE_REL
    output_path = PROJECT_ROOT / OUTPUT_REL
    qa_path = PROJECT_ROOT / QA_REL
    source_hash_before = _sha256(source_path)

    with Image.open(source_path) as opened:
        source_mode = opened.mode
        source_rgb_image = opened.convert("RGB")
    source_rgb = np.asarray(source_rgb_image, dtype=np.uint8)
    key = _estimate_key(source_rgb)
    alpha, extraction = _build_alpha(source_rgb, key)
    clean_rgb = _despill(source_rgb, alpha, key)
    output_array, source_crop = _crop_with_padding(clean_rgb, alpha)
    qa = _qa(output_array)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(output_array, mode="RGBA").save(
        output_path, format="PNG", compress_level=9, optimize=False
    )
    source_hash_after = _sha256(source_path)
    if source_hash_before != source_hash_after:
        raise ValueError("Phase 159 source changed while building the derived asset")

    report = {
        "phase": 159,
        "status": "PASSED",
        "policy": "deterministic_central_chroma_key_rgba_v1",
        "source": {
            "path": SOURCE_REL.as_posix(),
            "sha256": source_hash_before,
            "mode": source_mode,
            "dimensions": [int(source_rgb.shape[1]), int(source_rgb.shape[0])],
            "modified": False,
        },
        "output": {
            "path": OUTPUT_REL.as_posix(),
            "sha256": _sha256(output_path),
            "mode": "RGBA",
            "dimensions": [int(output_array.shape[1]), int(output_array.shape[0])],
            "source_crop_xyxy": [int(value) for value in source_crop],
            "transparent_padding_pixels": TRANSPARENT_PADDING,
        },
        "parameters": {
            "border_sample_pixels": BORDER_SAMPLE,
            "transparent_distance": TRANSPARENT_DISTANCE,
            "opaque_distance": OPAQUE_DISTANCE,
            "magenta_dominance_min": MAGENTA_DOMINANCE_MIN,
            "component_alpha_min": COMPONENT_ALPHA_MIN,
            "edge_support_dilations": EDGE_SUPPORT_DILATIONS,
            "fringe_alpha_min": FRINGE_ALPHA_MIN,
            "fringe_magenta_dominance": FRINGE_MAGENTA_DOMINANCE,
        },
        "extraction": extraction,
        "qa": qa,
    }
    qa_path.parent.mkdir(parents=True, exist_ok=True)
    qa_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(f"PHASE159_BOTANICAL_CLOCHE={output_path}")
    print(f"PHASE159_BOTANICAL_CLOCHE_SHA256={report['output']['sha256']}")
    print(f"PHASE159_BOTANICAL_CLOCHE_QA={qa_path}")
    print("PHASE159_BOTANICAL_CLOCHE=PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
