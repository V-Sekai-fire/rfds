# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2394-the-template-release-fault-is-diagnosed-not-guessed.exs
defmodule Rfd2394 do
  use Taskweft.DSL

  @name "rfd_2394"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2394": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2394": 0}}
  }

  @todo_list [
    ["prepare", "2394"],
    ["land", "2394"]
  ]
end
