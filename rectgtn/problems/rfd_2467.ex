# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2467-stablehlo-lower-power.exs
defmodule Rfd2467 do
  use Taskweft.DSL

  @name "rfd_2467"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2467": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2467": 0}}
  }

  @todo_list [
    ["prepare", "2467"],
    ["land", "2467"]
  ]
end
