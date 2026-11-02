# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2398, "the zone step ports the fabric zone into a guest", :discussion do
  flight_level :l1
  scope "the port of the fabric zone into the `guest/fabric` guest."

  prose ~S"""
  :: hook
  The zone step ports the fabric zone into a guest that two clients can play in.
  :: intrigue
  Could a frame have two owners or none? With the staging timeout floor removed, A rolls back to
  OWNED.
  :: exit
  Run `tests/gate_fabric_two_clients.gd` and check that each client sees the other's pose.
  :: decision
  - `guest/fabric`: `fabric_zone_types.h`, `relativistic_zone.h`, `predictive_bvh.h`, `r128.h` and
    the adapter verbatim with `real_t` as `double`; the static `_*_s` routines, intent packing and
    ghost helpers verbatim; `initialize`, `physics_process` and `finalize` rewritten as
    `ZoneCore::open(cfg)` and `tick(now_us)` with the `SceneTree`, `Engine`, `OS` and
    `ResourceSaver` calls replaced by arguments and byte buffers. The journal verbatim on
    in-memory
    SQLite with `export()` behind the write capability. The peer rewritten as `fabric_link.cpp`,
    one WebTransport session per neighbour with the channel in the frame. Each player is one
    entity. Its pose is one `CH_POSE` datagram a tick, 53 swing-twist triplets as int16, relayed
    with `local_broadcast_raw`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the zone step ports the fabric zone into a guest"

  prose ~S"""
  :: details Check and control
  Check: `tests/gate_fabric_two_clients.gd` runs server, worker and two players over loopback and
  reads each client's view of the other's pose; the Lean tests search for a frame with two owners
  or none across boundary crossings at candidate speeds and link delays. Control: the staging
  timeout floor removed with a one-tick delay rolls A back to OWNED while B's ACK is in flight,
  and
  the search finds two owners.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2398", :provides, "fabric-zone-guest-port"
    relate "rfd-2398", :provides, "zone-core-open-tick"
    relate "rfd-2398", :is_a, "guest-runtime"
    relate "rfd-2398", :spends, "guest-elf-double"
    relate "rfd-2398", :spends, "guest-ca-capabilities-repos"
  end
end
