# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2415, "test marks go only in test scenes", :discussion do
  flight_level :l2
  scope "where test marks may go."

  prose ~S"""
  :: hook
  Test marks go only in test scenes, so a scene that ships carries none.
  :: intrigue
  A test mark placed in a scene that ships stays in what ships.
  :: exit
  Check each new test mark against the rule: it goes in a test scene, never in a scene that ships.
  :: decision
  Test marks go only in test scenes, never in a scene that ships.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "test marks go only in test scenes"

  prose ~S"""
  :: details Where this came from
  This rule came out of How a desk works in RFD66606-2294.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2415", :provides, "test-marks-test-scenes-only"
    relate "rfd-2415", :is_a, "workspace-policy"
  end
end
