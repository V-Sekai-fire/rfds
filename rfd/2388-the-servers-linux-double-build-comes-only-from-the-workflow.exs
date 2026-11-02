# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2388, "the servers' Linux double build comes only from the workflow", :discussion do
  flight_level :l1
  scope "the one Linux x86_64 build of the servers' double."

  prose ~S"""
  :: hook
  The servers' Linux double build has one source, the workflow's `linux-x86_64` job.
  :: intrigue
  The Frame's own Linux path lacks XCursor and xkbcommon, so which Linux build is the servers'?
  :: exit
  Check that a Linux build for the servers comes from the matrix's `linux-x86_64` job in the
  workflow.
  :: decision
  - Linux x86_64 double, the servers' build, comes only from the workflow: the matrix's
    `linux-x86_64` job is the servers' one Linux build, it runs `--headless` in the Fly image, and
    the pen's headless gates run on the `ubuntu` runner.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the servers' Linux double build comes only from the workflow"

  prose ~S"""
  :: details The Frame's own Linux path
  The Frame's own Linux path, the compatibility layer's missing XCursor and xkbcommon, is a
  runtime
  `dlopen`. The x86_64 `SteamLinuxRuntime_sniper` entry point under FEX is tried once from the
  headset and `LD_DEBUG=libs` logged either way, and no rung waits on it.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2388", :provides, "workflow-only-linux-double"
    relate "rfd-2388", :spends, "actions-builds-double-binaries"
    relate "rfd-2388", :is_a, "ci-gate"
  end
end
