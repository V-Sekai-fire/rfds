# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Next do
  @shortdoc "Print the next free RFD serial and the transaction that allocates it"
  @moduledoc """
      mix rfd.next [slug]

  The next serial is one past the highest the register has spent, a `rfd/` source
  on disk claims, or a pushed `dev/rfd-NNNN-*` branch claims. The register is the
  one site still allocating, built from the journals: an allocated serial is its
  RFD journal, so the title transaction of `rfd/NNNN-slug.txn` allocates it and
  nothing is added to `journal/serials.txn`.
  """
  use Mix.Task

  @impl true
  def run(args) do
    slug = List.first(args) || "<slug>"
    reg = allocating(RFD.Register.from_journals())
    site = reg.layer[:site]
    n = next(reg, claimed(site))
    last = reg.rows |> Enum.filter(&(elem(&1, 0) == :allocated)) |> Enum.max_by(&elem(&1, 1))
    code = "RFD66606-#{n}"
    day = Date.utc_today() |> Date.to_iso8601()

    Mix.shell().info("""
    Next free serial: #{n}

    1. Write rfd/#{n}-#{slug}.txn. Its first transaction allocates the serial in
       #{reg.name}; nothing goes in journal/serials.txn:
           #{RFD.Txn.at(day, 0)} (#{code}) '<title>
            # uuid: #{RFD.Txn.v5("rfd", code)}
            # tags: rfd:title
            RFD:Prediscussion  1 RFD
            Serials:#{reg.name}
       Copy the shape of rfd/#{elem(last, 1)}-#{elem(last, 2)}.txn.
    2. Work on branch dev/rfd-#{n}-#{slug}, and commit the journal on it.
    """)
  end

  @doc "The one register that still allocates: every other site is decommissioned."
  def allocating(registers) do
    case Enum.reject(registers, &match?({:decommissioned, _}, &1.layer[:note])) do
      [reg] -> reg
      regs -> Mix.raise("#{length(regs)} sites allocate serials; RFD 1000 allows one")
    end
  end

  def next(%RFD.Register{} = reg, claimed \\ []) do
    site = reg.layer[:site]
    own = Enum.filter(Enum.map(reg.rows, &elem(&1, 1)) ++ claimed, &(div(&1, 1000) == site))
    n = Enum.max(own) + 1
    if div(n, 1000) == site, do: n, else: Mix.raise("site #{site} has no serial left")
  end

  defp claimed(site) do
    files = for f <- Path.wildcard("rfd/#{site}[0-9][0-9][0-9]-*.txn"), do: Path.basename(f)
    branches = remote_branches() ++ files

    for name <- branches,
        [_, d] <- [Regex.run(~r/(?:^|rfd-)(\d{4})-/, name)],
        do: String.to_integer(d)
  end

  defp remote_branches do
    case System.cmd("git", ~w(ls-remote --heads origin refs/heads/dev/rfd-*),
           stderr_to_stdout: true
         ) do
      {out, 0} ->
        String.split(out, "\n", trim: true)

      {out, _} ->
        Mix.shell().error("pushed branches not read, so not counted: #{String.trim(out)}")
        []
    end
  end
end
