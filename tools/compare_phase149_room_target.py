#!/usr/bin/env python3
"""Compare a Godot Player Room capture with the user-approved Phase 149 target.

The source target remains immutable. Both images are normalized to the logical
432x780 room viewport before metrics and diagnostic images are produced.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


LOGICAL_SCREEN_SIZE = (432, 960)
LOGICAL_ROOM_RECT = (0, 74, 432, 854)
LOGICAL_ROOM_SIZE = (432, 780)
TARGET_ROOM_CROP = (0, 137, 853, 1685)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def normalize_target(path: Path) -> Image.Image:
    source = Image.open(path).convert("RGB")
    if source.size != (853, 1844):
        raise ValueError(f"Unexpected target size: {source.size}")
    return source.crop(TARGET_ROOM_CROP).resize(LOGICAL_ROOM_SIZE, Image.Resampling.LANCZOS)


def normalize_actual(path: Path) -> Image.Image:
    source = Image.open(path).convert("RGB")
    scale_x = source.width / LOGICAL_SCREEN_SIZE[0]
    scale_y = source.height / LOGICAL_SCREEN_SIZE[1]
    if abs(scale_x - scale_y) > 0.01:
        raise ValueError(f"Capture is not a uniform 432x960 render: {source.size}")
    left, top, right, bottom = LOGICAL_ROOM_RECT
    crop = (
        round(left * scale_x),
        round(top * scale_y),
        round(right * scale_x),
        round(bottom * scale_y),
    )
    return source.crop(crop).resize(LOGICAL_ROOM_SIZE, Image.Resampling.LANCZOS)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True, type=Path)
    parser.add_argument("--actual", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--pixel-tolerance", type=int, default=12)
    args = parser.parse_args()

    args.output.mkdir(parents=True, exist_ok=True)
    target = normalize_target(args.target)
    actual = normalize_actual(args.actual)
    target_array = np.asarray(target, dtype=np.float32)
    actual_array = np.asarray(actual, dtype=np.float32)
    delta = np.abs(actual_array - target_array)
    per_pixel = delta.max(axis=2)

    metrics = {
        "target": str(args.target.resolve()),
        "target_sha256": sha256(args.target),
        "actual": str(args.actual.resolve()),
        "actual_sha256": sha256(args.actual),
        "logical_room_size": list(LOGICAL_ROOM_SIZE),
        "target_room_crop": list(TARGET_ROOM_CROP),
        "mean_abs_error": float(delta.mean()),
        "rmse": float(np.sqrt(np.square(actual_array - target_array).mean())),
        "changed_ratio": float((per_pixel > args.pixel_tolerance).mean()),
        "pixel_tolerance": args.pixel_tolerance,
    }

    target.save(args.output / "target-room-normalized.png")
    actual.save(args.output / "actual-room-normalized.png")
    heat = np.clip(per_pixel * 3.0, 0.0, 255.0).astype(np.uint8)
    heat_rgb = np.zeros((heat.shape[0], heat.shape[1], 3), dtype=np.uint8)
    heat_rgb[:, :, 0] = heat
    heat_rgb[:, :, 1] = (heat // 5).astype(np.uint8)
    Image.fromarray(heat_rgb, "RGB").save(args.output / "room-diff-heatmap.png")

    comparison = Image.new("RGB", (LOGICAL_ROOM_SIZE[0] * 3, LOGICAL_ROOM_SIZE[1]))
    comparison.paste(target, (0, 0))
    comparison.paste(actual, (LOGICAL_ROOM_SIZE[0], 0))
    comparison.paste(Image.fromarray(heat_rgb, "RGB"), (LOGICAL_ROOM_SIZE[0] * 2, 0))
    comparison.save(args.output / "target-actual-heatmap.png")
    (args.output / "metrics.json").write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(metrics, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
