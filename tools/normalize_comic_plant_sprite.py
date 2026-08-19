#!/usr/bin/env python3
"""Normalize a transparent comic plant sprite onto the shared runtime canvas.

The script never overwrites the source image. It crops by alpha, scales without
distortion and anchors the bottom centre so every growth stage shares one pivot.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--canvas-width", type=int, default=570)
    parser.add_argument("--canvas-height", type=int, default=640)
    parser.add_argument("--max-width", type=int, default=554)
    parser.add_argument("--max-height", type=int, required=True)
    parser.add_argument("--bottom-padding", type=int, default=8)
    parser.add_argument("--alpha-threshold", type=int, default=8)
    parser.add_argument(
        "--fixed-scale",
        type=float,
        default=0.0,
        help="Optional shared family scale. The result is still clamped to fit.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source = Image.open(args.input).convert("RGBA")
    alpha = source.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > args.alpha_threshold else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise SystemExit(f"No visible pixels found in {args.input}")

    subject = source.crop(bbox)
    fit_scale = min(
        args.max_width / subject.width,
        args.max_height / subject.height,
    )
    scale = min(fit_scale, args.fixed_scale) if args.fixed_scale > 0.0 else min(fit_scale, 1.0)
    target_size = (
        max(1, round(subject.width * scale)),
        max(1, round(subject.height * scale)),
    )
    if target_size != subject.size:
        subject = subject.resize(target_size, Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (args.canvas_width, args.canvas_height), (0, 0, 0, 0))
    x = (args.canvas_width - subject.width) // 2
    y = args.canvas_height - args.bottom_padding - subject.height
    if x < 0 or y < 0:
        raise SystemExit(
            f"Normalized subject {subject.size} does not fit canvas "
            f"{args.canvas_width}x{args.canvas_height}"
        )
    canvas.alpha_composite(subject, (x, y))
    args.out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(args.out, optimize=True)
    print(
        "COMIC_SPRITE_NORMALIZED "
        f"input={args.input} output={args.out} source_bbox={bbox} "
        f"subject={subject.width}x{subject.height} anchor=({x},{y}) "
        f"canvas={args.canvas_width}x{args.canvas_height}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
