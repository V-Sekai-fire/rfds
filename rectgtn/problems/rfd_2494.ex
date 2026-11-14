# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2494-mojo-builds-to-a-risc-v-guest-elf.exs
defmodule Rfd2494 do
  use Taskweft.DSL

  @name "rfd_2494"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2494": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2494": 0}}
  }

  @todo_list [
    ["prepare", "2494"],
    ["land", "2494"]
  ]
end
