// Copyright (c) 2026 K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: Apache-2.0 OR MIT
// The journey to the goal: committed RFDs, then open skills in waves, then the beta freeze.
(() => {
  const here = document.currentScript ? document.currentScript.src.replace(/[^/]*$/, "") : "assets/";
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

  const CHARTER = "https://v-sekai.github.io/manuals/decisions/20200608-vsekai-charter.html";
  const today = new Intl.DateTimeFormat("en-CA", { timeZone: "America/Vancouver" }).format(new Date());
  const gates = [2436, 2437, 2438, 2439, 2440];
  const seen = new Set([data.goal]);
  const queue = [data.goal];
  while (queue.length) needs(queue.shift()).forEach((m) => { if (!seen.has(m)) { seen.add(m); queue.push(m); } });
  seen.delete(data.goal);
  const nodes = [...seen];
  const open = nodes.filter((n) => !done(dn(n)));
  const doneIds = nodes.filter((n) => done(dn(n))).sort((a, b) => a - b);
  const early = new Set(doneIds.filter((n) => needs(n).some((m) => !done(dn(m)))));

  function plan() {
    const lines = nodes.concat([data.goal]).sort((a, b) => a - b).map((id) =>
      "skill " + id + " " + (done(dn(id)) ? 1 : 0) + " " + needs(id).join(" "));
    lines.push("goal " + data.goal);
    const out = JSON.parse(ask(lines.join("\n")));
    return out.plan ? out.plan.map((s) => +s.replace("activate-", "")).filter((n) => n !== data.goal) : null;
  }
  let ask = null;

  function render(order, msg) {
    host.replaceChildren();
    host.appendChild(h("p", { class: "bp-def" }, "The journey to " + short(data.goal) + ", " + dn(data.goal).t
      + ". It starts at the V-Sekai charter, submitted 2020-06-08 (Pacific), and today is " + today
      + " (Pacific). An RFD that is committed counts as complete, whatever order it landed in. "
      + doneIds.length + " of " + nodes.length + " skills are committed, " + open.length + " remain. "
      + (order ? "The order of the remaining skills is planned by the persona planner." : msg)));
    const track = h("div", { class: "jr-track" });
    const col = (title, sub, cls) => {
      const c = h("section", { class: "jr-col " + cls });
      c.appendChild(h("h4", {}, title));
      c.appendChild(h("p", { class: "jr-sub" }, sub));
      track.appendChild(c);
      return c;
    };
    const chip = (id, c, cls, step) => {
      const n = dn(id);
      const ready = !done(n) && needs(id).every((m) => done(dn(m)));
      const a = h("a", { class: "jr-chip " + (done(n) ? "done" : ready ? "ready" : "") + (cls || ""),
        href: "#" + n.id, title: short(id) + ": " + n.t + " (" + n.s + ")" }, (step ? step + ". " : "") + id + " " + n.t);
      const first = [...n.k, ...n.b][0];
      if (first !== undefined) a.style.borderLeftColor = color(first);
      c.appendChild(a);
    };
    const o = col("Origin", "2020-06-08, Pacific", "jr-origin");
    const link = h("a", { href: CHARTER }, "V-Sekai charter");
    const p1 = h("p", { class: "jr-text" });
    p1.appendChild(link);
    p1.appendChild(document.createTextNode(": an open, self-hosted social VR hub with spatialized voice and upper-body tracking, which RFD66606-2360 carries forward as see each other and hear each other."));
    o.appendChild(p1);
    const dated = doneIds.filter((id) => dn(id).a);
    const undated = doneIds.filter((id) => !dn(id).a);
    [...new Set(dated.map((id) => dn(id).a))].sort().forEach((day) => {
      const c = col("Acquired " + day, dated.filter((id) => dn(id).a === day).length + " put into production", "jr-done");
      dated.filter((id) => dn(id).a === day).forEach((id) => chip(id, c, early.has(id) ? " early" : ""));
    });
    const dc = col("Committed, date not recorded", undated.length + " committed"
      + (early.size ? ", " + early.size + " landed before something they need" : "")
      + ". Nothing yet says when each went into production, so no date is shown.", "jr-done");
    undated.forEach((id) => chip(id, dc, early.has(id) ? " early" : ""));
    if (order) {
      const per = Math.ceil(order.length / 4);
      const opened = new Set();
      for (let k = 0; k < order.length; k += per) {
        const part = order.slice(k, k + per);
        const fresh = new Set();
        part.forEach((id) => [...dn(id).k, ...dn(id).b].forEach((i) => { if (!opened.has(i)) { opened.add(i); fresh.add(i); } }));
        const c = col("Planned steps " + (k + 1) + " to " + (k + part.length),
          fresh.size ? "opens " + [...fresh].map((i) => tokenOf(i).name).join(", ") : "no new token", k === 0 ? "jr-now" : "");
        part.forEach((id, q) => chip(id, c, "", k + q + 1));
      }
    }
    const end = col(short(data.goal), "beta freeze: " + gates.filter((g) => done(dn(g))).length
      + " of " + gates.length + " slice gates committed", "jr-end");
    gates.forEach((g) => chip(g, end));
    host.appendChild(track);
  }

  render(null, "Loading the persona planner...");
  import(here + "persona.mjs")
    .then((m) => m.default({ locateFile: (f) => here + f }))
    .then((mod) => {
      if (mod._persona_init() !== 0) throw new Error("persona_init failed");
      ask = mod.cwrap("persona_plan", "string", ["string"]);
      const order = plan();
      render(order, order ? "" : "The planner found no route.");
    })
    .catch((e) => render(null, "The persona planner did not load, so the remaining skills have no order: " + e));
})();
