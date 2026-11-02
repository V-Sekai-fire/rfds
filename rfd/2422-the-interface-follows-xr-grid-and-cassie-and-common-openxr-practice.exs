# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2422, "the interface follows xr-grid and CASSIE and common OpenXR practice", :discussion do
  flight_level :l1
  scope "the interface's source in xr-grid and CASSIE, and its OpenXR practice."

  prose ~S"""
  :: hook
  The interface draws in a world-locked grid and keeps to common OpenXR practice for input and
  comfort.
  :: intrigue
  What a person makes is stored by content hash, so the other client fetches the garment by its
  hash and the ghost carries only the hash.
  :: exit
  Check a new input against the rule: it binds to an action in the action map, never to a raw
  button.
  :: decision
  The interface derives from xr-grid and CASSIE: the pen draws in a world-locked grid, and
  CASSIE's strokes, boundary marks and curvenet are what the person sees form. It keeps to common
  OpenXR practice, listed in the details.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  - RFD66606-2363, the world grab by which a person moves.
  """

  details_title "the interface follows xr-grid and CASSIE and common OpenXR practice"

  prose ~S"""
  :: details Selection, touch and storage
  Selection far away is the lasso: a pointing cone that snaps to the nearest target, its math
  (`LassoDB`, `LassoPoint`) moved from the engine module into `lasso.elf`. Near things are touched
  directly. What a person makes is stored by content hash with casync (`.caibx` chunk indexes, the
  fabric asset code moved into `asset.elf`), so the other client fetches the garment by its hash,
  and the ghost carries only the hash.

  :: details Common OpenXR practice
  The interface keeps to common OpenXR practice:

  - Input binds to actions in the action map, never to raw buttons, with a profile for each
    controller and for hand tracking.
  - The reference space is local-floor. Interface panels are world-locked, 1 to 3 m away, never
    locked to the head, and their text is at least 1 degree tall.
  - The frame rate holds the headset's refresh rate. A person moves by xr-grid's world grab, both
    grips pinching the world, with no smooth acceleration (RFD66606-2363).
  - A haptic pulse confirms each stroke closed, lasso target taken and garment worn.
  - The mirror is a world-locked object the person walks up to, not a window on their view.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2422", :provides, "xr-grid-cassie-interface"
  end
end
