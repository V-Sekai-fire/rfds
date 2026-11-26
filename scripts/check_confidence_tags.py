#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Fail any confidence tag whose word is off RFD66606-2295's scale or whose p falls outside the word's band.

The bands are read from RFD66606-2295's source, so the scale and this gate cannot disagree.
    python scripts/check_confidence_tags.py [paths...]
    python scripts/check_confidence_tags.py --self-test
"""
import pathlib
import json
import subprocess
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "rfd" / "2295-agent-replies-state-calibrated-confidence.txn"
TAG = re.compile(r"\(([a-z][a-z ]*?), p=(\d\.\d\d)\)")
ROW = re.compile(r"^\| ([a-z ]+?) \| (\d\.\d\d) \| (\d\.\d\d) \|$")


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


def read_bands(text: str) -> dict:
    bands = {m.group(1): (float(m.group(2)), float(m.group(3)))
             for m in (ROW.match(line.strip()) for line in text.splitlines()) if m}
    if not bands:
        raise SystemExit(f"FAIL no scale table in {SOURCE}")
    return bands


def problems(text: str, bands: dict, where: str) -> list:
    out = []
    top = max(hi for _, hi in bands.values())
    for m in TAG.finditer(text):
        word, p = m.group(1), float(m.group(2))
        if word not in bands:
            out.append(f"{where}: unknown word {word!r} in {m.group(0)}")
            continue
        lo, hi = bands[word]
        if not (lo <= p < hi or (hi == top and p == top)):
            out.append(f"{where}: p={p:.2f} is outside {word!r} [{lo:.2f}, {hi:.2f}) in {m.group(0)}")
    return out


def read_text(path) -> str:
    rel = path.relative_to(ROOT) if path.is_absolute() else path
    if is_journal(rel):
        return rfd_markdown(None, str(rel)) or ""
    return path.read_text(encoding="utf-8")


def default_paths() -> list:
    return sorted(ROOT.glob("logbook/*.md")) + sorted(ROOT.glob("rfd/[0-9][0-9][0-9][0-9]-*.txn"))


def self_test(bands: dict) -> int:
    cases = [
        ("a correct tag passes", "It lands (likely, p=0.80).", 0),
        ("an unknown word fails", "It lands (probable, p=0.80).", 1),
        ("a number outside its band fails", "It lands (likely, p=0.95).", 1),
        ("1.00 is inside almost certain", "It lands (almost certain, p=1.00).", 0),
    ]
    failed = 0
    for name, text, want in cases:
        got = len(problems(text, bands, "planted"))
        ok = got == want
        failed += 0 if ok else 1
        print(f"{'PASS' if ok else 'FAIL'} {name}: {got} problem(s), wanted {want}")
    return 1 if failed else 0


def main(argv: list) -> int:
    bands = read_bands(read_text(SOURCE))
    if "--self-test" in argv:
        return self_test(bands)
    paths = [pathlib.Path(a) for a in argv] or default_paths()
    found = []
    tags = 0
    for path in paths:
        text = read_text(path)
        tags += len(TAG.findall(text))
        found += problems(text, bands, str(path.relative_to(ROOT) if path.is_absolute() else path))
    for line in found:
        print(f"FAIL {line}")
    print(f"{len(paths)} file(s), {tags} tag(s), {len(found)} problem(s)")
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
