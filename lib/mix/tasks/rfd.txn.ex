# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Txn do
  @shortdoc "Check that every RFD journal is in its written form"
  @moduledoc """
      mix rfd.txn [--check]
      mix rfd.txn --convert --days JOURNAL

  With no flag, or `--check`, every `rfd/NNNN-slug.txn` must read
  through `RFD.Txn` and write back to the same bytes; `--write`
  rewrites any that do not.

  `--convert` writes each `rfd/NNNN-slug.exs` out as its journal, with
  `&{...}` references kept as written, dated by the day its serial was
  registered (the `(RFD66606-NNNN)` entries of JOURNAL). It fails
  unless the journal reads back to the doc the source loads, with and
  without references expanded, and is already in its written form.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, _} =
      OptionParser.parse!(args,
        strict: [check: :boolean, write: :boolean, convert: :boolean, days: :string]
      )

    Mix.Task.run("compile")
    if opts[:convert], do: convert(days(Keyword.fetch!(opts, :days))), else: check(opts)
  end

  defp check(opts) do
    paths = Path.wildcard("rfd/[0-9][0-9][0-9][0-9]-*.txn") |> Enum.sort()

    bad =
      for path <- paths,
          text = File.read!(path),
          canonical = RFD.Txn.canonical(text),
          canonical != text do
        if opts[:write], do: File.write!(path, canonical)
        path
      end

    for p <- bad, do: Mix.shell().error("#{if opts[:write], do: "wrote", else: "FAIL"} #{p}")

    Mix.shell().info(
      "#{length(paths) - length(bad)} of #{length(paths)} journals in written form"
    )

    if bad != [] and !opts[:write], do: Mix.raise("run mix rfd.txn --write")
  end

  defp convert(days) do
    sources = Path.wildcard("rfd/[0-9][0-9][0-9][0-9]-*.exs") |> Enum.sort()

    bad =
      for path <- sources, r = convert_one(path, days), r != :ok do
        Mix.shell().error("FAIL #{path}: #{r}")
        path
      end

    Mix.shell().info("#{length(sources) - length(bad)} of #{length(sources)} RFDs converted")
    if bad != [], do: Mix.raise("#{length(bad)} RFDs did not convert")
  end

  defp convert_one(path, days) do
    loaded = RFD.Source.load(path)
    raw = RFD.DSL.unexpanded(fn -> RFD.Source.load(path) end)
    day = Map.get(days, raw.serial) || Mix.raise("RFD #{raw.serial}: no registration day")
    site = if div(raw.serial, 1000) == 1, do: "Weftspun", else: "VSekaiFabric"
    madr? = File.read!(path) =~ ~r/^\s*madr do/m
    text = RFD.Txn.write(raw, day: day, site: site, madr: madr?)

    cond do
      RFD.Txn.parse!(text) != loaded -> "does not read back to the doc its source loads"
      RFD.Txn.parse_raw!(text) != raw -> "loses a reference as written"
      RFD.Txn.canonical(text) != text -> "is not in its written form"
      true -> write_journal(path, text)
    end
  end

  defp write_journal(path, text) do
    File.write!(String.replace_suffix(path, ".exs", ".txn"), text)
    :ok
  end

  defp days(path) do
    head = ~r/^(\d{4}-\d\d-\d\d)\S* \(RFD66606-(\d+)\)/m

    for [_, day, n] <- Regex.scan(head, File.read!(path)), into: %{} do
      {String.to_integer(n), day}
    end
  end
end
