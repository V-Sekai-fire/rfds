# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2469-stablehlo-match-xla-cpu-s-summation-order-in-reduce-and-dot-general.exs
defmodule Rfd2469 do
  use Taskweft.DSL

  @name "rfd_2469"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2469": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2469": 0}}
  }

  @todo_list [
    ["prepare", "2469"],
    ["land", "2469"]
  ]
end
