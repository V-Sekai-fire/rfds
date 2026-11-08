# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2478-anny-soma-x-rf-detr-keypoints-hairdeck-muscle-supermimic-and-the-pose.exs
defmodule Rfd2478 do
  use Taskweft.DSL

  @name "rfd_2478"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2478": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2478": 0}}
  }

  @todo_list [
    ["prepare", "2478"],
    ["land", "2478"]
  ]
end
