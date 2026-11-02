# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Decompose RFD prose into dependency ASTs with spaCy and label relations with NLI.

Reads the rendered README.md and DETAILS.md of each RFD, parses every sentence into a
dependency tree and predicate frames, and scores two claims per RFD reference with an NLI
model: that this RFD cannot be done until the other is, and that two RFDs are alternative
ways to the same result. Output is proposals for review, never edits to an RFD.
"""
import argparse
import glob
import itertools
import json
import os
import re

import spacy
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer

ID = re.compile(r"RFD66606-(\d{4})")
FENCE = re.compile(r"```.*?```", re.S)
SKIP_DEP = {"punct", "det"}
CUE = re.compile(r"\b(or|instead|alternative|either|fallback|rather than)\b", re.I)


def prose(path_dir, serial):
    text = ""
    for name in ("README.md", "DETAILS.md"):
        p = os.path.join(path_dir, name)
        if os.path.exists(p):
            text += "\n" + open(p, encoding="utf-8").read()
    text = FENCE.sub(" ", text)
    text = re.sub(r"^#+\s*", "", text, flags=re.M)
    text = re.sub(r"^\s*[-*]\s+", "", text, flags=re.M)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"`", "", text)
    text = ID.sub(lambda m: "RFD" + m.group(1), text)
    text = re.sub(r"\b[Tt]his RFD\b", f"RFD{serial}", text)
    return re.sub(r"[ \t]+", " ", text)


def tree(tok, depth=0):
    kids = [tree(c, depth + 1) for c in tok.children if c.dep_ not in SKIP_DEP and depth < 6]
    return {"t": tok.text, "lemma": tok.lemma_, "pos": tok.pos_, "dep": tok.dep_, "kids": kids}


def span(tok):
    return " ".join(t.text for t in tok.subtree if t.dep_ != "punct")


def frames(sent):
    out = []
    for tok in sent:
        if tok.pos_ not in ("VERB", "AUX") or tok.dep_ in ("aux", "auxpass"):
            continue
        kids = list(tok.children)
        subj = [span(c) for c in kids if c.dep_ in ("nsubj", "nsubjpass")]
        obj = [span(c) for c in kids if c.dep_ in ("dobj", "attr", "dative", "oprd")]
        if not (subj or obj):
            continue
        prep = [(c.text, span(p)) for c in kids if c.dep_ == "prep" for p in c.children if p.dep_ == "pobj"]
        out.append({
            "pred": tok.lemma_, "subj": subj, "obj": obj, "prep": prep,
            "neg": any(c.dep_ == "neg" for c in kids),
            "or": any(c.dep_ == "cc" and c.lower_ == "or" for t in tok.subtree for c in [t]),
        })
    return out


class NLI:
    def __init__(self, name):
        self.tok = AutoTokenizer.from_pretrained(name)
        self.mod = AutoModelForSequenceClassification.from_pretrained(name).eval()
        self.dev = "mps" if torch.backends.mps.is_available() else "cpu"
        self.mod.to(self.dev)
        names = {int(k): v.lower() for k, v in self.mod.config.id2label.items()}
        self.ent = next(i for i, n in names.items() if "entail" in n)
        self.con = next(i for i, n in names.items() if "contradict" in n)

    def score(self, pairs, batch=16):
        res = []
        for b in range(0, len(pairs), batch):
            chunk = pairs[b:b + batch]
            enc = self.tok([p for p, _ in chunk], [h for _, h in chunk], truncation=True,
                           max_length=256, padding=True, return_tensors="pt").to(self.dev)
            with torch.no_grad():
                prob = self.mod(**enc).logits.softmax(-1)
            res += [(float(r[self.ent]), float(r[self.con])) for r in prob]
        return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rfds", required=True, help="repo checkout holding rfd/<serial>-slug/README.md")
    ap.add_argument("--serials", nargs="+", type=int, required=True)
    ap.add_argument("--nli", required=True)
    ap.add_argument("--spacy", default="en_core_web_trf")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    nlp = spacy.load(a.spacy)
    nli = NLI(a.nli)
    asts, cands = {}, []
    for serial in a.serials:
        d = glob.glob(os.path.join(a.rfds, "rfd", f"{serial}-*/"))[0]
        lines = [ln.strip() for ln in prose(d, serial).split("\n") if len(ln.strip()) > 25]
        sents = []
        for doc in nlp.pipe(lines):
            for s in doc.sents:
                text = s.text.strip()
                if not re.search(r"[a-z]{3}", text):
                    continue
                sents.append({"text": text, "tree": tree(s.root), "frames": frames(s)})
                ment = sorted({int(m) for m in re.findall(r"RFD(\d{4})", text)} - {serial})
                for m in ment:
                    for h in (f"RFD{serial} depends on RFD{m}.", f"RFD{serial} builds on RFD{m}."):
                        cands.append(("spends", serial, m, text, h))
                if CUE.search(text):
                    for m, k in itertools.combinations(ment, 2):
                        cands.append(("alternative", m, k, text,
                                      f"RFD{m} is an alternative to RFD{k}."))
        asts[serial] = sents
    scores = nli.score([(c[3], c[4]) for c in cands])
    best = {}
    for (r, x, y, s, _), (e, c) in zip(cands, scores):
        k = (r, x, y, s)
        if k not in best or e > best[k][0]:
            best[k] = (e, c)
    props = [{"relation": r, "a": x, "b": y, "entail": round(e, 3), "contradict": round(c, 3),
              "sentence": s} for (r, x, y, s), (e, c) in best.items()]
    json.dump({"asts": asts, "proposals": props}, open(a.out, "w"), indent=1)
    print(len(asts), "RFDs,", sum(len(v) for v in asts.values()), "sentences,", len(props), "candidates")


if __name__ == "__main__":
    main()
