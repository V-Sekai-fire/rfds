# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2486-tri2d-cli-shared-algorithm-repo.exs
defmodule Rfd2486 do
  use Taskweft.DSL

  @name "rfd_2486"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2486": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2486": 0}}
  }

  @todo_list [
    ["prepare", "2486"],
    ["land", "2486"]
  ]
end
