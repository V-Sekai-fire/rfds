# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2404, "the evidence step records one session", :discussion do
  flight_level :l1
  scope "Step 8, the evidence: one session, its recordings, logs and logbook."

  prose ~S"""
  :: hook
  The evidence step records one session, with a check that refuses a truncated recording.
  :: intrigue
  A truncated `.cfhd` must not pass as the recorded session.
  :: exit
  Check that `av1mkv info`'s frame count equals the `.cfhd`'s, and that a truncated
  `.cfhd` fails `av1mkv check`.
  :: decision
  - The evidence is one session: the person in the headset and the operator on the desktop, the
    assistant's hands on the pen through priority mode and the live feeder.
  - `av1mkv mkv` makes the lossless wrap here, which with its `.cff` is the whole deliverable,
    and no WebM is made.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the evidence step records one session"

  prose ~S"""
  :: details The recordings and logs
  The headset view is `clip.sh` from the compositor
  mirror and `still.sh`. The desktop view is `godot-cineform` rebuilt
  at double for macOS arm64 (its own manifest's `godot-cpp` with
  precision double) writing `session.cfhd` through Movie Maker at a
  fixed 30 fps on the flat client, never the XR one. The zone logs are the three
  `zone.elf` journals exported under the write capability.

  :: details The logbook
  `logbook/logbook-rfd2287-rung.md` carries the apparatus (the exact
  `run-xr.sh` lines, driver settings, sha256s), the numbers with their
  baselines (frame ms with and without the world, the bone-follow
  displacement, the tracker profiles in both modes), every control's
  outcome, and the counted unchecked items.

  :: details Check and control
  Check: `av1mkv info`'s frame
  count equals the `.cfhd`'s. Control: a truncated `.cfhd` is refused
  by `av1mkv check`.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2404", :provides, "session-evidence-recording"
    relate "rfd-2404", :is_a, "experiment-record"
    relate "rfd-2404", :spends, "cineform-matroska-video"
    relate "rfd-2404", :spends, "mac-desktop-client"
    relate "rfd-2404", :spends, "steamvr-priority-pen-drawing"
  end
end
