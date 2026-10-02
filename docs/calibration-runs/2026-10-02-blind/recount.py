"""Recount every number the calibration note states for this run, naming the runs behind each.

Run from the repo root:  python3 docs/calibration-runs/2026-10-02-blind/recount.py
Reads the archived outputs next to this file and the seed in tests/fixtures/calibration/.
Criteria are the ones in GRADING.md here; sentence-level matching is a heuristic, so the
named runs are printed for a human to open and confirm.
"""
import re
from pathlib import Path

HERE = Path(__file__).parent
SEED_B = Path("tests/fixtures/calibration/plan-usr-014-b.md")
MENTION = re.compile(r"as strings|stop and ask|stop rule", re.I)
ASK = re.compile(r"\b(add|name|list|missing from|should appear|belongs in)\b", re.I)
OUTSIDE = re.compile(r"correctly|stays out|kept out|not a finding|rightly", re.I)
DECIDE = re.compile(r"what you decide|summary", re.I)
PURE = re.compile(r"pure function|no i/o|without starting a server", re.I)
STRENGTH = re.compile(r"strength|what is right|what checks out", re.I)


def sentences(text: str) -> list[str]:
    return [s for s in re.split(r"(?<=[.!?])\s+|\n\s*\n", text) if s.strip()]


def runs(prefix: str) -> list[Path]:
    return sorted(HERE.glob(f"{prefix}*-review.md"))


def scenario_a() -> None:
    hits = []
    for f in runs("r-a"):
        heads = [h for h in f.read_text().splitlines() if h.startswith("### ")]
        ranked = [h for h in heads if re.search(r"due_date|header", h, re.I) and re.match(r"### [BI]", h)]
        if ranked and re.search(r"what you decide", f.read_text(), re.I):
            hits.append(f.name.split("-review")[0])
    print(f"S3 header deviation at blocking/important with What you decide: {len(hits)}/5: {', '.join(hits)}")


def scenario_b() -> None:
    asked = []
    for f in runs("r-b"):
        for s in sentences(f.read_text()):
            if PURE.search(s) and DECIDE.search(s) and ASK.search(s):
                asked.append(f.name.split("-review")[0])
                break
    print(f"S4 pure-function decision asked into the human layer: {len(asked)}/5: {', '.join(asked) or 'none'}")


def stop_rule() -> None:
    requested, correct = [], []
    for f in runs("r-"):
        sents = sentences(f.read_text())
        name = f.name.split("-review")[0]
        if any(MENTION.search(s) and DECIDE.search(s) and ASK.search(s) and not OUTSIDE.search(s) for s in sents):
            requested.append(name)
        if any(re.search("stop rule", s, re.I) and OUTSIDE.search(s) for s in sents):
            correct.append(name)
    print(f"Stop rule asked for in Summary/What you decide: {len(requested)}/10: {', '.join(requested) or 'none'}")
    print(f"Stop rule said to be correctly outside: {len(correct)}/10: {', '.join(correct) or 'none'}")


def gate() -> None:
    plan = SEED_B.read_text()
    summary = plan.split("## Summary for humans", 1)[1].split("\n## ", 1)[0]
    bullets = [re.sub(r"\s+", " ", b).strip() for b in re.split(r"\n- ", "\n" + summary.strip()) if b.strip()]
    bullets = [b[2:].strip() if b.startswith("- ") else b for b in bullets]
    for f in sorted(HERE.glob("g*-gate.md")):
        out = re.sub(r"\s+", " ", f.read_text().replace("**", ""))
        pos = [out.find(b) for b in bullets]
        fm = out.lower().find("file map")
        verbatim = sum(p >= 0 for p in pos)
        before = fm >= 0 and all(p < fm for p in pos if p >= 0)
        print(f"B5.3 {f.name}: {verbatim}/5 verbatim, first 'file map' text after the Summary: {before}")


scenario_a()
scenario_b()
stop_rule()
gate()
