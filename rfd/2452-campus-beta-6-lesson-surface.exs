# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2452, "Campus beta 6: lesson surface", :discussion do
  flight_level :l1
  feature "the sixth and final milestone beta of RFD66606-2360, six features wide."
  scope "adding the lesson surface to RFD66606-2451's zone-transfer beta, for full parity."

  prose ~S"""
  :: hook
  Once five of six features ship, does the lesson surface close the gap to the full campus beta?
  :: intrigue
  RFD66606-2451 (campus beta 5) carries five of the six features of RFD66606-2360 (the full
  campus beta). The lesson surface, RFD66606-2445, is the last slice; this milestone asks whether
  adding it brings the sequence to full parity with the parent RFD's scope.
  :: exit
  Run all six feature gates together, and cut beta 6 once every one passes with its control: this
  is the same cut rule as RFD66606-2360's own exit.
  :: decision
  Beta 6 ships all six features of RFD66606-2360 and is equivalent in scope to the full campus
  beta (operator, 2026-11-07).
  - See each other, hear each other, draw and wear, the adventure party, the shopkeeper persona
    and seamless zone transfer: carried over from beta 5 unchanged.
  - A lesson surface, RFD66606-2445 (the lesson-surface slice): a teacher draws on a board and
    shows a window, and the learners see both.
  - No feature of RFD66606-2360 remains deferred after this milestone; this is the last beta in
    the sequence.
  :: related
  - RFD66606-2360, the full campus beta this milestone completes.
  - RFD66606-2451, the beta 5 milestone this one extends.
  - RFD66606-2445, the slice this beta adds.
  """

  details_title "Campus beta 6: lesson surface"

  prose ~S"""
  :: details Non-goals
  Beta 6 carries no non-goal of its own beyond RFD66606-2360's: this milestone is the full beta,
  so every item in that RFD's non-goals list is abandoned rather than deferred, exactly as the
  parent states.
  :: details What is not known
  - Whether the six gates run together as one combined cut check, or as six separate checks that
    each report pass before the beta is cut.
  """
end
