# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2447, "Campus beta 1: see each other", :discussion do
  flight_level :l1
  feature "the first milestone beta of RFD66606-2360, one feature wide."
  scope "the one feature the first version beta ships."

  prose ~S"""
  :: hook
  Can the campus cut a first beta on one feature?
  :: intrigue
  RFD66606-2360 ships one feature. A team that waits on anything past the sight gate sees
  nothing run end to end.
  :: exit
  Run the sight gate of RFD66606-2436 against a recorded pose stream, and cut beta 1 once it
  passes with its control.
  :: decision
  Beta 1 ships one feature: two people see each other in the campus zone (operator, 2026-11-07).
  - See each other, RFD66606-2436 (the see-each-other slice): one person in the standalone Steam
    Frame and one on the desktop, each sees the other's avatar.
  - Every other feature of the earlier six-feature beta is abandoned, not deferred (operator,
    2026-11-11).
  :: related
  - RFD66606-2360, the campus beta, which ships this one feature.
  - RFD66606-2436, the slice this beta cuts against.
  """

  details_title "Campus beta 1: see each other"

  prose ~S"""
  :: details Non-goals
  Voice, the pen, the adventure party, the shopkeeper persona, zone transfer and the lesson
  surface are abandoned (operator, 2026-11-11). RFD66606-2360's own non-goals list governs what
  else is cut from the product.
  :: details What is not known
  - Whether the win64 build and FEX targets of RFD66606-2360 are exercised at beta 1, or first at
    a later milestone once more of the server pieces are in place.
  """
end
