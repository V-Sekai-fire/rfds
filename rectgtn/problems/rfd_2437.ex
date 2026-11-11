# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2437-voice-is-an-independent-native-slice.exs
defmodule Rfd2437 do
  use Taskweft.DSL

  @name "rfd_2437"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2437": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2437": 0}}
  }

  @todo_list [
    ["prepare", "2437"],
    ["land", "2437"]
  ]
end
