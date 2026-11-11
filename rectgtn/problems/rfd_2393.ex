# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2393-the-pen-builds-and-ships-only-the-first-rung-s-guests.exs
defmodule Rfd2393 do
  use Taskweft.DSL

  @name "rfd_2393"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2393": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2393": 0}}
  }

  @todo_list [
    ["prepare", "2393"],
    ["land", "2393"]
  ]
end
