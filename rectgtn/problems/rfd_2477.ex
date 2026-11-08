# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2477-suit-markers-structured-light-decoding-with-anonymous-corners-and-latt.exs
defmodule Rfd2477 do
  use Taskweft.DSL

  @name "rfd_2477"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2477": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2477": 0}}
  }

  @todo_list [
    ["prepare", "2477"],
    ["land", "2477"]
  ]
end
