# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2356-workspace-services-stay-dns-only.exs
defmodule Rfd2356 do
  use Taskweft.DSL

  @name "rfd_2356"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2356": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2356": 2}}
  }

  @todo_list [
    ["prepare", "2356"],
    ["land", "2356"]
  ]
end
