# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2360, "The campus as a beta", :discussion do
  flight_level :l1
  scope "the stages, the one beta, and the nongoals."

  prose ~S"""
  :: hook
  Which use cases does the campus beta ship?
  :: intrigue
  A feature that misses the one beta keeps its RFD and its state.
  :: exit
  Check a new idea against the non-goals in the details, and cut the
  beta when the gate of RFD66606-2436 passes with its control.
  :: decision
  The beta ships one platform and the use cases that ride on it
  (operator, 2026-11-25). The details hold the rest.
  - See each other, RFD66606-2436, cuts the beta: one person on the
    Steam Frame or the Steam Deck and one on the win64 desktop each see
    the other's avatar (operator, 2026-11-26).
  - Voice, the model console and the planning persona ride on it.
  - A server is a NixOS flake container under Ankaios (operator,
    2026-11-26).
  - A character moves by walk mode.
  :: related
  - RFD66606-2436, the one slice; RFD66606-2490, the mission.
  - RFD66606-2487, RFD66606-2408 and RFD66606-2363, walking.
  - RFD66606-2312, the release tag.
  - RFD66606-2447, beta 1, folded in here (operator, 2026-11-26).
  """

  details_title "The campus ships one beta"

  prose ~S"""
  :: details The platform
  The platform is one guest host, one message shape and one build path.
  A use case is in the beta when it is a guest of that platform with a
  gate and a control, and it adds no host, message shape or build path
  of its own. The use cases maximize what the platform serves and the
  work minimizes what each costs (operator, 2026-11-25). The use cases
  named are seeing each other (RFD66606-2436), voice between the
  players, the console that loads, unloads and chains local models, and
  the persona that answers from a planning domain (RFD66606-2339), with
  the planner and the solver as its guests (operator, 2026-11-25). The
  beta ships each use case whose own gate has passed with its control by
  the cut; a use case whose gate has not passed does not hold the cut. A
  use case is a guest of the platform with a gate and a control, and
  adds none of its own. An RFD outside this list keeps its state
  (RFD66606-1000).

  The beta ships a native build for each target: win64 on Windows, and
  native builds for the Steam Frame and the Steam Deck (operator,
  2026-11-12). The board-wide non-goals of RFD66606-2490 bind the beta
  too.
  :: details Servers and protocols
  Anything that is a protocol or a server has an AsyncAPI 3.1 document,
  written before or with it (operator, 2026-11-25). A server is a
  gen_server. Its document may carry its states as data in
  `x-state-machine`: an initial state, the states, and transitions that
  name messages of the document. The server refuses a message with no
  transition from its state, and a document without the block describes
  a plain gen_server (operator, 2026-11-25).

  The zone server, the stores and the secrets engine are each a NixOS
  flake that builds a container image, run by Podman under Eclipse
  Ankaios as a workload whose manifest pins the image by digest
  (RFD66606-2501). The win64 client ships as folders pushed with ORAS
  and pulled by digest. No server piece ships as win64 or runs under
  NSSM (operator, 2026-11-26).
  :: details Walk mode
  The character walks by walk mode: the motion guest drives it from
  clips in an AnimationLibrary (RFD66606-2487), first proved on the
  plaza walk of RFD66606-2408. No hand-written character controller is
  added (RFD66606-2363) (operator, 2026-11-11). It is proved on the
  plaza walk of RFD66606-2408.
  :: details Non-goals
  Everything outside the beta is cut from this list, and an RFD outside
  it keeps its state (RFD66606-1000). A new idea that matches a nongoal
  is refused, and the list is not argued again before the beta ships.
  The non-goals named so far:

  - the pen's draw and wear
  - an adventure party and a shopkeeper persona
  - seamless zone transfer
  - a lesson surface

  The four above were abandoned (operator, 2026-11-11).

  - a hidden director that plans the day
  - friendships and romance
  - a shared limit gauge with a team finisher
  - shop prices and a loan
  - an end-of-day report
  - a job board where each seat accepts or refuses a job
  - campuses built by players
  - the Hyper-V machine with its emulated TPM
  - a Linux-only server build
  - text chat
  - trading between players
  - combat, damage and dying
  - a leaderboard or achievements
  - real-money purchases
  - a market, a shop listing or a save slot for drawn outfits
  - moderation, reporting and blocking tools
  - a tutorial or first-run walkthrough
  - a language other than English
  - a recorder or a replay inside the campus
  - a teacher seat or a learner seat; the people of a lesson are the
    player and the party's seats
  - a lesson record or a course cartridge: progress, completion, grades
    or an interchange format
  - host controls: mute-others, a raised hand or a per-person audio
    channel
  - more than four people in one zone
  :: details What is not known
  - Whether each server piece has its NixOS flake container yet, and
    which RFDs still describe another way to ship a server. Each is read
    from its source before it is amended.
  :: details After the cut
  Dev is development: features land and change. The beta is a
  feature-complete freeze after dev, cut when the gate in RFD66606-2436
  passes with its control. After the cut, only fixes land.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2360", :spends, "see-each-other"
    relate "rfd-2360", :is_a, "release-rung"
    relate "rfd-2360", :owns, "rfd-2436"
  end
end
