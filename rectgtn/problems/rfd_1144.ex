# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1144-image-to-omnigen2.exs
defmodule Rfd1144 do
  use Taskweft.DSL

  @name "rfd_1144"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1144": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1144": 1}}
  }

  @todo_list [
    ["prepare", "1144"],
    ["land", "1144"]
  ]
end
