# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2353-bao-runs-three-replicas-on-the-fdb-machines.exs
defmodule Rfd2353 do
  use Taskweft.DSL

  @name "rfd_2353"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2353": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2353": 2}}
  }

  @todo_list [
    ["prepare", "2353"],
    ["land", "2353"]
  ]
end
