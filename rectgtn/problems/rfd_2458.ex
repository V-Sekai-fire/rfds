# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2458-declare-the-real-alternatives-between-rfds-so-choice-and-backtracking.exs
defmodule Rfd2458 do
  use Taskweft.DSL

  @name "rfd_2458"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2458": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2458": 0}}
  }

  @todo_list [
    ["prepare", "2458"],
    ["land", "2458"]
  ]
end
