# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Plan do
  @shortdoc "Validate every apparatus plan source"
  @moduledoc """
  `mix rfd.plan` compiles each plan source and reports every rule it breaks.

      mix rfd.plan               # every plan source
      mix rfd.plan PATH...       # only these

  It writes nothing. The `.exs` is the plan, and no layer is rendered beside it
  (operator, 2026-11-26).
  """
  use Mix.Task

  @roots ["apparatus", "."]

  @impl true
  def run(argv) do
    Mix.Task.run("app.start")
    {_opts, paths} = OptionParser.parse!(argv, strict: [])
    sources = if paths == [], do: discover(), else: paths

    if sources == [] do
      Mix.raise("no plan source found; a plan source is an .exs whose module uses RFD.Plan")
    end

    bad = sources |> Enum.map(&check/1) |> Enum.count(&(&1 == :bad))

    Mix.shell().info("#{length(sources)} plan(s), #{bad} outside their shape")
    if bad > 0, do: Mix.raise("a plan source breaks its shape; see the lines above")
  end

  defp discover do
    @roots
    |> Enum.flat_map(&Path.wildcard(Path.join([&1, "**", "*.exs"])))
    |> Enum.reject(&String.contains?(&1, ["deps/", "_build/", "test/"]))
    |> Enum.filter(&(File.read!(&1) =~ "use RFD.Plan"))
    |> Enum.uniq()
  end

  defp check(source) do
    case load(source) |> problems() do
      [] ->
        Mix.shell().info("  ok   #{source}")
        :ok

      ps ->
        Mix.shell().info("  FAIL #{source}:\n         " <> Enum.join(ps, "\n         "))
        :bad
    end
  end

  defp problems({:ok, plan}), do: RFD.Plan.problems(plan)
  defp problems({:error, msg}), do: [msg]

  # `RFD.Plan.build/2` raises while the source compiles, so a broken plan arrives here as
  # an exception rather than as a struct; both are reported the same way.
  defp load(source) do
    case Enum.find(Code.compile_file(source), fn {m, _} -> function_exported?(m, :__plan__, 0) end) do
      {mod, _} -> {:ok, mod.__plan__()}
      nil -> {:error, "defines no module with __plan__/0"}
    end
  rescue
    e -> {:error, Exception.message(e)}
  end
end
