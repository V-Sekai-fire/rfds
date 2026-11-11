# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2448, "Campus beta 2: hear each other", :discussion do
  feature "the second milestone beta of RFD66606-2360, two features wide."
  scope "adding voice to RFD66606-2447's see-each-other beta."

  prose ~S"""
  :: hook
  Once two people see each other, does hearing each other ship as its own next version?
  :: intrigue
  RFD66606-2447 (campus beta 1) cuts the first milestone on sight alone. Voice is a second slice
  with its own gate, and stacking it onto beta 1 gives a second version with no new feature left
  unverified from the one before it.
  :: exit
  Run the sight gate of RFD66606-2436 and the voice gate of RFD66606-2437, and cut beta 2 once
  both pass with their controls.
  :: decision
  Beta 2 ships two features: everything in beta 1, plus voice between the two people (operator,
  2026-11-07).
  - See each other, RFD66606-2436 (the see-each-other slice): carried over from beta 1 unchanged.
  - Hear each other, RFD66606-2437 (the hear-each-other slice): voice between the two, played at
    the speaker's avatar.
  - The remaining four features of RFD66606-2360 are deferred to the next beta in this sequence,
    not abandoned.
  :: related
  - RFD66606-2360, the full campus beta this milestone works toward.
  - RFD66606-2447, the beta 1 milestone this one extends.
  - RFD66606-2437, the slice this beta adds.
  """

  details_title "Campus beta 2: hear each other"

  prose ~S"""
  :: details Non-goals
  The pen, the adventure party, the shopkeeper persona, zone transfer and the lesson surface stay
  out of scope. Each is deferred to a later beta in this sequence (beta 3 through beta 6), not
  abandoned: RFD66606-2360's own non-goals list still governs what is cut from the product
  altogether.
  :: details What is not known
  - Whether the two people hear each other at a shared loudness regardless of avatar distance, or
    whether distance already attenuates voice at this milestone.
  """
end
