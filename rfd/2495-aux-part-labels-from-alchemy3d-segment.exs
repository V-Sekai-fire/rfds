# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2495, "aux part labels from alchemy3d-segment", :ideation do
  feature "one segmentation model labels every garment and body-helper part of a dressed avatar."

  scope "part labels for ANNY avatars: class sources, label maps and the model that reads them."

  prose ~S"""
  :: hook
  Can one segmentation model split a dressed avatar into body and auxiliary parts, with a named
  source of labels for each of the ten classes, including the ones no dataset covers?
  :: intrigue
  The cage-wrapped net of RFD66606-2488 (cage-wrapped surface net) needs a cage and a trained
  DiffusionNet. Alchemy3D-Segment reads 1 to 8 coloured 2D maps instead, and its weights exist.
  Its README lists the map-making pipeline as unreleased, and its training code is unreleased.
  GarmentCode has panel programs for skirts, sleeves, collars and waistbands, and none for a
  cape, scarf, belt or bag. ANNY has no twist bones and no correctives. SOMA-X has both.
  :: exit
  Read DETAILS for the class table, what was measured and the open test, which dresses a
  garment on a body before Segment reads it.
  :: decision
  - Alchemy3D-Segment (a LoRA that paints part colours onto a 3D asset from 2D maps) labels the
    parts, in place of the cage-wrapped net and of TailorRig labelling (operator, 2026-11-14).
  - Separating auxiliary parts from the body is enough. SkinTokens (the skeleton and skin
    weight model) keeps rigging the body (operator, 2026-11-14).
  - The class set is TailorRig's ten auxiliary classes: Twist, Accessory, Correction, Muscle,
    Skirt, Hair, Cape, Sleeve, Collar, Face. Every class gets a source, and none is skipped
    because it is hard to source (operator, 2026-11-14).
  - Skirt, Sleeve and Collar come from GarmentCodeData panel labels. Cape, scarf, belt and bag
    come from patterns and shells we author, draped or built here with exact labels.
  - Hair comes from HairDeck. Twist and Correction come from SOMA-X. Face comes from ANNY's own
    body-part segmentation. Muscle comes from the source RFD66606-2478 (ANNY-soma-x pipeline)
    names, which is still unread for this use.
  - The 2D maps come from RF-DETR segmentation of renders. Instance or semantic maps are decided
    by testing Segment on both, not by preference (operator, 2026-11-14).
  - Which classes are rigid and which are soft is our rule per class, not TailorRig's.
  :: related
  - RFD66606-2488, the cage-wrapped net whose segmentation step this replaces.
  - RFD66606-2478, ANNY-soma-x, whose HairDeck licence note this updates.
  """

  details_title "aux part labels from alchemy3d-segment"

  prose ~S"""
  :: details Class table
  The ten classes were read by eye from the dataset-histogram figure of the TailorRig paper.
  The spelling and the per-class counts need a recheck before they go in a shared document.
  - Skirt, Sleeve, Collar: GarmentCodeData batch 0 of the default body, 3,450 garments. About
    ten panel families hold 7,537 distinct labels. Skirt is the largest. Hood belongs to the
    collar family upstream, and TailorRig has no hood class, so it is an open row.
  - Cape: no source exists. GarmentCode has no cape program, Fashionpedia has 19 clean images.
    We author a circle panel hung from a neck band and drape it.
  - Scarf and belt: waistbands exist upstream. A scarf is a long strip at the neck and a belt
    is a band at the waist, both authored.
  - Bag: three bodies. A tote is two panels and two strap bands with a proxy volume inside. A
    shoulder bag or handbag is a parametric rigid shell with a strap curve. A backpack is a
    shell with two straps. Straps on ANNY's shoulders and a posed hand are untested.
  - Hair: HairDeck turns one portrait into hair cards and spring-bone chains. The cards are
    separate meshes, so labels are exact. Its code and checkpoints are Apache-2.0, which
    settles the licence question RFD66606-2478 left open for those two. It needs the SAM 3
    and DINOv3 weights, which are gated, and Blender with the VRM add-on. Its output is
    generated data, so the generated-data rules apply.
  - Twist and Correction: ANNY's rigs and its bundled 78-bone SOMA rig have no twist bone, and
    its 1,136 blendshapes are shape, not correctives. The SOMA-X model repository
    (Apache-2.0, not gated) defines twist joints on a 110-joint template rig and ships a
    corrective network from joint rotations to vertex offsets.
  - Face: ANNY ships a body-part segmentation with head, eyes, mouth cavity, tongue, hands
    and feet.
  - Muscle: not read for this use.
  :: details What was measured
  - The GarmentCode segmentation file has one label per vertex of the box mesh: 29,667 labels
    and 29,667 vertices for one garment. The draped mesh has 29,784 vertices. Matching by index
    gives 83.2 percent of faces whose non-seam vertices share one panel, against 12.3 percent
    for a shuffled control. Exact labels on a drape need a drape we run ourselves.
  - Seam vertices are 4.6 percent of batch 0.
  - RF-DETR segmentation fine-tuned on Fashionpedia, a local clothing set and pseudo-labelled
    poseswap garments matched the baseline on held-out photographs: mask AP 0.327 against 0.328
    on the test split. Pseudo-labels added edges, not knowledge.
  - Segment ran on its README example in 6 to 12 seconds and 10.5 GB of GPU memory. Its labels
    come from MeanShift clustering of the colours it paints, so they are anonymous same-part
    ids, not class ids.
  - Positive control: given maps rendered from the pony's own labels, Segment reproduces them
    at adjusted Rand index (ARI, 1 for the same grouping, 0 for chance) 0.985. The example's
    own maps give 0.981 and a shuffled truth gives 0.0.
  - A first set of GarmentCode runs scored ARI 0.015 to 0.22 and was wrong. Segment looks each
    label up by nearest neighbour between the source file's own coordinates and its output,
    which sits in a unit cube. The source was in centimetres, 170 units tall, so the lookup
    distance was 94 units instead of 0.0007. Those numbers are withdrawn. Every result below
    used a source normalised into the unit cube.
  - One GarmentCode garment, eight Hammersley views, maps rendered from its exact labels with
    one colour per class or panel, scored against the true labels. On the neutral body, with
    a red cloth and a skin texture, semantic maps give ARI 0.81 against the five true classes
    and 0.61 against panels. Instance maps give 0.60 against classes and 0.75 against panels.
    Shuffled controls sit at 0.00. The garment alone reaches 0.97 on classes with semantic maps.
  - Garment against body as a two-way split: connected components separate them exactly (ARI
    1.000, 19 components, none mixed) because they are separate shells. Segment scores 0.44
    with instance maps and 0.58 with semantic maps, and calls 92 percent of faces right.
  - Welding the garment to the body within 5 mm (about three stacked pennies) changes 2,297
    vertices and leaves one connected mesh, so components score 0.0. Segment scores the same
    as before the weld: 0.45 and 0.57. It does not need separate shells, and it does not beat
    components where they work.
  - RF-DETR masks as the maps, on shaded renders of the same garment: the baseline checkpoint
    gives ARI 0.61 against garment and body, 0.65 against classes and 0.46 against panels. The
    fine-tune is worse on every row. The baseline's masks overlap the true garment pixels at a
    mean IoU of 0.88.
  - Training data for the 2D maps is relabelled into AUX ids: Skirt 1, Sleeve 2, Collar 3, Cape
    4 and Accessory 5. The real Fashionpedia-class set keeps 10,248 of 28,400 train
    annotations (Sleeve 5,600, Accessory 3,005, Collar 1,026, Skirt 595, Cape 22). Cape has no
    validation instance and two test instances, so it cannot be scored. Hood joins Collar and
    a sleeve cuff follows its sleeve. Whole garments, shoes, tights and details such as
    pockets are left as background.
  - A synthetic set from 360 GarmentCode drapes on the neutral body (281 train, 39 valid, 40
    test, split by garment, the tested garment held out) carries exact masks for Skirt, Sleeve
    and Collar. The fine-tune on it reached validation mask AP 0.367 at epoch 5 of 15 and
    was still rising. It has not been scored on the test split or on real photographs.
  - HairDeck, which makes hair cards and spring-bone chains from one portrait, ran on the Mac
    (Apple MPS) on one poseswap portrait in 35 seconds. It needs SAM 3 and DINOv3, both
    gated. Mirrors of the same bytes matched the pinned SHA-256 of each. The output was not
    inspected beyond its mask.
  - Segment has no camera input. Each map is cropped to its bounding box and fed as image
    tokens, and run() defaults to seed 42, so repeat runs match.
  - Mitsuba 3 and a nvdiffrast rasteriser agree on silhouettes at IoU 0.99 for seven of eight
    views. The pole view differs because its up vector is degenerate.
  - Segment ran without Blender, which is blocklisted as a renderer. The source ingest uses
    trimesh and the O-Voxel textured-mesh voxelizer, and is untested against upstream's path.
  - Generating mannequin outfits with OmniGen2 takes 67 seconds an image at 50 steps and 34
    seconds at 25. At 25 steps, three of three prompts dropped a requested garment.
  :: details Not yet run
  - Every garment result is one garment, one body and one set of shaded renders, and RF-DETR
    was trained on photographs. The cage guest has not run on any of this: it rejected the
    skirt shell at every knot count tried. The pony control and the view-order ablations come
    from before the unit fix, and a rerun is pending.
  - Where the SOMA-X twist skin weights live, and whether its ANNY wrap carries them to ANNY's
    topology, is unchecked. Labelling corrective vertices by offset magnitude over a pose set
    is our proposal, with a threshold SOMA-X does not define.
  - Only batch 0 of GarmentCodeData was surveyed.
  - TailorRig is CC BY-NC-ND and its dataset is blocklisted. Only the paper was read, and
    only for the class names.
  :: details Open questions
  - Do the scores hold on more garments, other bodies and the five classes GarmentCode lacks?
  - Hood goes to Collar and sleeve cuffs follow their sleeve in the training data. Does the
    operator accept that, and should a trouser cuff stay with the body?
  - Can RF-DETR maps on photographs or dressed ANNY renders match the synthetic scores?
  """
end
