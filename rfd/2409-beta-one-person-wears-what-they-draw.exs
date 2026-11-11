# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2409, "beta: one person wears what they draw", :discussion do
  flight_level :l2
  scope "the beta release: what ships and what is playable."

  prose ~S"""
  :: hook
  Beta lets one person draw, wear what they drew, and watch the assistant draw too.
  :: intrigue
  Can one person draw, lasso the avatar, wear it and walk to the mirror, then hand the pen to the
  assistant?
  :: exit
  Play the beta: draw, lasso the avatar, wear it, walk to the mirror, then hand the pen to the
  assistant.
  :: decision
  - Beta is one person wears what they draw, and the assistant draws too.
  - Playable: draw, lasso the avatar, wear it, walk to the mirror; hand the pen to the assistant
    and watch it draw.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "beta: one person wears what they draw"

  prose ~S"""
  :: details What the beta holds
  Guests at double with the precision gate; priority mode and the replay feeder, with `PRIORITY=0`
  and `NOFEED=1`; lasso, the grid, local-floor, hand tracking and haptics; the avatars placed, the
  rigid attach and the mirror with `no_attach`; the rest of the town's modules.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2409", :provides, "beta-wear-what-you-draw"
    relate "rfd-2409", :is_a, "release-rung"
    relate "rfd-2409", :spends, "draw-step-pipeline-attach"
    relate "rfd-2409", :spends, "hand-lasso-target"
    relate "rfd-2409", :spends, "garment-follows-hips"
    relate "rfd-2409", :spends, "steamvr-priority-pen-drawing"
    relate "rfd-2409", :spends, "dev1-station-visit"
    relate "rfd-2409", :spends, "guest-elf-double"
    relate "rfd-2409", :owns, "rfd-2395"
    relate "rfd-2409", :owns, "rfd-2396"
  end
end
