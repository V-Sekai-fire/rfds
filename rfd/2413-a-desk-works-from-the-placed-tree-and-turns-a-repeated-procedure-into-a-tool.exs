# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2413,
    "a desk works from the placed tree and turns a repeated procedure into a tool",
    :discussion do
  flight_level :l2
  scope "where a desk works, and what a repeated procedure becomes."

  prose ~S"""
  :: hook
  A desk works from the placed tree and turns a repeated procedure into a tool.
  :: intrigue
  A procedure a desk repeats as one-off shell is lost, where an Elixir DSL or a tool in the tree
  stays.
  :: exit
  Check a repeated procedure against the rule: write it as an Elixir DSL or a tool in the tree,
  not one-off shell.
  :: decision
  - An agent works from the placed tree, and branches where a pin is old.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a desk works from the placed tree and turns a repeated procedure into a tool"

  prose ~S"""
  :: details How a desk works
  A procedure a desk repeats becomes an Elixir DSL or a tool in the tree rather than
  one-off shell.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2413", :provides, "desk-placed-tree-tooling"
  end
end
