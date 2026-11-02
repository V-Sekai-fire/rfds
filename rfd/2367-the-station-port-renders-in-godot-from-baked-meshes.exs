# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2367, "the station port renders in Godot from baked meshes", :discussion do
  flight_level :l2
  scope "how the Sakuragaoka Station port builds, shades and renders its geometry in Godot."

  prose ~S"""
  :: hook
  The station port draws baked meshes in Godot, so it renders with the runtime vector shader off.
  :: intrigue
  CSG keeps UV and drops vertex colour, and it takes only manifold solids, so a geometry that
  fails the manifold check cannot be unioned as it is.
  :: exit
  Check a new station mesh against the rule: realize each closed solid through CSG, bake vector
  materials to meshes, and keep rasterized vector art out of the headset.
  :: decision
  The Sakuragaoka Station port (&{repo("entities-sakuragaoka-station")}):

  - realizes every closed solid through CSG, and carries each face's colour as a
    palette index in UV, since CSG keeps UV and drops vertex colour. CSG takes
    only manifold solids, so a geometry that fails the manifold check stays a
    plain surface, or goes through `remesh.elf` when it must be unioned;
  - shades with godot-vrm's MToon unchanged, and a variant includes it rather than
    forking it;
  - renders from meshes baked from the vector materials' data (signs, paving,
    bark), coarsened by LOD when over budget, so it works with the runtime vector
    shader off. Alpha-cut foliage cards bake too: each blossom card is its atlas
    cell's outline, baked by `slug.elf` at 256 triangles a cell, and the cards go
    into cluster LOD DAGs built by `remesh.elf`'s `cluster_lod` (meshoptimizer's
    `clusterlod.h`), which `clod_select` cuts per frame, binary-translated, on
    both standalone headsets (operator, 2026-10-10);
  - judges alpha on the final composite of its layers: an opaque object ends with
    no transparency, and a transparent base-colour material writes alpha.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "the station port renders in Godot from baked meshes"

  prose ~S"""
  :: details Quality and procedural detail
  The Sakuragaoka Station port:

  - runs `slughorn`'s per-pixel vector shader as a quality setting, on by default,
    adding detail to surfaces near the eye within the headset's GPU budget;
  - synthesizes finer detail only where the source is procedural.

  :: details What stays out of the headset
  No rasterized vector art or glyph outline goes into the headset. Meshes made
  from outlines are fine, and a glyph mesh goes through `remesh.elf` when its
  font's winding is invalid.

  :: details The blossom cards and the cut
  Over the 48 valid orbit views, the 53,211 cards are 13.6M triangles at full detail, and a 4 px
  cut
  for a 1760 px eye at 100 degrees draws a mean of 39k and at most 122k. With
  the cut, depth differs from the original on 0.16 % of the frame, and on
  2.15 % without the cards. Translated, the cut takes a median 1.6 ms a view
  on the desk, and 4.3 ms interpreted.

  :: details The outline
  The outline reads the mesh's geometric normal, which the toon-ramp hook writes,
  not MToon's bent indirect-light normal, and takes depth and normal from the
  majority MSAA sample.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2367", :provides, "station-csg-baked-mesh-render"
  end
end
