# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1033, "Geometric algorithms in the catalog", :published do
  feature "model inventory"
  attest_in :none

  prose ~S"""
  :: hook
  Geometric algorithms get their own list, apart from the neural models.
  :: intrigue
  The catalog mixes deep learning models and geometric algorithms. A reader who plans memory
  cannot tell the two apart.
  :: exit
  Check a new entry against the rule above: an algorithm that holds no weights goes in the
  algorithm table below, and a neural model goes in RFD66606-1016.
  :: decision
  List the geometric algorithms apart from the neural models. RFD66606-1016
  holds the neural models.

  See `DETAILS.md` for the algorithm table, how they scale with mesh
  size instead of parameter count, and a license note on
  `quadwild_retopology`.
  :: related
  RFD66606-1016 lists the neural models. RFD66606-1025 gives their bf16 memory.
  """

  details_title "Geometric algorithms in the catalog"

  prose ~S"""
  :: details The algorithms
  | Model id                  | Task            | License |
  | ------------------------- | --------------- | ------- |
  | quadwild_retopology       | Mesh retopology | GPL-3   |
  | instant_meshes_retopology | Mesh retopology | BSD-3   |
  | xatlas_uv_unwrapping      | UV unwrapping   | MIT     |
  | colmap_3dgs_reconstruct   | Photos to splat | BSD-3   |
  | pmp_decimate              | Mesh decimation | MIT*    |
  | geogram_decimate          | Mesh decimation | BSD-3   |

  `MIT*` is MIT with an employer disclaimer. Decimation is listed apart
  from retopology because the two answer different questions: retopology
  rebuilds the edge flow, decimation removes elements from the flow that
  is there, and an avatar losing triangles without losing its silhouette
  wants the second. PMP and Geogram are vendored in &{repo("entities-godot")} on
  `feat/cassie`; RFD66606-1029 records the licenses as read from those copies
  and why blend shape transfer, not triangle removal, is the hard half.

  Each one is packaged as its own model image, per RFD66606-1036.
  :: details How they scale
  These algorithms hold no weights. Their memory scales with the mesh,
  and not with a parameter count. A capacity plan must therefore use the
  vertex budget, and not a bf16 figure.

  src/library/aiModelsCatalog.js caps the mesh at 210,000 vertices. The
  constant is `API_MAX_MESH_VERTICES`, and it matches the API upload cap.
  :: details A license note
  quadwild_retopology uses the GPL-3 license, which RFD66606-1028 excludes.
  Instant Meshes is the permissive replacement, and RFD66606-1029 records the
  other options.
  :: details The problem
  The two kinds scale in different ways.
  """
end
