# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.TxnTest do
  use ExUnit.Case, async: true

  @fixtures Path.expand("fixtures/tackler", __DIR__)
  @oracle @fixtures
          |> Path.join("tackler.jsonl")
          |> File.read!()
          |> String.split("\n", trim: true)
          |> Enum.map(&JSON.decode!/1)

  defp num(nil), do: nil

  defp num(s) do
    [i | f] = String.split(s, ".")
    f = f |> List.first("") |> String.trim_trailing("0")
    if f == "", do: i, else: i <> "." <> f
  end

  defp ours(t) do
    %{
      code: t.code,
      description: t.description,
      uuid: t.uuid,
      tags: t.tags,
      comments: t.comments,
      posts:
        Enum.map(t.postings, &%{account: &1.account, amount: num(&1.amount), comment: &1.comment})
    }
  end

  defp theirs(t, mine) do
    posts =
      t["posts"]
      |> Enum.zip(mine.posts)
      |> Enum.map(fn {p, m} ->
        amount = if m.amount, do: num(p["amount"])
        %{account: p["account"], amount: amount, comment: p["comment"]}
      end)

    %{
      code: t["code"],
      description: t["description"],
      uuid: t["uuid"] && String.downcase(t["uuid"]),
      tags: t["tags"] || [],
      comments: t["comments"] || [],
      posts: posts
    }
  end

  defp same_instant?(ours, theirs) do
    {date, clock} = String.split_at(ours, 10)
    hms = clock |> String.trim_leading("T") |> String.split(~r/[Z+\-]/) |> hd()
    String.starts_with?(theirs, date) and String.contains?(theirs, hms)
  end

  defp order_key(t), do: {t.timestamp, t.code || "", t.description || "", t.uuid || ""}

  for o <- @oracle do
    @o o
    test "#{o["file"]} reads as tackler-core 0.12 reads it" do
      text = File.read!(Path.join(@fixtures, @o["file"]))

      case {@o["ok"], RFD.Txn.Parser.parse(text)} do
        {false, result} ->
          assert match?({:error, _}, result),
                 "tackler rejects it (#{String.slice(@o["error"], 0, 120)})"

        {true, {:error, e}} ->
          flunk("tackler accepts it; we reject it: #{inspect(e)}")

        {true, {:ok, txns}} ->
          assert length(txns) == length(@o["txns"])

          for {a, b} <- Enum.zip(Enum.sort_by(txns, &order_key/1), @o["txns"]) do
            assert same_instant?(a.timestamp, b["timestamp"])
            mine = ours(a)
            assert mine == theirs(b, mine)
          end
      end
    end
  end

  test "every RFD journal is in its written form and keeps its references as written" do
    for path <- RFD.Source.all(), not RFD.Source.register?(path) do
      text = File.read!(path)
      assert RFD.Txn.canonical(text) == text, path
      raw = RFD.Txn.parse_raw!(text)
      assert RFD.Txn.parse_raw!(RFD.Txn.canonical(text)) == raw, path
    end
  end

  test "a property tackler does not keep is refused" do
    text = """
    2026-01-01T00:00:00Z (RFD66606-2999) 'a title
     # tags: rfd:title
     ; a comment is not durable
     RFD:Discussion  1 RFD
     Serials:VSekaiFabric
    """

    assert_raise ArgumentError, ~r/comment is not durable/, fn -> RFD.Txn.parse(text) end
  end

  test "an unknown property is refused" do
    text = """
    2026-01-01T00:00:00Z (RFD66606-2999) 'a title
     # tags: rfd:title
     RFD:Discussion  1 RFD
     Serials:VSekaiFabric

    2026-01-01T00:00:01Z (RFD66606-2999) 'text
     # tags: rfd:colour
     Text:RFD2999  1 LINE
     Text:Written
    """

    assert_raise ArgumentError, ~r/unknown property/, fn -> RFD.Txn.parse(text) end
  end

  test "keeping references as written in one process leaves the others expanded" do
    [path] = Path.wildcard("rfd/2229-*.txn")
    text = File.read!(path)
    raw = RFD.Txn.parse_raw!(text)
    expanded = RFD.Txn.parse!(text)
    assert raw != expanded

    results =
      1..64
      |> Task.async_stream(
        fn i ->
          if rem(i, 2) == 0,
            do: {:raw, RFD.Txn.parse_raw!(text)},
            else: {:expanded, RFD.Txn.parse!(text)}
        end,
        max_concurrency: 16
      )
      |> Enum.map(fn {:ok, r} -> r end)

    for {kind, d} <- results do
      assert d == if(kind == :raw, do: raw, else: expanded)
    end
  end

  test "lines keep their order when read back sorted, as tackler sorts" do
    d = RFD.Source.load(hd(Path.wildcard("rfd/2360-*.txn")))
    text = RFD.Txn.write(d, day: "2026-01-01", site: "VSekaiFabric")
    reversed = text |> String.split("\n\n") |> Enum.reverse() |> Enum.join("\n\n")
    assert {:ok, ^d} = RFD.Txn.parse(reversed <> "\n")
  end
end
