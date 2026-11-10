# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2487,
    "Cage-wrapped surface net for body segmentation and garment spring-bone parameters",
    :ideation do
  feature "cage-wrapped net predicts body part labels and garment spring-bone parameters on messy meshes"
  scope "cage guest, diffusion-net, and the garment and articulation datasets"

  prose ~S"""
  :: hook
  Can a net predict body labels and spring-bone parameters on a messy avatar mesh without cleanup?
  :: intrigue
  The product avatar is a production or game character.
  Hair, clothes and eyes are separate floating components with cavities and non-manifold edges.
  Clean-data part segmentation and a plain surface net break there.
  A cage plus generalized barycentric coordinates hides the topology.
  The paper is non-commercial and its code is not released.
  So we implement the method instead of adopting its weights.
  :: exit
  Read DETAILS for the pipeline and the first gate.
  :: decision
  Ship the cage-wrapped surface net for robust 3D work.
  The cage.elf guest already builds the cage and binds it with biharmonic coordinates.
  Add a diffusion-net feature net on the cage.
  Transfer its output back to the messy mesh through the same binding.
  It gives body part labels, skinning weights, and garment spring-bone parameters for VRM.
  :: references
  - CageNet, SIGGRAPH 2025. doi 10.1145/3721238.3730654
  - DiffusionNet, ToG 2022. doi 10.1145/3507905
  :: related
  - RFD66606-1029, mesh segmentation and the part model it replaces.
  - RFD66606-1030, the See-Through split the net feeds.
  """

  details_title "Cage-wrapped surface net for body segmentation and garment spring-bone parameters"

  prose ~S"""
  :: details The problem
  The product avatar is a multi-component character mesh.
  Hair, clothes and eyes are separate shells, with cavities and non-manifold edges.
  A part segmenter trained on clean native 3D fails on messy meshes.
  A plain surface manifold net fails on the same cavity and edge traps.
  We need the body segmentation and the garment articulation in one robust pass.
  :: details Pipeline
  - The cage.elf guest builds a watertight cage that contains every vertex.
  - Bi-harmonic coordinates map each mesh vertex into the cage.
  - A diffusion-net feature net runs on the cage, taking those coordinates as its vertex features.
  - The per-cage-vertex output maps back to the mesh through the same coordinates.
  :: details Two applications
  - Segment the body and garment: per-vertex part and panel labels feeding the See-Through split.
  - Spring-bone parameters: a VRM rig from a garment mesh.
  The rig has joints, bones, bone connections, skin weights and rest lengths.
  :: details Data
  - GarmentCodeData v2 (CC BY 4.0): one row per file; a garment is the rows sharing batch, body and element.
  It carries the garment mesh and its per-vertex panel segmentation.
  It carries the waist and collar vertex labels, the sewing specification, and body measurements.
  - Articulation-XL 2.0 (CC BY 4.0): models, skeletons, meshes, skins and point clouds.
  - Each model gives joint positions, bones, bone connections, skin entries and the root joint.
  :: details What we already have
  The cage.elf guest ships the cage build and the bind.
  Its self test and property test assert every target vertex lies inside the cage.
  :: details What is new
  The diffusion-net stage and the back-transfer.
  DiffusionNet is a surface-manifold feature net, MIT.
  It runs on the cage and its output is mapped back through the cage coordinates.
  :: details The licence line
  The paper is non-commercial.
  We implement the method on our own code.
  We ship only the permissive parts, the cage guest and the diffusion-net port, both MIT.
  :: details First gate
  The cage-guest test passes on a production avatar mesh.
  A cage-to-net smoke produces stable labels and articulation values.
  The See-Through split and the spring-bone rig must use them.
  """
end
