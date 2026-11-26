# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1146-latent-to-pixal3d.exs
defmodule Rfd1146 do
  use Taskweft.DSL

  @name "rfd_1146"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1146": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1146": 1}}
  }

  @todo_list [
    ["prepare", "1146"],
    ["land", "1146"]
  ]
end
