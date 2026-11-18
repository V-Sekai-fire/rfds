# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2498-zfs-pool-written-raw-to-bdxl-disc.exs
defmodule Rfd2498 do
  use Taskweft.DSL

  @name "rfd_2498"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2498": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2498": 0}}
  }

  @todo_list [
    ["prepare", "2498"],
    ["land", "2498"]
  ]
end
