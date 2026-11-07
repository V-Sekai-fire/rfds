# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2443-entityserver-serves-64-hz-entity-state-beside-feedserver.exs
defmodule Rfd2443 do
  use Taskweft.DSL

  @name "rfd_2443"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2443": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2443": 1}}
  }

  @todo_list [
    ["prepare", "2443"],
    ["land", "2443"]
  ]
end
