# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2493-a-zone-relay-only-routes.exs
defmodule Rfd2493 do
  use Taskweft.DSL

  @name "rfd_2493"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2493": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2493": 1}}
  }

  @todo_list [
    ["prepare", "2493"],
    ["land", "2493"]
  ]
end
