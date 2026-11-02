# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2410, "rc: two people in one zone, talking", :discussion do
  flight_level :l1
  scope "the rc rung of the release ladder: two people in one zone, talking."

  prose ~S"""
  :: hook
  The rc rung puts two people in one zone, talking, with the garment made elsewhere.
  :: intrigue
  Can one person in the headset and one on the desktop each see the other's avatar and hear them?
  The drawn garment must materialise from the worker zone and be worn.
  :: exit
  Run the two-client gate against the address of `weftspun-zone`, with the headset as one client
  and the desktop as the other and the sidecar.
  :: decision
  - rc: two people in one zone, talking, the garment made elsewhere, the zones live on Fly.
  - Playable: one in the headset, one on the desktop, each sees the other's avatar and hears
    them. The drawn garment materialises from the worker zone and is worn.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "rc: two people in one zone, talking"

  prose ~S"""
  :: details What the rc holds
  &{repo("interactor-fabric-zone")} and &{repo("interactor-voice")} placed. `ca.elf` and the
  capability table. The transport over the host's UDP. The zone with the one-owner search. The
  worker zone and `asset.elf` with the corrupted chunk. Voice with the dropped packet. The zone
  journals on &{repo("service-bao-sqlite-fdb")} over FoundationDB, read back by `bao read` and
  resumed after a restart. `weftspun-zone` deployed and the two-client gate run against its
  address with the headset as one client and the desktop as the other and the sidecar.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2410", :provides, "rc-two-people-talking"
  end
end
