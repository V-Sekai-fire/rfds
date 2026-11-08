# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2470-minizinc-challenge-blocks-world-on-the-gtn-blocks-methods-climbing-fro.exs
defmodule Rfd2470 do
  use Taskweft.DSL

  @name "rfd_2470"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2470": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2470": 0}}
  }

  @todo_list [
    ["prepare", "2470"],
    ["land", "2470"]
  ]
end
