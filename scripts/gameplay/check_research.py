"""Validate deliverable structure and isolation, not commercial game semantics."""
import csv
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "research" / "match-and-powers"
required = [
    "00-evidence-index.md", "01-round-state-machine.md",
    "02-match-lifecycle-and-score.md", "03-modes-and-variants.md",
    "04-complete-power-catalog.csv", "04-complete-power-catalog.md",
    "05-power-interactions.md", "06-pickups-and-modifiers.md",
    "07-video-and-rea-findings.md", "08-open-questions.md",
    "09-trailwars-options.md", "10-implementation-blueprint.md",
    "11-review-gallery.html",
]
for name in required:
    assert (REPORT / name).stat().st_size > 100, f"Missing/truncated report: {name}"
with (REPORT / required[4]).open(encoding="utf-8-sig", newline="") as source:
    rows = list(csv.DictReader(source))
concrete = [r for r in rows if r["entry_kind"] == "concrete_factory_supported"]
assert len(rows) == 33 and len(concrete) == 31
assert {int(r["id"]) for r in concrete} == set(range(1, 32))
assert Counter(r["category"] for r in concrete) == {"Shots": 9, "Bombs": 4, "Powers": 10, "Fevers": 8}
assert len({r["identifier"] for r in concrete}) == 31
for row in rows:
    for field in ("client_provenance", "evidence_class", "open_questions", "runtime_timestamp"):
        assert row[field], f"Missing evidence boundary: {row['identifier']} / {field}"
for path in (ROOT / "src").rglob("*.luau"):
    if path.name not in {"MatchSeries.luau", "PlaytestMatchService.luau"}:
        assert "MatchSeries" not in path.read_text(encoding="utf-8-sig"), f"Series unexpectedly wired: {path}"
for path in (ROOT / "dev").rglob("*.luau"):
    assert "MatchSeries" not in path.read_text(encoding="utf-8-sig"), f"Series unexpectedly wired: {path}"
for name in required:
    if name.endswith(".md"):
        text = (REPORT / name).read_text(encoding="utf-8-sig")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if not re.match(r"[a-z]+:|#", target):
                assert (REPORT / target.split("#")[0]).exists(), f"Broken report link {target}"
print("RESEARCH STRUCTURE: 31 concrete powers + selector/orphan separated; reports complete; series remains opt-in")
