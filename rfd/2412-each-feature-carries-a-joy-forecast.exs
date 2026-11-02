# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2412, "each feature carries a joy forecast", :discussion do
  flight_level :l1
  scope "the joy forecast on each feature and the sense-of-wonder rubric."

  prose ~S"""
  :: hook
  Each feature carries a joy forecast, so the plan shows where players are expected to find joy.
  :: intrigue
  Infrastructure a player never notices rates low however necessary it is. The forecasts say
  where joy is expected, not what is worth building.
  :: exit
  Give a new feature a forecast in RFD66606-2295's tag form, rated on the five criteria, and
  compare it with the dev.1 table.
  :: decision
  Each feature carries a forecast, in RFD66606-2295's tag form, of the chance
  that a player finds joy in it, judged on a sense-of-wonder rubric of
  five criteria: a new sense (an experience new technology makes
  possible), a new standard (it changes how a player sees games),
  emergence (AI or other people make it come alive), motivation (seeing
  it makes someone want to play) and surprise.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2295, the tag form of the forecasts.
  - RFD66606-2296 carries dev.2's forecasts and RFD66606-2298 dev.next's.
  """

  details_title "each feature carries a joy forecast"

  prose ~S"""
  :: details The dev.1 forecasts
  | rung | feature | criteria | joy |
  | --- | --- | --- | --- |
  | dev.1 | walking a faithful station in VR | motivation, surprise | (likely, p=0.70) |
  | dev.1 | world grab: turning the town like a model | sense, surprise | (likely, p=0.65) |
  | dev.1 | the persona visitor touring on its own | emergence | (even, p=0.45) |
  | dev.1 | stick walking, snap turn, teleport | none | (unlikely, p=0.20) |
  | dev.1 | MuJoCo collision, bit-deterministic | none | (unlikely, p=0.15) |
  | dev.1 | playing on macOS via oxrsys, PyroWave | none | (unlikely, p=0.10) |
  """

  rebac do
    verbs_from 2351
    relate "rfd-2412", :provides, "feature-joy-forecast-tags"
    relate "rfd-2412", :is_a, "workspace-policy"
  end
end
