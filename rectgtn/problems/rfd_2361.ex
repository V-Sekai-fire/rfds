# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2361-a-section-names-its-own-gate.exs
defmodule Rfd2361 do
  use Taskweft.DSL

  @name "rfd_2361"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2361": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2361": 2}}
  }

  @todo_list [
    ["prepare", "2361"],
    ["land", "2361"]
  ]
end
