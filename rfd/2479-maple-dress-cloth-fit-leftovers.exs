# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2479, "Maple dress: cloth-fit leftovers", :prediscussion do
  feature "the Maple dress fit's leftover hem, blendshape and weight issues get closed out."

  scope "the Maple dress garment, its Unity scene and the body it fits in that scene."

  prose ~S"""
  :: hook
  Does the Maple dress read clean in Unity once its cloth-fit (PolyFEM + IPC) pass is done,
  or do spikes, a stray blendshape and stale weights still show?
  :: intrigue
  The Maple fit left four items open: hem spikes on the dress, the ClothFit blendshape that
  the fit shipped back into the Unity scene instead of consuming, other outfit pieces that
  were not carried through the same fit, and scene body weights that still reflect the
  pre-fit body. The unity-garment-cloth-fit skill covers the fit and bind steps these items
  touch.
  :: exit
  The dress renders in Unity with no hem spikes, no ClothFit blendshape left on the mesh, every
  other outfit piece carried through the same fit, and body weights matching the fitted body.
  :: decision
  - Smooth or re-solve the hem spikes left on the Maple dress's cloth-fit result until the hem
    reads flat in the Unity scene.
  - Remove the ClothFit blendshape the fit shipped back into the Unity scene; it is a solver
    artifact, not a scene asset, and must not ship on the mesh.
  - Carry every other outfit piece on the Maple body through the same cloth-fit pass the dress
    used, so no piece is fit to a stale body.
  - Rebind the scene's body weights to the fitted body so skinning matches the cloth-fit result,
    following the unity-garment-cloth-fit skill's bind step.
  """
end
