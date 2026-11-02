# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Propose which capability tokens an RFD spends, by testing its prose against token descriptions.

A candidate pair is an RFD paragraph window and a capability token another RFD provides. A pair
is kept when the window and the token's description share content lemmas, then the NLI model
judges whether the window says the RFD uses what the token names. Output is proposals only.
"""
import argparse
import glob
import json
import os
import re
import sys

import spacy
import torch

sys.path.insert(0, os.path.dirname(__file__))
from rfd_ast import NLI, prose  # noqa: E402

STOP = {"rfd", "rung", "step", "slice", "native", "build", "built", "guest", "guests", "the", "one", "use"}


def lemmas(doc):
    return {t.lemma_.lower() for t in doc if t.pos_ in ("NOUN", "PROPN", "VERB", "ADJ")
            and not t.is_stop and len(t.lemma_) > 2 and t.lemma_.lower() not in STOP}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rfds", required=True)
    ap.add_argument("--registry", nargs="+", required=True)
    ap.add_argument("--serials", nargs="+", type=int, required=True)
    ap.add_argument("--nli", required=True)
    ap.add_argument("--top", type=int, default=6)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    reg = {}
    for p in a.registry:
        for s, items in json.load(open(p)).items():
            for it in items:
                reg.setdefault(it["token"], (int(s), it["meaning"]))
    nlp = spacy.load("en_core_web_trf")
    mdocs = {t: nlp(m) for t, (_, m) in reg.items()}
    mlem = {t: lemmas(d) | {w.lower() for w in re.split(r"[-_]", t) if len(w) > 2} - STOP for t, d in mdocs.items()}
    nli = NLI(a.nli)
    pairs, meta = [], []
    for serial in a.serials:
        d = glob.glob(os.path.join(a.rfds, "rfd", f"{serial}-*/"))[0]
        sents = []
        for ln in prose(d, serial).split("\n"):
            if len(ln.strip()) > 25:
                sents += [s.text.strip() for s in nlp(ln).sents if len(s.text.strip()) > 20]
        for i in range(len(sents)):
            win = " ".join(sents[i:i + 3])
            wl = lemmas(nlp(win))
            scored = sorted(((len(wl & mlem[t]), t) for t, (prov, _) in reg.items() if prov != serial),
                            reverse=True)[:a.top]
            for ov, t in scored:
                if ov >= 2:
                    pairs.append((win, f"RFD{serial} uses {reg[t][1]}."))
                    meta.append((serial, t, reg[t][0], ov, win))
    print(len(pairs), "candidate pairs", file=sys.stderr)
    scores = nli.score(pairs)
    best = {}
    for (s, t, prov, ov, win), (e, c) in zip(meta, scores):
        if (s, t) not in best or e > best[(s, t)]["entail"]:
            best[(s, t)] = {"rfd": s, "token": t, "provider": prov, "entail": round(e, 3),
                            "contradict": round(c, 3), "overlap": ov, "evidence": win}
    json.dump(sorted(best.values(), key=lambda x: -x["entail"]), open(a.out, "w"), indent=1)
    print(len(best), "proposals")


if __name__ == "__main__":
    main()
