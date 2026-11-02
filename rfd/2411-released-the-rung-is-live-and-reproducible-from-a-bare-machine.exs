# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2411, "released: the rung is live and reproducible from a bare machine", :discussion do
  flight_level :l1
  scope "the released rung of the release ladder."

  prose ~S"""
  :: hook
  A bare directory bootstrapped to the released tag reaches the rc build and plays it.
  :: intrigue
  Without the bootstrap line, a Frame cannot reach the rc build to play it against the live zones.
  :: exit
  Run the bootstrap line in a bare directory, then play the rc build on a Frame against the live
  zones.
  :: decision
  released: the rung, live and reproducible from a bare machine. Playable: anyone with the
  bootstrap line and a Frame reaches the rc build and plays it against the live zones.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "released: the rung is live and reproducible from a bare machine"

  prose ~S"""
  :: details What the release holds
  The evidence session recorded as CineForm with the zone journals;
  &{repo("contract-manifest-skateboard", planned: "2-contract")}
  created with the gates and the bootstrap, and a bare directory bootstrapped to the released tag.
  The manual's Sides and allowlist edits and this RFD landed. The
  desk's GitHub credentials destroyed.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2411", :provides, "rung-live-reproducible-bare"
  end
end
