# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2232-rfd-dsl-in-elixir.exs
defmodule Rfd2232 do
  use Taskweft.DSL

  @name "rfd_2232"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2232": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2232": 2}}
  }

  @todo_list [
    ["prepare", "2232"],
    ["land", "2232"]
  ]
end
