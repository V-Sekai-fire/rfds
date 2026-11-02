# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2405, "the rung's setup uses a fixed set of credentials", :discussion do
  flight_level :l1
  scope "the credentials the rung's setup uses: the App, the Bao root token, Fly and the Frame."

  prose ~S"""
  :: hook
  The rung's setup uses a fixed set of credentials, each with one named use.
  :: intrigue
  The Bao root token is read from 1Password exactly once and never stored, and a 403 is logged
  and handed back rather than worked around.
  :: exit
  Check a new setup step against this list, and run the first `gh repo create` as the check of
  the App.
  :: decision
  - The App installation `v-sekai-fire-persona[bot]` creates the new repositories and sets their
    rulesets.
  - The Bao root token is read from 1Password with `op` exactly once, for `bao plugin register`,
    `bao secrets enable` and the `zone-fly` cert role, never stored.
  - Fly changes run in the personal org without asking: the app, the dedicated IPv4, and whatever
    `weftspun-fdb`'s checks say.
  - The Frame is `steamos@fire-s-frame.local`, given a `Host frame` block in `~/.ssh/config`
    first thing.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the rung's setup uses a fixed set of credentials"

  prose ~S"""
  :: details The App and the logbook
  The operator says the App installation can create the repositories and set their rulesets. The
  first `gh repo create` is the check, and a 403 is logged and handed back rather than worked
  around. The logbook records the three Bao commands and the plugin sha256.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2405", :provides, "fixed-setup-credentials-set"
    relate "rfd-2405", :is_a, "security-control"
    relate "rfd-2405", :spends, "bao"
    relate "rfd-2405", :spends, "fly"
  end
end
