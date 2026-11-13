# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2491-bonsai-2-runs-a-risc-v-machine-in-its-own-layers.exs
defmodule Rfd2491 do
  use Taskweft.DSL

  @name "rfd_2491"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2491": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2491": 0}}
  }

  @todo_list [
    ["prepare", "2491"],
    ["land", "2491"]
  ]
end
