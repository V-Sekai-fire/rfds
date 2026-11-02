# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2364, "the whole stack deploys offline on one laptop", :discussion do
  flight_level :l2
  scope "deploying the whole stack on one laptop with nothing from the WAN."

  prose ~S"""
  :: hook
  The whole stack runs on one laptop, on the LAN and perhaps the tailnet, with no WAN.
  :: intrigue
  A fetch that reaches past the laptop fails by name once the stack runs with its network
  unshared.
  :: exit
  Run the Bubblewrap test: run the stack with its network unshared and read the name of any
  fetch that fails.
  :: decision
  The whole stack deploys offline on one laptop, reachable on the LAN and perhaps
  the tailnet, with nothing needed from the WAN:

  - every build source is in the manifest and mirrored on the laptop, and release
    binaries are mirrored with their sha256s;
  - each runtime (FoundationDB, Uro, OpenBao, the zone servers, the object store)
    runs on the laptop, with only its own data;
  - names come from the laptop's own resolver or the tailnet, and certificates
    from the offline CA;
  - sign-in has a LAN-only method beside the third-party providers.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "the whole stack deploys offline on one laptop"

  prose ~S"""
  :: details The Bubblewrap test
  Bubblewrap is the test: the stack runs with its network unshared, so a fetch
  that reaches past the laptop fails by name. Uro runs next to its FoundationDB
  cluster, so a page read never leaves one machine.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2364", :provides, "offline-laptop-deploy"
    relate "rfd-2364", :is_a, "deployment"
    relate "rfd-2364", :spends, "bao"
    relate "rfd-2364", :spends, "fdb-sqlite"
  end
end
