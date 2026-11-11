# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2297-the-first-rungs-dev-3.exs
defmodule Rfd2297 do
  use Taskweft.DSL

  @name "rfd_2297"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2297": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2297": 0}}
  }

  @todo_list [
    ["prepare", "2297"],
    ["land", "2297"]
  ]
end
