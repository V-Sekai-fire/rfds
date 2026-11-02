# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2414, "no workflow or background subagent runs unless the operator asks", :discussion do
  flight_level :l2
  scope "when a workflow or background subagent may run."

  prose ~S"""
  :: hook
  No workflow or background subagent runs unless the operator asks for one.
  :: intrigue
  Does a workflow or background subagent start on its own, with no operator asking for it?
  :: exit
  Before starting a workflow or background subagent, check that the operator asked for it.
  :: decision
  No workflow or background subagent runs unless the operator asks
  for one.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "no workflow or background subagent runs unless the operator asks"

  prose ~S"""
  :: details Where the rule lived
  The rule is one sentence from the section "How a desk works" of RFD66606-2294.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2414", :provides, "operator-asked-runs-only"
    relate "rfd-2414", :is_a, "workspace-policy"
  end
end
