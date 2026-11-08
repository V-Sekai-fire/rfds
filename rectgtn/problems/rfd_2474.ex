# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2474-suit-markers-dead-on-gate-must-read-every-marker.exs
defmodule Rfd2474 do
  use Taskweft.DSL

  @name "rfd_2474"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2474": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2474": 0}}
  }

  @todo_list [
    ["prepare", "2474"],
    ["land", "2474"]
  ]
end
