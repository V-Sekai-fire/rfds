# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2403, "the zone reaches Bao by a certificate Bao issues", :discussion do
  flight_level :l1
  scope "how the zone's worker and server reach Bao, and who issues their certificate."

  prose ~S"""
  :: hook
  The zone reaches Bao by a client certificate that Bao itself issues.
  :: intrigue
  Every GitHub step needs a Bao tailnet node online, because the desk's own `gh` is an hourly
  installation token minted through Bao.
  :: exit
  Run `tailscale status` before a GitHub step to see whether a Bao tailnet node is online.
  :: decision
  - The worker and the server reach Bao over the private network at `weftspun-bao.internal:8200`
    with a client certificate from a new cert-auth role `zone-fly` whose policy is
    `sqlite-fdb/exec/zone-*` and `sqlite-fdb/query/zone-*` and nothing else. The players never
    reach Bao.
  - The certificate is issued by Bao itself: the org's intermediate CA (the chain in
    `~/.bao-creds/ca-chain.pem`, its key in 1Password) is installed into a `pki_int` mount from
    1Password with the root token, and the cert-auth role binds to the certificate's common name.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2142, whose shape the `pki_int` mount follows.
  """

  details_title "the zone reaches Bao by a certificate Bao issues"

  prose ~S"""
  :: details How the certificate is issued
  The intermediate CA is installed in RFD66606-2142's shape
  (`bao secrets enable -path=pki_int pki`, `bao write pki_int/config/ca pem_bundle=@-`
  from `op item get`, a role `zone-fly` limited to that common name and a 30-day TTL). The
  cert and key land as Fly secrets on `weftspun-zone`.

  :: details The desk's own gh
  The desk's own `gh` is an hourly installation token minted the same way
  (`gh-installation-token <org>` through `bao-mint-github` over
  Tailscale), so every GitHub step needs a Bao tailnet node online,
  which `tailscale status` says.

  :: details The catalog and the plugin
  &{repo("service-openbao")} ships the catalog
  (`schema "zone-*"`, `exec append_mutation`, `exec append_snapshot`,
  `query latest_snapshot`) and sets `BAO_SQLITE_FDB_CATALOG` and
  `BAO_SQLITE_FDB_CLUSTER`. The operator registers and enables the
  plugin once with the root token from 1Password and creates the role,
  both recorded in the logbook with the sha256 Bao was given.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2403", :provides, "zone-bao-client-cert-auth"
  end
end
