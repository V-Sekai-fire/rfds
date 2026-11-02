# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2407, "dev.1 and dev.2 play on macOS through oxrsys", :discussion do
  flight_level :l1
  scope "where the dev.1, dev.2 and dev.3 rungs play, and the playtest of a dev rung."

  prose ~S"""
  :: hook
  dev.1 and dev.2 play on one Mac through oxrsys, and dev.3 plays on the Frame.
  :: intrigue
  Collision and walking never run in Godot's physics, so where do they run?
  :: exit
  Check a dev release against the rule: it carries the macOS engine and addon checked against
  their sums.
  :: decision
  - dev.1 and dev.2 play on macOS; dev.3 plays on the Frame. dev.1 and dev.2 run the macOS arm64
    double editor and addon through the oxrsys OpenXR runtime and its simulator, streaming with
    PyroWave, so one machine carries the whole loop.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "dev.1 and dev.2 play on macOS through oxrsys"

  prose ~S"""
  :: details The release and the playtest
  The release carries the macOS engine and addon checked against their sums, with oxrsys pinned in
  `tools/frame/releases.env`. Collision and walking run in the MuJoCo guest, never Godot's
  physics,
  because the guest is bit-deterministic and migratable. The playtest of a dev rung is persona
  locomotion: a named visitor persona, driven by a language model through the simulator, visits
  the
  station beat by beat, each beat with a screenshot, and the logbook records it as the playtest
  with that deviation named.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2407", :provides, "macos-oxrsys-dev-play"
    relate "rfd-2407", :is_a, "workspace-policy"
    relate "rfd-2407", :spends, "mac-desktop-client"
  end
end
