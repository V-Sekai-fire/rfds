# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2320, "an agent drives the OXRSys simulator through cua-driver", :committed do
  feature "an MCP agent session on the Mac launches, sees and drives the OXRSys
Simulator through cua-driver, in the background"
  scope "XR Pilot's `oxrsys/docs/xr-cua-oxrsys.md` and
`oxrsys/scripts/xr-cua-oxrsys-register.sh`"

  prose ~S"""
  :: hook
  An agent sees and drives the OXRSys Simulator on the Mac without taking the operator's focus.
  :: intrigue
  The simulator is a desktop window. Without a way for an agent to see it and
  give it input, every simulator run needed a person at the keyboard.
  :: exit
  Run `scripts/xr-cua-oxrsys-register.sh` to register `xr-cua-oxrsys`; it prints the diff.
  :: decision
  An agent drives the OXRSys Simulator on the Mac through cua-driver's own MCP
  server, registered under the name `xr-cua-oxrsys`. It launches the simulator,
  reads the decoded preview as pixels and the control row as accessibility
  elements, and sends keys, clicks, typing and scrolls into the view. Every call
  runs in the background: no focus change and no cursor move, so the operator
  keeps working in another window. The operator ruled it done on 2026-10-17.
  :: related
  - RFD66606-2235, the agent that plans with taskweft through the editor, done in
    desktop mode through XR Pilot's plan tool.
  """

  details_title "how it is set up, and what it leaves out"

  prose ~S"""
  :: details Setup
  cua-driver is installed once on the Mac and reused across projects. Its
  accessibility and screen-recording grants belong to the driver app, not to the
  terminal that runs the agent. `scripts/xr-cua-oxrsys-register.sh` writes the
  `xr-cua-oxrsys` entry (command `cua-driver`, argument `mcp`) into the agent's
  MCP settings, keeps every other server and prints the diff. A running session
  picks the entry up when it reconnects its MCP servers.

  :: details Where it landed
  XR Pilot's repository, commit "Add xr-cua-oxrsys as the automation
  surface for the simulator" (2026-10-01): the document and the installer, 91
  lines in two files. The plan tool landed there in "Add a plan tool that acts
  out a taskweft RECTGTN task network" (2026-10-04).

  :: details What it leaves out
  - The headset side, a second server reached over SSH, is not on `main`. The
    document places it on the Flow 2 branch, and `docs/platforms/` does not
    exist on `main` (read 2026-10-17).
  - The simulator does not ship with cua-driver.
  - The name ends in `-oxrsys` so it does not clash with the headset-side server.
  """
end
