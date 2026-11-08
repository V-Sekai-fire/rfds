# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd(
  2475,
  "Suit markers: tag bench and the marker frontier (variants against input families)",
  :prediscussion
) do
  feature "a tag bench and a frontier table pick tag family, marker size and detector settings."

  scope "`tag_bench.py`, `frontier_markers.py`, and the detector variants they compare."

  prose ~S"""
  :: hook
  Which tag family, marker size and detector settings give the fewest wrong reads at distance
  and tilt?
  :: intrigue
  The first bench run was invalid: the flat sheets rendered mirrored, so flipping the frame read
  263 markers instead of the expected count, which gave 3,913 of 3,917 tags "broken" and failed
  the control outright. That bug is fixed in `tag_bench.py`. A per-tag blocklist is not a usable
  gate on its own, since it only reacts to tags that already failed; the frontier table has to
  decide tag family, marker size and detector settings up front instead.
  :: exit
  Re-render the bench and build the frontier table: detector variants crossed with distance and
  tilt, each cell holding its wrong-read count, plus a flipped-frame control that must itself
  read as broken.
  :: decision
  Ship the frontier table as the gate that selects tag family, marker size and detector settings,
  replacing any per-tag blocklist approach. Detector settings already show they matter at large
  marker scale: a window of 3 to 203 and a threshold constant of 3 recovered most of the unread
  markers at 220 px, and that setting becomes the frontier's starting point rather than a fixed
  default.
  """

  details_title "Suit markers: tag bench and the marker frontier"

  prose ~S"""
  :: details The mirrored-frame bug
  The flat sheets used to validate detector settings rendered mirrored left-to-right. Flipping
  the frame before detection recovered 263 readable markers that the un-flipped frame reported
  as unreadable, which inflated the broken-tag count to 3,913 of 3,917 and made the bench's own
  control pass for the wrong reason. `tag_bench.py` now flips consistently with the render path.
  :: details Frontier axes
  - Tag family: which marker dictionary is painted.
  - Marker size: physical size in mm (and the derived pixel count at a given camera distance).
  - Detector settings: adaptive-threshold window size and threshold constant.
  - Distance and tilt: the two viewing conditions crossed against every other axis.
  - Flipped-frame control: every cell also runs mirrored, and must report broken, not readable.
  :: details Code
  `tag_bench.py` and `frontier_markers.py`, both in
  https://github.com/V-Sekai-fire/interactor-garment-proxy.
  :: details Open
  The re-render and the full frontier table were queued, not yet run, at the time of this draft.
  """
end
