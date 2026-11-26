# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2168-retract-wholebody-detector-keep-renderer.exs
defmodule Rfd2168 do
  use Taskweft.DSL

  @name "rfd_2168"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2168": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2168": 1}}
  }

  @todo_list [
    ["prepare", "2168"],
    ["land", "2168"]
  ]
end
