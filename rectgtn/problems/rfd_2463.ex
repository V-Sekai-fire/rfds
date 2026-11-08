# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2463-stablehlo-lower-tanh-bit-equal-with-xla-cpu.exs
defmodule Rfd2463 do
  use Taskweft.DSL

  @name "rfd_2463"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2463": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2463": 0}}
  }

  @todo_list [
    ["prepare", "2463"],
    ["land", "2463"]
  ]
end
