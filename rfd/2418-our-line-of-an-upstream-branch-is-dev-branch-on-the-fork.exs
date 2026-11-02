# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2418, "our line of an upstream branch is dev/branch on the fork", :discussion do
  flight_level :l2
  scope "where our line of an upstream branch lives on the fork."

  prose ~S"""
  :: hook
  Our line of an upstream branch is `dev/<branch>` on the V-Sekai-fire fork.
  :: intrigue
  Would the upstream's branch-keyed workflows fire on our line, or could `main/<x>` sit beside
  `main`?
  :: exit
  Check that a new line of an upstream branch is named `dev/<branch>` and created at the
  upstream commit.
  :: decision
  - Our line of an upstream branch is `dev/<branch>` on the V-Sekai-fire fork, created at the
    upstream commit, so the upstream's branch-keyed workflows do not fire on it.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  prose ~S"""
  :: details The problem
  A branch named `main/<x>` cannot sit beside one named `main`, since git stores each ref as a
  path.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2418", :provides, "fork-dev-branch-naming"
  end
end
