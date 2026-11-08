# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2468-stablehlo-run-time-i32-arithmetic.exs
defmodule Rfd2468 do
  use Taskweft.DSL

  @name "rfd_2468"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2468": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2468": 0}}
  }

  @todo_list [
    ["prepare", "2468"],
    ["land", "2468"]
  ]
end
