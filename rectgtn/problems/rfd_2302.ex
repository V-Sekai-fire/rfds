# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2302-guest-work-runs-in-frame-slices.exs
defmodule Rfd2302 do
  use Taskweft.DSL

  @name "rfd_2302"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2302": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2302": 0}}
  }

  @todo_list [
    ["prepare", "2302"],
    ["land", "2302"]
  ]
end
