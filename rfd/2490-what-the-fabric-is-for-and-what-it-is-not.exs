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
  We work on the important problem, the one with a reasonable attack, and
  we stop work that serves no important problem (Hamming, "You and Your
  Research", 1986). We maximize our use cases and minimize our work and
  tools (operator, 2026-11-25). Today the important problem is the first
  beta (RFD66606-2360): two people in one campus zone see each other's
  avatars, one on the Steam Frame or the Steam Deck and one on the
  desktop, which is win64 (operator, 2026-11-26). The fabric is an open,
  remixable, self-hosted collaborative space built on Godot. The beta is one
  platform, one guest host with one message shape and one build path,
  shipped as a NixOS flake and as win64.
  The board-wide non-goals below bind every RFD on this board
  (operator, 2026-11-11). The details say how the board picks its work.
  :: related
  - RFD66606-2360, the campus beta, which points here for its
    non-goals.
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
    (beta 1). Hearing each other rides on the platform as a use case
    (RFD66606-2360, operator, 2026-11-25).
  - Kept: a neutral host for events, and for business meetings where
    privacy matters.
  - Superseded: Windows SteamVR and Oculus Quest as targets. The
    targets are win64 on Windows, the Steam Frame and the Steam Deck. The
    Frame and the Deck build natively (operator, 2026-11-12). The Mac is
    not a target (operator, 2026-11-26).
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

  The beta's own non-goals are listed once, in RFD66606-2360.

  :: details How the board picks its work
  The board picks work the way Hamming's "You and Your Research" (1986,
  https://www.cs.virginia.edu/~robins/YouAndYourResearch.html) says a researcher does
  (operator, 2026-11-25).
  - A problem is important when it has a reasonable attack. A problem with no attack is a
    non-goal, however large its consequence.
  - The beta's important problem is the one the gate of RFD66606-2436 holds. Each session says
    which important problem its work serves and what its attack is.
  - A session whose work serves no important problem stops or changes its goal, whatever work
    it has already started.
  - Doors stay open. A session says what it works on and what it needs, and reads what the others
    say.
  - A slice of the effort goes to the bigger question: is the gate still the important problem?
  - Unknowns stay on the page. Each RFD's "What is not known" and each planted-defect control is
    the list of evidence against the work.
  - Work is done so that others can build on it. A document comes before the code.
  """
end
