# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2417, "GitHub activity stays in our two organisations", :discussion do
  flight_level :l2
  scope "which GitHub organisations our activity may touch, and how pushed text cites upstream."

  prose ~S"""
  :: hook
  All GitHub activity stays in V-Sekai-fire and chibifire-stages, and upstreams hear nothing from
  us.
  :: intrigue
  An `owner/repo#N` reference or an issue or pull request URL in pushed text is posted back onto
  the upstream's timeline.
  :: exit
  Check a push against the rule: cite an upstream change by its bare commit SHA.
  :: decision
  - All GitHub activity stays in V-Sekai-fire and chibifire-stages: forks, new repositories and
    pushes, and no pull request, issue, comment or mention in any other organisation.
  - Pushed text cites an upstream change by its bare commit SHA, never by an `owner/repo#N`
    reference or an issue or pull request URL.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "GitHub activity stays in our two organisations"

  prose ~S"""
  :: details Reading is fine
  Reading and cloning public repositories is fine.
  :: details The problem
  GitHub posts those back onto the upstream's timeline.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2417", :provides, "github-two-orgs-only"
    relate "rfd-2417", :provides, "upstream-cited-by-bare-sha"
  end
end
