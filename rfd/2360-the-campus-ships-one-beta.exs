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
  The beta ships these five features and nothing else. Every nongoal is abandoned (operator,
  2026-10-30).
  - See each other, RFD66606-2436: two people in the campus zone, one in the Steam Frame on a PC
    VR stream and one on the desktop, each sees the other's avatar.
  - Hear each other, RFD66606-2437: voice between the two, played at the speaker's avatar.
  - Draw and wear, RFD66606-2438: the pen's first rung, RFD66606-2287, in the campus zone. The
    other person sees the drawn outfit worn.
  - An adventure party and a shopkeeper persona, RFD66606-2439 and RFD66606-2440: one player and
    the three seats, each filled by a friend or a persona, the takeover, the walk from the shop
    to a room and back, and the shopkeeper persona with its saved world.
  - Seamless zone transfer, RFD66606-2444: a person walks from one campus zone into another with
    no cut, and the other person sees the avatar leave the one zone and arrive in the other
    (operator, 2026-11-07).
  - The beta is a feature-complete freeze after dev. It is cut when every gate in
    RFD66606-2436 to RFD66606-2440 and RFD66606-2444 passes with its control.
  - The beta ships one win64 build. It runs natively on Windows, and through FEX on the Steam
    Frame in standalone and desktop modes and on the Steam Deck (operator, 2026-11-01).
  - Every server piece is win64: the zone server, the stores and the secrets engine. Where the
    host is ARM it runs through FEX. A test on the Mac also runs through Proton and FEX
    (operator, 2026-11-01).
  :: related
  - RFD66606-2436 to RFD66606-2440 and RFD66606-2444, the six slices that carry the features.
  - RFD66606-2312, the form of the release tag.
  """

  details_title "The campus ships one beta"

  prose ~S"""
  :: details Non-goals
  Everything outside the beta is cut, and every nongoal is abandoned rather than deferred
  (operator, 2026-10-30). A new idea that matches a nongoal is refused, and the list is not argued
  again before the beta ships. A daily lesson between the operator and one to three learners is a
  use of the five features, not a feature (operator, 2026-11-07). What a lesson wants beyond them is
  named below. The non-goals named so far:

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
  - a shared screen, slide, whiteboard or document in a zone; the lesson's screen sits on the
    desk beside the call
  - a paywall at the door: a licence, sponsor or membership check in the client or the server
  - a lesson record or a course cartridge: progress, completion, grades or an interchange format
  - host controls: mute-others, a raised hand or a per-person audio channel
  - more than four people in one zone
  - the campus as a stand-in for a call or a meeting-room app
  :: details What is not known
  - Whether each server piece has a win64 build, and which RFDs that describe the Linux images
    the rule replaces. Each is read from its source before it is amended.
  - Whether the gate in RFD66606-2439 covers avatars and voice for the player and three filled
    seats, or only the two people of RFD66606-2436 and RFD66606-2437.
  - How a Mac runs FEX and Proton. Both need a Linux guest on the Mac, and no run has made one.
  :: details After the cut
  Dev is development: features land and change. After the beta is cut, only fixes land.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2360", :spends, "see-each-other"
    relate "rfd-2360", :spends, "voice-native-slice"
    relate "rfd-2360", :spends, "draw-wear-native-slice"
    relate "rfd-2360", :spends, "party-seats-native-slice"
    relate "rfd-2360", :spends, "shop-books-native-slice"
    relate "rfd-2360", :spends, "zone-transfer-native-slice"
    relate "rfd-2360", :is_a, "release-rung"
    relate "rfd-2360", :owns, "rfd-2436"
    relate "rfd-2360", :owns, "rfd-2437"
    relate "rfd-2360", :owns, "rfd-2438"
    relate "rfd-2360", :owns, "rfd-2439"
    relate "rfd-2360", :owns, "rfd-2440"
    relate "rfd-2360", :owns, "rfd-2444"
  end
end
