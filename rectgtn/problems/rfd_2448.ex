# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2448-campus-beta-2-hear-each-other.exs
defmodule Rfd2448 do
  use Taskweft.DSL

  @name "rfd_2448"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2448": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2448": 0}}
  }

  @todo_list [
    ["prepare", "2448"],
    ["land", "2448"]
  ]
end
