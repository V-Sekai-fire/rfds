# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2427, "frontier learning picks the garment handover timing runs", :discussion do
  flight_level :l1
  scope "how the garment handover timing runs are chosen as levels, with a planted defect each."

  prose ~S"""
  :: hook
  Each timing level runs clean and with its defect planted, so a pass means something.
  :: intrigue
  A level that finds its planted defect only some of the time has a result that is luck.
  :: exit
  Check a new timing level against the rule. Run it on the rung as it is, then on the rung
  with that level's defect planted.
  :: decision
  - The timing runs are levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
    schedules the store's attacks.
  - Each level runs on the rung as it is and on the rung with that level's defect planted.
  - A clean run on the real rung counts only after its level found the planted defect in each of
    its last eight runs.
  - A finding on the real rung is never averaged into a rate: it stops the lane and becomes a
    level that runs every time.
  - The percentiles the pass limits come from are read only from calibrated levels, so a limit is
    never set from a load that could not see a slow leg.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  - RFD66606-2309, the sense of a level. RFD66606-2323, how the store's attacks are scheduled.
  """

  details_title "frontier learning picks the garment handover timing runs"

  prose ~S"""
  :: details Levels and problems
  A level is a load template with fixed attributes: players, the recorded replay, the zone's
  distance from the store, the commit group size, and the injected round trip and loss.
  A problem is one 5 minute run with a drawn seed and replay offset.

  :: details The planted defects
  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | store commit leg | a delay added to each commit | that leg's 95th percentile moves |
  | confirm order | confirm sent before the commit | a garment seen before its commit |
  | tick isolation | the tick waits on the store | a tick over its budget |
  | paused players | a short idle timeout | a reconnect during a pause |
  | replay limit | the replay host throttled | the replay named as the limit |

  :: details Success, regret and mutation
  On the planted target, success is the defect found. Regret `1[s ≥ 1] − s/n` over the last eight
  runs is high when the level finds its defect only some of the time, so its result is luck.
  Mutation moves one attribute, kept only when the planted find rate rises.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2427", :provides, "handover-timing-planted-levels"
  end
end
