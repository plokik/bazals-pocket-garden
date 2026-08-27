#!/usr/bin/env python3
"""Build the Phase 139 dynamic room-plant RGBA set from approved atlases.

The generated source atlases deliberately use a neutral near-white background.
Keeping each plant on an equal 591x887 authored canvas preserves the shared pot
and saucer dimensions; the common 84x126 runtime envelope may clip foliage but never rescales the
ceramic base independently between species or shelves.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = PROJECT_ROOT / "assets" / "ui" / "visual" / "phase139" / "source"
OUTPUT_ROOT = PROJECT_ROOT / "assets" / "ui" / "visual" / "phase139"
CELL_SIZE = (591, 887)
CONTACT_BOTTOM_Y = 850
# The generated atlases include a pale studio shadow below every saucer.  It
# cannot blend with the warm shelf and was the last remaining "sticker" cue in
# the live room.  The ceramic artwork ends above this row; runtime supplies a
# shelf-coloured contact shadow instead.
SOURCE_SHADOW_TRIM_Y = 822
SOURCE_SHADOW_FADE_Y = 805
SAUCER_TONE_START_Y = 760

ATLAS_SPECS = (
    (
        "player_room_plants_approved_atlas_a_v1.png",
        3,
        ("room_orchid_unified_v1.png", "room_broad_leaf_unified_v1.png", "room_tall_leaf_unified_v1.png"),
    ),
    (
        "player_room_plants_approved_atlas_b_v1.png",
        3,
        ("room_fern_unified_v1.png", "room_flowering_unified_v1.png", "room_round_leaf_unified_v1.png"),
    ),
    (
        "player_room_plants_approved_atlas_c_v1.png",
        2,
        ("room_striped_leaf_unified_v1.png", "room_climbing_vine_unified_v1.png"),
    ),
)

SAUCER_TINTS = {
    "room_orchid_unified_v1.png": (190, 151, 98),
    "room_broad_leaf_unified_v1.png": (34, 83, 145),
    "room_tall_leaf_unified_v1.png": (128, 137, 48),
    "room_fern_unified_v1.png": (29, 126, 132),
    "room_flowering_unified_v1.png": (184, 116, 72),
    "room_round_leaf_unified_v1.png": (35, 129, 125),
    "room_striped_leaf_unified_v1.png": (102, 70, 130),
    "room_climbing_vine_unified_v1.png": (35, 82, 119),
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


def _neutral_background_to_alpha(image: Image.Image) -> Image.Image:
    rgb = np.asarray(image.convert("RGB"), dtype=np.float32)
    distance = np.sqrt(np.sum(np.square(255.0 - rgb), axis=2))
    channel_min = np.min(rgb, axis=2)
    channel_range = np.max(rgb, axis=2) - channel_min
    background_candidate = (distance <= 18.0) | ((channel_min >= 236.0) & (channel_range <= 12.0))
    height, width = background_candidate.shape
    border_seeds = [(0, x) for x in range(width)] + [(height - 1, x) for x in range(width)]
    border_seeds += [(y, 0) for y in range(height)] + [(y, width - 1) for y in range(height)]
    connected_background = _flood_component(background_candidate, border_seeds)

    # Only the two-pixel contour next to the proven border background uses a
    # soft alpha ramp. Interior cream highlights stay opaque; the source-white
    # matte and its pale contact-shadow island are discarded.
    edge_zone = _dilate(connected_background, 2) & ~connected_background
    normalized = np.clip((distance - 8.0) / 30.0, 0.0, 1.0)
    alpha = normalized * normalized * (3.0 - 2.0 * normalized)
    alpha[~edge_zone & ~connected_background] = 1.0
    alpha[connected_background] = 0.0

    # Retain only the connected plant/pot/saucer body. The generated pale
    # shadow below the saucer is a separate island and runtime replaces it with
    # a warm shelf-aware shadow.
    strong = alpha >= 0.20
    central = strong.copy()
    central[:, : width // 5] = False
    central[:, width * 4 // 5 :] = False
    central[: height // 4, :] = False
    central[height * 9 // 10 :, :] = False
    central_points = np.argwhere(central)
    if central_points.size == 0:
        raise ValueError("Could not locate the central plant component")
    target = np.array([height * 0.68, width * 0.50])
    seed_index = int(np.argmin(np.sum(np.square(central_points - target), axis=1)))
    seed_y, seed_x = (int(value) for value in central_points[seed_index])
    main_component = _flood_component(strong, [(seed_y, seed_x)])
    keep = _dilate(main_component, 2)
    alpha[~keep] = 0.0
    row_indices = np.arange(height)[:, None]
    pale_shadow = (
        (row_indices >= SOURCE_SHADOW_FADE_Y)
        & (channel_min >= 222.0)
        & (channel_range <= 35.0)
    )
    alpha[pale_shadow] = 0.0
    alpha[SOURCE_SHADOW_TRIM_Y:, :] = 0.0

    alpha_u8 = np.rint(alpha * 255.0).astype(np.uint8)
    alpha_u8[alpha_u8 < 4] = 0
    # Remove white contamination from partially transparent edge pixels so the
    # downsampled contour adopts the room color instead of forming a white halo.
    alpha_float = alpha_u8.astype(np.float32) / 255.0
    safe_alpha = np.maximum(alpha_float, 0.08)
    foreground_rgb = 255.0 - (255.0 - rgb) / safe_alpha[:, :, None]
    foreground_rgb = np.clip(foreground_rgb, 0.0, 255.0).astype(np.uint8)
    rgba = np.dstack((foreground_rgb, alpha_u8))
    return Image.fromarray(rgba, mode="RGBA")


def _equal_cell(atlas: Image.Image, cell_index: int, cell_count: int) -> Image.Image:
    width, height = atlas.size
    if height != CELL_SIZE[1]:
        raise ValueError(f"Expected atlas height {CELL_SIZE[1]}, got {height}")
    center_x = round((cell_index + 0.5) * width / cell_count)
    left = center_x - CELL_SIZE[0] // 2
    right = left + CELL_SIZE[0]
    if left < 0 or right > width:
        raise ValueError(f"Cell {cell_index} falls outside {atlas.size}: {left}..{right}")
    return atlas.crop((left, 0, right, CELL_SIZE[1]))


def _align_contact_bottom(cell: Image.Image) -> Image.Image:
    alpha = np.asarray(cell.getchannel("A"))
    ys, _xs = np.nonzero(alpha >= 8)
    if ys.size == 0:
        raise ValueError("Atlas cell contains no foreground pixels")
    shift_y = CONTACT_BOTTOM_Y - int(ys.max())
    if shift_y == 0:
        return cell
    aligned = Image.new("RGBA", CELL_SIZE, (255, 255, 255, 0))
    aligned.alpha_composite(cell, (0, shift_y))
    return aligned


def _integrate_saucer_tone(cell: Image.Image, output_name: str) -> Image.Image:
    """Keep ceramic highlights while preventing a white sticker-like saucer."""
    rgba = np.asarray(cell, dtype=np.uint8).copy()
    rgb = rgba[:, :, :3].astype(np.float32)
    alpha = rgba[:, :, 3]
    channel_min = np.min(rgb, axis=2)
    channel_range = np.max(rgb, axis=2) - channel_min
    row_indices = np.arange(rgba.shape[0])[:, None]
    pale_ceramic = (
        (row_indices >= SAUCER_TONE_START_Y)
        & (alpha >= 8)
        & (channel_min >= 176.0)
        & (channel_range <= 58.0)
    )
    tint = np.asarray(SAUCER_TINTS[output_name], dtype=np.float32)
    strength = np.clip((channel_min - 164.0) / 120.0, 0.22, 0.58)
    rgb[pale_ceramic] = (
        rgb[pale_ceramic] * (1.0 - strength[pale_ceramic, None])
        + tint * strength[pale_ceramic, None]
    )
    rgba[:, :, :3] = np.rint(np.clip(rgb, 0.0, 255.0)).astype(np.uint8)
    return Image.fromarray(rgba, mode="RGBA")


def main() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for atlas_name, cell_count, output_names in ATLAS_SPECS:
        atlas_path = SOURCE_ROOT / atlas_name
        atlas = Image.open(atlas_path).convert("RGB")
        for cell_index, output_name in enumerate(output_names):
            cell = _equal_cell(atlas, cell_index, cell_count)
            rgba = _integrate_saucer_tone(
                _align_contact_bottom(_neutral_background_to_alpha(cell)),
                output_name,
            )
            output_path = OUTPUT_ROOT / output_name
            rgba.save(output_path, optimize=True)
            written.append(output_path)
    for path in written:
        with Image.open(path) as image:
            alpha_range = image.getchannel("A").getextrema()
            print(f"PHASE139_PLANT={path.relative_to(PROJECT_ROOT).as_posix()} size={image.size} alpha={alpha_range}")


if __name__ == "__main__":
    main()
