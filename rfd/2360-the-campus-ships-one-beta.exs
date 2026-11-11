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
  The beta ships one feature and nothing else. Every nongoal is abandoned (operator,
  2026-10-30).
  - See each other, RFD66606-2436: two people in the campus zone, one in the standalone Steam
    Frame and one on the desktop, each sees the other's avatar.
  - Voice, the pen, the adventure party, the shopkeeper persona, seamless zone transfer and the
    lesson surface are abandoned (operator, 2026-11-11).
  - A character moves by walk mode, RFD66606-2487, proved on the plaza walk of RFD66606-2408
    under RFD66606-2363: no hand-written character controller is added.
  - The beta is a feature-complete freeze after dev. It is cut when the gate in RFD66606-2436
    passes with its control.
  - The beta ships one win64 build. It runs through FEX on the Steam
    Frame in standalone and desktop modes and on the Steam Deck (operator, 2026-11-01).
  - Every server piece is win64: the zone server, the stores and the secrets engine. Where the
    host is ARM it runs through FEX. A test on the Mac also runs through Proton and FEX
    (operator, 2026-11-01).
  :: related
  - RFD66606-2436, the one slice; RFD66606-2487, RFD66606-2408 and RFD66606-2363, walking.
  - RFD66606-2312, the form of the release tag.
  """

  details_title "The campus ships one beta"

  prose ~S"""
  :: details Walk mode
  The character walks by walk mode: the motion guest drives it from clips in an AnimationLibrary
  (RFD66606-2487), first proved on the plaza walk of RFD66606-2408. No hand-written character
  controller is added (RFD66606-2363) (operator, 2026-11-11).
  :: details Non-goals
  Everything outside the beta is cut, and every nongoal is abandoned rather than deferred
  (operator, 2026-10-30). A new idea that matches a nongoal is refused, and the list is not argued
  again before the beta ships. The non-goals named so far:

  - voice between the players
  - the pen's draw and wear
  - an adventure party and a shopkeeper persona
  - seamless zone transfer
  - a lesson surface

  - a hidden director that plans the day
  - friendships and romance
  - a shared limit gauge with a team finisher
  - shop prices and a loan
  - an end-of-day report
  - a job board where each seat accepts or refuses a job
  - campuses built by players
  - the Hyper-V machine with its emulated TPM
  - an io_uring path in any server piece
  - a Linux-only server build
  - text chat
  - trading between players
  - combat, damage and dying
  - a leaderboard or achievements
  - real-money purchases
  - a build for any platform other than the one win64 build
  - a client for a phone or a web page
  - a market, a shop listing or a save slot for drawn outfits
  - moderation, reporting and blocking tools
  - a tutorial or first-run walkthrough
  - a language other than English
  - a recorder or a replay inside the campus
  - a teacher seat or a learner seat; the people of a lesson are the player and the party's seats
  - a paywall at the door: a licence, sponsor or membership check in the client or the server
  - a lesson record or a course cartridge: progress, completion, grades or an interchange format
  - host controls: mute-others, a raised hand or a per-person audio channel
  - more than four people in one zone
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
    relate "rfd-2360", :is_a, "release-rung"
    relate "rfd-2360", :owns, "rfd-2436"
    relate "rfd-2360", :owns, "rfd-2437"
    relate "rfd-2360", :owns, "rfd-2438"
    relate "rfd-2360", :owns, "rfd-2439"
    relate "rfd-2360", :owns, "rfd-2440"
    relate "rfd-2360", :owns, "rfd-2444"
    relate "rfd-2360", :owns, "rfd-2445"
  end
end
