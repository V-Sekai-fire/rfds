# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2385, "the Proton tweak on the Frame is reproduced by script", :discussion do
  flight_level :l1
  scope "the wineopenxr tweak in the Frame's Proton copy and the script that reproduces it."

  prose ~S"""
  :: hook
  The Frame's Proton tweak is rebuilt by a script and checked by sha256, not made by hand.
  :: intrigue
  The Frame's `~/rfd2287/proton-xrfix` is stock Proton 11.0 (ARM64) with a wineopenxr tweak made
  by
  hand, so a change made only by hand cannot be pinned.
  :: exit
  Run `tools/frame/proton-xrfix.sh` on a fresh copy and check that the sha256s match.
  :: decision
  - The tweak is reproduced, not pinned.
  - `tools/frame/proton-xrfix.sh` applies the same change to a fresh copy and checks the sha256s
    match, and the logbook records the diff.
  - The harness runs on the scripted copy from then on.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the Proton tweak on the Frame is reproduced by script"

  prose ~S"""
  :: details The copy on the Frame
  `~/rfd2287/proton-xrfix` on the Frame is stock Proton 11.0
  (ARM64) with a wineopenxr tweak made by hand. `diff -rq` of the copy against
  `steamapps/common/Proton 11.0 (ARM64)` over `ssh frame` names the
  changed files.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2385", :provides, "proton"
    relate "rfd-2385", :provides, "scripted-proton-xrfix-tweak"
    relate "rfd-2385", :is_a, "deployment"
  end
end
