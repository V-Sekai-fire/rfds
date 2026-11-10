# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2489-body-measurements-from-base-model.exs
defmodule Rfd2489 do
  use Taskweft.DSL

  @name "rfd_2489"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2489": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2489": 0}}
  }

  @todo_list [
    ["prepare", "2489"],
    ["land", "2489"]
  ]
end
