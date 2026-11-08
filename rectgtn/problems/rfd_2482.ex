# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2482-build-a-50-200-mb-feed-shaped-table-before-any-read-or-cluster-shape-c.exs
defmodule Rfd2482 do
  use Taskweft.DSL

  @name "rfd_2482"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2482": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2482": 0}}
  }

  @todo_list [
    ["prepare", "2482"],
    ["land", "2482"]
  ]
end
