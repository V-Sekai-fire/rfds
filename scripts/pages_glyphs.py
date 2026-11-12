# SPDX-License-Identifier: Apache-2.0 OR MIT
"""Write scripts/pages_glyphs.json, the outlines the tech-tree diagram draws its labels with.

Lottie 1.0 has no text layer, so every label is a path. Run once when the font moves:
    pip install fonttools && python scripts/pages_glyphs.py <font.ttf> > scripts/pages_glyphs.json
"""

import hashlib
import json
import sys

from fontTools.pens.basePen import BasePen
from fontTools.ttLib import TTFont


class LottiePen(BasePen):
    def __init__(self, glyphset):
        super().__init__(glyphset)
        self.contours, self.cur = [], None

    def _moveTo(self, p):
        self.cur = [[p, (0, 0), (0, 0)]]

    def _lineTo(self, p):
        self.cur.append([p, (0, 0), (0, 0)])

    def _curveToOne(self, c1, c2, p):
        last = self.cur[-1]
        last[2] = (c1[0] - last[0][0], c1[1] - last[0][1])
        self.cur.append([p, (c2[0] - p[0], c2[1] - p[1]), (0, 0)])

    def _qCurveToOne(self, c, p):
        p0 = self.cur[-1][0]
        c1 = (p0[0] + 2 / 3 * (c[0] - p0[0]), p0[1] + 2 / 3 * (c[1] - p0[1]))
        c2 = (p[0] + 2 / 3 * (c[0] - p[0]), p[1] + 2 / 3 * (c[1] - p[1]))
        self._curveToOne(c1, c2, p)

    def _closePath(self):
        first, last = self.cur[0], self.cur[-1]
        if len(self.cur) > 1 and first[0] == last[0]:
            first[1] = last[1]
            self.cur.pop()
        r = lambda q: [round(q[0]), round(-q[1])]
        self.contours.append([[*r(v), *r(i), *r(o)] for v, i, o in self.cur])
        self.cur = None

    _endPath = _closePath


def main(path):
    raw = open(path, "rb").read()
    font = TTFont(path)
    cmap, gs = font.getBestCmap(), font.getGlyphSet()
    glyphs = {}
    for code in range(32, 127):
        name = cmap[code]
        pen = LottiePen(gs)
        gs[name].draw(pen)
        glyphs[chr(code)] = {"w": gs[name].width, "c": pen.contours}
    names = font["name"]
    out = {
        "font": names.getDebugName(4),
        "version": names.getDebugName(5),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "license": "OFL-1.1, text in scripts/pages_glyphs.OFL.txt",
        "upm": font["head"].unitsPerEm,
        "glyphs": glyphs,
    }
    json.dump(out, sys.stdout, separators=(",", ":"), sort_keys=True)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main(sys.argv[1])
