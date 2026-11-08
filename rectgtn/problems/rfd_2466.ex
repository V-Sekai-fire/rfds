# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2466-stablehlo-lower-convolution.exs
defmodule Rfd2466 do
  use Taskweft.DSL

  @name "rfd_2466"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2466": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2466": 0}}
  }

  @todo_list [
    ["prepare", "2466"],
    ["land", "2466"]
  ]
end
