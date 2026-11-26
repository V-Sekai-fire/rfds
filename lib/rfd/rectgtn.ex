# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Step do
  @moduledoc false
  @enforce_keys [:name]
  defstruct name: nil, repos: [], missing: nil, check: nil, control: nil, state: :ready

  @type t :: %__MODULE__{}
end

defmodule RFD.RECTGTN do
  @moduledoc """
  The organization as one Taskweft RECTGTN domain, and each RFD as one problem that
  compiles into a solution.

  The domain is the organization: the ladder an RFD climbs and the step vocabulary
  RFD66606-2287 states for its critical path. A problem is one RFD's position on that
  ladder and the state of each step it declares. Both are Taskweft's own Elixir DSL,
  `Taskweft.Compose.compose_strings/2` merges the pair, and the plan it returns is the
  solution. `scripts/check_rectgtn_plan.exs` holds the rendered solution against it.

  """

  @states %{
    abandoned: -2,
    prediscussion: 0,
    ideation: 1,
    discussion: 2,
    published: 3,
    committed: 4
  }

  @step_states %{parked: -2, failed: -1, ready: 0, checked: 1}
  @levels %{l1: 1, l2: 2, l3: 3}
  @landed :committed
  @stopped [:abandoned]
  @domain "weftspun_organization"

  @actions [
    {"draft", [:serial], "A source under rfd/ that compiles inside RFD 1000's shape.",
     {"/rfd_state/{serial}", @states.discussion}},
    {"run-step", [:serial, :step],
     "One declared step, which ends at its own check and the control that must fail.",
     {"/step_state/{serial}.{step}", @step_states.checked}},
    {"close-the-gap", [:serial, :step],
     "The work a failed step named as missing, which makes the step ready to run again.",
     {"/step_state/{serial}.{step}", @step_states.ready}},
    {"park-step", [:serial, :step],
     "The step is named as parked rather than claimed done, with its reason.",
     {"/step_state/{serial}.{step}", @step_states.parked}},
    {"gate", [:serial], "`mix rfd.render`, `mix rfd.check`, `mix rfd.rebac` and the prek hooks.",
     {"/rfd_state/{serial}", @states.published}},
    {"open-pr", [:serial],
     "One pull request carrying the source, its register row and what shares its reasoning.",
     nil},
    {"enqueue", [:serial], "The merge queue takes it on green, and never `--admin`.",
     {"/rfd_state/{serial}", @states.committed}}
  ]

  def states, do: @states
  def step_states, do: @step_states
  def levels, do: @levels
  def domain_name, do: @domain

  @doc "Every reason a step declaration is not well formed."
  def problems(%{steps: steps}) when is_list(steps) do
    shape =
      Enum.flat_map(steps, fn s ->
        for {field, value} <- [name: s.name, check: s.check],
            not (is_binary(value) and String.trim(value) != ""),
            do: "step #{inspect(s.name)} states no #{field}"
      end)

    repos =
      for s <- steps,
          not (is_list(s.repos) and s.repos != [] and Enum.all?(s.repos, &is_binary/1)),
          do: "step #{inspect(s.name)} names no repository"

    unknown =
      for s <- steps,
          not Map.has_key?(@step_states, s.state),
          do:
            "step #{inspect(s.name)} is #{inspect(s.state)}, " <>
              "not one of #{inspect(Map.keys(@step_states))}"

    parked =
      for s <- steps,
          s.state == :parked and (s.missing == nil or String.trim(s.missing) == ""),
          do: "step #{inspect(s.name)} is parked and names nothing missing"

    dup =
      for {n, c} <- Enum.frequencies(Enum.map(steps, & &1.name)),
          c > 1,
          do: "step #{inspect(n)} is declared #{c} times"

    shape ++ repos ++ unknown ++ parked ++ dup
  end

  def problems(_), do: []

  # --- the solution ----------------------------------------------------------------

  @doc """
  The plan the domain compiles this problem into.

  Deterministic, because every alternative's check reads one pointer the problem states.
  A step that is `ready` runs; one that `failed` gains a `close-the-gap` before its
  retry, so a failure makes the plan longer rather than making it fail; one that is
  `parked` or `checked` expands to nothing.
  """
  def plan(%{} = doc) do
    if doc.state in @stopped or @states[doc.state] >= @states[@landed] do
      []
    else
      id = Integer.to_string(doc.serial)

      prepare = if @states[doc.state] == @states.discussion, do: [], else: [["draft", id]]

      steps =
        doc.steps
        |> Enum.with_index(1)
        |> Enum.flat_map(fn {s, n} -> step_plan(id, s, Integer.to_string(n)) end)

      prepare ++ steps ++ [["gate", id], ["open-pr", id], ["enqueue", id]]
    end
  end

  defp step_plan(_id, %{state: state}, _n) when state in [:checked, :parked], do: []
  defp step_plan(id, %{state: :failed}, n), do: [["close-the-gap", id, n], ["run-step", id, n]]
  defp step_plan(id, _step, n), do: [["run-step", id, n]]

  # --- the Markdown a reader reads -------------------------------------------------

  @doc "The organization domain as the sections RFD66606-2292 carries."
  def domain_sections do
    [
      {"The ladder is the domain", ladder_table()},
      {"The actions", action_table()},
      {"The methods, and where the antifragility is", method_list()},
      {"Compiling one problem into a solution", compile_note()}
    ]
  end

  @doc "One RFD as the problem and solution sections its DETAILS carries."
  def problem_sections(%{steps: []}), do: []

  def problem_sections(%{} = doc) do
    [
      {"The critical path", step_blocks(doc)},
      {"As a RECTGTN problem", problem_block(doc)},
      {"The solution the planner compiles", solution_block(doc)}
    ]
  end

  defp ladder_table do
    rows =
      @states
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.map(fn {state, n} -> "| `#{state}` | #{n} |" end)

    steps =
      Enum.map_join(Enum.sort_by(@step_states, &elem(&1, 1)), ", ", fn {s, n} ->
        "`#{s}` is #{n}"
      end)

    levels =
      Enum.map_join(Enum.sort_by(@levels, &elem(&1, 1)), ", ", fn {l, n} -> "`#{l}` is #{n}" end)

    Enum.join(
      ["| state | `/rfd_state` |", "|---|---|" | rows] ++
        [
          "",
          "An RFD is landed when `/rfd_state/<serial>` reaches #{@states[@landed]}, " <>
            "which is `#{@landed}`.",
          "A negative value is a document off the ladder rather than behind on it, and a",
          "problem asks for no plan while an RFD is in one.",
          "",
          "A declared step is #{steps}, held at `/step_state/<serial>.<index>`.",
          "`/flight_level/<serial>` carries the altitude of RFD 2177 (#{levels}), " <>
            "and 0 is an RFD that states none."
        ],
      "\n"
    )
  end

  defp action_table do
    rows =
      for {name, params, description, effect} <- @actions do
        written =
          case effect do
            nil -> "nothing"
            {pointer, value} -> "`#{pointer}` = #{value}"
          end

        "| `#{name}` | #{Enum.map_join(params, ", ", &"`#{&1}`")} | #{written} | #{description} |"
      end

    Enum.join(
      ["| action | params | what it writes | what it is |", "|---|---|---|---|" | rows],
      "\n"
    )
  end

  defp method_list do
    """
    Three task methods, and the planner tries each alternative in order.

    - **`prepare`** draws the RFD to `discussion`, or expands to nothing when it is
      already there.
    - **`step`** is where a failure pays. Its alternatives run
      `already_checked`, `close_the_gap_first`, `parked_and_named`, `run_it`,
      `park_it`. A step the problem states as `failed` matches
      `close_the_gap_first`, which plans `close-the-gap` **and then** `run-step`, so
      the plan a failure produces is longer and more specific than the plan before
      it. A step that cannot be closed matches `park_it` and is named rather than
      quietly dropped.
    - **`land`** runs `gate`, `open-pr`, `enqueue`, or expands to nothing when the
      RFD is already committed.

    The measurement, with its control: four problems over the same four-step RFD,
    differing only in step 3's state.

    | step 3 | plan length | what the planner adds |
    |---|---|---|
    | `ready` (the control) | 7 | nothing |
    | `failed` | 8 | `close-the-gap 2287 3` before the retry |
    | `parked` | 6 | nothing, and step 3 is not run |
    | `checked` | 6 | nothing, and step 3 is not run again |

    The failed case is the one that matters: the plan grew by the step that closes the
    gap. A system that merely survived the failure would have planned 7 again and
    retried the same step.
    """
    |> String.trim_trailing()
  end

  defp compile_note do
    """
    Both halves are Taskweft's own Elixir DSL, and `mix rfd.rectgtn` renders them:

        mix rfd.rectgtn                  # rectgtn/organization.ex and one problem per RFD
        mix rfd.rectgtn --check          # fails on drift, the way mix rfd.render does

    The planner is reached through our own implementation rather than a file format:

        {:ok, merged} = Taskweft.Compose.compose_strings([domain, problem], format: "dsl")
        Taskweft.NIF.plan(merged)

    `Taskweft.Compose` compiles each document with `check_calls: false`, which is what
    lets a problem call `prepare`, `step` and `land` without redefining them, and then
    checks every name once on the merged document. `scripts/check_rectgtn_plan.exs`
    runs that against the rendered solution in each RFD's `DETAILS.md` and fails when
    the two disagree, so a rendered plan is a measurement rather than a claim.
    """
    |> String.trim_trailing()
  end

  defp step_blocks(%{steps: steps}) do
    index =
      steps
      |> Enum.with_index(1)
      |> Enum.map_join("\n", fn {s, n} ->
        "| #{n} | #{s.name} | #{Enum.map_join(s.repos, ", ", &"`#{&1}`")} | `#{s.state}` |"
      end)

    blocks =
      steps
      |> Enum.with_index(1)
      |> Enum.map_join("\n\n", fn {s, n} ->
        [
          "### #{n}. #{s.name}",
          s.missing && "**What is missing.** #{s.missing}",
          "**Check.** #{s.check}",
          s.control && "**Control.** #{s.control}"
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join("\n\n")
      end)

    """
    Each step starts when the one before it runs, and each ends at its own check.
    The order below is the `run-step` order the planner takes.

    | # | step | repository | state |
    |---|---|---|---|
    #{index}

    #{blocks}
    """
    |> String.trim_trailing()
  end

  defp problem_block(%{} = doc) do
    inits =
      doc.steps
      |> Enum.with_index(1)
      |> Enum.map_join("\n", fn {s, n} ->
        "        /step_state/#{doc.serial}.#{n} = #{@step_states[s.state]}   # #{s.state}"
      end)

    """
    This RFD is one problem against the `#{@domain}` domain (RFD 2292), rendered to
    `rectgtn/problems/rfd_#{doc.serial}.ex` by `mix rfd.rectgtn`:

        source: #{@domain}
        /rfd_state/#{doc.serial} = #{@states[doc.state]}   # #{doc.state}
    #{inits}

    Its todo list is `prepare`, one `step` task per declared step, then `land`. The
    problem states which steps exist and what state each is in; the domain states what
    preparing a document, running a step and landing it are.
    """
    |> String.trim_trailing()
  end

  defp solution_block(%{} = doc) do
    plan = plan(doc)

    if plan == [] do
      "This RFD is #{doc.state}, so the problem asks for no plan and the solution is empty."
    else
      numbered =
        plan
        |> Enum.with_index(1)
        |> Enum.map_join("\n", fn {[action | args], n} ->
          params = Enum.map_join(args, ", ", &"`#{&1}`")
          "| #{n} | `#{action}` | #{params} | #{annotation(doc, action, args)} |"
        end)

      """
      Composing the domain with this problem and planning it returns #{length(plan)} steps:

      | # | action | args | what it stands for |
      |---|---|---|---|
      #{numbered}

      `scripts/check_rectgtn_plan.exs` asks the planner for this plan and fails when it
      differs, so the table is a measurement rather than a claim.
      """
      |> String.trim_trailing()
    end
  end

  defp annotation(doc, action, args) when action in ["run-step", "close-the-gap", "park-step"] do
    case Integer.parse(List.last(args)) do
      {n, ""} -> Enum.at(doc.steps, n - 1).name
      _ -> "a declared step"
    end
  end

  defp annotation(_doc, "draft", _), do: "the source compiles inside RFD 1000's shape"
  defp annotation(_doc, "gate", _), do: "the render and the prek hooks pass"
  defp annotation(_doc, "open-pr", _), do: "one pull request"
  defp annotation(_doc, "enqueue", _), do: "the queue takes it on green"

  # --- the Elixir the planner loads -------------------------------------------------

  @doc "The organization domain as a `Taskweft.DSL` module."
  def domain_source do
    """
    # Copyright (c) 2026 K. S. Ernest (iFire) Lee
    # SPDX-License-Identifier: MIT
    #
    # `mix rfd.rectgtn` renders this from RFD.RECTGTN; it is a build artifact
    # (RFD 2232, extended to the organization domain by RFD 2292). The problems
    # beside it in problems/ are rendered from the RFD sources.
    defmodule WeftspunOrganization do
      use Taskweft.DSL

      @name "#{@domain}"

      @enums %{
        rfd_state: %{#{kw(@states)}},
        step_state: %{#{kw(@step_states)}},
        flight_level: %{#{kw(@levels)}}
      }

      @variables %{
        rfd_state: %{type: :int, init: %{}},
        step_state: %{type: :int, init: %{}},
        flight_level: %{type: :int, init: %{}}
      }

      @actions %{
    #{Enum.map_join(@actions, ",\n", &action_source/1)}
      }

      @methods %{
        prepare: %{
          params: [:serial],
          alternatives: [
            %{
              name: :already_drafted,
              check: [#{eq_source("/rfd_state/{serial}", @states.discussion)}],
              subtasks: []
            },
            %{name: :draft_it, subtasks: [["draft", "{serial}"]]}
          ]
        },
        step: %{
          params: [:serial, :index],
          alternatives: [
            %{
              name: :already_checked,
              check: [#{eq_source("/step_state/{serial}.{index}", @step_states.checked)}],
              subtasks: []
            },
            %{
              name: :close_the_gap_first,
              check: [#{eq_source("/step_state/{serial}.{index}", @step_states.failed)}],
              subtasks: [
                ["close-the-gap", "{serial}", "{index}"],
                ["run-step", "{serial}", "{index}"]
              ]
            },
            %{
              name: :parked_and_named,
              check: [#{eq_source("/step_state/{serial}.{index}", @step_states.parked)}],
              subtasks: []
            },
            %{name: :run_it, subtasks: [["run-step", "{serial}", "{index}"]]},
            %{name: :park_it, subtasks: [["park-step", "{serial}", "{index}"]]}
          ]
        },
        land: %{
          params: [:serial],
          alternatives: [
            %{
              name: :already_landed,
              check: [#{eq_source("/rfd_state/{serial}", @states[@landed])}],
              subtasks: []
            },
            %{
              name: :gate_then_queue,
              subtasks: [
                ["gate", "{serial}"],
                ["open-pr", "{serial}"],
                ["enqueue", "{serial}"]
              ]
            }
          ]
        }
      }

      @todo_list []
    end
    """
  end

  @doc "One RFD as a `Taskweft.DSL` problem module paired to the domain by `@source`."
  def problem_source(%{} = doc) do
    id = Integer.to_string(doc.serial)
    level = (doc.flight_level && @levels[doc.flight_level]) || 0

    step_inits =
      doc.steps
      |> Enum.with_index(1)
      |> Enum.map_join(", ", fn {s, n} -> ~s("#{id}.#{n}": #{@step_states[s.state]}) end)

    todo =
      if plan(doc) == [] do
        "[]"
      else
        tasks =
          [~s(["prepare", "#{id}"])] ++
            for({_, n} <- Enum.with_index(doc.steps, 1), do: ~s(["step", "#{id}", "#{n}"])) ++
            [~s(["land", "#{id}"])]

        "[\n    " <> Enum.join(tasks, ",\n    ") <> "\n  ]"
      end

    """
    # Copyright (c) 2026 K. S. Ernest (iFire) Lee
    # SPDX-License-Identifier: MIT
    #
    # A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
    # rfd/#{slug(doc)}.exs
    defmodule Rfd#{doc.serial} do
      use Taskweft.DSL

      @name "rfd_#{doc.serial}"
      @source "#{@domain}"

      @variables %{
        rfd_state: %{type: :int, init: %{"#{id}": #{@states[doc.state]}}},
        step_state: %{type: :int, init: %{#{step_inits}}},
        flight_level: %{type: :int, init: %{"#{id}": #{level}}}
      }

      @todo_list #{todo}
    end
    """
  end

  defp kw(map) do
    map
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map_join(", ", fn {k, v} -> "#{k}: #{v}" end)
  end

  defp action_source({name, params, _description, effect}) do
    body =
      case effect do
        nil -> "[]"
        {pointer, value} -> ~s([%{pointer_set: "#{pointer}", value: #{value}}])
      end

    ~s(    "#{name}": %{params: #{inspect(params)}, body: #{body}})
  end

  defp eq_source(pointer, value) do
    ~s(%{eval: %{type: "math/eq", a: %{pointer_get: "#{pointer}"}, b: #{value}}})
  end

  @doc "The RFD's own directory name, which the problem's comment points back to."
  def slug(%{serial: serial}) do
    prefix = Integer.to_string(serial) <> "-"

    Path.wildcard("rfd/#{prefix}*.txn")
    |> Enum.map(&Path.basename(&1, ".txn"))
    |> Enum.find("#{serial}-unknown", &String.starts_with?(&1, prefix))
  end
end
