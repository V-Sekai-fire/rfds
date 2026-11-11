# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2441-github-job-logs-in-to-bao-with-its-identity-token.exs
defmodule Rfd2441 do
  use Taskweft.DSL

  @name "rfd_2441"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2441": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2441": 0}}
  }

  @todo_list [
    ["prepare", "2441"],
    ["land", "2441"]
  ]
end
