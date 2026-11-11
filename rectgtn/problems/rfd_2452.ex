# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2452-campus-beta-6-lesson-surface.exs
defmodule Rfd2452 do
  use Taskweft.DSL

  @name "rfd_2452"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2452": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2452": 0}}
  }

  @todo_list [
    ["prepare", "2452"],
    ["land", "2452"]
  ]
end
