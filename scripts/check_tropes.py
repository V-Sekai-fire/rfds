#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Trope density did not rise.

    python scripts/check_tropes.py                # report
    python scripts/check_tropes.py --base <ref>   # gate
    python scripts/check_tropes.py --self-test
"""
import argparse
import json
import pathlib
import os
import re
import subprocess
import sys
import textwrap

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import md_ast
import trope_nlp

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

TELLS = {
    "em_dash_join": re.compile(r"(?<=\S) [-—][-—]? "),
    "counting_announcement": re.compile(
        r"\b(in|for|on)\s+(two|three|four|five|six)\s+(ways|reasons|counts|things|senses)\b",
        re.I,
    ),
    "reasoning_leak": re.compile(
        r"\b(the reason .+? is that|the whole point .+? is that|what makes .+? is)\b",
        re.I,
    ),
    "pompous_copula": re.compile(r"\b(is|are)\s+what\s+(makes|proves|shows|says)\b", re.I),
    "exact_window": re.compile(r"\bthe exact (window|moment|shape|line|point|reason|failure)\b", re.I),
    "elided_predicate": re.compile(
        r"(?:(?<=\. )|(?<=\.\n)|(?<=^))"
        r"(?:It|They|This|That|We)\s+"
        r"(?:is|are|was|were|does|do|did|has|have|had|can|could|will|would|should|must|may)"
        r"\s+not\s*\.",
        re.I | re.M,
    ),
    "preamble": re.compile(
        r"\b(?:let me|let's (?:dive|unpack|break)|(?:it'?s|it is) worth (?:noting|mentioning)|"
        r"worth noting that|here'?s the thing)\b",
        re.I,
    ),
    "forced_sass": re.compile(
        r"\bhere'?s (?:the (?:truth|deal|catch|kicker)|what nobody|why that matters)\b"
        r"|\bhot take:|\band honestly\?|\bthen i realized:|(?:^|(?<=[.!?] ))the result\?",
        re.I | re.M,
    ),
    "buzzword": re.compile(
        r"\bdelv(?:e|es|ed|ing)\b|\btapestry\b|\bempower(?:s|ed|ing)?\b"
        r"|\bleverag(?:e|es|ed|ing)\b|\bfoster(?:s|ed|ing)? (?:a|an|the)\b",
        re.I,
    ),
    "cliche_opener": re.compile(
        r"\bin today'?s (?:fast-paced|digital|ever-changing)\b"
        r"|\bin the (?:dynamic|ever-evolving) (?:world|landscape) of\b"
        r"|\bas the world continues to evolve\b|\bshouting into the void\b|\bno fluff\b",
        re.I,
    ),
    "no_no_just": re.compile(r"\bNo [^.\n]{1,40}\. No [^.\n]{1,40}\. Just\b"),
    "the_real_x": re.compile(r"\bthat'?s the real (?!reason\b)[a-z]+", re.I),
    "tight_em_dash": re.compile("(?<=\\S)\u2014(?=\\S)"),
    "assistant_leak": re.compile(r"\bas an? (?:large )?language model\b", re.I),
    "welded_clauses": re.compile(
        r"(?<!when )(?<!where )(?<!unless )(?<!only when )"
        r"\b(?:A|An|The)\s+[a-z][a-z-]*\s+(?:is|are)\s+"
        r"(?!.*\b(?:that|which|when|where|if|whether|because)\b)"
        r"[^.;,\n]{3,60}\s+and\s+"
        r"(?:a|an|the|every|each|no|its|this)\s+(?:[a-z][a-z-]*\s+){1,2}"
        r"(?:is|are|says|does|has|have|carries|reads|means|makes|gets)\b",
        re.I,
    ),
}


_RFD_TEXTS = {}


def _rfd_fetch(rev, paths):
    args = ["mix", "rfd.text"] + (["--rev", rev] if rev else []) + paths
    out = subprocess.run(args, cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    if out.returncode != 0:
        raise SystemExit(f"FAIL mix rfd.text: {out.stderr.strip()[-300:]}")
    rows = (json.loads(l) for l in out.stdout.splitlines() if l.startswith("{"))
    return {r["path"]: r for r in rows}


def rfd_text(rev, path):
    """An RFD journal as the prose gates read it; one `mix rfd.text` per revision."""
    if rev not in _RFD_TEXTS:
        every = sorted(str(p.relative_to(ROOT)) for p in pathlib.Path(ROOT).glob("rfd/[0-9][0-9][0-9][0-9]-*.txn"))
        _RFD_TEXTS[rev] = _rfd_fetch(rev, every)
    path = str(path).replace("\\", "/")
    if path not in _RFD_TEXTS[rev]:
        _RFD_TEXTS[rev].update(_rfd_fetch(rev, [path]))
    return _RFD_TEXTS[rev][path]


def rfd_markdown(rev, path):
    t = rfd_text(rev, path)
    return t["markdown"] if t.get("found") else None


def is_journal(path):
    return re.match(r"^rfd/[0-9]{4}-[^/]+\.txn$", str(path).replace("\\", "/")) is not None


FILE_PATTERNS = (
    re.compile(r"^rfd/[0-9]{4}-[^/]+\.(exs|txn)$"),
    re.compile(r"^rfd/[^/]+/(README|DETAILS)\.md$"),
    re.compile(r"^logbook/.+\.md$"),
)


def in_scope(path: str) -> bool:
    p = path.replace("\\", "/")
    return any(pat.match(p) for pat in FILE_PATTERNS)


def count_tropes(text: str) -> tuple[int, dict[str, int]]:
    readable = md_ast.prose(text, tables=False)
    per = {name: len(rx.findall(readable)) for name, rx in TELLS.items()}
    per.update(trope_nlp.count(text))
    return sum(per.values()), per


def non_blank_lines(text: str) -> int:
    return sum(1 for line in text.splitlines() if line.strip())


def source_prose(text: str) -> str:
    bodies = (textwrap.dedent(b) for b in md_ast.HEREDOC.findall(text))
    return re.sub(r"(?m)^:: .*$", "", "\n\n".join(bodies))


def density(text: str, source: bool = False) -> float:
    if source:
        text = source_prose(text)
    n = non_blank_lines(text)
    hits, _ = count_tropes(text)
    return (100.0 * hits / n) if n else 0.0


def git_show(ref: str, path: str) -> str | None:
    out = subprocess.run(
        ["git", "show", f"{ref}:{path}"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=ROOT,
    )
    return out.stdout if out.returncode == 0 else None


def rendered(path: str) -> bool:
    m = re.match(r"^rfd/([0-9]{4}-[^/]+)/(README|DETAILS)\.md$", path.replace("\\", "/"))
    return bool(m) and any(os.path.isfile(os.path.join(ROOT, "rfd", m.group(1) + x))
                           for x in (".exs", ".txn"))


def prior_text(base: str, path: str) -> str:
    text = git_show(base, path)
    if text is not None:
        return text
    m = re.match(r"^rfd/([0-9]{4}-[^/]+)\.exs$", path.replace("\\", "/"))
    if not m:
        return ""
    return "".join(git_show(base, f"rfd/{m.group(1)}/{n}") or ""
                   for n in ("README.md", "DETAILS.md"))


def changed_files(base: str) -> list[str]:
    out = subprocess.run(
        ["git", "diff", "--name-only", f"{base}...HEAD"],
        capture_output=True,
        text=True,
        cwd=ROOT,
        check=True,
    )
    return [p for p in out.stdout.splitlines() if in_scope(p) and not rendered(p)]


def gate(base: str) -> int:
    changed = changed_files(base)
    if not changed:
        print("0 changed prose file(s) in scope.")
        return 0

    fails = 0
    for path in changed:
        full = os.path.join(ROOT, path)
        if not os.path.isfile(full):
            continue
        if is_journal(path):
            d_now = density(rfd_markdown(None, path) or "")
            d_was = density(rfd_markdown(base, path) or "")
        else:
            d_now = d_was = None
        after = "" if is_journal(path) else open(full, encoding="utf-8").read()
        before = "" if is_journal(path) else prior_text(base, path)
        exs = path.endswith(".exs")
        if d_now is None:
            d_now = density(after, exs)
            d_was = density(before, exs and bool(md_ast.HEREDOC.search(before)))
        if d_now > d_was + 0.001:
            hits, per = count_tropes(after)
            top = ", ".join(f"{k}={v}" for k, v in per.items() if v)
            print(f"  FAIL {path}  {d_now:.2f}% was {d_was:.2f}%  ({hits} hits: {top})")
            fails += 1
        else:
            print(f"  ok   {path}  {d_now:.2f}% was {d_was:.2f}%")
    print(f"{fails} of {len(changed)} scoped file(s) rose above their prior density.")
    return 1 if fails else 0


def report() -> int:
    scanned = 0
    for dirpath, _, filenames in os.walk(os.path.join(ROOT, "rfd")):
        for name in filenames:
            if name in ("README.md", "DETAILS.md") or in_scope(
                    os.path.relpath(os.path.join(dirpath, name), ROOT)):
                rel = os.path.relpath(os.path.join(dirpath, name), ROOT)
                d = density(open(os.path.join(dirpath, name), encoding="utf-8").read(),
                            name.endswith(".exs"))
                if d > 0:
                    print(f"  {d:5.2f}%  {rel}")
                scanned += 1
    for name in sorted(os.listdir(os.path.join(ROOT, "logbook"))):
        if name.endswith(".md"):
            rel = os.path.join("logbook", name)
            d = density(open(os.path.join(ROOT, rel), encoding="utf-8").read())
            if d > 0:
                print(f"  {d:5.2f}%  {rel}")
            scanned += 1
    print(f"{scanned} scoped file(s) scanned.")
    return 0


def self_test() -> int:
    controls = [
        ("em-dash between clauses", "The gate ran — every control fired.", "em_dash_join", 1),
        ("hyphen range unchanged", "The window is day 11-14.", "em_dash_join", 0),
        (
            "markdown bullet is not a join",
            "See the deployment notes:\n\n- first item\n- second item\n- third item\n",
            "em_dash_join",
            0,
        ),
        (
            "a dataset table's cells are records, not prose",
            "| id | title |\n|---|---|\n| `a1` | Walking in CORK - 4K 60fps |\n",
            "em_dash_join",
            0,
        ),
        (
            "prose after a dataset table is still read",
            "| id | title |\n|---|---|\n| `a1` | Walking in CORK |\n\nThe gate ran — every control fired.\n",
            "em_dash_join",
            1,
        ),
        ("counting announcement", "It shapes the checks in three ways.", "counting_announcement", 1),
        ("prose that mentions three ways", "Three ways lead there.", "counting_announcement", 0),
        ("reasoning leak", "The reason it holds is that quorum tolerates one down.", "reasoning_leak", 1),
        ("pompous copula", "The second check is what proves the restart.", "pompous_copula", 1),
        ("plain because", "The second check proves the restart because a stale write would fail.", "pompous_copula", 0),
        ("exact window", "That is the exact window in which a shard can stall.", "exact_window", 1),
        (
            "a sentence that is only a negated auxiliary",
            "The card should carry the whole graph. It does not.",
            "elided_predicate",
            1,
        ),
        (
            "the predicate spelled out",
            "The card should carry the whole graph. It carries eleven of nineteen operators.",
            "elided_predicate",
            0,
        ),
        (
            "ellipsis with its antecedent in the same sentence",
            "The forwards are arithmetic where the inverses are not.",
            "elided_predicate",
            0,
        ),
        (
            "a negated auxiliary that still has a predicate",
            "It does not divide by 24.",
            "elided_predicate",
            0,
        ),
        ("negative parallelism, two sentences", "It is not a pipeline. It is a star.", "negative_parallelism", 1),
        ("negative parallelism, comma", "It's not bold, it's backwards.", "negative_parallelism", 1),
        ("not just X but Y", "The gate is not just a check but a ratchet.", "negative_parallelism", 1),
        ("the question isn't", "The question isn't whether to optimize.", "negative_parallelism", 1),
        ("a plain negation is not a parallelism", "The gate is not wired into CI. Wire it in the next change.", "negative_parallelism", 0),
        ("semicolon join", "One beta holds the features; every nongoal is abandoned.", "clause_semicolon", 1),
        ("two sentences instead", "One beta holds the features. Every nongoal is abandoned.", "clause_semicolon", 0),
        ("a semicolon in a code span is not prose", "Run `a; b` to chain.", "clause_semicolon", 0),
        ("preamble", "Worth noting that the gate is red.", "preamble", 1),
        ("no preamble", "The gate is red.", "preamble", 0),
        ("pompous verb", "The table serves as the index.", "pompous_verb", 1),
        ("plain is", "The table is the index.", "pompous_verb", 0),
        ("ta-da phrase", "But here's the truth: the gate is red.", "forced_sass", 1),
        ("ta-da question", "The gate failed. The result? A red build.", "forced_sass", 1),
        ("plain but", "But the gate is red.", "forced_sass", 0),
        ("a result in a sentence", "The result is a red build.", "forced_sass", 0),
        ("buzzword delve", "We delve into the gate.", "buzzword", 1),
        ("buzzword leverage", "It leverages the cache.", "buzzword", 1),
        ("plain verb", "We read the gate.", "buzzword", 0),
        ("cliche opener", "In today's fast-paced digital landscape the gate runs.", "cliche_opener", 1),
        ("plain opener", "The gate runs on every push.", "cliche_opener", 0),
        ("no no just", "No config. No setup. Just run it.", "no_no_just", 1),
        ("one no is not the pattern", "No config is needed. Just run it.", "no_no_just", 0),
        ("the real unlock", "That's the real unlock.", "the_real_x", 1),
        ("the real reason is exempt", "That's the real reason it failed.", "the_real_x", 0),
        ("tight em-dash", "The gate ran\u2014every control fired.", "tight_em_dash", 1),
        ("spaced em-dash is the other gate", "The gate ran \u2014 every control fired.", "tight_em_dash", 0),
        ("assistant leak", "As a large language model, I cannot run it.", "assistant_leak", 1),
        ("not just X, also Y", "It's not just a check. It's also a ratchet.", "negative_parallelism", 1),
        ("a semicolon between list items is not a join", "See RFD66606-2340, the campus; RFD66606-2358, the party; RFD66606-2359, the shop.", "clause_semicolon", 0),
        ("a verb serving something is not serves as", "The server serves assets to clients.", "pompous_verb", 0),
        ("negation answered in the next sentence", "It is not a pipeline. It is a star.", "negative_parallelism", 1),
        ("a negation with no reply", "The gate is not wired into CI. Wire it in the next change.", "negative_parallelism", 0),
        ("personified abstraction", "Nothing chose which gates a change needed.", "personified_abstraction", 1),
        ("a person chooses", "The operator chose which gates a change needed.", "personified_abstraction", 0),
        ("manufactured emphasis fragment", "A hidden director plans the day. Two boxes. That is the whole gap.", "emphasis_fragment", 1),
        ("a short imperative is not a fragment", "The gate is red. Fix it.", "emphasis_fragment", 0),
        ("adjective triplet", "The system is fast, reliable, and scalable.", "adjective_triplet", 1),
        ("two adjectives are not a triplet", "The system is fast and reliable.", "adjective_triplet", 0),
        (
            "two clauses welded by a bare and",
            "A release is one flat namespace and every build tree says fdbserver.",
            "welded_clauses",
            1,
        ),
        (
            "the same point subordinated",
            "A release is one flat namespace for every build tree.",
            "welded_clauses",
            0,
        ),
        (
            "a comma before and is ordinary English",
            "The account is five characters, and the corpus is 3.2 GB.",
            "welded_clauses",
            0,
        ),
        (
            "a compound predicate is not two clauses",
            "A permission is not a preference and cannot be granted sideways.",
            "welded_clauses",
            0,
        ),
        (
            "and inside a subordinate clause",
            "A build is the confirmation that auth and the endpoint are reachable.",
            "welded_clauses",
            0,
        ),
    ]
    one, two = "The gate ran -- every control fired.\n", "    tree |-- a/\n"
    deep = "".join(f'    {f} ~S"""\n' + textwrap.indent(b, "    ") + '    """\n'
                   for f, b in (("decision", one), ("problem", two)))
    deep = 'defmodule R do\n  rfd 1, "t" do\n' + deep + "  end\nend\n"
    flat = textwrap.indent(":: decision\n" + one + ":: problem\n" + two, "  ")
    flat = 'rfd 1, "t", :ideation do\n  prose ~S"""\n' + flat + '  """\nend\n'
    sources = [
        ("a tell in an indented heredoc is counted", density(deep, True) > 0),
        ("an RFD source's density ignores its wrapper", density(deep, True) == density(flat, True)),
    ]
    fails = 0
    for label, ok in sources:
        if not ok:
            print(f"  FAIL {label}")
            fails += 1
    for label, text, tell, expected in controls:
        _, per = count_tropes(text)
        got = per[tell]
        if got != expected:
            print(f"  FAIL {label}: {tell} expected {expected}, got {got}")
            fails += 1
    total = len(controls) + len(sources)
    if fails:
        print(f"{fails} of {total} controls failed")
        return 1
    print(f"ok   {total} of {total} controls fired in both directions")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", help="git ref to compare against (fail on density rise)")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    if a.base:
        return gate(a.base)
    return report()


if __name__ == "__main__":
    sys.exit(main())
