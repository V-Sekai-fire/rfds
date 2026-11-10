# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2489, "Extracting body measurements from the base model", :ideation do
  feature "body measurements are re-readable from the base model mesh along labeled loops"
  scope "base model mesh, waist and collar vertex labels, geodesic measurement"

  prose ~S"""
  :: hook
  What numbers should the base model's body carry so clothing fits and the net can be checked?
  :: intrigue
  The base model is the body base (the reference rig everything else hangs from).
  GarmentCodeData v2 (the CC BY 4.0 garment dataset) stores body measurements
  beside the waist and collar vertex labels.
  Those labels plus the mesh are all a garment needs to sit on the body.
  So the measurements must be re-readable from the base model alone.
  :: exit
  Read DETAILS for the loop definitions and the first gate.
  :: decision
  The base model's body measurements come from the mesh itself.
  Circumference is the perimeter of a labeled cross-section loop.
  Length is a geodesic distance between two landmarks.
  GarmentCodeData v2 supplies the waist and collar vertex labels that anchor them.
  RFD66606-2488 (cage-wrapped surface net) reproduces those same labels.
  So measuring the base model is also a check that the net read the parts correctly.
  :: related
  - RFD66606-2488, the cage-wrapped surface net whose part labels this RFD reads.
  - RFD66606-2424, the anthropometric keypoint fit whose landmark vocabulary this inherits.
  """

  details_title "Extracting body measurements from the base model"

  prose ~S"""
  :: details The problem
  The base model is the reference body mesh, the static rig everything hangs from.
  It must be measured so garments fit it and the net can be checked.
  Hand-measured numbers are the only source today and they do not round-trip to the mesh.
  :: details How measurement is made
  - Circumference is the perimeter of a labeled cross-section loop.
  - Waist and collar are the loops GarmentCodeData v2 already labels.
  - Length is a geodesic distance between two landmarks.
  :: details First gate
  Re-derive the stored body measurements from the base model mesh alone.
  The recovered numbers agree with GarmentCodeData v2 within tolerance in the model-explorer viewer.
  """
end
