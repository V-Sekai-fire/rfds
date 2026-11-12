# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2490, "What the fabric is for, and what it is not", :discussion do
  flight_level :l2
  scope "the whole RFD board: its purpose and its non-goals."

  prose ~S"""
  :: hook
  Does a new RFD on this board serve the open, self-hosted campus,
  or does it drift toward a walled garden?
  :: intrigue
  The 2020 charter asked for an open, remixable, self-hosted VR space.
  Most of it still holds. The targets and the trust model have moved on.
  :: exit
  Check a new idea against the non-goals in the details. A match is
  refused, not argued again.
  :: decision
  The fabric is an open, remixable, self-hosted collaborative space
  built on Godot. People in one room can see each other. Hearing each
  other is a charter intent that the first beta does not ship
  (RFD66606-2447).
  The board-wide non-goals below bind every RFD on this board
  (operator, 2026-11-11).
  :: related
  - RFD66606-2360, the campus beta, which points here for its
    non-goals.
  - RFD66606-2447, beta 1: see each other.
  - RFD66606-2146, bao is the secret store.
  - RFD66606-2202, ReBAC role tuples enforced via Bao identity groups.
  - The 2020-06-08 V-Sekai charter, at
    https://v-sekai.github.io/manuals/decisions/20200608-vsekai-charter.html.
  """

  details_title "Charter digest and board-wide non-goals"

  prose ~S"""
  :: details Charter digest
  The 2020 Mozilla MVP application
  (https://v-sekai.github.io/manuals/decisions/20200608-vsekai-charter.html)
  set out these intents.
  - Kept: a remixable, self-hosted, collaborative VR environment on
    Godot Engine.
  - Kept: openness and communication as the basis of the platform.
  - Kept: an open alternative to walled-garden social VR.
  - Kept: users keep power over their data and can run the platform
    privately.
  - Kept: easy to compile and modify.
  - Kept: baseline presence, people in a room who can see each other
    (beta 1). Hearing each other is not in beta 1 and is not on this
    board's current plan.
  - Kept: a neutral host for events, and for business meetings where
    privacy matters.
  - Superseded: Windows SteamVR and Oculus Quest as targets. The
    targets are the Mac, the Steam Frame and the Steam Deck. The Frame and the Deck build
    natively (operator, 2026-11-12). The Mac's native build is unknown.
  - Superseded: decentralized authentication through a GPG web of
    trust. OpenBao is the identity and secret store (operator,
    2026-11-11; see RFD66606-2146 and RFD66606-2202).
  - Superseded: BitTorrent and IPFS distribution. Content ships from a
    standard CDN through HTTP range requests, chunked so that
    desync-compatible tools can fetch it (operator, 2026-11-11).
  - Dropped: the 2020 stack (k3s, CentOS 8, Digital Ocean Spaces), the
    eight-week Gantt chart, team bios and user-count estimates.
  - Not promised here: end-to-end encryption between users. OpenBao
    does not provide it, and nothing in this board commits to it.

  :: details Board-wide non-goals
  A non-goal on this board is abandoned, not deferred. A new RFD that
  matches one is refused, and the list is not argued again.
  - A paywall at the door: no licence, sponsor or membership check in
    the client or the server.
  - A client for a phone or a web page.
  - Fly as a host for any server piece (operator, 2026-11-12).
  - FEX, the x86 emulation layer, as a runtime for any build (operator, 2026-11-12).
  - Proton, the third-party compatibility layer (operator, 2026-11-12).

  :: details Beta-only non-goals in RFD66606-2360
  These stay beta-only non-goals in RFD66606-2360 (operator, 2026-11-11).
  They are not on the board-wide list.
  - Real-money purchases.
  - A leaderboard or achievements.
  - Campuses or worlds built by players. This pulls against the
    remixable intent in the charter.
  - Moderation, reporting and blocking tools.
  """
end
