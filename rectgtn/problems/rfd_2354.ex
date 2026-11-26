# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2354-bao-unseals-itself-through-a-seal-bao-on-fly.exs
defmodule Rfd2354 do
  use Taskweft.DSL

  @name "rfd_2354"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2354": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2354": 2}}
  }

  @todo_list [
    ["prepare", "2354"],
    ["land", "2354"]
  ]
end
