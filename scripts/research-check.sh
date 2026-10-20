#!/usr/bin/env bash
# research-check.sh, the mechanical check a research report runs before review
# (skills/research/SKILL.md step 5b). It catches, by rule, the defects the RES-002 review
# rounds found by hand (docs/evals/RES-002.md): a finding without exactly one confidence
# word, a Verified finding on fewer than two notes or on two notes from one source, a
# one-source finding missing from Unverified, a reference to a finding or note that does
# not exist, a key term of a Verified finding that is not inside a quote of each of its
# notes, and (with --sources) a quote that is not verbatim in the saved source text.
#
# What it CANNOT see, so the reviewer still reads for it: whether two notes quote the
# same FACT rather than sharing a word (the key terms are the author's choice), whether
# two differently named sources are really independent, and whether a finding joins two
# facts. "Same source" is a heuristic: a note's source is the text before its first comma.
#
# Report format it reads (skills/research/SKILL.md step 5):
#   - **F1** One fact. **Verified** (notes 1, 2)
#     <!-- terms: key term; alt one|alt two -->
#   - **F2** One fact. **One source** (note 1)
#   - **C1** ... **conflict** ...
#   ### Notes
#   1. <Source>, <page or file>: "verbatim quote" ...
#
# Usage:
#   research-check.sh <report.md> [--sources <dir>]
#
# Exit: 0 clean (quotes "not checked" without --sources is still clean). 1 violations
# found, each printed as "research-check: <what>". 2 the check did NOT run: a malformed
# invocation, an unreadable or unparseable report, a missing sources dir, or no python3.
set -uo pipefail

usage() {
  echo "usage: research-check.sh <report.md> [--sources <dir>]" >&2
  echo "       checks labels, notes, references, key terms and (with --sources) quotes." >&2
}
die2() { echo "research-check: $1 (the check did not run)" >&2; exit 2; }

[ "$#" -ge 1 ] || { usage; exit 2; }
report="$1"; shift
sources=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sources) [ "$#" -ge 2 ] || { usage; exit 2; }; sources="$2"; shift 2 ;;
    *) usage; exit 2 ;;
  esac
done
[ -f "$report" ] && [ -r "$report" ] || die2 "cannot read report '$report'"
[ -z "$sources" ] || [ -d "$sources" ] || die2 "sources dir '$sources' does not exist"
command -v python3 >/dev/null 2>&1 || die2 "python3 is required"

python3 -I - "$report" "$sources" <<'PY'
import os, re, sys

report, sources = sys.argv[1], sys.argv[2]
text = open(report, encoding="utf-8", errors="replace").read()
LABELS = ("Verified", "One source", "Unverified", "conflict")
violations = []

def norm(s):
    return re.sub(r"\s+", " ", s).strip()

def section(name):
    m = re.search(r"(?ms)^## " + re.escape(name) + r"\b.*?(?=^## |\Z)", text)
    return m.group(0) if m else ""

findings_sec = section("Findings")
if "### Notes" not in findings_sec:
    print("research-check: no '## Findings' with a '### Notes' list (the check did not run)",
          file=sys.stderr)
    sys.exit(2)
claims_part, notes_part = findings_sec.split("### Notes", 1)
notes_part = re.split(r"(?m)^### ", notes_part, maxsplit=1)[0]

notes = {int(m.group(1)): m.group(2) for m in
         re.finditer(r"(?ms)^(\d+)\. (.*?)(?=^\d+\. |\Z)", notes_part)}

def source_of(n):
    return notes[n].split(",", 1)[0].strip()

def quotes_of(n):
    return [a or b for a, b in re.findall(r'"([^"]+)"|`([^`]+)`', notes[n])]

findings = {}
for m in re.finditer(r"(?ms)^- \*\*([FC]\d+[a-z]?)\*\* (.*?)(?=^- \*\*|^### |\Z)", claims_part):
    fid, body = m.group(1), m.group(2)
    if fid in findings:
        violations.append(f"{fid}: duplicate finding id")
        continue
    findings[fid] = body

unverified_sec = section("Unverified")
for fid, body in findings.items():
    flat = norm(body)
    words = [w for w in re.findall(r"\*\*([^*]+)\*\*", flat) if w in LABELS]
    if len(words) != 1:
        violations.append(f"{fid}: {len(words)} confidence words {words}")
    cited = [int(x) for grp in re.findall(r"\(notes? ([\d, ]+)\)", flat)
             for x in re.findall(r"\d+", grp)]
    for n in cited:
        if n not in notes:
            violations.append(f"{fid}: cites missing note {n}")
    cited = [n for n in dict.fromkeys(cited) if n in notes]
    if words == ["One source"] and not re.search(r"\b" + re.escape(fid) + r"\b", unverified_sec):
        violations.append(f"{fid}: one source but not listed under Unverified")
    if words != ["Verified"]:
        continue
    if len(cited) < 2:
        violations.append(f"{fid}: Verified needs two notes, cites {cited}")
        continue
    srcs = {source_of(n) for n in cited}
    if len(srcs) < 2:
        violations.append(f"{fid}: Verified on notes from one source ({srcs.pop()})")
    tm = re.search(r"<!--\s*terms:\s*(.*?)\s*-->", body, re.S)
    if not tm:
        violations.append(f"{fid}: Verified but no key terms (<!-- terms: ... -->)")
        continue
    terms = [[a.strip() for a in t.split("|") if a.strip()] for t in tm.group(1).split(";")]
    for n in cited:
        q = norm(" ".join(quotes_of(n))).lower()
        for alts in terms:
            if alts and not any(a.lower() in q for a in alts):
                violations.append(f"{fid}: key term '{'|'.join(alts)}' not inside a quote of note {n}")

ref_sections = ["Answer", "Implications for us", "Numbers", "Unverified"]
for name in ref_sections:
    for ref in sorted(set(re.findall(r"\b([FC]\d+[a-z]?)\b", section(name)))):
        if ref not in findings:
            violations.append(f"{name}: unknown finding {ref}")
for ref in sorted(set(re.findall(r"\b([FC]\d+[a-z]?)\b", claims_part))):
    if ref not in findings:
        violations.append(f"Findings: unknown finding {ref}")

if sources:
    corpus = []
    for root, _dirs, files in os.walk(sources):
        for f in files:
            try:
                corpus.append(open(os.path.join(root, f), encoding="utf-8", errors="replace").read())
            except OSError as e:
                print(f"research-check: cannot read source {f}: {e}", file=sys.stderr)
    corpus = norm("\n".join(corpus))
    total = found = 0
    for n in sorted(notes):
        for q in re.findall(r'"([^"]{12,})"', notes[n]):
            total += 1
            if norm(q) in corpus:
                found += 1
            else:
                violations.append(f'note {n}: quote not found verbatim: "{norm(q)[:70]}"')
    quote_line = f"quotes: {found}/{total} verbatim"
else:
    quote_line = "quotes: not checked (no --sources dir)"

for v in violations:
    print(f"research-check: {v}")
print(f"research-check: {len(findings)} findings, {len(notes)} notes; {quote_line}")
sys.exit(1 if violations else 0)
PY
