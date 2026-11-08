# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2478,
    "ANNY-soma-x: RF-DETR keypoints, HairDeck, muscle-supermimic and the pose and shape sweep",
    :prediscussion do
  feature "ANNY-soma-x gains a keypoint head, a hair occluder and muscle-driven motion."

  scope "the ANNY-soma-x mesh and dataset pipeline on the Windows desk's RTX 4090."

  prose ~S"""
  :: hook
  Can ANNY-soma-x (the reference rig's SOMA-X variant) read a keypoint head, a hair occluder
  and a muscle-driven motion source without crossing a licence line?
  :: intrigue
  Nothing is started yet. RF-DETR Keypoint (Preview, 576 px, Apache-2.0) runs on the Windows
  desk, a pixi env with Python 3.12 and CUDA PyTorch; depth from it is ground truth only, never
  training data. HairDeck covers hair as both an occluder and an avatar part on CUDA.
  muscle-supermimic's MyoFullBody (24 GB) and the entities-model-explorer motion clips are the
  motion sources, retargeted to the 78 ANNY joints with rotation-star. The licences read on
  2026-11-02: SOMA-X and ANNY code are Apache-2.0, ANNY data is CC0, so ANNY-soma-x meshes and
  datasets can be published with attribution; AMASS clips stay non-commercial and unpublished;
  HairDeck hair assets are unchecked.
  :: exit
  A keypoint head, a hair occluder pass and one retargeted muscle-driven clip each run end to
  end on the desk, and the publish manifest lists every asset's licence class.
  :: decision
  - Run RF-DETR Keypoint on the Windows desk's RTX 4090 pixi env (Python 3.12, CUDA PyTorch).
    Its depth output is ground truth for evaluation only and is never folded into training data.
  - Add HairDeck on CUDA for two roles: hair as an occluder in the keypoint pass, and hair as an
    avatar part on the published mesh.
  - Retarget muscle-supermimic's MyoFullBody (24 GB) and the entities-model-explorer motion
    clips to the 78 ANNY joints with rotation-star as the motion source for muscle-driven poses.
  - Clear each asset against its licence before publish: SOMA-X and ANNY code (Apache-2.0) and
    ANNY data (CC0) clear ANNY-soma-x meshes and datasets for publication with attribution.
    AMASS clips stay non-commercial and are never published. HairDeck hair assets stay unchecked
    until their licence is read, and are held out of any publish manifest until then.
  """

  details_title "ANNY-soma-x: RF-DETR keypoints, HairDeck, muscle-supermimic and the pose and " <>
                  "shape sweep"

  prose ~S"""
  :: details The pose and shape sweep
  The sweep covers the pose and shape space ANNY-soma-x must cover: a grid of body shapes
  crossed with a set of muscle-driven poses from the retargeted motion clips, each rendered
  through the RF-DETR keypoint head with HairDeck's occluder active.

  :: details Open questions
  - Whether rotation-star retargeting onto the 78 ANNY joints preserves muscle-supermimic's
    joint limits, or needs a clamp pass.
  - Whether HairDeck's licence, once read, permits the same publish path as SOMA-X and ANNY
    data, or restricts hair-bearing renders to an unpublished set.
  - Whether RF-DETR's 576 px input resolution undersamples the hand and face keypoints ANNY
    needs, or a crop-and-rerun pass is required.
  """
end
