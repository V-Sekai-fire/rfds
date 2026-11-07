# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2445-the-lesson-surface-is-an-independent-native-slice.exs
defmodule Rfd2445 do
  use Taskweft.DSL

  @name "rfd_2445"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2445": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2445": 1}}
  }

  @todo_list [
    ["prepare", "2445"],
    ["land", "2445"]
  ]
end
