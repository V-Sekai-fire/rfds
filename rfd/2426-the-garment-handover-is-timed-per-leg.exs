# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2426, "the garment handover is timed per leg", :discussion do
  flight_level :l1
  scope "the timed garment handover, its legs, its load and its checks."

  prose ~S"""
  :: hook
  The garment handover is timed leg by leg, so a slow leg shows up where it happens.
  :: intrigue
  The round trip from a player's desk to the store's region measured 22 to 28 ms. Which leg of the
  handover spends it?
  :: exit
  Run the timed handover: replay the recorded pen strokes for 5 minutes and read the 95th and 99th
  percentiles of each leg.
  :: decision
  The store and the backend stay together in one region, and the zones run on a server near the
  players (operator, 2026-10-23). The handover is the step that crosses the round trip, and the
  rung times it. The measure is per server and per leg, never a count of servers to minimise
  (operator, 2026-10-23).

  The time runs from the worker zone finishing the garment to its ghost drawn in the players'
  zone, split by leg: the store commit, the ownership handover, and the fetch by hash. The load is
  a replay of recorded pen strokes with the players' recorded head and hand tracks, pauses
  included, never scripted motion. It holds for 5 minutes and is judged on the 95th and 99th
  percentiles, never on a mean.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "the garment handover is timed per leg"

  prose ~S"""
  :: details Why several servers
  Running several servers is expected: a system that tolerates faulty or lying members needs more
  machines to match one machine's reliability, so the measure is per server and per leg.

  :: details Rules of the run
  - A zone confirms a handover only after the store commits it. Writes may group into one commit,
    and every waiter waits for that commit.
  - The zone's tick never waits on the store.
  - A player who pauses keeps their session. The replay's pauses must not cause a reconnect.
  - The report names what stopped the run: tick time, memory, the store commit, or sessions.
  - The first run on a new host repeats a reference build, so a change of machine is not read as a
    change of code.

  :: details Checks and controls
  Checks, each with a control that must fail:

  - The legs add up to the measured total. A control that adds a delay to the store commit must
    show up in that leg and nowhere else.
  - No player sees a garment confirmed before its commit. A control that confirms first must be
    caught.
  - The replay is not the bottleneck: the replay host's own load is reported beside the zone's,
    and a control that throttles the replay must be named as the limit.

  :: details Pass limits
  The pass limits are not set yet: the first sustained run measures them, and the operator sets
  them from it.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2426", :provides, "per-leg-handover-timing"
  end
end
