# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2458,
    "Declare the real alternatives between RFDs, so choice and backtracking show",
    :prediscussion do
  feature "the RFD generator treats a capability with several providers as a declared choice."

  scope "the rebac edge generator and the tuples it emits across the RFD corpus in rfd/*.exs."

  prose ~S"""
  :: hook
  Does a capability that several RFDs can provide ever get recorded as a real choice, with a
  preferred order and a fallback the planner can use when one provider fails?
  :: intrigue
  The generator already knows how to turn a capability with multiple providers into an
  alternative set, ordered by commit date, then publish date, then serial, and a planner that
  backtracks to the next provider when one fails. The idea was tested on one synthetic pair, but
  no capability in the RFD corpus today actually has two providers recorded, so the beta's own
  route never exercises the backtracking path it depends on.
  :: exit
  Run a research pass over the corpus and its neighbors, from titles and bodies only, to find
  capabilities with more than one stated provider, fallback, or rejected approach, and record
  each as a second `provides` edge in preference order.
  :: decision
  - Treat this as a research task before a code task: read the cone of RFDs named in the issue
    and their neighbors for stated alternatives, fallbacks, and rejected approaches.
  - Where two RFDs plausibly provide the same capability, add a second `provides` edge in
    preference order so the planner's backtracking has a real pair to exercise.
  - Candidate pairs raised by the issue, unverified until read: Tailscale versus an SSH tunnel
    for reaching Bao, standalone versus PC VR streaming for headset rendering, WSL libraries
    versus this Mac as the desktop client, and two RFDs that both claimed the same guest ELF
    double capability in an early drafting pass.
  - Until a pair is verified by reading both RFDs in full, no alternative edge should be
    committed.
  """
end
