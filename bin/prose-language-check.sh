#!/usr/bin/env bash
# prose-language-check.sh, SOFT check that a generated document's prose reads as the
# project's effective output language.
#
# ADVISORY ONLY: it prints, it never blocks, and no document content, whatever it
# contains, can make it exit non-zero. It is a heuristic, and a warning enforces
# nothing: a mismatched document commits, merges and ships exactly as before. Human
# review and /merge remain the backstop. See AGENTS.md Guardrails 7.
#
# One divergence from bin/session-end-check.sh, the advisory script this follows: that
# one exits 0 even when it breaks, because a Stop hook must never trap a session. This
# one exits 2 on a MALFORMED INVOCATION, because an agent that mistypes the call must
# learn the check did not run rather than read silence as a pass.
#
# Usage:
#   prose-language-check.sh <project-dir> <file> [<file>...]
#
# Exit: 0 whenever the check RAN (warnings included). 2 when the invocation was
# malformed. Never anything else.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "usage: prose-language-check.sh <project-dir> <file> [<file>...]" >&2
  echo "       advisory: warns on a prose-language mismatch, never blocks." >&2
}
die2() { echo "prose-language-check: $1" >&2; exit 2; }

# The warning threshold, ONE assignment site so it can be changed in one place and
# asserted by the suite. Below MIN_HITS a single stray sentence would decide the verdict.
MIN_HITS=12

# Function-word lists. ASCII-only and pairwise DISJOINT by contract; the highest
# frequency cross-language homographs are excluded from all four, because a shared token
# would score hits for the wrong language on correct prose. One PHYSICAL line each, so
# the suite can extract them without sourcing this file (sourcing would run the argument
# parsing below and exit 2).
WORDS_DE="aber alle auch auf aus bei beim dabei damit dann das dass dazu dem den der die durch ein eine einem einen einer es gegen ihre ihrem ihren im immer ist jede jeder jedes kann kein keine mehr mit muss nach nicht noch nur oder ohne schon sehr seine seinen sich sie sind und uns unter vom von weil wenn werden wie wir wird wurde zu zum zur zwischen"
WORDS_EN="about after against all and any are as at be because been before between but by can could each every for from had has have here if into is it its more must not of only or out over should some such than that the their them then there these this those through under very we were when which while with without would you"
WORDS_FR="alors au aussi aux avec ce cela ces cette chez comme dans doit dont elle elles encore entre est et faut il ils la le les leur leurs lorsque mais nous ont ou par pas peut pour quand que qui sera ses son sont sous sur tous tout toute toutes un une vous"
WORDS_HR="ako ali bez bi bila bilo bio biti da gdje ili iz jedan jedna jer kad kada kao koja koje koji kroz mi na nakon nam nas nije nisu njih ona oni ono ova ovaj ovo po pod prije prema preko sam samo smo ste su sve svaki svi ta taj te vi za zato"

# ---------------------------------------------------------------------------
# Invocation. Every failure here means THE CHECK DID NOT RUN.
# ---------------------------------------------------------------------------
[ "$#" -ge 2 ] || { usage; exit 2; }
for a in "$@"; do case "$a" in -*) usage; die2 "unknown option: $a" ;; esac; done
PROJECT_DIR="$1"; shift
[ -d "$PROJECT_DIR" ] || die2 "not a directory: $PROJECT_DIR"
for f in "$@"; do
  [ -f "$f" ] || die2 "not a regular file: $f"
  [ -r "$f" ] || die2 "not readable: $f"
done

# The expected code comes from the shipped resolver and is never re-derived here, the
# same pass-through bin/language-status.sh uses, so the two can never disagree.
RESOLVER="$HERE/resolve-language.sh"
[ -f "$RESOLVER" ] || die2 "resolver not found: $RESOLVER"
EXPECTED="$(CLAUDE_GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md}" bash "$RESOLVER" "$PROJECT_DIR" 2>/dev/null)" \
  || die2 "resolver failed for $PROJECT_DIR"
case "$EXPECTED" in en|de|fr|hr) : ;; *) die2 "resolver returned an unknown code: '$EXPECTED'" ;; esac

# ---------------------------------------------------------------------------
# The prose region (contract C1). Steps 1 to 5 are line-level exclusions; steps 6 to 8 are
# inline and run in the SAME per-line pass. No exclusion consumes more than the construct it
# names, and nothing a document contains can make a deletion cross a line break.
#
# SAME-LINE ONLY, and why (this is where three review Criticals lived). A code span, a link
# target and a URL are deleted only within ONE line. Deleting a span that WRAPS across a line
# break is what every earlier version tried, and each attempt mispaired backticks on some shape
# and ate real prose from the lines between them, which silences the very warning this check
# exists to raise. Pairing backticks correctly when one is a stray is not decidable from a
# single document, so this version does not try. Instead it carries one bit, `opn`: a line that
# begins INSIDE an open span is code and is kept verbatim, never scanned, so a wrapped span is
# handled without any deletion crossing the break. A deletion therefore can never leave the
# line it starts on.
#
# The two costs are deliberate and bounded, because for a word-FREQUENCY check they barely
# register. (a) A code span that wraps across a line break is left in place, content and all,
# but that content is code, almost never a function word in any of the four lists, so it is not
# counted and the verdict does not move. (b) On a single line whose backticks do not pair
# cleanly (a stray plus a real span), that line's own prose up to the next backtick can be
# deleted; the loss is confined to ONE line and cannot silence a verdict built from a whole
# document. Cases K10 (a), K15c (b), against K12/K12e/K14/K15 which show a document is never
# silenced and AGENTS.md stays whole.
# ---------------------------------------------------------------------------
prose_region() {
  tr -d '\r' < "$1" | awk '
    NR==1 && $0=="---" { fm=1; next }                  # 2. frontmatter opens
    fm==1 && $0=="---" { fm=2; next }                  #    ... and closes
    fm==1              { next }                        #    everything between is dropped
    {
      line=$0
      probe=line; sub(/^[ \t]+/, "", probe)            # 3. fences, first non-ws run
      if (probe ~ /^```/ || probe ~ /^~~~/) {
        fchar = substr(probe, 1, 1)
        frun = probe; sub("[^" fchar "].*$", "", frun)
        if (!infence)                                  { infence=1; fc=fchar; fn=length(frun) }
        else if (fchar == fc && length(frun) >= fn)     { infence=0 }
        next                                           # the marker line never counts
      }
      if (infence) next
      hprobe=line                                      # 4. ATX heading, no awk intervals
      if (substr(hprobe,1,1)==" ") hprobe=substr(hprobe,2)
      if (substr(hprobe,1,1)==" ") hprobe=substr(hprobe,2)
      if (substr(hprobe,1,1)==" ") hprobe=substr(hprobe,2)
      if (substr(hprobe,1,1)=="#") {
        hrun=hprobe; sub(/[^#].*$/, "", hrun)
        hrest=substr(hprobe, length(hrun)+1)
        if (length(hrun) <= 6 && (hrest=="" || substr(hrest,1,1)==" " || substr(hrest,1,1)=="\t")) next
      }
      probe2=line; sub(/^[ \t]+/, "", probe2)
      if (substr(probe2,1,1) == "|") next              # 5. one table row

      # 6, 7, 8. Inline, SAME LINE, and only on a line that BEGINS outside a code span.
      # `opn` carries one bit across lines: whether an earlier line left a code span open with
      # an unpaired backtick. A line inside such a span is code, not prose, so it is kept
      # VERBATIM and never scanned; that is how a code span wrapping across a line break is
      # honoured without a deletion ever crossing the break. On a line that starts outside a
      # span, pairs are deleted within the line, and a leftover unpaired backtick opens a span
      # the next line inherits. Fence, heading and table lines were dropped above, so their
      # backticks never reach this counter.
      if (line ~ /^[ \t]*$/) opn=0                     # a blank line closes any open span
      if (opn == 0) {
        while (match(line, /`[^`]*`/))
          line = substr(line,1,RSTART-1) " " substr(line,RSTART+RLENGTH)   # 6. code span
        while (match(line, /\]\([^)]*\)/))
          line = substr(line,1,RSTART-1) "] " substr(line,RSTART+RLENGTH)  # 7. link target
        while (match(line, /(https?:\/\/|mailto:)[^ \t)>]*/))
          line = substr(line,1,RSTART-1) " " substr(line,RSTART+RLENGTH)   # 8. url
      }
      bt=$0; opn=(opn + gsub(/`/, "", bt)) % 2         # count backticks on the ORIGINAL line
      print line
    }
    END { if (fm==1) exit 0 }                          # unterminated header: nothing printed
  '
}

# Tokens: every byte that is not an ASCII letter becomes a newline, fold to lowercase,
# drop empties and single characters. LC_ALL=C so no locale can widen the class.
tokens() { LC_ALL=C tr -c 'A-Za-z' '\n' < /dev/stdin | LC_ALL=C tr 'A-Z' 'a-z' | awk 'length($0)>1'; }

has_word() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

warnings=0
checked=0
for f in "$@"; do
  checked=$((checked+1))
  # The region is captured ONCE, because the status has to tell "nothing to check" from "I
  # could not read this". The tokenizer keeps ASCII letters only, so a non-Latin body scores
  # counted=0 exactly like a document whose prose region is empty; only the region itself
  # says which of the two happened. Non-whitespace CHARACTERS, not tokens, for that reason.
  # [:space:] under LC_ALL=C, so a form feed or a vertical tab counts as whitespace like a
  # space does. Honest bound: a NON-ASCII space (NBSP) is not stripped and reports UNREADABLE,
  # which is the truthful answer, the tokenizer cannot read that byte either.
  region="$(prose_region "$f")"
  region_chars="$(printf '%s' "$region" | LC_ALL=C tr -d '[:space:]' | LC_ALL=C wc -c | tr -d ' ')"
  n_de=0; n_en=0; n_fr=0; n_hr=0
  while IFS= read -r t; do
    if   has_word "$t" "$WORDS_DE"; then n_de=$((n_de+1))
    elif has_word "$t" "$WORDS_EN"; then n_en=$((n_en+1))
    elif has_word "$t" "$WORDS_FR"; then n_fr=$((n_fr+1))
    elif has_word "$t" "$WORDS_HR"; then n_hr=$((n_hr+1))
    fi
  done <<EOF
$(printf '%s\n' "$region" | tokens)
EOF
  counted=$((n_de+n_en+n_fr+n_hr))

  # detected: most hits, ties broken alphabetically so the output is deterministic.
  detected=none; best=-1
  for pair in "de:$n_de" "en:$n_en" "fr:$n_fr" "hr:$n_hr"; do
    c="${pair%%:*}"; v="${pair#*:}"
    if [ "$v" -gt "$best" ]; then best="$v"; detected="$c"; fi
  done
  [ "$counted" -eq 0 ] && detected=none

  # rival: the highest count among the codes other than the expected one.
  rival=0; rival_code=""
  for pair in "de:$n_de" "en:$n_en" "fr:$n_fr" "hr:$n_hr"; do
    c="${pair%%:*}"; v="${pair#*:}"
    [ "$c" = "$EXPECTED" ] && continue
    if [ "$v" -gt "$rival" ]; then rival="$v"; rival_code="$c"; fi
  done

  # The decision rule (contract C4). "More than half" is STRICT.
  #
  # RECORDED DEVIATION from C4 and from C3. C4 has ONE counted==0 case; this splits it in two.
  # C3 declares the status set closed at WARN | OK | LOW-EVIDENCE | NO-PROSE; UNREADABLE is a
  # FIFTH token. Both deviations are deliberate, and C3's list is raised as a plan correction
  # at the gate rather than edited here. No shipped consumer enumerates statuses (checked:
  # nothing in bin/, skills/ or agents/ greps a status token, and neither AGENTS.md nor
  # global/CLAUDE.md lists them), so the widening breaks nothing that exists.
  #
  # What UNREADABLE means, stated as the CODE behaves and not more narrowly: a region that is
  # non-empty but yields no countable token. Non-Latin script is the case that motivated it,
  # but it also fires on perfectly legible Latin prose holding none of the four lists' function
  # words, a Spanish sentence for instance, or a region that is only a place name and a year.
  # It carries no new language knowledge and can never warn: with lists for en de hr fr only,
  # the check can say it could not read the region, never that the language is wrong. NO-PROSE
  # keeps its old meaning, an empty region, and a reader seeing UNREADABLE knows that a line
  # without a warning is not evidence of a match.
  if   [ "$counted" -eq 0 ] && [ "$region_chars" -eq 0 ]; then st=NO-PROSE
  elif [ "$counted" -eq 0 ];            then st=UNREADABLE
  elif [ "$counted" -lt "$MIN_HITS" ];  then st=LOW-EVIDENCE
  elif [ $((rival * 2)) -gt "$counted" ]; then st=WARN; detected="$rival_code"
  else                                       st=OK
  fi

  fieldline="prose-language: $st $f expected=$EXPECTED detected=$detected counted=$counted de=$n_de en=$n_en fr=$n_fr hr=$n_hr"
  if [ "$st" = "WARN" ]; then
    warnings=$((warnings+1))
    echo "$fieldline" >&2
    echo "prose-language: warning only, nothing is blocked. $f reads as $detected while this project is set to $EXPECTED." >&2
  else
    echo "$fieldline"
  fi
done

echo "prose-language: $checked file(s) checked, $warnings warning(s); warnings never fail, exit 0."
exit 0
