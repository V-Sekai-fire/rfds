# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2353, "Bao runs three replicas on the FDB machines", :discussion do
  scope "weftspun-bao and the weftspun-fdb machines it runs on."
  attest_in :details

  prose ~S"""
  :: hook
  Bao runs as three replicas, one beside each FDB machine.
  :: intrigue
  Bao was one machine, and every consumer now depends on it: every routine credential read,
  coordination write and policy check routes through Bao, so one outage stops them all.
  :: exit
  Deploy the image to the three weftspun-fdb machines one at a time and unseal each, then
  destroy the `weftspun-bao` app once the three serve.
  :: decision
  `ha_enabled = true`, coordinated over FDB (operator, 2026-10-13). The `weftspun-bao`
  app retires once the three instances serve. Superseded on 2026-11-01: Bao runs as one
  instance beside a single-node FDB cluster on one Fly machine, restored from the R2
  backup, with `ha_enabled = false` (operator, 2026-11-01).
  :: related
  RFD66606-2140, RFD66606-2144, RFD66606-2145, RFD66606-2146.
  Split from the old RFD66606-2147: RFD66606-2354 (unseal), 2355 (cache), 2356 (no CDN proxy).
  """

  details_title "Bao runs three replicas on the FDB machines"

  prose ~S"""
  :: details Why HA now, not before
  RFD66606-2140 chose `ha_enabled = "false"` when Bao was one machine and one
  operator. Under that arrangement, Bao being down meant one thing was
  down: the Bao API. Everything else routed around Bao by holding its
  credentials in Fly secrets or 1P.

  RFD66606-2146 turned that inside out. Every consumer now authenticates to
  Bao with its per-service cert, reads its credentials from Bao at
  runtime, and coordinates state through Bao's KV. When Bao goes down,
  the DNS-editing path goes down, the R2-write path goes down, the FDB
  coordinator info lookup goes down, and any new spend gate that
  follows the same pattern goes down with them. The single-machine
  posture that was fine as a convenience store is not fine as the
  switchboard.
  :: details Colocated on the FDB machines
  The operator chose on 2026-10-13 to run Bao on the three weftspun-fdb
  machines instead of in its own app. The Fly plan in use includes
  three `shared-cpu-1x` 256 MB machines and 3 GB of volumes; three FDB
  machines plus a separate Bao machine overran both, and the separate
  machine bought no redundancy. FDB keeps `double` redundancy and three
  coordinators, so one machine may still be lost.

  Each machine runs fdbserver, the backup agent, Bao, tailscaled and
  sshd, at 512 MB. Measured on 2026-10-13 at 256 MB: an FDB machine used
  about 130 MB, and the Bao machine about 130 MB, of which Bao was 77 MB,
  tailscaled 26 MB and the plugin 18 MB. The two together do not fit in
  the 207 MB a 256 MB machine leaves usable.

  - The `weftspun-bao` app retires once the three instances serve. Its
    volume held no secrets: Bao's storage is FDB, and the volume kept the
    tailnet identity, the SSH host key and renewed listener certificates.
  - Each instance advertises its own machine address as `api_addr` and
    `cluster_addr`, so standbys forward to the active instance. Standbys
    forward every read to the active instance.
  - Clients keep verifying the listener as `weftspun-bao.internal`; the
    name in the certificate does not move with the app.
  - One machine carries the existing tailnet state and keeps the
    `weftspun-bao` node; the others join under their own names.
  - The SSH tunnel port is balanced across all three machines, so they
    share one host key, held as a secret rather than generated per
    volume.
  - The change is proved on a throwaway three-machine app before
    weftspun-fdb is touched: an initialised test Bao, a secret written
    and read back, one machine restarted and unsealed while the others
    keep serving.
  :: details Replicas: 3 in sjc, coordinated over FDB
  OpenBao's FDB backend supports HA by leader election over the same
  storage the writes go to. One instance runs on each FDB machine, so
  Bao spreads across the same three zones FDB does.

  Standby replicas can either serve reads directly or forward every
  request to the leader. Read-serving standbys would suit the read/write
  ratio the cert-auth path establishes (many reads per one write); until
  the fork is shown to serve reads from a standby, standbys forward.

  The 3-machine scale exposes one wrinkle: three machines mean three
  seal states, three unseal calls per fleet restart. This is the reason
  auto-unseal stays the goal.
  :: details Migration path
  Enabling the replicas on the live cluster is:

  1. Update `service-openbao/config-fdb.hcl`: `ha_enabled = "true"`.
  2. Build one image carrying the FDB server and Bao, and deploy it to
     the three weftspun-fdb machines one at a time, unsealing each.
  3. Stop the `weftspun-bao` app, then destroy it once the three serve.
  :: details A desk reaches the active instance
  Read on 2026-10-16. The three instances elect one leader, and only the
  leader answers a login; a standby redirects to the leader's
  `<machine>.vm.weftspun-fdb.internal` address, which no desk resolves.
  Two of the three carried tailnet names that day (`weftspun-bao-3`,
  `weftspun-bao-4`), both unsealed standbys, and the leader, the third
  machine, had none, so a desk asking the tailnet found no
  leader and the desk helper exited without a word.

  The route that worked: read `sys/leader` from any instance (no token,
  mTLS only), take the machine id out of `leader_address`, and run
  `fly proxy 8200:8200 <id>.vm.weftspun-fdb.internal -a weftspun-fdb` as a
  background process. The desk then uses `BAO_ADDR=https://127.0.0.1:8200`
  with `BAO_TLS_SERVER_NAME=weftspun-bao.internal` and its agent
  certificate. The proxy exits on its own after some minutes; a
  `connection refused` on 127.0.0.1:8200 means restart it, not that Bao
  is down.

  The retired `weftspun-bao` app still exists, stopped. `fly proxy -a
  weftspun-bao` fails with `host was not found in DNS` because nothing
  runs there, and starting its machine brings up a second Bao against the
  same FDB storage, which stops again within a minute. It was started
  twice that day by mistake before the route above was found; it is not
  started again, and its deletion is an open item.
  :: details Sub-decisions open
  - Delete the retired `weftspun-bao` app and its volume, so a desk
    cannot start a second Bao by mistake.
  - Every instance joins the tailnet under its own name, or the leader's
    name is published where a desk can read it without a Fly login.
  - 3 replicas, one per FDB machine (operator, 2026-10-13).
  - Standbys serve reads (`disable_performance_standby = false`) vs
    forward to leader. Read-heavy workload argues for serving.
  - The FDB and Bao data machines run as one machine or as an HA set; the one-machine form
    relies on tested backups (operator, 2026-10-30).
  :: details Sources
  - OpenBao HA storage docs (FDB backend supports HA via leader
    election on the shared FDB cluster).
  - RFD66606-2140 (Bao on FDB, this raises its ambition), 2145 (leaf and CA
    rotation cadence this HA has to survive), 2146 (the capability
    topology this now underwrites).
  :: details The problem
  RFD66606-2140's `ha_enabled = "false"` fit that framing. RFD66606-2146 then moved every
  routine credential read, coordination write, and policy check onto Bao. Every consumer now
  depends on Bao being up, and RFD66606-2140's reliability budget is smaller than what routes
  through Bao now needs.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2353", :provides, "bao-single-fly-instance"
    relate "rfd-2353", :is_a, "deployment"
    relate "rfd-2353", :spends, "bao"
    relate "rfd-2353", :spends, "bao-fdb-storage-backend"
    relate "rfd-2353", :spends, "bao-cert-auth-role-map"
    relate "rfd-2353", :spends, "fdb-backup-r2-dr-tag"
    relate "rfd-2353", :spends, "fly"
    relate "rfd-2353", :spends, "tailscale"
  end
end
