# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2383-the-assistant-draws-with-the-pen-through-steamvr-priority-mode.exs
defmodule Rfd2383 do
  use Taskweft.DSL

  @name "rfd_2383"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2383": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2383": 0}}
  }

  @todo_list [
    ["prepare", "2383"],
    ["land", "2383"]
  ]
end
