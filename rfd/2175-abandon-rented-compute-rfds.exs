# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2175, "Abandon RFDs whose decision uses blocklisted rented compute", :published do
  feature "documentation retraction"
  scope "RFD66606-1132, RFD66606-1140, RFD66606-1163, RFD66606-2133, RFD66606-2138"

  prose ~S"""
  :: hook
  Five RFDs that name rented compute are abandoned and stay in the register.
  :: intrigue
  CLAUDE.md's hard constraint is "the local desktop GPU is the only compute; RunPod and Vast.ai
  blocklisted". Five open RFDs still name rented compute as their decision.
  :: exit
  Read RFD66606-2169 next, the companion walk-back of the same class.
  :: decision
  Abandon five RFDs (1132, 1140, 1163, 2133, 2138) whose decisions name RunPod or Vast.ai rented
  compute, which CLAUDE.md's hard constraint blocklisted when this was written. Each moves to
  `abandoned` alongside this document landing. The Compute rule re-allowed rented providers on
  2026-11-04; the five stay abandoned to keep the scope down.
  :: related
  Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1132,1140,1163},
  urn:oid:1.3.6.1.4.1.66606.1.2.{2133,2138}
  Anchor: CLAUDE.md's Compute hard constraint as it stood when this was written.
  Companion: RFD66606-2169 (studio-core abandonment), same class of walk-back.
  """

  details_title "Abandon RFDs whose decision uses blocklisted rented compute"

  prose ~S"""
  :: details The five
    RFD66606-1140  Rented GPUs on RunPod. Decision 'rented GPU work runs
              on RunPod' contradicts CLAUDE.md's RunPod blocklist.
    RFD66606-1132  Priority list of converted models. RunPod as serving
              interactor. Same contradiction.
    RFD66606-1163  The accelerator in the loops. 'flow runs on RunPod'.
    RFD66606-2133  The pool rents from the spot book. 'Rent single
              RTX 4090s from the vast.ai book'.
    RFD66606-2138  interactor-shuttle. Merges the spot-broker whose whole
              reason was renting vast.ai. Abandoned with 2133.
  :: details The problem
  The RFD's whole reason for existing contradicts the blocklist. The RFDs themselves stay in
  the register for citation, per CLAUDE.md's "retractions stay in place next to what they
  retract".
  """
end
