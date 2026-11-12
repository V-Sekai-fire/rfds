# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# The beta tech tree as one Lottie 1.0 file (.lot), labels drawn as glyph outlines.
defmodule PagesTechtree do
  @w 1280
  @h 720
  @fps 30
  @op 60
  @ink [0.12, 0.14, 0.16]
  @paper [0.98, 0.98, 0.97]
  @line [0.55, 0.58, 0.62]
  @fill %{done: [0.80, 0.92, 0.82], ready: [1.0, 0.91, 0.70], blocked: [0.90, 0.91, 0.92]}
  @edge %{done: [0.18, 0.55, 0.30], ready: [0.85, 0.55, 0.05], blocked: [0.55, 0.58, 0.62]}
  @word %{done: "committed", ready: "ready", blocked: "blocked"}
  @card {160, 112}

  def write(tree, out) do
    lot = tree |> build() |> JSON.encode!()
    File.write!(Path.join(out, "assets/techtree.lot"), lot)
    File.write!(Path.join(out, "assets/techtree.xmp"), xmp())
    lot
  end

  # CDN for now (operator, 2026-11-12).
  @player "https://unpkg.com/@thorvg/lottie-player@1.1.3/dist/sw-lite/lottie-player.js"
  @sri "sha384-jG9aaX1Gb/uJNurNkdTDEuLP4dRsiuJwPIgZ6FWpcm1VeKFd4hwIdpM7xButdISs"

  def figure do
    "<figure id=\"techtree\" class=\"techtree\">\n" <>
      "<script src=\"#{@player}\" integrity=\"#{@sri}\" crossorigin=\"anonymous\" " <>
      "defer></script>\n" <>
      "<lottie-player src=\"assets/techtree.lot\" filetype=\"lot\" autoplay loop " <>
      "role=\"img\" aria-label=\"The tech tree to the beta: skills, gates and tokens\" " <>
      "style=\"display:block;width:100%;max-width:1280px;aspect-ratio:16/9\">" <>
      "</lottie-player>\n" <>
      "<script>for (const p of document.querySelectorAll(\"lottie-player[src]\")) " <>
      "p.setAttribute(\"src\", new URL(p.getAttribute(\"src\"), document.baseURI).href)" <>
      "</script>\n" <>
      "<figcaption>The tech tree to the beta, drawn by ThorVG from " <>
      "<a href=\"assets/techtree.lot\">techtree.lot</a>. " <>
      "The same facts are in <a href=\"#s1-1\">the tables below</a>.</figcaption>\n</figure>\n"
  end

  def build(tree) do
    font = glyphs()
    by = Map.new(tree.nodes, &{&1.n, &1})
    {layers, used} = layers(tree, by, font)

    %{
      v: "5.7.0",
      nm: "techtree",
      fr: @fps,
      ip: 0,
      op: @op,
      w: @w,
      h: @h,
      assets: for(c <- Enum.sort(used), do: glyph_asset(font, c)),
      layers: Enum.with_index(layers, 1) |> Enum.map(fn {l, i} -> Map.put(l, :ind, i) end)
    }
  end

  defp layers(tree, by, font) do
    goal = by[tree.goal]
    path = tree.nodes |> Enum.reject(&(&1.n == tree.goal)) |> Enum.sort_by(& &1.n)
    depths = path |> Enum.map(& &1.d) |> Enum.uniq() |> Enum.sort(:desc)
    pos = place(path, depths)
    {cw, ch} = @card

    texts =
      [
        {"RFD66606-#{goal.n}: #{goal.t}", 40, 58, 26, @w - 80},
        {"The beta freeze: cut when every gate in RFD66606-2436 passes with its control.", 40, 92,
         15, @w - 80}
      ] ++
        Enum.flat_map(path, fn n ->
          {x, y} = pos[n.n]
          st = PagesTree.status(by, n)

          [{"RFD66606-#{n.n}", x + 10, y + 22, 13, cw - 20}] ++
            wrap(font, n.t, x + 10, y + 42, 12, cw - 20, 4) ++
            [{@word[st], x + 10, y + ch - 8, 11, cw - 20}]
        end) ++ panel_text(tree) ++ legend_text(tree)

    cards =
      Enum.flat_map(path, fn n ->
        {x, y} = pos[n.n]
        st = PagesTree.status(by, n)
        ring = if st == :ready, do: [pulse(x, y)], else: []
        ring ++ [rect(x, y, cw, ch, 10, @fill[st], @edge[st], 2)]
      end)

    edges =
      for n <- path, m <- n.c, pos[m], by[m].d > n.d do
        {x1, y1} = pos[m]
        {x2, y2} = pos[n.n]
        elbow({x1 + cw, y1 + ch / 2}, {x2, y2 + ch / 2}, @edge[PagesTree.status(by, by[m])])
      end

    gates =
      for n <- path, n.d == 1 do
        {x, y} = pos[n.n]
        line([{x + cw / 2, y}, {x + cw / 2, 118}], @edge[PagesTree.status(by, n)], 3)
      end

    feature =
      for f <- tree.features, n <- path, n.n in f.slices do
        {x, y} = pos[n.n]
        label = "feature: #{f.name}"
        w = width(font, label, 12)
        {label, x + cw / 2 - 8 - w, (y + 118) / 2 + 4, 12, w + 1}
      end

    texts = texts ++ feature
    glyph_layers = Enum.flat_map(texts, &text(font, &1))

    used =
      for {s, _, _, _, _} <- texts,
          c <- String.graphemes(plain(s)),
          c != " ",
          uniq: true,
          do: c

    banner = rect(20, 20, @w - 40, 98, 12, [0.93, 0.95, 0.99], [0.25, 0.38, 0.75], 3)
    bg = rect(0, 0, @w, @h, 0, @paper, nil, 0)

    {glyph_layers ++
       panel_marks(tree) ++
       legend_marks() ++ cards ++ edges ++ gates ++ [panel_box(), banner, bg], used}
  end

  defp place(path, depths) do
    {cw, ch} = @card
    gap = (850 - 40 - length(depths) * cw) / max(length(depths) - 1, 1)

    for {d, col} <- Enum.with_index(depths),
        col_nodes = Enum.filter(path, &(&1.d == d)),
        k = length(col_nodes),
        {n, row} <- Enum.with_index(col_nodes),
        into: %{} do
      top = 150 + (450 - (k * ch + (k - 1) * 40)) / 2
      {n.n, {40 + col * (cw + gap), top + row * (ch + 40)}}
    end
  end

  defp panel_box, do: rect(890, 150, 370, 450, 10, [1.0, 1.0, 1.0], @line, 1.5)

  defp tokens(tree), do: tree.tokens ++ tree.boring

  defp rows(tree) do
    inn = for {t, i} <- Enum.with_index(tree.tokens), do: {t, :inn, 205 + i * 24}
    base = 205 + length(tree.tokens) * 24 + 40
    inn ++ for {t, i} <- Enum.with_index(tree.boring), do: {t, :boring, base + i * 24}
  end

  defp panel_text(tree) do
    base = 205 + length(tree.tokens) * 24 + 40

    [{"Innovation tokens", 908, 180, 15, 340}, {"Boring technology", 908, base - 24, 15, 340}] ++
      for {t, _, y} <- rows(tree), do: {"#{t.i}  #{t.name}", 934, y + 5, 12.5, 316}
  end

  defp panel_marks(tree) do
    for {t, kind, y} <- rows(tree) do
      fill = if t.access, do: [0.25, 0.38, 0.75], else: nil

      case kind do
        :inn -> rect(910, y - 7, 14, 14, 2, fill, [0.25, 0.38, 0.75], 1.5)
        :boring -> dot(917, y, 7, fill, [0.25, 0.38, 0.75])
      end
    end
  end

  defp legend_text(tree) do
    spent = Enum.count(tree.nodes, &(&1.k != [] or &1.b != []))
    held = Enum.count(tokens(tree), & &1.access)

    [
      {"committed", 66, 648, 12.5, 120},
      {"ready: every need committed", 196, 648, 12.5, 220},
      {"blocked", 446, 648, 12.5, 120},
      {"filled mark: the org has access", 590, 648, 12.5, 260},
      {"#{spent} of #{length(tree.nodes)} skills name a token. " <>
         "#{held} of #{length(tokens(tree))} tokens with access. As of #{tree.asof}.", 40, 690,
       12.5, 1200}
    ]
  end

  defp legend_marks do
    for {st, x} <- [done: 40, ready: 170, blocked: 420] do
      rect(x, 636, 18, 16, 3, @fill[st], @edge[st], 1.5)
    end ++ [rect(566, 637, 14, 14, 2, [0.25, 0.38, 0.75], [0.25, 0.38, 0.75], 1.5)]
  end

  defp wrap(font, s, x, y, size, max, lines) do
    s
    |> String.split(" ")
    |> Enum.reduce([], fn word, acc ->
      case acc do
        [line | rest] ->
          try = line <> " " <> word
          if width(font, try, size) <= max, do: [try | rest], else: [word, line | rest]

        [] ->
          [word]
      end
    end)
    |> Enum.reverse()
    |> clip(font, size, max, lines)
    |> Enum.with_index()
    |> Enum.map(fn {l, i} -> {l, x, y + i * size * 1.3, size, max} end)
  end

  defp clip(all, font, size, max, lines) when length(all) > lines do
    {keep, [last | _]} = Enum.split(all, lines - 1)
    keep ++ [fit(font, last <> "...", size, max)]
  end

  defp clip(all, _, _, _, _), do: all

  defp fit(font, s, size, max) do
    if width(font, s, size) <= max or String.length(s) <= 4,
      do: s,
      else: fit(font, String.slice(s, 0..-5//1) <> "...", size, max)
  end

  defp plain(s) do
    s
    |> String.replace(["\u2018", "\u2019"], "'")
    |> String.replace(["\u201C", "\u201D"], "\"")
    |> String.replace(["\u2013", "\u2014"], "-")
    |> String.graphemes()
    |> Enum.map_join(fn c -> if c =~ ~r/^[\x20-\x7e]$/, do: c, else: "?" end)
  end

  defp width(font, s, size) do
    s |> String.graphemes() |> Enum.map(&adv(font, &1)) |> Enum.sum() |> Kernel.*(size / 1000)
  end

  defp adv(font, c) do
    case font["glyphs"][c] do
      nil -> raise "the tech-tree glyph table has no #{inspect(c)}"
      g -> g["w"]
    end
  end

  defp text(font, {s, x, y, size, max}) do
    font
    |> fit(plain(s), size, max)
    |> String.graphemes()
    |> Enum.map_reduce(x, fn c, cx -> {{c, cx}, cx + adv(font, c) * size / 1000} end)
    |> elem(0)
    |> Enum.reject(fn {c, _} -> c == " " end)
    |> Enum.map(fn {c, cx} ->
      g = font["glyphs"][c]

      %{
        ty: 0,
        nm: c,
        refId: gid(c),
        w: g["w"] + 200,
        h: 1500,
        ip: 0,
        op: @op,
        st: 0,
        ks: tf([100, 1100], [r(cx), r(y)], size / 10, 100)
      }
    end)
  end

  defp gid(c), do: "g#{:binary.first(c)}"

  defp glyph_asset(font, c) do
    g = font["glyphs"][c]

    paths =
      for contour <- g["c"] do
        %{
          ty: "sh",
          ks: %{
            a: 0,
            k: %{
              c: true,
              v: for([x, y | _] <- contour, do: [x, y]),
              i: for([_, _, ix, iy, _, _] <- contour, do: [ix, iy]),
              o: for([_, _, _, _, ox, oy] <- contour, do: [ox, oy])
            }
          }
        }
      end

    group = %{ty: "gr", it: paths ++ [fill(@ink), tr([0, 0], [100, 1100])]}

    %{
      id: gid(c),
      layers: [
        %{ty: 4, ind: 1, ip: 0, op: @op, st: 0, ks: tf([0, 0], [0, 0], 100, 100), shapes: [group]}
      ]
    }
  end

  defp rect(x, y, w, h, rad, fill_c, stroke_c, sw) do
    it =
      [%{ty: "rc", p: st([r(x + w / 2), r(y + h / 2)]), s: st([r(w), r(h)]), r: st(rad)}] ++
        if(stroke_c, do: [stroke(stroke_c, sw)], else: []) ++
        if(fill_c, do: [fill(fill_c)], else: []) ++ [tr([0, 0], [0, 0])]

    shape_layer([%{ty: "gr", it: it}], 100)
  end

  defp dot(x, y, rad, fill_c, stroke_c) do
    it =
      [%{ty: "el", p: st([x, y]), s: st([2 * rad, 2 * rad])}, stroke(stroke_c, 1.5)] ++
        if(fill_c, do: [fill(fill_c)], else: []) ++ [tr([0, 0], [0, 0])]

    shape_layer([%{ty: "gr", it: it}], 100)
  end

  defp pulse(x, y) do
    {cw, ch} = @card

    it = [
      %{ty: "rc", p: st([r(x + cw / 2), r(y + ch / 2)]), s: st([cw + 12, ch + 12]), r: st(14)},
      stroke(@edge.ready, 4),
      tr([0, 0], [0, 0])
    ]

    o = %{
      a: 1,
      k: [
        %{t: 0, s: [0], o: %{x: [0.4], y: [0]}, i: %{x: [0.6], y: [1]}},
        %{t: div(@op, 2), s: [90], o: %{x: [0.4], y: [0]}, i: %{x: [0.6], y: [1]}},
        %{t: @op, s: [0]}
      ]
    }

    [%{ty: "gr", it: it}] |> shape_layer(100) |> put_in([:ks, :o], o)
  end

  defp elbow({x1, y1}, {x2, y2}, c) do
    mid = (x1 + x2) / 2
    line([{x1, y1}, {mid, y1}, {mid, y2}, {x2, y2}], c, 3)
  end

  defp line(points, c, w) do
    v = for {x, y} <- points, do: [r(x), r(y)]
    z = for _ <- v, do: [0, 0]
    sh = %{ty: "sh", ks: %{a: 0, k: %{c: false, v: v, i: z, o: z}}}
    shape_layer([%{ty: "gr", it: [sh, stroke(c, w), tr([0, 0], [0, 0])]}], 100)
  end

  defp shape_layer(shapes, o) do
    %{ty: 4, ip: 0, op: @op, st: 0, ks: tf([0, 0], [0, 0], 100, o), shapes: shapes}
  end

  defp fill(c), do: %{ty: "fl", c: st(c), o: st(100), r: 1}
  defp stroke(c, w), do: %{ty: "st", c: st(c), o: st(100), w: st(w), lc: 2, lj: 2, ml: 4}
  defp tr(a, p), do: Map.merge(%{ty: "tr"}, tf(a, p, 100, 100))

  defp tf(a, p, s, o),
    do: %{a: st(a), p: st(p), s: st([s, s]), r: st(0), o: st(o)}

  defp st(k), do: %{a: 0, k: k}
  defp r(x), do: Float.round(x * 1.0, 2)

  defp glyphs, do: Path.join(__DIR__, "pages_glyphs.json") |> File.read!() |> JSON.decode!()

  defp xmp do
    media = %{format: "video/lottie+json", frame_rate: @fps, frames: @op}
    Path.join(__DIR__, "techtree.cff") |> Rfd.Cff.read!() |> Rfd.CffXmp.derive(media)
  end
end
