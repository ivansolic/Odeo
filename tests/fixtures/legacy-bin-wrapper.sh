#!/usr/bin/env bash
# Fixture: the forwarding wrapper Odeo 0.3.0 to 0.3.5 shipped in bin/ for every program. The
# repo no longer ships bin/, but those versions can still sit in a user's plugin cache, where a
# 0.2.x git hook or ~/bin shim reaches the program through this wrapper. Tests copy it under the
# program's name into a fake cache. Same body as the shipped wrappers, by name instead of
# a hardcoded one.
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  t="$(readlink "$src")"
  case "$t" in /*) src="$t" ;; *) src="$(dirname "$src")/$t" ;; esac
done
exec "$(cd "$(dirname "$src")/.." && pwd)/scripts/$(basename "$src")" "$@"
