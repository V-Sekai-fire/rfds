# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2409-beta-one-person-wears-what-they-draw.exs
defmodule Rfd2409 do
  use Taskweft.DSL

  @name "rfd_2409"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2409": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2409": 2}}
  }

  @todo_list [
    ["prepare", "2409"],
    ["land", "2409"]
  ]
end
