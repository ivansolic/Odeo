#!/usr/bin/env bash
# prose-language-check.sh , SOFT check that a generated document's prose reads as the
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
EXPECTED="$(CLAUDE_GLOBAL_CONFIG="${CLAUDE_GLOBAL_CONFIG:-$HOME/.claude/CLAUDE.md}" bash "$RESOLVER" "$PROJECT_DIR" 2>/dev/null)" \
  || die2 "resolver failed for $PROJECT_DIR"
case "$EXPECTED" in en|de|fr|hr) : ;; *) die2 "resolver returned an unknown code: '$EXPECTED'" ;; esac

# ---------------------------------------------------------------------------
# The prose region (contract C1). Steps 1 to 5 are line level, 6 to 8 inline.
# No exclusion consumes more than the construct it names.
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
      print line
    }
    END { if (fm==1) exit 0 }                          # unterminated header: nothing printed
  ' | awk 'BEGIN{ RS="\x01" }
    {
      line=$0
      while (match(line, /`[^`]*`/)) \
        line = substr(line,1,RSTART-1) " " substr(line,RSTART+RLENGTH)   # 6. shortest span
      while (match(line, /\]\([^)]*\)/)) \
        line = substr(line,1,RSTART-1) "] " substr(line,RSTART+RLENGTH)  # 7. link target
      while (match(line, /(https?:\/\/|mailto:)[^ \t)>]*/)) \
        line = substr(line,1,RSTART-1) " " substr(line,RSTART+RLENGTH)   # 8. url
      print line
    }
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
  n_de=0; n_en=0; n_fr=0; n_hr=0
  while IFS= read -r t; do
    if   has_word "$t" "$WORDS_DE"; then n_de=$((n_de+1))
    elif has_word "$t" "$WORDS_EN"; then n_en=$((n_en+1))
    elif has_word "$t" "$WORDS_FR"; then n_fr=$((n_fr+1))
    elif has_word "$t" "$WORDS_HR"; then n_hr=$((n_hr+1))
    fi
  done <<EOF
$(prose_region "$f" | tokens)
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
  if   [ "$counted" -eq 0 ];            then st=NO-PROSE
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
