# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2392, "df32 holds guest geometry far from the origin", :discussion do
  flight_level :l1
  scope "the scalar for guest geometry that must hold far from the origin."

  prose ~S"""
  :: hook
  Guest geometry far from the origin is held in df32, a pair of float32 values.
  :: intrigue
  Can a stroke be placed 3.8e8 m out when float32 spacing there is about 32 m?
  :: exit
  Check that any guest geometry far from the origin is held in df32, and that the canvas origin
  crosses the API boundary in df32 or double.
  :: decision
  - df32, a double-float pair of a high and a low float32, is the
    scalar for guest geometry that must hold far from the origin,
    with `two_sum`, `quick_two_sum` and `two_prod` as the anny Slang
    kernels write them.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "df32 holds guest geometry far from the origin"

  prose ~S"""
  :: details Canvas-local coordinates
  Graph math runs in
  canvas-local coordinates. The canvas origin crosses the API
  boundary in df32 or double. float32 stays a one-line switch, kept
  for comparison against float32 sources.
  :: details The problem
  On the Moon, about 3.8e8 m out, float32
  spacing is about 32 m, some 480 soda cans, so float32 world
  coordinates cannot place a stroke there.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2392", :provides, "df32-far-origin-geometry"
  end
end
