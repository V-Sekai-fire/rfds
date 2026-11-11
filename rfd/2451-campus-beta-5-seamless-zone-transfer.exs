# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2451, "Campus beta 5: seamless zone transfer", :discussion do
  feature "the fifth milestone beta of RFD66606-2360, five features wide."
  scope "adding seamless zone transfer to RFD66606-2450's party-and-shop beta."

  prose ~S"""
  :: hook
  Once two people can see, hear, dress and adventure together, can they also walk between zones?
  :: intrigue
  RFD66606-2450 (campus beta 4) confines both people to one campus zone. Seamless zone transfer,
  RFD66606-2444, lets a person walk into another zone with no cut; this milestone asks whether
  that walk runs alongside the four features already shipped.
  :: exit
  Run the sight, voice, draw-and-wear, party-seat, shopkeeper-persona and zone-transfer gates
  together, and cut beta 5 once all six pass with their controls.
  :: decision
  Beta 5 ships five features: everything in beta 4, plus seamless zone transfer (operator,
  2026-11-07).
  - See each other, hear each other, draw and wear, the adventure party and the shopkeeper
    persona: carried over from beta 4 unchanged.
  - Seamless zone transfer, RFD66606-2444 (the zone-transfer slice): a person walks from one
    campus zone into another with no cut, and the other person sees the avatar leave and arrive.
  - The lesson surface, the last of RFD66606-2360's six features, is deferred to beta 6, the
    final milestone in this sequence, not abandoned.
  :: related
  - RFD66606-2360, the full campus beta this milestone works toward.
  - RFD66606-2450, the beta 4 milestone this one extends.
  - RFD66606-2444, the slice this beta adds.
  """

  details_title "Campus beta 5: seamless zone transfer"

  prose ~S"""
  :: details Non-goals
  The lesson surface stays out of scope. It is deferred to beta 6, not abandoned: RFD66606-2360's
  own non-goals list still governs what is cut from the product altogether.
  :: details What is not known
  - Whether a transfer mid-conversation keeps voice connected across the two zones at this
    milestone, or whether that join is a later refinement.
  """
end
