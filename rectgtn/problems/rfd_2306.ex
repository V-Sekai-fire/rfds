# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2306-operating-the-shared-windows-vr-desk.exs
defmodule Rfd2306 do
  use Taskweft.DSL

  @name "rfd_2306"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2306": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2306": 2}}
  }

  @todo_list [
    ["prepare", "2306"],
    ["land", "2306"]
  ]
end
