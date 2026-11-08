# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2447, "Campus beta 1: see each other", :discussion do
  flight_level :l1
  feature "the first milestone beta of RFD66606-2360, one feature wide."
  scope "which of the six RFD66606-2360 features ship in the first version beta."

  prose ~S"""
  :: hook
  Can the campus ship a first cut before all six features of the full beta are done?
  :: intrigue
  RFD66606-2360 (the full campus beta) lists six features and ships them together. A team that
  waits on all six before the first version sees nothing run end to end until the last one lands.
  :: exit
  Run the sight gate of RFD66606-2436 against a recorded pose stream, and cut beta 1 once it
  passes with its control.
  :: decision
  Beta 1 ships one feature: two people see each other in the campus zone (operator, 2026-11-07).
  - See each other, RFD66606-2436 (the see-each-other slice): one person in the Steam Frame on a
    PC VR stream and one on the desktop, each sees the other's avatar.
  - Every other feature of RFD66606-2360 is deferred to the next beta in this sequence, not
    abandoned: it ships in beta 2 or later.
  :: related
  - RFD66606-2360, the full campus beta this milestone works toward.
  - RFD66606-2436, the slice this beta cuts against.
  """

  details_title "Campus beta 1: see each other"

  prose ~S"""
  :: details Non-goals
  Voice, the pen, the adventure party, the shopkeeper persona, zone transfer and the lesson
  surface are out of scope for this milestone. Each is deferred to a later beta in this sequence
  (beta 2 through beta 6), not abandoned: RFD66606-2360's own non-goals list still governs what is
  cut from the product altogether.
  :: details What is not known
  - Whether the win64 build and FEX targets of RFD66606-2360 are exercised at beta 1, or first at
    a later milestone once more of the server pieces are in place.
  """
end
