# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2403-the-zone-reaches-bao-by-a-certificate-bao-issues.exs
defmodule Rfd2403 do
  use Taskweft.DSL

  @name "rfd_2403"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2403": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2403": 0}}
  }

  @todo_list [
    ["prepare", "2403"],
    ["land", "2403"]
  ]
end
