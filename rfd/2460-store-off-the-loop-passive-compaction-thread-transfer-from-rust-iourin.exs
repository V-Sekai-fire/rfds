# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2460,
    "Store: off-the-loop passive compaction thread (transfer from rust-iouring-kensac)",
    :prediscussion do
  feature "the store's compaction moves off the write loop onto its own passive, timed thread."

  scope "the store's fold and compact path in fdb_vfs.c, ported from a challenge submission."

  prose ~S"""
  :: hook
  Can the store's compaction run on its own thread, on a timer, so a write caller never pays a
  fold's cost on its own latency?
  :: intrigue
  A winning entry in an outside challenge, rust-iouring-kensac, already runs its checkpoint and
  compaction off the write loop on a second, low-priority thread, so write callers never wait on
  it. The store's compaction today is demand-driven: a call to weft_compact_due blocks whichever
  caller happens to ask for it. That is exactly the kind of tail latency a day-long benchmark is
  built to catch, since it measures the slowest save a day reaches rather than a p99.
  :: exit
  Add a dedicated, nice'd compaction thread on its own FoundationDB connection, and measure
  whether a planted burst of writes still shows a fold cost on the write caller's own latency.
  :: decision
  - Add a dedicated, lower-priority compaction thread that opens its own FoundationDB connection
    and runs folds passively on a timer once the log grows past a threshold, instead of folding
    on demand inside the caller's path.
  - Change weft_compact_due from a blocking fold into a cheap call that wakes the thread when the
    log is already short, so the write loop never performs the fold itself.
  - Bound the hold time the compaction thread may take per pass, following the referenced
    entry's bound of at most 250 milliseconds, so passive compaction cannot itself become a
    tail-latency source.
  - Verify the change against the existing day-long benchmark that measures the slowest saves a
    day reaches, not only the median or the p99.
  """
end
