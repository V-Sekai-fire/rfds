# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2140, "OpenBao on FoundationDB", :discussion do
  feature "FoundationDB as the storage backend for the secrets manager"
  scope "weftspun-bao on Fly.io; the OpenBao fork at weftspun/openbao"
  attest_in :none

  prose ~S"""
  :: hook
  OpenBao stores its data in FoundationDB again, restored from the Vault v1.14.8 backend.
  :: intrigue
  OpenBao dropped every storage plugin when it forked from Vault v1.14.x.
  :: exit
  Read RFD66606-2353 next for how Bao runs beside the FDB server on each machine.
  :: decision
  Restore the FoundationDB backend from Vault v1.14.8 (last MPL-2.0
  release), connecting to the existing weftspun-fdb cluster over 6PN.
  The port rewrites three interfaces that diverged after the fork:
  `ListPage`, interactive transactions (`BeginTx`/`BeginReadOnlyTx`
  with Commit/Rollback), and pins the FDB 7.3.79 Go binding
  (`headerVersion = 730`). Build tag `foundationdb`, `CGO_ENABLED=1`.

  Deployment files in weftspun/service-openbao. Bao runs beside the FDB
  server on each weftspun-fdb machine (RFD66606-2353) and reaches the cluster
  as a TLS client. Interface details and deploy measurements are in
  DETAILS.md.
  :: section Verification
  `bao status`: Storage foundationdb, unsealed. KV v2 at `secret/`,
  anchor creds written from weftspun-fdb over 6PN. Root in 1Password.
  :: related
  RFD66606-2109 (FDB as the store), RFD66606-2134 (cluster TLS).
  """

  details_title "OpenBao on FoundationDB"

  prose ~S"""
  :: details The three interface changes
  OpenBao's `physical.Backend` diverged from Vault's after v1.14.x.
  The port rewrites three sites.

  **ListPage.** Vault's `List(prefix)` returned all keys. OpenBao added
  `ListPage(ctx, prefix, after, limit)` to the interface. The FDB
  implementation uses a range query with `after` as a begin-selector
  offset and `limit` as the range option.

  **Interactive transactions.** Vault used a one-shot
  `Transaction([]*TxnEntry)`. OpenBao replaced it with `BeginTx` and
  `BeginReadOnlyTx`, each returning a `physical.Transaction` carrying
  Put/Get/Delete/List/ListPage/Commit/Rollback. The FDB port calls
  `db.CreateTransaction()` and wraps the result in a struct that tracks
  committed/readonly state and returns the canonical error sentinels
  (`ErrTransactionReadOnly`, `ErrTransactionAlreadyCommitted`,
  `ErrTransactionCommitFailure`). PostgreSQL's `transaction.go` was the
  reference for the shape.

  **Backend registry.** `internal/command/commands.go` gains one import
  and one map entry (`"foundationdb": physFDB.NewFDBBackend`), wired the
  same way file, inmem, raft, and postgresql are.
  :: details The binding version
  The FDB Go binding hardcodes a `headerVersion` that must match or
  exceed the C client's API version. The 2019 binding
  (`cd5c9d91fad2`, headerVersion around 520) crashed at startup with
  error 2203 against the FDB 7.3 C client. The 7.3.79 binding
  (`0074653ee011`, `headerVersion := 730`) resolved it. The Go pseudo-
  version is `v0.0.0-20260715201227-0074653ee011`.
  :: details The deploy
  Since 2026-10-13 Bao runs on the three `weftspun-fdb` machines, one HA
  instance beside each FDB server, at 512 MB each (RFD66606-2353). The image
  layers the Bao image's binaries and plugins onto the FDB server image,
  so the plugin catalog's hashes still match. Bao reads the server's own
  cluster file and presents the machine's FDB leaf as its client
  certificate, so it verifies the cluster with the rule the cluster uses.

  Listener binds `[::]:8200` (dual-stack). Each instance advertises its
  machine address (`<machine-id>.vm.weftspun-fdb.internal`) as `api_addr`
  and `cluster_addr`, so standbys forward to the active instance.
  Clients verify the listener as `weftspun-bao.internal`.

  The first deploy was a separate `weftspun-bao` app on one machine,
  built by `Dockerfile.fdb` with only the FDB client library. That app
  is stopped and kept for rollback until the operator retires it.
  :: details What the co-located fdbserver was, and why it moved
  The first deploy ran a single-node fdbserver inside the bao machine
  on the same volume. That worked for initialization but carried no
  redundancy, no backup, and no TLS. Moving to the cluster gives all
  three for free. The co-located entrypoint and the single-node config
  are kept in the repository's git history.
  :: details What the anchor creds cover
  Two KV v2 paths carry the FDB cluster's identity material:

  `secret/fdb/tls-anchor`: the CA certificate (base64 PEM), the
  cluster ID, and the verify-peers rule.

  `secret/fdb/blobstore`: the Tigris S3 credentials used by the FDB
  backup agents (AWS key pair, endpoint, region, bucket name).

  Both were written from a weftspun-fdb machine over 6PN, where the
  Fly secrets are available as environment variables.
  :: details The problem
  The weftspun-fdb cluster already runs three machines with
  double redundancy, TLS, and backup, and raft on a single shared-cpu
  machine has no replication path.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2140", :provides, "bao"
    relate "rfd-2140", :provides, "bao-fdb-storage-backend"
    relate "rfd-2140", :spends, "fdb-sqlite"
    relate "rfd-2140", :spends, "fdb-cluster-mutual-tls"
    relate "rfd-2140", :is_a, "deployment"
  end
end
