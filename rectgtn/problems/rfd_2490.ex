# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2490-what-the-fabric-is-for-and-what-it-is-not.exs
defmodule Rfd2490 do
  use Taskweft.DSL

  @name "rfd_2490"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2490": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2490": 2}}
  }

  @todo_list [
    ["prepare", "2490"],
    ["land", "2490"]
  ]
end
