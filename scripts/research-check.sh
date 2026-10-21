#!/usr/bin/env bash
# research-check.sh, the mechanical check a research report runs before review
# (skills/research/SKILL.md step 5b). It catches, by rule, the defects the RES-002 review
# rounds found by hand: a finding without exactly one confidence
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
# Notes parse FAIL CLOSED: the header must be "<source>, <locator>: " with the comma and the
# colon both before the first double quote, and a typographic double quote (U+201C,
# U+201D, U+201E, U+00AB, U+00BB) outside a straight-quoted or backtick span is a
# violation, never silently skipped; inside one it is the source's own quote mark and goes
# to the verbatim check. Only text after the header counts as quotes, so a file name in the
# locator never satisfies a quote term.
# Finding ids are checked in Answer, Implications and Numbers only inside parentheses
# ("(F1, verified)"), so a word like "C3 model" is not a reference. Note citations parse
# FAIL CLOSED too: every parenthesis outside the Notes list is scanned (code spans removed
# first; a link address, the parenthesis right after "]" unless it starts with "note " or
# "notes ", is skipped, but a parenthesis nested inside it is read, so a separate word
# "note" in a URL's own parentheses is a false alarm, never a miss), and a "note" or
# "notes" in one must be followed by a number
# list, optionally then ", <qualifier>" or "; <qualifier>" ("(note 24, measured)"). A
# qualifier after a comma holds no digit, so no note number can hide in it ("(notes 1, 2,
# and 9)"); one with a digit follows ";". Any other "note" in a parenthesis ("(notes 1 and
# 2)", "(a note on pricing)") is a violation. A number after ";" is qualifier text, so every
# cited note goes in the list before it: "(notes 1; 9)" checks note 1 only. Headings, the
# title and the frontmatter are scanned too ("Title" names the text above the first "## ").
# The guard against a sources dir holding a copy of the report is a heuristic: it refuses
# only when a note of 40 or more characters appears unchanged in a source file, so a copy
# whose notes were all edited afterwards is not caught.
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

LABELS = ("Verified", "One source", "Unverified", "conflict")
MUST_LIST = {"One source": "one source", "Unverified": "unverified", "conflict": "conflict"}
TYPOGRAPHIC = "“”„«»"
NOTE_WORD = re.compile(r"\bnotes?\b", re.I)
NOTE_LIST = re.compile(r"notes?\s+(\d+(?:\s*,\s*\d+)*)\s*(?:,\s*\D[^\d]*)?", re.I | re.S)


def did_not_run(why):
    print(f"research-check: {why} (the check did not run)", file=sys.stderr)
    sys.exit(2)


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def section(text, name):
    m = re.search(r"(?ms)^## " + re.escape(name) + r"\b.*?(?=^## |\Z)", text)
    return m.group(0) if m else ""


def paren_texts(text):
    """The text of every parenthesis, nested ones included, after code spans are removed.
    A parenthesis right after "]" is a link address, unless it starts with the word note
    or notes and a space, which no address does: it is not read, and the text directly
    inside it is blanked, so a URL, a title or a <> address holding "notes" is not a
    citation, while a parenthesis nested inside it is still read. An unclosed parenthesis
    runs to the end of its paragraph, so it is read rather than skipped."""
    text = re.sub(r"`[^`]*`", "", text)
    chars, opened, spans = list(text), [], []
    for i, c in enumerate(text):
        if c == "(":
            link = i > 0 and text[i - 1] == "]" and \
                not re.match(r"[ \t]*notes?\s", text[i + 1:], re.I)
            opened.append((i, link))
        elif c == ")" and opened:
            start, link = opened.pop()
            spans.append((start, i, link))
        elif opened and opened[-1][1]:
            chars[i] = " "
    text = "".join(chars)
    out = [text[start + 1:end] for start, end, link in spans if not link]
    for start, link in opened:
        if not link:
            end = re.search(r"\n\s*\n|\Z", text[start:])
            out.append(text[start + 1:start + end.start()])
    return out


def cited_notes(text, where, violations):
    """Note numbers cited in parentheses of text; a "note" that is not a number list is a
    violation named after where. A nested parenthesis is read once on its own, so the
    outer one is scanned with its nested parts blanked out."""
    nums = []
    for paren in paren_texts(text):
        paren = re.sub(r"\([^()]*\)", "", paren)
        for m in NOTE_WORD.finditer(paren):
            segment = paren[m.start():].split(";", 1)[0]
            cite = NOTE_LIST.fullmatch(segment)
            if cite is None:
                violations.append(f"{where}: unreadable note citation '({norm(paren)[:60]})'; "
                                  "write (note N), (notes N, M), (note N, <qualifier without "
                                  "digits>) or (note N; <qualifier>), or reword a parenthesis "
                                  "that is not a citation")
                continue
            nums.extend(int(x) for x in re.findall(r"\d+", cite.group(1)))
    return nums


def quotes_in(region):
    return [norm(a or b) for a, b in re.findall(r'"([^"]+)"|`([^`]+)`', region)]


def parse_notes(notes_part, violations):
    notes = {}
    for m in re.finditer(r"(?ms)^(\d+)\. (.*?)(?=^\d+\. |\Z)", notes_part):
        n = int(m.group(1))
        if n in notes:
            violations.append(f"note {n}: duplicate note number")
            continue
        notes[n] = norm(m.group(2))
    for n, body in notes.items():
        outside = re.sub(r'"[^"]*"|`[^`]*`', "", body)
        if any(c in outside for c in TYPOGRAPHIC):
            violations.append(f"note {n}: typographic quote mark outside a quote; delimit "
                              "quotes with straight double quotes (the source's own marks "
                              "may stay inside them)")
        if body.count('"') % 2:
            violations.append(f"note {n}: odd number of '\"', so its quotes cannot be paired")
    return notes


def header(note):
    """(source, quote region) for '<source>, <locator>: ' before the first double quote."""
    first_quote = note.find('"') if '"' in note else len(note)
    comma = note.find(", ")
    colon = note.find(": ", comma + 2) if comma >= 0 else -1
    if comma < 0 or colon < 0 or colon > first_quote:
        return None
    return norm(note[:comma]), note[colon + 2:]


def parse_findings(claims_part, violations):
    findings = {}
    for m in re.finditer(r"(?ms)^- \*\*([FC]\d+[a-z]?)\*\* (.*?)(?=^- \*\*|^### |^\||\Z)", claims_part):
        fid, body = m.group(1), m.group(2)
        if fid in findings:
            violations.append(f"{fid}: duplicate finding id")
            continue
        findings[fid] = body
    return findings


def check_verified(fid, body, cited, notes, violations, term_quotes):
    if len(cited) < 2:
        violations.append(f"{fid}: Verified needs two notes, cites {cited}")
        return
    heads = {}
    for n in cited:
        h = header(notes[n])
        if h is None:
            violations.append(f"note {n}: no '<source>, <locator>: ' header before its first quote")
        else:
            heads[n] = h
    if len(heads) == len(cited) and len({h[0].casefold() for h in heads.values()}) < 2:
        violations.append(f"{fid}: Verified on notes from one source ({next(iter(heads.values()))[0]})")
    tm = re.search(r"<!--\s*terms:\s*(.*?)\s*-->", body, re.S)
    if not tm:
        violations.append(f"{fid}: Verified but no quote terms (<!-- terms: ... -->)")
        return
    terms = [[a.strip() for a in t.split("|") if a.strip()] for t in tm.group(1).split(";")]
    for n, (_src, region) in heads.items():
        quotes = quotes_in(region)
        for alts in [a for a in terms if a]:
            hit = [q for q in quotes if any(a.lower() in q.lower() for a in alts)]
            if not hit:
                violations.append(f"{fid}: quote term '{'|'.join(alts)}' not inside a quote of note {n}")
            term_quotes.update((n, q) for q in hit)


def check_finding(fid, body, notes, unverified_sec, violations, term_quotes):
    flat = norm(body)
    words = [w for w in re.findall(r"\*\*([^*]+)\*\*", flat) if w in LABELS]
    if len(words) != 1:
        violations.append(f"{fid}: {len(words)} confidence words {words}")
    cited = cited_notes(body, fid, violations)
    for n in cited:
        if n not in notes:
            violations.append(f"{fid}: cites missing note {n}")
    cited = [n for n in dict.fromkeys(cited) if n in notes]
    if len(words) == 1 and words[0] in MUST_LIST and \
            not re.search(r"\b" + re.escape(fid) + r"\b", unverified_sec):
        violations.append(f"{fid}: {MUST_LIST[words[0]]} but not listed under Unverified")
    if words == ["Verified"]:
        check_verified(fid, body, cited, notes, violations, term_quotes)


def check_citations(text, findings, notes, claims_part, notes_part, violations):
    for name in ("Answer", "Implications for us", "Numbers"):
        refs = set()
        for paren in re.findall(r"\(([^()]*)\)", section(text, name)):
            refs.update(re.findall(r"\b([FC]\d+[a-z]?)\b", paren))
        for ref in sorted(refs - set(findings)):
            violations.append(f"{name}: unknown finding {ref}")
    for name, part in (("Unverified", section(text, "Unverified")), ("Findings", claims_part)):
        for ref in sorted(set(re.findall(r"\b([FC]\d+[a-z]?)\b", part)) - set(findings)):
            violations.append(f"{name}: unknown finding {ref}")
    rest = text.replace(notes_part, "\n")
    for body in findings.values():
        rest = rest.replace(body, "\n", 1)
    first = re.search(r"(?m)^## ", rest)
    parts = [("Title", rest[:first.start()] if first else rest)]
    parts += [(m.group(1), m.group(0)) for m in
              re.finditer(r"(?ms)^## ([^\n(]*?)\s*(?:\(.*?)?$.*?(?=^## |\Z)", rest)]
    for name, part in parts:
        for n in sorted(set(cited_notes(part, name, violations)) - set(notes)):
            violations.append(f"{name}: cites missing note {n}")


def read_sources(report, sources, notes):
    root = os.path.realpath(sources)
    if os.path.commonpath([root, os.path.realpath(report)]) == root:
        did_not_run(f"sources dir '{sources}' contains the report itself")
    texts = []

    def walk_error(err):
        print(f"research-check: cannot read {err.filename}: {err.strerror}", file=sys.stderr)

    for dirpath, _dirs, files in os.walk(sources, onerror=walk_error):
        for f in files:
            path = os.path.join(dirpath, f)
            if re.fullmatch(r"res-\d+.*\.md", f, re.I):
                did_not_run(f"sources dir '{sources}' contains a research report ({f})")
            if not stat.S_ISREG(os.lstat(path).st_mode):
                continue
            try:
                texts.append((path, norm(open(path, encoding="utf-8", errors="replace").read())))
            except OSError as e:
                print(f"research-check: cannot read source {path}: {e.strerror}", file=sys.stderr)
    for path, body in texts:
        for n, note in notes.items():
            if len(note) >= 40 and note in body:
                did_not_run(f"source '{path}' holds the text of note {n}, a copy of the report")
    return " ".join(body for _p, body in texts)


def check_quotes(notes, term_quotes, corpus, violations):
    checked, skipped = [], 0
    for n in sorted(notes):
        h = header(notes[n])
        region = h[1] if h else notes[n]
        double_quoted = {norm(x) for x in re.findall(r'"([^"]+)"', region)}
        for q in quotes_in(region):
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


def main(report, sources):
    text = open(report, encoding="utf-8", errors="replace").read()
    violations = []
    findings_sec = section(text, "Findings")
    if "### Notes" not in findings_sec:
        did_not_run("no '## Findings' with a '### Notes' list")
    claims_part, notes_part = findings_sec.split("### Notes", 1)
    notes_part = re.split(r"(?m)^### ", notes_part, maxsplit=1)[0]
    notes = parse_notes(notes_part, violations)
    findings = parse_findings(claims_part, violations)
    if not findings:
        did_not_run("no findings parsed (expected '- **F1** ...' lines under '## Findings')")
    term_quotes = set()
    unverified_sec = section(text, "Unverified")
    for fid, body in findings.items():
        check_finding(fid, body, notes, unverified_sec, violations, term_quotes)
    check_citations(text, findings, notes, claims_part, notes_part, violations)
    if sources:
        quote_line = check_quotes(notes, term_quotes, read_sources(report, sources, notes), violations)
    else:
        quote_line = "quotes: not checked (no --sources dir)"
    for v in violations:
        print(f"research-check: {v}")
    print(f"research-check: {len(findings)} findings, {len(notes)} notes; {quote_line}")
    sys.exit(1 if violations else 0)


try:
    main(sys.argv[1], sys.argv[2])
except SystemExit:
    raise
except Exception as e:  # an internal error must never read as "violations found"
    did_not_run(f"internal error: {type(e).__name__}: {e}")
PY
