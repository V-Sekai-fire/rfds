# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: the solution each RFD renders is the plan Taskweft returns for its problem.
#
# The rendered table in an RFD's DETAILS.md is a claim until something asks the planner.
# This asks our own implementation: Taskweft.Compose merges rectgtn/organization.ex with
# rectgtn/problems/rfd_NNNN.ex and Taskweft.NIF.plan returns the solution (RFD66606-2292).
#
# Taskweft lives in another checkout, so this runs at the manual stage, where a `repo`
# workspace exists. A missing checkout is a FAIL rather than a skip: a silent skip reads
# exactly like a pass.
#
# Usage:
#     elixir scripts/check_rectgtn_plan.exs [--taskweft ../../3-interactor/taskweft]
#     elixir scripts/check_rectgtn_plan.exs --self-test
# Exit codes: 0 every rendered solution is the planner's, 1 one is not, 2 bad usage.

for f <- [
      "lib/rfd/rebac.ex",
      "lib/rfd/rectgtn.ex",
      "lib/rfd/hide.ex",
      "lib/rfd/doc.ex",
      "lib/rfd/dsl.ex"
    ],
    do: Code.require_file(f)

defmodule RectgtnPlanGate do
  # The workspace places taskweft on the interactor side. A worktree sits deeper, so the
  # candidates are tried in order rather than one path being assumed.
  @candidates [
    "../../3-interactor/taskweft",
    "../../../../../3-interactor/taskweft",
    "../../../../../../3-interactor/taskweft"
  ]

  defp default_taskweft, do: Enum.find(@candidates, List.first(@candidates), &File.dir?/1)

  def run(argv) do
    case OptionParser.parse(argv, strict: [taskweft: :string, self_test: :boolean]) do
      {[self_test: true], [], []} -> self_test()
      {opts, [], []} -> gate(opts[:taskweft] || default_taskweft())
      _ -> usage()
    end
  end

  defp usage do
    IO.puts(
      :stderr,
      "usage: elixir scripts/check_rectgtn_plan.exs [--taskweft DIR] | --self-test"
    )

    System.halt(2)
  end

  @doc "Every RFD that declares a critical path, with the solution its DETAILS renders."
  def rendered do
    Code.compiler_options(ignore_module_conflict: true)

    for path <- Path.wildcard("rfd/[0-9][0-9][0-9][0-9]-*.txn"),
        doc = RFD.Source.load(path),
        doc.steps != [] do
      {doc, RFD.RECTGTN.plan(doc)}
    end
  end

  defp gate(taskweft) do
    cases = rendered()

    cond do
      cases == [] ->
        IO.puts("check_rectgtn_plan: no RFD declares a critical path, so nothing is checked")
        System.halt(1)

      not File.dir?(taskweft) ->
        IO.puts("check_rectgtn_plan: no taskweft checkout at #{taskweft}")
        System.halt(1)

      true ->
        report(cases, taskweft)
    end
  end

  defp report(cases, taskweft) do
    problems =
      for {doc, want} <- cases, reduce: [] do
        acc ->
          case plan_through_taskweft(taskweft, doc) do
            {:ok, ^want} ->
              IO.puts("  ok   RFD #{doc.serial}: #{length(want)} steps")
              acc

            {:ok, got} ->
              IO.puts(
                "  FAIL RFD #{doc.serial}: rendered #{length(want)} steps, " <>
                  "planner #{length(got)}"
              )

              IO.puts("       rendered: #{inspect(want)}")
              IO.puts("       planner:  #{inspect(got)}")
              [doc.serial | acc]

            {:error, why} ->
              IO.puts("  FAIL RFD #{doc.serial}: #{why}")
              [doc.serial | acc]
          end
      end

    passed = length(cases) - length(problems)
    IO.puts("check_rectgtn_plan: #{passed}/#{length(cases)} solutions are the planner's")
    if problems != [], do: System.halt(1)
  end

  # The planner is reached through taskweft's own mix project, because the NIF lives there.
  defp plan_through_taskweft(taskweft, doc) do
    domain = Path.expand("rectgtn/organization.ex")
    problem = Path.expand("rectgtn/problems/rfd_#{doc.serial}.ex")

    script = """
    sources = [File.read!("#{domain}"), File.read!("#{problem}")]

    case Taskweft.Compose.compose_strings(sources, format: "dsl") do
      {:ok, merged} ->
        json = if is_binary(merged), do: merged, else: Jason.encode!(merged)
        IO.puts("PLAN " <> Taskweft.NIF.plan(json))

      {:error, reason} ->
        IO.puts("ERR " <> inspect(reason))
    end
    """

    file = Path.join(System.tmp_dir!(), "rectgtn_plan_#{doc.serial}.exs")
    File.write!(file, script)

    try do
      case System.cmd("mix", ["run", file], cd: taskweft, stderr_to_stdout: true) do
        {out, 0} -> decode(out)
        {out, code} -> {:error, "mix run exited #{code}: #{last_line(out)}"}
      end
    after
      File.rm(file)
    end
  end

  defp decode(out) do
    case Enum.find(String.split(out, "\n"), &String.starts_with?(&1, "PLAN ")) do
      nil -> {:error, "the planner printed no plan: #{last_line(out)}"}
      "PLAN " <> json -> {:ok, decode_plan(json)}
    end
  end

  defp decode_plan(json) do
    # The plan is a JSON array of arrays of strings, which is a narrow enough shape to
    # read without a JSON dependency: this project has none.
    json
    |> String.trim()
    |> String.trim_leading("[")
    |> String.trim_trailing("]")
    |> String.split(~r/\]\s*,\s*\[/)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(fn step ->
      step
      |> String.trim()
      |> String.trim_leading("[")
      |> String.trim_trailing("]")
      |> String.split(~r/\s*,\s*/)
      |> Enum.map(&String.trim(&1, "\""))
    end)
  end

  defp last_line(out) do
    lines = out |> String.split("\n") |> Enum.reject(&(String.trim(&1) == ""))
    List.last(lines) || "no output"
  end

  defp self_test do
    steps = fn states ->
      for {s, i} <- Enum.with_index(states, 1) do
        %RFD.Step{name: "step #{i}", repos: ["r"], check: "c", state: s, missing: "m"}
      end
    end

    doc = fn state, states ->
      %RFD.Doc{serial: 2999, title: "t", state: state, steps: steps.(states)}
    end

    controls = [
      {"a ready step plans one run-step", RFD.RECTGTN.plan(doc.(:discussion, [:ready])),
       [["run-step", "2999", "1"], ["gate", "2999"], ["open-pr", "2999"], ["enqueue", "2999"]]},
      {"a failed step plans the gap before the retry",
       RFD.RECTGTN.plan(doc.(:discussion, [:failed])),
       [
         ["close-the-gap", "2999", "1"],
         ["run-step", "2999", "1"],
         ["gate", "2999"],
         ["open-pr", "2999"],
         ["enqueue", "2999"]
       ]},
      {"a failure makes the plan longer than the same plan without it",
       length(RFD.RECTGTN.plan(doc.(:discussion, [:failed]))) >
         length(RFD.RECTGTN.plan(doc.(:discussion, [:ready]))), true},
      {"a checked step plans nothing", RFD.RECTGTN.plan(doc.(:discussion, [:checked])),
       [["gate", "2999"], ["open-pr", "2999"], ["enqueue", "2999"]]},
      {"a parked step plans nothing", RFD.RECTGTN.plan(doc.(:discussion, [:parked])),
       [["gate", "2999"], ["open-pr", "2999"], ["enqueue", "2999"]]},
      {"an undrafted RFD plans a draft first",
       RFD.RECTGTN.plan(doc.(:ideation, [])) |> List.first(), ["draft", "2999"]},
      {"a committed RFD plans nothing", RFD.RECTGTN.plan(doc.(:committed, [:ready])), []},
      {"an abandoned RFD plans nothing", RFD.RECTGTN.plan(doc.(:abandoned, [:ready])), []},
      {"a parked step that names nothing missing is refused",
       RFD.RECTGTN.problems(%{
         steps: [%RFD.Step{name: "s", repos: ["r"], check: "c", state: :parked}]
       }), ["step \"s\" is parked and names nothing missing"]},
      {"a step naming no repository is refused",
       RFD.RECTGTN.problems(%{steps: [%RFD.Step{name: "s", repos: [], check: "c"}]}),
       ["step \"s\" names no repository"]},
      {"a step with no check is refused",
       RFD.RECTGTN.problems(%{steps: [%RFD.Step{name: "s", repos: ["r"], check: nil}]}),
       ["step \"s\" states no check"]},
      {"a well-formed step is accepted",
       RFD.RECTGTN.problems(%{steps: [%RFD.Step{name: "s", repos: ["r"], check: "c"}]}), []},
      {"the rendered problem names the domain",
       String.contains?(
         RFD.RECTGTN.problem_source(doc.(:discussion, [:ready])),
         ~s(@source "weftspun_organization")
       ), true},
      {"the rendered domain carries a negative literal the parser used to refuse",
       String.contains?(RFD.RECTGTN.domain_source(), "value: -2"), true}
    ]

    results =
      for {name, got, want} <- controls do
        ok = got == want
        IO.puts("  #{if ok, do: "ok  ", else: "FAIL"} #{name}")
        unless ok, do: IO.puts("       got #{inspect(got)}\n       want #{inspect(want)}")
        ok
      end

    passed = Enum.count(results, & &1)
    IO.puts("check_rectgtn_plan self-test: #{passed}/#{length(results)} controls behave")
    if passed != length(results), do: System.halt(1)
  end
end

RectgtnPlanGate.run(System.argv())
