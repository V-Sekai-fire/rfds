# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2287-the-first-rung-draw-and-wear-it-in-a-headset.exs
defmodule Rfd2287 do
  use Taskweft.DSL

  @name "rfd_2287"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2287": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2287": 0}}
  }

  @todo_list [
    ["prepare", "2287"],
    ["land", "2287"]
  ]
end
