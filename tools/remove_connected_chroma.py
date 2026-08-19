#!/usr/bin/env python3
"""Remove a flat chroma background without erasing enclosed subject colours.

Unlike a global colour key, this utility grows the matte only from pixels that
are genuinely close to the key colour.  That keeps violet flowers opaque even
when a magenta key is required for a green plant family.
"""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--key-color", default="#ed05f0")
    parser.add_argument("--transparent-threshold", type=int, default=12)
    parser.add_argument("--opaque-threshold", type=int, default=220)
    parser.add_argument(
        "--interior-key-threshold",
        type=int,
        default=64,
        help="Remove near-key pixels even in enclosed gaps inside a dense subject.",
    )
    return parser.parse_args()


def parse_hex_colour(value: str) -> tuple[int, int, int]:
    raw = value.strip().lstrip("#")
    if len(raw) != 6:
        raise SystemExit("--key-color must be a six-digit RGB hex value")
    return tuple(int(raw[index : index + 2], 16) for index in (0, 2, 4))


def smoothstep(value: float) -> float:
    clamped = max(0.0, min(1.0, value))
    return clamped * clamped * (3.0 - 2.0 * clamped)


def main() -> int:
    args = parse_args()
    if not 0 <= args.transparent_threshold < args.opaque_threshold <= 255:
        raise SystemExit("Expected 0 <= transparent threshold < opaque threshold <= 255")

    key = parse_hex_colour(args.key_color)
    source = Image.open(args.input).convert("RGBA")
    width, height = source.size
    pixels = list(source.get_flattened_data())
    count = width * height
    distances = bytearray(count)
    key_like = bytearray(count)
    visited = bytearray(count)
    queue: deque[int] = deque()

    for index, (red, green, blue, _alpha) in enumerate(pixels):
        distance = max(abs(red - key[0]), abs(green - key[1]), abs(blue - key[2]))
        distances[index] = distance
        # A magenta key is red/blue dominant.  Requiring the same dominance
        # prevents the matte from growing through green leaves or black ink.
        dominance = min(red, blue) - green
        if distance <= args.opaque_threshold and dominance >= 8:
            key_like[index] = 1
        if distance <= args.interior_key_threshold:
            visited[index] = 1
            queue.append(index)

    while queue:
        index = queue.popleft()
        x = index % width
        neighbours = []
        if x:
            neighbours.append(index - 1)
        if x + 1 < width:
            neighbours.append(index + 1)
        if index >= width:
            neighbours.append(index - width)
        if index + width < count:
            neighbours.append(index + width)
        for neighbour in neighbours:
            if key_like[neighbour] and not visited[neighbour]:
                visited[neighbour] = 1
                queue.append(neighbour)

    output: list[tuple[int, int, int, int]] = []
    transparent = 0
    partial = 0
    threshold_span = float(args.opaque_threshold - args.transparent_threshold)
    for index, (red, green, blue, source_alpha) in enumerate(pixels):
        if not visited[index]:
            output.append((red, green, blue, source_alpha))
            continue

        distance = distances[index]
        if distance <= args.interior_key_threshold:
            output.append((0, 0, 0, 0))
            transparent += 1
            continue

        ratio = (distance - args.transparent_threshold) / threshold_span
        alpha = round(255.0 * smoothstep(ratio) * (source_alpha / 255.0))
        if alpha <= 4:
            output.append((0, 0, 0, 0))
            transparent += 1
            continue

        # The generated family already has a dark ink contour.  A neutral dark
        # antialias fringe preserves that contour without leaving magenta/cyan
        # pixels on bright in-game backgrounds.  Fully opaque interior violet
        # pixels never enter this branch, so the flowers retain their colour.
        edge_value = min(red, green, blue)
        output.append((edge_value, edge_value, edge_value, alpha))
        partial += 1

    result = Image.new("RGBA", source.size, (0, 0, 0, 0))
    result.putdata(output)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    result.save(args.out, optimize=True)
    print(
        "CONNECTED_CHROMA_REMOVED "
        f"input={args.input} output={args.out} key={args.key_color} "
        f"transparent={transparent} partial={partial} total={count}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
