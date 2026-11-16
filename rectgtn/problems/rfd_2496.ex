# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2496-zfs-data-disks-on-the-mac-desk.exs
defmodule Rfd2496 do
  use Taskweft.DSL

  @name "rfd_2496"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2496": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2496": 0}}
  }

  @todo_list [
    ["prepare", "2496"],
    ["land", "2496"]
  ]
end
