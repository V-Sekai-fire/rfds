# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Builds the Pages source as one flow: sources -> records -> groups -> sections -> files.
# A masthead and the newest RFDs lead; the logbook and RFD archives follow, dated from git.
#   mix run scripts/pages_site.exs <out-dir>
Code.require_file("pages_tree.exs", __DIR__)

defmodule PagesSite do
  @states ~w(prediscussion ideation discussion published committed abandoned)
  @emoji %{
    "prediscussion" => "📝",
    "ideation" => "💡",
    "discussion" => "💬",
    "published" => "📢",
    "committed" => "✅",
    "abandoned" => "🪦"
  }
  @pages ~w(README.md AGENTS.md BLOCKLIST.md PITFALLS.md KEYPOINTS.md)
  @alive ~w(discussion prediscussion ideation published committed)

  def main([out]) do
    root = Path.expand("..", __DIR__)
    File.rm_rf!(out)

    dates = last_changed(root)
    logs = logbook(root, dates)
    rfds = rfds(dates)

    slugs = Map.new(rfds, &{&1.serial, &1.href})
    Enum.each(logs ++ rfds, &copy(&1, out, slugs))

    for f <- @pages, File.exists?(Path.join(root, f)) do
      text = edit_from(f) <> linked(File.read!(Path.join(root, f)), "", slugs, nil)
      File.write!(Path.join(out, "page-" <> f), text)
    end

    docs = Enum.flat_map(logs ++ rfds, &found/1) ++ Enum.flat_map(@pages, &page_found(root, &1))
    File.mkdir_p!(Path.join(out, "assets"))
    File.write!(Path.join(out, "search.json"), JSON.encode!(docs))
    File.cp!(Path.join(__DIR__, "pages_search.js"), Path.join(out, "assets/search.js"))
    File.cp!(Path.join(__DIR__, "pages_tree.js"), Path.join(out, "assets/tree.js"))
    File.cp!(Path.join(__DIR__, "pages_navigator.js"), Path.join(out, "assets/navigator.js"))

    File.write!(Path.join(out, "_config.yml"), config())
    File.mkdir_p!(Path.join(out, "_layouts"))
    File.write!(Path.join(out, "_layouts/default.html"), layout())
    File.write!(Path.join(out, "page-SERIALS.md"), serials(root, rfds))
    File.write!(Path.join(out, "page-LOGBOOK.md"), logbook_page(logs))
    File.write!(Path.join(out, "_layouts/spec.html"), spec_layout())

    File.write!(
      Path.join(out, "index.md"),
      single_page(root, logs, rfds, edition(root), slugs, out)
    )

    IO.puts("pages: #{length(logs)} logbook entries, #{length(rfds)} RFDs, #{length(docs)} found")
  end

  defp last_changed(root) do
    {out, 0} = System.cmd("git", ["-C", root, "log", "--format=%x00%cs", "--name-only"])

    out
    |> String.split(<<0>>, trim: true)
    |> Enum.reduce(%{}, fn chunk, acc ->
      [date | files] = String.split(chunk, "\n", trim: true)
      Enum.reduce(files, acc, &Map.put_new(&2, &1, date))
    end)
  end

  defp edition(root) do
    {out, 0} = System.cmd("git", ["-C", root, "log", "-1", "--format=%cs %h"])
    [date, sha] = String.split(String.trim(out), " ")
    %{date: date, sha: sha}
  end

  # Sources become records: what the index shows and which files the site carries.
  defp logbook(root, dates) do
    for f <- Path.wildcard(Path.join(root, "logbook/*.md")) |> Enum.sort() do
      slug = Path.basename(f, ".md")
      words = slug |> String.replace_prefix("logbook-", "") |> String.split("-")

      %{
        kind: :log,
        group: hd(words),
        label: Enum.join(words, " "),
        href: "logbook/#{slug}.html",
        date: Map.get(dates, "logbook/#{slug}.md", ""),
        source: "logbook/#{slug}.md",
        files: [{f, "logbook/#{slug}.md"}]
      }
    end
  end

  defp rfds(dates) do
    for path <- RFD.Source.all(),
        dir = RFD.Source.dir_of(path),
        File.exists?(Path.join(dir, "README.md")) do
      d = RFD.Source.load(path)
      slug = Path.basename(dir)
      drafted = d.attest_in != :none && %{ai: "🧑‍🦰", human: "✍️"}[d.drafted_by]
      status = [Map.get(@emoji, to_string(d.state), "❔"), drafted, RFD.Doc.details(d) && "📎"]

      %{
        kind: :rfd,
        source: "rfd/#{slug}.exs",
        group: to_string(d.state),
        serial: d.serial,
        hook: d.hook && d.hook |> String.split() |> Enum.join(" "),
        label: shorten(d.title, &short/1),
        status: status |> Enum.reject(&(&1 in [nil, false])) |> Enum.join(" "),
        href: "rfd/#{slug}/",
        date: Map.get(dates, "rfd/#{slug}.exs", ""),
        files:
          for(
            f <- ["README.md", "DETAILS.md"],
            File.exists?(Path.join(dir, f)),
            do: {Path.join(dir, f), "rfd/#{slug}/#{f}"}
          )
      }
    end
  end

  defp copy(%{files: files} = e, out, slugs) do
    paired = length(files) == 2
    up = String.duplicate("../", length(Path.split(hd(files) |> elem(1))) - 1)

    for {from, to} <- files do
      File.mkdir_p!(Path.dirname(Path.join(out, to)))

      text =
        cond do
          not paired ->
            File.read!(from) |> linked(up, slugs, Map.get(e, :serial))

          Path.basename(to) == "README.md" ->
            merged(files) |> linked(up, slugs, Map.get(e, :serial))

          true ->
            details_moved()
        end

      File.write!(Path.join(out, to), edit_from(e.source, index_of(to)) <> text)
    end
  end

  defp details_moved do
    refresh = ~s(<meta http-equiv="refresh" content="0; url=./">)
    refresh <> "\n\nThe details moved to [the RFD page](./).\n"
  end

  defp merged([{readme, _}, {details, _}]) do
    top =
      File.read!(readme)
      |> String.replace("\n\n`DETAILS.md` carries the rest of this RFD.", "")
      |> then(&Regex.replace(~r/(^|[.!?]\s+|

)`DETAILS\.md`/, &1, fn _, pre -> pre <> "The details section" end))
      |> String.replace("`DETAILS.md`", "the details section")

    [_title, body] = String.split(File.read!(details), "\n", parts: 2)
    seen = String.split(top, ~r/\n\s*\n/) |> Enum.map(&String.trim/1)

    rest =
      body
      |> String.split(~r/\n\s*\n/)
      |> Enum.reject(&(String.trim(&1) in seen))
      |> Enum.join("\n\n")

    case String.split(top, "\n## Related", parts: 2) do
      [head, tail] ->
        String.trim_trailing(head) <> "\n\n" <> String.trim(rest) <> "\n\n## Related" <> tail

      [_] ->
        String.trim_trailing(top) <> "\n\n" <> String.trim(rest) <> "\n"
    end
  end

  # Names a reader would click become links: RFD serials, the blocklist, org repositories.
  @repo ~r{^(V-Sekai-fire|chibifire-smoke-water|chibifire-stages)/[A-Za-z0-9_.-]*[A-Za-z0-9_]$}

  defp linked(text, up, slugs, own) do
    {lines, _} =
      text
      |> String.split("\n")
      |> Enum.map_reduce(false, fn line, fenced ->
        cond do
          String.starts_with?(String.trim_leading(line), "```") -> {line, not fenced}
          fenced -> {line, fenced}
          String.starts_with?(line, "# ") -> {shorten(line, &short/1), fenced}
          true -> {link_line(line, up, slugs, own), fenced}
        end
      end)

    Enum.join(lines, "\n")
  end

  defp link_line(line, up, slugs, own) do
    line
    |> String.split(~r/(`[^`]*`)/, include_captures: true)
    |> Enum.map_join(fn
      "`" <> _ = code ->
        name = String.trim(code, "`")
        if Regex.match?(@repo, name), do: "[#{code}](https://github.com/#{name})", else: code

      prose ->
        prose
        |> shorten(&cite(&1, up, slugs, own))
        |> then(
          &Regex.replace(
            ~r/(?<![\[\w\/`-])BLOCKLIST\.md(?![\]\w])/,
            &1,
            "[BLOCKLIST.md](#{up}page-BLOCKLIST.html)"
          )
        )
    end)
  end

  defp found(%{files: [{_, to}, {_, _}]} = e) do
    [doc(merged(e.files), url_of(to), e.kind, Map.get(e, :status, ""), e.date)]
  end

  defp found(e) do
    for {from, to} <- e.files do
      kind = if Path.basename(to) == "DETAILS.md", do: :details, else: e.kind
      doc(File.read!(from), url_of(to), kind, Map.get(e, :status, ""), e.date)
    end
  end

  defp page_found(root, f) do
    path = Path.join(root, f)

    if File.exists?(path),
      do: [doc(File.read!(path), url_of("page-" <> f), :page, "", "")],
      else: []
  end

  defp doc(text, url, kind, status, date) do
    [title | body] = String.split(text, "\n", parts: 2)
    %{u: url, k: kind, s: status, d: date, t: plain(title), b: plain(Enum.join(body))}
  end

  defp url_of(to) do
    if Path.basename(to) == "README.md" and String.starts_with?(to, "rfd/"),
      do: Path.dirname(to) <> "/",
      else: String.replace_suffix(to, ".md", ".html")
  end

  defp plain(md) do
    md
    |> shorten(&short/1)
    |> String.replace(~r/<[^>]+>/, " ")
    |> String.replace(~r/!?\[([^\]]*)\]\([^)]*\)/, "\\1")
    |> String.replace(~r/[`*#>|]+|-{3,}/, " ")
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
  end

  defp logbook_page(logs) do
    {topics, single} =
      logs |> Enum.group_by(& &1.group) |> Enum.split_with(fn {_, es} -> length(es) > 1 end)

    groups =
      Enum.sort(topics) ++
        if(single == [], do: [], else: [{"other", single |> Enum.flat_map(&elem(&1, 1))}])

    body =
      Enum.map_join(groups, "\n\n", fn {g, es} ->
        "## #{g} (#{length(es)})\n\n" <> log_list(es)
      end)

    "# Logbook (#{length(logs)} entries)\n\nWhat the workspace measured, grouped by topic.\n\n" <>
      body
  end

  defp serials(root, rfds) do
    docs = Map.new(rfds, &{&1.serial, &1})

    sites =
      for path <- Path.wildcard(Path.join(root, "SERIALS*.exs")) |> Enum.sort() do
        r = RFD.Source.load(path)

        {dead, alive} =
          r.rows
          |> Enum.sort_by(&elem(&1, 1))
          |> Enum.map(fn {table, serial, slug, opts} ->
            {row_state(table, opts, docs, serial), serial, slug}
          end)
          |> Enum.split_with(fn {state, _, _} -> dead?(state) end)

        alive = Enum.sort_by(alive, fn {state, serial, _} -> {rank(state), serial} end)

        "## #{r.name} (site #{r.layer[:site]})\n\n#{r.thesis}\n\n" <>
          "<h3>Alive (#{length(alive)})</h3>\n\n" <>
          serial_table(alive, docs) <>
          "\n\n<details>\n<summary>Deleted, abandoned and retired " <>
          "(#{length(dead)})</summary>\n" <>
          "<p>Serials: #{ranges(dead)}</p>\n" <> serial_table(dead, docs) <> "\n</details>"
      end

    [
      edit_from("SERIALS.exs") <> "# Serials",
      "Every serial each register holds. Live documents come first, newest work on top. " <>
        "A dead serial keeps its row in the fold below, so a citation of it still names one " <>
        "document.",
      "Search ranks abandoned stubs below live documents."
      | sites
    ]
    |> Enum.join("\n\n")
  end

  defp dead?(state), do: state not in @alive

  defp rank(state), do: Enum.find_index(@alive, &(&1 == state))

  defp serial_table(rows, docs) do
    body =
      Enum.map_join(rows, "\n", fn {state, serial, slug} ->
        "<tr><td>#{serial_link(serial, docs)}</td><td>#{slug}</td><td>#{state}</td></tr>"
      end)

    "<table>\n<thead><tr><th>serial</th><th>slug</th><th>state</th></tr></thead>\n" <>
      "<tbody>\n#{body}\n</tbody>\n</table>"
  end

  defp serial_link(serial, docs) do
    case docs[serial] do
      nil -> short(serial)
      e -> ~s(<a href="#{e.href}">#{short(serial)}</a>)
    end
  end

  defp ranges(rows) do
    rows
    |> Enum.map(&elem(&1, 1))
    |> Enum.chunk_while(
      [],
      fn
        n, [] -> {:cont, [n]}
        n, [last | _] = run when n == last + 1 -> {:cont, [n | run]}
        n, run -> {:cont, Enum.reverse(run), [n]}
      end,
      fn
        [] -> {:cont, []}
        run -> {:cont, Enum.reverse(run), []}
      end
    )
    |> Enum.map_join(", ", fn
      [n] -> "#{n}"
      run -> "#{hd(run)}–#{List.last(run)}"
    end)
  end

  defp row_state(:allocated, _opts, docs, serial),
    do: if(docs[serial], do: docs[serial].group, else: "allocated")

  defp row_state(:retired, opts, _docs, _serial),
    do: "retired, recorded in #{short(opts[:recorded_in])}"

  defp row_state(table, _opts, _docs, _serial), do: String.replace(to_string(table), "_", " ")

  defp log_list(es), do: Enum.map_join(es, "\n", &"- [#{&1.label}](#{&1.href})")

  defp short(serial), do: "RFD66606-#{serial}"

  defp cite(n, up, slugs, own) do
    href = Map.get(slugs, n)
    if href && n != own, do: "[#{short(n)}](#{up}#{href})", else: short(n)
  end

  @serial "(?:RFD66606-)?\\d{4}"
  @cited ~r/(?<![\[\w\/-])(?:RFDs? |RFD66606-)(\d{4}(?:(?:,? and|,| or) #{@serial})*)(?![\]\w])/

  defp shorten(text, to) do
    Regex.replace(@cited, text, fn _, ns ->
      Regex.replace(~r/(?:RFD66606-)?(\d{4})/, ns, fn _, n -> to.(String.to_integer(n)) end)
    end)
  end

  defp single_page(root, logs, rfds, ed, slugs, out) do
    pages = for f <- @pages -- ["README.md"], File.exists?(Path.join(root, f)), do: f

    parts = [
      {"2", "Working agreements and reference pages",
       pages |> Enum.sort() |> Enum.map(&page_part(root, &1, slugs))},
      {"3", "RFDs", rfds |> Enum.sort_by(& &1.serial) |> Enum.map(&entry_part(&1, slugs))},
      {"4", "Logbook",
       logs |> Enum.sort_by(&{&1.date, &1.href}) |> Enum.map(&entry_part(&1, slugs))},
      {"A", "Serials", [{"page-SERIALS.html", "Serials", serials(root, rfds), "page-SERIALS.md"}]}
    ]

    numbered = for {n, title, docs} <- parts, do: {n, title, number_docs(n, docs)}
    ids = for {_, _, docs} <- numbered, d <- docs, into: %{}, do: {d.href, d.id}

    texts =
      for e <- rfds do
        %{
          serial: e.serial,
          label: e.label,
          state: e.group,
          id: ids[e.href],
          date: e.date,
          text: full_text(e)
        }
      end

    notes =
      for l <- logs do
        %{date: l.date, label: l.label, id: ids[l.href], text: full_text(l)}
      end

    tree = PagesTree.build(texts, notes, tree_repos(), ed.date)

    File.write!(
      Path.join(out, "assets/campus.domain.jsonld"),
      JSON.encode!(PagesTree.domain(tree))
    )

    File.write!(
      Path.join(out, "assets/campus.problem.jsonld"),
      JSON.encode!(PagesTree.problem(tree))
    )

    hero = navigator_block() <> "\n\n" <> map_block(tree) <> "\n\n<!--search-->"

    foreword =
      "## 1. The tech tree to the beta {#part-1}\n\n" <>
        "What the workspace measured (the logbook) and what it decided from that " <>
        "(the RFDs, also called requests for discussion, design docs or architecture " <>
        "decision records). #{tally(rfds)}\n\n" <>
        "This page holds the whole site: #{length(pages)} reference pages, " <>
        "#{length(rfds)} RFDs, #{length(logs)} logbook entries and the serial register. " <>
        "Each entry ends with a link to its own page. Search finds every RFD.\n\n" <>
        PagesTree.markdown(tree)

    body =
      Enum.map_join(numbered, "\n\n", fn {n, title, docs} ->
        head = if n == "A", do: "Appendix A: #{title}", else: "#{n}. #{title}"
        "## #{head} {#part-#{n}}\n\n" <> Enum.map_join(docs, "\n\n", &doc_text(&1, ids))
      end)

    [
      "---\nlayout: spec\ntitle: manuals-weftspun\nedit_source: scripts/pages_site.exs\n---",
      "# manuals-weftspun\n{: .title}",
      hero,
      "Edition of #{ed.date}, built from `#{ed.sha}`.\n{: .edition}",
      "## Table of Contents\n{: #toc-title .no_toc}\n\n* TOC\n{:toc}",
      foreword,
      body
    ]
    |> Enum.join("\n\n")
  end

  defp full_text(%{files: files}),
    do: Enum.map_join(files, "\n\n", fn {from, _} -> File.read!(from) end)

  defp tree_repos do
    [
      %{
        repo: "V-Sekai-fire/interactor-taskweft-persona",
        n: 2339,
        note:
          "It answers a goal with an exact plan from a planning domain, with no weights. " <>
            "The guest persona.elf runs on the godot-sandbox extension under libriscv, " <>
            "and the build runs through pixi."
      }
    ]
  end

  defp navigator_block do
    "<div id=\"navigator\" class=\"navigator\" markdown=\"0\">" <>
      "<noscript>The navigator needs a script. " <>
      "The journey below lists the same RFDs.</noscript></div>"
  end

  defp map_block(tree) do
    "<div id=\"journey\" class=\"journey\" markdown=\"0\"></div>\n" <>
      "<script type=\"application/json\" id=\"tree-data\">#{PagesTree.json(tree)}</script>\n" <>
      "<noscript>The journey needs a script. Section 1 holds the same facts as tables.</noscript>"
  end

  defp tally(rfds) do
    for s <- @states, n = Enum.count(rfds, &(&1.group == s)), n > 0 do
      "#{@emoji[s]} #{n} #{s}"
    end
    |> Enum.join(" · ")
  end

  defp page_part(root, f, slugs) do
    text = linked(File.read!(Path.join(root, f)), "", slugs, nil)
    {"page-" <> Path.rootname(f) <> ".html", first_title(text, f), text, f}
  end

  defp entry_part(%{files: files} = e, slugs) do
    text =
      case files do
        [_, _] -> merged(files)
        [{from, _}] -> File.read!(from)
      end

    {e.href, first_title(text, e.label), linked(text, "", slugs, Map.get(e, :serial)), e.source}
  end

  defp first_title(text, fallback) do
    text
    |> String.split("\n")
    |> Enum.find_value(fallback, &(String.starts_with?(&1, "# ") && plain(&1)))
  end

  defp number_docs(n, docs) do
    for {{href, title, text, source}, i} <- Enum.with_index(docs, 1) do
      label = if n == "A", do: "A", else: "#{n}.#{i}"
      id = "s" <> String.replace(label, ".", "-")
      %{href: href, id: id, label: label, title: title, text: text, source: source}
    end
  end

  defp doc_text(d, ids) do
    {items, _} =
      d.text
      |> String.split("\n")
      |> Enum.map_reduce({false, [0, 0, 0], false}, fn line, {fenced, count, seen} ->
        fence = String.starts_with?(String.trim_leading(line), "```")

        case {fenced or fence, Regex.run(~r/^(\#{1,6})\s+(.*?)\s*\#*$/, line)} do
          {true, _} -> {{:code, line}, {fenced != fence, count, seen}}
          {false, [_, marks, text]} -> heading(d, String.length(marks), text, count, seen)
          {false, nil} -> {{:text, line}, {false, count, seen}}
        end
      end)

    anchors = for {:heading, _, text, id} <- items, into: %{}, do: {slug(text), id}

    lines =
      Enum.flat_map(items, fn
        {:code, line} -> [line]
        {:text, line} -> [line |> relink(d, ids, anchors) |> unopened()]
        {:heading, line, _, _} -> [line]
        :skip -> []
      end)

    Enum.join(lines, "\n") <> "\n\n*Source: [#{d.source}](#{d.href})*"
  end

  defp heading(d, 1, text, count, false) do
    if d.label == "A",
      do: {:skip, {false, count, true}},
      else: {{:heading, "### #{d.label}. #{text} {##{d.id}}", text, d.id}, {false, count, true}}
  end

  defp heading(d, 1, text, count, true), do: heading(d, 2, text, count, true)

  defp heading(d, level, text, count, seen) when level <= 4 do
    k = level - 2

    count =
      count
      |> Enum.with_index()
      |> Enum.map(fn {c, i} -> if i < k, do: c, else: if(i == k, do: c + 1, else: 0) end)

    label = d.label <> "." <> (count |> Enum.take(k + 1) |> Enum.join("."))
    id = "s" <> String.replace(label, ".", "-")
    hashes = String.duplicate("#", if(d.label == "A", do: level + 1, else: level + 2))
    {{:heading, "#{hashes} #{label}. #{text} {##{id}}", text, id}, {false, count, seen}}
  end

  defp heading(_d, level, text, count, seen) do
    {{:text, String.duplicate("#", min(level + 2, 6)) <> " " <> text}, {false, count, seen}}
  end

  defp slug(text) do
    text
    |> String.replace(~r/!?\[([^\]]*)\]\([^)]*\)/, "\\1")
    |> String.replace(~r/[`*]/, "")
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}\s_-]/u, "")
    |> String.replace(~r/\s/u, "-")
  end

  defp relink(line, d, ids, anchors) do
    Regex.replace(~r/\]\(([^)\s]+)\)/, line, fn whole, target ->
      cond do
        String.starts_with?(target, "#") ->
          "](##{Map.get(anchors, String.trim_leading(target, "#"), d.id)})"

        Regex.match?(~r{^[a-z][a-z0-9+.-]*:}, target) ->
          whole

        true ->
          [path | frag] = String.split(target, "#", parts: 2)

          dir =
            "/" <>
              if(String.ends_with?(d.href, "/"),
                do: String.trim_trailing(d.href, "/"),
                else: Path.dirname(d.href)
              )

          at = path |> Path.expand(dir) |> String.trim_leading("/")
          found = Enum.find_value([at, at <> "/", details_owner(at)], &Map.get(ids, &1))
          if found, do: "](##{found})", else: "](#{at}#{Enum.map_join(frag, &("#" <> &1))})"
      end
    end)
  end

  @html ~w(a b br code details div em h1 h2 h3 h4 h5 h6 i img kbd li ol p pre span
           strong sub summary sup table tbody td th thead tr ul)

  # A line opening with an unknown tag (<card>) would make the rest of the page raw HTML.
  defp unopened(line) do
    Regex.replace(~r/^(\s*)<([A-Za-z][\w-]*)/, line, fn whole, space, tag ->
      if String.downcase(tag) in @html, do: whole, else: space <> "\\<" <> tag
    end)
  end

  defp details_owner(path) do
    if Path.basename(path) == "DETAILS.html", do: Path.dirname(path) <> "/"
  end

  defp spec_layout do
    ~S"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{{ site.title }}: {{ site.description }}</title>
        <style>
          :root { --muted: #666; --accent: #1a5fb4; --line: #ddd; --code: #f5f5f5; }
          body { margin: 0; font: 16px/1.6 "Noto Serif", Georgia, serif; color: #222; }
          h2#toc-title + ul { position: fixed; top: 0; left: 0; bottom: 0; width: 22rem;
            margin: 0;
            overflow: auto; padding: 3.2rem 1rem 1rem; border-right: 1px solid var(--line);
            background: #fafafa; font: 13px/1.4 system-ui, sans-serif; list-style: none; }
          h2#toc-title + ul ul { list-style: none; padding-left: .9rem; }
          h2#toc-title { position: fixed; top: 0; left: 0; width: 20rem; z-index: 2; margin: 0;
            padding: .8rem 1rem; background: #fafafa; font: 700 15px system-ui; border: 0; }
          main { margin-left: 22rem; max-width: 62rem; padding: 2rem 3rem; }
          main a { color: var(--accent); }
          h2#toc-title + ul a { text-decoration: none; }
          h1.title { margin: 0 0 1.2rem; font: 600 .95rem system-ui, sans-serif;
            letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }
          p.hook { margin: 0 0 .5rem; font-size: 2.2rem; line-height: 1.2; font-weight: 700; }
          p.intrigue { margin: 0 0 .8rem; font-size: 1.2rem; color: #444; }
          p.delivery { margin: 0 0 .4rem; }
          ul.features { margin: 0 0 .8rem; padding-left: 1.2rem; font-size: .95rem;
            line-height: 1.45; }
          p.exit { margin: 0 0 1rem; font-weight: 600; }
          .edition { color: var(--muted); font-size: .85rem; }
          h2 { margin-top: 3rem; padding-top: 1.5rem; font-size: 1.7rem;
            border-bottom: 2px solid var(--line); }
          h3 { margin-top: 2.5rem; padding-top: 1rem; font-size: 1.35rem;
            border-top: 1px solid var(--line); }
          h4 { font-size: 1.15rem; margin-top: 1.6rem; }
          h5, h6 { font-size: 1rem; }
          code, pre { background: var(--code); font: .88em Menlo, monospace; }
          pre { padding: .8rem; overflow: auto; border: 1px solid var(--line); }
          table { border-collapse: collapse; display: block; overflow: auto; }
          th, td { border: 1px solid var(--line); padding: .35rem .6rem; vertical-align: top; }
          .journey { margin: 0 0 1rem; font: 14px/1.4 system-ui, sans-serif; }
          .jr-track { display: flex; gap: .6rem; overflow-x: auto; align-items: flex-start;
            max-height: 58vh; padding-bottom: .4rem; }
          .jr-col { flex: 0 0 15rem; border: 1px solid var(--line); border-top: 4px solid #888;
            padding: .4rem .5rem; background: #fcfcfd; max-height: 56vh; overflow-y: auto; }
          .jr-col h4 { margin: 0; font-size: .95rem; }
          .jr-sub { margin: .1rem 0 .4rem; color: var(--muted); font-size: 12px; }
          .jr-done { border-top-color: #1a5fb4; }
          .jr-now { border-top-color: #e67e00; background: #fff8ee; }
          .jr-origin { border-top-color: #2e7d32; }
          .jr-text { margin: 0; font-size: 12.5px; }
          .jr-end { border-top-color: #f2c94c; background: #fffbea; }
          .jr-chip { display: block; margin: 0 0 .25rem; padding: .15rem .4rem; font-size: 12px;
            border: 1px solid var(--line); border-left: 5px solid #bbb; background: #fff;
            color: #222; text-decoration: none; overflow: hidden; text-overflow: ellipsis;
            white-space: nowrap; }
          .jr-chip.done { background: #e8f0fb; }
          .jr-chip.ready { border-color: #e67e00; }
          .jr-chip.early { border-style: dashed; border-color: #c0392b; }
          .navigator { margin: 0 0 1rem; padding: .6rem .8rem; border: 1px solid var(--line);
            border-left: 5px solid var(--accent); background: #f7faff;
            font: 14px/1.45 system-ui, sans-serif; }
          .nv-title { margin: 0 0 .4rem; padding: 0; border: 0; font-size: 1rem; }
          .nv-row { display: flex; flex-wrap: wrap; gap: .5rem; align-items: center; }
          .nv-row label { font-weight: 600; }
          .nv-row select { flex: 1 1 14rem; min-width: 0; max-width: 100%; padding: .3rem; }
          .navigator button { padding: .3rem .7rem; font: inherit; cursor: pointer; }
          .navigator button[aria-pressed="true"] { background: var(--accent); color: #fff; }
          .nv-status { margin: .4rem 0 0; color: var(--muted); font-size: 13px; }
          .nv-refused { color: #c0392b; font-weight: 600; }
          .nv-steps { margin: .3rem 0 0; padding-left: 1.4rem; max-height: 14rem;
            overflow: auto; }
          .nv-console textarea { width: 100%; box-sizing: border-box;
            font: 12px/1.35 Menlo, monospace; }
          blockquote { margin: 1rem 0; padding: .2rem 1rem; background: #f0f6ff;
            border-left: 4px solid var(--accent); }
          @media (max-width: 1000px) {
            h2#toc-title + ul, h2#toc-title { position: static; width: auto; border: 0; }
            main { margin: 0; padding: 1rem; }
          }
          @media print {
            h2#toc-title + ul, h2#toc-title { position: static; width: auto; }
            main { margin: 0; }
          }
        </style>
      </head>
      <body>
        <main>
          {% capture search %}
          <div id="site-search" role="search" data-base="{{ "/" | relative_url }}">
            <input type="search"
              placeholder="Search RFDs, the logbook and the agreements (press /)"
              aria-label="Search the site" autocomplete="off" spellcheck="false">
            <p hidden></p>
            <ol hidden></ol>
          </div>
          {% endcapture %}
          {{ content | replace: "<!--search-->", search }}
        </main>
        <script src="{{ "/assets/search.js" | relative_url }}" defer></script>
        <script src="{{ "/assets/tree.js" | relative_url }}" defer></script>
        <script src="{{ "/assets/navigator.js" | relative_url }}" defer></script>
      </body>
    </html>
    """
  end

  # The theme's edit link points at the generated copy; this one points at the tracked source.
  defp edit_from(source, permalink \\ nil) do
    at = if permalink, do: "permalink: #{permalink}\n", else: ""
    "---\nedit_source: #{source}\n#{at}---\n"
  end

  defp index_of("rfd/" <> _ = to),
    do: if(Path.basename(to) == "README.md", do: "/#{Path.dirname(to)}/")

  defp index_of(_), do: nil

  defp layout do
    ~S"""
    <!DOCTYPE html>
    <html lang="{{ page.lang | default: site.lang | default: "en-US" }}">
      <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    {% seo %}
        {% assign css = "/assets/css/style.css?v=" | append: site.github.build_revision %}
        <link rel="stylesheet" href="{{ css | relative_url }}">
        {% include head-custom.html %}
      </head>
      <body>
        <div class="container-lg px-3 my-5 markdown-body">
          {% if site.title and site.title != page.title %}
          <h1><a href="{{ "/" | absolute_url }}">{{ site.title }}</a></h1>
          {% endif %}
          <div id="site-search" role="search" data-base="{{ "/" | relative_url }}">
            <input type="search"
              placeholder="Search RFDs, the logbook and the agreements (press /)"
              aria-label="Search the site" autocomplete="off" spellcheck="false">
            <p hidden></p>
            <ol hidden></ol>
          </div>

          {{ content }}

          {% if page.edit_source %}
          <div class="footer border-top border-gray-light mt-5 pt-3 text-right text-gray">
            This site is open source.
            <a href="{{ site.github.repository_url }}/edit/main/{{ page.edit_source }}">
              Improve this page</a>.
          </div>
          {% endif %}
        </div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.1.0/anchor.min.js"
          integrity="sha256-lZaRhKri35AyJSypXXs4o6OPFTbTmUoltBbDCbdzegg="
          crossorigin="anonymous"></script>
        <script>anchors.add();</script>
        <script src="{{ "/assets/search.js" | relative_url }}" defer></script>
      </body>
    </html>
    """
  end

  defp config do
    """
    title: manuals-weftspun
    description: Logbook, RFDs and working agreements
    theme: jekyll-theme-primer
    kramdown:
      toc_levels: 2..4
    """
  end
end

PagesSite.main(System.argv())
