# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2142, "Zero-trust service TLS via OpenBao PKI", :discussion do
  compact_head true
  feature "mTLS on the bao listener and cert-based service auth"
  scope "weftspun-bao, spot-broker, weft-warp-burrito"
  attest_in :none

  prose ~S"""
  :: hook
  Services on 6PN authenticate to bao with a client certificate over TLS.
  :: intrigue
  Services on 6PN read secrets from bao over plaintext HTTP. The root token in
  1Password is for emergencies; sharing it with services is the credential distribution
  problem bao exists to solve.
  :: exit
  Before a service on 6PN logs in to bao, read RFD66606-2146 for the role and policy map it
  needs, and give it a client certificate.
  :: decision
  Implemented 2026-09-01; see RFD66606-2146 for the role/policy map.

  `DETAILS.md` carries the full text of this RFD.
  :: related
  RFD66606-2140 (bao on FDB), RFD66606-2141 (FDB TLS rotation).
  """

  details_title "Zero-trust service TLS via OpenBao PKI"

  prose ~S"""
  :: details Why a standalone root CA rather than an intermediate
  The FDB root CA key (`fdb-ca.chibifire.com`, SHA-256 fingerprint
  `89:20:69:EB:BF:AB:...`) was lost twice. The first loss is
  documented in RFD66606-2141. The second happened during this session:
  `op item create` returned item IDs that do not correspond to any
  persisted item. The `op item edit` path (updating an existing item)
  did persist. The failure mode is a biometric timeout that `op`
  reports as exit code 0 with an item ID in stdout.

  Chaining under the FDB CA would require the FDB CA key or another
  full cluster TLS rotation. Bao's PKI engine generates and stores
  its own root key internally, so no external CA key is needed.

  The two trust domains are separate by design: the FDB CA gates
  cluster membership (verify-peers rule
  `S.CN>=fdb-,S.CN<=.chibifire.com`), and bao's PKI gates service
  authentication to the secrets API.
  :: details Enabling the PKI secrets engine
  Note: the `ttl=87600h` (10 years) and `max_ttl=8760h` (1 year) below
  were retracted by RFD66606-2145 on 2026-09-01. Current guidance:
  `ttl=26280h` (3 years) on intermediates, `max_ttl=2160h` (90 days) on
  service leaves. The old values are kept where they stand so a reader
  following an older link sees the change; new deploys use RFD66606-2145's
  numbers.

      bao secrets enable pki
      bao write pki/root/generate/internal \
        common_name="svc-ca.chibifire.com" \
        ttl=87600h   # 10 years
      bao write pki/config/urls \
        issuing_certificates="https://weftspun-bao.internal:8200/v1/pki/ca" \
        crl_distribution_points="https://weftspun-bao.internal:8200/v1/pki/crl"
  :: details Issuing the bao listener cert
  Create a role for the listener:

      bao write pki/roles/bao-listener \
        allowed_domains="weftspun-bao.internal" \
        allow_bare_domains=true \
        max_ttl=8760h   # 1 year

  Issue the cert:

      bao write pki/issue/bao-listener \
        common_name="weftspun-bao.internal" \
        ttl=8760h

  The certificate, private key, and CA chain are returned in the
  response. Store the cert and key as Fly secrets
  `BAO_TLS_CERT_B64` and `BAO_TLS_KEY_B64`. Store the CA cert as
  `BAO_TLS_CA_B64` (needed by clients to verify the listener).
  :: details Enabling TLS on the listener
  Update `config-fdb.hcl`:

      listener "tcp" {
        address         = "[::]:8200"
        tls_disable     = false
        tls_cert_file   = "/bao/data/tls/listener-cert.pem"
        tls_key_file    = "/bao/data/tls/listener-key.pem"
        tls_client_ca_file = "/bao/data/tls/svc-ca.pem"
        tls_require_and_verify_client_cert = true
      }

  The entrypoint decodes `BAO_TLS_CERT_B64`, `BAO_TLS_KEY_B64`, and
  `BAO_TLS_CA_B64` to disk before starting bao, alongside the
  existing FDB client TLS material.
  :: details TLS cert auth backend
      bao auth enable cert
      bao write auth/cert/certs/spot-broker \
        display_name="spot-broker" \
        policies="spot-broker" \
        certificate=@svc-ca.pem \
        allowed_common_names="spot-broker.chibifire.com"

  Policy `spot-broker`:

      path "secret/data/vastai/*" {
        capabilities = ["read", "list"]
      }

  A service presenting a client cert with
  CN=spot-broker.chibifire.com signed by bao's PKI CA receives a
  token scoped to `secret/data/vastai/*` only. No root token leaves
  1Password.
  :: details Service onboarding: spot-broker
  1. Issue a client cert:

         bao write pki/roles/spot-broker \
           allowed_domains="spot-broker.chibifire.com" \
           allow_bare_domains=true \
           max_ttl=8760h

         bao write pki/issue/spot-broker \
           common_name="spot-broker.chibifire.com" \
           ttl=8760h

  2. Store cert/key as Fly secrets on spot-broker.

  3. The entrypoint authenticates to bao via TLS cert auth, receives
     a scoped token, reads `secret/data/vastai/api`, and exports
     `VAST_API_KEY`. The Elixir code is unchanged.

  4. Elixir services that need dynamic secret access (lease renewal,
     cert rotation) use `libvault` (hex.pm, 14k recent downloads).
     For a static bearer token like the Vast.ai key, an entrypoint
     curl is sufficient.
  :: details The gate
  The gate asserts two properties:

  1. A plaintext HTTP request to `weftspun-bao.internal:8200` is
     rejected (connection reset or TLS handshake error, not HTTP 200).
  2. A TLS request without a client cert, or with an expired cert,
     returns 403 (not 200).

  Both are negative controls. A gate that only checks "valid cert
  gets 200" passes when TLS is disabled entirely.
  :: details The 1Password `op item create` failure
  Three `op item create` calls during this session returned exit
  code 0 and printed item IDs:

  | returned ID                  | intended content         |
  |------------------------------|--------------------------|
  | jw6rvt6zvfbb7hrxfkdwp5cdg4  | FDB CA private key       |
  | 4jzyphsx2w64gvr2m475sm4f4q  | bao KV tls-anchor backup |
  | honp7pukafh4g62hycaa7anddm  | bao KV blobstore backup  |

  All three IDs return "isn't an item in any vault" on subsequent
  `op item get`. The `op item edit` call to existing item
  `d7fx6rayd6o43sie5joxinfyte` did persist; the difference is that
  `edit` updates an existing record while `create` allocates a new one,
  and the allocation silently fails when biometric authentication times
  out.

  This is the second loss of the FDB CA key. The first (RFD66606-2141)
  was a scratchpad cleanup; the second is a credential store that
  reported success without persisting.
  """

  details "From the README, moved here on 2026-09-07", ""

  prose ~S"""
  :: details Decision
  Implemented 2026-09-01; see RFD66606-2146 for the role/policy map.

  Bao's PKI secrets engine becomes a standalone root CA for service
  auth. The FDB CA (`fdb-ca.chibifire.com`) stays separate for
  cluster mutual TLS.

  1. Mount `pki/` and generate a root CA inside bao.
  2. Issue a listener cert; enable TLS on `:8200`.
  3. Enable the TLS cert auth backend. Each service presents a client
     cert signed by bao's PKI and receives a scoped token for its
     KV paths.
  4. Elixir services use `libvault` (hex.pm) as the vault client.

  **Gate:** bao rejects a plaintext request to `:8200`.
  **Negative control:** a request with no client cert, or with an
  expired cert, returns 403.
  :: details Problem
  Services on 6PN read secrets from bao over plaintext HTTP. The root
  token in 1Password is for emergencies; sharing it with services is
  the credential distribution problem bao exists to solve. Any 6PN
  neighbor can observe or modify traffic to the listener.

  The FDB root CA key is lost a second time (the replacement from
  RFD66606-2141 was stored via `op item create`, which returned an item ID but
  did not persist the item). Chaining under that CA is not possible
  without rotating FDB again.
  :: details Related
  RFD66606-2140 (bao on FDB), RFD66606-2141 (FDB TLS rotation).
  :: details The problem
  Any 6PN neighbor can observe or modify traffic to the listener.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2142", :provides, "bao-pki-service-tls"
    relate "rfd-2142", :spends, "bao"
    relate "rfd-2142", :spends, "x509-v3-cert-profile"
    relate "rfd-2142", :is_a, "security-control"
  end
end
