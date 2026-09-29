#!/usr/bin/env bash
# Compatibility wrapper: the program lives in scripts/prose-language-check.sh. bin/ stays for one release so
# git hooks and ~/bin shims written by Odeo 0.2.x still find it; it is removed later.
# Symlinks are followed first (an old install.sh link install points ~/bin here).
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  t="$(readlink "$src")"
  case "$t" in /*) src="$t" ;; *) src="$(dirname "$src")/$t" ;; esac
done
exec "$(cd "$(dirname "$src")/.." && pwd)/scripts/prose-language-check.sh" "$@"
