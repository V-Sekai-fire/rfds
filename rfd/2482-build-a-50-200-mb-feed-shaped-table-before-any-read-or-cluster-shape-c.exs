# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2482,
    "Build a 50-200 MB feed-shaped table before any read or cluster-shape claim",
    :prediscussion do
  feature "the reader bend gets re-measured on a realistic feed-shaped table, not a toy one."

  scope "the scratch FoundationDB cluster's VFS, its test table, and PROTOCOL.md's pair cells."

  prose ~S"""
  :: hook
  Does the reader bend survive a realistic table?
  :: intrigue
  In the pair matrix, per-pair reads fell to 0.65-0.67 of M=1 at M=8 with the writer fixed at
  50 commits/s, and to 0.47-0.48 with the writer at max rate. The current test table has 2,000
  rows, about 500 KB, with a total store size probably around 4 MB, which data distribution
  almost certainly keeps in one shard on one storage process; adding storage processes would
  then change nothing, so a "not the cluster" conclusion drawn from it would be wrong. Under
  NORMAL locking, SQLite drops its whole page cache on every head move, so each uncached page
  costs one round trip when the speculative get hits and two when it misses, and a 500 KB
  table flatters that cost. Three candidate causes must stay separate: one storage process serving
  every page read, the VFS re-fetching pages after each head move, and this Mac.
  :: exit
  A measured partitions_count above one (or a stated reason it stayed at one), and the M=8
  reader ratio on the feed-shaped table with its confounds stated.
  :: decision
  - Build a 50-200 MB table with the challenge's schema shape (schema.sql: users, posts, likes)
    and run a feed-shaped query against it.
  - Before reading any result, record cluster.data.partitions_count and the per-role query
    counters from status json, and read per-process CPU as deltas of cputime, never ps %cpu.
  - Repeat the M=1 and M=8 pair cells, three repeats, under the pre-registered reading rule in
    PROTOCOL.md.
  - Report a measured partitions count above one, or a stated reason it stayed at one, and the
    M=8 reader ratio with its confounds stated.
  - Any change to fdb_vfs.c goes on a dev/ branch of datasource-store with a probe that fails
    without it, and only after this question is answered.
  :: related
  - RFD66606-2473, the single-writer baseline the pair ratios divide by.
  - RFD66606-2474, the companion WSL-desk run that separates the Mac from the cluster.
  """
end
