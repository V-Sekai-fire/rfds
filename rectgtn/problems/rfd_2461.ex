# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2461-store-b-tree-cursor-reads-on-hot-read-paths-secondary-transfer-from-ru.exs
defmodule Rfd2461 do
  use Taskweft.DSL

  @name "rfd_2461"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2461": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2461": 0}}
  }

  @todo_list [
    ["prepare", "2461"],
    ["land", "2461"]
  ]
end
