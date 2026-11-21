# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2501, "A stream persona avatar drawn by Godot and cut out in OBS", :discussion do
  feature "a Godot window draws colour and depth panels, and an OBS shader cuts the avatar out."

  scope "the avatar project, the depth composite shader, and the OBS scene that uses them."

  prose ~S"""
  :: hook
  Can the stream persona be drawn by the engine, with her edges cut by depth in OBS, and
  show no seam against the game picture?
  :: intrigue
  The three.js viewer is gone. A Godot window holds three panels side by side: colour, depth
  of the outfit and hair, and depth of the body alone. An obs-shaderfilter shader keeps the
  nearer depth as alpha. The first cut left a faint line down both sides of her box.
  :: exit
  Read the filtered source back through OBS and check that the first and last columns have
  alpha 0, then look at the scene with the game picture behind her.
  :: decision
  The repository interactor-stream-persona holds the project, the shader and the
  scene collection, and its checkout is the folder OBS reads (operator, 2026-11-21).
  - The shader samples the depth panels at exact thirds, half a texel inside each panel.
  - OBS keeps the first shader it compiled, so a changed shader means a re-created filter.
  - The avatar art, renders, MToon copies and generated data stay out of the repository.
  :: related
  - RFD66606-2499 (portrait to hair-card VRM), which makes the avatars this project draws.
  - RFD66606-2500 (the face tracker), which will drive her face from the headcam.
  """

  details_title "Measurements behind the depth composite"

  prose ~S"""
  :: details What was measured
  On a captured frame, the old shader gave alpha 0.39 in column 0 and 0 in the rest of an
  empty row, and exact thirds gave 0 in every column. In the live scene the old line was a
  dip of about 20 percent in brightness across one column. After the filter was re-created,
  alpha was 0 in columns 0 to 2 and 437 to 439 of the 440-column source.

  :: details What was not measured
  - The result on a recorded or streamed output, and on a second monitor scale.
  - Whether an edge remains at the game picture's own borders for other videos.
  - Any cost of the three-panel window on the 4090 or the stream's frame rate.
  """
end
