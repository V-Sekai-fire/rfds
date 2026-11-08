# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2481,
    "Separate this Mac from the cluster: bare commit loop on the WSL desk",
    :prediscussion do
  feature "the per-process bend and commit stalls get re-run on a non-Mac desk."

  scope "the scratch FoundationDB cluster's bare commit-loop benchmark and the WSL desk."

  prose ~S"""
  :: hook
  Do the per-process bend (N=8 at 0.68-0.73 of N=1) and the 100-730 ms commit stalls belong to
  the scratch cluster's commit path, or to this Mac?
  :: intrigue
  results-contention-matrix5.log (6be7ddb), a bare libfdb_c loop with no SQLite and no VFS,
  gives per-process commits/s at N=1, 2, 4, 8 of 106.5-113.5, 89.3-112.9, 90.5-101.1 and
  72.7-82.8; the ratio to N=1 at N=8 is 0.68-0.73. The SQLite pairs bent the same way, which
  clears the VFS for writes. See the details for the slow-commit and server-side evidence.
  :: exit
  The N=1/2/4/8 commit-rate and stall figures from the WSL desk, read against the fixed rule
  below and reported as measured.
  :: decision
  - Run mac/bare.c and mac/scratch-fdb.sh start 4 on the AlmaLinux desk through desk.py, three
    repeats at N=1, 2, 4 and 8, with the cluster formed as commit_proxies=1 grv_proxies=1 (the
    proxies=1 form is rejected).
  - Install libfdb_c and a Linux fdbserver and fdbcli on the desk from the engine release with
    checksums, since none are installed there yet. Stop the scratch servers when done, and
    check the claims board before using the desk.
  - Optional second arm: run the same loop on a RAM-disk cluster on the Mac.
  - Fixed before the run: if the desk shows the same bend and the same stalls, the cause sits
    in the cluster or commit path, and this Mac is cleared. If the desk is flat and
    stall-free, this Mac's disk or scheduler is implicated. Anything in between is reported
    as measured, with no cause named.
  :: related
  - RFD66606-2473, the single-writer baseline the pair ratios divide by.
  """

  details_title "Separate this Mac from the cluster: bare commit loop on the WSL desk"

  prose ~S"""
  :: details Slow commits and server-side evidence
  On a 4-process scratch cluster, three repeats, 15 s cells: slow commits over 100 ms
  clustered 24 times across the 12 cells, 14 touching more than one process and 10 touching
  one (8 at N=1, 2 at N=8). A lone writer stalled in 2 of 3 repeats (5 and 4 commits over
  100 ms), so sharing alone does not explain the stalls. Server CPU stayed near half a core,
  Ratekeeper said limited_by=workload throughout, and scratch trace logs held one SlowTask
  event in total and no disk-stall events. The scratch tlog shares the Mac's SSD with the
  production cluster; that is an untested candidate.
  """
end
