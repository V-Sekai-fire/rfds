# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2384, "the station is ported to Godot module by module against a reference", :discussion do
  flight_level :l1
  scope "the Godot port of Sakuragaoka Station, module by module, checked against reference.json."

  prose ~S"""
  :: hook
  The station is ported to Godot one module at a time, each checked against a reference.
  :: intrigue
  If the match depends on the budget and not the seed, does the port prove anything about the
  town?
  :: exit
  Run `npm ci && node tools/check.mjs <modules>` in the fork to print the triangle count per
  module, then write `reference.json` with `tools/reference.mjs`.
  :: decision
  - The station is three.js and the rung is Godot, so the generation is ported, as RFD66606-2267
    says a port is.
  - The port goes in the order the person sees it, and the fork's `reference.json` at seed 1 and
    `t = 0` is the oracle.
  - Each ported module is checked against that oracle by `tools/gate_station.gd`, headless.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2267, what a port is.
  """

  details_title "the station is ported to Godot module by module against a reference"

  prose ~S"""
  :: details The world: Sakuragaoka Station, in Godot
  A new repository,
  &{repo("entities-sakuragaoka-station")}, is a Godot addon,
  `addons/sakuragaoka_station/`, in the station's own shape: one
  `world/<module>.gd` per `src/world/<module>.js` with a `build(ctx)`,
  `world/layout.gd` as the world contract (coordinates, roads, lots,
  spots, `heightAt`), `core/rng.gd` as mulberry32 so a seed gives the
  same town in both, `core/toon.gdshader` for the 4-band ramp on vertex
  colour, and `core/batch.gd` merging static meshes by cell as
  `batch2.js` does. Materials are vertex colours as in the original.
  Textured signs are blank. The pen instances `station.tscn` under
  `World/Station`, origin on the plaza at `(-1, 0, -11.4)`, metres and
  Y up as the original, no conversion.

  :: details The order of the port and the oracle
  The port goes in the order the person sees it: `layout`,
  `environment` (ground, sky, far hills), `plaza`, `station`, `sakura`,
  then `street`, `poles`, `railway`, `props`, then `houses`, `shopsA`,
  `shopsB`, `shrine`. Trains, vehicles, characters, petals and audio are
  animation and stay out of the rung. They are later modules of the same
  addon. The first measurement, before any code: `npm ci && node
  tools/check.mjs <modules>` in the fork prints the triangle count per
  module, and the fork gains `tools/reference.mjs`, which writes
  `reference.json`: per module, its triangle count, its bounding box,
  and the count of meshes by colour, all at seed 1 and `t = 0`. That
  file is the oracle.

  :: details Check and controls
  Check, `tools/gate_station.gd` in the addon, headless: for each ported
  module, the Godot build at seed 1 matches `reference.json` on triangle
  count within 2% and bounding box within 0.1 m, and the whole scene
  holds 72 fps in the headset gate (p95 at or under 13.9 ms). The plaza
  is seen on the devkit's stream, and `tools/frame/clip.sh` and
  `still.sh` keep what was seen under `logs/`. Controls:
  `--control=drop_lot` removes one lot from `layout.gd` and the plaza
  module's count must miss the oracle by name. X--control=seed_2` builds
  at seed 2 and must miss it, confirming the match depends on the
  seed and not the budget.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2384", :provides, "station-godot-module-port"
  end
end
