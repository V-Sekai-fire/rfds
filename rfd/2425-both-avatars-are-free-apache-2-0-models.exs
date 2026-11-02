# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2425, "both avatars are free Apache-2.0 models", :discussion do
  flight_level :l1
  scope "the two avatars, their licence and their repositories."

  prose ~S"""
  :: hook
  Both avatars are free original models under the Apache-2.0 licence, each in its own repository.
  :: intrigue
  Each avatar ships with its own licence file and a Unity humanoid bone map of 53 roles.
  :: exit
  Check a new avatar against the rule: its own repository holds the licence file
  and the 53-role map.
  :: decision
  - Both avatars are free original models under the Apache-2.0 licence, each in its own repository
    with its licence file and its Unity humanoid bone map (53 roles).
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "both avatars are free Apache-2.0 models"

  prose ~S"""
  :: details The two repositories
  The headset player is &{repo("character-mille-mire-feuille")}. The desktop player is
  &{repo("character-marocchino")}.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2425", :provides, "apache-avatar-pair"
    relate "rfd-2425", :is_a, "avatar-pipeline"
  end
end
