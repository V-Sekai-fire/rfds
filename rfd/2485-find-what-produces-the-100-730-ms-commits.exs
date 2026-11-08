# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2485, "Find what produces the 100 ms to 730 ms commits", :prediscussion do
  feature "a probe isolates whether FoundationDB, macOS scheduling, or cluster-wide pauses " <>
            "produce the slow commits seen in every benchmark arm so far."

  scope "a plain fsync probe, trace-event correlation and a RAM-disk cluster arm, run " <>
          "against the bare libfdb_c commit loop."

  prose ~S"""
  :: hook
  What produces the commits from 100 ms to 730 ms seen in every benchmark arm so far?
  :: intrigue
  `results-contention-matrix5.log` (commit 6be7ddb) ran a bare libfdb_c loop with no SQLite
  and no VFS (the SQLite-on-FoundationDB virtual file system), so the VFS is not the cause.
  Slow-commit clusters (events within 0.25 s of each other) numbered 24 across 12 cells: 14
  touched more than one process and 10 touched one, correcting an earlier report that every
  cluster touched more than one process. A lone process stalled in 2 of 3 repeats, so
  sharing alone does not explain the stalls. Server CPU stayed near half a core, ratekeeper
  reported `limited_by=workload` throughout, and the scratch trace logs held one SlowTask
  event in total and no disk-stall events.
  :: exit
  A cause counts only if a control reproduces or suppresses the stall on demand; otherwise
  it stays undetermined, with what was ruled out, built from log files.
  :: decision
  - Run a plain C loop of `write` plus `fcntl(F_FULLFSYNC)` on the same volume as the scratch
    cluster, recording the maximum latency, both alone and alongside a commit loop; if it
    stalls the same way, FoundationDB is cleared as the cause.
  - Correlate the wall-clock start of every slow commit against fdbserver trace events and
    against production `fdbmonitor` log activity; sample `fs_usage` or `iostat` during the
    cells; run a RAM-disk cluster arm on the Mac and the desk arm from the sibling scheduling
    probe.
  - Run the two controls: `SIGSTOP` a scratch `fdbserver` for 300 ms and confirm the detector
    reports a multi-process cluster; run with no load and confirm no stalls are reported.
  - Keep the three candidates separate and untested until a control decides each: the
    scratch tlog's fsync sharing the Mac's SSD with the production cluster, macOS scheduling
    of client processes, and a cluster-wide pause. Do not cite the commit-proxy latency
    lines in `status json` per cell; they are cluster-wide windows, repeated across cells.
  :: related
  - RFD66606-2382, the skateboard's manifest, which names datasource-store's SQLite VFS over
    FoundationDB as the store these commits were measured against.
  """

  details_title "Find what produces the 100 ms to 730 ms commits"

  prose ~S"""
  :: details Data so far
  `results-contention-matrix5.log` (6be7ddb), bare libfdb_c loop, no SQLite and no VFS, so
  the VFS is not the cause:

  - Slow-commit clusters (events within 0.25 s of each other): 24 in the 12 cells. 14
    touched more than one process, 10 touched one.
    - N=1: 8 clusters, all single-process. N=2: 4, all multi. N=4: 3, all multi. N=8: 9, of
      which 7 multi and 2 single.
    - An earlier report said every cluster hit more than one process. That was wrong, and
      this table corrects it.
  - A lone process stalled in 2 of 3 repeats (5 and 4 commits over 100 ms), so sharing alone
    does not explain the stalls.
  - Server CPU stayed near half a core. Ratekeeper said `limited_by=workload` throughout.
  - The scratch trace logs held one SlowTask event in total and no disk-stall events.
  - The commit-proxy latency lines in `status json` are cluster-wide windows, repeated
    identically across cells. Do not cite them per cell.

  :: details Candidates, kept separate and all untested
  1. The scratch tlog's fsync sharing the Mac's SSD with the production cluster.
  2. macOS scheduling of the client processes.
  3. A pause across the cluster.

  :: details Method
  - Cheap decisive probe: a plain C loop of `write` plus `fcntl(F_FULLFSYNC)` on the same
    volume, recording the maximum latency, run alone and alongside a commit loop. If it
    stalls the same way, FoundationDB is cleared.
  - Correlate the wall-clock start of every slow commit with fdbserver trace events (trace
    format with timestamps) and with production `fdbmonitor` log activity.
  - Sample `fs_usage` or `iostat` during the cells.
  - A RAM-disk cluster arm on the Mac.
  - The desk arm from the sibling scheduling probe.

  :: details Controls that must be able to fail
  - SIGSTOP a scratch `fdbserver` for 300 ms: the detector must report it as a multi-process
    cluster.
  - A run with no load must show no stalls.

  :: details Reading rule, fixed before the run
  A cause counts only if a control reproduces or suppresses the stall on demand. Otherwise
  it stays "undetermined", with the list of what was ruled out.

  :: details Acceptance
  One named cause, or an explicit "undetermined" with what was ruled out, built from log
  files.
  """
end
