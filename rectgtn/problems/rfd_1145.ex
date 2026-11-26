# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1145-stylized-to-omnigen2.exs
defmodule Rfd1145 do
  use Taskweft.DSL

  @name "rfd_1145"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1145": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1145": 1}}
  }

  @todo_list [
    ["prepare", "1145"],
    ["land", "1145"]
  ]
end
