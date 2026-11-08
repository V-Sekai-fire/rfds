# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2483-find-the-group-commit-knee-rows-per-sqlite-transaction-against-commits.exs
defmodule Rfd2483 do
  use Taskweft.DSL

  @name "rfd_2483"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2483": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2483": 0}}
  }

  @todo_list [
    ["prepare", "2483"],
    ["land", "2483"]
  ]
end
