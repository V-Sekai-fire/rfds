# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2480-settle-the-single-writer-baseline-lone-writer-against-the-m-1-pair.exs
defmodule Rfd2480 do
  use Taskweft.DSL

  @name "rfd_2480"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2480": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2480": 0}}
  }

  @todo_list [
    ["prepare", "2480"],
    ["land", "2480"]
  ]
end
