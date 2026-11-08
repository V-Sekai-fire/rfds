# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2484-load-the-challenge-seed-into-a-store-once-verified-by-counts-and-hashe.exs
defmodule Rfd2484 do
  use Taskweft.DSL

  @name "rfd_2484"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2484": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2484": 0}}
  }

  @todo_list [
    ["prepare", "2484"],
    ["land", "2484"]
  ]
end
