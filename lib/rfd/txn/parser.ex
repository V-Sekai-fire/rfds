# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Txn.Parser do
  @moduledoc """
  Reads tackler journal text the way tackler-core 0.12 (tackler-ng
  v25.06.1, `tackler-core/src/parser/parts/`) does, rule for rule:

  - a journal is optional blank lines, then one or more transactions;
  - a transaction is a header, optional metadata (`uuid`, `tags`,
    `location`, each at most once, in any order), optional comments,
    then one or more postings with an amount and an optional last
    posting without one, and it ends at blank lines or the end;
  - a header is an ISO 8601 date or date-time (with `Z` or `+HH:MM`),
    then optional `(code)` and `'description`, each after spaces.

  `parse/1` returns the transactions, or the line and column where the
  text stops being tackler. tackler's semantic checks are applied too:
  real dates and times, distinct tags, one commodity per transaction
  without value positions, and postings that sum to zero.
  """
  import NimbleParsec

  id_start =
    [?a..?z, ?A..?Z, ?$, 0xA2..0xA5, 0xB0, 0xB5, 0xB9, 0xB2, 0xB3, 0xBC..0xBE] ++
      [0xC0..0xD6, 0xD8..0xF6, 0xF8..0x2FF, 0x370..0x37D, 0x37F..0x1FFF] ++
      [0x200C..0x200D, 0x2070..0x218F, 0x2C00..0x2FEF, 0x3001..0xD7FF] ++
      [0xF900..0xFDCF, 0xFDF0..0xFFFD]

  id_char = id_start ++ [?0..?9, ?_, ?-, 0xB7, 0x300..0x36F, 0x203F..0x2040]

  eol = choice([string("\r\n"), string("\n")])
  space0 = ascii_string([?\s, ?\t], min: 0)
  space1 = ascii_string([?\s, ?\t], min: 1)
  content = utf8_string([not: ?\n, not: ?\r], min: 0)
  hex = fn n -> ascii_string([?0..?9, ?a..?f, ?A..?F], n) end
  dec = fn n -> ascii_string([?0..?9], n) end

  identifier =
    utf8_char(id_start)
    |> repeat(utf8_char(id_char))
    |> reduce({List, :to_string, []})

  multi_id =
    identifier
    |> repeat(string(":") |> utf8_string(id_char, min: 1))
    |> reduce({Enum, :join, []})

  number =
    optional(string("-"))
    |> ascii_string([?0..?9], min: 1)
    |> optional(string(".") |> ascii_string([?0..?9], min: 1))
    |> reduce({Enum, :join, []})

  date = dec.(4) |> string("-") |> concat(dec.(2)) |> string("-") |> concat(dec.(2))

  time =
    string("T")
    |> concat(dec.(2))
    |> string(":")
    |> concat(dec.(2))
    |> string(":")
    |> concat(dec.(2))
    |> optional(string(".") |> ascii_string([?0..?9], min: 1, max: 9))

  zone =
    choice([
      string("Z"),
      choice([string("+"), string("-")])
      |> concat(dec.(2))
      |> string(":")
      |> concat(dec.(2))
    ])

  timestamp =
    date
    |> optional(time |> optional(zone))
    |> reduce({Enum, :join, []})
    |> post_traverse({__MODULE__, :timestamp, []})

  code_chars =
    [not: ?), not: ?', not: ?(, not: ?[, not: ?], not: ?{, not: ?}] ++
      [not: ?<, not: ?>, not: ?\r, not: ?\n]

  code =
    ignore(space1)
    |> ignore(string("("))
    |> utf8_string(code_chars, min: 0)
    |> ignore(string(")"))
    |> post_traverse({__MODULE__, :content, [:code]})

  description =
    ignore(space1)
    |> ignore(string("'"))
    |> concat(content)
    |> lookahead(eol)
    |> post_traverse({__MODULE__, :content, [:description]})

  header =
    timestamp
    |> optional(code)
    |> optional(description)
    |> ignore(space0)
    |> ignore(eol)

  meta_line = fn key, value ->
    ignore(space1)
    |> ignore(string("#"))
    |> ignore(space1)
    |> ignore(string(key <> ":"))
    |> ignore(space1)
    |> concat(value)
    |> ignore(space0)
    |> ignore(eol)
  end

  uuid =
    hex.(8)
    |> string("-")
    |> concat(hex.(4))
    |> string("-")
    |> concat(hex.(4))
    |> string("-")
    |> concat(hex.(4))
    |> string("-")
    |> concat(hex.(12))
    |> reduce({Enum, :join, []})
    |> map({String, :downcase, []})
    |> unwrap_and_tag(:uuid)

  tags =
    multi_id
    |> repeat(ignore(space0 |> string(",") |> concat(space0)) |> concat(multi_id))
    |> tag(:tags)

  location =
    ignore(string("geo:"))
    |> ignore(space0)
    |> concat(number)
    |> ignore(space0 |> string(",") |> concat(space0))
    |> concat(number)
    |> ignore(space0)
    |> optional(ignore(string(",") |> concat(space0)) |> concat(number))
    |> tag(:location)

  meta =
    choice([
      meta_line.("uuid", uuid),
      meta_line.("tags", tags),
      meta_line.("location", location)
    ])
    |> unwrap_and_tag(:meta)

  comment =
    ignore(string(";"))
    |> choice([
      lookahead(eol) |> replace(""),
      ignore(ascii_char([?\s, ?\t])) |> concat(content) |> lookahead(eol)
    ])
    |> post_traverse({__MODULE__, :content, [:comment]})

  txn_comment = ignore(space1) |> concat(comment) |> ignore(eol)

  closing =
    ignore(space1)
    |> choice([string("@"), string("=")])
    |> ignore(space1)
    |> concat(number)
    |> ignore(space1)
    |> concat(identifier)
    |> tag(:closing)

  opening =
    ignore(space1)
    |> ignore(string("{"))
    |> ignore(space0)
    |> concat(number)
    |> ignore(space1)
    |> concat(identifier)
    |> ignore(space0)
    |> ignore(string("}"))
    |> tag(:opening)

  position = choice([opening |> optional(closing), closing])

  posting =
    ignore(space1)
    |> concat(multi_id)
    |> ignore(space1)
    |> concat(number)
    |> optional(ignore(space1) |> concat(identifier) |> optional(position))
    |> ignore(space0)
    |> optional(comment)
    |> ignore(eol)
    |> tag(:posting)

  last_posting =
    ignore(space1)
    |> concat(multi_id)
    |> ignore(space0)
    |> optional(comment)
    |> ignore(eol)
    |> tag(:last_posting)

  blanks = times(ignore(space0) |> ignore(eol), min: 1)

  txn =
    header
    |> repeat(meta)
    |> repeat(txn_comment)
    |> times(posting, min: 1)
    |> optional(last_posting)
    |> choice([blanks, eos()])
    |> pre_traverse({__MODULE__, :mark, []})
    |> post_traverse({__MODULE__, :txn, []})

  defparsecp(:journal, optional(blanks) |> times(txn, min: 1) |> eos())

  @doc "The transactions of a journal, or `{line, column, message}`."
  def parse(text) do
    case journal(text) do
      {:ok, txns, "", _, _, _} -> {:ok, txns}
      {:error, msg, _, _, {line, start}, at} -> {:error, {line, at - start + 1, msg}}
    end
  end

  @doc false
  def mark(rest, acc, context, {line, _}, _offset) do
    {rest, acc, Map.put(context, :line, line)}
  end

  @doc false
  def timestamp(rest, [ts], context, _line, _offset) do
    case check_timestamp(ts) do
      :ok -> {rest, [{:timestamp, ts}], context}
      {:error, why} -> {:error, "ISO 8601 timestamp #{ts}: #{why}"}
    end
  end

  @doc false
  def content(rest, acc, context, _line, _offset, key) do
    s =
      case {key, acc} do
        {:code, [s]} -> String.trim(s)
        {:code, []} -> ""
        {:description, [s]} -> String.trim_trailing(s)
        {:comment, [s]} -> s
      end

    case Enum.find(String.to_charlist(s), &(not content_char?(&1))) do
      nil -> {rest, [{key, s}], context}
      c -> {:error, "#{key}: U+#{Integer.to_string(c, 16)} is not tackler text"}
    end
  end

  @doc false
  def txn(rest, acc, context, _line, _offset) do
    tokens = Enum.reverse(acc)

    with {:ok, meta} <- metadata(Keyword.get_values(tokens, :meta)),
         {:ok, postings} <- postings(tokens) do
      header = %{
        line: context.line,
        timestamp: Keyword.fetch!(tokens, :timestamp),
        code: Keyword.get(tokens, :code),
        description: Keyword.get(tokens, :description),
        comments: Keyword.get_values(tokens, :comment),
        postings: postings
      }

      {rest, [Map.merge(meta, header)], context}
    end
  end

  defp metadata(lines) do
    keys = Enum.map(lines, &elem(&1, 0))
    tags = Keyword.get(lines, :tags)

    cond do
      keys != Enum.uniq(keys) ->
        {:error, "txn metadata: uuid, tags and location each come at most once"}

      tags != nil and tags != Enum.uniq(tags) ->
        {:error, "txn tags contains duplicate tags: #{inspect(tags)}"}

      bad_location?(Keyword.get(lines, :location)) ->
        {:error, "txn metadata location: latitude or longitude out of range"}

      true ->
        {:ok,
         %{
           uuid: Keyword.get(lines, :uuid),
           tags: tags || [],
           location: Keyword.get(lines, :location)
         }}
    end
  end

  defp bad_location?(nil), do: false

  defp bad_location?([lat, lon | _]) do
    out = fn s, lim -> abs(elem(Float.parse(s), 0)) > lim end
    out.(lat, 90) or out.(lon, 180)
  end

  defp postings(tokens) do
    full = for {:posting, parts} <- tokens, do: full_posting(parts)
    last = for {:last_posting, parts} <- tokens, do: last_posting(parts)

    commodities = full |> Enum.map(& &1.txn_commodity) |> Enum.uniq()
    sum = full |> Enum.map(& &1.value) |> Enum.reduce({0, 0}, &add/2)

    zero = Enum.find(full, &(elem(&1.value, 0) == 0))

    cond do
      zero != nil ->
        {:error, "Zero sum postings are not allowed: #{zero.account}"}

      Enum.any?(full, & &1.same?) ->
        {:error, "both commodities are the same for a value position"}

      length(commodities) > 1 ->
        {:error, "different commodities without value positions in one transaction"}

      last == [] and elem(sum, 0) != 0 ->
        {:error, "TXN postings do not zero"}

      true ->
        {:ok, Enum.map(full ++ last, &Map.drop(&1, [:value, :same?]))}
    end
  end

  defp full_posting(parts) do
    {comment, parts} = take_comment(parts)
    [account, amount | rest] = parts
    {unit, pos} = unit(rest)

    {txn_unit, value, same?} =
      case {pos[:opening], pos[:closing]} do
        {_, [op, price, c]} -> {c, closing_value(op, amount, price), c == unit}
        {[_, _], nil} -> {"", dec(amount), false}
        {nil, nil} -> {unit || "", dec(amount), false}
      end

    %{
      account: account,
      amount: amount,
      commodity: unit,
      txn_commodity: txn_unit,
      comment: comment,
      value: value,
      same?: same?
    }
  end

  defp last_posting(parts) do
    {comment, [account]} = take_comment(parts)
    %{account: account, amount: nil, commodity: nil, txn_commodity: nil, comment: comment}
  end

  defp take_comment(parts) do
    case List.keytake(parts, :comment, 0) do
      {{:comment, c}, rest} -> {c, rest}
      nil -> {nil, parts}
    end
  end

  defp unit([]), do: {nil, %{}}
  defp unit([u | pos]), do: {u, Map.new(pos)}

  defp closing_value("@", amount, price), do: mult(dec(amount), dec(price))

  defp closing_value("=", amount, total) do
    {n, s} = dec(total)
    if String.starts_with?(amount, "-"), do: {-n, s}, else: {n, s}
  end

  defp dec(s) do
    case String.split(s, ".") do
      [i] -> {String.to_integer(i), 0}
      [i, f] -> {String.to_integer(i <> f), String.length(f)}
    end
  end

  defp mult({a, s}, {b, t}), do: {a * b, s + t}

  defp add({a, s}, {b, t}) do
    m = max(s, t)
    {a * Integer.pow(10, m - s) + b * Integer.pow(10, m - t), m}
  end

  defp check_timestamp(ts) do
    {date, rest} = String.split_at(ts, 10)

    case {Date.from_iso8601(date), rest} do
      {{:error, _}, _} -> {:error, "not a calendar date"}
      {{:ok, _}, ""} -> :ok
      {{:ok, _}, "T" <> t} -> check_time(t)
    end
  end

  defp check_time(t) do
    [clock | zone] =
      Regex.run(~r/^(\d\d:\d\d:\d\d(?:\.\d{1,9})?)(.*)$/, t, capture: :all_but_first)

    cond do
      match?({:error, _}, Time.from_iso8601(clock)) -> {:error, "not a clock time"}
      zone in [[""], ["Z"]] -> :ok
      true -> check_offset(hd(zone))
    end
  end

  defp check_offset(<<_sign, h::binary-2, ":", m::binary-2>>) do
    secs = String.to_integer(h) * 3600 + String.to_integer(m) * 60
    if secs < 26 * 3600, do: :ok, else: {:error, "offset out of range"}
  end

  @doc "tackler's `content_char`: alphanumeric, space, punctuation, name or other symbol."
  def content_char?(c) do
    alnum?(c) or c in [?\s, ?\t] or punct?(c) or id_char?(c) or other?(c)
  end

  defp alnum?(c), do: <<c::utf8>> =~ ~r/^[\p{L}\p{N}\p{Mn}\p{Mc}]$/u

  defp punct?(c) do
    c in ?!..?/ or c in ?:..?@ or c in ?[..?` or c in ?{..?~ or c in 0xA0..0xBF or
      c in [0xD7, 0xF7, 0x37E]
  end

  defp other?(c) do
    c in 0x2000..0x206F or c in 0x2190..0x2BFF or c == 0x3000 or c in 0x1D400..0x1D7FF or
      c in 0x1EE00..0x1FAFF
  end

  @id_char Enum.map(id_char, fn
             r when is_integer(r) -> r..r
             r -> r
           end)

  defp id_char?(c), do: Enum.any?(@id_char, &(c in &1))
end
