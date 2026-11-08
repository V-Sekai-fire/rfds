# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2481-separate-this-mac-from-the-cluster-bare-commit-loop-on-the-wsl-desk.exs
defmodule Rfd2481 do
  use Taskweft.DSL

  @name "rfd_2481"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2481": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2481": 0}}
  }

  @todo_list [
    ["prepare", "2481"],
    ["land", "2481"]
  ]
end
