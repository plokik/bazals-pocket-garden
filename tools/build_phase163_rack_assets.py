#!/usr/bin/env python3
"""Build the approved Phase 163 rack overlays without repainting source RGB.

The user-approved full-screen PNG is immutable.  This tool derives alpha-only
cutouts for one locked-planter master and one grow-light master, then records
all source/output hashes and extraction geometry in a deterministic manifest.
"""

from __future__ import annotations

from collections import deque
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE = PROJECT_ROOT / "docs/visual-proposals/phase163/user-approved-locked-planter-rack-screen-v1.png"
OUTPUT_ROOT = PROJECT_ROOT / "assets/ui/visual/phase163/rack"
LOCKED_OUTPUT = OUTPUT_ROOT / "rack_locked_planter_phase163_v1.png"
LIGHT_OUTPUT = OUTPUT_ROOT / "rack_grow_light_phase163_v1.png"
MANIFEST_OUTPUT = OUTPUT_ROOT / "phase163_rack_manifest.json"
SOURCE_SHA256 = "bd906524ed677fb996098578e3efbed3f19c797ac8078cbc8c7db86aeb1bc349"
LOCKED_SOURCE_RECT = (356, 735, 486, 910)
LIGHT_SOURCE_RECT = (112, 600, 212, 668)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def largest_component(mask: np.ndarray) -> np.ndarray:
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    best: list[tuple[int, int]] = []
    for start_y, start_x in np.argwhere(mask):
        if visited[start_y, start_x]:
            continue
        component: list[tuple[int, int]] = []
        queue = deque([(int(start_y), int(start_x))])
        visited[start_y, start_x] = True
        while queue:
            y, x = queue.popleft()
            component.append((y, x))
            for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if 0 <= next_y < height and 0 <= next_x < width and mask[next_y, next_x] and not visited[next_y, next_x]:
                    visited[next_y, next_x] = True
                    queue.append((next_y, next_x))
        if len(component) > len(best):
            best = component
    result = np.zeros_like(mask, dtype=bool)
    for y, x in best:
        result[y, x] = True
    return result


def fill_holes(mask: np.ndarray) -> np.ndarray:
    height, width = mask.shape
    outside = np.zeros_like(mask, dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        for y in (0, height - 1):
            if not mask[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if not mask[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= next_y < height and 0 <= next_x < width and not mask[next_y, next_x] and not outside[next_y, next_x]:
                outside[next_y, next_x] = True
                queue.append((next_y, next_x))
    return mask | ~outside


def locked_alpha(rgb: np.ndarray) -> Image.Image:
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    purple_seed = (red >= green + 14) & (blue >= green + 10) & ((red + blue) >= 100)
    joined = Image.fromarray((purple_seed.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(9))
    component = largest_component(np.asarray(joined, dtype=np.uint8) >= 128)
    expanded = Image.fromarray((component.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(3))
    filled = fill_holes(np.asarray(expanded, dtype=np.uint8) >= 128)
    dark = np.maximum.reduce((red, green, blue)) <= 95
    gold = (red >= 120) & (green >= 55) & (green <= red) & (blue <= green)
    pale = (red >= 130) & (blue >= 90) & (green <= red - 8)
    support = Image.fromarray(((purple_seed | dark | gold | pale).astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(5))
    silhouette = filled & (np.asarray(support, dtype=np.uint8) >= 128)
    return Image.fromarray((silhouette.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MinFilter(5)).filter(ImageFilter.GaussianBlur(0.40))


def light_alpha(rgb: np.ndarray) -> Image.Image:
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    height, width = red.shape
    yy, xx = np.mgrid[:height, :width]
    top_body = (xx >= width * 0.08) & (xx <= width * 0.92) & (yy >= height * 0.26) & (yy <= height * 0.55)
    lower_rim = ((xx - width * 0.50) / (width * 0.49)) ** 2 + ((yy - height * 0.57) / (height * 0.23)) ** 2 <= 1.0
    prior = top_body | lower_rim
    dark = (red < 125) & (green < 105) & (blue < 80)
    component_seed = Image.fromarray(((dark & prior).astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(3))
    component = largest_component(np.asarray(component_seed, dtype=np.uint8) >= 128)
    expanded = Image.fromarray((component.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(3))
    silhouette = fill_holes(np.asarray(expanded, dtype=np.uint8) >= 128) & prior
    return Image.fromarray((silhouette.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.40))


def build_cutout(source: Image.Image, rect: tuple[int, int, int, int], alpha_builder, output: Path) -> dict[str, object]:
    crop = source.crop(rect).convert("RGB")
    alpha = alpha_builder(np.asarray(crop))
    bounds = alpha.point(lambda value: 255 if value > 3 else 0).getbbox()
    if bounds is None:
        raise RuntimeError(f"Alpha extraction is empty for {output}")
    rgba = crop.convert("RGBA")
    rgba.putalpha(alpha)
    trimmed = rgba.crop(bounds)
    padding = 6
    result = Image.new("RGBA", (trimmed.width + padding * 2, trimmed.height + padding * 2), (0, 0, 0, 0))
    result.alpha_composite(trimmed, (padding, padding))
    output.parent.mkdir(parents=True, exist_ok=True)
    result.save(output)
    result_alpha = np.asarray(result.getchannel("A"), dtype=np.uint8)
    border = np.concatenate((result_alpha[0, :], result_alpha[-1, :], result_alpha[:, 0], result_alpha[:, -1]))
    return {
        "path": "res://" + output.relative_to(PROJECT_ROOT).as_posix(),
        "sha256": sha256(output),
        "size": list(result.size),
        "source_rect": list(rect),
        "source_rgb_policy": "approved_reference_rgb_preserved_alpha_only_v1",
        "alpha_nonzero_pixels": int(np.count_nonzero(result_alpha)),
        "alpha_partial_pixels": int(np.count_nonzero((result_alpha > 0) & (result_alpha < 255))),
        "border_alpha_max": int(border.max(initial=0)),
    }


def main() -> int:
    if sha256(SOURCE) != SOURCE_SHA256:
        raise RuntimeError("The Phase 163 approved source hash changed")
    source = Image.open(SOURCE).convert("RGB")
    if source.size != (872, 1804):
        raise RuntimeError(f"Unexpected approved source size: {source.size}")
    locked = build_cutout(source, LOCKED_SOURCE_RECT, locked_alpha, LOCKED_OUTPUT)
    light = build_cutout(source, LIGHT_SOURCE_RECT, light_alpha, LIGHT_OUTPUT)
    manifest = {
        "schema": "phase163_approved_rack_overlay_assets_v1",
        "approved_reference": {
            "path": "res://" + SOURCE.relative_to(PROJECT_ROOT).as_posix(),
            "sha256": SOURCE_SHA256,
            "size": list(source.size),
            "acceptance": "APPROVED_BY_USER_20260826",
        },
        "runtime_policy": "single_master_asset_reused_for_every_locked_slot_v1",
        "locked_planter": locked,
        "grow_light": light,
    }
    MANIFEST_OUTPUT.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    print(f"PHASE163_LOCKED_ASSET={LOCKED_OUTPUT}")
    print(f"PHASE163_LIGHT_ASSET={LIGHT_OUTPUT}")
    print(f"PHASE163_MANIFEST={MANIFEST_OUTPUT}")
    print("PHASE163_SOURCE_RGB_PRESERVED=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
