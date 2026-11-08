# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2459, "Review the AI-drafted token edges (provides, spends, owns, is_a)", :prediscussion do
  feature "an AI pass drafted provides/spends/owns/is_a edges for all open RFDs, unverified."

  scope "the rebac tuples embedded in rfd/*.exs and the ownership facts in RFD66606-2351."

  prose ~S"""
  :: hook
  Were the edges two AI agents drafted from each RFD's own text faithful to what each RFD
  actually asks for, or just internally consistent with each other?
  :: intrigue
  Two agent passes produced provides, spends, owns, and one is_a edge for each of the
  ninety-nine open RFDs: a hundred seventeen provides edges, a hundred fifty-six spends edges,
  and thirty-three owns edges. Those edges already pass checks for cycles, provider conflicts,
  and owner consistency, but passing a structural check is not the same as being true to the
  source text. About a dozen RFDs spend nothing at all, which likely means the agent could not
  pin down a real prerequisite rather than that the RFD truly has none, and a short route
  through the planner can hide a dependency that should have slowed it down.
  :: exit
  Read each of the roughly twelve RFDs that spend nothing and decide, by hand, whether a real
  prerequisite is missing; where one is found, add the spends edge and re-run the cycle and
  provider checks.
  :: decision
  - Review the drafted edges RFD by RFD rather than trusting the structural checks alone,
    starting with the dozen that spend nothing, since an empty spends list is the likeliest
    sign of a missed dependency.
  - Re-check the ownership and access facts recorded for RFD66606-2351, including the claim
    that it owns the store, fex, and the guest ELF double capability, since those facts were
    guessed rather than sourced.
  - Decide, separately, whether the bare repository name used for the private lab should become
    public, and record that decision once made.
  :: related
  - RFD66606-2351, the ownership and access facts under review.
  """
end
