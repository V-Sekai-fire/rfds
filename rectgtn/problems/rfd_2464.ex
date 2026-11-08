# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2464-stablehlo-lower-erf-bit-equal-with-xla-cpu.exs
defmodule Rfd2464 do
  use Taskweft.DSL

  @name "rfd_2464"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2464": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2464": 0}}
  }

  @todo_list [
    ["prepare", "2464"],
    ["land", "2464"]
  ]
end
