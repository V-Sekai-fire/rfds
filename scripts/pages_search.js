// Copyright (c) 2026 K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: Apache-2.0 OR MIT
// Full-text search over search.json, which scripts/pages_site.exs writes beside the pages.
(() => {
  const box = document.getElementById("site-search");
  if (!box) return;
  const input = box.querySelector("input");
  const list = box.querySelector("ol");
  const status = box.querySelector("p");
  const base = box.dataset.base;
  const kinds = { rfd: "RFD", details: "details", log: "logbook", page: "agreement" };
  const k1 = 1.2, b = 0.75, limit = 40;
  let index = null, loading = null, hits = [], at = -1;

  document.head.insertAdjacentHTML(
    "beforeend",
    `<style>
    #site-search { position: relative; margin: 0 0 24px; }
    #site-search input { width: 100%; padding: 8px 12px; font-size: 16px; border-radius: 6px;
      border: 1px solid #d0d7de; background: #f6f8fa; }
    #site-search input:focus { background: #fff; outline: 2px solid #0969da; border-color: #0969da; }
    #site-search p { margin: 6px 2px 0; font-size: 13px; color: #57606a; }
    #site-search ol { position: absolute; z-index: 10; left: 0; right: 0; margin: 4px 0 0;
      padding: 0; list-style: none; max-height: 70vh; overflow-y: auto; background: #fff;
      border: 1px solid #d0d7de; border-radius: 6px; box-shadow: 0 8px 24px rgba(140,149,159,.2); }
    #site-search li { margin: 0; border-bottom: 1px solid #eaeef2; }
    #site-search li a { display: block; padding: 8px 12px; color: inherit; text-decoration: none; }
    #site-search li.on a, #site-search li a:hover { background: #ddf4ff; }
    #site-search .t { display: block; font-weight: 600; color: #0969da; }
    #site-search .m { display: block; font-size: 12px; color: #57606a; }
    #site-search .s { display: block; font-size: 13px; color: #24292f; }
    #site-search mark { background: #fff8c5; padding: 0; }
    </style>`,
  );

  const fold = (s) => s.toLowerCase().normalize("NFKD").replace(/\p{M}/gu, "");
  const words = (s) => fold(s).match(/[\p{L}\p{N}]+/gu) || [];
  const stem = (w) => (w.length > 3 && /[^s]s$/.test(w) ? w.slice(0, -1) : w);
  const esc = (s) => s.replace(/[&<>"]/g, (c) => `&#${c.charCodeAt(0)};`);
  const reEsc = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

  function build(raw) {
    const df = new Map();
    let total = 0;
    const docs = raw.map((d) => {
      const tf = new Map();
      const body = words(d.b);
      for (const w of body) tf.set(stem(w), (tf.get(stem(w)) || 0) + 1);
      const title = new Set(words(d.t).map(stem));
      for (const w of new Set([...tf.keys(), ...title])) df.set(w, (df.get(w) || 0) + 1);
      total += body.length;
      return { ...d, tf, title, len: body.length, low: fold(d.t + " " + d.b) };
    });
    const vocab = [...df.keys()].sort();
    return { docs, df, vocab, avg: total / docs.length || 1 };
  }

  function load() {
    loading ||= fetch(base + "search.json")
      .then((r) => r.json())
      .then((raw) => (index = build(raw)));
    return loading;
  }

  function one(a, c) {
    let i = 0;
    while (i < a.length && a[i] === c[i]) i++;
    return a.slice(i + 1) === c.slice(i + 1) || a.slice(i) === c.slice(i + 1) ||
      a.slice(i + 1) === c.slice(i);
  }

  function near(w) {
    if (w.length < 4) return [];
    const out = [];
    for (const v of index.vocab) {
      if (Math.abs(v.length - w.length) <= 1 && v !== w && one(w, v)) out.push(v);
      if (out.length === 8) break;
    }
    return out;
  }

  function expand(w, last) {
    const s = stem(w);
    const out = new Map([[s, 1]]);
    if (last || w.length >= 3) {
      let lo = 0, hi = index.vocab.length;
      while (lo < hi) {
        const m = (lo + hi) >> 1;
        index.vocab[m] < w ? (lo = m + 1) : (hi = m);
      }
      for (let i = lo; i < index.vocab.length && index.vocab[i].startsWith(w); i++) {
        if (out.size > 60) break;
        if (!out.has(index.vocab[i])) out.set(index.vocab[i], last ? 0.8 : 0.5);
      }
    }
    if (![...out.keys()].some((v) => index.df.has(v))) for (const v of near(s)) out.set(v, 0.4);
    return out;
  }

  function parse(q) {
    const phrases = [...q.matchAll(/"([^"]+)"/g)].map((m) => fold(m[1]).trim()).filter(Boolean);
    const terms = words(q.replace(/"[^"]*"?/g, " ").replace(/\brfd66606\b/gi, " "));
    const open = !/[\s"]$/.test(q);
    const groups = terms.map((w, i) => expand(w, open && i === terms.length - 1));
    for (const p of phrases) for (const w of words(p)) groups.push(new Map([[stem(w), 1]]));
    return { phrases, groups };
  }

  function score(d, group) {
    let best = 0;
    for (const [w, weight] of group) {
      const df = index.df.get(w);
      if (!df) continue;
      const idf = Math.log(1 + (index.docs.length - df + 0.5) / (df + 0.5));
      const tf = d.tf.get(w) || 0;
      const body = (tf * (k1 + 1)) / (tf + k1 * (1 - b + (b * d.len) / index.avg));
      const s = weight * idf * (body + (d.title.has(w) ? 3 : 0));
      if (s > best) best = s;
    }
    return best;
  }

  function search(q) {
    const { phrases, groups } = parse(q);
    if (!groups.length) return { hits: [], partial: false };
    const ranked = (all) => {
      const out = [];
      for (const d of index.docs) {
        if (phrases.some((p) => !d.low.includes(p))) continue;
        let s = 0, matched = 0;
        for (const g of groups) {
          const gs = score(d, g);
          if (gs > 0) matched++;
          else if (all) { s = 0; break; }
          s += gs;
        }
        if (s > 0 && (all || matched)) {
          const dead = d.s.includes("🪦") ? 0.4 : 1;
          const lead = (d.k === "rfd" || d.k === "page" ? 1.15 : 1) * dead;
          out.push({ d, s: s * lead * (all ? 1 : matched / groups.length) });
        }
      }
      return out.sort((x, y) => y.s - x.s);
    };
    const strict = ranked(true);
    if (strict.length || groups.length === 1) return { hits: strict, groups, phrases, partial: false };
    return { hits: ranked(false), groups, phrases, partial: true };
  }

  function pattern(groups) {
    const ws = new Set();
    for (const g of groups) for (const w of g.keys()) ws.add(reEsc(w));
    if (!ws.size) return null;
    const alts = [...ws].sort((x, y) => y.length - x.length).join("|");
    return new RegExp(`(?<![\\p{L}\\p{N}])(?:${alts})[\\p{L}\\p{N}]*`, "giu");
  }

  function snippet(d, re, phrases) {
    const text = d.b;
    let start = 0, word = "";
    const at = phrases.length ? text.toLowerCase().indexOf(phrases[0]) : -1;
    if (at >= 0) {
      start = Math.max(0, at - 60);
      word = text.slice(at, at + phrases[0].length);
    } else if (re) {
      re.lastIndex = 0;
      const m = re.exec(text);
      if (m) {
        start = Math.max(0, m.index - 60);
        word = m[0];
      }
    }
    if (start > 0) start = text.indexOf(" ", start) + 1 || start;
    const cut = text.slice(start, start + 200);
    const body = (start > 0 ? "… " : "") + cut + (start + 200 < text.length ? " …" : "");
    return { html: mark(body, re), word };
  }

  function mark(text, re) {
    if (!re) return esc(text);
    let out = "", last = 0;
    re.lastIndex = 0;
    for (const m of text.matchAll(re)) {
      out += esc(text.slice(last, m.index));
      out += `<mark>${esc(m[0])}</mark>`;
      last = m.index + m[0].length;
    }
    return out + esc(text.slice(last));
  }

  function render(q) {
    if (!q.trim()) {
      list.hidden = status.hidden = true;
      hits = [];
      return;
    }
    const r = search(q);
    const re = pattern(r.groups || []);
    hits = r.hits.slice(0, limit).map(({ d }) => {
      const sn = snippet(d, re, r.phrases || []);
      const frag = sn.word ? `#:~:text=${encodeURIComponent(sn.word)}` : "";
      return { href: base + (d.u.startsWith("#") ? d.u + frag.replace(/^#/, "") : d.u + frag), d, sn };
    });
    at = hits.length ? 0 : -1;
    const n = r.hits.length;
    status.textContent = n
      ? `${n} result${n === 1 ? "" : "s"}${r.partial ? " (not every word matched)" : ""}` +
        (n > limit ? `, showing the first ${limit}` : "")
      : "No results.";
    status.hidden = false;
    // Every interpolated string passes through esc() or mark(), which escapes.
    list.innerHTML = hits
      .map(
        (h, i) =>
          `<li${i === at ? ' class="on"' : ""}><a href="${esc(h.href)}">` +
          `<span class="t">${mark(h.d.t, re)}</span>` +
          `<span class="m">${esc([kinds[h.d.k], h.d.s, h.d.d].filter(Boolean).join(" · "))}` +
          `</span><span class="s">${h.sn.html}</span></a></li>`,
      )
      .join("");
    list.hidden = !hits.length;
  }

  function move(by) {
    if (!hits.length) return;
    const items = list.children;
    items[at]?.classList.remove("on");
    at = (at + by + hits.length) % hits.length;
    items[at].classList.add("on");
    items[at].scrollIntoView({ block: "nearest" });
  }

  let timer = 0;
  const run = () => {
    clearTimeout(timer);
    timer = setTimeout(() => load().then(() => render(input.value)), 60);
  };

  input.addEventListener("focus", () => load(), { once: true });
  input.addEventListener("input", run);
  input.addEventListener("keydown", (e) => {
    if (e.key === "ArrowDown") move(1);
    else if (e.key === "ArrowUp") move(-1);
    else if (e.key === "Enter" && hits[at]) location.href = hits[at].href;
    else if (e.key === "Escape") {
      input.value = "";
      render("");
      input.blur();
    } else return;
    e.preventDefault();
  });
  document.addEventListener("keydown", (e) => {
    const typing = /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement?.tagName);
    if (e.key === "/" && !typing && !e.metaKey && !e.ctrlKey) {
      e.preventDefault();
      input.focus();
    }
  });
  document.addEventListener("click", (e) => {
    if (!box.contains(e.target)) list.hidden = status.hidden = true;
  });
  input.addEventListener("focus", () => input.value.trim() && run());

  const q = new URLSearchParams(location.search).get("q");
  if (q) {
    input.value = q;
    run();
  }
})();
