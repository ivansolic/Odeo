# Plan: Enforced publish guard (internal-artifact leak prevention)
approved: yes (human, 2026-07-25)
model_plan:
  judgment: Opus 4.8 (session, strongest tier) effort high
  builder: sonnet tier (per AGENTS.md tier map) effort high
arch_review: pending (v1 review: 3 BLOCKING + 2 important. Revised v2: push-contract A
  = refuse any non-snapshot push to the public remote (Task 3); NUL-delimited path reading
  so non-ASCII names cannot bypass the denylist (Task 2/3, BLOCKING-2); privacy-scan is
  ADVISORY exit 3, denylist is the hard gate exit 1 (Task 2/4, BLOCKING-1, empirically only
  docs/privacy-guard.md false-positives); ref-shapes covered by contract A hard-refuse
  (IMPORTANT-4); gitignore-vs-denylist sync note (Task 6, IMPORTANT-5).
  v2 re-review verdict CLEAN-WITH-NITS: all 3 BLOCKING + 2 IMPORTANT confirmed CLOSED. One
  new IMPORTANT: the denylist is fail-open, so a FUTURE committed-but-internal directory
  nobody adds to the denylist (e.g. docs/postmortems/) would ship. Revised v3 closes it by
  making the publish path FAIL-CLOSED: a KEEP-PUBLIC allowlist (docs/public-paths.txt, second
  single-source list) + a guard --require-allowlist mode; the snapshot REFUSES (exit 1) any
  materialized path not covered by the allowlist, so an unclassified path blocks publish
  instead of leaking. Invariant reframed toward committed-path coverage (Task 6). Two v2
  NITs (symlink enumeration, snapshot-dir-is-a-separate-repo seam) folded in as notes.
  v3 re-review verdict CLEAN-WITH-NITS: v2 IMPORTANT confirmed CLOSED (fail-closed via
  allowlist + --require-allowlist hard gate; forgotten-future-internal-dir scenario walked
  through and fails exit 1, snapshot deleted); both v2 NITs FOLDED; exit-logic unambiguous;
  invariant now committed-path coverage. Two new doc-accuracy NITs raised and FOLDED here:
  (NIT-1) allowlist seed completed with privacy-guard.md, skill-authoring-standard.md,
  second-opinion-protocol.md; (NIT-2) Task 5 real-tree snapshot expected exit 3 (advisory
  privacy on privacy-guard.md), guard-on-snapshot exit 0 is the completeness proof. No
  BLOCKING/IMPORTANT open. arch_review: CLEAN. Awaiting human approval to flip `approved`.)

## Header
Goal: Make it physically impossible for internal build artifacts (todo/lessons,
  dogfood checklists, evals, plans, prds, stories, research) to reach the PUBLIC
  GitHub repo, via a single-source denylist, a deterministic guard, a pre-push
  hook backstop, and a clean-snapshot builder that is the real publish path.
Serves: the [E] no-leak guardrail and the locked human decision that the public
  repo is published as a clean snapshot, never a raw push of the working branch.
  This is the enforcement half of "internal artifacts never ship" (memory:
  never-publish-internal-artifacts): gitignore documents intent, this makes it
  fail-closed.
Architecture context: bash + markdown repo, no build step. Deterministic gates
  live in `bin/*.sh` with self-contained `tests/*.test.sh` (mktemp fixtures). The
  established gate contract (coverage-check.sh, language-guard.sh, privacy-scan.sh):
  exit 0 = clean, exit 1 = violation named on stderr, exit 2 = usage error;
  `set -uo pipefail`; `LC_ALL=C`; `tr -d '\r'`; `mktemp` fixtures; lists read from a
  file. Git hooks are installed (not versioned) by `bin/install-git-guards.sh`. This
  plan INHERITS that contract and does not redecide it.
Constraints:
  - TDD for the deterministic pieces (publish-guard: RED first). Logic with clear
    rules, so test-first is mandatory.
  - English-only comments; no em/en dashes; no version-pinned names (C11); chmod +x.
  - The denylist is a SINGLE source of truth (`docs/internal-paths.txt`); guard and
    snapshot builder both read it (env-overridable path for tests).
  - FAIL-CLOSED publish (v3): a denylist alone is fail-open (anything unlisted ships), so a
    future committed-but-internal path nobody denylists would leak. To make that impossible,
    the PUBLISH PATH is allowlist-gated: a second single-source list `docs/public-paths.txt`
    (KEEP-PUBLIC) enumerates what may be published, and the snapshot REFUSES (exit 1) any
    materialized path not covered by it. Denylist and allowlist are complementary: denylist =
    "definitely internal, strip it"; allowlist = "confirmed public, everything else is
    unclassified and blocks the publish until a human classifies it". docs/ is the mixed zone,
    so the allowlist NEVER lists `docs/` as a whole (that would re-open the hole); it lists
    only the specific public docs entries. Env-overridable path for tests
    (`CLAUDE_PUBLIC_PATHS`, default `docs/public-paths.txt`).
  - Denylist (public snapshot EXCLUDES exactly these; they stay in the working repo):
      .claude/tasks/todo.md
      .claude/tasks/lessons.md
      docs/checklists/dogfood-protocol.md
      docs/checklists/dogfood-results.md
      docs/checklists/prototype-dogfood-protocol.md
      docs/checklists/prototype-dogfood-results.md
      docs/checklists/anthropic-practices-pass.md
      docs/checklists/skills-alignment-pass.md
      docs/evals/          (directory prefix)
      docs/plans/          (directory prefix)
      docs/prds/           (directory prefix)
      docs/stories/        (directory prefix)
      docs/research/       (directory prefix)
  - KEEP-PUBLIC allowlist seed (`docs/public-paths.txt`): the wholly-public top-level dirs
    coarsely (skills/, agents/, bin/, tests/, project-templates/, global/, .github/) plus the
    public root files (README.md, ROADMAP.md, INSTALL.md, install.sh, LICENSE, CONTRIBUTING.md,
    CODE_OF_CONDUCT.md, AGENTS.md, BEGINNERS-GUIDE.md, WORKFLOW.md, CLAUDE.md, .gitignore) plus
    ONLY the specific public docs entries (docs/examples/, docs/checklists/review-calibration.md,
    and each public docs root file: plan-format.md, eval-framework.md, invariants.md,
    system-map.md, internal-paths.txt, public-paths.txt, privacy-guard.md,
    skill-authoring-standard.md, second-opinion-protocol.md, and any other public docs/*.md
    the dry-run reveals). NEVER `docs/` as a whole. The builder completes this list against the real
    HEAD tree and PROVES completeness via the Task 5 dry-run (snapshot must exit 0): any public
    path missing from the allowlist makes the dry-run fail, which is the forcing function.
  - Success signal MUST include a DRY-RUN proving the guard FAILS on the current
    working tree (internal paths present) and PASSES on a snapshot with them removed.
  - Do-not-touch: `bin/privacy-scan.sh` is REUSED, not modified. The existing
    pre-push "no direct main/master" body must be PRESERVED; the denylist check is
    ADDED alongside it.
  - Public-remote name configurable (default `origin`, override CLAUDE_PUBLIC_REMOTE).
  - No product-level architecture change; no ADR. gitignore unchanged (docs/evals
    stays committed, kept public-clean by the snapshot step).

## File map (before any tasks)
- docs/internal-paths.txt          CREATE: single-source denylist globs (commented).
- docs/public-paths.txt            CREATE: single-source KEEP-PUBLIC allowlist globs
                                   (commented). Fail-closed side of the publish gate.
- bin/publish-guard.sh             CREATE: deterministic guard. dir arg and/or stdin
                                   file list; exit 1 naming any denylist match; optional
                                   --require-allowlist mode also exit 1 on any path NOT
                                   covered by the allowlist (unclassified); runs privacy-scan
                                   on publishable files; exit 2 usage. +x.
- tests/publish-guard.test.sh      CREATE: mktemp fixtures, RED first.
- bin/install-git-guards.sh        MODIFY: extend pre-push hook to also run the
                                   denylist check for the public remote; preserve the
                                   no-direct-main body + pre-commit.
- bin/publish-snapshot.sh          CREATE: clean public tree = tracked HEAD content
                                   minus denylist, verified by publish-guard
                                   --require-allowlist (denylist HARD + allowlist HARD +
                                   privacy ADVISORY); emits the snapshot dir path. +x.
- tests/publish-snapshot.test.sh   CREATE: mktemp git repo fixture.
- tests/install-git-guards.test.sh CREATE: hook-install assertions.
- docs/invariants.md               MODIFY: prose note (denylist single source).
- docs/system-map.md               MODIFY: register the two scripts + pre-push note.
- AGENTS.md                        MODIFY: one [E] guardrail bullet under Privacy.

## Tasks

### Task 1: single-source denylist + KEEP-PUBLIC allowlist files
- Scrutiny: standard
- Test first: none of its own; Task 2's RED run first exercises both (committed
  separately for a clean history entry).
- Implement:
  - `docs/internal-paths.txt` with a commented header explaining the match rules
    (trailing "/" = directory prefix; no trailing "/" = exact repo-relative file; # and
    blank ignored) and a pointer to the allowlist, then the 13 denylist entries exactly
    as listed in Constraints.
  - `docs/public-paths.txt` with the SAME commented match-rule header and a note that it
    is the fail-closed KEEP-PUBLIC side (publish refuses anything not covered here; NEVER
    add `docs/` as a whole), then the allowlist seed entries from Constraints. The builder
    MUST reconcile this list against the real HEAD tree so the Task 5 dry-run snapshot
    exits 0 (add any public path the dry-run flags as unclassified).
- Verify: `grep -vE '^#|^$' docs/internal-paths.txt | wc -l` prints `13`;
  `grep -c '^docs/' docs/internal-paths.txt` prints `5`; `docs/public-paths.txt` has a
  non-empty entry list and does NOT contain a bare `docs/` line
  (`grep -qxE 'docs/' docs/public-paths.txt` must FAIL).
- Produces: both lists; env overrides `CLAUDE_INTERNAL_PATHS` (default
  `docs/internal-paths.txt`) and `CLAUDE_PUBLIC_PATHS` (default `docs/public-paths.txt`),
  resolved at the repo root.
- Commit: `chore(publish-guard): add internal-paths denylist and public-paths allowlist as single sources of truth`

### Task 2: bin/publish-guard.sh (TDD, RED first)
- Scrutiny: judgment (security core; matching + privacy integration).
- Test first: `tests/publish-guard.test.sh` BEFORE the script; run, watch FAIL. Style
  of coverage/language-guard tests (mktemp, assert_exit, assert_contains, trap). Cases:
  1. Clean dir (only public files) -> exit 0, "clean".
  2. Dir with `docs/plans/p.md` -> exit 1, names it.
  3. Dir with `docs/evals/EVR-1.md` (dir-prefix match) -> exit 1, names it.
  4. Dir with `.claude/tasks/todo.md` (exact match) -> exit 1, names it.
  5. NEGATIVE: `docs/checklists/review-calibration.md` present, no denylisted file
     -> exit 0 (keep-public not confused with denylisted checklists).
  6. NEGATIVE: `docs/plans-summary.md` (looks similar, NOT under docs/plans/) -> exit 0.
  6b. NON-ASCII (BLOCKING-2): a denylisted `docs/plans/résumé.md` (name with a non-ASCII
      byte) fed via `git ls-tree -r -z` / `find -print0` must still MATCH -> exit 1, named.
      This is the security-core case: paths must be read NUL-delimited so git's C-quoting
      of non-ASCII names cannot silently defeat the match.
  7. stdin file-list mode (no dir arg): piped NUL-delimited list incl. `docs/stories/s.md`
     -> exit 1.
  8. Privacy (ADVISORY): public `README.md` containing a fake `API_KEY=sk_live_...`, no
     denylisted file -> exit 3 (not 1), output names the file as a privacy finding to review.
     And: a denylisted file PLUS a privacy finding -> exit 1 (denylist is the hard gate, wins).
  9. Env override: `CLAUDE_INTERNAL_PATHS` at a temp denylist listing only `docs/foo/`;
     `docs/foo/x.md` -> exit 1; real `docs/plans/` NOT flagged (file is the only source).
  10. Usage: no dir arg AND no stdin, or nonexistent dir -> exit 2.
  11. ALLOWLIST (fail-closed): with `--require-allowlist` and a temp allowlist covering
      `README.md` + `skills/`, a dir holding `README.md`, `skills/x/SKILL.md` -> exit 0.
  12. ALLOWLIST catches the forgotten-internal-dir: with `--require-allowlist`, a dir holding
      a NEW `docs/postmortems/p.md` that is in NEITHER list -> exit 1, message names it as an
      unclassified path (this is the v3 IMPORTANT-fix case: a denylist alone would pass it).
  13. ALLOWLIST precedence: with `--require-allowlist`, a dir holding both `docs/plans/p.md`
      (denylisted) and an unclassified `docs/postmortems/p.md` -> exit 1 (denylist reported
      first / both are hard). WITHOUT `--require-allowlist`, the unclassified path alone
      -> exit 0 (allowlist enforcement is opt-in; the hook backstop does not require it).
- Implement: `bin/publish-guard.sh`, `chmod +x`. `set -uo pipefail`. Resolve repo root
  from `$0`; `DENYLIST="${CLAUDE_INTERNAL_PATHS:-$ROOT/docs/internal-paths.txt}"`
  (missing -> exit 2). Parse a leading `--require-allowlist` flag (default off); when set,
  `ALLOWLIST="${CLAUDE_PUBLIC_PATHS:-$ROOT/docs/public-paths.txt}"` (missing -> exit 2). Then
  parse optional dir arg (`-` = also read stdin); no dir + stdin is a TTY -> exit 2. Build the
  candidate list NUL-DELIMITED (BLOCKING-2, so git C-quoting of non-ASCII names cannot defeat
  the match): dir arg -> `( cd dir && find . \( -type f -o -type l \) -print0 )` stripped of
  leading `./` (v2-NIT: include symlinks so a symlinked internal path cannot slip the dir-mode
  scan); stdin -> `read -r -d ''`; dedup. Callers piping git MUST use
  `git ls-tree -r -z --name-only` (NUL). Never parse newline-delimited path lists. Load
  denylist under `LC_ALL=C` into `dir_prefixes` (trailing `/`) and `exact_files`. Match:
  exact equality, or `case "$cand" in "$prefix"*)` (prefix always ends `/`, so
  `docs/plans/` does not match `docs/plans-summary.md`). On denylist match:
  `echo "publish-guard: BLOCK internal path present: $cand" >&2; deny=1`. ALLOWLIST tier
  (only when `--require-allowlist`): load `$ALLOWLIST` the SAME way (LC_ALL=C, dir_prefixes +
  exact_files); a candidate that matches NEITHER the denylist NOR the allowlist is
  unclassified -> `echo "publish-guard: BLOCK unclassified path (not in public-paths.txt): $cand" >&2; unclassified=1`.
  (A denylisted path is already handled by `deny`; do not double-report it as unclassified.)
  Privacy is a SEPARATE, ADVISORY tier (BLOCKING-1): locate `$ROOT/bin/privacy-scan.sh`; for
  each NON-denylisted candidate readable as a file (only when a dir arg gave real content), run
  it; a finding -> `echo "publish-guard: privacy finding (review): $cand" >&2; priv=1` (do
  NOT fold into deny). End (hard gates win over advisory): `deny` OR `unclassified` set ->
  exit 1 (hard: internal path present, or an unclassified path that must be added to one of
  the two lists before publishing). Else `priv` set -> exit 3 (advisory, human must review
  privacy findings). Else `echo "publish-guard: clean (N files checked)."; exit 0`.
  Header documents that stdin-only mode checks denylist membership only (no bodies to
  scan); the snapshot builder always passes a real dir, so the publish path gets privacy.
- Verify: `bash tests/publish-guard.test.sh` all GREEN; `test -x bin/publish-guard.sh`.
- Consumes: Task 1 denylist; `bin/privacy-scan.sh` (unmodified).
- Commit: `feat(publish-guard): deterministic guard against publishing internal artifacts`

### Task 3: extend the pre-push hook (public-remote backstop)
- Scrutiny: judgment (ref inspection; fail closed).
- Test first: `tests/install-git-guards.test.sh` (CREATE): run the installer in a mktemp
  `git init` repo with a bare `origin` remote; assert (a) `.git/hooks/pre-push` exists +x,
  (b) it still contains the `refs/heads/main` refusal (preserved), (c) contract A behavior:
  a push to `origin` (public) of a feature branch WITHOUT `CLAUDE_PUBLISH_SNAPSHOT=1` is
  REFUSED (grep REFUSED / non-zero), (d) the same push WITH `CLAUDE_PUBLISH_SNAPSHOT=1` and
  a denylist-clean tree is allowed, (e) WITH the marker but a `docs/plans/x.md` in the tree
  is REFUSED (defense-in-depth guard), (f) a force-push and a tag push to origin without the
  marker are both REFUSED (contract A covers every ref-shape), (g) a push to a NON-public
  remote `backup` is not subject to the public refusal. Run FIRST -> the contract-A cases
  FAIL (RED); (a)/(b) are regression guards.
- Implement (PUSH CONTRACT A, locked): in `bin/install-git-guards.sh`, extend the installed
  pre-push hook. Hook reads git's `$1` (remote name), `public_remote="${CLAUDE_PUBLIC_REMOTE:-origin}"`.
  For each pushed ref line: PRESERVE the existing main/master refusal (unchanged).
  THEN, when `remote_name = public_remote`, **REFUSE the push outright** unless an explicit
  snapshot marker is set (`CLAUDE_PUBLISH_SNAPSHOT=1`, which ONLY `bin/publish-snapshot.sh`'s
  own push step sets). Rationale (contract A): the working repo's HISTORY contains internal
  files, so NO raw push of it is ever safe; the public repo is published ONLY from the clean
  snapshot. So the default is hard refuse to the public remote, covering every ref-shape at
  once (new branch, force-push, tag, multiple refs), a raw push simply cannot reach public.
  Defense-in-depth: even when the snapshot marker IS set, still run the denylist guard over
  what is pushed (`git ls-tree -r -z --name-only "$local_sha"` NUL-delimited, see BLOCKING-2)
  piped to publish-guard; if it finds anything, or enumeration fails, REFUSE (fail closed).
  Deletion (all-zero local_sha) is skipped. Message on refuse: "publish via
  bin/publish-snapshot.sh; the working repo is never pushed to $public_remote." Preserve the
  pre-commit heredoc, the `chmod +x`, and the installer's `set -euo pipefail` + work-tree guard.
- Verify: `bash tests/install-git-guards.test.sh` all pass. Manual smoke (builder runs):
  mktemp repo, install, commit a `docs/plans/x.md`, add a bare `origin`, `git push origin
  HEAD 2>&1 | grep -q REFUSED` -> refused; a push to a non-public remote is not blocked by
  the internal check.
- Consumes: Task 2 guard; Task 1 denylist; `CLAUDE_PUBLIC_REMOTE` (default origin).
- Commit: `feat(publish-guard): pre-push hook blocks internal artifacts to the public remote`

### Task 4: bin/publish-snapshot.sh (the real publish path)
- Scrutiny: judgment (content snapshot, not history).
- Test first: `tests/publish-snapshot.test.sh` (CREATE): mktemp `git init`, commit public
  files (README.md, skills/x/SKILL.md, docs/checklists/review-calibration.md) + internal
  (docs/plans/p.md, docs/evals/e.md, .claude/tasks/todo.md); point CLAUDE_INTERNAL_PATHS at
  a fixture denylist AND a fixture allowlist (via CLAUDE_PUBLIC_PATHS) covering README.md,
  skills/, docs/checklists/review-calibration.md. Cases: (1) build -> exit 0; snapshot HAS
  README + review-calibration, LACKS docs/plans, docs/evals, .claude/tasks/todo.md. (2) plant
  a fake secret in README -> exit 3 (advisory privacy), snapshot KEPT for review. (3) re-run
  over same HEAD -> exit 0 (fresh temp dir). (4) v3 FAIL-CLOSED case: commit a NEW
  `docs/postmortems/p.md` that is in NEITHER the fixture denylist NOR the fixture allowlist
  -> build exit 1, "unclassified", no publishable snapshot (this is the forgotten-future-dir
  guarantee). Run FIRST -> FAIL (RED).
- Implement: `bin/publish-snapshot.sh`, `chmod +x`. `set -uo pipefail`. Require a git repo
  (else exit 2). Resolve root, denylist, guard (missing -> exit 2). Output dir: `$1` or
  `mktemp -d`. Materialize tracked HEAD content: `git archive --format=tar HEAD | tar -x -C
  "$out"` (only tracked files at HEAD; history never copied). Strip denylist from the
  materialized tree (dir-prefix -> `rm -rf -- "$out/$entry"`; exact -> `rm -f`). Verify in
  two tiers (BLOCKING-1): (a) HARD gate , run `bin/publish-guard.sh --require-allowlist "$out"`
  (denylist AND allowlist both enforced): any internal path OR any path not covered by the
  KEEP-PUBLIC allowlist (unclassified) -> "verification FAILED", `rm -rf "$out"`, exit 1. This
  is the fail-closed guarantee (v3): a forgotten-future-internal dir that never made it into
  the denylist is not on the allowlist either, so it fails here instead of shipping. (b) PRIVACY
  is ADVISORY , privacy-scan is a "redact or confirm each is a generic example" net by its
  own design and false-positives on legit public docs (empirically `docs/privacy-guard.md`
  trips because it DOCUMENTS the patterns). So privacy findings are SURFACED per file and
  exit 3 = "human must review before publishing" (snapshot KEPT for inspection), never a
  silent pass nor a permanent hard-fail. Success (denylist clean + no privacy findings):
  `echo "$out"` to stdout + human line to stderr, exit 0. The push marker
  `CLAUDE_PUBLISH_SNAPSHOT=1` is set by the human only after confirming any exit-3 findings.
- Verify: `bash tests/publish-snapshot.test.sh` GREEN; `test -x bin/publish-snapshot.sh`.
- Consumes: Task 2 guard; Task 1 denylist; git.
- Commit: `feat(publish-guard): clean-snapshot builder as the public publish path`

### Task 5: DRY-RUN success signal on the real working tree
- Scrutiny: standard (mandated proof, not new logic).
- Test first: none (evidence step, recorded in the commit body).
- Implement / Verify (run from repo root, capture output):
  1. `git ls-tree -r --name-only HEAD | bin/publish-guard.sh; echo "exit=$?"` ->
     exit 1, names docs/plans/*, docs/evals/*, docs/prds/*, docs/stories/*, docs/research/*.
  2. `snap="$(bin/publish-snapshot.sh)"; echo "exit=$?"; bin/publish-guard.sh --require-allowlist "$snap";
     echo "guard-on-snapshot=$?"; find "$snap" -path '*docs/plans*' -o -path '*docs/evals*'`
     -> snapshot build exit 3 EXPECTED on the real tree (advisory privacy finding on
     docs/privacy-guard.md, which DOCUMENTS the secret patterns; snapshot is KEPT, human
     confirms it is a generic documented example, not a leak). The completeness proof is the
     next check: guard-on-snapshot exit 0, and find prints nothing. guard-on-snapshot exit 0
     with --require-allowlist PROVES docs/public-paths.txt covers the entire real public tree
     (any missing public path would surface here as unclassified; add it). Do NOT edit
     docs/privacy-guard.md to force snapshot exit 0; exit 3 is the correct advisory outcome.
  Paste both transcripts into the commit body.
- Commit: `test(publish-guard): dry-run proof, guard fails on working tree, passes on snapshot`

### Task 6: docs (invariants, system-map, AGENTS.md) + memory note
- Scrutiny: standard.
- Test first: none (docs). Prose invariant; the mechanical enforcement is the allowlist gate
  built in Tasks 2/4, not a new skills-lint check (see Risks 6).
- Implement:
  - `docs/system-map.md`: add publish-guard.sh + publish-snapshot.sh rows; note the
    pre-push extension (public remote, CLAUDE_PUBLIC_REMOTE) and the two lists
    (internal-paths.txt denylist + public-paths.txt allowlist).
  - `AGENTS.md` under "### 2. Privacy and data": one [E] bullet , internal artifacts never
    reach the public repo: publish-guard.sh + pre-push backstop refuse them, and the public
    repo is published only via publish-snapshot.sh, which is FAIL-CLOSED (refuses any path not
    on the docs/public-paths.txt allowlist, so an unclassified path blocks publish). No em/en
    dashes.
  - `docs/invariants.md`: prose lines. (1) The publish lists live ONLY in
    docs/internal-paths.txt (denylist) and docs/public-paths.txt (allowlist); guard, hook, and
    snapshot all read them, no second copies. (2) FAIL-CLOSED invariant (the real guarantee,
    reframed from IMPORTANT-5's original direction): every COMMITTED path must be classified as
    EITHER internal (denylist) OR public (allowlist); the publish snapshot mechanically REFUSES
    any unclassified path (publish-guard --require-allowlist, exit 1), so a future
    committed-but-internal directory that nobody denylists cannot silently ship, it blocks the
    publish until a human classifies it. This replaces the fragile "remember to add it to the
    denylist" discipline with enforcement. (3) The `.gitignore` "Internal build artifacts" block
    and docs/internal-paths.txt are two lists with different jobs (gitignore governs
    `git archive`/tracking; the denylist governs guard/snapshot); gitignored internal paths are
    belt-and-suspenders (git archive omits them anyway). No separate skills-lint drift check is
    needed, the allowlist gate at publish time IS the mechanical enforcement.
  - Commit body includes a MEMORY note for the human (do NOT edit MEMORY.md):
    never-publish-internal-artifacts enforcement now exists and is FAIL-CLOSED; sources =
    docs/internal-paths.txt (denylist) + docs/public-paths.txt (allowlist).
- Verify: `bin/skills-lint.sh .` exit 0; grep confirms the three docs mention the scripts
  and both lists.
- Commit: `docs(publish-guard): register guard, snapshot, and pre-push backstop`

## Task order
Sequential: 1 (denylist) -> 2 (guard, TDD) -> 3 (hook) and 4 (snapshot) both depend on 2
-> 5 (dry-run) depends on 2+4 -> 6 (docs). One builder, one session.

## Risks / open questions
1. Pre-push inspects the TIP tree (`git ls-tree "$local_sha"`), not the full pushed commit
   RANGE. Correct for what lands, and the snapshot (history-free) is the real guarantee; an
   internal file only in an intermediate commit is not flagged by the hook. ASK if
   range-scanning is required (git rev-list loop, heavier).
2. History holds internal files, so a raw `git push origin <branch>` leaks even if the tip
   were clean. Mitigation: publish-snapshot.sh is a CONTENT copy (`git archive HEAD`, no
   history); the hook is only a backstop. OPEN: the exact public-repo push mechanism (fresh
   repo vs orphan branch vs subtree) from the snapshot dir is out of scope; the builder
   emits the verified snapshot dir path and the human decides who pushes it. Flag if you
   want the push step included. NOTE (v2 NIT): the emitted snapshot dir is a SEPARATE repo
   the working-repo pre-push hook does not govern; it is trusted because it was guard-verified
   (--require-allowlist) at build time, and it contains no history to leak. Pushing it is safe
   precisely because contract A keeps the working repo unpushable and the snapshot is clean by
   construction.
3. Directory-prefix (trailing `/`) vs exact-file (no slash) matching; `docs/plans/` does
   not match `docs/plans-summary.md` (test 6). Confirm the trailing-slash convention.
4. stdin mode does not run privacy-scan (no bodies); only the dir mode (publish-snapshot,
   the real path) does. Secrets on commits are already covered by the pre-commit
   secret-scan. Confirm the split.
5. CLAUDE_PUBLIC_REMOTE default origin, overridable. Noted, not open.
6. RESOLVED in v3: the drift risk (a future committed-but-internal path nobody denylists) is
   now enforced MECHANICALLY, not by prose. The KEEP-PUBLIC allowlist + snapshot
   --require-allowlist gate REFUSES any unclassified path at publish time (fail-closed), which
   is a stronger and better-placed guarantee than a skills-lint text check would have been. The
   invariant text (Task 6) now describes this enforcement rather than a discipline to remember.
7. NOT doing: no gitignore change, no history rewrite, no automated push of the snapshot. (v3
   DOES add the allowlist as the mechanical drift guard, reversing v2's "no new enforcement".)
   Pull anything else in at the gate if wanted.
