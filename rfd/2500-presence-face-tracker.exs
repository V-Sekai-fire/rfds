# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2500, "A face tracker that starts from speech and a headcam", :discussion do
  feature "a face tracker for one wearer, from a headcam and speech to Unified Expressions."

  scope "the take format, the keypoint head, the face policy, and the Hailo front end."

  prose ~S"""
  :: hook
  Can a muscle-driven policy track one person's face from a headcam and from speech, and also
  drive a persona that has no camera, with every model openly licensed and the face never stored?
  :: intrigue
  The pieces now exist in parts. A skin patch under small forces responds as a membrane should.
  A take file written by an Elixir DSL round-trips 200 random takes exactly, and OpenUSD 0.26.5
  opens it. The headcam gives an upright 768 by 1024 frame. The Hailo-10H is rated 40 TOPS at
  INT4 and 20 at INT8. A keypoint head trained on synthetic renders scores 0.86 against a bar of
  0.80 on held-out renders, in one run. No face muscle model or policy exists yet.
  :: exit
  Run the single build command in the take repository. It compiles, runs the tests, and has
  OpenUSD open a good take and refuse three broken ones.
  :: decision
  The goal is a VRCFT tracker for the operator's own face, headcam to Unified Expressions, by a
  MuscleMimic-style policy that also runs with any input masked (operator, 2026-11-21).
  - English comes first, and the first slice is jaw and mouth from speech, driven by the TTS
    text and timing (operator, 2026-11-21).
  - The operator's face is never stored or trained on. It is scored live in memory, and only
    numbers are written (operator, 2026-11-21).
  - Stages exchange a take, one OpenUSD file. Take files are written in GDScript, C++ or an
    Elixir DSL, never Python (operator, 2026-11-21).
  - Data and weights are Apache, MIT or CC0 (operator, 2026-11-22). Training data are renders
    and simulation.
  - The policy is a guest ELF trained on the RTX 4090. Reflexive networks go to the Hailo-10H
    when they fit, at 4-bit or lower, and exactness does not block them (operator, 2026-11-21).
  :: related
  - RFD66606-2478 (ANNY-soma-x keypoints), whose keypoint head this one extends to the face.
  - RFD66606-2327 (keypoints, supports and contacts), the generic keypoint vocabulary.
  - RFD66606-2311 (serving Bonsai 2), the quantization route for the 2-bit goal.
  """

  details_title "Measurements behind the face tracker plan"

  prose ~S"""
  :: details What was measured
  Skin patch: a 9 by 9 grid, 5 millimetres apart (a little under a pencil's width) and 2 thick,
  border pinned, in MuJoCo 3.4.0 on CPU, stretch only. A free patch moved 6 to 23 millimetres,
  from about a pencil's width to a bit more than a penny's width. At 20 kilopascals an in-plane
  push of 2 millinewtons moved the centre 0.0756 millimetres (a tenth of a card's thickness),
  and 4 millinewtons moved it twice as far. Ten times stiffer gave ten times less. A normal
  push moved it 1.88 millimetres (a little more than a penny's thickness), and doubling the
  force gave 1.34 times that, near the 1.26 of a stretch-only membrane.

  Take format: 10 tests pass. 200 random takes, with quotes, newlines and non-Latin text,
  decode to exactly what was written, and a writer that rounds floats fails two tests. A second
  write never replaces a file. OpenUSD 0.26.5 in the usd guest opened the good take, read its
  layer data back, and refused a missing bracket, a half file and plain text.

  Hardware: the headcam opens only through the Media Foundation backend, upright, with the
  right eye closing on the image's left. Windows shows the Hailo-10H with firmware 5.5.0, and the
  compiler's TensorFlow and PyTorch both see the RTX 4090.

  Keypoint head: RF-DETR's keypoint preview, fine-tuned for 40 epochs on 120 synthetic head
  renders with 88 keypoints whose labels come from the mesh, seed 1, on the GPU only. A held-out
  test of 24 renders (1,992 visible keypoints) is scored once per run, on the checkpoint that
  validation picks. PCK at 0.05 (the share of visible keypoints within 0.05 of the face box's
  diagonal) is 0.86 overall with GPU image decoding, against 0.14 for a model-free control that
  places every point at its mean position in the box. The four pitch bands (camera 0 to 10, 10
  to 20, 20 to 30 and 30 to 40 degrees below the face) score 0.72, 0.92, 0.88 and 0.88, masked
  images 0.88 and bare ones 0.84. The same recipe with CPU image decoding scores 0.50, with
  bands from 0.48 to 0.51. The two runs differ in the decoder. One of them was also restarted
  during training. The cause of the gap is unknown. The bar, set before training, is 0.80
  overall and 0.60 in every band.

  Label quality: a second split of 480 renders (its own seed, sharing no image with the test,
  validation or first split) has a median camera fit of 0.118 px. 22 of the 480 sit over 1 px,
  11 over 2 px, and the worst is 4.2 px. A larger fit residual puts the label that far from the
  drawn feature. A 2020 study of landmark annotation noise (arXiv 2007.15269) finds zero-mean
  noise of up to 3 percent of the box does not lower accuracy and raises output jitter, and
  4.2 px is about 1.3 percent of the box diagonal (an estimate). All 600 images stay in the mix
  (operator, 2026-11-22).

  :: details What was not measured
  - Whether any Hailo network parses, optimizes or compiles, and its distance from float.
  - The skin patch with bending, a solid, a jaw with muscles, or a GPU run.
  - The licence file inside the GNM weights, and the keypoint list.
  - Any policy, the residual FSQ latent, and 2-bit weights, whose recipe is undisclosed.
  - Reading the channel arrays back through OpenUSD. The guest reports counts and layer data.
  - A live run on the operator's face, and the memory of the Hailo module in use.
  - A second seed of the keypoint head, and any score from the 600-image mix run.
  :: details Parked
  Each item names why it waits and what restarts it.
  - Mix run: training on the 600 renders (the first 120 plus the second split) is paused after
    two of 40 epochs by a stop signal of unknown origin, and no score exists. It resumes when
    the operator releases it. Its best checkpoint is then scored once on the same 24 test renders
    and compared with the 0.86 above. More images and five times more optimizer steps change
    together, so a gain cannot be credited to the data alone.
  - Decoder gap: the 0.50 and the 0.86 differ for a reason nobody has found. It resumes with a
    clean rerun of the CPU-decoding recipe, with no restart.
  - Epoch timeline: AppSignal drops the last epoch span of a run in three runs, though the sender
    reports success. It resumes when the span timeline is needed. The integrated follower sends
    that span before the root span, which tests the guess that a late arrival is dropped.
  - Portrait library: 1,499 AI-generated portraits under CC0, with a request not to redistribute
    the files. Projecting one onto a head as a texture is refused (operator, 2026-11-22). A mesh
    fitted from detected landmarks gives labels only as good as the detector, and a photograph
    has no truth to check against. It resumes after a landmark-driven fit on our own renders,
    where the truth is known, scores inside the 0.05 bar.
  """
end
