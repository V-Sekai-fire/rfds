# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2476-suit-markers-raise-yield-per-island-toward-2310-without-the-id-cap.exs
defmodule Rfd2476 do
  use Taskweft.DSL

  @name "rfd_2476"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2476": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2476": 0}}
  }

  @todo_list [
    ["prepare", "2476"],
    ["land", "2476"]
  ]
end
