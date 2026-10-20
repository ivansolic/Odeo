#!/usr/bin/env bash
# research-check.sh, the mechanical check a research report runs before review
# (skills/research/SKILL.md step 5b). It catches, by rule, the defects the RES-002 review
# rounds found by hand (docs/evals/RES-002.md): a finding without exactly one confidence
# word, a Verified finding on fewer than two notes or on two notes from one source, a
# not-verified or contested finding missing from Unverified, a reference to a finding or
# note that does not exist, a quote term of a Verified finding that is not inside one quote
# of each of its notes, and (with --sources) a quote that is not verbatim in the saved
# source text.
#
# What it CANNOT see, so the reviewer still reads for it: whether two notes quote the
# same FACT rather than sharing a word (the quote terms are the author's choice), whether
# two differently named sources are really independent, and whether a finding joins two
# facts. "Same source" is a heuristic: a note's source is the text before its first comma,
# compared without case and extra spaces. It is stricter than the rubric's Note definition
# in one way, on purpose: it wants one source per note, as the skill's step 4b asks.
#
# Report format it reads (skills/research/SKILL.md step 4b):
#   - **F1** One fact. **Verified** (notes 1, 2)
#     <!-- terms: quote term; alt one|alt two -->
#   - **F2** One fact. **One source** (note 1)
#   - **C1** ... **conflict** ...
#   ### Notes
#   1. <Source>, <locator>: "verbatim quote" ...
# Only text after the locator's ": " counts as quotes, so a file name in the locator never
# satisfies a quote term.
#
# Usage:
#   research-check.sh <report.md> [--sources <dir>]
#
# Exit: 0 clean ("quotes: not checked" without --sources is still clean). 1 violations
# found, each printed as "research-check: <what>". 2 the check did NOT run: a malformed
# invocation, an unreadable or unparseable report, a bad sources dir, no python3, or an
# internal error. Never read exit 1 as "the check ran" unless violations are printed.
set -uo pipefail

usage() {
  echo "usage: research-check.sh <report.md> [--sources <dir>]" >&2
  echo "       checks labels, notes, references, quote terms and (with --sources) quotes." >&2
}
die2() { echo "research-check: $1 (the check did not run)" >&2; exit 2; }

[ "$#" -ge 1 ] || { usage; exit 2; }
report="$1"; shift
sources=""; sources_given=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sources)
      [ "$#" -ge 2 ] || { usage; exit 2; }
      [ -n "$2" ] || die2 "--sources needs a directory"
      sources="$2"; sources_given=1; shift 2 ;;
    *) usage; exit 2 ;;
  esac
done
[ -f "$report" ] && [ -r "$report" ] || die2 "cannot read report '$report'"
[ "$sources_given" -eq 0 ] || [ -d "$sources" ] || die2 "sources dir '$sources' does not exist"
command -v python3 >/dev/null 2>&1 || die2 "python3 is required"

python3 -I - "$report" "$sources" <<'PY'
import os, re, stat, sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")


def did_not_run(why):
    print(f"research-check: {why} (the check did not run)", file=sys.stderr)
    sys.exit(2)


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def main(report, sources):
    text = open(report, encoding="utf-8", errors="replace").read()
    labels = ("Verified", "One source", "Unverified", "conflict")
    must_list = {"One source": "one source", "Unverified": "unverified", "conflict": "conflict"}
    violations = []

    def section(name):
        m = re.search(r"(?ms)^## " + re.escape(name) + r"\b.*?(?=^## |\Z)", text)
        return m.group(0) if m else ""

    findings_sec = section("Findings")
    if "### Notes" not in findings_sec:
        did_not_run("no '## Findings' with a '### Notes' list")
    claims_part, notes_part = findings_sec.split("### Notes", 1)
    notes_part = re.split(r"(?m)^### ", notes_part, maxsplit=1)[0]

    notes = {}
    for m in re.finditer(r"(?ms)^(\d+)\. (.*?)(?=^\d+\. |\Z)", notes_part):
        n = int(m.group(1))
        if n in notes:
            violations.append(f"note {n}: duplicate note number")
            continue
        notes[n] = m.group(2)

    def header(n):
        """(source, quote region) when the note has '<source>, <locator>: ', else None."""
        flat = norm(notes[n])
        first_quote = flat.find('"') if '"' in flat else len(flat)  # a `name` may sit in the source
        comma = flat.find(", ")
        if comma < 0 or comma > first_quote:
            return None
        colon = flat.find(": ", comma)
        if colon < 0:
            return None
        return norm(flat[:comma]), flat[colon + 2:]

    def quotes_in(region):
        return [a or b for a, b in re.findall(r'"([^"]+)"|`([^`]+)`', region)]

    for n, body in notes.items():
        if body.count('"') % 2:
            violations.append(f"note {n}: odd number of '\"', so its quotes cannot be paired")

    findings = {}
    for m in re.finditer(r"(?ms)^- \*\*([FC]\d+[a-z]?)\*\* (.*?)(?=^- \*\*|^### |^\||\Z)", claims_part):
        fid, body = m.group(1), m.group(2)
        if fid in findings:
            violations.append(f"{fid}: duplicate finding id")
            continue
        findings[fid] = body
    if not findings:
        did_not_run("no findings parsed (expected '- **F1** ...' lines under '## Findings')")

    term_quotes = set()  # (note, quote) pairs a quote term relied on; checked with --sources
    unverified_sec = section("Unverified")
    for fid, body in findings.items():
        flat = norm(body)
        words = [w for w in re.findall(r"\*\*([^*]+)\*\*", flat) if w in labels]
        if len(words) != 1:
            violations.append(f"{fid}: {len(words)} confidence words {words}")
        cited = [int(x) for grp in re.findall(r"\(notes? ([\d, ]+)\)", flat)
                 for x in re.findall(r"\d+", grp)]
        for n in cited:
            if n not in notes:
                violations.append(f"{fid}: cites missing note {n}")
        cited = [n for n in dict.fromkeys(cited) if n in notes]
        if len(words) == 1 and words[0] in must_list and \
                not re.search(r"\b" + re.escape(fid) + r"\b", unverified_sec):
            violations.append(f"{fid}: {must_list[words[0]]} but not listed under Unverified")
        if words != ["Verified"]:
            continue
        if len(cited) < 2:
            violations.append(f"{fid}: Verified needs two notes, cites {cited}")
            continue
        heads = {}
        for n in cited:
            h = header(n)
            if h is None:
                violations.append(f"note {n}: no '<source>, <locator>: ' header before its first quote")
            else:
                heads[n] = h
        if len(heads) == len(cited) and len({h[0].casefold() for h in heads.values()}) < 2:
            violations.append(f"{fid}: Verified on notes from one source ({next(iter(heads.values()))[0]})")
        tm = re.search(r"<!--\s*terms:\s*(.*?)\s*-->", body, re.S)
        if not tm:
            violations.append(f"{fid}: Verified but no quote terms (<!-- terms: ... -->)")
            continue
        terms = [[a.strip() for a in t.split("|") if a.strip()] for t in tm.group(1).split(";")]
        for n, (_src, region) in heads.items():
            quotes = [norm(q) for q in quotes_in(region)]
            for alts in [a for a in terms if a]:
                hit = [q for q in quotes if any(a.lower() in q.lower() for a in alts)]
                if not hit:
                    violations.append(f"{fid}: key term '{'|'.join(alts)}' not inside a quote of note {n}")
                term_quotes.update((n, q) for q in hit)

    cite_sections = ["Answer", "Implications for us", "Numbers"]
    for name in cite_sections:
        refs = set()
        for paren in re.findall(r"\(([^()]*)\)", section(name)):
            refs.update(re.findall(r"\b([FC]\d+[a-z]?)\b", paren))
        for ref in sorted(refs - set(findings)):
            violations.append(f"{name}: unknown finding {ref}")
    for name, part in (("Unverified", unverified_sec), ("Findings", claims_part)):
        for ref in sorted(set(re.findall(r"\b([FC]\d+[a-z]?)\b", part)) - set(findings)):
            violations.append(f"{name}: unknown finding {ref}")

    if sources:
        quote_line = check_sources(report, sources, notes, header, quotes_in, term_quotes, violations)
    else:
        quote_line = "quotes: not checked (no --sources dir)"

    for v in violations:
        print(f"research-check: {v}")
    print(f"research-check: {len(findings)} findings, {len(notes)} notes; {quote_line}")
    sys.exit(1 if violations else 0)


def check_sources(report, sources, notes, header, quotes_in, term_quotes, violations):
    root = os.path.realpath(sources)
    if os.path.realpath(report).startswith(root + os.sep):
        did_not_run(f"sources dir '{sources}' contains the report itself")
    corpus = []

    def walk_error(err):
        print(f"research-check: cannot read {err.filename}: {err.strerror}", file=sys.stderr)

    for dirpath, _dirs, files in os.walk(sources, onerror=walk_error):
        for f in files:
            path = os.path.join(dirpath, f)
            if re.fullmatch(r"RES-\d+.*\.md", f):
                did_not_run(f"sources dir '{sources}' contains a research report ({f})")
            if not stat.S_ISREG(os.lstat(path).st_mode):
                continue
            try:
                corpus.append(open(path, encoding="utf-8", errors="replace").read())
            except OSError as e:
                print(f"research-check: cannot read source {path}: {e.strerror}", file=sys.stderr)
    corpus = norm("\n".join(corpus))

    checked, skipped = [], 0
    for n in sorted(notes):
        h = header(n)
        region = h[1] if h else norm(notes[n])
        double_quoted = {norm(x) for x in re.findall(r'"([^"]+)"', region)}
        for q in quotes_in(region):
            q = norm(q)
            if (q in double_quoted and len(q) >= 12) or (n, q) in term_quotes:
                checked.append((n, q))
            else:
                skipped += 1
    checked = list(dict.fromkeys(checked))
    if not checked:
        did_not_run("--sources given, but the notes hold no checkable quotes")
    found = 0
    for n, q in checked:
        if q in corpus:
            found += 1
        else:
            violations.append(f'note {n}: quote not found verbatim: "{q[:70]}"')
    return f"quotes: {found}/{len(checked)} verbatim ({skipped} short or code quotes not checked)"


try:
    main(sys.argv[1], sys.argv[2])
except SystemExit:
    raise
except Exception as e:  # an internal error must never read as "violations found"
    did_not_run(f"internal error: {type(e).__name__}: {e}")
PY
