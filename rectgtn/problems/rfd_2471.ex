# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2471-minizinc-challenge-precedence-scheduling-problems-on-the-temporal-plan.exs
defmodule Rfd2471 do
  use Taskweft.DSL

  @name "rfd_2471"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2471": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2471": 0}}
  }

  @todo_list [
    ["prepare", "2471"],
    ["land", "2471"]
  ]
end
