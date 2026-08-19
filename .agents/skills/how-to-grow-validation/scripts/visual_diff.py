#!/usr/bin/env python3
"""Create normalized visual-regression metrics and heatmaps without modifying baselines."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

try:
    from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageOps, ImageStat
except ImportError as exc:  # pragma: no cover - environment preflight
    raise SystemExit("Pillow is required. Run with the Codex bundled Python or install Pillow.") from exc


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", required=True, type=Path)
    parser.add_argument("--artifacts", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--report-only", action="store_true", help="Measure gates without failing thresholds.")
    return parser.parse_args()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def safe_id(value: str) -> str:
    normalized = re.sub(r"[^a-z0-9-]+", "-", value.lower()).strip("-")
    if not normalized:
        raise ValueError("Visual case id must contain a letter or digit.")
    return normalized


def crop_box(size: tuple[int, int], normalized: list[float]) -> tuple[int, int, int, int]:
    if len(normalized) != 4:
        raise ValueError("Crop must be [x, y, width, height].")
    x, y, width, height = (float(item) for item in normalized)
    if x < 0 or y < 0 or width <= 0 or height <= 0 or x + width > 1.000001 or y + height > 1.000001:
        raise ValueError(f"Invalid normalized crop: {normalized}")
    left = round(x * size[0])
    top = round(y * size[1])
    right = round((x + width) * size[0])
    bottom = round((y + height) * size[1])
    if right <= left or bottom <= top:
        raise ValueError(f"Crop has no pixels: {normalized} for {size}")
    return left, top, right, bottom


def normalized_image(path: Path, crop: list[float], size: tuple[int, int]) -> Image.Image:
    with Image.open(path) as source:
        rgb = source.convert("RGB")
        cropped = rgb.crop(crop_box(rgb.size, crop))
        return cropped.resize(size, Image.Resampling.LANCZOS)


def valid_mask(size: tuple[int, int], masks: list[list[float]]) -> Image.Image:
    mask = Image.new("L", size, 255)
    draw = ImageDraw.Draw(mask)
    for rectangle in masks:
        left, top, right, bottom = crop_box(size, rectangle)
        draw.rectangle((left, top, max(left, right - 1), max(top, bottom - 1)), fill=0)
    return mask


def max_channel(image: Image.Image) -> Image.Image:
    red, green, blue = image.split()
    return ImageChops.lighter(ImageChops.lighter(red, green), blue)


def average(values: list[float]) -> float:
    return sum(values) / max(1, len(values))


def compare_case(
    case: dict[str, Any],
    defaults: dict[str, Any],
    project_root: Path,
    artifacts: Path,
    output: Path,
    report_only: bool,
) -> dict[str, Any]:
    case_id = safe_id(str(case["id"]))
    reference_path = (project_root / str(case["reference"])).resolve()
    actual_path = (artifacts / str(case["actual"])).resolve()
    if not reference_path.is_file():
        raise FileNotFoundError(f"Missing reference: {reference_path}")
    if not actual_path.is_file():
        raise FileNotFoundError(f"Missing capture: {actual_path}")

    target_size_raw = case.get("size")
    if not isinstance(target_size_raw, list) or len(target_size_raw) != 2:
        raise ValueError(f"Case {case_id} requires size [width, height].")
    target_size = (int(target_size_raw[0]), int(target_size_raw[1]))
    if target_size[0] <= 0 or target_size[1] <= 0:
        raise ValueError(f"Case {case_id} has invalid target size {target_size}.")

    reference = normalized_image(reference_path, case.get("reference_crop", [0, 0, 1, 1]), target_size)
    actual = normalized_image(actual_path, case.get("actual_crop", [0, 0, 1, 1]), target_size)
    mask = valid_mask(target_size, case.get("masks", []))
    valid_pixels = mask.histogram()[255]
    if valid_pixels == 0:
        raise ValueError(f"Case {case_id} masks every pixel.")

    difference = ImageChops.difference(reference, actual)
    difference_max = max_channel(difference)
    tolerance = int(case.get("pixel_tolerance", defaults.get("pixel_tolerance", 0)))
    changed = difference_max.point(lambda value: 255 if value > tolerance else 0)
    changed = ImageChops.multiply(changed, mask)
    changed_pixels = changed.histogram()[255]
    stats = ImageStat.Stat(difference, mask=mask)
    extrema = difference.getextrema()

    mean_abs_error = average([float(value) for value in stats.mean])
    rmse = average([float(value) for value in stats.rms])
    maximum_error = max(channel[1] for channel in extrema)
    changed_ratio = changed_pixels / valid_pixels

    case_output = output / case_id
    case_output.mkdir(parents=True, exist_ok=True)
    reference_file = case_output / "reference-normalized.png"
    actual_file = case_output / "actual-normalized.png"
    heatmap_file = case_output / "heatmap.png"
    comparison_file = case_output / "comparison.png"
    reference.save(reference_file)
    actual.save(actual_file)

    gain = float(case.get("heatmap_gain", defaults.get("heatmap_gain", 4.0)))
    amplified = ImageEnhance.Brightness(difference_max).enhance(max(0.1, gain))
    heatmap = ImageOps.colorize(amplified, black=(0, 0, 0), white=(255, 32, 0))
    ignored_overlay = Image.new("RGB", target_size, (64, 64, 64))
    heatmap = Image.composite(heatmap, ignored_overlay, mask)
    heatmap.save(heatmap_file)

    comparison = Image.new("RGB", (target_size[0] * 3, target_size[1]), (0, 0, 0))
    comparison.paste(reference, (0, 0))
    comparison.paste(actual, (target_size[0], 0))
    comparison.paste(heatmap, (target_size[0] * 2, 0))
    comparison.save(comparison_file)

    thresholds = case.get("thresholds", {})
    checks = {
        "mean_abs_error": (mean_abs_error, thresholds.get("max_mean_abs_error")),
        "rmse": (rmse, thresholds.get("max_rmse")),
        "changed_ratio": (changed_ratio, thresholds.get("max_changed_ratio")),
    }
    failures = [
        f"{name}={value:.6f} > {float(limit):.6f}"
        for name, (value, limit) in checks.items()
        if limit is not None and value > float(limit)
    ]
    gated = bool(case.get("gate", False)) and not report_only
    status = "failed" if gated and failures else ("passed" if gated else "reported")
    return {
        "id": case_id,
        "description": str(case.get("description", "")),
        "status": status,
        "gate": bool(case.get("gate", False)),
        "gate_enforced": gated,
        "reference": str(reference_path),
        "actual": str(actual_path),
        "reference_sha256": sha256(reference_path),
        "actual_sha256": sha256(actual_path),
        "normalized_size": list(target_size),
        "pixel_tolerance": tolerance,
        "masked_pixels": target_size[0] * target_size[1] - valid_pixels,
        "valid_pixels": valid_pixels,
        "changed_pixels": changed_pixels,
        "metrics": {
            "mean_abs_error": round(mean_abs_error, 6),
            "rmse": round(rmse, 6),
            "maximum_error": maximum_error,
            "changed_ratio": round(changed_ratio, 6),
        },
        "thresholds": thresholds,
        "threshold_failures": failures,
        "artifacts": {
            "reference_normalized": str(reference_file),
            "actual_normalized": str(actual_file),
            "heatmap": str(heatmap_file),
            "comparison": str(comparison_file),
        },
    }


def markdown_report(results: list[dict[str, Any]], manifest: Path, report_only: bool) -> str:
    failed = [result for result in results if result["status"] == "failed"]
    lines = [
        "# Bazal’s Pocket Garden visual validation",
        "",
        f"- Manifest: `{manifest}`",
        f"- Report-only override: `{str(report_only).lower()}`",
        f"- Result: `{'FAILED' if failed else 'PASSED'}`",
        "",
        "| Case | Mode | Status | Mean abs. error | RMSE | Changed ratio |",
        "| --- | --- | --- | ---: | ---: | ---: |",
    ]
    for result in results:
        metrics = result["metrics"]
        mode = "gate" if result["gate_enforced"] else "report"
        lines.append(
            f"| {result['id']} | {mode} | {result['status']} | "
            f"{metrics['mean_abs_error']:.3f} | {metrics['rmse']:.3f} | {metrics['changed_ratio']:.3%} |"
        )
    for result in results:
        lines.extend(
            [
                "",
                f"## {result['id']}",
                "",
                result["description"],
                "",
                f"- Comparison: `{result['artifacts']['comparison']}`",
                f"- Heatmap: `{result['artifacts']['heatmap']}`",
                f"- Reference SHA-256: `{result['reference_sha256']}`",
                f"- Actual SHA-256: `{result['actual_sha256']}`",
            ]
        )
        if result["threshold_failures"]:
            lines.append("- Threshold findings: " + "; ".join(result["threshold_failures"]))
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    project_root = args.project_root.resolve()
    artifacts = args.artifacts.resolve()
    manifest_path = args.manifest.resolve()
    output = args.output.resolve()
    if not (project_root / "project.godot").is_file():
        raise SystemExit(f"Not a Godot project root: {project_root}")
    if not manifest_path.is_file():
        raise SystemExit(f"Missing manifest: {manifest_path}")

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Could not load manifest: {exc}") from exc
    if manifest.get("version") != 1 or not isinstance(manifest.get("cases"), list):
        raise SystemExit("Unsupported or invalid visual manifest.")
    output.mkdir(parents=True, exist_ok=True)

    results: list[dict[str, Any]] = []
    try:
        for case in manifest["cases"]:
            result = compare_case(
                case,
                manifest.get("defaults", {}),
                project_root,
                artifacts,
                output,
                args.report_only,
            )
            results.append(result)
            metrics = result["metrics"]
            print(
                f"VISUAL_CASE={result['id']} status={result['status']} "
                f"mean_abs_error={metrics['mean_abs_error']:.3f} "
                f"rmse={metrics['rmse']:.3f} changed_ratio={metrics['changed_ratio']:.3%}"
            )
    except (FileNotFoundError, ValueError, OSError) as exc:
        print(f"VISUAL_VALIDATION_ERROR={exc}", file=sys.stderr)
        return 2

    json_report = output / "report.json"
    markdown_file = output / "report.md"
    payload = {
        "schema": 1,
        "manifest": str(manifest_path),
        "project_root": str(project_root),
        "artifacts": str(artifacts),
        "report_only": args.report_only,
        "results": results,
    }
    json_report.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    markdown_file.write_text(markdown_report(results, manifest_path, args.report_only), encoding="utf-8")
    print(f"VISUAL_REPORT={markdown_file}")

    failed = [result for result in results if result["status"] == "failed"]
    if failed:
        print("HOW_TO_GROW_VISUALS=FAILED")
        return 1
    print("HOW_TO_GROW_VISUALS=PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
