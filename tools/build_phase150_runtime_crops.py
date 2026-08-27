"""Build deterministic plant-only Phase150 crop layers from immutable Phase127 RGBA art.

The source paintings remain byte-for-byte unchanged. Only alpha in the authored
soil contact band is reduced; retained RGB pixels are copied verbatim.
"""

from __future__ import annotations

import hashlib
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "assets/ui/visual/phase127/greenhouse_sprites"
OUTPUT_ROOT = ROOT / "assets/ui/visual/phase150/greenhouse/crops"
QA_OUTPUT = ROOT / "docs/visual-proposals/phase150/qa/phase150-runtime-crop-layers-v1.png"
MANIFEST_OUTPUT = OUTPUT_ROOT / "phase150_runtime_crops_manifest.json"

CROPS = {
    "seedlings": {
        "source": "greenhouse_crop_seedlings_v1.png",
        "output": "greenhouse_crop_seedlings_phase150_v1.png",
        "sha256": "BF0F6FF1A745C9FD26B3CD1DC04D67BDB0596BA7C12056C2B6BAA62AA5CEE51E",
        "soil_start_y": 122,
    },
    "cherry_tomato": {
        "source": "greenhouse_crop_tomato_v1.png",
        "output": "greenhouse_crop_tomato_phase150_v1.png",
        "sha256": "833A7B2B895E01DC9987DB264F759EEA3AA04000033915E88FAA941C5892287A",
        "soil_start_y": 220,
    },
    "sweet_pepper": {
        "source": "greenhouse_crop_pepper_v1.png",
        "output": "greenhouse_crop_pepper_phase150_v1.png",
        "sha256": "3E9E691A4AC7E506308C0BFD7D2D4DB31E99428353AF445072A49B5EBD52FD3F",
        "soil_start_y": 218,
    },
    "garden_radish": {
        "source": "greenhouse_crop_radish_v1.png",
        "output": "greenhouse_crop_radish_phase150_v1.png",
        "sha256": "33C4D7A570D84506A6A3F9DBFB636C59AA3430A40E0E4792E29FCFBA1C0DB0BB",
        "soil_start_y": 174,
    },
    "salad_cucumber": {
        "source": "greenhouse_crop_cucumber_v1.png",
        "output": "greenhouse_crop_cucumber_phase150_v1.png",
        "sha256": "899ADECAB2A4C640D8042D116FAF69E001E60E59E640978230C30663F45A3056",
        "soil_start_y": 208,
    },
    "garden_eggplant": {
        "source": "greenhouse_crop_eggplant_v1.png",
        "output": "greenhouse_crop_eggplant_phase150_v1.png",
        "sha256": "C7E77DCCF7045F05A3EE01B763BCD7602FEFDAE23613EA604BBEF03AA072816B",
        "soil_start_y": 202,
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def semantic_plant_mask(rgba: np.ndarray) -> np.ndarray:
    hsv = np.asarray(Image.fromarray(rgba[:, :, :3], "RGB").convert("HSV"), dtype=np.uint8)
    hue = hsv[:, :, 0].astype(np.float32) / 255.0
    saturation = hsv[:, :, 1].astype(np.float32) / 255.0
    value = hsv[:, :, 2].astype(np.float32) / 255.0
    visible = rgba[:, :, 3] > 0
    green = (hue >= 0.16) & (hue <= 0.48) & (saturation >= 0.28) & (value >= 0.12)
    red = ((hue <= 0.022) | (hue >= 0.975)) & (saturation >= 0.48) & (value >= 0.42)
    purple = (hue >= 0.70) & (hue <= 0.94) & (saturation >= 0.25) & (value >= 0.18)
    flower_yellow = (hue >= 0.125) & (hue <= 0.19) & (saturation >= 0.32) & (value >= 0.32)
    return visible & (green | red | purple | flower_yellow)


def structural_colour_components(mask: np.ndarray) -> np.ndarray:
    """Keep authored plant-colour islands before any dilation.

    Soil highlights contain scattered yellow-green pixels.  Dilating first joined
    those specks into one large mound, which recreated the sticker silhouette we
    are explicitly removing.  Components are therefore classified on the raw
    semantic mask and expanded only after the soil islands have been rejected.
    """

    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    retained = np.zeros_like(mask, dtype=bool)
    for start_y in range(height):
        for start_x in range(width):
            if not mask[start_y, start_x] or visited[start_y, start_x]:
                continue
            queue = deque([(start_x, start_y)])
            visited[start_y, start_x] = True
            component: list[tuple[int, int]] = []
            min_x = max_x = start_x
            min_y = max_y = start_y
            while queue:
                x, y = queue.popleft()
                component.append((x, y))
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)
                for next_y in range(max(0, y - 1), min(height, y + 2)):
                    for next_x in range(max(0, x - 1), min(width, x + 2)):
                        if mask[next_y, next_x] and not visited[next_y, next_x]:
                            visited[next_y, next_x] = True
                            queue.append((next_x, next_y))
            component_width = max_x - min_x + 1
            component_height = max_y - min_y + 1
            if len(component) < 36 or component_width < 4 or component_height < 8:
                continue
            for x, y in component:
                retained[y, x] = True
    return retained


def build_crop(source: Path, output: Path, soil_start_y: int) -> dict:
    source_image = Image.open(source).convert("RGBA")
    rgba = np.asarray(source_image, dtype=np.uint8).copy()
    original_alpha = rgba[:, :, 3].copy()
    semantic = structural_colour_components(semantic_plant_mask(rgba))
    expanded = Image.fromarray((semantic * 255).astype(np.uint8), "L")
    expanded = expanded.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.45))
    keep_alpha = np.asarray(expanded, dtype=np.uint8)
    derived_alpha = original_alpha.copy()
    derived_alpha[soil_start_y:, :] = np.minimum(
        original_alpha[soil_start_y:, :], keep_alpha[soil_start_y:, :]
    )
    derived_alpha[derived_alpha < 3] = 0
    rgba[:, :, 3] = derived_alpha

    visible_y, visible_x = np.nonzero(derived_alpha > 0)
    if visible_x.size == 0:
        raise ValueError(f"alpha extraction removed the entire crop: {source}")
    padding = 2
    x0 = max(0, int(visible_x.min()) - padding)
    y0 = max(0, int(visible_y.min()) - padding)
    x1 = min(rgba.shape[1], int(visible_x.max()) + padding + 1)
    y1 = min(rgba.shape[0], int(visible_y.max()) + padding + 1)
    cropped = rgba[y0:y1, x0:x1].copy()
    output.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(cropped, "RGBA").save(output, format="PNG", optimize=False, compress_level=9)

    removed = int(np.count_nonzero((original_alpha > 0) & (derived_alpha == 0)))
    softened = int(np.count_nonzero((derived_alpha > 0) & (derived_alpha < original_alpha)))
    retained = derived_alpha > 0
    rgb_unchanged = bool(np.array_equal(rgba[:, :, :3][retained], np.asarray(source_image)[:, :, :3][retained]))
    return {
        "source_size": [source_image.width, source_image.height],
        "soil_start_y": soil_start_y,
        "source_crop_xyxy": [x0, y0, x1, y1],
        "output_size": [x1 - x0, y1 - y0],
        "opaque_pixels_removed": removed,
        "edge_pixels_softened": softened,
        "retained_rgb_unchanged": rgb_unchanged,
        "output_sha256": sha256(output),
    }


def build_contact_sheet(outputs: list[tuple[str, Path]]) -> None:
    tile_width, tile_height = 360, 330
    sheet = Image.new("RGB", (tile_width * 3, tile_height * 2), "#d9f3e7")
    draw = ImageDraw.Draw(sheet)
    for index, (crop_id, path) in enumerate(outputs):
        tile_x = (index % 3) * tile_width
        tile_y = (index // 3) * tile_height
        checker = 18
        for y in range(tile_y, tile_y + tile_height, checker):
            for x in range(tile_x, tile_x + tile_width, checker):
                alternating = ((x - tile_x) // checker + (y - tile_y) // checker) % 2
                colour = "#d9f3e7" if alternating == 0 else "#78b8aa"
                draw.rectangle((x, y, min(x + checker - 1, tile_x + tile_width - 1), min(y + checker - 1, tile_y + tile_height - 1)), fill=colour)
        image = Image.open(path).convert("RGBA")
        scale = min(300 / image.width, 250 / image.height)
        resized = image.resize(
            (max(1, round(image.width * scale)), max(1, round(image.height * scale))),
            Image.Resampling.LANCZOS,
        )
        paste_x = tile_x + (tile_width - resized.width) // 2
        paste_y = tile_y + 45 + (250 - resized.height)
        sheet.paste(resized, (paste_x, paste_y), resized)
        draw.text((tile_x + 12, tile_y + 12), crop_id, fill="#fff4cf")
    QA_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(QA_OUTPUT, format="PNG", optimize=False, compress_level=9)


def main() -> int:
    manifest = {
        "schema": "phase150_runtime_crops_v1",
        "policy": "source_rgb_immutable_alpha_only_soil_contact_cleanup_v1",
        "status": "PASSED",
        "crops": {},
    }
    outputs: list[tuple[str, Path]] = []
    for crop_id, spec in CROPS.items():
        source = SOURCE_ROOT / str(spec["source"])
        if sha256(source) != spec["sha256"]:
            raise ValueError(f"immutable source hash mismatch: {source}")
        output = OUTPUT_ROOT / str(spec["output"])
        result = build_crop(source, output, int(spec["soil_start_y"]))
        if not result["retained_rgb_unchanged"]:
            raise ValueError(f"retained RGB changed: {crop_id}")
        manifest["crops"][crop_id] = {
            "source": source.relative_to(ROOT).as_posix(),
            "source_sha256": spec["sha256"],
            "output": output.relative_to(ROOT).as_posix(),
            **result,
        }
        outputs.append((crop_id, output))
    build_contact_sheet(outputs)
    manifest["qa_contact_sheet"] = QA_OUTPUT.relative_to(ROOT).as_posix()
    MANIFEST_OUTPUT.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("PHASE150_RUNTIME_CROPS=PASSED")
    print(f"PHASE150_RUNTIME_CROP_COUNT={len(outputs)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
