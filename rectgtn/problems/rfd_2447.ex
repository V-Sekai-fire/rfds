# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2447-campus-beta-1-see-each-other.exs
defmodule Rfd2447 do
  use Taskweft.DSL

  @name "rfd_2447"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2447": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2447": 1}}
  }

  @todo_list [
    ["prepare", "2447"],
    ["land", "2447"]
  ]
end
