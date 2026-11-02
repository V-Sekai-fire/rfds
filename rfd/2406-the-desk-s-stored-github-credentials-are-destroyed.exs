# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2406, "the desk's stored GitHub credentials are destroyed", :discussion do
  flight_level :l1
  scope "which GitHub credentials the desk destroys, and how to check."

  prose ~S"""
  :: hook
  The desk keeps no stored GitHub credentials once the manifest repository and avatar links exist.
  :: intrigue
  A login or token left on the desk lets anything there reach GitHub, and none of them is in
  1Password.
  :: exit
  Run `security dump-keychain | grep github-app-4890712` and `gh auth status` on the desk: the
  first prints nothing and the second reports no account.
  :: decision
  The desk's stored GitHub credentials, none of them in 1Password, are destroyed once the manifest
  repository and the avatar links exist. The Bao agent bundle in `~/.bao-creds` is not a GitHub
  credential and stays. Anything that needs GitHub after that is a release workflow, not the desk.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the desk's stored GitHub credentials are destroyed"

  prose ~S"""
  :: details What is destroyed
  - the `gh` keyring login (`gh auth logout -h github.com -u 'v-sekai-fire-persona[bot]'`),
  - the cached installation tokens and their expiries (`security delete-generic-password -a
    github-app-4890712 -s github-app-token-<org>` and `github-app-token-expiry-<org>` for each
    org),
  - the App private key if the retired path left one (`-s github-app-private-key`),
  - and `gh-installation-token.keychain-jwt.bak`.

  :: details Check
  Check: `security dump-keychain | grep github-app-4890712` prints nothing and `gh auth status`
  reports no account.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2406", :provides, "desk-github-credentials-destroyed"
  end
end
