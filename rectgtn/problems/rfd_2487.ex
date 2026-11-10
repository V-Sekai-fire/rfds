# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2487-cage-wrapped-surface-net.exs
defmodule Rfd2487 do
  use Taskweft.DSL

  @name "rfd_2487"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2487": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2487": 0}}
  }

  @todo_list [
    ["prepare", "2487"],
    ["land", "2487"]
  ]
end
