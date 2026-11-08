# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2485-find-what-produces-the-100-730-ms-commits.exs
defmodule Rfd2485 do
  use Taskweft.DSL

  @name "rfd_2485"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2485": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2485": 0}}
  }

  @todo_list [
    ["prepare", "2485"],
    ["land", "2485"]
  ]
end
