#!/usr/bin/env python3
#
# token-report.py, per-agent token/cost report for a Claude Code session.
#
# Parses a session transcript (.jsonl) and sums token usage per agent: the main
# session plus each dispatched subagent. Prints a table (messages, input, output,
# cache) and totals. Token counts always; a dollar column ONLY when you pass both
# prices. Nothing about models or prices is baked in, the tiers and their prices
# live with the human and the tier map (AGENTS.md), never in this script.
#
#   0 = report printed   1 = no usage data found   2 = usage error
#
# Usage:
#   token-report.py <session.jsonl>            report one transcript
#   token-report.py <dir>                      newest *.jsonl in <dir>
#   token-report.py                            newest in ~/.claude/projects/<cwd>/
#   token-report.py <path> --input-price 3 --output-price 15   add a $ column
#
# Prices are dollars per million tokens; the input price applies to input plus
# cache-creation plus cache-read tokens (all billed as input).

import sys
import os
import json
import argparse
from pathlib import Path
from collections import defaultdict


def err(msg):
    """Print an error with the script-name prefix and return usage exit code."""
    print(f"token-report: {msg}", file=sys.stderr)
    return 2


def resolve_transcript(arg):
    """Turn the path argument (file, dir, or None) into a concrete .jsonl file.

    None -> newest transcript under ~/.claude/projects/<normalized-cwd>/.
    A directory -> its newest *.jsonl. A file -> itself. Returns a Path or None.
    """
    if arg is None:
        normalized = os.getcwd().replace("/", "-")
        base = Path.home() / ".claude" / "projects" / normalized
        if not base.is_dir():
            return None
        return _newest_jsonl(base)
    p = Path(arg)
    if p.is_dir():
        return _newest_jsonl(p)
    if p.is_file():
        return p
    return None


def _newest_jsonl(directory):
    """Return the most recently modified *.jsonl in a directory, or None."""
    candidates = list(directory.glob("*.jsonl"))
    if not candidates:
        return None
    return max(candidates, key=lambda f: f.stat().st_mtime)


def new_usage():
    return {
        "input": 0,
        "output": 0,
        "cache_creation": 0,
        "cache_read": 0,
        "messages": 0,
        "description": None,
    }


def _int(value):
    """Coerce a usage field to a non-negative int; anything odd becomes 0."""
    try:
        return max(0, int(value))
    except (TypeError, ValueError):
        return 0


def add_usage(bucket, usage):
    """Accumulate one message's usage block into a bucket (shape-tolerant)."""
    if not isinstance(usage, dict):
        usage = {}
    bucket["messages"] += 1
    bucket["input"] += _int(usage.get("input_tokens"))
    bucket["output"] += _int(usage.get("output_tokens"))
    bucket["cache_creation"] += _int(usage.get("cache_creation_input_tokens"))
    bucket["cache_read"] += _int(usage.get("cache_read_input_tokens"))


def parse(path):
    """Read a transcript and return (main_usage, {agent_id: usage})."""
    main = new_usage()
    subagents = defaultdict(new_usage)
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
            except (ValueError, TypeError):
                continue  # a malformed line is skipped, never fatal
            if not isinstance(data, dict):
                continue  # a valid-JSON non-object (array/scalar) is not a turn
            # Main session assistant turns carry usage on the message.
            if data.get("type") == "assistant" and isinstance(data.get("message"), dict):
                add_usage(main, data["message"].get("usage", {}))
            # Subagent turns arrive as tool results tagged with an agentId.
            if data.get("type") == "user":
                result = data.get("toolUseResult")
                if isinstance(result, dict) and "usage" in result and "agentId" in result:
                    bucket = subagents[result["agentId"]]
                    add_usage(bucket, result["usage"])
                    if bucket["description"] is None:
                        prompt = result.get("prompt", "") or ""
                        first = prompt.split("\n", 1)[0][:40] if prompt else ""
                        bucket["description"] = first
    return main, dict(subagents)


def cost(usage, input_price, output_price):
    """Estimated dollars: input+cache billed at input price, output at output price."""
    billed_input = usage["input"] + usage["cache_creation"] + usage["cache_read"]
    return billed_input * input_price / 1_000_000 + usage["output"] * output_price / 1_000_000


def fmt(n):
    return f"{n:,}"


def print_report(main, subagents, input_price, output_price):
    """Print the per-agent table and totals. Cost column only when priced."""
    priced = input_price is not None and output_price is not None

    def line(label, msgs, inp, out, cache, cst):
        # Two-space join so columns never merge, even when a value overflows.
        cells = [f"{str(label)[:40]:<40}", f"{msgs:>6}", f"{inp:>15}",
                 f"{out:>15}", f"{cache:>17}"]
        if priced:
            cells.append(f"{cst:>11}")
        return "  ".join(cells)

    header = line("agent", "msgs", "input", "output", "cache", "cost")
    sep = "-" * len(header)
    print(sep)
    print(header)
    print(sep)

    def row(label, usage):
        cst = None
        if priced:
            cst = "$" + format(cost(usage, input_price, output_price), ".2f")
        print(line(label, usage["messages"], fmt(usage["input"]),
                   fmt(usage["output"]),
                   fmt(usage["cache_read"] + usage["cache_creation"]), cst))

    row("main", main)
    for agent_id in sorted(subagents):
        usage = subagents[agent_id]
        label = usage["description"] or agent_id
        row(label, usage)

    total = new_usage()
    for usage in [main, *subagents.values()]:
        for key in ("input", "output", "cache_creation", "cache_read", "messages"):
            total[key] += usage[key]
    print(sep)
    row("TOTAL", total)
    print(sep)
    billed_input = total["input"] + total["cache_creation"] + total["cache_read"]
    print(f"total tokens (input incl cache + output): {fmt(billed_input + total['output'])}")
    if priced:
        print(f"estimated cost: ${cost(total, input_price, output_price):.2f}"
              f"  (at ${input_price}/${output_price} per M input/output)")
    else:
        print("tokens only; pass --input-price and --output-price for a cost column.")


def main(argv):
    parser = argparse.ArgumentParser(
        prog="token-report.py", add_help=True,
        description="Per-agent token/cost report for a Claude Code session transcript.")
    parser.add_argument("path", nargs="?", default=None,
                        help="a .jsonl transcript, a directory (newest is used), "
                             "or omit for ~/.claude/projects/<cwd>/")
    parser.add_argument("--input-price", type=float, default=None,
                        help="dollars per million input tokens (incl cache)")
    parser.add_argument("--output-price", type=float, default=None,
                        help="dollars per million output tokens")
    args = parser.parse_args(argv)

    if (args.input_price is None) != (args.output_price is None):
        return err("pass BOTH --input-price and --output-price, or neither")

    transcript = resolve_transcript(args.path)
    if transcript is None:
        return err("no transcript found; give a .jsonl path or a directory")

    try:
        main_usage, subagents = parse(transcript)
    except OSError as exc:
        return err(f"cannot read {transcript}: {exc.strerror or exc}")
    if main_usage["messages"] == 0 and not subagents:
        print(f"token-report: no usage data in {transcript}", file=sys.stderr)
        return 1

    print(f"token-report: {transcript}")
    print_report(main_usage, subagents, args.input_price, args.output_price)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
