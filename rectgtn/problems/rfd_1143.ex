# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1143-keypoints-to-anny.exs
defmodule Rfd1143 do
  use Taskweft.DSL

  @name "rfd_1143"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1143": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1143": 1}}
  }

  @todo_list [
    ["prepare", "1143"],
    ["land", "1143"]
  ]
end
