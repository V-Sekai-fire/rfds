# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Txn do
  @shortdoc "Write each RFD as a tackler journal, or prove the round trip"
  @moduledoc """
      mix rfd.txn --write --days journal/pages.txn
      mix rfd.txn --check --days journal/pages.txn

  `--write` writes `rfd/NNNN-slug.txn` beside each source, dated by the
  day its serial was registered (the `(RFD66606-NNNN)` entries of the
  journal `--days` names). `--check` reads every journal back and fails
  unless it equals the doc its source loads and writes back to the same
  bytes.
  """
  use Mix.Task

  @sites %{1 => "Weftspun", 2 => "VSekaiFabric"}

  @impl true
  def run(args) do
    {opts, _} =
      OptionParser.parse!(args, strict: [write: :boolean, check: :boolean, days: :string])

    Mix.Task.run("compile")
    days = days(Keyword.fetch!(opts, :days))

    results =
      for path <- RFD.Source.all(), not RFD.Source.register?(path) do
        d = RFD.Source.load(path)
        madr? = File.read!(path) =~ ~r/^\s*madr do/m
        day = Map.get(days, d.serial) || Mix.raise("RFD #{d.serial}: no registration day")

        text =
          RFD.Txn.write(d, day: day, site: Map.fetch!(@sites, div(d.serial, 1000)), madr: madr?)

        out = String.replace_suffix(path, ".exs", ".txn")
        if opts[:write], do: File.write!(out, text)
        {path, if(opts[:check], do: check(d, text, day, madr?), else: :ok)}
      end

    bad = for {p, r} <- results, r != :ok, do: {p, r}
    for {p, r} <- bad, do: Mix.shell().error("FAIL #{p}: #{r}")
    Mix.shell().info("#{length(results) - length(bad)} of #{length(results)} RFDs round-trip")
    if bad != [], do: Mix.raise("#{length(bad)} RFDs do not round-trip")
  end

  defp check(d, text, day, madr?) do
    case RFD.Txn.parse(text) do
      {:ok, ^d} ->
        site = Map.fetch!(@sites, div(d.serial, 1000))
        again = RFD.Txn.write(d, day: day, site: site, madr: madr?)
        if again == text, do: :ok, else: "writing it again gives other bytes"

      {:ok, other} ->
        diff =
          for {k, v} <- Map.from_struct(d), Map.get(other, k) != v, do: k

        "fields differ: #{inspect(diff)}"

      {:error, e} ->
        "does not parse: #{e}"
    end
  end

  defp days(path) do
    head = ~r/^(\d{4}-\d\d-\d\d) \(RFD66606-(\d+)\)/m

    for [_, day, n] <- Regex.scan(head, File.read!(path)), into: %{} do
      {String.to_integer(n), day}
    end
  end
end
