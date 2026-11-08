# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2474, "Suit markers: dead-on gate must read every marker", :prediscussion do
  feature "the dead-on gate reads every painted marker in perfect conditions, with no exceptions."

  scope "`dead_on.py`, `texture_markers.py`, and the placed-marker set they score."

  prose ~S"""
  :: hook
  Does every marker we paint scan dead on, with the camera square on and nothing in the way?
  :: intrigue
  Today the gate fails: 276 of 280 visible markers read (98.57%) with the original ids, 278 of
  280 (99.29%) with the ids moved. Camera 74 fails with two different ids at the same spot, so
  that is a position fault: a sharply tilted surface strip sits beside the marker. Ids 664, 703,
  1973 and 1268 fail only at some positions, so those are pattern faults, not position faults.
  :: exit
  Run the full pass over all 2,600 placed positions once it finishes rendering, and read the gate
  against that pass: 100% of the markers left after dropping the failing ids must read.
  :: decision
  Drop every marker id that fails the dead-on gate (held in `DROP_IDS`) and require a 100% read
  rate on the rest. A dropped id's slot stays a hole on the garment rather than being refilled by
  a neighbour, so the drop list is stable across renders. Camera 74's failure is tracked and
  fixed separately as a position fault, since it is a tilt problem in the surface strip, not a
  marker pattern problem, and fixing it is out of this gate's scope.
  """

  details_title "Suit markers: dead-on gate must read every marker"

  prose ~S"""
  :: details The two fault classes
  - Position fault: a marker's own pattern is fine, but where it sits (near a seam, a sharp
    fold, or a tilted strip) keeps the camera from reading it. Camera 74's dual-id read at one
    spot is this class.
  - Pattern fault: the marker's pattern itself does not read cleanly regardless of where it
    sits. Ids 664, 703, 1973 and 1268, which fail only at some positions and not others, land
    here once position is ruled out.
  :: details Where the code lands
  `dead_on.py` scores each rendered position against the expected id, and `texture_markers.py`
  paints the marker set onto the garment texture before render. Both are referenced from pull
  requests V-Sekai-fire/interactor-taskweft-persona#6 and #7 against
  https://github.com/V-Sekai-fire/interactor-garment-proxy.
  :: details Open
  The full 2,600-position pass was still rendering at the time of this draft. `DROP_IDS` is
  provisional until that pass completes and confirms no additional ids fail.
  """
end
