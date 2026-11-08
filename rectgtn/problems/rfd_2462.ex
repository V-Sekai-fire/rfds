# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2462-replace-thirdparty-llama-cpp-with-prismml-s-prism-branch-for-dflash-n.exs
defmodule Rfd2462 do
  use Taskweft.DSL

  @name "rfd_2462"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2462": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2462": 0}}
  }

  @todo_list [
    ["prepare", "2462"],
    ["land", "2462"]
  ]
end
