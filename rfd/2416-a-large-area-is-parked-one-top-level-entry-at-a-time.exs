# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2416, "a large area is parked one top-level entry at a time", :discussion do
  flight_level :l2
  scope "how a desk parks a large area."

  prose ~S"""
  :: hook
  A large area is parked one top-level entry at a time, and the area visibly shrinks.
  :: intrigue
  A census of every file first delays the move, and the area shows no sign of shrinking.
  :: exit
  Park the next large area by taking its first top-level entry, pushing or moving it into the
  tree, then removing it.
  :: decision
  A large area is parked one top-level entry at a time, so the area visibly shrinks.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a large area is parked one top-level entry at a time"

  prose ~S"""
  :: details Each entry
  Each is pushed or moved into the tree and then removed until the area is empty, with no census
  of every file first.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2416", :provides, "area-parked-entry-by-entry"
  end
end
