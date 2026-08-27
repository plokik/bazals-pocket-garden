#!/usr/bin/env python3
"""Split a Phase 127 4x4 atlas into trimmed, versioned sprites.

The source atlas is preserved.  Every output keeps its real alpha and gets a
small transparent safety margin so Godot filtering cannot clip the outline.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


PROFILE_SPRITE_IDS = {
    "room": (
        "room_orchid",
        "room_fern",
        "room_broad_leaf",
        "room_striped_leaf",
        "room_tall_leaf",
        "room_flowering",
        "room_round_leaf",
        "room_climbing_vine",
        "room_books",
        "room_fertilizer",
        "room_nested_pots",
        "room_lamp",
        "room_botanical_art",
        "room_watering_can",
        "room_herb_jars",
        "room_cat_corner",
    ),
    "greenhouse": (
        "greenhouse_bed_empty",
        "greenhouse_bed_watered",
        "greenhouse_bed_locked",
        "greenhouse_bed_selected",
        "greenhouse_crop_seedlings",
        "greenhouse_crop_tomato",
        "greenhouse_crop_pepper",
        "greenhouse_crop_radish",
        "greenhouse_crop_cucumber",
        "greenhouse_crop_eggplant",
        "greenhouse_status_water",
        "greenhouse_status_ready",
        "greenhouse_soil_wet",
        "greenhouse_status_plaque",
        "greenhouse_progress_fill",
        "greenhouse_order_crate",
    ),
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--profile", choices=tuple(PROFILE_SPRITE_IDS), default="room")
    args = parser.parse_args()

    source = args.source.resolve()
    output = args.output.resolve()
    image = Image.open(source).convert("RGBA")
    if image.getextrema()[3][0] == 255:
        raise SystemExit("The atlas has no transparent pixels.")

    output.mkdir(parents=True, exist_ok=True)
    width, height = image.size
    records: list[dict[str, object]] = []
    sprite_ids = PROFILE_SPRITE_IDS[args.profile]
    for index, sprite_id in enumerate(sprite_ids):
        column = index % 4
        row = index // 4
        left = round(column * width / 4)
        right = round((column + 1) * width / 4)
        top = round(row * height / 4)
        bottom = round((row + 1) * height / 4)
        cell = image.crop((left, top, right, bottom))
        alpha_bounds = cell.getchannel("A").getbbox()
        if alpha_bounds is None:
            raise SystemExit(f"Atlas cell {index} ({sprite_id}) is empty.")
        sprite = cell.crop(alpha_bounds)
        safety_margin = max(8, round(max(sprite.size) * 0.04))
        padded = Image.new(
            "RGBA",
            (sprite.width + safety_margin * 2, sprite.height + safety_margin * 2),
            (0, 0, 0, 0),
        )
        padded.alpha_composite(sprite, (safety_margin, safety_margin))
        destination = output / f"{sprite_id}_v1.png"
        padded.save(destination, optimize=True)
        records.append(
            {
                "id": sprite_id,
                "source_region": [left, top, right - left, bottom - top],
                "trim_region": list(alpha_bounds),
                "output": destination.name,
                "size": list(padded.size),
                "sha256": sha256(destination),
            }
        )

    manifest = {
        "contract": f"phase127_{args.profile}_atlas_v1",
        "source": source.name,
        "source_size": [width, height],
        "source_sha256": sha256(source),
        "sprites": records,
    }
    (output / f"{args.profile}_sprites_v1.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"PHASE127_ATLAS_SPLIT=PASSED profile={args.profile} sprites={len(records)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
