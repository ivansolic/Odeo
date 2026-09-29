#!/usr/bin/env python3
# Compatibility wrapper: the program lives in scripts/token-report.py. bin/ stays for one
# release so callers written for Odeo 0.2.x still find it; it is removed later. Written in
# Python (unlike the other wrappers) so `python3 bin/token-report.py` keeps working.
import os
import sys

here = os.path.dirname(os.path.realpath(__file__))
target = os.path.join(os.path.dirname(here), "scripts", "token-report.py")
os.execv(target, [target] + sys.argv[1:])
