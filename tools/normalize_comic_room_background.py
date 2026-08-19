#!/usr/bin/env python3
"""Center-crop and resize a room background to the deterministic rack canvas."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--width", type=int, default=887)
    parser.add_argument("--height", type=int, default=1420)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source = Image.open(args.input).convert("RGB")
    target_ratio = args.width / args.height
    source_ratio = source.width / source.height
    if source_ratio > target_ratio:
        crop_width = round(source.height * target_ratio)
        left = (source.width - crop_width) // 2
        crop = (left, 0, left + crop_width, source.height)
    else:
        crop_height = round(source.width / target_ratio)
        top = (source.height - crop_height) // 2
        crop = (0, top, source.width, top + crop_height)
    normalized = source.crop(crop).resize((args.width, args.height), Image.Resampling.LANCZOS)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    normalized.save(args.out, optimize=True)
    print(
        "COMIC_ROOM_NORMALIZED "
        f"input={args.input} source={source.width}x{source.height} crop={crop} "
        f"output={args.out} size={args.width}x{args.height}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
