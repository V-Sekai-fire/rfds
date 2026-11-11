# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2288-guest-capabilities-as-macaroons.exs
defmodule Rfd2288 do
  use Taskweft.DSL

  @name "rfd_2288"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2288": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2288": 1}}
  }

  @todo_list [
    ["prepare", "2288"],
    ["land", "2288"]
  ]
end
