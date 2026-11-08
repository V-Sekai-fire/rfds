# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2457-navigator-show-the-temporal-route-and-state-durations-for-the-beta-s-r.exs
defmodule Rfd2457 do
  use Taskweft.DSL

  @name "rfd_2457"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2457": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2457": 0}}
  }

  @todo_list [
    ["prepare", "2457"],
    ["land", "2457"]
  ]
end
