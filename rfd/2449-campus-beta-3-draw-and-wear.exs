# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2449, "Campus beta 3: draw and wear", :discussion do
  feature "the third milestone beta of RFD66606-2360, three features wide."
  scope "adding the pen's first rung to RFD66606-2448's hear-each-other beta."

  prose ~S"""
  :: hook
  Once two people see and hear each other, is a drawn outfit the next version to ship?
  :: intrigue
  RFD66606-2448 (campus beta 2) stacks voice onto sight. The pen's first rung, RFD66606-2287,
  already draws a worn garment in isolation; this milestone asks whether that slice runs alongside
  the two already shipped.
  :: exit
  Run the sight, voice and draw-and-wear gates together, and cut beta 3 once all three pass with
  their controls.
  :: decision
  Beta 3 ships three features: everything in beta 2, plus a drawn outfit worn in the zone
  (operator, 2026-11-07).
  - See each other, RFD66606-2436, and hear each other, RFD66606-2437: carried over from beta 2
    unchanged.
  - Draw and wear, RFD66606-2438 (the draw-and-wear slice): the pen's first rung, RFD66606-2287
    (the pen's first rung), in the campus zone. The other person sees the drawn outfit worn.
  - The remaining three features of RFD66606-2360 are deferred to the next beta in this sequence,
    not abandoned.
  :: related
  - RFD66606-2360, the full campus beta this milestone works toward.
  - RFD66606-2448, the beta 2 milestone this one extends.
  - RFD66606-2438, the slice this beta adds.
  """

  details_title "Campus beta 3: draw and wear"

  prose ~S"""
  :: details Non-goals
  The adventure party, the shopkeeper persona, zone transfer and the lesson surface stay out of
  scope. Each is deferred to a later beta in this sequence (beta 4 through beta 6), not abandoned:
  RFD66606-2360's own non-goals list still governs what is cut from the product altogether.
  :: details What is not known
  - Whether a drawn outfit persists across the session or is redrawn each time, at this milestone
    versus a later one.
  """
end
