# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2360, "The campus as a beta", :discussion do
  flight_level :l1
  scope "the stages, the one beta, and the nongoals."

  prose ~S"""
  :: hook
  Which features does the campus beta ship?
  :: intrigue
  A feature that misses the one beta is abandoned rather than deferred.
  :: exit
  Check a new idea against the nongoals in the details, and cut the beta when every gate passes
  with its control.
  :: decision
  The beta ships these four features and nothing else. Every nongoal is abandoned (operator,
  2026-10-30).
  - See each other: two people in the campus zone, one in the Steam Frame on a PC VR stream and
    one on the desktop, each sees the other's avatar.
  - Hear each other: voice between the two, played at the speaker's avatar.
  - Draw and wear: the pen's first rung, RFD66606-2287, in the campus zone. The other person
    sees the drawn outfit worn.
  - An adventure party and a shopkeeper persona: one player and the three seats, each filled by a friend or a
    persona, the takeover, the walk from the shop to a room and back, and the shopkeeper persona
    with its saved world.
  - The beta is a feature-complete freeze after dev. It is cut when every gate in
    RFD66606-2436 to RFD66606-2440 passes with its control.
  - The beta ships one win64 build. It runs natively on Windows, and through FEX on the Steam
    Frame in standalone and desktop modes and on the Steam Deck (operator, 2026-11-01).
  - Every server piece is win64: the zone server, the stores and the secrets engine. Where the
    host is ARM it runs through FEX. A test on the Mac also runs through Proton and FEX
    (operator, 2026-11-01).
  :: related
  - RFD66606-2436 to RFD66606-2440, the five slices that carry the features.
  - RFD66606-2312, the form of the release tag.
  """

  details_title "The campus ships one beta"

  prose ~S"""
  :: details Non-goals
  Everything outside the beta is cut, and every nongoal is abandoned rather than deferred
  (operator, 2026-10-30). A new idea that matches a nongoal is refused, and the list is not argued
  again before the beta ships. The non-goals named so far:

  - a hidden director that plans the day
  - friendships and romance
  - a shared limit gauge with a team finisher
  - shop prices and a loan
  - an end-of-day report
  - a job board where each seat accepts or refuses a job
  - campuses built by players
  - the Hyper-V machine with its emulated TPM
  :: details What is not known
  - Whether each server piece has a win64 build, and which RFDs that describe the Linux images
    the rule replaces. Each is read from its source before it is amended.
  - How a Mac runs FEX and Proton. Both need a Linux guest on the Mac, and no run has made one.
  :: details After the cut
  Dev is development: features land and change. After the beta is cut, only fixes land.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2360", :spends, "see-each-other"
    relate "rfd-2360", :spends, "hear-each-other"
    relate "rfd-2360", :spends, "draw-and-wear"
    relate "rfd-2360", :spends, "adventure-party"
    relate "rfd-2360", :spends, "shop-books"
  end
end
