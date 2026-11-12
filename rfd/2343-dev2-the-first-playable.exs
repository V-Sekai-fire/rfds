# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2343, "dev.2, the first playable", :committed do
  feature "what the pen holds at its pinned commit: draw, curvenet's closed shell, the statue,
world grab"
  scope "the pen at its pinned commit and the tray's dev.1 build; RFD66606-2344 proves it"

  prose ~S"""
  :: hook
  dev.2 is what the pen holds at its pinned commit, and nothing more.
  :: intrigue
  The first version of this rung promised a shared world, a wardrobe, the mascot's
  requests and the signs. None of them is built.
  :: exit
  Run the proof in RFD66606-2344 against each dev.2 claim: the XR pen, the closed shell, the
  dress-on statue, world grab and the station walker.
  :: decision
  dev.2 is what the pen holds at its pinned commit, written down and nothing more.
  A person draws with the XR pen, curvenet.elf closes the strokes into one shell,
  and the shell shows on the dress-on statue. World grab and the station walker
  work. RFD66606-2344 proves each of these under the private working agreements.
  :: related
  - RFD66606-2342, dev.1 (tray); RFD66606-2344, dev.3 (the proof); RFD66606-2341 (dev.next).
  - RFD66606-2262, the pen's release ladder.
  - The private brief, the private blocklist and the private pitfalls list.
  """

  details_title "dev.2, what the pen holds at its pinned commit"

  prose ~S"""
  :: details What dev.2 holds
  Each line names the gate in the pen's `tools/` that already exercises it.

  - The scripted pen in `xr_main.tscn`, XR or flat: 6 strokes close 2 cycles and
    2 openings into one skirt shell (`gate_xr_scripted.gd`).
  - A recorded or replayed stroke layer, through OXRSys or from `.usda`, meshed
    to its expected counts; a CASSIE session replayed to every expected cycle
    (`gate_replay.gd`).
  - The dress-on statue beside the plaza monument: the skirt drawn at the statue
    lands in its body frame and shows on it as a closed garment
    (`gate_statue.gd`).
  - World grab: both grips carry, turn and scale the canvas; one grip moves
    nothing (`gate_world_grab.gd`).
  - The walker on the station's colliders in the MuJoCo guest: walk, stairs,
    ledge and handrail refusal, snap turn, teleport, bit-exact repeat
    (`gate_locomotion.gd`).
  - Pen strokes drawn as Line3D ribbons; every shipped guest and `.sgd`
    binary-translated on macOS and Windows.
  - The tray from RFD66606-2342: icon, popup, headset probe, the mascot idling.
  :: details What dev.2 does not hold
  Every gate above stops at MESH. Nothing checks a garment against a body mesh,
  a clothing hide, or bone rest scale. No SCSS port is in the pen. No zone, no
  ENet clients, no FDB-SQLite wardrobe, no mascot requests, no signs, no audio
  cues. These wait in RFD66606-2341.
  :: details The pins
  Each pin is the commit or release the dev.2 logbook names.

  - Engine: our Godot build fork's release v20260930-double.1.
  - Our meshing pen and our curvenet interactor.
  - Our XR pilot interactor: OXRSys and xr_pilot_mcp.
  - The tray's dev.1 build.
  :: details The problem
  A rung that lists
  unbuilt work as done cannot be verified, so this one lists only what exists.
  """
end
