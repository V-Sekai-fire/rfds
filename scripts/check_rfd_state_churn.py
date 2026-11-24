#!/usr/bin/env python3
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Refuse a change that abandons or deletes more than KILL_LIMIT live RFDs.

    python scripts/check_rfd_state_churn.py --base origin/main
    python scripts/check_rfd_state_churn.py --history 30 --ref origin/main
    python scripts/check_rfd_state_churn.py --self-test
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile

KILL_LIMIT = 3
RFD_GLOB = "rfd/*.exs"
HEAD_RE = re.compile(r"^\s*rfd\s*\(?\s*(\d+)\s*,(.*?),\s*:([a-z_]+)\s*\)?\s+do\b", re.M | re.S)
BARE_RE = re.compile(r'^\s*rfd\s+(\d+)\s*,\s*"(?:[^"\\]|\\.)*"\s+do\b', re.M)
STATE_LINE_RE = re.compile(r"^\s*state\s+:([a-z_]+)", re.M)


def git(*args: str, cwd: str | None = None, check: bool = True) -> str:
    out = subprocess.run(
        ["git", *args], cwd=cwd, capture_output=True, text=True, check=False
    )
    if check and out.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)}: {out.stderr.strip()}")
    return out.stdout


def header(text: str) -> tuple[int, str] | None:
    m = HEAD_RE.search(text)
    if m:
        return int(m.group(1)), m.group(3)
    m, st = BARE_RE.search(text), STATE_LINE_RE.search(text)
    return (int(m.group(1)), st.group(1)) if m and st else None


def state_of(text: str) -> str | None:
    h = header(text)
    return h[1] if h else None


def states(rev: str, paths: list[str], cwd: str | None) -> tuple[dict, list[str]]:
    by_num: dict[int, tuple[str, str]] = {}
    unread = []
    for path in paths:
        out = subprocess.run(
            ["git", "show", f"{rev}:{path}"], cwd=cwd, capture_output=True, text=True
        )
        if out.returncode != 0:
            continue
        h = header(out.stdout)
        if h is None:
            unread.append(f"{rev}:{path}")
        else:
            by_num[h[0]] = (h[1], path)
    return by_num, unread


def classify(old: str, new: str, cwd: str | None = None) -> dict[str, list[str]]:
    names = git(
        "diff", "--name-only", "--no-renames", old, new, "--", RFD_GLOB, cwd=cwd
    ).split()
    before, u1 = states(old, names, cwd)
    after, u2 = states(new, names, cwd)
    res: dict[str, list[str]] = {"kill": [], "revive": [], "reap": [], "unread": u1 + u2}
    for num, (was, path) in sorted(before.items()):
        now = after.get(num, (None, None))[0]
        if was != "abandoned" and now in (None, "abandoned"):
            res["kill"].append(path)
        elif was == "abandoned" and now is None:
            res["reap"].append(path)
        elif was == "abandoned" and now != "abandoned":
            res["revive"].append(path)
    return res


def verdict(res: dict[str, list[str]]) -> tuple[bool, list[str]]:
    lines = []
    for k in ("kill", "revive", "reap", "unread"):
        lines.append(f"{k}: {len(res[k])}")
        lines += [f"  {p}" for p in res[k]]
    ok = len(res["kill"]) <= KILL_LIMIT and not res["unread"]
    if len(res["kill"]) > KILL_LIMIT:
        lines.append(
            f"FAIL: {len(res['kill'])} live RFDs abandoned or deleted, limit {KILL_LIMIT}. "
            "Cut scope in the plan's list and leave the RFDs in their state (RFD66606-1000)."
        )
    if res["unread"]:
        lines.append(f"FAIL: {len(res['unread'])} RFD sources with no readable state")
    return ok, lines


def run_base(base: str) -> int:
    mb = git("merge-base", base, "HEAD").strip()
    ok, lines = verdict(classify(mb, "HEAD"))
    print("\n".join(lines))
    print("PASS" if ok else "")
    return 0 if ok else 1


def run_history(days: int, ref: str) -> int:
    log = git(
        "log", ref, f"--since={days}.days", "--no-merges", "--format=%H %h %ad %s",
        "--date=short", "--", RFD_GLOB,
    ).splitlines()
    total = refused_lines = 0
    refused = []
    kills = revives = unread = 0
    for row in log:
        full, short, date, subj = row.split(" ", 3)
        num = git("show", "--numstat", "--format=", full, "--", RFD_GLOB)
        lines = sum(
            int(a) + int(b)
            for a, b, *_ in (r.split("\t") for r in num.splitlines() if r)
            if a.isdigit() and b.isdigit()
        )
        total += lines
        parent = git("rev-list", "--parents", "-n1", full).split()
        if len(parent) < 2:
            continue
        res = classify(parent[1], full)
        unread += len(res["unread"])
        kills += len(res["kill"])
        revives += len(res["revive"])
        if len(res["kill"]) > KILL_LIMIT:
            refused.append((short, date, len(res["kill"]), lines, subj))
            refused_lines += lines
    print(f"window: {days} days on {ref}, {len(log)} commits touching {RFD_GLOB}")
    print(f"RFD lines changed: {total}")
    print(f"kills: {kills}  revives: {revives}  unread: {unread}  limit: {KILL_LIMIT}")
    print(f"refused commits: {len(refused)}, lines {refused_lines} "
          f"({100 * refused_lines / max(total, 1):.1f}%)")
    for short, date, k, n, subj in refused:
        print(f"  {short} {date} kills={k} lines={n} {subj}")
    return 0


def self_test() -> int:
    def rfd(n: int, state: str, body: str = "x") -> str:
        return f'use RFD.DSL\n\nrfd {n}, "Title {n}", :{state} do\n  # {body}\nend\n'

    failures = 0

    def expect(name: str, want_ok: bool, edits: dict[str, str | None]) -> None:
        nonlocal failures
        with tempfile.TemporaryDirectory() as d:
            git("init", "-q", cwd=d)
            git("config", "user.email", "t@t", cwd=d)
            git("config", "user.name", "t", cwd=d)
            os.makedirs(os.path.join(d, "rfd"))
            for i in range(10):
                with open(os.path.join(d, "rfd", f"{2000 + i}-t.exs"), "w") as f:
                    f.write(rfd(2000 + i, "abandoned" if i == 9 else "discussion"))
            git("add", ".", cwd=d)
            git("commit", "-qm", "base", cwd=d)
            for name_, text in edits.items():
                p = os.path.join(d, "rfd", name_)
                if text is None:
                    os.remove(p)
                else:
                    with open(p, "w") as f:
                        f.write(text)
            git("add", "-A", cwd=d)
            git("commit", "-qm", "change", cwd=d)
            ok, _ = verdict(classify("HEAD~1", "HEAD", cwd=d))
            good = ok == want_ok
            failures += 0 if good else 1
            print(f"{'ok ' if good else 'BAD'} {name}: want {'pass' if want_ok else 'fail'}")

    f = lambda i: f"{2000 + i}-t.exs"  # noqa: E731
    expect("abandon four live RFDs", False,
           {f(i): rfd(2000 + i, "abandoned") for i in range(4)})
    expect("abandon three live RFDs", True,
           {f(i): rfd(2000 + i, "abandoned") for i in range(3)})
    expect("delete four live RFDs", False, {f(i): None for i in range(4)})
    expect("two abandoned, two deleted", False,
           {f(0): rfd(2000, "abandoned"), f(1): rfd(2001, "abandoned"),
            f(2): None, f(3): None})
    expect("edit nine RFD bodies, no state change", True,
           {f(i): rfd(2000 + i, "discussion", "edited") for i in range(9)})
    expect("defer four RFDs to prediscussion", True,
           {f(i): rfd(2000 + i, "prediscussion") for i in range(4)})
    expect("revive the abandoned RFD", True, {f(9): rfd(2009, "discussion")})
    expect("reap the abandoned stub", True, {f(9): None})
    expect("state that does not parse", False, {f(0): "use RFD.DSL\n# no header\n"})
    expect("a title with an escaped quote still parses", True,
           {f(0): 'rfd 2000, "A \\"quoted\\" title", :discussion do\nend\n'})
    expect("rename four live RFDs", True,
           {**{f(i): None for i in range(4)},
            **{f"{2000 + i}-renamed.exs": rfd(2000 + i, "discussion") for i in range(4)}})
    expect("rename four and abandon them", False,
           {**{f(i): None for i in range(4)},
            **{f"{2000 + i}-renamed.exs": rfd(2000 + i, "abandoned") for i in range(4)}})
    expect("a wrapped header inside defmodule parses", True,
           {f(0): 'defmodule R do\n  use RFD.DSL\n  rfd 2000,\n    "A " <>\n      "b",\n'
                  '    :discussion do\n  end\nend\n'})
    expect("a parenthesised header parses", True,
           {f(0): 'rfd(\n  2000,\n  "A, b",\n  :discussion\n) do\nend\n'})
    expect("a state line under a bare header parses", True,
           {f(0): 'rfd 2000, "t" do\n  state :discussion\nend\n'})
    print(f"{15 - failures}/15 controls hold")
    return 0 if failures == 0 else 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--base", help="compare HEAD with its merge base against this ref")
    g.add_argument("--history", type=int, metavar="DAYS", help="back-test the window")
    g.add_argument("--self-test", action="store_true")
    ap.add_argument("--ref", default="HEAD", help="ref for --history")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    if a.history:
        return run_history(a.history, a.ref)
    return run_base(a.base)


if __name__ == "__main__":
    sys.exit(main())
