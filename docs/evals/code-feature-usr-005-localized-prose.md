---
artifact: USR-005
type: code
branch: feature/usr-005-localized-prose
artifact_version: 3
date: 2026-08-12
reviewed_commit: fd8d6e5
scorer: code-reviewer
model: claude-opus-5[1m]
model_tier: strongest
effort: high
scores: { correctness: 2, security: 2, performance: 2, readability: 2, testing: 1, conventions: 2 }
total: 11/12
verdict: APPROVE WITH COMMENTS
previous_total: 11/12
---

# Code review, USR-005 generate prose in the chosen language (round 3, final loop round)

Scope: the delta `1b5e1da..fd8d6e5` only. One commit, one file,
`tests/localized-prose.test.sh`, +5/-2 (two assertion lines replaced, three comment lines
added). Everything else was cleared at `1b5e1da` (11/12) and at `a308b11`, and I did not
re-review it. Contract: `docs/plans/2026-08-12-usr-005-localized-prose.md`, entry C3 (the
German fixture project). Worktree clean at `fd8d6e5` apart from this record; I restored the
fixture from git after every mutation and re-confirmed `git status --porcelain` empty.

This is round 3, the last the loop allows. The human arbitrates from here.

## Provenance (unchanged from rounds 1 and 2)

No `builder` agent was dispatched. The `builder` definition pins `isolation: worktree` and
the orchestrating session's working directory is not a git repository, so the agent would
not start. The human chose that the orchestrator execute the plan instead. **The executor
was the orchestrating session, not an isolated builder**, so `build_model_as_dispatched:`
is omitted rather than filled with a guess.

Consequence, same as round 2: I accepted no reported observation on the strength of the
commit body. Every claim below was re-measured by me at `fd8d6e5`, including a nine
mutation battery against the committed fixture.

## Verdict
APPROVE WITH COMMENTS

The round-2 Important is genuinely closed, and closed by the criterion I set: both claimed
mutations go RED in my hands, not just in the author's. The mechanism does what the second
half of its comment says on this platform, on both grep binaries present here, and the
frontmatter half still catches a real localized `title:`. One residual remains, and it is
the same species one order narrower: the class matches non-ASCII BYTES while the message,
the comment and contract C3 all say LETTERS, so an all-ASCII prose body carrying one curly
apostrophe, one NBSP or one box-drawing character in a code fence still passes. I
demonstrated three such passes. Test precision only, nothing user facing ships wrong, and
the residual is a defect of the class I myself prescribed in round 2. 11/12, threshold
cleared, no dimension at 0. **This can go to the human gate.**

## Question 1: does the mechanism do what the comment claims, on this platform, in both halves?

**Yes for behavior, no for the comment's first three words.**

Environment note that matters for the answer: `grep` on this machine is **ugrep 7.5.0**, not
the system `grep`. I therefore ran every probe against BOTH `/usr/bin/grep` (BSD grep 2.6.0
FreeBSD) and the ugrep in PATH, and both agree on every case below. There are no CI
workflows in this repo, so the runtime is a developer shell.

Instrument warning first, because it nearly produced a false finding: the shell this review
tool hands me does NOT expand `$'...'` the way bash does. My first direct probe reported
`0` matching lines in a fixture whose body has 6, and reported empty counts for every raw
byte. Both were artifacts of my own probe, not the code (`lessons.md:16`, a negative result
is only meaningful from an instrument proven to give a positive). Every number below was
produced from a script file executed by real bash, after confirming the instrument gives a
positive on a planted umlaut.

Byte-level behavior of `$'[\200-\377]'` under `LC_ALL=C`, both greps, macOS bash 3.2.57:

| input byte(s) | shipped class | old `[^ -~]` |
|---|---|---|
| TAB 0x09 (the round-2 hole) | 0 | 1 |
| CR 0x0D, ESC 0x1B, DEL 0x7F | 0 | 1 |
| `ä` C3 A4, `ß` C3 9F | 1 | 1 |
| lone continuation 0x80, 0xBF | 1 | 1 |
| 0xFF, lone lead 0xC3, latin1 0xE4 | 1 | 1 |

So the pattern bytes are `5b 80 2d ff 5d`, the range is byte valued under `LC_ALL=C`, and
every ASCII control byte is now excluded. The claim in the comment's second and third
sentences (`[^ -~]` also matches control bytes, TAB is 0x09) is exactly right.

**The comment's first three words are wrong.** `[\200-\377]` is not "UTF-8 LEAD BYTES": it
is every byte at or above 0x80, which includes the continuation range 0x80 to 0xBF and the
never-valid bytes 0xC0, 0xC1 and 0xF5 to 0xFF. I confirmed a lone 0x80 matches. The error is
in the safe direction (the mechanism is wider than the comment, not narrower), but in a file
whose own discipline line is "Claim no wider than the mechanism" the comment now claims
NARROWER than the mechanism, and a maintainer who trusts it could later "tighten" to
`[\302-\364]` believing that is what is already there. Folded into the Important below,
since one fix settles it.

**The frontmatter half is correct and is not weakened for the case that matters.** Planted a
real leak (mutation M7, `title: Sitzungsablauf bei Inaktivität`) into the committed fixture:
the suite goes RED three ways at once, `FAIL: and the fixture frontmatter carries none
(expected '0', got '1')` plus both guard assertions of case 4. A localized `title:` with an
umlaut is still caught.

The one thing the `== 0` half stopped catching is an ASCII control byte in frontmatter, and
I checked whether that leaves a gap rather than assuming. It does not: `bin/language-guard.sh:49`
defines `is_ascii` as `grep -q '[^ -~]'`, printable ASCII only, which is the correct layer
for control bytes. Mutation M9 (a TAB inside `status:`) takes the suite RED through the guard
case, `FAIL: guard passes the German-body fixture PRD ... (expected exit 0, got 1)`. Net
coverage is unchanged and the division of labor is now cleaner than before: the guard owns
"printable ASCII", the fixture-shape assertion owns "carries non-ASCII".

## Question 2: can the fixed assertion still pass for a wrong reason?

**Yes, three demonstrated passes, and one attack that held.** All applied to the committed
fixture, whole-suite exit recorded, fixture restored from git each time.

| mutation | suite | shape line |
|---|---|---|
| M1 transliterated + one TAB-indented body line (round-2 hole) | **exit 1** | `FAIL: the fixture body is all ASCII, so the guard case above proves nothing` |
| M2 plain transliteration, no control bytes | **exit 1** | same FAIL |
| M3 transliterated + `don’t` (U+2019) in prose | exit 0 | `ok: ... carries non-ASCII letters (1 lines)` |
| M4 transliterated + box-drawing bytes inside a ```` ```text ```` fence | exit 0 | `ok: ... (1 lines)` |
| M5 transliterated + `café` inside a URL | exit 0 | `ok: ... (1 lines)` |
| M6 transliterated + one NBSP (U+00A0) | exit 0 | `ok: ... (1 lines)` |
| M7 umlaut in frontmatter `title:` (real leak) | **exit 1** | 3 FAILs, leak caught |
| M8 frontmatter leak after a bare `---` line | exit 0 | held, see below |
| M9 TAB inside a frontmatter value | **exit 1** | caught by the guard case |

M1 and M2 confirm the round-2 fix independently. M3, M4, M6 are the wrong-reason passes: the
body is ASCII prose, the German is gone, the tripwire stays green, and the `ok:` line asserts
"non-ASCII letters" about a curly quote. M5 is a letter but not prose, which is the same
defect wearing better clothes.

**M8 held, for the right reason, so it is not a finding.** Putting `notes: |` then a bare
`---` then `  Prüfprotokoll` into the frontmatter does shift `awk`'s partition, and the
umlaut is then counted as body (7 lines) while `fm_nonascii` reads 0. But a bare `---` on its
own line terminates YAML frontmatter in every parser that reads it, including
`bin/language-guard.sh` itself, so that text IS body by the format's own semantics. The test
and the guard share one delimiter model. Correct, not a hole.

I also attacked the partition in the other direction: a missing closing `---` leaves the body
`awk` (`n>=2`) empty, so `body_nonascii` is 0 and the suite fails loudly. Every way I could
break the partition or the class fails in the safe direction on the body half, and the body
half is on the SAME class as the frontmatter half, so it doubles as the in-suite positive
control the frontmatter's negative claim needs (`lessons.md:16`). That property is real and
worth protecting: nobody should ever delete the body half as redundant.

## Question 3: did the change break or weaken anything else in that file?

**No.** The diff replaces two expressions and adds a three line comment; no other line moved.
At `fd8d6e5` the suite is green, 26 assertions, exit 0, and the cases round 2 validated all
still behave: the AC3 positive control (`ok: control: the temp global IS read where no
project override exists`), both AC4 guard mutations (`ok: guard FIRES on a non-ASCII
frontmatter value`, `ok: guard FIRES on a non-ASCII filename`), and the AC4 pass case. The
file-wide invariant holds, every `resolve-language.sh` and `language-status.sh` call still
carries `CLAUDE_GLOBAL_CONFIG="$tmpglobal"`. `$'[\200-\377]'` and `[^ -~]` appear nowhere
else in `tests/` or `bin/` except `language-guard.sh:49`, which is untouched, so the delta
has no reader outside this file and I did not re-run the other suites.

One portability note, not a finding: `$'...'` is a bash extension. The shebang is bash, the
repo convention is `bash tests/*.test.sh`, and macOS `/bin/sh` (bash 3.2 in posix mode)
expands it correctly (verified: TAB 0, umlaut 1). Under dash it would degrade, and it would
degrade loudly on the body half. No CI runs this with `sh`.

**AC1 stays an observation.** The live half is proven by the human reading
`docs/checklists/language-live-check.md` at the gate. It is not a deterministic pass, it
counts toward no score here, and nothing in this delta changes that.

## Critical (must fix before merge)

None.

## Important (should fix)

- **`tests/localized-prose.test.sh:93-99`, the assertion proves "the body carries non-ASCII
  BYTES" while three separate surfaces claim "LETTERS", so an ASCII-prose body with one
  stray symbol still passes.** The three surfaces are the `ok:` message ("carries non-ASCII
  letters"), the comment's first three words ("UTF-8 LEAD BYTES", which the class is not,
  see Q1), and contract C3, which declares the fixture's "body prose is German including
  non-ASCII letters". The mechanism proves none of the three. Demonstrated: M3 (curly
  apostrophe), M4 (box drawing in a code fence), M6 (NBSP) each keep the suite green with the
  German fully transliterated, and M3 prints `ok: the fixture body carries non-ASCII letters
  (1 lines)` about an apostrophe. The realistic regression path in this repo is an LLM
  rewrite of the fixture, and LLM-written markdown routinely carries curly quotes and NBSP,
  so this is the scenario the tripwire is most likely to meet. `lessons.md:14` states the
  rule and both branches of it are acceptable:
  - **Narrow the mechanism (recommended).** Use `$'[\303-\305][\200-\277]'` in both lines,
    i.e. U+00C0 to U+017F, the Latin-1 Supplement plus Latin Extended-A. I proved this class
    before prescribing it, because the class I prescribed in round 2 is what created this
    finding: it matches `ä ß é ç` (de, fr) AND `č đ š` (hr, which the Latin-1-only
    `$'\303[\200-\277]'` misses), rejects U+2019, U+00A0, U+250C, U+1F600, U+2013 and TAB,
    keeps the fixture at exactly 6 body lines and 0 frontmatter lines, and still counts the
    M7 frontmatter leak as 1. Both grep binaries agree. Honest caveat to write into the
    comment rather than discover later: this is a letter BLOCK range, not a letter class, so
    `×` U+00D7 and `÷` U+00F7 still match, and a fixture translated outside those two blocks
    (Greek, Cyrillic) would fail LOUDLY rather than silently, which is the safe direction.
  - **Or narrow the claim.** Keep `$'[\200-\377]'` and say "bytes" in the `ok:` line, the
    FAIL line and the comment, and fix "UTF-8 LEAD BYTES" to "any byte >= 0x80".
  Either way, re-run M3, M4 and M6 and confirm the first option takes them RED (or, under the
  second option, that the message no longer lies about what stayed green).

## Nitpicks (optional)

- `tests/localized-prose.test.sh:96-97`, `grep -c` exits 1 when the count is 0, so the
  `fm_nonascii` assignment normally carries exit status 1 under `pipefail`. Harmless today
  (nothing reads `$?` until line 141, after a different command), but line 141 shows this
  file does read bare `$?`, so a future assertion inserted after line 97 would misread it.
  A trailing `|| true` on both assignments removes the trap for one token.
- The round-2 nitpicks are untouched by this delta and still stand as written:
  `tests/skills-lint.test.sh:10-14` asserting exit code only; `$TMP` doubling as the
  no-override project directory and the mutation scratch directory; the helper comment
  placement in `bin/skills-lint.sh:113-117`; the six-file reviewer-tail identity still
  verified by hand instead of by a two-line `shasum | sort -u | wc -l` assertion.

## Scores
correctness 2/2 · security 2/2 · performance 2/2 · readability 2/2 ·
testing 1/2 · conventions 2/2  -> total 11/12  (threshold: >=9, no zero)

Rounds 1 to 3, per criterion:

| criterion | R1 `a308b11` | R2 `1b5e1da` | R3 `fd8d6e5` | movement |
|---|---|---|---|---|
| correctness | 1 | 2 | 2 | better, then held |
| security | 2 | 2 | 2 | same |
| performance | 2 | 2 | 2 | same |
| readability | 1 | 2 | 2 | better, then held |
| testing | 1 | 1 | 1 | same number, narrower hole |
| conventions | 1 | 2 | 2 | better, then held |
| **total** | **8/12** | **11/12** | **11/12** | 8 -> 11 -> 11 |

**Same total, not the same quality, and I will not pretend otherwise.** In round 2 the
tripwire could be defeated by ONE ordinary edit that nobody aimed at it: a tab-indented line
in a markdown body, with the German untouched. At `fd8d6e5` it takes a COMPOUND edit,
transliterate the German AND leave a non-ASCII symbol behind. The assertion now fires on the
regression it exists to catch, in that regression's ordinary form (M2 proves it). The 0-2
rubric has no room between "one Important" and "clean", so a real improvement reads flat.
That is a granularity limit of the rubric, not a stall.

Why testing stays at 1 rather than going to 2: the artifact still admits a wrong-reason pass
that I reproduced three times, and "1 = Important finding(s)" is my own rule. The point is
withheld from the ARTIFACT, not from the executor's discipline, which was exact: the round-2
fix text asked for `$'[\200-\377]'` in two lines plus two RED mutations, and that is
precisely what shipped, reproducible in a third party's hands. **The residual is a defect of
my own prescription.** Round 2 named the hole "TAB" and prescribed a class that fixes TAB and
nothing else; the wider claim/mechanism gap survived because my prescription carried it.
Recording that here so the next round is not tempted to read a repeat finding as a repeated
mistake by the executor.

Where the other points sit. **correctness 2**: the mechanism is byte-correct on both grep
flavors and both shells present, the frontmatter half still catches a real leak three ways,
and every way I could break the awk partition fails in the safe direction. **security 2**:
unchanged, a test-internal character class, no user input, no secrets, no PII; mutations go
to `mktemp -d` with a trap, and C3's "the fixture is never mutated in place by a test" holds.
**performance 2**: two greps over 26 lines. **readability 2**: the comment's factual error is
inside the Important above rather than double-counted here; the rest of the comment is the
best kind, it names the byte value and the concrete regression instead of restating the code.
**conventions 2**: CLAUDE.md's "coverage claims are proven by mutation, not asserted, break
the target and watch it go RED before writing the claim" was followed literally, RED first
and then the fix, and I reproduced both REDs; comments English; conventional commit subject;
correct branch; no test weakened, the change strengthens one.

## Ceiling
**11/12 for this round, and the missing point was not the executor's to earn.** Nothing here
caps structurally: the delta is fully deterministic-testable, and AC1's live half is
correctly excluded from the deterministic layer by design rather than faked, so it costs no
points. But 12/12 at `fd8d6e5` required the executor to improve on the reviewer's own
prescribed character class rather than implement it, which is not a reasonable expectation of
a round-3 fix commit. 12/12 is reachable in one more edit, now that the class is proven:
`$'[\303-\305][\200-\277]'` in two lines, the word "letters" made true, "UTF-8 LEAD BYTES"
corrected, and M3, M4, M6 shown RED. That is the human's call, not a loop round.

## What's good

- **RED before GREEN, and the RED reproduces in someone else's hands.** M1 and M2 both go
  RED at `fd8d6e5` exactly as the commit body says. The common failure mode is a mutation
  proof that only works for its author; this one did not need the author present.
- **The fix reached BOTH lines, not just the one I demonstrated.** I showed the hole on the
  body half only. Changing the frontmatter half too was the executor's own extension of the
  finding, it is the half where an under-broad class would hide a real leak, and M7 confirms
  it still catches one. That is `lessons.md:19`, verify the whole surface the change touches.
- **The comment records the regression, not the code.** "TAB is 0x09" and the sentence naming
  the exact defeated scenario are what a maintainer needs in three years; a comment saying
  "match non-ASCII" would have been worthless. Two of its three sentences are precisely right.
- **The layering is now honest.** Control bytes belong to the guard's printable-ASCII rule
  (`language-guard.sh:49`), non-ASCII shape belongs to this assertion, and M9 proves the two
  together leave no gap where the narrowing removed coverage.
- **Round 1 to 3 with no scope creep at all.** Round 3 is one file, one concern, five lines,
  no drive-by edits, no test weakened, no unrelated refactor riding along.

## History

- Round 1, `a308b11`, 8/12, REQUEST CHANGES. Seven findings: the C2 pointer clause had zero
  coverage and was silently deletable; the six AC3 assertions could not see the temp global's
  content; the fixture's non-ASCII property was asserted nowhere; `skills-lint.sh` carried two
  verbatim copies of the definition detector; five agent files shipped a false claim about
  their own output template; rule F had dropped the two gate script names; two line-budget
  deviations were undisclosed.
- Round 2, `1b5e1da`, 11/12, APPROVE WITH COMMENTS. All seven closed, verified by independent
  mutation. One new Important introduced by fix 3: `[^ -~]` also matches TAB, so a
  transliterated body with one tab-indented line passed.
- Round 3, `fd8d6e5`, 11/12, APPROVE WITH COMMENTS. The TAB hole is closed and both claimed
  mutations reproduce RED independently; the frontmatter half still catches a real localized
  `title:`; net coverage of control bytes is preserved by the guard layer. Residual, same
  species one order narrower and authored by round 2's own prescription: the class matches
  non-ASCII bytes while the message, the comment and contract C3 say letters, so a
  transliterated body carrying one curly quote, NBSP or box-drawing character still passes
  (M3, M4, M6 demonstrated). Loop cap reached; the human arbitrates.
