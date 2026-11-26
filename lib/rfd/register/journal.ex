# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Register.Journal do
  @moduledoc """
  The serial registers read from tackler journals; `SERIALS*.exs` is not
  their source (operator, 2026-11-26).

  An allocated serial is its RFD, `rfd/NNNN-slug.txn`. Its title
  transaction, dated the registration day and coded `RFD66606-NNNN`,
  posts `RFD:<State>  1 RFD` from `Serials:<Site>`. The slug is the file
  name, and allocated rows run in serial order, the order they were
  appended in. The register's flight level of an allocated row is the
  register's own column, not the RFD's `rfd:flight-level:` title tag:
  the two were recorded apart and 35 of them disagree, so the register's
  stays in `journal/serials.txn` until a ruling joins them.

  `journal/serials.txn` holds the rest, one entity per code, each
  transaction of an entity on its own second so the order survives
  tackler's sort:

  - a site, coded `SITE66606-N`. Its title is the register's name,
    tagged `site:title` and `site:category:N`. Each line of a property is
    one more transaction tagged with it: `site:arc`, `site:site-name`,
    `site:category-name`, `site:pen`, `site:rule`, `site:note:<kind>`,
    `site:thesis`. The sections follow in order: `site:section` names
    one (allocated, unused or deleted), `site:section-note` carries its
    note, and `site:row` lists its rows by code in register order. Under
    allocated, `site:flight-level:lN` names an allocated row by code with
    the register's flight level for it. A line of text is one
    transaction however long it is: a sentence is never broken up for
    line length (operator, 2026-11-26).
  - a serial with no RFD, coded `RFD66606-NNNN` and dated the day it was
    registered: one transaction, tagged `serial:row`, that posts
    `Serials:<Site>:Deleted`, `:Retired` or `:NeverWritten`  1 RFD from
    `Serials:<Site>`. A deleted row's description is its slug; a
    `serial:flight-level:lN` or `serial:recorded-in:NNNN` tag carries the
    field where it is set.

  `registers/1` builds the `%RFD.Register{}` of every site; `write/1` and
  `read!/1` turn the journal's model into text and back.
  """

  alias RFD.Txn.Parser

  @path "journal/serials.txn"
  @site "SITE66606-"
  @serial "RFD66606-"
  @tables %{"Deleted" => :deleted, "Retired" => :retired, "NeverWritten" => :never_written}
  @home %{deleted: :deleted, retired: :deleted, never_written: :unused}
  @kinds %{"allocated" => :allocated, "unused" => :unused, "deleted" => :deleted}
  @props [
    {"site:arc", :arc},
    {"site:site-name", :site_name},
    {"site:category-name", :category_name},
    {"site:pen", :pen},
    {"site:rule", :rule}
  ]

  def path, do: @path

  @doc "Every site's register, from `journal/serials.txn` and `rfd/*.txn` under `root`."
  def registers(root) do
    model = root |> Path.join(@path) |> File.read!() |> read!()
    build(model, titles(root))
  end

  @doc "The journal in its written form: what `write/1` gives for the model it holds."
  def canonical(text), do: text |> read!() |> write()

  # -- reading --------------------------------------------------------------------

  @doc "The model a journal holds: `%{sites: [...], rows: %{serial => row}}`."
  def read!(text) do
    txns =
      case Parser.parse(text) do
        {:ok, txns} -> txns
        {:error, {l, c, msg}} -> raise ArgumentError, "#{@path}: line #{l}, column #{c}: #{msg}"
      end

    for t <- txns, t.comments != [] do
      raise ArgumentError, "#{@path}: line #{t.line}: a comment is not durable data"
    end

    {sites, rows} =
      txns
      |> Enum.group_by(& &1.code)
      |> Enum.map(fn {code, ts} -> {code, in_order(code, ts)} end)
      |> Enum.split_with(fn {code, _} -> String.starts_with?(code || "", @site) end)

    %{
      sites: sites |> Enum.map(fn {code, ts} -> site(code, ts) end) |> Enum.sort_by(& &1.site),
      rows: Map.new(rows, fn {code, ts} -> code |> row(ts) |> then(&{&1.serial, &1}) end)
    }
  end

  defp in_order(code, ts) do
    sorted = Enum.sort_by(ts, & &1.timestamp)

    if length(Enum.uniq_by(sorted, & &1.timestamp)) != length(sorted) do
      raise ArgumentError, "#{@path}: two transactions of #{code} share a second"
    end

    sorted
  end

  defp site(@site <> n = code, [%{tags: ["site:title" | scalars]} = title | rest]) do
    site = String.to_integer(n)
    for t <- [title | rest], do: postings!(t, {"Text:Site#{n}", "LINE"}, "Text:Written")

    category =
      case scalars do
        ["site:category:" <> c] -> String.to_integer(c)
        other -> raise ArgumentError, "#{code}: title tags #{inspect(other)}"
      end

    acc =
      rest
      |> Enum.reduce(%{layer: %{site: site, category: category}, thesis: nil, sections: []}, fn
        %{tags: [tag]} = t, acc -> put(code, tag, t.description || "", acc)
        t, _ -> raise ArgumentError, "#{code}: line #{t.line}: tags #{inspect(t.tags)}"
      end)

    sections =
      acc.sections
      |> Enum.reverse()
      |> Enum.map(fn {kind, note, rows} -> {kind, note, Enum.reverse(rows)} end)

    %{
      site: site,
      name: title.description,
      day: day(title),
      layer: acc.layer,
      thesis: acc.thesis,
      sections: sections
    }
  end

  defp site(code, _),
    do: raise(ArgumentError, "#{code}: the first transaction is not a site title")

  defp put(code, "site:note:" <> kind, s, acc) do
    k = String.to_atom(kind)

    note =
      case acc.layer[:note] do
        nil -> {k, s}
        {^k, text} -> {k, text <> "\n" <> s}
        _ -> raise ArgumentError, "#{code}: a second note"
      end

    put_in(acc.layer[:note], note)
  end

  defp put(_code, "site:thesis", s, acc), do: %{acc | thesis: append(acc.thesis, s)}

  defp put(code, "site:section", s, acc) do
    kind = Map.get(@kinds, s) || raise ArgumentError, "#{code}: no section kind #{s}"
    %{acc | sections: [{kind, nil, []} | acc.sections]}
  end

  defp put(_code, "site:section-note", s, %{sections: [{k, note, rows} | rest]} = acc),
    do: %{acc | sections: [{k, append(note, s), rows} | rest]}

  defp put(_code, "site:flight-level:" <> l, @serial <> n, acc)
       when l in ~w(l1 l2 l3) and elem(hd(acc.sections), 0) == :allocated do
    [{:allocated, note, levels} | rest] = acc.sections
    level = {String.to_integer(n), String.to_atom(l)}
    %{acc | sections: [{:allocated, note, [level | levels]} | rest]}
  end

  defp put(_code, "site:row", @serial <> n, %{sections: [{k, note, rows} | rest]} = acc)
       when k != :allocated,
       do: %{acc | sections: [{k, note, [String.to_integer(n) | rows]} | rest]}

  defp put(code, tag, s, acc) do
    case List.keyfind(@props, tag, 0) do
      {_, key} ->
        put_in(acc.layer[key], append(acc.layer[key], s))

      nil ->
        raise ArgumentError, "#{code}: #{tag} #{inspect(s)} has no place here"
    end
  end

  defp append(nil, s), do: s
  defp append(text, s), do: text <> "\n" <> s

  defp row(@serial <> n = code, [%{tags: ["serial:row" | scalars]} = t]) do
    [%{account: "Serials:" <> to} | _] = t.postings
    [site, table_name] = String.split(to, ":")
    postings!(t, {"Serials:#{site}:#{table_name}", "RFD"}, "Serials:#{site}")
    table = Map.get(@tables, table_name) || raise ArgumentError, "#{code}: no table #{to}"

    if table == :deleted != is_binary(t.description) do
      raise ArgumentError, "#{code}: only a deleted row carries a slug, and it always does"
    end

    %{
      serial: String.to_integer(n),
      day: day(t),
      site: site,
      table: table,
      slug: t.description,
      opts: Enum.map(scalars, &opt(code, &1))
    }
  end

  defp row(code, _), do: raise(ArgumentError, "#{@path}: #{code} is not one register row")

  defp opt(_code, "serial:flight-level:" <> l) when l in ~w(l1 l2 l3),
    do: {:flight_level, String.to_atom(l)}

  defp opt(_code, "serial:recorded-in:" <> n), do: {:recorded_in, String.to_integer(n)}
  defp opt(code, tag), do: raise(ArgumentError, "#{code}: unknown row tag #{tag}")

  defp postings!(t, {debit, unit}, credit) do
    got = Enum.map(t.postings, &{&1.account, &1.amount, &1.commodity})

    if got != [{debit, "1", unit}, {credit, nil, nil}] do
      raise ArgumentError, "#{@path}: line #{t.line}: postings #{inspect(got)}"
    end
  end

  defp day(%{timestamp: ts}), do: String.slice(ts, 0, 10)

  # -- the RFD journals -----------------------------------------------------------

  @doc "Each RFD journal's title, as the allocated row it is."
  def titles(root) do
    for path <- Path.wildcard(Path.join(root, "rfd/[0-9][0-9][0-9][0-9]-*.txn")) do
      name = Path.basename(path, ".txn")
      title = title!(path, File.read!(path))
      @serial <> n = title.code

      if n != String.slice(name, 0, 4) do
        raise ArgumentError, "#{path}: coded #{title.code}, named #{name}"
      end

      site =
        case List.last(title.postings) do
          %{account: "Serials:" <> site, amount: nil} -> site
          _ -> raise ArgumentError, "#{path}: the title posts from no Serials: site"
        end

      %{serial: String.to_integer(n), slug: String.slice(name, 5..-1//1), site: site}
    end
  end

  # The written form puts the title first, so its block is read alone; any other
  # shape is read whole and its earliest transaction taken, as RFD.Txn reads it.
  defp title!(path, text) do
    first = text |> String.trim_leading() |> String.split(~r/\n[ \t]*\n/, parts: 2) |> hd()

    case Parser.parse(first <> "\n") do
      {:ok, [%{tags: ["rfd:title" | _]} = t]} ->
        t

      _ ->
        case Parser.parse(text) do
          {:ok, [_ | _] = txns} ->
            t = Enum.min_by(txns, &instant/1)

            if match?(["rfd:title" | _], t.tags),
              do: t,
              else: raise(ArgumentError, "#{path}: the first transaction is not an RFD title")

          {:ok, []} ->
            raise ArgumentError, "#{path}: an empty journal"

          {:error, {l, c, msg}} ->
            raise ArgumentError, "#{path}: line #{l}, column #{c}: #{msg}"
        end
    end
  end

  defp instant(%{timestamp: <<_::binary-10>> = day}), do: day <> "T00:00:00Z"
  defp instant(%{timestamp: ts}), do: ts

  # -- the registers ----------------------------------------------------------------

  @doc "The registers a model and the RFD titles make, each validated."
  def build(%{sites: sites, rows: rows}, titles) do
    names = MapSet.new(sites, & &1.name)

    for t <- titles, not MapSet.member?(names, t.site) do
      raise ArgumentError, "RFD #{t.serial} posts from Serials:#{t.site}, which #{@path} lacks"
    end

    listed =
      for s <- sites,
          {kind, _, serials} <- s.sections,
          kind != :allocated,
          n <- serials,
          do: {n, {s.name, kind}}

    for {n, _} <- listed -- Enum.uniq_by(listed, &elem(&1, 0)) do
      raise ArgumentError, "#{@path}: #{@serial}#{n} is listed twice"
    end

    where = Map.new(listed)

    for {n, r} <- rows, where[n] != {r.site, @home[r.table]} do
      raise ArgumentError,
            "#{@path}: #{@serial}#{n} belongs in #{r.site}'s #{@home[r.table]} section"
    end

    for {n, _} <- listed, not Map.has_key?(rows, n) do
      raise ArgumentError, "#{@path}: #{@serial}#{n} is listed and has no row"
    end

    for s <- sites do
      own = titles |> Enum.filter(&(&1.site == s.name)) |> Enum.sort_by(& &1.serial)

      if own != [] and not Enum.any?(s.sections, &(elem(&1, 0) == :allocated)) do
        raise ArgumentError, "#{s.name}: RFDs post from the site, and it has no allocated section"
      end

      register_rows =
        Enum.flat_map(s.sections, fn
          {:allocated, _, levels} ->
            levels = Map.new(levels)

            for {n, _} <- levels, not Enum.any?(own, &(&1.serial == n)) do
              raise ArgumentError, "#{@path}: #{@serial}#{n} has a flight level and no RFD"
            end

            for t <- own do
              opts = if levels[t.serial], do: [flight_level: levels[t.serial]], else: []
              {:allocated, t.serial, t.slug, opts}
            end

          {_, _, serials} ->
            for n <- serials, r = Map.fetch!(rows, n), do: {r.table, n, r.slug, r.opts}
        end)

      RFD.Register.validate!(%RFD.Register{
        name: s.name,
        layer: s.layer,
        thesis: s.thesis,
        sections: Enum.map(s.sections, fn {kind, note, _} -> {kind, note} end),
        rows: register_rows
      })
    end
  end

  @doc """
  The model of registers that carry their own allocated rows, as `SERIALS*.exs`
  did: `day_of` gives the day each serial was registered.
  """
  def model(registers, day_of) do
    sites =
      for r <- Enum.sort_by(registers, & &1.layer.site) do
        %{
          site: r.layer.site,
          name: r.name,
          day: day_of.(r.layer.site * 1000),
          layer: r.layer,
          thesis: r.thesis,
          sections:
            for {kind, note} <- r.sections do
              serials =
                if kind == :allocated,
                  do:
                    for(
                      {:allocated, n, _, o} <- r.rows,
                      o[:flight_level],
                      do: {n, o[:flight_level]}
                    ),
                  else: for({t, n, _, _} <- r.rows, @home[t] == kind, do: n)

              {kind, note, serials}
            end
        }
      end

    rows =
      for r <- registers, {t, n, slug, opts} <- r.rows, t != :allocated, into: %{} do
        {n, %{serial: n, day: day_of.(n), site: r.name, table: t, slug: slug, opts: opts}}
      end

    %{sites: sites, rows: rows}
  end

  # -- writing --------------------------------------------------------------------

  @doc "The journal text of a model."
  def write(%{sites: sites, rows: rows}) do
    blocks =
      Enum.map(sites, &site_text/1) ++
        for s <- sites, {kind, _, serials} <- s.sections, kind != :allocated, n <- serials do
          row_text(Map.fetch!(rows, n))
        end

    Enum.join(blocks, "\n")
  end

  defp site_text(s) do
    code = @site <> Integer.to_string(s.site)
    post = " Text:Site#{s.site}  1 LINE\n Text:Written\n"
    l = s.layer

    title =
      header(s.day, 0, code, s.name) <>
        " # uuid: #{RFD.Txn.v5("site", code)}\n" <>
        " # tags: site:title, site:category:#{l.category}\n" <> post

    note =
      case l[:note] do
        {kind, text} -> [{"site:note:#{kind}", text}]
        nil -> []
      end

    props =
      for({tag, key} <- @props, do: {tag, Map.fetch!(l, key)}) ++
        note ++
        [{"site:thesis", s.thesis}] ++
        Enum.flat_map(s.sections, fn {kind, n, serials} ->
          [{"site:section", Atom.to_string(kind)}] ++
            if(n, do: [{"site:section-note", n}], else: []) ++
            for(r <- serials, do: row_line(kind, r))
        end)

    lines =
      props
      |> Enum.flat_map(fn {tag, text} ->
        for line <- String.split(text, "\n"), do: {tag, line}
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {{tags, desc}, i} ->
        header(s.day, i, code, desc) <> " # tags: #{tags}\n" <> post
      end)

    Enum.join([title | lines], "\n")
  end

  defp row_line(:allocated, {n, l}),
    do: {"site:flight-level:#{l}", @serial <> Integer.to_string(n)}

  defp row_line(_kind, n), do: {"site:row", @serial <> Integer.to_string(n)}

  defp row_text(r) do
    code = @serial <> Integer.to_string(r.serial)
    table = Enum.find_value(@tables, fn {name, t} -> if t == r.table, do: name end)

    tags =
      ["serial:row"] ++
        for {k, v} <- r.opts do
          case k do
            :flight_level -> "serial:flight-level:#{v}"
            :recorded_in -> "serial:recorded-in:#{v}"
          end
        end

    "#{RFD.Txn.at(r.day, 0)} (#{code})" <>
      if(r.slug, do: " '#{r.slug}", else: "") <>
      "\n # uuid: #{RFD.Txn.v5("serial", code)}\n" <>
      " # tags: #{Enum.join(tags, ", ")}\n" <>
      " Serials:#{r.site}:#{table}  1 RFD\n Serials:#{r.site}\n"
  end

  defp header(day, n, code, desc), do: "#{RFD.Txn.at(day, n)} (#{code}) '#{desc}\n"
end
