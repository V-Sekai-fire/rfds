# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2216, "Three.js blocklist", :discussion do
  feature "three.js goes on the CLAUDE.md / BLOCKLIST.md\nblocklist as an in-browser 3D runtime"
  scope "`CLAUDE.md`, `BLOCKLIST.md`, cascade of retirements\nin consumer files"

  prose ~S"""
  :: hook
  Three.js is blocklisted as an in-browser 3D runtime; Godot ships every 3D surface.
  :: intrigue
  A three.js path forks the scene-graph, material pipeline, animation graph, and lighting
  model that the workspace otherwise ships through Godot.
  :: exit
  Read RFD66606-2215 next for the one-runtime argument behind this blocklist.
  :: decision
  Blocklist three.js as an in-browser 3D runtime. Substitute is
  **Godot as a native binary per platform** built from
  &{repo("entities-godot-sandbox", planned: "4-entities")} with the Vulkan renderer (MoltenVK on
  macOS).
  :: related
  - [RFD66606-2210](../2210-atelier-godot-web-shipping-surface/), L3
    strategic bet.
  - [RFD66606-2211](../2211-base-tree-entities-godot-sandbox/), base
    tree pick.
  - [RFD66606-2215](../2215-one-binary-two-heads/), the "one runtime,
    not two" argument that also drives this blocklist.
  - RFD66606-1170 (cleanroom presence loop), earlier RFD picking Godot
    over three.js for a different workload.
  """

  details_title "Three.js blocklist"

  prose ~S"""
  :: details The objection
  Three.js itself is MIT-licensed, the objection is not
  licence, it is
  runtime story: the workspace ships every 3D surface via Godot,
  and a three.js path forks the scene-graph, material pipeline,
  animation graph, and lighting model.
  :: details Live rows
  `CLAUDE.md` blocklist table + `BLOCKLIST.md` full
  section (the section body carries the argument in current form).
  """
end
