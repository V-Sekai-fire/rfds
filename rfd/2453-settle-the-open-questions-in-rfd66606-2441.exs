# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2453, "Settle the open questions in RFD66606-2441", :prediscussion do
  feature "a GitHub job reads its secrets from Bao with no stored credential, pending rulings."

  scope "RFD66606-2441's open questions on the Bao listener, Tailscale scope, keys and claims."

  prose ~S"""
  :: hook
  Can a GitHub job authenticate to Bao with no stored credential while RFD66606-2441's four
  open questions remain unresolved?
  :: intrigue
  RFD66606-2441 leaves four questions open, and the listener question decides the others. A job
  carries no client certificate, so the Bao listener's request for one before login needs an
  answer: accept the request without requiring it and lean on the tailnet access list as the
  transport gate, or give the endpoint a second listener. Either path weakens or splits the
  second factor of RFD66606-2195, so the choice is not neutral. Three more questions hang on
  the listener's answer: how far the Tailscale identity's scope reaches, where Bao gets
  GitHub's signing keys, and which claims fix a role.
  :: exit
  Rule on the listener question first, then write a gate with its control for each of the
  remaining three questions.
  :: decision
  - Rule on the Bao listener question before the other three, since the other answers depend
    on it (proposed).
  - For each of the four questions, record the ruling and a gate with its control in
    RFD66606-2441 (proposed).
  - Decide whether Bao fetches GitHub's signing keys live or holds a static set someone
    refreshes (proposed).
  - Decide which claims fix a role: repository, ref, environment and workflow, in some
    combination (proposed).
  :: related
  - RFD66606-2441, the open questions this settles.
  - RFD66606-2195, the second factor the listener choice affects.
  """
end
