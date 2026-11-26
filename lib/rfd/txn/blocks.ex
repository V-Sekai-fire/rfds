# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Txn.Blocks do
  @moduledoc """
  Markdown text as blocks, one per transaction. A paragraph or a list
  item is one line: Markdown reads a newline inside it as a space. A
  heading, table row, quote line, rule, HTML line, indented code line
  or fenced code line stays as written.

  A blank line is kept only where it changes what Markdown reads: between
  two blocks of a kind that would otherwise run together (list items,
  table rows, quote lines, indented or fenced code). There it is an empty
  block. Everywhere else `join/1` puts a blank line back between blocks.
  """

  @item ~r/^\s*(?:[-*+]|\d{1,9}[.)])(?:\s|$)/
  @fence ~r/^\s*(`{3,}|~{3,})/
  @row ~r/^\s*\|/
  @quote ~r/^\s{0,3}>/
  @heading ~r/^\s{0,3}\#{1,6}(?:\s|$)/
  @rule ~r/^\s{0,3}(?:(?:-[ \t]*){3,}|(?:\*[ \t]*){3,}|(?:_[ \t]*){3,}|=+)$/
  @html ~r/^\s{0,3}</
  @setext ~r/^\s{0,3}(=+|-+)\s*$/
  @marker ~r/^(\s*(?:[-*+]|\d{1,9}[.)]))(\s*)/
  @runs [:item, :row, :quote, :indented, :code, :item_code]
  @in_item [:item, :item_code]

  @doc "The blocks of a Markdown text, in order."
  def split(text) do
    text
    |> String.split("\n")
    |> go(%{out: [], cur: nil, last: nil, fence: nil, blank: true, item: 0})
  end

  defp go([], s), do: s |> flush() |> Map.fetch!(:out) |> Enum.reverse()

  defp go([l | rest], %{fence: f} = s) when f != nil do
    s = emit(s, l, :code)
    go(rest, if(closes?(l, f), do: %{s | fence: nil}, else: s))
  end

  defp go([l | rest], s) do
    if blank?(l) do
      s = flush(s)
      rest = Enum.drop_while(rest, &blank?/1)

      s =
        case rest do
          [next | _] when s.last in @runs ->
            if kind_of(next, s) == s.last, do: %{s | out: ["" | s.out]}, else: s

          _ ->
            s
        end

      go(rest, %{s | blank: true})
    else
      go(rest, block(l, s))
    end
  end

  defp block(l, s) do
    open? = s.cur != nil and not s.blank

    cond do
      open? and Regex.match?(@setext, l) and not Regex.match?(@item, s.cur) ->
        level = if String.contains?(l, "="), do: "# ", else: "## "
        emit(%{s | cur: nil}, level <> String.trim(s.cur), :line)

      m = Regex.run(@fence, l) ->
        %{emit(flush(s), l, :code) | fence: Enum.at(m, 1)}

      s.last == :row and not s.blank and String.contains?(l, "|") ->
        emit(s, l, :row)

      item_code?(l, s, open?) ->
        emit(flush(s), l, :item_code)

      indent(l) >= 4 and not open? and s.last not in @in_item ->
        emit(flush(s), l, :indented)

      verbatim?(l) and not (open? and Regex.match?(@html, l)) ->
        emit(flush(s), l, verbatim_kind(l))

      Regex.match?(@item, l) ->
        %{flush(s) | cur: l, blank: false, item: content_indent(l)}

      s.cur != nil and not s.blank ->
        %{s | cur: s.cur <> " " <> String.trim(l)}

      true ->
        %{flush(s) | cur: l, blank: false}
    end
  end

  # Code inside a list item: indented four past the item's content, after
  # a blank line or another such line.
  defp item_code?(l, s, open?) do
    s.last in @in_item and indent(l) >= s.item + 4 and
      (s.last == :item_code or (s.blank and not open?))
  end

  defp content_indent(l) do
    [_, marker, gap] = Regex.run(@marker, l)
    String.length(marker) + if(String.length(gap) in 1..4, do: String.length(gap), else: 1)
  end

  # The kind a line after a blank line would start, given the block before it.
  defp kind_of(l, s) do
    last = s.last

    cond do
      Regex.match?(@fence, l) -> :code
      last == :row and String.contains?(l, "|") -> :row
      last in @in_item and indent(l) >= s.item + 4 -> :item_code
      indent(l) >= 4 and last not in @in_item -> :indented
      verbatim?(l) -> verbatim_kind(l)
      Regex.match?(@item, l) -> :item
      true -> :para
    end
  end

  defp verbatim?(l) do
    Enum.any?([@row, @quote, @heading, @rule, @html], &Regex.match?(&1, l))
  end

  defp emit(s, l, kind), do: %{s | out: [l | s.out], last: kind, blank: false}

  defp flush(%{cur: nil} = s), do: s

  defp flush(%{cur: c} = s) do
    kind = if Regex.match?(@item, c), do: :item, else: :para
    %{s | out: [c | s.out], cur: nil, last: kind}
  end

  defp verbatim_kind(l) do
    cond do
      Regex.match?(@row, l) -> :row
      Regex.match?(@quote, l) -> :quote
      true -> :line
    end
  end

  defp closes?(l, open) do
    t = String.trim(l)
    c = String.first(open)
    t != "" and String.trim(t, c) == "" and String.length(t) >= String.length(open)
  end

  defp blank?(l), do: String.trim(l) == ""
  defp indent(l), do: String.length(l) - String.length(String.trim_leading(l))

  @doc "Markdown text from its blocks, with the blank lines Markdown reads."
  def join(blocks) do
    {parts, _, _, _, _} =
      Enum.reduce(blocks, {[], nil, nil, 0, nil}, fn b, {acc, prev, fence, item, run} ->
        {kind, fence} = classify(b, fence, run, item)
        item = if kind == :item, do: content_indent(b), else: item
        sep = if prev == nil, do: "", else: separator(prev, kind)
        run = if kind == :blank, do: run, else: kind
        {[b, sep | acc], kind, fence, item, run}
      end)

    parts |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp classify(b, fence, _run, _item) when fence != nil do
    {:code, if(closes?(b, fence), do: nil, else: fence)}
  end

  defp classify("", nil, _run, _item), do: {:blank, nil}

  defp classify(b, nil, run, item) do
    cond do
      m = Regex.run(@fence, b) -> {:code, Enum.at(m, 1)}
      run == :row and String.contains?(b, "|") -> {:row, nil}
      run in @in_item and indent(b) >= item + 4 -> {:item_code, nil}
      indent(b) >= 4 and run not in @in_item -> {:indented, nil}
      Regex.match?(@row, b) -> {:row, nil}
      Regex.match?(@quote, b) -> {:quote, nil}
      verbatim?(b) -> {:line, nil}
      Regex.match?(@item, b) -> {:item, nil}
      true -> {:para, nil}
    end
  end

  defp separator(_, :blank), do: "\n"
  defp separator(:blank, _), do: "\n"
  defp separator(:code, :code), do: "\n"
  defp separator(k, k) when k in [:item, :row, :quote, :indented, :item_code], do: "\n"
  defp separator(_, _), do: "\n\n"
end
