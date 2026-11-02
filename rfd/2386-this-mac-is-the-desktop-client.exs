# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2386, "this Mac is the desktop client", :discussion do
  flight_level :l1
  scope "what this Mac builds so it serves as the desktop client."

  prose ~S"""
  :: hook
  This Mac runs the desktop client: the macOS double editor, the addon library and compute-rd.
  :: intrigue
  Without a macOS client, the pen's parked `macos.yml` stays parked and the headless gates have
  no macOS arm.
  :: exit
  Run `tools/run-mac.sh` beside `run-windows.sh` to start the flat client and the sidecar on this
  Mac.
  :: decision
  - This Mac as the desktop client: the macOS double editor from the release, the addon's macOS
    double library, compute-rd on Metal through the same `rdc::Device`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "this Mac is the desktop client"

  prose ~S"""
  :: details Scripts and gates
  `tools/run-mac.sh` beside `run-windows.sh` for the flat client and the sidecar; the pen's
  parked `macos.yml` becomes the macOS arm of the headless gates.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2386", :provides, "mac-desktop-client"
  end
end
