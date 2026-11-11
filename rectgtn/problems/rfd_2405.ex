# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2405-the-rung-s-setup-uses-a-fixed-set-of-credentials.exs
defmodule Rfd2405 do
  use Taskweft.DSL

  @name "rfd_2405"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2405": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2405": 0}}
  }

  @todo_list [
    ["prepare", "2405"],
    ["land", "2405"]
  ]
end
