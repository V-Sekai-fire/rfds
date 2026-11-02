# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2400, "the worker zone dispatches and a sidecar computes", :discussion do
  flight_level :l1
  scope "the worker zone, its GPU sidecar, and the garment's one owner."

  prose ~S"""
  :: hook
  The tiny worker zone owns and dispatches the garment while a sidecar with a GPU computes it.
  :: intrigue
  What if one byte of one chunk is flipped on the way back? The worker verifies every chunk
  against its id, so the flip is caught there.
  :: exit
  Run the two-client gate and check that it counts exactly one owner of the garment every tick.
  :: decision
  - The worker zone is tiny and has no GPU, so it owns and dispatches and does not compute.
    `zone.elf` in worker mode (zone 1) keeps the job queue, the garment's ownership and the
    asset index.
  - The GPU stage runs on a sidecar, a client that has a GPU and the pen's sandbox (this Mac in
    this rung, the Frame when it is idle), which registers with the worker over a `CH_JOB`
    stream when it connects.
  - When no sidecar is attached the worker runs the CPU target of the same Lean-emitted kernels
    (`kernels/cassie/cpp`, the slangc cpp emits under slang-rt, one source two targets) itself,
    slower and the same answer within RFD66606-2269's intervals.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2269, the CPU oracle's intervals.
  """

  details_title "the worker zone dispatches and a sidecar computes"

  prose ~S"""
  :: details The sidecar path
  On `strokes_ready` the worker sends the stroke set to one sidecar. The sidecar's
  `stages/sidecar_stage.gd` runs `curvenet.elf` on compute-rd, then `asset_store` through
  `asset.elf`, and streams the `.caibx` and the chunks back on `CH_ASSET`. The worker verifies
  every chunk against its id (`guest/asset`: `parse_caibx`, the buzhash chunker, `sha512_256`,
  `decompress_and_verify_chunk`, `assemble_from_caibx`, lifted from `fabric_mmog_asset.cpp` onto
  std types. HTTP, keychain and ACL dropped), writes them under the server's store, records the
  index hash in its journal, then `zone_garment_spawn(hash)` and `zone_handoff(eid, 0)`. The
  ghost carries the index hash. Each client fetches by it and assembles.

  :: details Check and controls
  Check: the two-client gate counts the garment's owners every tick and finds exactly one. A
  garment the sidecar made lies inside the CPU oracle's intervals (RFD66606-2269). The Lean chunk
  property stores random data up to 1 MiB, verifies every chunk and assembles the input.

  Controls: one byte of one chunk flipped with the expectation kept must be caught at the worker.
  A sidecar kernel built with `-ffp-contract=on` falls outside the interval and is named. The
  worker with no sidecar makes the garment itself and the gate records both times.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2400", :provides, "worker-zone-dispatch"
    relate "rfd-2400", :provides, "gpu-sidecar-compute"
    relate "rfd-2400", :is_a, "guest-runtime"
    relate "rfd-2400", :spends, "zone-core-open-tick"
    relate "rfd-2400", :spends, "sandbox-guest-heavy-compute"
  end
end
