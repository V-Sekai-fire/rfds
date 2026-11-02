// Copyright (c) 2026 K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: Apache-2.0 OR MIT
// The journey to the goal: committed RFDs, then open skills in waves, then the beta freeze.
(() => {
  const host = document.getElementById("journey");
  const raw = document.getElementById("tree-data");
  if (!host || !raw) return;
  const data = JSON.parse(raw.textContent);
  const INNOV = ["#e6194b", "#f58231", "#b8860b", "#00a5cf", "#4363d8", "#911eb4", "#008080"];
  const BORE = ["#2e7d32", "#689f38", "#00897b", "#827717"];
  const all = [...data.tokens, ...data.boring];
  const color = (id) => (typeof id === "number" ? INNOV[id - 1] : BORE[+id.slice(1) - 1]);
  const tokenOf = (id) => all.find((t) => t.i === id);
  const byN = new Map(data.nodes.map((n) => [n.n, n]));
  const short = (n) => "RFD66606-" + n;
  const done = (n) => n.s === "committed";
  const dn = (id) => byN.get(id);
  const needs = (id) => dn(id).c.filter((m) => dn(m) && dn(m).d > dn(id).d);
  const h = (tag, attrs = {}, text) => {
    const e = document.createElement(tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (text !== undefined) e.textContent = text;
    return e;
  };

  const gates = [2436, 2437, 2438, 2439, 2440];
  const seen = new Set([data.goal]);
  const queue = [data.goal];
  while (queue.length) needs(queue.shift()).forEach((m) => { if (!seen.has(m)) { seen.add(m); queue.push(m); } });
  seen.delete(data.goal);
  const nodes = [...seen];
  const open = nodes.filter((n) => !done(dn(n)));
  const wave = new Map();
  const level = (id) => {
    if (wave.has(id)) return wave.get(id);
    wave.set(id, 1);
    const w = 1 + Math.max(0, ...needs(id).filter((m) => !done(dn(m))).map(level));
    wave.set(id, w);
    return w;
  };
  open.forEach(level);
  const top = Math.max(1, ...open.map((n) => wave.get(n)));
  const doneIds = nodes.filter((n) => done(dn(n))).sort((a, b) => a - b);
  const early = new Set(doneIds.filter((n) => needs(n).some((m) => !done(dn(m)))));
  const opened = new Set();

  host.appendChild(h("p", { class: "bp-def" }, "The journey to " + short(data.goal) + ", " + dn(data.goal).t
    + ". An RFD that is committed counts as complete, whatever order it landed in. Each step right needs the steps before it. "
    + doneIds.length + " of " + nodes.length + " skills are committed, " + open.length + " remain."));
  const track = h("div", { class: "jr-track" });
  const col = (title, sub, cls) => {
    const c = h("section", { class: "jr-col " + cls });
    c.appendChild(h("h4", {}, title));
    c.appendChild(h("p", { class: "jr-sub" }, sub));
    track.appendChild(c);
    return c;
  };
  const chip = (id, c, cls) => {
    const n = dn(id);
    const ready = !done(n) && needs(id).every((m) => done(dn(m)));
    const a = h("a", { class: "jr-chip " + (done(n) ? "done" : ready ? "ready" : "") + (cls || ""),
      href: "#" + n.id, title: short(id) + ": " + n.t + " (" + n.s + ")" }, id + " " + n.t);
    const first = [...n.k, ...n.b][0];
    if (first !== undefined) a.style.borderLeftColor = color(first);
    c.appendChild(a);
  };
  const dc = col("Committed", doneIds.length + " done"
    + (early.size ? ", " + early.size + " landed before something they need" : ""), "jr-done");
  doneIds.forEach((id) => chip(id, dc, early.has(id) ? " early" : ""));
  for (let w = 1; w <= top; w++) {
    const ids = open.filter((n) => wave.get(n) === w).sort((a, b) => a - b);
    const fresh = new Set();
    ids.forEach((id) => [...dn(id).k, ...dn(id).b].forEach((i) => { if (!opened.has(i)) { opened.add(i); fresh.add(i); } }));
    const sub = ids.length + " skills" + (fresh.size ? ", opens " + [...fresh].map((i) => tokenOf(i).name).join(", ") : "");
    const c = col(w === 1 ? "Next: ready now" : "Then, step " + w, sub, w === 1 ? "jr-now" : "");
    ids.forEach((id) => chip(id, c));
  }
  const end = col(short(data.goal), "beta freeze: " + gates.filter((g) => done(dn(g))).length
    + " of " + gates.length + " slice gates committed", "jr-end");
  gates.forEach((g) => chip(g, end));
  host.appendChild(track);
})();
