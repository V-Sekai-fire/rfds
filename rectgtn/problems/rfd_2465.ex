# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2465-stablehlo-lower-gather-with-indices-computed-at-run-time.exs
defmodule Rfd2465 do
  use Taskweft.DSL

  @name "rfd_2465"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2465": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2465": 0}}
  }

  @todo_list [
    ["prepare", "2465"],
    ["land", "2465"]
  ]
end
