# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2408, "dev.1: one person visits the station", :discussion do
  flight_level :l1
  scope "the dev.1 prerelease, where one person walks the ported station."

  prose ~S"""
  :: hook
  dev.1 lets one person walk from the plaza toward the station, snap turn and teleport.
  :: intrigue
  The persona did not reach the platform or climb the stairs, and past the four modules the
  terrain is open.
  :: exit
  Run `gate_locomotion` in the pen's `double.yml` and check that each control fails.
  :: decision
  - The pen's `v20261001-dev.1` tag marks dev.1, and the prerelease carries the double engine
    `v20260930-double.1`, the addon `v20260930-addon.1` and the five guest ELFs, each against
    `SHA256SUMS`.
  - The four ported modules (`environment`, `station`, `plaza`, `sakura`), each a faithful port of
    the pinned original, send their 1089 primitive colliders and the terrain height field to the
    MuJoCo guest as the original's `physics.js` calls make them.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2296, whose dev.2 works from the gap the logbook names.
  """

  details_title "dev.1: one person visits the station"

  prose ~S"""
  :: details The station port is abandoned
  RFD66606-2384, the module-by-module port, is abandoned (operator, 2026-11-11). The plaza's
  assets and tech stay in use, and baking goes through slughorn.

  :: details The walker and world grab
  A walker ported from the original's `player.js` (radius 0.3 m, height 1.7 m, step 0.45 m) runs
  on
  the guest's ray and contact queries, read through rx's stick movement and rotation components,
  with a 30 degree snap turn and teleport; there is no jump. World grab is off by default and sits
  in a three-wedge radial (hold B or Y, tilt, release: world grab, recentre, exit).

  :: details Gates
  Gates: `gate_colliders` in &{repo("entities-sakuragaoka-station")} (every collider matches the
  original's, with `drop_one` and `shift` as controls), run by hand because that repository has no
  CI. And `gate_locomotion` in the pen's `double.yml` (walk, step-up and the refused 1.25 m ledge,
  the handrail stopping the walker, snap turn, teleport landing and refused, and bit-identical
  poses across two runs), with the controls `step_high`, `no_resolve`, `solid_land` and `ulp`,
  each
  of which must fail.

  :: details Playable, and the gap
  Playable, as the persona run on 2026-10-02 showed: walk from the plaza toward the station, snap
  turn, teleport, reach the forecourt, and toggle world grab from the radial. The persona did not
  reach the platform or climb the stairs. The locomotion gate climbs the six treads headless. Past
  the four modules the terrain is open where the town's houses and shops stand in the original.
  The
  logbook names that gap and counts five others, which RFD66606-2296's dev.2 works from.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2408", :provides, "dev1-station-visit"
    relate "rfd-2408", :is_a, "dev-rung"
    relate "rfd-2408", :spends, "sakuragaoka-plaza-setting"
    relate "rfd-2408", :spends, "macos-oxrsys-dev-play"
    relate "rfd-2408", :spends, "guest-elf-double"
    relate "rfd-2408", :spends, "actions-builds-double-binaries"
    relate "rfd-2408", :spends, "xr-world-grab-locomotion"
  end
end
