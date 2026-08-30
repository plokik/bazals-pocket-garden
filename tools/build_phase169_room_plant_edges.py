"""Audit and remove source-background residue from the preserved Phase167 plants.

The user already authorized deterministic alpha-only extraction. This is not
repainting: source PNGs, RGB, padded canvases and the shelf geometry stay intact.
Trial output is isolated under .godot; --write installs versioned derivatives.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_MANIFEST = "assets/ui/visual/phase167/player_room/phase167_plant_alpha_manifest.json"
SOURCE_MANIFEST_SHA256 = "8DABD24E4493FA5BEF72F153E4FE74D4CBFFFBDA3E89B510AFEB24926C80D0FB"
OUTPUT = "assets/ui/visual/phase169/player_room"
# Existing measured rim/floor coordinates; this tool does not change geometry.
CERAMICS = {
    "orchid": (228, 398), "glossy_broadleaf": (182, 360),
    "snake_plant": (225, 408), "fern": (180, 364),
    "flowering_begonia": (168, 348), "roundleaf_pilea": (179, 364),
    "striped_calathea": (151, 334), "lemon_maranta": (164, 325),
    "compact_aglaonema": (151, 332), "fittonia": (137, 331),
    "pothos": (155, 339), "coleus": (154, 344),
}
# Manually inspected source-coordinate holes BETWEEN stems/leaves, not a
# global white/chroma key. Each rectangle is half-open and each seed lies in
# a confirmed background fragment. Snake plant and coleus have no such holes.
HOLES = {
    "orchid": [(119, 75, 137, 87, 129, 78)],
    "glossy_broadleaf": [
        (100, 76, 115, 101, 110, 84), (49, 110, 68, 124, 63, 115),
        (123, 102, 137, 114, 131, 109), (143, 124, 156, 135, 149, 130),
        (83, 146, 93, 156, 86, 151), (54, 163, 67, 176, 59, 171),
        (78, 124, 84, 132, 81, 129), (129, 160, 137, 170, 133, 165),
    ],
    "fern": [
        (133, 82, 143, 94, 137, 87), (139, 98, 148, 108, 143, 101),
        (185, 137, 197, 148, 189, 143), (177, 142, 188, 152, 181, 147),
        (188, 104, 198, 116, 191, 109), (73, 157, 85, 170, 77, 162),
        (86, 125, 95, 134, 89, 129), (159, 95, 169, 106, 163, 99),
    ],
    "flowering_begonia": [
        (92, 57, 106, 75, 102, 65), (130, 66, 141, 82, 136, 71),
        (164, 80, 177, 93, 173, 86), (44, 99, 65, 113, 55, 106),
        (209, 98, 219, 109, 214, 103), (157, 106, 168, 117, 162, 111),
        (71, 136, 81, 146, 75, 140), (67, 95, 78, 104, 71, 100),
    ],
    "roundleaf_pilea": [
        (116, 95, 126, 109, 121, 100), (137, 158, 147, 176, 142, 165),
        (147, 163, 158, 176, 154, 167), (68, 128, 76, 138, 71, 133),
    ],
    "striped_calathea": [
        (124, 85, 135, 102, 130, 93), (110, 93, 126, 104, 119, 98),
        (159, 83, 169, 92, 164, 88), (146, 90, 157, 107, 151, 98),
    ],
    "lemon_maranta": [
        (137, 70, 150, 85, 144, 78), (117, 67, 126, 80, 122, 72),
        (90, 73, 102, 83, 95, 77), (148, 80, 161, 88, 154, 84),
        (77, 109, 92, 120, 84, 114), (91, 103, 107, 114, 99, 108),
        (116, 98, 125, 117, 120, 109), (129, 83, 138, 97, 133, 90),
    ],
    "compact_aglaonema": [
        (119, 65, 135, 79, 128, 73), (146, 65, 162, 78, 154, 71),
        (164, 84, 174, 100, 168, 92), (100, 85, 111, 97, 105, 90),
    ],
    "fittonia": [
        (95, 69, 114, 95, 103, 85), (129, 58, 137, 71, 132, 64),
        (157, 59, 175, 78, 166, 68), (146, 83, 157, 97, 152, 91),
        (133, 118, 143, 129, 138, 123),
    ],
    "pothos": [
        (83, 88, 99, 108, 89, 98), (140, 108, 150, 121, 144, 114),
        (152, 121, 161, 134, 156, 128), (216, 134, 227, 149, 221, 142),
    ],
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def expand(mask: np.ndarray, radius: int = 1) -> np.ndarray:
    return np.asarray(Image.fromarray(mask.astype(np.uint8) * 255).filter(
        ImageFilter.MaxFilter(2 * radius + 1))) > 0


def connected(mask: np.ndarray, seeds: np.ndarray) -> np.ndarray:
    height, width = mask.shape
    reached = np.zeros(mask.shape, dtype=bool)
    queue = deque((int(y), int(x)) for y, x in np.argwhere(mask & seeds))
    for y, x in queue:
        reached[y, x] = True
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < height and 0 <= nx < width and mask[ny, nx] and not reached[ny, nx]:
                reached[ny, nx] = True
                queue.append((ny, nx))
    return reached


def cleanup(source: Image.Image, source_id: str) -> tuple[Image.Image, dict]:
    rgba = np.array(source.convert("RGBA"))
    rgb = rgba[:, :, :3].astype(np.int16)
    alpha = rgba[:, :, 3].copy()
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    rim, floor = CERAMICS[source_id]
    y = np.arange(source.height)[:, None]
    # A warm grey matte baked into the source drop shadow lies OUTSIDE the
    # dark ceramic outline. Connectivity prevents deleting the pot's painted
    # floral pattern or highlights even if they share the same RGB range.
    shadow_zone = y >= rim + int((floor - rim) * 0.65)
    matte = shadow_zone & (r >= g) & (g >= b) & (r - b <= 78) \
        & (r - g <= 34) & (g - b <= 50) & (r >= 68) & (r <= 210)
    remove = connected(matte & (alpha > 0), expand(alpha == 0))
    holes = np.zeros(alpha.shape, dtype=bool)
    pink = (r - g >= 12) & (b - g >= 4)
    neutral = (rgb.min(axis=2) >= 80) & (rgb.max(axis=2) - rgb.min(axis=2) <= 80) & ~pink
    for left, top, right, bottom, sx, sy in HOLES.get(source_id, []):
        roi = np.zeros(alpha.shape, dtype=bool)
        roi[top:bottom, left:right] = True
        candidates = roi & neutral & (alpha > 0)
        # A 2px seed tolerance only resolves a measured point onto the same
        # tiny neutral fragment; the ROI and connectivity still bound removal.
        seeds = np.zeros(alpha.shape, dtype=bool)
        seeds[max(top, sy - 2):min(bottom, sy + 3), max(left, sx - 2):min(right, sx + 3)] = True
        fragment = connected(candidates, seeds)
        assert fragment.any(), f"Measured neutral hole no longer present: {source_id} {(sx, sy)}"
        holes |= fragment
    assert not np.any(remove & holes), "Saucer matte and crown holes must be disjoint"
    remove_all = remove | holes
    rgba[remove_all, 3] = 0
    # Keep RGB exact, including invisible RGB; import's alpha-border handling
    # extends real edge colors after the final alpha has been computed.
    assert np.array_equal(rgba[:, :, :3], np.asarray(source)[:, :, :3])
    assert np.all(rgba[:, :, 3] <= alpha)
    assert not np.any(remove_all & pink), "Painted pink details must not be keyed out"
    assert np.count_nonzero(remove_all) < 0.05 * np.count_nonzero(alpha), "Unexpected mass erasure"
    return Image.fromarray(rgba), {
        "matte_removed_pixels": int(remove.sum()),
        "hole_removed_pixels": int(holes.sum()),
        "hole_regions": [list(region) for region in HOLES.get(source_id, [])],
        "alpha_changed_pixels": int(np.count_nonzero(rgba[:, :, 3] != alpha)),
        "rgb_byte_exact_to_phase167": True,
        "canvas_unchanged": True,
    }


def sheet(items: list[tuple[str, Image.Image, Image.Image]], path: Path) -> None:
    width, height = 600, 470
    canvas = Image.new("RGB", (width * 3, height * 4), "#223b40")
    draw = ImageDraw.Draw(canvas)
    for index, (name, before, after) in enumerate(items):
        x, y = index % 3 * width, index // 3 * height
        draw.text((x + 12, y + 8), name + "   BEFORE / AFTER", fill="white")
        for column, picture in enumerate((before, after)):
            ox = x + column * 300
            draw.rectangle((ox + 4, y + 30, ox + 295, y + height - 5), fill="#352517")
            canvas.paste(picture, (ox + (300 - picture.width) // 2, y + height - 16 - picture.height), picture)
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, compress_level=9)


def inspection_details(items: list[tuple[str, Image.Image, Image.Image]], output: Path) -> None:
    """Labelled nearest-neighbour diagnostic magnification, never runtime art."""
    for name, before, after in items:
        rim, _ = CERAMICS[name]
        crop = before.crop((0, 0, before.width, rim)).resize((before.width * 3, rim * 3), Image.Resampling.NEAREST)
        panel = Image.new("RGB", crop.size, "#342516")
        panel.paste(crop, (0, 0), crop)
        draw = ImageDraw.Draw(panel)
        for x in range(0, before.width, 20):
            draw.line((x * 3, 0, x * 3, panel.height), fill="#967854", width=1)
            draw.text((x * 3 + 2, 2), str(x), fill="white")
        for y in range(0, rim, 20):
            draw.line((0, y * 3, panel.width, y * 3), fill="#967854", width=1)
            draw.text((2, y * 3 + 2), str(y), fill="white")
        panel.save(output / f"inspect-{name}.png", compress_level=9)
        after_crop = after.crop((0, 0, before.width, rim)).resize(crop.size, Image.Resampling.NEAREST)
        after_panel = Image.new("RGB", crop.size, "#342516")
        after_panel.paste(after_crop, (0, 0), after_crop)
        after_panel.save(output / f"after-crown-{name}.png", compress_level=9)
        changed = np.asarray(before)[:, :, 3] != np.asarray(after)[:, :, 3]
        diff = np.array(before)
        diff[changed] = (255, 0, 255, 255)
        diff_image = Image.fromarray(diff)
        diff_panel = Image.new("RGB", diff_image.size, "#342516")
        diff_panel.paste(diff_image, (0, 0), diff_image)
        diff_panel.resize((diff_image.width * 3, diff_image.height * 3), Image.Resampling.NEAREST).save(output / f"changed-{name}.png", compress_level=9)


def build(output_root: Path, check: bool = False) -> dict:
    assert sha256(ROOT / SOURCE_MANIFEST) == SOURCE_MANIFEST_SHA256, "Historical manifest changed"
    source_manifest = json.loads((ROOT / SOURCE_MANIFEST).read_text(encoding="utf-8"))
    assert len(source_manifest["assets"]) == len(CERAMICS) == 12
    assert {r["id"] for r in source_manifest["assets"]} == set(CERAMICS)
    records = []
    trials = []
    pending = []
    for source_record in source_manifest["assets"]:
        name = source_record["id"]
        assert source_record["output"] == f"assets/ui/visual/phase167/player_room/plants/room_plant_{name}_phase167.png"
        source_path = ROOT / source_record["output"]
        assert sha256(source_path) == source_record["output_sha256"], f"Source changed: {name}"
        source = Image.open(source_path).convert("RGBA")
        result, metrics = cleanup(source, name)
        path = output_root / "plants" / f"room_plant_{name}_phase169.png"
        pending.append((path, result))
        records.append({"id": name, "source": source_record["output"],
                        "source_sha256": source_record["output_sha256"],
                        "output": f"{OUTPUT}/plants/{path.name}",
                        "size": list(result.size), **metrics})
        trials.append((name, source, result))
    # Audit every source and every pixel invariant BEFORE writing any derivative.
    for path, result in pending:
        if check:
            assert path.is_file(), f"Missing derivative: {path}"
            assert np.array_equal(np.asarray(Image.open(path).convert("RGBA")), np.asarray(result)), f"Derivative changed: {path}"
        elif output_root == ROOT / OUTPUT and path.exists():
            assert np.array_equal(np.asarray(Image.open(path).convert("RGBA")), np.asarray(result)), f"Existing derivative differs; use a new version: {path}"
    for (path, result), record in zip(pending, records):
        if not check and not path.exists():
            path.parent.mkdir(parents=True, exist_ok=True)
            result.save(path, compress_level=9)
        elif not check and output_root != ROOT / OUTPUT:
            result.save(path, compress_level=9)
        record["output_sha256"] = sha256(path)
    manifest = {"schema": "phase169_room_plant_edges_v1", "assets": records,
                "source_manifest": SOURCE_MANIFEST,
                "source_manifest_sha256": SOURCE_MANIFEST_SHA256,
                "method": "alpha_only_connected_warm_matte_and_measured_neutral_holes_v1",
                "historical_png_policy": "unchanged_append_only_derivatives",
                "geometry_policy": "unchanged_phase167_canvas_and_landmarks",
                "rgb_policy": "all_rgb_bytes_unchanged_including_invisible_pixels"}
    manifest_path = output_root / "phase169_plant_edges_manifest.json"
    if check:
        assert json.loads(manifest_path.read_text(encoding="utf-8")) == manifest
    else:
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        if output_root != ROOT / OUTPUT:
            sheet(trials, output_root / "alpha-before-after.png")
            inspection_details(trials, output_root)
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--trial", type=Path, help="Isolated diagnostic output; no runtime switch")
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    output = args.trial.resolve() if args.trial else ROOT / OUTPUT
    if args.trial:
        assert output.is_relative_to(ROOT / ".godot"), "Trials belong only in isolated project .godot evidence"
    manifest = build(output, args.check)
    print("PHASE169_PLANT_EDGES=PASSED")
    print(json.dumps([{ "id": item["id"], "matte_removed_pixels": item["matte_removed_pixels"],
                       "hole_removed_pixels": item["hole_removed_pixels"] }
                      for item in manifest["assets"]]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
