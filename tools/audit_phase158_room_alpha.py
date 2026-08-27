#!/usr/bin/env python3
"""Create report-only alpha cleanup trials for Phase 149 room layers."""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


PROJECT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_REL = Path("assets/ui/visual/phase149/player_room/phase149_target_layers_manifest.json")
CLEAN_REL = Path("assets/ui/player_room/player_room_phase149_target_clean_v1.png")
CONTENT_CROP_Y = 137


def _edge_connected(mask: np.ndarray, alpha_support: np.ndarray) -> np.ndarray:
    height, width = mask.shape
    reached = np.zeros_like(mask, dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    padded = np.pad(alpha_support, 1, constant_values=False)
    touches_transparency = (
        ~padded[:-2, 1:-1]
        | ~padded[2:, 1:-1]
        | ~padded[1:-1, :-2]
        | ~padded[1:-1, 2:]
    )
    for y, x in np.argwhere(mask & touches_transparency):
        queue.append((int(y), int(x)))
    while queue:
        y, x = queue.popleft()
        if reached[y, x] or not mask[y, x]:
            continue
        reached[y, x] = True
        if y > 0: queue.append((y - 1, x))
        if y + 1 < height: queue.append((y + 1, x))
        if x > 0: queue.append((y, x - 1))
        if x + 1 < width: queue.append((y, x + 1))
    return reached


def _trial(source: Image.Image, clean_patch: Image.Image, threshold: float) -> tuple[Image.Image, int]:
    rgba = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    clean = np.asarray(clean_patch.convert("RGB"), dtype=np.float32)
    rgb = rgba[:, :, :3].astype(np.float32)
    alpha = rgba[:, :, 3]
    difference = np.sqrt(np.mean((rgb - clean) ** 2, axis=2))
    candidate = (alpha > 0) & (difference <= threshold)
    remove = _edge_connected(candidate, alpha > 0)
    rgba[remove, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, mode="RGBA"), int(np.count_nonzero(remove))


def _template_trial(source: Image.Image, template: Image.Image, threshold: float) -> tuple[Image.Image, int]:
    rgba = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    template_rgba = template.convert("RGBA")
    bounds = template_rgba.getchannel("A").point(lambda value: 255 if value > 2 else 0).getbbox()
    if bounds is None:
        raise ValueError("template has no alpha")
    trimmed = template_rgba.crop(bounds)
    inset = 4
    resized = trimmed.resize(
        (max(1, source.width - inset * 2), max(1, source.height - inset * 2)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", source.size, (0, 0, 0, 0))
    canvas.alpha_composite(resized, (inset, inset))
    template_array = np.asarray(canvas, dtype=np.float32)
    source_rgb = rgba[:, :, :3].astype(np.float32)
    template_rgb = template_array[:, :, :3]
    prior = template_array[:, :, 3]
    sample = (prior >= 128) & (rgba[:, :, 3] > 0)
    offset = np.zeros(3, dtype=np.float32)
    if np.count_nonzero(sample):
        offset = np.median(source_rgb[sample] - template_rgb[sample], axis=0)
    corrected = np.clip(template_rgb + offset.reshape((1, 1, 3)), 0, 255)
    difference = np.sqrt(np.mean((source_rgb - corrected) ** 2, axis=2))
    keep = (rgba[:, :, 3] > 0) & (prior > 3) & (difference <= threshold)
    old_visible = int(np.count_nonzero(rgba[:, :, 3]))
    rgba[~keep, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, mode="RGBA"), old_visible - int(np.count_nonzero(keep))


def _envelope_trial(source: Image.Image, template: Image.Image, margin: int) -> tuple[Image.Image, int]:
    rgba = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    template_rgba = template.convert("RGBA")
    bounds = template_rgba.getchannel("A").point(lambda value: 255 if value > 2 else 0).getbbox()
    if bounds is None:
        raise ValueError("template has no alpha")
    trimmed = template_rgba.crop(bounds)
    inset = 4
    resized = trimmed.resize(
        (max(1, source.width - inset * 2), max(1, source.height - inset * 2)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("L", source.size, 0)
    canvas.paste(resized.getchannel("A"), (inset, inset))
    prior = np.asarray(canvas, dtype=np.uint8) > 3
    envelope = np.zeros_like(prior, dtype=bool)
    for y in range(source.height):
        xs = np.flatnonzero(prior[y])
        if xs.size:
            envelope[y, max(0, int(xs[0]) - margin):min(source.width, int(xs[-1]) + margin + 1)] = True
    column_envelope = np.zeros_like(prior, dtype=bool)
    for x in range(source.width):
        ys = np.flatnonzero(prior[:, x])
        if ys.size:
            column_envelope[max(0, int(ys[0]) - margin):min(source.height, int(ys[-1]) + margin + 1), x] = True
    keep = (rgba[:, :, 3] > 0) & envelope & column_envelope
    old_visible = int(np.count_nonzero(rgba[:, :, 3]))
    rgba[~keep, 3] = 0
    rgba[rgba[:, :, 3] == 0, :3] = 0
    return Image.fromarray(rgba, mode="RGBA"), old_visible - int(np.count_nonzero(keep))


def _topology_trial(source: Image.Image, template: Image.Image, margin: int) -> tuple[Image.Image, int]:
    """Intersect target RGB with the clean Phase 148 silhouette only.

    Unlike the orthogonal row/column envelope, this keeps transparent gaps
    between leaves, stems, handles and separate objects.  A small dilation
    margin protects target-native antialiasing without admitting rectangular
    shelf or background fragments.
    """
    rgba = np.asarray(source.convert("RGBA"), dtype=np.uint8).copy()
    template_rgba = template.convert("RGBA")
    bounds = template_rgba.getchannel("A").point(lambda value: 255 if value > 2 else 0).getbbox()
    if bounds is None:
        raise ValueError("template has no alpha")
    trimmed = template_rgba.crop(bounds)
    inset = 4
    resized = trimmed.resize(
        (max(1, source.width - inset * 2), max(1, source.height - inset * 2)),
        Image.Resampling.LANCZOS,
    )
    prior_canvas = Image.new("L", source.size, 0)
    prior_canvas.paste(resized.getchannel("A"), (inset, inset))
    if margin > 0:
        prior_canvas = prior_canvas.filter(ImageFilter.MaxFilter(margin * 2 + 1))
    prior = np.asarray(prior_canvas, dtype=np.uint8)
    old_alpha = rgba[:, :, 3].copy()
    rgba[:, :, 3] = np.minimum(old_alpha, prior)
    rgba[rgba[:, :, 3] == 0, :3] = 0
    old_visible = int(np.count_nonzero(old_alpha))
    new_visible = int(np.count_nonzero(rgba[:, :, 3]))
    return Image.fromarray(rgba, mode="RGBA"), old_visible - new_visible


def _sheet(items: list[tuple[str, Image.Image, int]], output: Path) -> None:
    cell_w, cell_h, columns = 220, 260, 4
    rows = (len(items) + columns - 1) // columns
    sheet = Image.new("RGB", (cell_w * columns, cell_h * rows), "#efd89c")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, (name, image, removed) in enumerate(items):
        x = (index % columns) * cell_w
        y = (index // columns) * cell_h
        draw.rectangle((x, y, x + cell_w - 1, y + cell_h - 1), fill="#f6e8bf", outline="#68421b")
        preview = image.copy()
        preview.thumbnail((190, 210), Image.Resampling.LANCZOS)
        px = x + (cell_w - preview.width) // 2
        py = y + 28 + (210 - preview.height) // 2
        sheet.paste(preview, (px, py), preview)
        draw.text((x + 7, y + 6), f"{name} removed={removed}", fill="#2a1b10", font=font)
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, format="PNG", compress_level=9, optimize=False)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--thresholds", default="24,32,40,48")
    parser.add_argument("--envelope-margins", default="2,4,6")
    args = parser.parse_args()
    output_root = args.output_root.resolve()
    manifest = json.loads((PROJECT_ROOT / MANIFEST_REL).read_text(encoding="utf-8"))
    with Image.open(PROJECT_ROOT / CLEAN_REL) as opened:
        clean = opened.convert("RGB")
    for threshold in [float(value) for value in args.thresholds.split(",")]:
        items: list[tuple[str, Image.Image, int]] = []
        template_items: list[tuple[str, Image.Image, int]] = []
        for record in manifest["assets"]:
            source_path = PROJECT_ROOT / str(record["output"])
            x, y, width, height = [int(value) for value in record["source_bbox_full"]]
            with Image.open(source_path) as opened:
                source = opened.convert("RGBA")
            clean_patch = clean.crop((x, y - CONTENT_CROP_Y, x + width, y - CONTENT_CROP_Y + height))
            trial, removed = _trial(source, clean_patch, threshold)
            items.append((str(record["id"]), trial, removed))
            with Image.open(PROJECT_ROOT / str(record["topology_template"])) as opened:
                template = opened.convert("RGBA")
            template_trial, template_removed = _template_trial(source, template, threshold)
            template_items.append((str(record["id"]), template_trial, template_removed))
        _sheet(items, output_root / f"phase158-edge-clean-t{int(threshold)}.png")
        _sheet(template_items, output_root / f"phase158-template-clean-t{int(threshold)}.png")
    for margin in [int(value) for value in args.envelope_margins.split(",")]:
        envelope_items: list[tuple[str, Image.Image, int]] = []
        topology_items: list[tuple[str, Image.Image, int]] = []
        for record in manifest["assets"]:
            source_path = PROJECT_ROOT / str(record["output"])
            with Image.open(source_path) as opened:
                source = opened.convert("RGBA")
            with Image.open(PROJECT_ROOT / str(record["topology_template"])) as opened:
                template = opened.convert("RGBA")
            envelope_trial, envelope_removed = _envelope_trial(source, template, margin)
            envelope_items.append((str(record["id"]), envelope_trial, envelope_removed))
            topology_trial, topology_removed = _topology_trial(source, template, margin)
            topology_items.append((str(record["id"]), topology_trial, topology_removed))
        _sheet(envelope_items, output_root / f"phase158-envelope-clean-m{margin}.png")
        _sheet(topology_items, output_root / f"phase158-topology-clean-m{margin}.png")
    fern_path = PROJECT_ROOT / "assets/ui/visual/phase158/player_room/plants/room_plant_fern_phase158_v2.png"
    if fern_path.is_file():
        with Image.open(fern_path) as opened:
            fern = opened.convert("RGBA")
        scale = 4
        grid = Image.new("RGBA", (fern.width * scale, fern.height * scale), (239, 216, 156, 255))
        enlarged = fern.resize(grid.size, Image.Resampling.NEAREST)
        grid.alpha_composite(enlarged)
        draw = ImageDraw.Draw(grid)
        for x in range(0, fern.width, 10):
            draw.line((x * scale, 0, x * scale, grid.height), fill=(0, 130, 220, 100), width=1)
            draw.text((x * scale + 2, 2), str(x), fill=(0, 40, 70, 255))
        for y in range(0, fern.height, 10):
            draw.line((0, y * scale, grid.width, y * scale), fill=(220, 40, 70, 100), width=1)
            draw.text((2, y * scale + 2), str(y), fill=(80, 0, 20, 255))
        grid.save(output_root / "phase158-fern-grid.png", format="PNG", compress_level=9)
    print(f"PHASE158_ALPHA_AUDIT={output_root}")
    print("PHASE158_ALPHA_AUDIT=PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
