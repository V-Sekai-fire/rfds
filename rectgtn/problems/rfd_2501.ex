# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2501-binaries-come-from-each-repositorys-flake.exs
defmodule Rfd2501 do
  use Taskweft.DSL

  @name "rfd_2501"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2501": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2501": 0}}
  }

  @todo_list [
    ["prepare", "2501"],
    ["land", "2501"]
  ]
end
