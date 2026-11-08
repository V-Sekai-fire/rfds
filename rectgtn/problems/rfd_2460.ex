# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2460-store-off-the-loop-passive-compaction-thread-transfer-from-rust-iourin.exs
defmodule Rfd2460 do
  use Taskweft.DSL

  @name "rfd_2460"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2460": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2460": 0}}
  }

  @todo_list [
    ["prepare", "2460"],
    ["land", "2460"]
  ]
end
