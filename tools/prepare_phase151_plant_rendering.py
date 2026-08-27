#!/usr/bin/env python3
"""Prepare Phase 151 plant rendering without changing source PNG pixels.

The gameplay catalog remains authoritative.  This script discovers all stage
textures from data/plants, enables mipmap generation only in their Godot import
sidecars, and records byte hashes plus dimensions in a deterministic manifest.
"""

from __future__ import annotations

import hashlib
import json
import struct
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PLANT_DATA_ROOT = PROJECT_ROOT / "data" / "plants"
MANIFEST_PATH = (
    PROJECT_ROOT
    / "assets"
    / "ui"
    / "visual"
    / "phase151"
    / "rack"
    / "phase151_runtime_manifest.json"
)
EXPECTED_STATES = ("seed", "sprout", "young", "mature", "sick", "harvest_ready")
EMPTY_POT_PATH = "res://assets/plants/comic/empty_pot_v1.png"
LOCK_PATH = "res://assets/ui/visual/phase151/rack/rack_locked_cylinder_phase151_v1.png"
LOCK_SHA256 = "2bfef1216cb102d9e7c19e801dae52060edd3875e674a7eab45ca941c29b4fe3"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        header = handle.read(24)
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise RuntimeError(f"Not a PNG: {path}")
    return struct.unpack(">II", header[16:24])


def project_path(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise RuntimeError(f"Expected res:// path, got {resource_path!r}")
    return PROJECT_ROOT / resource_path.removeprefix("res://")


def enable_mipmaps(png_path: Path) -> None:
    import_path = Path(f"{png_path}.import")
    if not import_path.is_file():
        raise RuntimeError(f"Missing Godot import sidecar: {import_path}")
    source = import_path.read_text(encoding="utf-8")
    if "mipmaps/generate=false" in source:
        source = source.replace("mipmaps/generate=false", "mipmaps/generate=true", 1)
        import_path.write_text(source, encoding="utf-8", newline="\n")
    if "mipmaps/generate=true" not in import_path.read_text(encoding="utf-8"):
        raise RuntimeError(f"Mipmap setting was not enabled: {import_path}")


def main() -> int:
    source_rows: list[dict[str, object]] = []
    import_targets: set[str] = {EMPTY_POT_PATH, LOCK_PATH}
    species_count = 0

    for profile_path in sorted(PLANT_DATA_ROOT.glob("*.json")):
        profile = json.loads(profile_path.read_text(encoding="utf-8"))
        stage_textures = profile.get("stage_textures")
        if not isinstance(stage_textures, dict):
            # catalog.json is the ordered index, not a species profile.
            if profile_path.name == "catalog.json":
                continue
            raise RuntimeError(f"Missing stage_textures in {profile_path}")
        species_id = str(profile.get("id", profile_path.stem))
        missing = [state for state in EXPECTED_STATES if not stage_textures.get(state)]
        if missing:
            raise RuntimeError(f"Missing states for {species_id}: {missing}")
        species_count += 1
        for state in EXPECTED_STATES:
            resource_path = str(stage_textures[state])
            png_path = project_path(resource_path)
            if not png_path.is_file():
                raise RuntimeError(f"Missing catalog texture: {png_path}")
            before_hash = sha256(png_path)
            width, height = png_size(png_path)
            import_targets.add(resource_path)
            source_rows.append(
                {
                    "species_id": species_id,
                    "state": state,
                    "path": resource_path,
                    "width": width,
                    "height": height,
                    "source_sha256": before_hash,
                }
            )

    if species_count != 11 or len(source_rows) != 66:
        raise RuntimeError(
            f"Phase151 requires 11 species x 6 states, got {species_count} x "
            f"{len(source_rows) // max(species_count, 1)} ({len(source_rows)} rows)"
        )

    unique_stage_paths = {str(row["path"]) for row in source_rows}
    if len(unique_stage_paths) != 66:
        raise RuntimeError(f"Stage textures must be unique, got {len(unique_stage_paths)}")

    before = {resource_path: sha256(project_path(resource_path)) for resource_path in sorted(import_targets)}
    for resource_path in sorted(import_targets):
        enable_mipmaps(project_path(resource_path))
    after = {resource_path: sha256(project_path(resource_path)) for resource_path in sorted(import_targets)}
    if before != after:
        changed = [path for path in before if before[path] != after[path]]
        raise RuntimeError(f"Source PNG bytes changed unexpectedly: {changed}")
    if after[LOCK_PATH] != LOCK_SHA256:
        raise RuntimeError(f"Unexpected Phase151 lock hash: {after[LOCK_PATH]}")

    manifest = {
        "schema": "phase151_dynamic_rack_detail_assets_v1",
        "runtime_set": "phase151_rack_dynamic_painted_v1",
        "approved_references": {
            "rack": {
                "path": "res://docs/visual-proposals/phase151/user-approved-painted-rack-screen-v1.png",
                "sha256": "7540369ad83e2dcb0a707052c649e8c0e919d621086b970985ea891eff02697c",
            },
            "detail": {
                "path": "res://docs/visual-proposals/phase151/user-approved-painted-detail-screen-v1.png",
                "sha256": "599283f38afd50cfc6d121613f9687e15707cdf56ed1de6fe743765727bcafde",
            },
        },
        "source_policy": "source_png_bytes_immutable_import_sidecars_mipmaps_only_v1",
        "species_count": species_count,
        "states_per_species": len(EXPECTED_STATES),
        "stage_texture_count": len(source_rows),
        "mipmapped_import_count": len(import_targets),
        "locked_slot_asset": {
            "path": LOCK_PATH,
            "sha256": after[LOCK_PATH],
            "width": png_size(project_path(LOCK_PATH))[0],
            "height": png_size(project_path(LOCK_PATH))[1],
        },
        "stage_textures": source_rows,
    }
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"PHASE151_SPECIES={species_count}")
    print(f"PHASE151_STAGE_TEXTURES={len(source_rows)}")
    print(f"PHASE151_MIPMAPPED_IMPORTS={len(import_targets)}")
    print("PHASE151_SOURCE_PNGS_UNCHANGED=PASS")
    print(f"PHASE151_MANIFEST={MANIFEST_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
