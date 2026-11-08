# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2473-planner-search-heuristics-for-the-shortest-plan.exs
defmodule Rfd2473 do
  use Taskweft.DSL

  @name "rfd_2473"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2473": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2473": 0}}
  }

  @todo_list [
    ["prepare", "2473"],
    ["land", "2473"]
  ]
end
