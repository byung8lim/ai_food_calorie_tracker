#!/usr/bin/env python3
"""Restore the authentic nutrition asset from the v0.6 release ZIP.

Usage: python3 tools/restore_nutrition.py /path/to/ai_food_calorie_tracker_v0_6_unverified.zip
Does not fabricate records, silently use sample data, or modify a source ZIP.
"""
import json
import pathlib
import sys
import zipfile

DEST = pathlib.Path("assets/nutrition/seed.json")
REQUIRED = {"name", "kcal", "source", "source_id", "unit"}

def main(archive_path: str) -> None:
    with zipfile.ZipFile(archive_path) as archive:
        names = [name for name in archive.namelist()
                 if name.replace("\\", "/").endswith("assets/nutrition/seed.json")
                 and not name.endswith("/")]
        if len(names) != 1:
            raise SystemExit(f"Expected exactly one nutrition seed.json in release ZIP, found {len(names)}")
        raw = archive.read(names[0])
    rows = json.loads(raw)
    if not isinstance(rows, list) or len(rows) <= 10000:
        raise SystemExit("Nutrition data rejected: expected >10,000 records")
    for index, row in enumerate(rows):
        if not isinstance(row, dict) or not REQUIRED.issubset(row):
            raise SystemExit(f"Nutrition row {index}: missing required metadata")
        if row["unit"] != "100g" or not row["source_id"] or not row["source"]:
            raise SystemExit(f"Nutrition row {index}: invalid source/unit")
        if not isinstance(row["kcal"], (int, float)) or isinstance(row["kcal"], bool) or row["kcal"] < 0:
            raise SystemExit(f"Nutrition row {index}: invalid calories")
    DEST.parent.mkdir(parents=True, exist_ok=True)
    DEST.write_bytes(raw)
    import hashlib
    print(f"Restored {len(rows)} records to {DEST} (sha256={hashlib.sha256(raw).hexdigest()})")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    main(sys.argv[1])
