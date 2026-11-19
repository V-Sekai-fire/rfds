# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2499, "A portrait becomes a hair-card VRM inside the engine", :discussion do
  feature "one portrait becomes a VRM 1.0 avatar with hair cards and spring bones, in-engine."

  scope "the hair-card guests, the viewer that runs them, and the masks they read."

  prose ~S"""
  :: hook
  Can one portrait become a VRM with hair cards and spring bones inside the engine, with no
  Blender, no PyTorch and only openly licensed models?
  :: intrigue
  HairDeck (single image to hair cards, Apache-2.0) ships as Python on Blender. Its five models
  now run as ggml-rd (ggml on the engine's GPU) guests and match PyTorch within 5e-5. 26
  portraits gave 26 VRMs in one viewer process, about 7 s each after a 20 s load. The masks
  still come from SAM 3 and BiRefNet in PyTorch. SAM 3 is under Meta's SAM licence.
  :: exit
  Run the viewer's batch mode on a folder of portraits, then open one VRM in a second reader.
  The check passes when every image gives a VRM and the window never stops for 4 s.
  :: decision
  A portrait becomes a VRM 1.0 file in one engine process, with every model as a guest ELF or
  an engine module and no Python at run time.
  - Text prompts become boxes through Bonsai 2 with its image projector, inside the engine
    (operator, 2026-11-19). SAM 2.1 base-plus turns each box into a mask, and BiRefNet-matting
    gives the person alpha, each as a guest ELF. SAM 3 leaves the pipeline.
  - The VRM carries the hair cards, one spring chain per strand group, and a SOMA-X body with
    the ANNY identity (the reference rig) and its pose correctives, in a CC0 sport suit.
  - The VRM's licence fields are CC0, and the repositories keep HairDeck's notices.
  - All slow work runs on one worker thread. A stop over 4 s fails the run, and at 5 s the
    viewer ends itself.
  :: related
  - RFD66606-2478 (ANNY-soma-x keypoints), which held HairDeck's licence as unread.
  - RFD66606-2311 (serving Bonsai 2), the same model served outside the engine.
  """

  details_title "Measurements behind the portrait-to-VRM pipeline"

  prose ~S"""
  :: details What was measured
  Each guest was compared with HairDeck's PyTorch code in fp32 on the same inputs, as relative
  L2 error: the card VAE 1.3e-6, the image, chain and colour DiTs about 1e-6, DINOv3 1.4e-5,
  and the 50-step sampler 4.5e-5. The guests also run binary-translated, with results
  identical to the interpreted run.

  Mask quality was measured against the SAM 3 masks on the same 26 images, given the box of
  the SAM 3 mask. SAM 2.1 base-plus reached a mean IoU of 0.83 on hair and 0.92 on face, and
  six hair masks fell below 0.7. SAM 2.1 large reached 0.85 and 0.91 at 2.6 times the encode
  time, so base-plus is the choice. Box detectors were measured on the same images by box IoU:
  OWLv2 base 0.87 on hair and 0.76 on face, Grounding DINO base 0.89 and 0.87.

  :: details What was not measured
  - Bonsai 2's boxes. The engine's language module built its image projector code out, so the
    model never saw an image. The build fix is in review, and the 26-image box test waits on it.
  - SAM 2.1 and BiRefNet as guests. Both ran only natively or in PyTorch so far.
  - The effect of the new masks on the cards, and whether a reader other than the VRM add-on
    used to write the file opens it.
  - The pose correctives when a bone turns. They are baked for the rest pose only.
  """
end
