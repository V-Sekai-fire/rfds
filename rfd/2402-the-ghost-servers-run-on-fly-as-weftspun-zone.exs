# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2402, "the ghost servers run on Fly as weftspun-zone", :discussion do
  flight_level :l1
  scope "the weftspun-zone Fly app, the existing machines it joins, and its check."

  prose ~S"""
  :: hook
  The ghost servers run on Fly as the weftspun-zone app, with no GPU and no public TCP.
  :: intrigue
  `backup_fresh` and `backup_fresh_dr` are critical on all three `weftspun-fdb` machines, so the
  backups are unverified before the journals depend on the cluster.
  :: exit
  Run `fly checks list -a weftspun-zone` and check that all checks pass, then run `fly machine
  run`
  of the image with `--mode=server` and check that it reaches Bao.
  :: decision
  - A new app, `weftspun-zone`, from a new repository
    &{repo("service-zone")}: a Containerfile that
    takes the Linux x86_64 double headless engine, the addon's double
    `.so`, and the pen at the release tag, and runs
    `godot --headless --path pen --script tools/zone_main.gd` with a `--mode=<server|worker>`
    argument after the script separator. A
    `fly.toml` with two process groups, `server` (zone 0 and `ca.elf`,
    `shared-cpu-1x`) and `worker` (zone 1, the ghost, `shared-cpu-2x` for
    the CPU fallback), a UDP service on a dedicated IPv4 that the host
    binds at `fly-global-services`, and no public TCP.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2403, where the worker and the server reach Bao.
  """

  details_title "the ghost servers run on Fly as weftspun-zone"

  prose ~S"""
  :: details The existing machines
  The operator on 2026-09-30: `weftspun-fdb`, three `shared-cpu-2x`
  machines in `sjc` with 1 GB volumes (`cluster_health` passing on all
  three; `backup_fresh` and `backup_fresh_dr` critical on all three
  with `connect: connection refused`, the backup-freshness probe of
  &{file("datasource-store", "fly/backup-fresh.sh")} not answering, so the
  backups are unverified and that service is brought back and checked
  before the journals depend on the cluster), and `weftspun-bao`, one `shared-cpu-1x` in `sjc`
  with a dedicated IPv6, OpenBao on FoundationDB storage, mutual TLS on
  8200, a Tailscale sidecar, and the `sqlite-fdb` and GitHub plugins
  built into the image under `/bao/plugins` and left unregistered. None
  of them has a GPU, and none will.

  :: details The clients that have GPUs
  The clients are what have GPUs: the Frame's Adreno and this Mac's
  M2 Pro. Both render, both run `curvenet.elf` on compute-rd for their
  own drawing (Vulkan on the Frame, Metal here), and the Mac is the
  worker's sidecar. The round trip
  from the Frame to `sjc` is measured and logged beside the Wi-Fi
  numbers already in `logbook-steam-frame-sizing.md`. Pose and voice
  datagrams at 50 to 90 Hz sit inside it or the rung says so.

  :: details Check and controls
  Check: `fly machine run` of the image with `--mode=server` reaches
  Bao (`bao token lookup` under the role's cert) and the two-client
  gate passes with the headset and the desktop as the clients against
  the Fly address. Xfly checks list -a weftspun-zone` is all passing.
  Controls: the image with the role's key swapped for the desk agent's
  is refused by Bao's listener. A `zone-2` database name is refused by
  the policy. The UDP service with the bind on `[::]` instead of
  `fly-global-services` receives nothing, confirming the bind
  matters.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2402", :provides, "fly"
    relate "rfd-2402", :provides, "weftspun-zone-ghost-servers"
  end
end
