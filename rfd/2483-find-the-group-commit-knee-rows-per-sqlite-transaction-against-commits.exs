# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2483,
    "Find the group-commit knee: rows per SQLite transaction against commits and p99",
    :prediscussion do
  feature "a benchmark measures how many rows one SQLite transaction must carry to keep a " <>
            "FoundationDB-backed store at the challenge's write rate."

  scope "the 4-process scratch cluster's writer loop, its batch sizes, and the commit-rate " <>
          "table the run produces."

  prose ~S"""
  :: hook
  How many requests must one SQLite transaction carry so a server on this store keeps up
  with the challenge's write rate?
  :: intrigue
  One SQLite transaction is one FoundationDB transaction, and a commit costs a median of
  about 8.4 ms, so a server that commits per request caps near 100 writes/s per store. A
  lone writer through the VFS (the SQLite-on-FoundationDB virtual file system) measured
  from 89.7 commits/s to 106.9 commits/s, and a bare libfdb_c loop with no SQLite and no
  VFS measured from 106.5 commits/s to 113.5 commits/s per process at N=1. The challenge's
  user model is derived, not measured on this server, at about 165 writes/s at 20,000 users
  and about 830 writes/s at 100,000 users; re-derive from `bench/load.js` before quoting.
  :: exit
  Run a writer that carries K row-writes in one SQLite transaction, for K = 1, 4, 16, 64,
  256, three repeats, in closed-loop and fixed-arrival-rate modes. K=1 must reproduce about
  100 commits/s or the probe is wrong. Rows/s must grow close to linearly in K until commit
  latency rises; that point is the knee.
  :: decision
  - Run the writer on the 4-process scratch cluster (never port 4700), through the VFS, at
    K = 1, 4, 16, 64, 256, three repeats, in closed-loop and fixed-arrival-rate modes, and
    record whether any batch's dirty pages crossed into the VFS's staging path (FoundationDB
    bounds one transaction to 10 MB and 5 s).
  - Build a table from the log files with min, mean and max over the repeats; report rows/s,
    per-row p99 acknowledge latency, commits over 100 ms, and conflicted delta; name the knee
    batch size and amend `PROTOCOL.md` with the chosen batch window and size.
  - Run the crash-check control: a planted variant that acknowledges before the commit must
    show higher throughput and then fail the check; `kill -9` right after an acknowledgement
    must still find every acknowledged row in the store.
  :: related
  - RFD66606-2382, the skateboard's manifest, which names datasource-store's SQLite VFS over
    FoundationDB as the store this benchmark measures.
  """

  details_title "Find the group-commit knee: rows per SQLite transaction against commits and p99"

  prose ~S"""
  :: details Data so far
  - Lone writer through the VFS: from 89.7 commits/s to 106.9 commits/s
    (`results-contention-matrix2.log`, `results-contention-matrix3.log`, commit 482974a).
  - Bare libfdb_c loop, no SQLite, no VFS: from 106.5 commits/s to 113.5 commits/s per
    process at N=1, median commit about 8.4 ms (`results-contention-matrix5.log`, commit
    6be7ddb).
  - Derived, not measured on this server: the user model does a like with probability 0.15
    and a post with probability 0.02 per iteration of roughly 21 s of think time (think-time
    bands of 3 s to 7 s, 3 s to 8 s, and 5 s to 15 s). That is about 0.008 writes/s per user,
    so about 165 writes/s at 20,000 users and about 830 writes/s at 100,000. Re-derive from
    `bench/load.js` before quoting.
  - The C leader already group-commits; this store's writer must too.

  :: details Reading rule, fixed before the run
  - K=1 must reproduce about 100 commits/s. If it does not, the probe is wrong.
  - Rows/s should grow close to linearly in K until commit latency rises. The knee is the
    batch size the server uses.
  - Report rows/s, per-row p99 acknowledge latency, commits over 100 ms, and conflicted
    delta.

  :: details Controls that must be able to fail
  - A planted variant that acknowledges before the commit must show higher throughput and
    then fail the crash check.
  - Crash check: `kill -9` the writer right after an acknowledgement and confirm every
    acknowledged row is in the store. An earlier measurement found a store that acknowledged
    before durable, and this is the failure that catches it.

  :: details Acceptance
  A table built from the log files, with min, mean and max over the repeats; the knee named;
  and a one-line `PROTOCOL.md` amendment stating the batch window and size the benchmark
  server will use.
  """
end
