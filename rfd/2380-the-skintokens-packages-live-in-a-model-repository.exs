# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2380, "the SkinTokens packages live in a model repository", :discussion do
  flight_level :l2
  scope "where the SkinTokens viewer's packages ship, and how an upload is checked."

  prose ~S"""
  :: hook
  The SkinTokens viewer's packages ship from a public model repository, checked by hash.
  :: intrigue
  Each package holds the rig model and is about 1.3 GB, more than a Space can hold. Which files
  do visitors get, and who decides when they change?
  :: exit
  Check each upload by comparing the repository's file hashes with the package's `SHA256SUMS`,
  and change the Space page's SHA-256 lines in the same pass.
  :: decision
  - The packages are files of a public model repository on Hugging Face, and the auto-rig Space
    links that repository's `main`.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "the SkinTokens packages live in a model repository"

  prose ~S"""
  :: details Dev releases
  A dev release puts the same files on its `dev` branch, so visitors keep the files on `main`
  until the operator promotes it (operator, 2026-10-18).
  :: details The problem
  The SkinTokens viewer's packages hold the rig model, about 1.3 GB each, more than a Space can
  hold.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2380", :provides, "skintokens-model-repo-packages"
  end
end
