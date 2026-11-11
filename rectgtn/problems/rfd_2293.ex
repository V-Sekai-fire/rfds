# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2293-the-skateboards-workspace-and-the-first-rungs-plan.exs
defmodule Rfd2293 do
  use Taskweft.DSL

  @name "rfd_2293"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2293": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2293": 0}}
  }

  @todo_list [
    ["prepare", "2293"],
    ["land", "2293"]
  ]
end
