#!/usr/bin/env python3
"""Validate a BRD revision register against the current canonical HTML IDs."""
from __future__ import annotations

import argparse
import csv
from html.parser import HTMLParser
from pathlib import Path


FIELDS = {
    "revision_id", "previous_version", "current_version", "requested_change",
    "change_class", "target_ids", "source_or_authority", "evidence_ids",
    "affected_projection_ids", "disposition", "rationale", "validation_status",
}
CHANGE_CLASSES = {
    "wording_only", "evidence_correction", "business_semantics",
    "scope_priority", "contract_structure",
}
DISPOSITIONS = {"applied", "deferred", "rejected"}
SEMANTIC_CLASSES = {"evidence_correction", "business_semantics", "scope_priority"}


class IdParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.ids: set[str] = set()
        self.projection_ids: set[str] = set()

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = dict(attrs)
        item_id = (data.get("id") or "").strip()
        if item_id:
            self.ids.add(item_id)
            if data.get("data-contract-type") == "derived-review":
                self.projection_ids.add(item_id)


def split_ids(value: str) -> list[str]:
    return [item for item in value.split() if item]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("register", type=Path)
    parser.add_argument("--brd", type=Path, required=True)
    args = parser.parse_args()

    parsed = IdParser()
    parsed.feed(args.brd.resolve().read_text(encoding="utf-8"))
    errors: list[str] = []
    seen_revisions: set[str] = set()

    with args.register.resolve().open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if not reader.fieldnames or not FIELDS.issubset(reader.fieldnames):
            missing = sorted(FIELDS - set(reader.fieldnames or []))
            errors.append("revision register missing columns: " + ", ".join(missing))
            rows: list[dict[str, str]] = []
        else:
            rows = list(reader)

    if not rows and not errors:
        errors.append("revision register has no revision rows")

    for number, row in enumerate(rows, start=2):
        revision_id = row["revision_id"].strip()
        change_class = row["change_class"].strip()
        disposition = row["disposition"].strip()
        targets = split_ids(row["target_ids"])
        projections = split_ids(row["affected_projection_ids"])

        if not revision_id:
            errors.append(f"row {number}: missing revision_id")
        elif revision_id in seen_revisions:
            errors.append(f"row {number}: duplicate revision_id {revision_id}")
        seen_revisions.add(revision_id)
        if not row["previous_version"].strip() or not row["current_version"].strip():
            errors.append(f"row {number}: missing previous_version or current_version")
        if not row["requested_change"].strip():
            errors.append(f"row {number}: missing requested_change")
        if change_class not in CHANGE_CLASSES:
            errors.append(f"row {number}: unsupported change_class {change_class!r}")
        if disposition not in DISPOSITIONS:
            errors.append(f"row {number}: unsupported disposition {disposition!r}")
        if disposition == "applied" and not targets:
            errors.append(f"row {number}: applied revision has no target_ids")
        for target in targets:
            if target not in parsed.ids:
                errors.append(f"row {number}: target_id not found in BRD: {target}")
        for projection in projections:
            if projection not in parsed.projection_ids:
                errors.append(f"row {number}: affected projection is missing or not derived-review: {projection}")
        if change_class in SEMANTIC_CLASSES and disposition == "applied":
            if not row["source_or_authority"].strip() and not row["evidence_ids"].strip():
                errors.append(f"row {number}: applied semantic revision lacks evidence or participant authority")
        if disposition == "applied" and row["validation_status"].strip() != "passed":
            errors.append(f"row {number}: applied revision validation_status must be passed")
        if disposition in {"deferred", "rejected"} and not row["rationale"].strip():
            errors.append(f"row {number}: {disposition} revision requires rationale")

    if errors:
        print("INVALID")
        for error in errors:
            print("- " + error)
        return 1
    print(f"VALID: {args.register.resolve()} ({len(rows)} atomic revisions)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
