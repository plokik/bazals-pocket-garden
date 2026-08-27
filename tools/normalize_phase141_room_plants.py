#!/usr/bin/env python3
"""Normalize the approved Phase 141 room plants into one runtime geometry.

The ImageGen sources are immutable visual evidence. Some carry real alpha and
some contain a painted light checkerboard, so this script performs deterministic
border-background removal, retains the connected plant/pot/saucer body, strips
detached glow, and aligns every saucer to one shared width and contact baseline.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = PROJECT_ROOT / "assets" / "ui" / "visual" / "phase141" / "source"
OUTPUT_ROOT = PROJECT_ROOT / "assets" / "ui" / "visual" / "phase141"
CANVAS_SIZE = (591, 887)
TARGET_SAUCER_WIDTH = 340
CONTACT_BOTTOM_Y = 850

SOURCE_TO_OUTPUT = {
    "room_orchid_source_v1.png": "room_orchid_final_v1.png",
    "room_broad_leaf_source_v1.png": "room_broad_leaf_final_v1.png",
    "room_tall_leaf_source_v1.png": "room_tall_leaf_final_v1.png",
    "room_fern_source_v2.png": "room_fern_final_v1.png",
    "room_flowering_source_v1.png": "room_flowering_final_v1.png",
    "room_round_leaf_source_v1.png": "room_round_leaf_final_v1.png",
    "room_striped_leaf_source_v1.png": "room_striped_leaf_final_v1.png",
    "room_climbing_vine_source_v1.png": "room_climbing_vine_final_v1.png",
    "room_aglaonema_source_v1.png": "room_aglaonema_final_v1.png",
    "room_fittonia_source_v1.png": "room_fittonia_final_v1.png",
    "room_lemon_maranta_source_v1.png": "room_lemon_maranta_final_v1.png",
    "room_coleus_source_v1.png": "room_coleus_final_v1.png",
}


def _flood_component(mask: np.ndarray, seeds: list[tuple[int, int]]) -> np.ndarray:
    height, width = mask.shape
    visited = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for y, x in seeds:
        if 0 <= y < height and 0 <= x < width and mask[y, x] and not visited[y, x]:
            visited[y, x] = True
            queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= next_y < height and 0 <= next_x < width and mask[next_y, next_x] and not visited[next_y, next_x]:
                visited[next_y, next_x] = True
                queue.append((next_y, next_x))
    return visited


def _dilate(mask: np.ndarray, iterations: int) -> np.ndarray:
    result = mask.copy()
    for _index in range(iterations):
        expanded = result.copy()
        expanded[1:, :] |= result[:-1, :]
        expanded[:-1, :] |= result[1:, :]
        expanded[:, 1:] |= result[:, :-1]
        expanded[:, :-1] |= result[:, 1:]
        expanded[1:, 1:] |= result[:-1, :-1]
        expanded[1:, :-1] |= result[:-1, 1:]
        expanded[:-1, 1:] |= result[1:, :-1]
        expanded[:-1, :-1] |= result[1:, 1:]
        result = expanded
    return result


def _remove_painted_background(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8).copy()
    rgb = rgba[:, :, :3].astype(np.float32)
    original_alpha = rgba[:, :, 3].astype(np.float32) / 255.0
    channel_min = np.min(rgb, axis=2)
    channel_range = np.max(rgb, axis=2) - channel_min

    # A generated fake transparency grid is near-neutral and touches the image
    # border. Real cream ceramic is warmer and is not border-connected.
    painted_background_candidate = (channel_min >= 218.0) & (channel_range <= 20.0)
    height, width = painted_background_candidate.shape
    border_seeds = [(0, x) for x in range(width)] + [(height - 1, x) for x in range(width)]
    border_seeds += [(y, 0) for y in range(height)] + [(y, width - 1) for y in range(height)]
    painted_background = _flood_component(painted_background_candidate, border_seeds)

    alpha = original_alpha.copy()
    alpha[painted_background] = 0.0
    edge_zone = _dilate(painted_background, 2) & ~painted_background
    neutral_distance = np.sqrt(np.sum(np.square(255.0 - rgb), axis=2))
    edge_alpha = np.clip((neutral_distance - 6.0) / 42.0, 0.0, 1.0)
    alpha[edge_zone] = np.minimum(alpha[edge_zone], edge_alpha[edge_zone])

    # Retain only the connected authored body. This removes generated coloured
    # ambient glows without erasing antialiasing on the actual object contour.
    strong = alpha >= 0.30
    central = strong.copy()
    central[:, : width // 6] = False
    central[:, width * 5 // 6 :] = False
    central[: height // 5, :] = False
    central[height * 19 // 20 :, :] = False
    points = np.argwhere(central)
    if points.size == 0:
        raise ValueError("Could not locate the central plant component")
    target = np.array([height * 0.72, width * 0.50])
    seed_index = int(np.argmin(np.sum(np.square(points - target), axis=1)))
    seed_y, seed_x = (int(value) for value in points[seed_index])
    main_component = _flood_component(strong, [(seed_y, seed_x)])
    keep = _dilate(main_component, 3)
    alpha[~keep] = 0.0
    alpha[alpha < 0.015] = 0.0

    alpha_u8 = np.rint(alpha * 255.0).astype(np.uint8)
    rgba[:, :, 3] = alpha_u8
    return Image.fromarray(rgba, mode="RGBA")


def _foreground_bounds(image: Image.Image, threshold: int = 8) -> tuple[int, int, int, int]:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.nonzero(alpha >= threshold)
    if ys.size == 0:
        raise ValueError("Plant source contains no visible foreground")
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def _saucer_width(image: Image.Image, bounds: tuple[int, int, int, int]) -> int:
    left, top, right, bottom = bounds
    alpha = np.asarray(image.getchannel("A"))
    region_top = top + int((bottom - top) * 0.70)
    widest = 0
    for y in range(region_top, bottom):
        xs = np.flatnonzero(alpha[y, :] >= 96)
        if xs.size:
            widest = max(widest, int(xs.max() - xs.min() + 1))
    if widest <= 0:
        raise ValueError("Could not measure the plant saucer")
    return widest


def _normalize_geometry(image: Image.Image) -> Image.Image:
    bounds = _foreground_bounds(image)
    saucer_width = _saucer_width(image, bounds)
    scale = TARGET_SAUCER_WIDTH / float(saucer_width)
    scaled_size = (
        max(1, round(image.width * scale)),
        max(1, round(image.height * scale)),
    )
    scaled = image.resize(scaled_size, Image.Resampling.LANCZOS)
    scaled_bounds = _foreground_bounds(scaled)
    left, top, right, bottom = scaled_bounds
    foreground = scaled.crop(scaled_bounds)
    destination_x = (CANVAS_SIZE[0] - foreground.width) // 2
    destination_y = CONTACT_BOTTOM_Y - foreground.height
    if destination_x < 0 or destination_y < 0:
        raise ValueError(
            f"Normalized foreground {foreground.size} does not fit {CANVAS_SIZE}; "
            "the source violates the shared pot geometry"
        )
    output = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    output.alpha_composite(foreground, (destination_x, destination_y))
    return output


def main() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    failures: list[str] = []
    for source_name, output_name in SOURCE_TO_OUTPUT.items():
        source_path = SOURCE_ROOT / source_name
        output_path = OUTPUT_ROOT / output_name
        try:
            cleaned = _remove_painted_background(Image.open(source_path))
            normalized = _normalize_geometry(cleaned)
        except ValueError as error:
            failures.append(f"{source_name}: {error}")
            print(f"PHASE141_PLANT_ERROR={source_name} reason={error}")
            continue
        normalized.save(output_path, optimize=True)
        alpha = normalized.getchannel("A")
        bounds = _foreground_bounds(normalized)
        print(
            f"PHASE141_PLANT={output_path.relative_to(PROJECT_ROOT).as_posix()} "
            f"size={normalized.size} alpha={alpha.getextrema()} bounds={bounds} "
            f"contact_bottom={bounds[3] - 1}"
        )
    if failures:
        raise SystemExit("Phase 141 normalization failed: " + " | ".join(failures))


if __name__ == "__main__":
    main()
