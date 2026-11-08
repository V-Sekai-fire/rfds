# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2450, "Campus beta 4: adventure party and shop", :discussion do
  flight_level :l1
  feature "the fourth milestone beta of RFD66606-2360, four features wide."
  scope "adding the adventure party and the shopkeeper persona to RFD66606-2449's beta."

  prose ~S"""
  :: hook
  Once two people see, hear and dress each other, does the party ship as the next version?
  :: intrigue
  RFD66606-2449 (campus beta 3) carries sight, voice and a drawn outfit. The adventure party,
  RFD66606-2439, and the shopkeeper persona, RFD66606-2440, each have their own gate; this
  milestone asks whether both slot in alongside the three already shipped.
  :: exit
  Run the sight, voice, draw-and-wear, party-seat and shopkeeper-persona gates together, and cut
  beta 4 once all five pass with their controls.
  :: decision
  Beta 4 ships four features: everything in beta 3, plus the adventure party and the shopkeeper
  persona (operator, 2026-11-07).
  - See each other, hear each other and draw and wear: carried over from beta 3 unchanged.
  - An adventure party and a shopkeeper persona, RFD66606-2439 (the party-seat slice) and
    RFD66606-2440 (the shopkeeper-persona slice): one player and the three seats, each filled by a
    friend or a persona, the takeover, the walk from the shop to a room and back, and the
    shopkeeper persona with its saved world.
  - The remaining two features of RFD66606-2360 are deferred to the next beta in this sequence,
    not abandoned.
  :: related
  - RFD66606-2360, the full campus beta this milestone works toward.
  - RFD66606-2449, the beta 3 milestone this one extends.
  - RFD66606-2439 and RFD66606-2440, the slices this beta adds.
  """

  details_title "Campus beta 4: adventure party and shop"

  prose ~S"""
  :: details Non-goals
  Zone transfer and the lesson surface stay out of scope. Each is deferred to a later beta in this
  sequence (beta 5 and beta 6), not abandoned: RFD66606-2360's own non-goals list still governs
  what is cut from the product altogether.
  :: details What is not known
  - Whether the gate in RFD66606-2439 covers avatars and voice for the player and three filled
    seats, or only the two people of RFD66606-2436 and RFD66606-2437, at this milestone.
  """
end
