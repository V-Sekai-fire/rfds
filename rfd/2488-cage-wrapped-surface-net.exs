# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2488,
    "Cage-wrapped segmentation net and independent garment bodies for VRM spring-bone rigs",
    :ideation do
  feature "net segments garment and body; everything else becomes a VRM spring-bone chain"
  scope "cage guest, diffusion-net, spring-bone addon, Cassie VBD, and the two datasets"

  prose ~S"""
  :: hook
  Can a garment become independent bodies that swing on their own?
  :: intrigue
  The product avatar wears clothes.
  Hair, skirts, belts and scarves are separate parts with cavities and non-manifold edges.
  A plain surface net cannot see across disconnected components.
  Garments must move independently.
  Skin weights attach; they do not swing the cloth.
  :: exit
  Read DETAILS for the part-to-body mapping and the first gate.
  :: decision
  The cage-wrapped net segments the body and garment into per-vertex part and panel labels.
  Every part that is not the body base becomes a VRM spring-bone chain.
  SkinTokens gives the body base skeleton and weights; the chains swing on their own.
  Rest lengths come from the mesh; spring stiffness and damping are tuned.
  :: references
  - CageNet, SIGGRAPH 2025. doi 10.1145/3721238.3730654
  - DiffusionNet, ToG 2022. doi 10.1145/3507905
  - SkinTokens, arXiv:2602.04805.
  :: related
  - RFD66606-1029, mesh segmentation and the part model it replaces.
  - RFD66606-1030, the See-Through split the net feeds.
  """

  details_title "Cage-wrapped segmentation net and independent garment bodies for VRM spring-bone rigs"

  prose ~S"""
  :: details The problem
  The product avatar wears clothes. Hair, skirts, belts and scarves are separate parts.
  They must move independently: a belt swings, a skirt drapes, a tail and hair dangle.
  :: details The two layers
  - The segmentation net: CageNet builds a manifold cage; DiffusionNet runs on the cage; the mapping operator P projects per-vertex part and panel labels back to the messy mesh.
  - The independent bodies: VRM spring-bone chains for every part that is not the body base.
  - Stiff parts (belt, collar, hat) use short chains or a rigid pivot at the attachment bone.
  - Soft fabric (skirt, dress, sleeves) is a cloth approximated by spring-bone chains that Cassie VBD drives.
  :: details Why the cage
  DiffusionNet alone does not communicate between distinct components.
  The single manifold cage lets one net see across hair, clothes and eyes.
  So it is the part-label engine for the garment and the body.
  :: details Part-to-body mapping
  - Body base: SkinTokens skeleton and weights; the static rig everything hangs from.
  - Everything else: a VRM spring-bone chain.
  - Belt, collar, skirt, dress, sleeves, shawl, hair, tail, scarf.
  - Each chain carries bones with rest lengths from the mesh, tuned stiffness, damping and collision shapes.
  :: details Data
  - GarmentCodeData v2 (CC BY 4.0): the garment mesh, per-vertex panel segmentation, waist and collar vertex labels, the sewing specification, and body measurements. The segmentation is the carving; the scrappy path uses it directly without the net.
  - Articulation-XL 2.0 (CC BY 4.0): models, skeletons, meshes, skins and point clouds. Feeds SkinTokens evaluation, which was trained on it.
  :: details What we already have
  The cage.elf guest ships the cage build and the bind.
  Its self test and property test assert every target vertex lies inside the cage.
  The VRM addon runs SpringBoneSimulator3D with per-bone stiffness, damping, limits and collision shapes.
  Cassie cloth emits VBD soft-body code with adjacency, gather and project springs.
  :: details What is new
  The DiffusionNet stage on the cage, and the mapping operator P, which segment the garment and body into parts.
  The rig: a SkinTokens base skeleton, and spring-bone chains for everything else.
  :: details The licence line
  The CageNet paper is non-commercial; we implement the cage and DiffusionNet (MIT) on our own code.
  SkinTokens is permissive and in-house; we adopt it for the base skeleton and weights.
  :: details First gate
  A production garment is carved into labeled parts and rigged as VRM spring-bone chains.
  Its belt, skirt and hair move independently while the body moves, in the model-explorer viewer.
  """
end
