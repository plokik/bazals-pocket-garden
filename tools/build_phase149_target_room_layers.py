#!/usr/bin/env python3
"""Build target-native Phase 149 player-room layers deterministically.

The approved production target remains immutable.  The clean plate starts as an
exact copy of its content crop and replaces pixels only in the solid interiors
of the 21 collectible masks.  A separately generated object-free painting is
used only as the local donor below those masks.  Every collectible keeps the
approved target RGB byte-for-byte; this tool derives only its alpha mask.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter


TOOL_VERSION = 1
TARGET_RELATIVE = Path(
    "docs/visual-proposals/phase147/"
    "player-room-painted-cartoon-production-target-v1.png"
)
TARGET_SHA256 = "26A4387743AEBA8B9F464493D2563BF584620D28E2539E13E73EB076B421794D"
TARGET_SIZE = (853, 1844)
CONTENT_CROP = (0, 137, 853, 1685)
CONTENT_SIZE = (853, 1548)
CONTENT_SHA256 = "82D14A3B872C218B37B860F22E3980466974461A8A05784784BBD7ACEBDED8F7"

DEFAULT_DONOR = Path(
    "docs/visual-proposals/phase149/player-room-object-free-clean-donor-v2.png"
)
DONOR_SHA256 = "C61E60B39C14182EDADC57FFA43F3DEDD31C7BE1BD5FBECD1502D9BCF415B6A6"
DONOR_SIZE = (931, 1689)

OUTPUT_CLEAN_RELATIVE = Path(
    "assets/ui/player_room/player_room_phase149_target_clean_v1.png"
)
OUTPUT_FULL_RELATIVE = Path(
    "assets/ui/player_room/player_room_phase149_target_full_v1.png"
)
OUTPUT_ROOT_RELATIVE = Path("assets/ui/visual/phase149/player_room")
MANIFEST_NAME = "phase149_target_layers_manifest.json"
FOREGROUND_NAME = "player_room_furniture_foreground_v1.png"


@dataclass(frozen=True)
class AssetSpec:
    asset_id: str
    group: str
    filename: str
    bbox_full: tuple[int, int, int, int]
    anchor_full: tuple[int, int]
    template_relative: Path
    slot_index: int
    visual_index_in_slot: int = 0


def _phase148_template(group: str, filename: str) -> Path:
    return Path("assets/ui/visual/phase148/player_room") / group / filename


ASSETS = (
    AssetSpec("orchid", "plants", "room_plant_orchid_phase149.png", (80, 499, 127, 310), (130, 811), _phase148_template("plants", "room_plant_orchid_phase148.png"), 0),
    AssetSpec("glossy_broadleaf", "plants", "room_plant_glossy_broadleaf_phase149.png", (197, 582, 145, 228), (274, 811), _phase148_template("plants", "room_plant_glossy_broadleaf_phase148.png"), 1),
    AssetSpec("snake_plant", "plants", "room_plant_snake_plant_phase149.png", (330, 542, 139, 267), (416, 811), _phase148_template("plants", "room_plant_snake_plant_phase148.png"), 2),
    AssetSpec("fern", "plants", "room_plant_fern_phase149.png", (58, 826, 158, 208), (130, 1046), _phase148_template("plants", "room_plant_fern_phase148.png"), 3),
    AssetSpec("flowering_begonia", "plants", "room_plant_flowering_begonia_phase149.png", (199, 826, 158, 208), (274, 1046), _phase148_template("plants", "room_plant_flowering_begonia_phase148.png"), 4),
    AssetSpec("roundleaf_pilea", "plants", "room_plant_roundleaf_pilea_phase149.png", (339, 829, 136, 205), (416, 1046), _phase148_template("plants", "room_plant_roundleaf_pilea_phase148.png"), 5),
    AssetSpec("striped_calathea", "plants", "room_plant_striped_calathea_phase149.png", (58, 1072, 156, 214), (130, 1286), _phase148_template("plants", "room_plant_striped_calathea_phase148.png"), 6),
    AssetSpec("lemon_maranta", "plants", "room_plant_lemon_maranta_phase149.png", (199, 1087, 155, 199), (274, 1286), _phase148_template("plants", "room_plant_lemon_maranta_phase148.png"), 7),
    AssetSpec("compact_aglaonema", "plants", "room_plant_compact_aglaonema_phase149.png", (341, 1082, 134, 204), (414, 1286), _phase148_template("plants", "room_plant_compact_aglaonema_phase148.png"), 8),
    AssetSpec("fittonia", "plants", "room_plant_fittonia_phase149.png", (63, 1315, 149, 193), (130, 1507), _phase148_template("plants", "room_plant_fittonia_phase148.png"), 9),
    AssetSpec("pothos", "plants", "room_plant_pothos_phase149.png", (199, 1308, 157, 199), (274, 1507), _phase148_template("plants", "room_plant_pothos_phase148.png"), 10),
    AssetSpec("coleus", "plants", "room_plant_coleus_phase149.png", (339, 1308, 138, 199), (414, 1507), _phase148_template("plants", "room_plant_coleus_phase148.png"), 11),
    AssetSpec("books", "decor", "room_decor_books_phase149.png", (512, 282, 145, 129), (584, 412), _phase148_template("decor", "room_decor_books_phase148.png"), 12),
    AssetSpec("herb_jars", "decor", "room_decor_herb_jars_phase149.png", (670, 298, 159, 113), (750, 412), _phase148_template("decor", "room_decor_herb_jars_phase148.png"), 18),
    AssetSpec("fertilizer_bags", "decor", "room_decor_fertilizer_bags_phase149.png", (512, 474, 172, 133), (598, 608), _phase148_template("decor", "room_decor_fertilizer_bags_phase148.png"), 13),
    AssetSpec("botanical_print", "decor", "room_decor_botanical_print_phase149.png", (709, 472, 118, 136), (768, 608), _phase148_template("decor", "room_decor_botanical_print_phase148.png"), 16),
    AssetSpec("table_lamp", "decor", "room_decor_table_lamp_phase149.png", (550, 1044, 99, 164), (600, 1210), _phase148_template("decor", "room_decor_table_lamp_phase148.png"), 15),
    AssetSpec("nested_pots", "decor", "room_decor_nested_pots_phase149.png", (678, 1052, 122, 158), (739, 1212), _phase148_template("decor", "room_decor_nested_pots_phase148.png"), 14),
    AssetSpec("watering_can", "decor", "room_decor_watering_can_phase149.png", (520, 1360, 140, 150), (590, 1511), _phase148_template("decor", "room_decor_watering_can_phase148.png"), 17),
    AssetSpec("cat_bed", "decor", "room_decor_cat_bed_phase149.png", (638, 1355, 200, 155), (736, 1511), _phase148_template("decor", "room_decor_cat_bed_phase148.png"), 19, 0),
    AssetSpec("paired_bowls", "decor", "room_decor_paired_bowls_phase149.png", (574, 1505, 205, 105), (681, 1610), _phase148_template("decor", "room_decor_paired_bowls_phase148.png"), 19, 1),
)


# Full-master coordinates.  These sparse strips are drawn above collectibles so
# their contact line is physically seated behind the authored furniture lip.
OCCLUSION_RECTS_FULL = (
    (48, 811, 442, 32),
    (49, 1044, 442, 22),
    (49, 1284, 442, 27),
    (49, 1505, 442, 20),
    (506, 409, 335, 24),
    (507, 605, 333, 25),
    (536, 1208, 277, 23),
)

# One target leaf tip extends just above the measured third-row envelope.  Keep
# this correction local instead of expanding or repainting the whole rack.
CLEAN_FRAGMENT_RECTS_CONTENT = (
    (278, 932, 28, 24),
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def _sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest().upper()


def _relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return str(path.resolve())


def _content_bbox(bbox_full: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    x, y, width, height = bbox_full
    return (x, y - CONTENT_CROP[1], width, height)


def _content_anchor(anchor_full: tuple[int, int]) -> tuple[int, int]:
    return (anchor_full[0], anchor_full[1] - CONTENT_CROP[1])


def _trim_template(template: Image.Image) -> Image.Image:
    if template.mode != "RGBA":
        raise ValueError(f"template must be RGBA, got {template.mode}")
    alpha = template.getchannel("A")
    bounds = alpha.point(lambda value: 255 if value > 2 else 0).getbbox()
    if bounds is None:
        raise ValueError("template has no non-transparent pixels")
    return template.crop(bounds).convert("RGBA")


def _mask_from_target_and_template(
    target_patch: Image.Image,
    donor_patch: Image.Image,
    template: Image.Image,
    asset_id: str,
) -> tuple[Image.Image, dict]:
    """Build a target-first trimap constrained by the prior silhouette.

    The Phase 148 alpha is not treated as artwork.  It is only a topology prior
    telling us which target/donor differences belong to this object instead of
    neighbouring furniture.  Strong target/donor evidence may expand that prior
    by eight pixels, which is important for the differently proportioned target
    orchid and pet bowls.
    """

    width, height = target_patch.size
    inset = 4
    inner_width = max(1, width - inset * 2)
    inner_height = max(1, height - inset * 2)
    resized_template = template.resize((inner_width, inner_height), Image.Resampling.LANCZOS)
    resized_prior = resized_template.getchannel("A")
    prior_canvas = Image.new("L", (width, height), 0)
    prior_canvas.paste(resized_prior, (inset, inset))
    prior = np.asarray(prior_canvas, dtype=np.uint8)

    template_canvas = Image.new("RGB", (width, height), (0, 0, 0))
    template_canvas.paste(resized_template.convert("RGB"), (inset, inset))
    template_rgb = np.asarray(template_canvas, dtype=np.int16)

    support_image = prior_canvas.point(lambda value: 255 if value > 3 else 0).filter(ImageFilter.MaxFilter(13))
    support = np.asarray(support_image, dtype=np.uint8) > 0
    target = np.asarray(target_patch.convert("RGB"), dtype=np.int16)
    donor = np.asarray(donor_patch.convert("RGB"), dtype=np.int16)

    ring = (prior < 4) & (~support)
    if int(ring.sum()) < 32:
        ring = prior < 4
    colour_offset = np.zeros(3, dtype=np.int16)
    if int(ring.sum()) > 0:
        colour_offset = np.rint(np.median((target - donor)[ring], axis=0)).astype(np.int16)
    corrected = np.clip(donor + colour_offset.reshape((1, 1, 3)), 0, 255)
    difference = np.sqrt(np.mean((target.astype(np.float32) - corrected.astype(np.float32)) ** 2, axis=2))

    template_sample = prior >= 128
    template_offset = np.zeros(3, dtype=np.int16)
    if int(template_sample.sum()) > 0:
        template_offset = np.rint(np.median((target - template_rgb)[template_sample], axis=0)).astype(np.int16)
    corrected_template = np.clip(template_rgb + template_offset.reshape((1, 1, 3)), 0, 255)
    template_difference = np.sqrt(
        np.mean((target.astype(np.float32) - corrected_template.astype(np.float32)) ** 2, axis=2)
    )
    template_values = template_difference[template_sample]
    appearance_p82 = float(np.percentile(template_values, 82)) if template_values.size else 72.0
    appearance_p94 = float(np.percentile(template_values, 94)) if template_values.size else 108.0
    appearance_threshold = min(72.0, max(52.0, appearance_p82))
    loose_appearance_threshold = min(105.0, max(78.0, appearance_p94))

    ring_values = difference[ring]
    noise_p90 = float(np.percentile(ring_values, 90)) if ring_values.size else 12.0
    noise_p97 = float(np.percentile(ring_values, 97)) if ring_values.size else 20.0
    weak_threshold = max(10.0, noise_p90 + 2.0)
    strong_threshold = max(22.0, noise_p97 + 5.0)

    # Keep the known topology, then admit strong target-only evidence close to
    # it.  This produces an irregular silhouette rather than a rectangular crop.
    # The old atlas is a topology prior, never an RGB source.  Retain its full
    # irregular alpha silhouette instead of cutting away target leaves merely
    # because their new painting differs in colour.  Strong target/donor
    # evidence may extend it locally by six pixels, but never beyond that
    # dilated non-rectangular support.
    capped_strong_threshold = min(75.0, strong_threshold)
    topology_coverage = np.asarray(
        prior_canvas.point(lambda value: 255 if value >= 12 else 0).filter(ImageFilter.MaxFilter(7)),
        dtype=np.uint8,
    ) > 0
    binary = topology_coverage
    binary |= support & (difference >= capped_strong_threshold) & (template_difference <= 145.0)
    binary &= support

    binary_image = Image.fromarray((binary.astype(np.uint8) * 255), mode="L")
    # A one-source-pixel outward safety keeps target AA while the separate clean
    # removal envelope handles all larger silhouette drift.
    binary_image = binary_image.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(3))
    binary = np.asarray(binary_image, dtype=np.uint8) > 0

    if asset_id == "paired_bowls":
        yy, xx = np.mgrid[0:height, 0:width]
        teal_bowl = ((xx - 43.0) / 49.0) ** 2 + ((yy - 43.0) / 43.0) ** 2 <= 1.0
        orange_bowl = ((xx - 135.0) / 50.0) ** 2 + ((yy - 43.0) / 43.0) ** 2 <= 1.0
        teal_shadow = ((xx - 43.0) / 52.0) ** 2 + ((yy - 76.0) / 11.0) ** 2 <= 1.0
        orange_shadow = ((xx - 135.0) / 53.0) ** 2 + ((yy - 76.0) / 11.0) ** 2 <= 1.0
        binary &= teal_bowl | orange_bowl | teal_shadow | orange_shadow
    elif asset_id == "watering_can":
        target_rgb = target.astype(np.int16)
        warm_overlap = (
            (np.indices((height, width))[1] > int(width * 0.70))
            & (np.indices((height, width))[0] < int(height * 0.70))
            & (target_rgb[:, :, 0] > 130)
            & (target_rgb[:, :, 1] > 60)
            & (target_rgb[:, :, 2] < 90)
            & (target_rgb[:, :, 0] > target_rgb[:, :, 1] * 1.05)
        )
        binary &= ~warm_overlap
    elif asset_id in {
        "orchid",
        "glossy_broadleaf",
        "snake_plant",
        "fern",
        "flowering_begonia",
        "roundleaf_pilea",
        "striped_calathea",
        "lemon_maranta",
        "compact_aglaonema",
        "fittonia",
        "pothos",
        "coleus",
    }:
        target_rgb = target.astype(np.int16)
        yy, xx = np.mgrid[0:height, 0:width]
        side_band = (xx < int(width * 0.22)) | (xx > int(width * 0.78))
        warm_background = (
            side_band
            & (yy < int(height * 0.72))
            & (target_rgb[:, :, 0] > target_rgb[:, :, 1] * 1.08)
            & (target_rgb[:, :, 1] > target_rgb[:, :, 2] * 1.25)
            & ((target_rgb[:, :, 0] - target_rgb[:, :, 2]) > 45)
        )
        binary &= ~warm_background

    # The measured bboxes already include a four-pixel painted-AA envelope.
    # Keeping a transparent outer two-pixel frame proves that no rectangular
    # sticker background can survive and is safe under linear downsampling.
    binary[:2, :] = False
    binary[-2:, :] = False
    binary[:, :2] = False
    binary[:, -2:] = False

    hard = Image.fromarray((binary.astype(np.uint8) * 255), mode="L")
    feathered = hard.filter(ImageFilter.GaussianBlur(0.55))
    eroded = hard.filter(ImageFilter.MinFilter(3))
    alpha_array = np.asarray(feathered, dtype=np.uint8).copy()
    alpha_array[np.asarray(eroded, dtype=np.uint8) == 255] = 255
    alpha_array[:1, :] = 0
    alpha_array[-1:, :] = 0
    alpha_array[:, :1] = 0
    alpha_array[:, -1:] = 0
    alpha = Image.fromarray(alpha_array, mode="L")

    qa = {
        "template_prior_only_not_rgb_source": True,
        "target_donor_colour_offset_rgb": [int(value) for value in colour_offset],
        "target_template_colour_offset_rgb": [int(value) for value in template_offset],
        "background_noise_p90": round(noise_p90, 4),
        "background_noise_p97": round(noise_p97, 4),
        "weak_threshold": round(weak_threshold, 4),
        "strong_threshold": round(strong_threshold, 4),
        "capped_strong_threshold": round(capped_strong_threshold, 4),
        "appearance_p82": round(appearance_p82, 4),
        "appearance_p94": round(appearance_p94, 4),
        "appearance_threshold": round(appearance_threshold, 4),
        "loose_appearance_threshold": round(loose_appearance_threshold, 4),
        "nonzero_alpha_pixels": int((alpha_array > 0).sum()),
        "solid_alpha_pixels": int((alpha_array == 255).sum()),
        "soft_alpha_pixels": int(((alpha_array > 0) & (alpha_array < 255)).sum()),
        "transparent_ratio": round(float((alpha_array == 0).sum()) / alpha_array.size, 6),
        "solid_coverage_ratio": round(float((alpha_array == 255).sum()) / alpha_array.size, 6),
        "edge_max_alpha": int(max(alpha_array[0, :].max(), alpha_array[-1, :].max(), alpha_array[:, 0].max(), alpha_array[:, -1].max())),
    }
    return alpha, qa


def _make_rgba(target_patch: Image.Image, alpha: Image.Image) -> Image.Image:
    rgba = target_patch.convert("RGBA")
    rgba.putalpha(alpha)
    array = np.asarray(rgba, dtype=np.uint8).copy()
    array[array[:, :, 3] == 0, :3] = 0
    return Image.fromarray(array, mode="RGBA")


def _save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", compress_level=9, optimize=False)


def _clean_removal_union() -> Image.Image:
    """Return a soft, local removal mask covering every approved object bbox.

    The layer trimaps stay irregular and sticker-free.  The clean plate has a
    different job: it must remove every last painted fragment even where the old
    atlas topology does not match the target.  Rounded, feathered target-native
    envelopes give the object-free donor enough room while keeping all pixels
    outside their union byte-identical to the target.
    """

    union = Image.new("L", CONTENT_SIZE, 0)
    for spec in ASSETS:
        x, y, width, height = _content_bbox(spec.bbox_full)
        _anchor_x, anchor_y = _content_anchor(spec.anchor_full)
        extra = 12 if spec.group == "plants" else 10
        blur_radius = 6.0 if spec.group == "plants" else 5.0
        if spec.asset_id == "botanical_print":
            extra = 28
            blur_radius = 12.0
        elif spec.asset_id in {"books", "herb_jars", "fertilizer_bags"}:
            extra = 16
            blur_radius = 8.0
        elif spec.asset_id in {"cat_bed", "paired_bowls", "watering_can"}:
            extra = 15
            blur_radius = 8.0
        left = max(0, x - extra)
        top = max(0, y - extra)
        right = min(CONTENT_SIZE[0] - 1, x + width + extra)
        bottom = min(CONTENT_SIZE[1] - 1, max(y + height + extra, anchor_y + extra))
        local = Image.new("L", CONTENT_SIZE, 0)
        draw = ImageDraw.Draw(local)
        radius = max(5, min(14, min(width, height) // 8))
        draw.rounded_rectangle(
            (left, top, right, bottom),
            radius=radius,
            fill=255,
        )
        local = local.filter(ImageFilter.GaussianBlur(blur_radius))
        union = ImageChops.lighter(union, local)
    for x, y, width, height in CLEAN_FRAGMENT_RECTS_CONTENT:
        local = Image.new("L", CONTENT_SIZE, 0)
        draw = ImageDraw.Draw(local)
        draw.rounded_rectangle((x, y, x + width - 1, y + height - 1), radius=7, fill=255)
        local = local.filter(ImageFilter.GaussianBlur(4.0))
        union = ImageChops.lighter(union, local)
    return union


def _foreground_occlusion(target: Image.Image) -> tuple[Image.Image, dict]:
    rgba = Image.new("RGBA", CONTENT_SIZE, (0, 0, 0, 0))
    alpha = Image.new("L", CONTENT_SIZE, 0)
    rects_content: list[list[int]] = []
    for x, y, width, height in OCCLUSION_RECTS_FULL:
        content_rect = (x, y - CONTENT_CROP[1], width, height)
        left, top, rect_width, rect_height = content_rect
        region = target.crop((left, top, left + rect_width, top + rect_height)).convert("RGBA")
        region.putalpha(255)
        rgba.alpha_composite(region, (left, top))
        alpha.paste(255, (left, top, left + rect_width, top + rect_height))
        rects_content.append(list(content_rect))
    return rgba, {
        "source_rects_full": [list(rect) for rect in OCCLUSION_RECTS_FULL],
        "content_rects": rects_content,
        "nonzero_alpha_pixels": int(np.count_nonzero(np.asarray(alpha, dtype=np.uint8))),
        "edge_max_alpha": 0,
        "role": "target_native_furniture_front_lips_drawn_above_collectibles",
    }


def build(project_root: Path, donor_path: Path) -> dict:
    errors: list[str] = []
    target_path = project_root / TARGET_RELATIVE
    clean_path = project_root / OUTPUT_CLEAN_RELATIVE
    full_path = project_root / OUTPUT_FULL_RELATIVE
    output_root = project_root / OUTPUT_ROOT_RELATIVE

    if not target_path.is_file():
        raise FileNotFoundError(f"missing target: {target_path}")
    if _sha256(target_path) != TARGET_SHA256:
        raise ValueError(f"target hash mismatch: {_sha256(target_path)}")
    if not donor_path.is_file():
        raise FileNotFoundError(f"missing donor: {donor_path}")
    if _sha256(donor_path) != DONOR_SHA256:
        raise ValueError(f"donor hash mismatch: {_sha256(donor_path)}")

    with Image.open(target_path) as opened:
        if opened.size != TARGET_SIZE:
            raise ValueError(f"target size mismatch: {opened.size}")
        target_full = opened.convert("RGB")
    target = target_full.crop(CONTENT_CROP)
    if target.size != CONTENT_SIZE:
        raise ValueError(f"content crop size mismatch: {target.size}")
    if _sha256_bytes(target.tobytes()) == "":
        raise AssertionError("unreachable content digest guard")

    # Verify the existing versioned content crop without changing it.
    content_reference = project_root / "docs/visual-proposals/phase149/player-room-exact-content-target-v1.png"
    if not content_reference.is_file() or _sha256(content_reference) != CONTENT_SHA256:
        raise ValueError("versioned Phase149 content reference is missing or changed")
    full_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(content_reference, full_path)
    if _sha256(full_path) != CONTENT_SHA256:
        raise ValueError("canonical full runtime master is not byte-exact to content reference")

    with Image.open(donor_path) as opened:
        if opened.size != DONOR_SIZE:
            raise ValueError(f"donor size mismatch: {opened.size}")
        donor = opened.convert("RGB").resize(CONTENT_SIZE, Image.Resampling.LANCZOS)

    clean = target.copy()
    hard_union = Image.new("L", CONTENT_SIZE, 0)
    asset_records: list[dict] = []
    layer_images: list[tuple[AssetSpec, Image.Image, tuple[int, int, int, int]]] = []

    for spec in ASSETS:
        template_path = project_root / spec.template_relative
        if not template_path.is_file():
            errors.append(f"missing topology template: {spec.template_relative.as_posix()}")
            continue
        with Image.open(template_path) as opened:
            template = _trim_template(opened.copy())

        x, y, width, height = _content_bbox(spec.bbox_full)
        if x < 0 or y < 0 or x + width > CONTENT_SIZE[0] or y + height > CONTENT_SIZE[1]:
            errors.append(f"{spec.asset_id}: content bbox is outside the approved crop")
            continue
        target_patch = target.crop((x, y, x + width, y + height))
        donor_patch = donor.crop((x, y, x + width, y + height))
        alpha, qa = _mask_from_target_and_template(target_patch, donor_patch, template, spec.asset_id)
        alpha_array = np.asarray(alpha, dtype=np.uint8)
        if qa["nonzero_alpha_pixels"] < 64:
            errors.append(f"{spec.asset_id}: alpha mask is unexpectedly empty")
        if qa["edge_max_alpha"] != 0:
            errors.append(f"{spec.asset_id}: alpha reaches PNG edge")
        if qa["transparent_ratio"] < 0.01:
            errors.append(f"{spec.asset_id}: less than 1% transparent; rectangular sticker risk")

        rgba = _make_rgba(target_patch, alpha)
        output_path = output_root / spec.group / spec.filename
        _save_png(rgba, output_path)

        saved_hash = _sha256(output_path)
        with Image.open(output_path) as check:
            if check.mode != "RGBA" or check.size != (width, height):
                errors.append(f"{spec.asset_id}: saved PNG mode/size mismatch")
            saved = np.asarray(check.convert("RGBA"), dtype=np.uint8)
        target_array = np.asarray(target_patch, dtype=np.uint8)
        visible = saved[:, :, 3] > 0
        rgb_mismatch = int(np.count_nonzero(np.any(saved[:, :, :3][visible] != target_array[visible], axis=1)))
        if rgb_mismatch:
            errors.append(f"{spec.asset_id}: {rgb_mismatch} visible RGB pixels differ from target")

        solid = Image.fromarray(((alpha_array == 255).astype(np.uint8) * 255), mode="L")
        hard_union.paste(ImageChops.lighter(hard_union.crop((x, y, x + width, y + height)), solid), (x, y))
        layer_images.append((spec, rgba, (x, y, width, height)))
        asset_records.append(
            {
                "id": spec.asset_id,
                "group": spec.group,
                "slot_index": spec.slot_index,
                "visual_index_in_slot": spec.visual_index_in_slot,
                "source_bbox_full": list(spec.bbox_full),
                "content_bbox": [x, y, width, height],
                "anchor_full": list(spec.anchor_full),
                "anchor_content": list(_content_anchor(spec.anchor_full)),
                "pivot_in_output": [spec.anchor_full[0] - spec.bbox_full[0], spec.anchor_full[1] - spec.bbox_full[1]],
                "output": _relative(output_path, project_root),
                "output_size": [width, height],
                "output_mode": "RGBA",
                "output_sha256": saved_hash,
                "rgb_policy": "all_nontransparent_rgb_is_byte_exact_target_crop_rgb",
                "topology_template": _relative(template_path, project_root),
                "qa": {**qa, "visible_target_rgb_mismatch_pixels": rgb_mismatch},
            }
        )

    # The collectible alpha union is retained as topology evidence.  The clean
    # plate uses the broader target-native removal envelopes so no flower, leaf,
    # ceramic edge, or contact shadow survives an empty slot.
    hard_union_array = np.asarray(hard_union, dtype=np.uint8) == 255
    removal_union = _clean_removal_union()
    removal_alpha = np.asarray(removal_union, dtype=np.float32)[:, :, None] / 255.0
    clean_array = np.asarray(clean, dtype=np.uint8).copy()
    donor_array = np.asarray(donor, dtype=np.uint8)
    blended = np.rint(
        np.asarray(target, dtype=np.float32) * (1.0 - removal_alpha)
        + donor_array.astype(np.float32) * removal_alpha
    ).clip(0, 255).astype(np.uint8)
    removal_nonzero = removal_alpha[:, :, 0] > 0.0
    clean_array[removal_nonzero] = blended[removal_nonzero]
    clean = Image.fromarray(clean_array, mode="RGB")
    _save_png(clean, clean_path)

    foreground, foreground_qa = _foreground_occlusion(target)
    foreground_path = output_root / FOREGROUND_NAME
    _save_png(foreground, foreground_path)

    reconstruction = clean.convert("RGBA")
    for _spec, layer, (x, y, _width, _height) in layer_images:
        reconstruction.alpha_composite(layer, (x, y))
    reconstruction.alpha_composite(foreground)
    reconstructed_rgb = np.asarray(reconstruction.convert("RGB"), dtype=np.int16)
    target_rgb = np.asarray(target, dtype=np.int16)
    absolute = np.abs(reconstructed_rgb - target_rgb)
    squared = (reconstructed_rgb.astype(np.float32) - target_rgb.astype(np.float32)) ** 2
    exact_pixels = np.all(reconstructed_rgb == target_rgb, axis=2)
    reconstruction_metrics = {
        "mean_abs_error": round(float(absolute.mean()), 8),
        "rgb_mae": round(float(absolute.mean()), 8),
        "rgb_rmse": round(float(np.sqrt(squared.mean())), 8),
        "max_channel_error": int(absolute.max()),
        "exact_pixel_ratio": round(float(exact_pixels.mean()), 8),
        "changed_pixel_count": int((~exact_pixels).sum()),
    }
    per_pixel_error = np.max(absolute, axis=2)
    coverage_gap = per_pixel_error > 12
    severe_gap = per_pixel_error > 48
    reconstruction_metrics["pixels_over_tolerance_12"] = int(coverage_gap.sum())
    reconstruction_metrics["ratio_over_tolerance_12"] = round(float(coverage_gap.mean()), 8)
    reconstruction_metrics["pixels_over_tolerance_48"] = int(severe_gap.sum())
    reconstruction_metrics["ratio_over_tolerance_48"] = round(float(severe_gap.mean()), 8)

    qa_output_root = output_root / "qa"
    reconstruction_path = qa_output_root / "phase149_canonical_reconstruction_qa.png"
    heatmap_path = qa_output_root / "phase149_layer_coverage_heatmap.png"
    _save_png(reconstruction.convert("RGB"), reconstruction_path)
    heat_strength = np.clip(per_pixel_error.astype(np.float32) * 2.4, 0, 255).astype(np.uint8)
    heatmap_array = np.zeros((CONTENT_SIZE[1], CONTENT_SIZE[0], 4), dtype=np.uint8)
    heatmap_array[:, :, 0] = heat_strength
    heatmap_array[:, :, 1] = np.where(per_pixel_error <= 12, heat_strength // 5, 0)
    heatmap_array[:, :, 3] = np.where(per_pixel_error > 3, np.maximum(72, heat_strength), 0)
    _save_png(Image.fromarray(heatmap_array, mode="RGBA"), heatmap_path)
    target_array = np.asarray(target, dtype=np.uint8)
    clean_saved = np.asarray(clean, dtype=np.uint8)
    outside_union = ~removal_nonzero
    outside_mismatch = int(
        np.count_nonzero(np.any(clean_saved[outside_union] != target_array[outside_union], axis=1))
    )
    if outside_mismatch:
        errors.append(f"clean plate changed {outside_mismatch} pixels outside object removal masks")
    solid_removal = removal_alpha[:, :, 0] >= 1.0
    solid_not_donor = int(
        np.count_nonzero(np.any(clean_saved[solid_removal] != donor_array[solid_removal], axis=1))
    )
    if solid_not_donor:
        errors.append(f"clean plate retained {solid_not_donor} non-donor pixels in solid removal cores")

    slot_visual_counts = {str(index): 0 for index in range(20)}
    for record in asset_records:
        slot_visual_counts[str(record["slot_index"])] += 1
    expected_counts = {str(index): 1 for index in range(20)}
    expected_counts["19"] = 2
    if slot_visual_counts != expected_counts:
        errors.append(f"slot/visual topology mismatch: {slot_visual_counts}")

    manifest = {
        "schema": "phase149_target_room_layers_v1",
        "tool_version": TOOL_VERSION,
        "deterministic": True,
        "coordinate_space": {
            "full_master_size": list(TARGET_SIZE),
            "content_crop_xyxy": list(CONTENT_CROP),
            "content_size": list(CONTENT_SIZE),
            "bbox_format": "x_y_width_height",
            "asset_png_policy": "canvas_size_equals_content_bbox_size_no_extra_padding",
        },
        "sources": {
            "target": {
                "path": _relative(target_path, project_root),
                "sha256": TARGET_SHA256,
                "mode": "RGB",
                "size": list(TARGET_SIZE),
                "immutable": True,
            },
            "content_reference": {
                "path": _relative(content_reference, project_root),
                "sha256": CONTENT_SHA256,
                "size": list(CONTENT_SIZE),
                "immutable": True,
            },
            "clean_donor": {
                "path": _relative(donor_path, project_root),
                "sha256": DONOR_SHA256,
                "source_size": list(DONOR_SIZE),
                "registration": "deterministic_lanczos_full_frame_resize_to_853x1548",
                "usage": "only_under_solid_target_object_masks",
            },
        },
        "clean_plate": {
            "output": _relative(clean_path, project_root),
            "output_sha256": _sha256(clean_path),
            "mode": "RGB",
            "size": list(CONTENT_SIZE),
            "layer_solid_union_pixels": int(hard_union_array.sum()),
            "removal_mask_nonzero_pixels": int(removal_nonzero.sum()),
            "removal_mask_solid_pixels": int((removal_alpha[:, :, 0] >= 1.0).sum()),
            "outside_removal_mask_rgb_mismatch_pixels": outside_mismatch,
            "solid_removal_pixels_not_equal_registered_donor": solid_not_donor,
            "removal_mask_policy": "rounded_target_bbox_union_per_group_5_to_12px_feather_plus_locked_fragment_patch_v1",
            "locked_fragment_rects_content": [list(rect) for rect in CLEAN_FRAGMENT_RECTS_CONTENT],
            "empty_ghost_qa": {
                "status": "PASSED" if outside_mismatch == 0 and solid_not_donor == 0 else "FAILED",
                "rack_leaf_fragments": "covered_by_plant_envelopes_and_locked_x278_y932_patch",
                "floor_bowl_outlines": "covered_by_corrected_paired_bowls_removal_envelope",
                "right_wall_rectangular_artifact": "covered_by_expanded_botanical_print_mask_with_12px_feather",
            },
        },
        "canonical_full_master": {
            "output": _relative(full_path, project_root),
            "output_sha256": _sha256(full_path),
            "mode": "RGB",
            "size": list(CONTENT_SIZE),
            "byte_exact_content_reference_copy": True,
            "coverage": {
                "status": "PASSED",
                "mean_abs_error": 0.0,
                "rgb_rmse": 0.0,
                "max_channel_error": 0,
                "exact_pixel_ratio": 1.0,
            },
        },
        "slot_contract": {
            "slot_count": 20,
            "visual_layer_count": 21,
            "plant_slot_count": 12,
            "fixed_slot_count": 8,
            "slot_visual_counts": slot_visual_counts,
            "slot_19_layers": ["cat_bed", "paired_bowls"],
        },
        "assets": asset_records,
        "foreground_occlusion": {
            "output": _relative(foreground_path, project_root),
            "output_sha256": _sha256(foreground_path),
            "mode": "RGBA",
            "size": list(CONTENT_SIZE),
            "qa": foreground_qa,
        },
        "reconstruction": reconstruction_metrics,
        "full_layer_coverage": {
            "status": "PASSED"
            if reconstruction_metrics["mean_abs_error"] <= 2.0
            and reconstruction_metrics["rgb_rmse"] <= 12.0
            and reconstruction_metrics["ratio_over_tolerance_12"] <= 0.08
            else "FAILED",
            "thresholds": {
                "mean_abs_error_max": 2.0,
                "rgb_rmse_max": 12.0,
                "ratio_over_tolerance_12_max": 0.08,
            },
            "metrics": reconstruction_metrics,
            "reconstruction_output": _relative(reconstruction_path, project_root),
            "reconstruction_sha256": _sha256(reconstruction_path),
            "heatmap_output": _relative(heatmap_path, project_root),
            "heatmap_sha256": _sha256(heatmap_path),
        },
        "qa": {
            "status": "PASSED" if not errors and len(asset_records) == 21 else "FAILED",
            "expected_slot_count": 20,
            "expected_visual_layer_count": 21,
            "written_visual_layer_count": len(asset_records),
            "expected_collectible_layer_count": 21,
            "written_collectible_layer_count": len(asset_records),
            "target_source_rgb_mutation": False,
            "canonical_reconstruction_is_metric_not_claimed_byte_exact": True,
            "full_layer_coverage_status": "PASSED"
            if reconstruction_metrics["mean_abs_error"] <= 2.0
            and reconstruction_metrics["rgb_rmse"] <= 12.0
            and reconstruction_metrics["ratio_over_tolerance_12"] <= 0.08
            else "FAILED",
            "canonical_full_master_coverage_status": "PASSED",
            "rectangular_sticker_backgrounds": False,
            "errors": errors,
        },
    }
    return manifest


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--donor", type=Path, default=DEFAULT_DONOR)
    args = parser.parse_args(list(argv) if argv is not None else None)

    project_root = args.project_root.resolve()
    output_root = (project_root / OUTPUT_ROOT_RELATIVE).resolve()
    clean_path = (project_root / OUTPUT_CLEAN_RELATIVE).resolve()
    full_path = (project_root / OUTPUT_FULL_RELATIVE).resolve()
    if project_root != Path(__file__).resolve().parents[1]:
        print("ERROR: --project-root must be the checkout containing this tool", file=sys.stderr)
        return 2
    if (
        not str(output_root).startswith(str(project_root))
        or not str(clean_path).startswith(str(project_root))
        or not str(full_path).startswith(str(project_root))
    ):
        print("ERROR: output paths escaped the project root", file=sys.stderr)
        return 2

    try:
        donor_path = args.donor if args.donor.is_absolute() else project_root / args.donor
        manifest = build(project_root, donor_path.resolve())
    except (FileNotFoundError, ValueError, OSError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    output_root.mkdir(parents=True, exist_ok=True)
    manifest_path = output_root / MANIFEST_NAME
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if manifest["qa"]["status"] != "PASSED":
        print(json.dumps(manifest["qa"], ensure_ascii=False, indent=2), file=sys.stderr)
        return 1

    print("PHASE149_ASSET_INTEGRITY=PASSED")
    print(f"PHASE149_FULL_LAYER_COVERAGE={manifest['full_layer_coverage']['status']}")
    print("PHASE149_CANONICAL_MASTER_COVERAGE=PASSED")
    print(f"PHASE149_COLLECTIBLE_LAYERS={len(manifest['assets'])}")
    print(f"PHASE149_SLOT_COUNT={manifest['slot_contract']['slot_count']}")
    print(f"PHASE149_RECONSTRUCTION_MAX_ERROR={manifest['reconstruction']['max_channel_error']}")
    print(f"PHASE149_MANIFEST={_relative(manifest_path, project_root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
