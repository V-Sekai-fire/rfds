# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# The RFD site as committed static files in docs/: build, convert with MDEx, compare.
#     mix run scripts/pages_docs.exs [--write | --self-test]
defmodule PagesDocs do
  @root Path.expand("..", __DIR__)
  @docs Path.join(@root, "docs")
  @base "/rfds/"
  @regen "mix run scripts/pages_docs.exs --write"

  def main(["--self-test"]), do: self_test()

  def main(args) do
    out = build()

    if args == ["--write"] do
      File.rm_rf!(@docs)
      File.cp_r!(out, @docs)
      IO.puts("wrote docs/: #{length(files(@docs))} files")
    else
      problems = drift(out, @docs) ++ sidecar(Path.join(@docs, "assets"))
      Enum.each(problems, &IO.puts("  FAIL #{&1}"))

      if problems == [] do
        IO.puts("ok   docs/ matches the RFD sources (#{length(files(@docs))} files)")
      else
        IO.puts("regenerate with: #{@regen}")
        System.halt(1)
      end
    end
  end

  defp build do
    tmp = Path.join(System.tmp_dir!(), "pages-docs-#{System.unique_integer([:positive])}")
    env = [{"ERL_COMPILER_OPTIONS", "[nowarn_deprecated_catch]"}]
    run!(~w(rfd.render), env)
    run!(["run", "scripts/pages_site.exs", Path.join(tmp, "src")], env)
    convert(Path.join(tmp, "src"), Path.join(tmp, "out"))
  end

  defp run!(args, env) do
    {text, code} = System.cmd("mix", args, cd: @root, env: env, stderr_to_stdout: true)
    if code != 0, do: raise("mix #{Enum.join(args, " ")} failed:\n#{text}")
  end

  def convert(src, out) do
    File.mkdir_p!(out)

    [_, front, md] =
      Regex.run(~r/\A---\n(.*?)\n---\n(.*)\z/s, File.read!(Path.join(src, "index.md")))

    layout = front |> field("layout") |> then(&File.read!(Path.join(src, "_layouts/#{&1}.html")))
    config = File.read!(Path.join(src, "_config.yml"))
    File.write!(Path.join(out, "index.html"), page(layout, html(md), config))
    File.cp!(Path.join(src, "404.html"), Path.join(out, "404.html"))
    File.cp!(Path.join(src, "search.json"), Path.join(out, "search.json"))
    File.cp_r!(Path.join(src, "assets"), Path.join(out, "assets"))
    File.write!(Path.join(out, ".nojekyll"), "")
    out
  end

  defp field(yaml, key) do
    case Regex.run(~r/^#{key}:\s*(.+)$/m, yaml) do
      [_, v] -> String.trim(v)
      nil -> raise "no #{key} in the front matter or _config.yml"
    end
  end

  def html(md) do
    md = String.replace(md, "* TOC\n{:toc}", "<!--toc-->")

    body =
      md
      |> MDEx.to_html!(
        extension: [table: true, strikethrough: true, autolink: true, tasklist: true],
        parse: [smart: true],
        render: [unsafe: true]
      )
      |> heading_ids()
      |> ial()
      |> auto_ids()

    String.replace(body, "<!--toc-->", toc(body))
  end

  defp heading_ids(html) do
    Regex.replace(~r/<h([1-6])>(.*?)\s*\{#([A-Za-z0-9_.:-]+)\}<\/h\1>/, html, fn _, l, t, id ->
      ~s(<h#{l} id="#{id}">#{t}</h#{l}>)
    end)
  end

  defp ial(html) do
    html =
      Regex.replace(
        ~r/<h([1-6])((?: [a-z]+="[^"]*")*)>(.*?)<\/h\1>\n<p>\{:\s*([^}]*)\}<\/p>/,
        html,
        fn _, l, attrs, t, spec -> "<h#{l}#{merge(attrs, spec)}>#{t}</h#{l}>" end
      )

    Regex.replace(~r/<p>((?:(?!<\/p>).)*?)\n\{:\s*([^}]*)\}<\/p>/s, html, fn _, t, spec ->
      "<p#{merge("", spec)}>#{t}</p>"
    end)
  end

  defp merge(attrs, spec) do
    tokens = String.split(spec)
    classes = for "." <> c <- tokens, do: c
    ids = for "#" <> i <- tokens, do: i
    cls = if classes == [], do: "", else: ~s( class="#{Enum.join(classes, " ")}")
    id = if ids == [] or attrs =~ "id=", do: "", else: ~s( id="#{hd(ids)}")
    attrs <> id <> cls
  end

  defp auto_ids(html) do
    Regex.replace(~r/<h([1-6])((?: class="[^"]*")?)>(.*?)<\/h\1>/, html, fn _, l, attrs, t ->
      "<h#{l}#{attrs} id=\"#{slug(t)}\">#{t}</h#{l}>"
    end)
  end

  defp slug(t) do
    t
    |> String.replace(~r/<[^>]+>/, "")
    |> String.replace(~r/^[^a-zA-Z]+/, "")
    |> String.replace(~r/[^a-zA-Z0-9 -]/, "")
    |> String.replace(" ", "-")
    |> String.downcase()
  end

  defp toc(html) do
    heads =
      for [_, l, attrs, t] <- Regex.scan(~r/<h([2-4])([^>]*)>(.*?)<\/h\1>/, html),
          [_, id] <- [Regex.run(~r/id="([^"]+)"/, attrs) || [nil, nil]],
          id != nil and not (attrs =~ "no_toc"),
          do: {String.to_integer(l), id, String.replace(t, ~r/<\/?a\b[^>]*>/, "")}

    ~s(<ul id="markdown-toc">\n) <> nest(heads, 2) <> "</ul>"
  end

  defp nest(heads, level) do
    heads
    |> Enum.chunk_while(
      [],
      fn {l, _, _} = h, acc ->
        if l == level and acc != [], do: {:cont, Enum.reverse(acc), [h]}, else: {:cont, [h | acc]}
      end,
      fn acc -> {:cont, Enum.reverse(acc), []} end
    )
    |> Enum.reject(&(&1 == []))
    |> Enum.map_join(fn
      [{l, id, t} | kids] when l == level ->
        inner = if kids == [], do: "", else: "<ul>\n" <> nest(kids, level + 1) <> "</ul>"
        ~s(<li><a href="##{id}" id="markdown-toc-#{id}">#{t}</a>#{inner}</li>\n)

      kids ->
        nest(kids, level + 1)
    end)
  end

  def page(layout, body, config) do
    [_, search] = Regex.run(~r/\{%\s*capture search\s*%\}(.*?)\{%\s*endcapture\s*%\}/s, layout)
    shell = Regex.replace(~r/\{%\s*capture search\s*%\}.*?\{%\s*endcapture\s*%\}\n?/s, layout, "")

    shell =
      shell
      |> String.replace("{{ site.title }}", field(config, "title"))
      |> String.replace("{{ site.description }}", field(config, "description"))
      |> then(
        &Regex.replace(~r/\{\{\s*"\/?([^"]*)"\s*\|\s*relative_url\s*\}\}/, &1, @base <> "\\1")
      )

    search =
      Regex.replace(~r/\{\{\s*"\/?([^"]*)"\s*\|\s*relative_url\s*\}\}/, search, @base <> "\\1")

    content = ~r/\{\{\s*content\s*\|\s*replace:\s*"<!--search-->",\s*search\s*\}\}/
    if not Regex.match?(content, shell), do: raise("the layout's content tag moved")
    [pre, post] = Regex.split(content, shell, parts: 2)
    if pre <> post =~ ~r/\{\{|\{%/, do: raise("an unhandled Liquid tag is left in the layout")
    pre <> String.replace(body, "<!--search-->", search, global: false) <> post
  end

  def files(dir) do
    for f <- Path.wildcard(Path.join(dir, "**/*"), match_dot: true),
        File.regular?(f),
        into: [],
        do: Path.relative_to(f, dir)
  end

  def drift(built, tracked) do
    a = MapSet.new(files(built))
    b = MapSet.new(files(tracked))

    for(f <- MapSet.difference(a, b), do: "docs/#{f} is missing") ++
      for(f <- MapSet.difference(b, a), do: "docs/#{f} is not written by the generator") ++
      for f <- MapSet.intersection(a, b),
          File.read!(Path.join(built, f)) != File.read!(Path.join(tracked, f)),
          do: "docs/#{f} differs from what the generator writes"
  end

  def sidecar(dir) do
    with {:ok, lot} <- File.read(Path.join(dir, "techtree.lot")),
         {:ok, xmp} <- File.read(Path.join(dir, "techtree.xmp")),
         {:ok, cff} <- File.read(Path.join(dir, "techtree.cff")) do
      doc = JSON.decode!(lot)
      media = %{format: "video/lottie+json", frame_rate: doc["fr"], frames: doc["op"] - doc["ip"]}
      want = cff |> Rfd.Cff.parse!() |> Rfd.CffXmp.derive(media)
      if xmp == want, do: [], else: ["docs/assets/techtree.xmp is not what techtree.cff derives"]
    else
      _ -> ["docs/assets/techtree.lot, .xmp or .cff is missing"]
    end
  end

  defp self_test do
    dir = Path.join(System.tmp_dir!(), "pages-docs-self-#{System.unique_integer([:positive])}")
    [a, b] = for s <- ~w(built tracked), do: Path.join(dir, s)
    for d <- [a, b], do: File.mkdir_p!(Path.join(d, "assets"))
    lot = ~s({"fr":30,"ip":0,"op":60}\n)
    cff = File.read!(Path.join(@root, "assets/techtree.cff"))
    media = %{format: "video/lottie+json", frame_rate: 30, frames: 60}
    xmp = cff |> Rfd.Cff.parse!() |> Rfd.CffXmp.derive(media)

    for d <- [a, b] do
      File.write!(Path.join(d, "index.html"), "<p>x</p>\n")
      File.write!(Path.join(d, "assets/techtree.lot"), lot)
      File.write!(Path.join(d, "assets/techtree.cff"), cff)
      File.write!(Path.join(d, "assets/techtree.xmp"), xmp)
    end

    md =
      "# T\n{: .title}\n\n* TOC\n{:toc}\n\n## One {#one}\n\nA \"q\".\n{: .edition}\n\n### Two\n"

    h = html(md)

    checks = [
      {"matching trees pass", drift(a, b) == [] and sidecar(Path.join(b, "assets")) == []},
      {"a heading's {#id} becomes its id", h =~ ~s(<h2 id="one">One</h2>)},
      {"a heading without one gets a kramdown id", h =~ ~s(<h3 id="two">Two</h3>)},
      {"an IAL line sets the class", h =~ ~s(<h1 class="title" id="t">T</h1>)},
      {"a trailing IAL sets a paragraph class", h =~ ~s(<p class="edition">A “q”.</p>)},
      {"the TOC lists the headings", h =~ ~s(<a href="#two" id="markdown-toc-two">)},
      {"no marker is left as text", not (h =~ "{#" or h =~ "{:")},
      {"a flipped byte is drift",
       File.write!(Path.join(b, "index.html"), "<p>y</p>\n") == :ok and
         Enum.any?(drift(a, b), &(&1 =~ "differs"))},
      {"an extra file is drift",
       File.write!(Path.join(b, "stray.html"), "") == :ok and
         Enum.any?(drift(a, b), &(&1 =~ "not written"))},
      {"a missing file is drift",
       File.rm!(Path.join(b, "assets/techtree.cff")) == :ok and
         Enum.any?(drift(a, b), &(&1 =~ "missing"))},
      {"a sidecar that disagrees with the .lot fails",
       File.write!(Path.join(a, "assets/techtree.lot"), String.replace(lot, ":60", ":61")) ==
         :ok and
         sidecar(Path.join(a, "assets")) != []}
    ]

    for {name, ok} <- checks, do: IO.puts("  #{if ok, do: "ok  ", else: "FAIL"} #{name}")
    if Enum.all?(checks, &elem(&1, 1)), do: :ok, else: System.halt(1)
  end
end

PagesDocs.main(System.argv())
