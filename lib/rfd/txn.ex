# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Txn do
  @moduledoc """
  An RFD as a tackler journal. Every transaction carries the serial's
  registration day and its code, `RFD66606-NNNN`. The first is the
  title: it moves the serial from its site into its state. Each line of
  a property is one more transaction, its description the line and its
  tag the property, so a property's metadata runs and only the text
  changes. A line is one transaction, however long. A value ends in a
  newline unless its last line is also tagged `rfd:no-final-newline`.

  `write/2` writes a `%RFD.Doc{}` out; `parse/1` reads one back through
  `RFD.DSL.build/6`, so every check of the DSL runs on it.
  """

  alias RFD.Txn.Parser

  @states ~w(prediscussion ideation discussion published committed abandoned)a
  @text ~w(feature scope front_matter preamble hook intrigue exit
           details_title details_preamble abandoned_at)a
  @spine ~w(decision related references)a
  @scalars ~w(flight_level attest_in details_pointer compact_head drafted_by)a
  @ns <<0x6BA7B811::32, 0x9DAD::16, 0x11D1::16, 0x80B4::16, 0x00C04FD430C8::48>>
  @base "https://github.com/V-Sekai-fire/rfds/"

  @doc "The journal text of a doc registered on `day` under `site`."
  def write(%RFD.Doc{} = d, opts) do
    day = Keyword.fetch!(opts, :day)
    site = Keyword.fetch!(opts, :site)
    code = "RFD66606-#{d.serial}"
    t = %{day: day, code: code, text: "Text:RFD#{d.serial}"}
    state = "RFD:" <> camel(d.state)

    title =
      header(at(day, 0), code, d.title) <>
        " # uuid: #{v5("rfd", code)}\n" <>
        " # tags: #{Enum.join(["rfd:title" | scalar_tags(d)], ", ")}\n" <>
        " #{state}  1 RFD\n Serials:#{site}\n"

    body =
      Enum.flat_map(@text, &text(t, "rfd:#{dash(&1)}", Map.get(d, &1))) ++
        Enum.flat_map(d.order, &spine(t, d, &1)) ++
        Enum.flat_map(d.details, &detail(t, &1, opts[:madr] == true)) ++
        rebac(t, d.rebac) ++
        Enum.flat_map(d.steps, &term(t, "rfd:step", &1))

    lines =
      body
      |> Enum.with_index(1)
      |> Enum.map(fn {e, i} ->
        header(at(day, i), code, e.desc) <>
          " # tags: #{e.tags}\n #{t.text}  1 LINE\n Text:Written\n"
      end)

    Enum.join([title | lines], "\n")
  end

  @doc "The timestamp of an RFD's n-th transaction: its registration day, second n."
  def at(day, n) when n in 0..86_399 do
    [h, m, s] = Enum.map([div(n, 3600), div(rem(n, 3600), 60), rem(n, 60)], &pad/1)
    "#{day}T#{h}:#{m}:#{s}Z"
  end

  def at(_day, n), do: raise(ArgumentError, "an RFD of #{n} lines has no second left in its day")

  defp pad(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")

  defp spine(t, d, {:section, h}) do
    {^h, body} = List.keyfind(d.sections, h, 0)
    line(t, "rfd:section-heading", h) ++ text(t, "rfd:section", body)
  end

  defp spine(_t, %{abandoned_at: sha}, :decision) when is_binary(sha), do: []
  defp spine(t, d, key), do: text(t, "rfd:#{key}", Map.fetch!(d, key))

  defp detail(t, {h, body}, madr?) do
    madr_heading? = madr? and h in Keyword.values(RFD.DSL.madr_sections())
    tag = if madr_heading?, do: "rfd:madr-heading", else: "rfd:details-heading"
    line(t, tag, h) ++ text(t, "rfd:details", body)
  end

  defp rebac(_t, nil), do: []

  defp rebac(t, r) do
    Enum.flat_map(r.verbs_from, &line(t, "rebac:verbs-from", "#{&1}")) ++
      Enum.flat_map(r.verbs, fn v ->
        line(t, "rebac:verb", Atom.to_string(v.name)) ++
          text(t, "rebac:meaning", v.meaning)
      end) ++
      Enum.flat_map(r.tuples, &tuple(t, &1)) ++
      Enum.flat_map(r.capabilities, &capability(t, &1)) ++
      Enum.flat_map(r.renders_into, &renders_into(t, &1))
  end

  defp capability(t, c) do
    line(t, "rebac:capability", Atom.to_string(c.name)) ++
      line(t, "rebac:capability-verb", Atom.to_string(c.verb)) ++
      if(c.object, do: line(t, "rebac:capability-object", c.object), else: []) ++
      Enum.flat_map(c.caveats, &line(t, "rebac:caveat", Atom.to_string(&1)))
  end

  defp renders_into(t, {path, subject}) do
    line(t, "rebac:renders-into", path) ++
      if(subject, do: line(t, "rebac:renders-subject", subject), else: [])
  end

  defp tuple(t, %{subject: s, verb: v, object: o} = row) do
    for x <- [s, o], not (is_binary(x) and not String.contains?(x, " ")) do
      raise ArgumentError, "rebac tuple #{inspect(row)}: a name with a space"
    end

    tag = if row.deny, do: "rebac:deny", else: "rebac:relate"
    line(t, tag, "#{s} #{v} #{o}") ++ text(t, "rebac:reason", row.reason)
  end

  defp term(t, tag, value) do
    line(t, tag, inspect(value, limit: :infinity, printable_limit: :infinity))
  end

  defp text(_t, _tag, nil), do: []

  defp text(t, tag, s) when is_binary(s) do
    {body, open?} =
      if String.ends_with?(s, "\n"),
        do: {String.replace_suffix(s, "\n", ""), false},
        else: {s, true}

    lines = String.split(body, "\n")
    last = length(lines)

    lines
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {l, i} ->
      line(t, if(open? and i == last, do: tag <> ", rfd:no-final-newline", else: tag), l)
    end)
  end

  defp line(t, tag, s) do
    if s != String.trim_trailing(s) do
      raise ArgumentError, "#{t.code} #{tag}: a line ends in whitespace"
    end

    [%{desc: s, tags: tag}]
  end

  defp header(ts, code, desc), do: "#{ts} (#{code}) '#{desc}\n"

  defp scalar_tags(d) do
    blank = struct(RFD.Doc, serial: d.serial, title: d.title)

    for k <- @scalars, Map.get(d, k) != Map.get(blank, k) do
      "rfd:#{dash(k)}:#{Map.get(d, k)}"
    end
  end

  @doc "A doc read back from journal text, through the DSL's checks."
  def parse(text) do
    case Parser.parse(text) do
      {:ok, [_ | _] = txns} ->
        [title | rest] = Enum.sort_by(txns, &instant/1)
        build(title, rest)

      {:ok, []} ->
        {:error, "an empty journal"}

      {:error, {line, col, msg}} ->
        {:error, "line #{line}, column #{col}: #{msg}"}
    end
  end

  defp instant(%{timestamp: <<_::binary-10>> = day}), do: day <> "T00:00:00Z"
  defp instant(%{timestamp: ts}), do: ts

  @doc "The doc with `&{...}` references as written, not expanded."
  def parse_raw!(text), do: RFD.DSL.unexpanded(fn -> parse!(text) end)

  @doc "Every text of a doc, joined: what `&{...}` references and prose checks read."
  def prose(%RFD.Doc{} = d) do
    pairs = Enum.flat_map(d.details ++ d.sections, fn {h, b} -> [h, b] end)

    rebac =
      if d.rebac,
        do: Enum.flat_map(d.rebac.tuples, &[&1.reason]) ++ Enum.map(d.rebac.verbs, & &1.meaning),
        else: []

    (Enum.map(@text ++ @spine, &Map.get(d, &1)) ++ [d.title | pairs] ++ rebac)
    |> Enum.filter(&is_binary/1)
    |> Enum.join("\n")
  end

  @doc "The day an RFD's serial was registered: its title transaction's date."
  def registered_on(text) do
    case Parser.parse(text) do
      {:ok, txns} ->
        txns |> Enum.min_by(&instant/1) |> Map.fetch!(:timestamp) |> String.slice(0, 10)

      {:error, {line, col, msg}} ->
        raise ArgumentError, "line #{line}, column #{col}: #{msg}"
    end
  end

  @doc "The journal in its written form: what `write/2` gives for the doc it holds."
  def canonical(text) do
    d = parse_raw!(text)
    site = if div(d.serial, 1000) == 1, do: "Weftspun", else: "VSekaiFabric"
    madr? = String.contains?(text, "# tags: rfd:madr-heading")
    write(d, day: registered_on(text), site: site, madr: madr?)
  end

  def parse!(text) do
    case parse(text) do
      {:ok, d} -> d
      {:error, e} -> raise ArgumentError, e
    end
  end

  defp build(%{code: "RFD66606-" <> n, tags: ["rfd:title" | scalars]} = title, rest) do
    serial = String.to_integer(n)
    [%{account: "RFD:" <> state, amount: "1", commodity: "RFD"} | _] = title.postings

    for t <- [title | rest], t.comments != [] do
      raise ArgumentError, "line #{t.line}: a comment is not durable data"
    end

    acc =
      rest
      |> Enum.reduce(empty(), &step/2)

    fields =
      [state: acc.state || state(state)] ++
        Enum.map(scalars, &scalar/1) ++
        for(k <- @text ++ @spine, v = acc.text[k], v != nil, do: {k, v}) ++
        rebac_field(serial, acc.rebac) ++
        if(acc.steps == [], do: [], else: [steps: Enum.reverse(acc.steps)])

    if acc.madr != [], do: madr!(serial, Enum.reverse(acc.madr))

    try do
      {:ok,
       RFD.DSL.build(
         serial,
         title.description,
         Enum.reverse(fields),
         acc.details,
         acc.sections,
         acc.order
       )}
    rescue
      e in ArgumentError -> {:error, Exception.message(e)}
    end
  end

  defp build(_, _), do: {:error, "the first transaction is not an RFD title"}

  defp empty do
    %{text: %{}, order: [], details: [], sections: [], madr: []}
    |> Map.merge(%{rebac: [], steps: [], at: nil, state: nil})
  end

  @text_tags ~w(rfd:section rfd:details rebac:meaning rebac:reason)

  defp step(%{tags: [tag, "rfd:no-final-newline"]} = t, acc),
    do: put(tag, t.description || "", acc)

  defp step(%{tags: [tag]} = t, acc) do
    s = t.description || ""
    if text_tag?(tag), do: put(tag, s <> "\n", acc), else: put(tag, s, acc)
  end

  defp step(%{tags: tags}, _acc), do: raise(ArgumentError, "tags #{inspect(tags)} on a line")

  defp text_tag?(tag) do
    tag in @text_tags or
      Enum.any?(@text ++ @spine, &("rfd:" <> dash(&1) == tag))
  end

  defp put("rfd:state", s, acc), do: %{acc | state: state(s), at: nil}

  defp put("rfd:section-heading", h, acc),
    do: %{
      acc
      | at: {:section, h},
        order: [{:section, h} | acc.order],
        sections: [{h, nil} | acc.sections]
    }

  defp put("rfd:section", s, %{at: {:section, _}} = acc),
    do: %{acc | sections: add(acc.sections, s)}

  defp put("rfd:details-heading", h, acc),
    do: %{acc | at: :details, details: [{h, nil} | acc.details]}

  defp put("rfd:madr-heading", h, acc),
    do: %{acc | at: :details, details: [{h, nil} | acc.details], madr: [h | acc.madr]}

  defp put("rfd:details", s, %{at: :details} = acc), do: %{acc | details: add(acc.details, s)}

  defp put("rebac:verbs-from", s, acc),
    do: %{acc | rebac: [{:verbs_from, String.to_integer(s)} | acc.rebac], at: nil}

  defp put("rebac:verb", s, acc),
    do: %{acc | rebac: [{:verb, %{name: String.to_atom(s), meaning: nil}} | acc.rebac], at: :verb}

  defp put("rebac:meaning", s, %{at: :verb, rebac: [{:verb, v} | r]} = acc),
    do: %{acc | rebac: [{:verb, %{v | meaning: append(v.meaning, s)}} | r]}

  defp put("rebac:relate", s, acc),
    do: %{acc | rebac: [{:tuple, row(s, false)} | acc.rebac], at: :tuple}

  defp put("rebac:deny", s, acc),
    do: %{acc | rebac: [{:tuple, row(s, true)} | acc.rebac], at: :tuple}

  defp put("rebac:reason", s, %{at: :tuple, rebac: [{:tuple, r} | rest]} = acc),
    do: %{acc | rebac: [{:tuple, %{r | reason: append(r.reason, s)}} | rest]}

  defp put("rebac:capability", s, acc) do
    cap = %{name: String.to_atom(s), verb: String.to_atom(s), object: nil, caveats: []}
    %{acc | rebac: [{:capability, cap} | acc.rebac], at: :capability}
  end

  defp put("rebac:capability-verb", s, %{at: :capability} = acc),
    do: update_capability(acc, &%{&1 | verb: String.to_atom(s)})

  defp put("rebac:capability-object", s, %{at: :capability} = acc),
    do: update_capability(acc, &%{&1 | object: s})

  defp put("rebac:caveat", s, %{at: :capability} = acc),
    do: update_capability(acc, &%{&1 | caveats: &1.caveats ++ [String.to_atom(s)]})

  defp put("rebac:renders-into", s, acc),
    do: %{acc | rebac: [{:renders_into, {s, nil}} | acc.rebac], at: :renders}

  defp put(
         "rebac:renders-subject",
         s,
         %{at: :renders, rebac: [{:renders_into, {p, nil}} | r]} = acc
       ),
       do: %{acc | rebac: [{:renders_into, {p, s}} | r]}

  defp put("rfd:step", s, acc),
    do: %{acc | steps: [struct!(RFD.Step, literal!(s) |> Map.from_struct()) | acc.steps], at: nil}

  defp put("rfd:" <> key, s, acc) do
    k = known!(key, @text ++ @spine, "unknown property rfd:#{key}")

    order = if k in @spine and not Map.has_key?(acc.text, k), do: [k | acc.order], else: acc.order
    %{acc | text: Map.update(acc.text, k, s, &(&1 <> s)), order: order, at: k}
  end

  defp put(tag, _s, _acc), do: raise(ArgumentError, "unknown property #{tag}")

  defp update_capability(%{rebac: [{:capability, c} | r]} = acc, fun),
    do: %{acc | rebac: [{:capability, fun.(c)} | r]}

  defp add([{h, body} | rest], s), do: [{h, append(body, s)} | rest]

  defp append(nil, s), do: s
  defp append(body, s), do: body <> s

  defp row(s, deny) do
    [subject, verb, object] = String.split(s, " ")
    %{subject: subject, verb: String.to_atom(verb), object: object, deny: deny, reason: nil}
  end

  defp rebac_field(_serial, []), do: []
  defp rebac_field(serial, entries), do: [rebac: RFD.DSL.put_rebac!(:"RFD#{serial}", entries)]

  defp madr!(serial, headings) do
    canon = RFD.DSL.madr_sections() |> Keyword.values()
    ranks = Enum.map(headings, &Enum.find_index(canon, fn c -> c == &1 end))

    cond do
      nil in ranks ->
        raise ArgumentError, "RFD #{serial}: a MADR heading outside the template"

      ranks != Enum.sort(ranks) ->
        raise ArgumentError, "RFD #{serial}: MADR sections out of order"

      not Enum.all?([0, 3], &(&1 in ranks)) ->
        raise ArgumentError, "RFD #{serial}: MADR needs context and outcome"

      true ->
        :ok
    end
  end

  defp state(s) do
    atom = String.to_existing_atom(String.downcase(s))
    if atom in @states, do: atom, else: raise(ArgumentError, "unknown state #{s}")
  end

  @scalar_values %{
    flight_level: ~w(l1 l2 l3)a,
    attest_in: ~w(readme details none)a,
    drafted_by: ~w(ai human)a,
    details_pointer: [true, false],
    compact_head: [true, false]
  }

  defp scalar("rfd:" <> rest) do
    [key, value] = String.split(rest, ":", parts: 2)
    k = known!(key, @scalars, "unknown title tag rfd:#{key}")
    v = Enum.find(Map.fetch!(@scalar_values, k), &(to_string(&1) == value))
    if v == nil, do: raise(ArgumentError, "title tag rfd:#{key} has no value #{value}")
    {k, v}
  end

  defp literal!(s) do
    ast = Code.string_to_quoted!(s)
    unless literal?(ast), do: raise(ArgumentError, "not a literal: #{s}")
    {v, _} = Code.eval_quoted(ast)
    v
  end

  defp literal?(x) when is_atom(x) or is_number(x) or is_binary(x), do: true
  defp literal?(l) when is_list(l), do: Enum.all?(l, &literal?/1)
  defp literal?({a, b}), do: literal?(a) and literal?(b)
  defp literal?({:{}, _, args}), do: literal?(args)
  defp literal?({:%{}, _, kv}), do: literal?(kv)
  defp literal?({:%, _, [{:__aliases__, _, [:RFD, :Step]}, map]}), do: literal?(map)
  defp literal?({:-, _, [n]}) when is_number(n), do: true
  defp literal?(_), do: false

  defp known!(key, keys, why) do
    Enum.find(keys, &(dash(&1) == key)) || raise(ArgumentError, why)
  end

  defp camel(atom), do: atom |> Atom.to_string() |> String.capitalize()
  defp dash(atom), do: atom |> Atom.to_string() |> String.replace("_", "-")

  @doc "A name-based (v5) UUID in the URL namespace under this repository."
  def v5(kind, key) do
    name = @ns <> @base <> kind <> "/" <> key
    <<a::48, _::4, b::12, _::2, c::62, _::32>> = :crypto.hash(:sha, name)
    <<x::32, y::16, z::16, w::16, v::48>> = <<a::48, 5::4, b::12, 2::2, c::62>>

    [<<x::32>>, <<y::16>>, <<z::16>>, <<w::16>>, <<v::48>>]
    |> Enum.map_join("-", &Base.encode16(&1, case: :lower))
  end
end
