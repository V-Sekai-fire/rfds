# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2369, "the standalone headset draws at most 700k triangles", :discussion do
  flight_level :l2
  scope "the triangle budget for the standalone headset and how it is enforced."

  prose ~S"""
  :: hook
  The standalone headset draws at most 700k triangles in view per frame, split between world and
  characters.
  :: intrigue
  Past 700k triangles in view the frame is over the operator's budget, and the crowd of
  non-player characters is the first to drop to impostors.
  :: exit
  Check a scene against the budget: at most 700k triangles in view per frame, 250k for world
  geometry and 450k for characters.
  :: decision
  The operator's budget for the standalone headset: at most 700k triangles in
  view per frame, of which world geometry gets 250k (400k at most) and characters
  450k. A crowd of non-player characters holds 150k of the character share and
  drops to impostors first. One equal-error LOD threshold over the frame enforces
  it, and the LODs come from Godot's own `generate_lods` on welded meshes, except
  the blossom cards, whose levels are the cluster LOD DAGs of RFD66606-2367.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2367, the cluster LOD DAGs of the blossom cards.
  """

  details_title "the standalone headset draws at most 700k triangles"

  prose ~S"""
  :: details Shadows
  Avatars and characters cast their shadows from tapered capsules fitted per
  skeleton (issue 110), not from the shadow map. An untapered capsule keeps stock
  Godot's height and radius behaviour.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2369", :provides, "headset-700k-triangle-budget"
    relate "rfd-2369", :is_a, "workspace-policy"
    relate "rfd-2369", :spends, "station-csg-baked-mesh-render"
  end
end
