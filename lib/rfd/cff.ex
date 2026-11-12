# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
defmodule Rfd.Cff do
  @moduledoc "Reads a CITATION.cff: the YAML subset the house records use, refusing the rest."

  @key ~r/^([A-Za-z0-9_.-]+):(?:\s+(.*))?$/
  @item_key ~r/^[A-Za-z0-9_.-]+:(\s|$)/

  def read!(path), do: path |> File.read!() |> parse!()

  def parse!(text) do
    lines =
      text
      |> String.split(["\r\n", "\n"])
      |> Enum.with_index(1)
      |> Enum.map(fn {l, n} -> line(l, n) end)
      |> Enum.reject(&(&1 == :comment))

    {map, rest} = map(lines, 0, %{})

    cond do
      map == %{} -> raise ArgumentError, "a .cff that is not a mapping is refused"
      drop_blank(rest) == [] -> map
      true -> refuse(hd(drop_blank(rest)), "a line outside the mapping")
    end
  end

  defp line(l, n) do
    t = String.trim_trailing(l)
    body = String.trim_leading(t, " ")

    cond do
      body == "" -> {n, :blank, ""}
      String.starts_with?(body, "#") -> :comment
      String.starts_with?(body, "\t") -> refuse({n, 0, t}, "a tab indent")
      true -> {n, byte_size(t) - byte_size(body), body}
    end
  end

  defp drop_blank(lines), do: Enum.drop_while(lines, fn {_, i, _} -> i == :blank end)

  defp map(lines, ind, acc) do
    case drop_blank(lines) do
      [{n, ^ind, text} = l | rest] ->
        case Regex.run(@key, text) do
          [_, key | val] ->
            if Map.has_key?(acc, key), do: refuse(l, "a duplicate key #{key}")
            {value, rest} = value(List.first(val) || "", rest, ind, n)
            map(rest, ind, Map.put(acc, key, value))

          nil ->
            {acc, lines}
        end

      _ ->
        {acc, lines}
    end
  end

  defp list(lines, ind, acc) do
    case drop_blank(lines) do
      [{n, ^ind, "- " <> item} | rest] ->
        body = String.trim_leading(item, " ")
        deeper = ind + 2 + byte_size(item) - byte_size(body)

        {v, rest} =
          if Regex.match?(@item_key, body),
            do: map([{n, deeper, body} | rest], deeper, %{}),
            else: value(body, rest, ind, n)

        list(rest, ind, [v | acc])

      _ ->
        {Enum.reverse(acc), lines}
    end
  end

  defp value("", rest, ind, n) do
    case drop_blank(rest) do
      [{_, i, "- " <> _} | _] = lines when is_integer(i) and i >= ind -> list(lines, i, [])
      [{_, i, _} | _] = lines when is_integer(i) and i > ind -> map(lines, i, %{})
      _ -> refuse({n, ind, ""}, "a key with no value")
    end
  end

  defp value(raw, rest, ind, _n) when raw in [">", ">-", "|", "|-"] do
    {body, rest} = deeper(rest, ind)
    {block(raw, body), rest}
  end

  defp value(<<q, _::binary>> = raw, rest, ind, n) when q in [?", ?'] do
    {more, rest} = deeper(rest, ind)
    {quoted(fold([raw | Enum.map(more, &elem(&1, 2))]), q, n), rest}
  end

  defp value(<<c, _::binary>> = raw, _rest, ind, n) when c in ~c"[{&*!%@`|>" do
    refuse({n, ind, raw}, "YAML outside the subset a .cff uses")
  end

  defp value(raw, rest, ind, _n) do
    {more, rest} = deeper(rest, ind)
    first = raw |> String.split(" #") |> hd()
    {fold([first | Enum.map(more, &elem(&1, 2))]), rest}
  end

  defp deeper(lines, ind) do
    {taken, rest} =
      Enum.split_while(lines, fn {_, i, _} -> i == :blank or (is_integer(i) and i > ind) end)

    {trailing, kept} = taken |> Enum.reverse() |> Enum.split_while(&(elem(&1, 1) == :blank))
    {Enum.reverse(kept), Enum.reverse(trailing) ++ rest}
  end

  defp fold(texts) do
    texts
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 |> hd() == ""))
    |> Enum.map_join("\n", &Enum.join(&1, " "))
  end

  defp block(style, lines) do
    texts = Enum.map(lines, &elem(&1, 2))

    body =
      if String.starts_with?(style, ">"),
        do: fold(texts),
        else: Enum.join(texts, "\n")

    if String.ends_with?(style, "-"), do: body, else: body <> "\n"
  end

  defp quoted(<<q, s::binary>>, q, n), do: unquote_(s, q, n, "")

  defp unquote_("\\" <> <<c::utf8, r::binary>>, ?" = q, n, acc),
    do: unquote_(r, q, n, acc <> escape(c, n))

  defp unquote_("''" <> r, ?' = q, n, acc), do: unquote_(r, q, n, acc <> "'")

  defp unquote_(<<q, r::binary>>, q, n, acc) do
    tail = String.trim(r)

    if tail == "" or String.starts_with?(tail, "#"),
      do: acc,
      else: refuse({n, 0, r}, "text after a quote")
  end

  defp unquote_(<<c::utf8, r::binary>>, q, n, acc),
    do: unquote_(r, q, n, <<acc::binary, c::utf8>>)

  defp unquote_("", _q, n, _acc), do: refuse({n, 0, ""}, "an unterminated quoted string")

  defp escape(c, n) do
    case c do
      ?" -> "\""
      ?\\ -> "\\"
      ?/ -> "/"
      ?n -> "\n"
      ?t -> "\t"
      ?\s -> " "
      _ -> refuse({n, 0, <<?\\, c::utf8>>}, "an escape outside the subset")
    end
  end

  defp refuse({n, _, text}, why),
    do: raise(ArgumentError, ".cff line #{n}: #{why}: #{inspect(text)}")
end
