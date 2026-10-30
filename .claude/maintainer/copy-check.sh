#!/usr/bin/env bash
# copy-check.sh <odeo-file> <source-file> [min-words]
# Maintainer tooling (PRD-003 R24, USR-029), never published.
# Finds every run of min-words (default 9) or more consecutive words that appears in both
# files, after lowercasing and turning every non-alphanumeric character into a space, so
# case, punctuation, sentence boundaries and line breaks do not hide a copy. It prints the
# matching stretches of the Odeo file; two copied runs that sit next to each other there
# print as one stretch even when they come from different places in the source. ASCII
# only: other characters act as word separators (a heuristic, named as one).
# Exit 0: no shared run. Exit 1: at least one (listed). Exit 2: usage error.
set -uo pipefail

MIN="${3:-9}"
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: copy-check.sh <odeo-file> <source-file> [min-words]" >&2
  exit 2
fi
[ -f "$1" ] || { echo "copy-check: not a file: $1" >&2; exit 2; }
[ -f "$2" ] || { echo "copy-check: not a file: $2" >&2; exit 2; }
case "$MIN" in ''|*[!0-9]*|0) echo "copy-check: min-words must be a positive integer" >&2; exit 2 ;; esac

# awk reads a bare argument like `x=y.md` as a variable assignment, so relative paths get ./
abs() { case "$1" in /*) printf '%s' "$1" ;; *) printf './%s' "$1" ;; esac; }
ODEO="$(abs "$1")"; SRC="$(abs "$2")"

# FILENAME, not FNR == NR, tells the files apart: with an empty source FNR == NR would
# misfile the Odeo file's words as source words.
awk -v min="$MIN" -v src="$SRC" '
  { line = tolower($0); gsub(/[^a-z0-9]+/, " ", line); n = split(line, w, " ")
    for (i = 1; i <= n; i++) { if (FILENAME == src) s[++ns] = w[i]; else o[++no] = w[i] } }
  END {
    for (i = 1; i + min - 1 <= ns; i++) {
      k = s[i]; for (j = 1; j < min; j++) k = k " " s[i + j]
      grams[k] = 1
    }
    for (i = 1; i + min - 1 <= no; i++) {
      k = o[i]; for (j = 1; j < min; j++) k = k " " o[i + j]
      if (k in grams) for (j = 0; j < min; j++) hit[i + j] = 1
    }
    found = 0; run = ""
    for (i = 1; i <= no + 1; i++) {
      if (i <= no && (i in hit)) run = (run == "" ? o[i] : run " " o[i])
      else if (run != "") { count[run]++; order[++nr] = run; run = "" }
    }
    for (r = 1; r <= nr; r++) if (!(order[r] in seen)) {
      seen[order[r]] = 1; found++
      printf "shared run (%d x in odeo file): %s\n", count[order[r]], order[r]
    }
    exit (found > 0 ? 1 : 0)
  }
' "$SRC" "$ODEO"
