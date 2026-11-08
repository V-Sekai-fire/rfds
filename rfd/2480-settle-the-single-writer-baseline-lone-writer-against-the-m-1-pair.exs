# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2480,
    "Settle the single-writer baseline: lone writer against the M=1 pair",
    :prediscussion do
  feature "the lone-writer baseline that every pair-matrix ratio divides by gets measured."

  scope "the scratch FoundationDB cluster's contention benchmark and PROTOCOL.md."

  prose ~S"""
  :: hook
  Why did the M=1 pair writer run about 142 commits/s at max rate, when a lone writer ran
  90-114 commits/s in every other run?
  :: intrigue
  Every "ratio to M=1" in the pair matrix divides by the lone-writer baseline. The 0.68-0.73
  bend seen at M=4 and M=8 may be mostly an inflated denominator: pairs at M=4 and M=8 ran
  98-101 commits/s, the same as a lone writer. See the details for the logs behind both
  figures. A Mac power-state or clock effect is a hypothesis, untested.
  :: exit
  A table in the repo, built from the log files, giving min, mean and max commits/s for the
  lone writer and the M=1 pair across the alternating cycles, plus a one-line PROTOCOL.md
  amendment naming which baseline the pair ratios use.
  :: decision
  - Alternate the lone writer and the M=1 pair back to back, three cycles, on the same
    4-process scratch cluster (never port 4700), same 15 s cell length, using mac/contention.c
    and mac/scratch-fdb.sh. Record load average, writer p50 and p99, and commits over 100 ms.
  - Fixed before the run: if the lone writer and the M=1 pair land within 10% of each other,
    call it no effect, and recompute every pair ratio against the lone-writer figure.
  - Fixed before the run: if they land outside 10%, name the cause before any ratio is quoted.
    Run a CPU-burner control, an idle-core spinner next to a lone writer, and require it to
    move the lone writer's rate; if it cannot, drop the power-state hypothesis.
  - Ship a table in the repo (min/mean/max over the cycles) and one line in PROTOCOL.md
    stating which baseline the pair ratios use. If the cause is not found, mark it
    undetermined rather than guessed.
  :: related
  - RFD66606-2474, the companion WSL-desk run that separates the Mac from the cluster.
  """

  details_title "Settle the single-writer baseline: lone writer against the M=1 pair"

  prose ~S"""
  :: details The logs behind both figures
  results-contention-matrix4.log (commit 1b6db4e) shows the M=1 pair writer at 141.8-142.0
  commits/s across three repeats at max rate. Lone-writer runs on the same scratch cluster
  shape read lower: results-contention-matrix2.log gives 98.7-106.9 commits/s with stores=1;
  results-contention-matrix3.log (482974a) gives 89.7, 100.7 and 98.5 commits/s; and
  results-contention-matrix5.log (6be7ddb), a bare libfdb_c loop at N=1, gives 106.5-113.5
  commits/s. The first matrix on a one-process cluster showed the same jump: 111 commits/s
  alone, 150 with 2 readers.
  """
end
