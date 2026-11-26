# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Next do
  @shortdoc "Print the next free RFD serial and the three places it goes"
  @moduledoc """
      mix rfd.next [slug]

  The next serial is one past the highest the register has spent, a `rfd/` source
  on disk claims, or a pushed `dev/rfd-NNNN-*` branch claims.
  """
  use Mix.Task

  @register "SERIALS-vsekai-fabric.exs"

  @impl true
  def run(args) do
    slug = List.first(args) || "<slug>"
    [{mod, _} | _] = Code.compile_file(@register)
    reg = mod.__register__()
    site = reg.layer[:site]
    n = next(reg, claimed(site))
    last = reg.rows |> Enum.filter(&(elem(&1, 0) == :allocated)) |> Enum.max_by(&elem(&1, 1))

    Mix.shell().info("""
    Next free serial: #{n}

    1. In #{@register}, add this row to `allocated do`, below `serial #{elem(last, 1)}`:
           serial #{n}, "#{slug}"
    2. Write rfd/#{n}-#{slug}.exs. Copy the shape of rfd/#{elem(last, 1)}-#{elem(last, 2)}.exs.
    3. Work on branch dev/rfd-#{n}-#{slug}, and commit the row and the source together.
    """)
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
