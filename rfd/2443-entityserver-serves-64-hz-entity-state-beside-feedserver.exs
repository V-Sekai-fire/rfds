# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2443, "EntityServer serves 64 Hz entity state beside FeedServer", :committed do
  flight_level :l1

  feature "a sibling EntityServer serves 64 Hz 3D state beside FeedServer."

  scope "the transport repository: entity modules, one executable, the codec, the load generator."

  prose ~S"""
  :: hook
  Can the feed server's ring, store and layers carry a tick loop without a second copy of any of
  them?
  :: intrigue
  The repository already has the io_uring glue with a provided-buffer ring, a store that opens
  FoundationDB through a VFS, and layered proofs. It has no tick, no packet codec and no load
  generator.
  :: exit
  The first gate: a binary ticks at 64 Hz on Linux, sends a fixed batch of 12 entities to one
  registered address, and prints tick-to-send percentiles.
  :: decision
  EntityServer is a sibling of FeedServer in the same repository, built by the same lakefile
  (operator, 2026-11-07). It reuses the ring glue, the JWT layer and the store, and edits them
  where they must change. It adds no parallel copy.
  - State lives in memory in a flat array. The tick path does no SQLite and no disk I/O.
  - The 100 byte packet layout has one source, the entity packet contract, taken by subtree.
    EntityServer never re-emits the offsets.
  - The tick kernel is written in a restricted Lean subset with proofs and emitted as standalone
    C99 with fixed-capacity arrays and no heap. The ring loop stays hand-written C.
  - Pose goes by datagram. Join, leave and ownership go on a small reliable channel.
  - The timer uses absolute deadlines on the monotonic clock. An overrun coalesces or drops, and
    never queues a backlog.
  - Each client owns its own avatar entity, so pose has no write conflicts. Store writes happen
    behind the tick.
  :: related
  - RFD66606-2442, the latency metric that judges this server.
  - RFD66606-2044, Lean at build time and a flat C ABI at run time.
  - RFD66606-2304, the one Lean library that generates a C planner through the same compiler.
  """

  details_title "EntityServer serves 64 Hz entity state beside FeedServer"

  prose ~S"""
  :: details The problem
  The repository's own record was partly stale. The store path through FoundationDB, its header
  and the subtree are on the main branch. Parity and profile figures in the divergence notes were
  measured on SQLite, not on FoundationDB, and the README said the submission has no FoundationDB
  code.
  :: details Rungs
  - Skateboard: timer, UDP socket, fixed batch of 12 entities, tick-to-send percentiles printed.
  - Multishot receive into the existing buffer ring, and a session table keyed by address.
  - The codec from the contract, with two proofs: a decode reads no more than 100 bytes, and a
    batch with headers stays within 1,280 bytes.
  - Area-of-interest grid, so fan-out is users times entities in view, not users squared.
  - Load generator and sweep, with a control that fails: a planted slow handler that pushes p99
    over budget.
  - Write-behind to the node's store, then two nodes.
  :: details Acceptance
  - The emitted C builds with strict C99 warnings as errors, and the tick object has no allocation
    or runtime symbols.
  - Fixtures through the Lean semantics and through the emitted C give identical bytes, and a
    planted bug in the C makes that check fail.
  - The tick kernel has zero unproved goals. No MISRA conformance is claimed.
  - The default feed path keeps passing its diff and smoke scripts.
  - On the CPU runner, only checks that need no cluster run. A live FoundationDB check is an
    integration test.
  :: details Open
  Extend the in-house emitter, which emits only the codec header today, or vendor the Trust-Lean
  compiler by subtree. One source either way, never a copy or a submodule.
  - Gate evidence: the feed server, CI run
    42417791013, jobs tick-budget and client sweeps (success). entity_serve.c fails a
    run whose p99 is over 4 ms, and the planted-defect sweeps are caught. The Lean tick
    kernel and its emitted-C byte check are not in the repo, so the Lean-to-C acceptance
    is unmet and stated as such.
  """
end
