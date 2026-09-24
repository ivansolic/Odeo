---
description: Build-to-learn discovery, spin up N disposable working prototypes in parallel (each in its own worktree, own port, running server), compare them live, kill the weak ones, and capture the winner's learnings as findings that feed the real build. Use when an idea is concrete enough to touch but you don't know which shape is right. Prototypes prove desirability; they never ship raw.
disable-model-invocation: true
---

# Prototype (taste at speed)

Instead of speccing first, build 2-3 cheap working variants, FEEL them, keep the
best, throw the rest. The prototype's job is LEARNING, not shipping: code quality
comes later, through the real build pipeline.

## Preconditions
- A git project. None here? Offer: "want me to init a light project so prototypes
  and findings have a home?" If declined: work in a scratch worktree, but say the
  consequence plainly, promoting to a real build will need a project later.

## Process
1. **Frame the question**: what must these prototypes teach us? (e.g. "which
   invoicing flow feels effortless?"). One sentence, written down.
   **If PM artifacts already exist** (docs/prds/, or docs/research/ holding
   discovery packets and RES-NNN research reports), DERIVE the framing question
   and variant ideas from them instead of
   asking from scratch: "PRD-002 says the problem is X for persona Y, proposed
   framing: 'which shape of Z feels effortless for Y?', confirm or correct."
   Record in the findings WHICH document the prototypes test, so a later
   promote knows what it updates. No artifacts -> ask from scratch as below.
2. **Fidelity choice** (ask plainly, and RECOMMEND from the framing question):
   - **lo-fi**, looks and behaves like the app, but nothing is really saved
     (frontend only, fake data). Tests how it FEELS: flow, layout, wording.
     Fast (minutes to an hour) and easiest to share.
   - **hi-fi**, a real miniature system (saving, accounts, real logic). Tests
     whether it actually WORKS: a parser, a calculation, a sync. Roughly 3x
     heavier; pick it only when the risk lives in the mechanics.
   The framing question decides: "which flow feels effortless?" -> lo-fi;
   "can this parser/algorithm work reliably?" -> hi-fi. Say your
   recommendation and why in one line; the user chooses.
3. **Spin up N variants (2-3)**: each gets its own git worktree, its own port,
   its own `.env`/install, and a RUNNING server. Builders may work in parallel
   (they're disposable, prototype rigor: no TDD, no review, speed over polish,
   this is the ONE place that's allowed, because nothing here ships).
4. **Present live, and actually OPEN it**: printing URLs is not presenting.
   Open each variant in the browser yourself (`open http://localhost:3001`,
   `open http://localhost:3002`, one tab per variant), and offer the editor
   view: "want the worktrees in your VS Code window too?" (`code --add <a> <b>`,
   the reuse-never-multiply ladder: code -> cursor -> graceful skip). Then the
   user clicks through and compares the real thing side by side.
5. **Share (optional, always your call, outward = gated)**:
   - quick, no account: `share-tunnel.sh <port> [minutes]` (on PATH through the Odeo plugin), a
     cloudflared quick tunnel that SHUTS ITSELF DOWN when the TTL expires
     (default 60 min; ask how long, extend by re-running). It announces the
     expiry up front and records the share in `docs/prototypes/.shares`;
   - days/stakeholders: a preview deploy (frontend host for lo-fi; full-stack
     host for hi-fi; free tiers, needs an account). If a path would make the
     code PUBLIC (e.g. GitHub Pages needs a public repo), say so plainly and
     get an explicit go.
   - **Never real or personal data in a shared prototype**, seed/fake only, and
     run `privacy-scan.sh` over the prototype's seed/env before exposing it
     (it is on PATH through the Odeo plugin;
     only if truly absent, do a manual equivalent scan and show the results).
   - **Own the exposure lifecycle.** Tunnels expire on their own (the TTL is
     the enforced floor); still say what is public and until when, offer
     teardown at any natural end of the conversation, and on "stop sharing"
     kill the tunnel AND the server and confirm both are dead. Preview
     DEPLOYS cannot expire on their own: record each one in
     `docs/prototypes/.shares` (what, host, URL, date), recommend password
     protection where the host offers it, and delete the deploy when it has
     served its purpose, `/odeo:start` reminds about old ones.
   - Live-editing a SHARED prototype: static servers + tunnels cache hard;
     reload with a cache-busted URL (`?v=<timestamp>`) so the viewer sees the
     change, not the stale copy.
6. **Evaluate and kill**: compare variants against the framing question (pairwise:
   which is better, why). Expect to kill most, they were cheap on purpose. Record
   WHY the losers lost.
7. **Write the findings** to `docs/prototypes/<idea>/findings.md`, the durable
   handoff (checklist below), **and commit them**: durable means committed, an
   untracked file dies with the next cleanup. Branch `chore/prototype-findings`,
   commit, offer `/odeo:merge` (docs-only PR). Delete or keep the dead worktrees;
   the findings are what matters.
   (A reference example of a complete findings file:
   `docs/examples/prototype-findings-example.md`.)
8. **Promote gate (your decision)**: the winner rejoins the normal flow AT THE
   PHASE ITS SCOPE NEEDS:
   - solo/small feature -> `/odeo:spec` (prd -> critique -> stories) -> `/odeo:build`;
   - real product / many epics -> strategy (scaled to ambition) -> product-level
     foundation (architecture + ADR + high-level critique incl. security), never
     skipped -> `/odeo:plan` -> `/odeo:spec` per epic -> `/odeo:build`.
   Two build paths: **harden in place** (clean prototype: add tests, review,
   refactor to standard) or **rebuild from findings** (dirty prototype: throw the
   code, keep the learnings). Either way full dev rigor applies from here on.

## Findings checklist (capture ALL of it, nothing gets lost in a rebuild)
User flow · screens + states · tasks/stories implied · test feedback (what people
did/said) · decisions + why the winner won · why the killed variants lost ·
what worked / what didn't · tech approach + data-model sketch · edge cases found ·
security & data notes (PII/auth touched? feeds the PRD's pre-mortem) · assumptions
validated/invalidated · what the prototype did NOT cover · dependencies discovered ·
complexity signal for the real build · open risks · metrics if users touched it ·
source document tested (PRD/RES id, or "none, no PM artifacts existed") ·
date + the framing question.

## Rules for yourself
- Prototypes are disposable; say so, act so. NOTHING here ships raw.
- Prototype rigor exception applies ONLY inside this skill; promotion re-enters
  full discipline (foundation + dev rigor are never skipped).
- Sharing is outward: your explicit OK + privacy scan, fake data only.
- Each variant isolated (worktree, port, env), parallel-safe by construction.
