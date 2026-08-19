#!/usr/bin/env python3
"""Split a transparent 3x2 comic plant-family sheet without modifying it."""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image


STATES = ("seed", "sprout", "young", "mature", "sick", "harvest_ready")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    parser.add_argument("--prefix", required=True)
    parser.add_argument(
        "--keep-largest-component",
        action="store_true",
        help="Discard disconnected artwork leaking in from neighbouring cells.",
    )
    parser.add_argument(
        "--min-component-size",
        type=int,
        default=0,
        help="Keep every disconnected alpha component with at least this many pixels.",
    )
    parser.add_argument(
        "--component-margin",
        type=int,
        default=0,
        help="Also require each component bbox to stay this far inside its source cell.",
    )
    parser.add_argument(
        "--max-edge-component-size",
        type=int,
        default=0,
        help="Discard edge-touching components up to this size while keeping large subjects.",
    )
    parser.add_argument(
        "--top-row-keep-largest",
        action="store_true",
        help="Keep only the main connected subject in each top-row growth cell.",
    )
    parser.add_argument(
        "--column-cuts",
        default="",
        help="Optional two comma-separated x cuts for artwork that overlaps an exact grid.",
    )
    parser.add_argument(
        "--row-cut",
        type=int,
        default=0,
        help="Optional y cut placed in the visual gutter instead of at half height.",
    )
    return parser.parse_args()


def keep_largest_alpha_component(image: Image.Image, threshold: int = 8) -> Image.Image:
    alpha = image.getchannel("A")
    width, height = image.size
    visible = bytearray(1 if value > threshold else 0 for value in alpha.get_flattened_data())
    visited = bytearray(width * height)
    largest: list[int] = []

    for start in range(width * height):
        if not visible[start] or visited[start]:
            continue
        visited[start] = 1
        queue: deque[int] = deque([start])
        component: list[int] = []
        while queue:
            index = queue.popleft()
            component.append(index)
            x = index % width
            if x and visible[index - 1] and not visited[index - 1]:
                visited[index - 1] = 1
                queue.append(index - 1)
            if x + 1 < width and visible[index + 1] and not visited[index + 1]:
                visited[index + 1] = 1
                queue.append(index + 1)
            if index >= width and visible[index - width] and not visited[index - width]:
                visited[index - width] = 1
                queue.append(index - width)
            if index + width < width * height and visible[index + width] and not visited[index + width]:
                visited[index + width] = 1
                queue.append(index + width)
        if len(component) > len(largest):
            largest = component

    keep = bytearray(width * height)
    for index in largest:
        keep[index] = 255
    cleaned = Image.new("RGBA", image.size, (0, 0, 0, 0))
    cleaned_pixels = list(image.get_flattened_data())
    cleaned.putdata(
        [pixel if keep[index] else (0, 0, 0, 0) for index, pixel in enumerate(cleaned_pixels)]
    )
    return cleaned


def keep_alpha_components(
    image: Image.Image,
    minimum_size: int,
    margin: int = 0,
    max_edge_component_size: int = 0,
    threshold: int = 8,
) -> Image.Image:
    alpha = image.getchannel("A")
    width, height = image.size
    visible = bytearray(1 if value > threshold else 0 for value in alpha.get_flattened_data())
    visited = bytearray(width * height)
    keep = bytearray(width * height)

    for start in range(width * height):
        if not visible[start] or visited[start]:
            continue
        visited[start] = 1
        queue: deque[int] = deque([start])
        component: list[int] = []
        while queue:
            index = queue.popleft()
            component.append(index)
            x = index % width
            if x and visible[index - 1] and not visited[index - 1]:
                visited[index - 1] = 1
                queue.append(index - 1)
            if x + 1 < width and visible[index + 1] and not visited[index + 1]:
                visited[index + 1] = 1
                queue.append(index + 1)
            if index >= width and visible[index - width] and not visited[index - width]:
                visited[index - width] = 1
                queue.append(index - width)
            if index + width < width * height and visible[index + width] and not visited[index + width]:
                visited[index + width] = 1
                queue.append(index + width)
        xs = [index % width for index in component]
        ys = [index // width for index in component]
        inside_cell = (
            min(xs) >= margin
            and max(xs) < width - margin
            and min(ys) >= margin
            and max(ys) < height - margin
        )
        keep_component = len(component) >= minimum_size and (
            inside_cell or len(component) > max_edge_component_size
        )
        if keep_component:
            for index in component:
                keep[index] = 255

    cleaned = Image.new("RGBA", image.size, (0, 0, 0, 0))
    cleaned_pixels = list(image.get_flattened_data())
    cleaned.putdata(
        [pixel if keep[index] else (0, 0, 0, 0) for index, pixel in enumerate(cleaned_pixels)]
    )
    return cleaned


def main() -> int:
    args = parse_args()
    source = Image.open(args.input).convert("RGBA")
    if args.column_cuts or args.row_cut:
        try:
            column_cuts = [int(value.strip()) for value in args.column_cuts.split(",")]
        except ValueError as error:
            raise SystemExit("--column-cuts must contain two integers") from error
        if len(column_cuts) != 2:
            raise SystemExit("--column-cuts must contain exactly two integers")
        if not 0 < column_cuts[0] < column_cuts[1] < source.width:
            raise SystemExit("--column-cuts must be ordered inside the image")
        if not 0 < args.row_cut < source.height:
            raise SystemExit("--row-cut must be inside the image")
        x_bounds = [0, column_cuts[0], column_cuts[1], source.width]
        y_bounds = [0, args.row_cut, source.height]
    else:
        if source.width % 3 or source.height % 2:
            raise SystemExit(f"Expected an exact 3x2 grid, got {source.size}")
        cell_width = source.width // 3
        cell_height = source.height // 2
        x_bounds = [0, cell_width, cell_width * 2, source.width]
        y_bounds = [0, cell_height, source.height]
    args.out_dir.mkdir(parents=True, exist_ok=True)

    for index, state in enumerate(STATES):
        column = index % 3
        row = index // 3
        cell = source.crop(
            (
                x_bounds[column],
                y_bounds[row],
                x_bounds[column + 1],
                y_bounds[row + 1],
            )
        )
        if args.top_row_keep_largest and row == 0:
            cell = keep_largest_alpha_component(cell)
        elif args.min_component_size > 0:
            cell = keep_alpha_components(
                cell,
                args.min_component_size,
                args.component_margin,
                args.max_edge_component_size,
            )
        elif args.keep_largest_component:
            cell = keep_largest_alpha_component(cell)
        output = args.out_dir / f"{args.prefix}_{state}_raw_v1.png"
        cell.save(output, optimize=True)
        bbox = cell.getchannel("A").getbbox()
        print(
            "COMIC_FAMILY_CELL "
            f"state={state} output={output} cell={cell.size} alpha_bbox={bbox}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
