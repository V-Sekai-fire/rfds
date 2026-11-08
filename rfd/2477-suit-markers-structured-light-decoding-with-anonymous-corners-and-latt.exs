# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd(
  2477,
  "Suit markers: structured-light decoding with anonymous corners and lattice voting",
  :prediscussion
) do
  feature "corners are placed by lattice voting, so markers read even when their id is wrong."

  scope "`predict_neighbours.py`, the chart's lattice, and the corner-voting gates it must pass."

  prose ~S"""
  :: hook
  Can a corner be placed on the chart correctly even when the id painted next to it is wrong?
  :: intrigue
  Treat the board as a spatially coded pattern instead of a set of independently-read tags:
  detect corners without trusting their ids, place each corner on the chart by voting over
  offsets, rotations and instances, and recover unread markers from their read neighbours.
  `predict_neighbours.py` already exists for this but was never run, and was left out of the
  earlier pull requests.
  :: exit
  Run `predict_neighbours.py` against planted gates before trusting any measurement from it.
  :: decision
  Ship three gates ahead of any measurement, each with its own planted-defect control:
  - A planted wrong offset must lose the vote, so one bad candidate never outvotes the
    consistent majority.
  - A blank pattern (no corners detected) gives nothing back, rather than a false placement.
  - The UV pass marks every assignment right or wrong, with no assignment left unjudged.
  Once those three gates pass, measure corners placed, wrong placements, and markers recovered
  that tag decoding alone misses, and report those three numbers together, not separately.
  :: related
  - RFD66606-2467, the dead-on gate this recovery path feeds markers back into.
  - RFD66606-2469, island charting and the fold test that screens markers before placement.
  """
end
