"""Measure immutable plant PNGs; emit metadata only, never repaint pixels."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "assets/ui/visual/phase170/rack"
TEXTURE = DEST / "rack_ceramic_saucer_phase170_v1.png"
MANIFEST = DEST / "phase170_saucer_manifest.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def measure() -> dict:
    paths = {"res://assets/plants/comic/empty_pot_v1.png"}
    for path in sorted((ROOT / "data/plants").glob("*.json")):
        paths.update(json.loads(path.read_text(encoding="utf-8-sig")).get("stage_textures", {}).values())
    plants = {}
    for path in sorted(paths):
        source = ROOT / path.removeprefix("res://")
        rgba = np.array(Image.open(source).convert("RGBA"))
        alpha = rgba[:, :, 3] > 127
        ys, _ = np.where(alpha)
        if not len(ys):
            raise ValueError(f"Empty source: {path}")
        contact_y = int(ys.max()) + 1
        _, xs = np.where(alpha[max(0, contact_y - 60):contact_y])
        left, right = int(xs.min()), int(xs.max()) + 1
        plants[path] = {
            "canvas": [int(rgba.shape[1]), int(rgba.shape[0])],
            "contact": [(left + right) / 2, contact_y],
            "base_width": right - left,
            "source_sha256": sha(source),
        }
    if len(plants) != 67:
        raise ValueError("Review footprint coverage when the plant catalog changes")
    rgba = np.array(Image.open(TEXTURE).convert("RGBA"))
    if np.count_nonzero(rgba[:, :, 3] == 0) < rgba.shape[0] * rgba.shape[1] * 0.3:
        raise ValueError("Saucer must have genuine transparent background, not a baked checkerboard")
    # Generated alpha can contain isolated <=4/255 dust far from the artwork.
    # Use a source ROI, not a rewritten PNG, with one extra AA pixel per side.
    ys, xs = np.where(rgba[:, :, 3] > 4)
    left, top = max(0, int(xs.min()) - 1), max(0, int(ys.min()) - 1)
    width = min(rgba.shape[1], int(xs.max()) + 2) - left
    height = min(rgba.shape[0], int(ys.max()) + 2) - top
    if not 0.18 <= height / width <= 0.32:
        raise ValueError("Review shallow saucer silhouette; do not distort its painted aspect")
    return {
        "schema": "phase170_rack_saucer_v1",
        "measurement": "alpha_gt_127_last_60px_relative_to_visible_floor_v1",
        "source_policy": "all_existing_pngs_unchanged",
        "plants": plants,
        "saucer": {
            "texture": "res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png",
            "canvas": [int(rgba.shape[1]), int(rgba.shape[0])],
            "source_rect_policy": "alpha_gt_4_bbox_plus_1px_runtime_crop_no_png_edit",
            "source_rect": [left, top, width, height],
            "sha256": sha(TEXTURE),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    result = measure()
    if args.check:
        if json.loads(MANIFEST.read_text(encoding="utf-8")) != result:
            raise ValueError("Footprint manifest no longer matches the immutable sources")
    else:
        if MANIFEST.exists() and json.loads(MANIFEST.read_text(encoding="utf-8")) != result:
            raise ValueError("Refusing to overwrite different provenance; version the asset explicitly")
        MANIFEST.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("PHASE170_FOOTPRINTS=PASSED_67")
    print(json.dumps(result["saucer"]))


if __name__ == "__main__":
    main()
