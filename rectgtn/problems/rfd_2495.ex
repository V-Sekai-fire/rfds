# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2495-aux-part-labels-from-alchemy3d-segment.exs
defmodule Rfd2495 do
  use Taskweft.DSL

  @name "rfd_2495"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2495": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2495": 0}}
  }

  @todo_list [
    ["prepare", "2495"],
    ["land", "2495"]
  ]
end
