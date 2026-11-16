# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1058, "Zero trust networking", :published do
  scope "`weftspun_studio/`, `scripts/deploy-weftspun-quadlet.sh`"
  attest_in :none

  prose ~S"""
  :: hook
  weftspun_studio and its CockroachDB host run as Podman Quadlets on loopback-only ports.
  :: intrigue
  A perimeter firewall is not a boundary here. The router and the database run on the same
  host as every other process the operator runs.
  :: exit
  Run `sudo bash scripts/deploy-weftspun-quadlet.sh`; the sections below hold the verified status.
  :: decision
  Run weftspun_studio and its CockroachDB host as Podman Quadlets. A
  Quadlet is a `.container`, `.volume`, `.network`, or `.build` file.
  `podman-system-generator` reads it and writes a systemd service.

  Write no hand-written `.service` file. Each unit here is a Quadlet
  file under `weftspun_studio/deploy/quadlet/`.

  See `DETAILS.md` for the two zero-trust mechanisms, and why
  CockroachDB replaces the ZooKeeper Manta's metadata tier needed. It
  also covers the two images, the migrate-before-serve entrypoint, two
  boot bugs this RFD found and fixed, the deploy command, and the
  verified status.
  :: related
  RFD66606-1019 gives the API server, and RFD66606-1020 pins the CockroachDB build.
  RFD66606-1037 gives the taskweft job/task split. RFD66606-1055 selects Docker
  images, on this box first. RFD66606-1057 tracks what is still open.
  RFD66606-1073 put an S3 server on the Fly toplevel this RFD's loopback rule
  governed.
  """

  details_title "Zero trust networking"

  prose ~S"""
  :: details Why the deploy shape
  RFD66606-1055 selects plain Docker images, on this box first. The router
  and the CockroachDB host need a deploy shape on this box too, the
  single 4090 RTX box this project develops on.
  :: details Zero trust, in this deployment
  Zero trust denies a request by default. It grants access by
  identity and by context, not by network position. The two
  mechanisms below give that here.

  **A private network per deployment.** `weftspun.network` joins the
  `weftspun` and `weftspun-crdb` containers. No other container reaches
  either one by name.

  **No port past the loopback address.** Each `PublishPort` binds
  `127.0.0.1`. A process on this host reaches the API or the database,
  and a process on the network does not. CockroachDB runs `--insecure`
  inside `weftspun-crdb`, and that is safe only because of this bind.
  `deps/cockroach_local`'s own foreground task warns that `--insecure`
  fits a developer machine. On a single box with loopback-only ports,
  this container plays that same narrow role.

  SeaweedFS fronts object storage with the S3 API (operator, 2026-11-16). A future worker
  may read model weights over S3. It would reach SeaweedFS on its own bound port, under the
  same rule as this section. No port goes past loopback unless a remote caller needs it, and
  then only that one port.

  RFD66606-1073 once ran `versitygw` on the Fly toplevel, colocated with `weftspun_studio`
  on `127.0.0.1:10000`. The operator rescinded versitygw on 2026-11-16, and RFD66606-1079
  had already removed it. Fly's Tigris and Cloudflare's R2 stay as the hosted S3 stores.
  :: details CockroachDB replaces the Manta metadata tier's ZooKeeper
  Mark Cavage and David Pacheco's ["Bringing Arbitrary Compute to
  Authoritative Data"](https://queue.acm.org/detail.cfm?id=2645649)
  (ACM Queue, 2014) describes Manta, Joyent's object store with
  in-place compute. Two parts of that design carry over here.

  Manta's metadata tier shards PostgreSQL, fronted by a key/value
  layer named Moray. A crashed primary needs a new one, chosen by
  leader election. Manta wrote that election on top of ZooKeeper,
  because PostgreSQL holds no leader election of its own.

  CockroachDB holds Raft consensus and leader election inside the
  database. `weftspun-crdb` needs no ZooKeeper, and no Moray, for the
  same failover Manta built by hand.

  Manta isolates each compute task in its own OS zone, and it rolls
  that zone back between jobs. A Podman Quadlet container is this
  project's equivalent. It gives one container per service, its own
  network namespace, and its own file system. `podman build` tears
  each one down and rebuilds it from the image. RFD66606-1037's taskweft
  domains give the job/task split Manta's supervisor and agent gave.
  The Quadlet gives the isolation Manta's zone gave.
  :: details The images
  `weftspun_studio/Dockerfile` builds the `weftspun_container` release
  (`mix.exs`). It is a plain `mix release` with no Burrito step.
  Burrito wraps a release for a host with no Elixir and no Erlang.
  Inside a container the image is already that unit, so wrapping it
  again would add a Zig build step for nothing. The bare-metal Burrito
  release (`weftspun`, same `mix.exs`) still exists for a host with
  no Podman.

  `weftspun_studio/deploy/Dockerfile.crdb` builds CockroachDB from the
  V-Sekai 22.1 binary `deps/cockroach_local` downloads. It does not
  use the stock Docker Hub image, so the container matches the version
  RFD66606-1020 already pins.
  :: details Migrate before serve, inside the container
  `weftspun_studio/deploy/docker-entrypoint.sh` runs
  `WeftspunStudio.Release.create/0`, then `migrate/0`, then execs the
  server. No second Quadlet runs the migration as a oneshot step. The
  entrypoint does it, so the deployment stays to Quadlet-managed
  containers only.

  `Release.create/0` is new. `Ecto.Migrator.with_repo/2` connects to a
  database. It does not create one. A first boot against an empty
  CockroachDB node failed with `invalid_catalog_name` before this
  function existed. `storage_up/1` is idempotent, so the entrypoint
  calls it every start.
  :: details Two boot bugs this RFD found and fixed
  Building and running the images surfaced two faults in
  `WeftspunStudio.Application`. Neither ran before this RFD. RFD66606-1057
  marks the Burrito binary "written, and never run." The container
  path was the first real boot of either fault.

  **The halt-after-boot bug.** `application.ex` ran
  `WeftspunStudio.CLI.main(argv())` and halted whenever `RELEASE_NAME`
  was set, with no check for empty argv. A standard Elixir release
  sets `RELEASE_NAME` and passes no argv on `bin/APP start`. A normal
  release start therefore halted the node right after it booted. The
  Burrito binary never hit this fault, because Burrito's own launcher
  sets `__BURRITO_RELEASE_NAME`, not `RELEASE_NAME`, so `release?()`
  read false there by accident. The fix checks for non-empty argv too,
  so `db migrate` still reaches the CLI and a bare `start` does not.

  **The `Mix.env/0` crash.** `serve?()` called `Mix.env()` to skip the
  HTTP listener in tests. Mix ships with the compiler, not with a
  release, so a released node crashed at boot with
  `UndefinedFunctionError`. The fix guards the call with
  `Code.ensure_loaded?(Mix)`, the same pattern `argv/0` already used
  for `Burrito.Util.Args`.
  :: details Deploy
  ```bash
  sudo bash scripts/deploy-weftspun-quadlet.sh
  ```

  The script syncs this repository to `/opt/weftspun/src`, the fixed
  path the `.build` Quadlets read a `Containerfile` from. It installs
  the Quadlet files to `/etc/containers/systemd/`, and it starts
  `weftspun.service`. `weftspun.service` requires
  `weftspun-crdb.service`, so one command brings up both. The API
  answers at `http://127.0.0.1:4001`. See Verified, below, for why
  4000 is not the port.
  :: details Verified, on this box, through the real Quadlet path
  `scripts/deploy-weftspun-quadlet.sh` ran as root.
  `podman-system-generator` turned all six Quadlet files into
  `.service` units. `systemctl status` shows both `weftspun-crdb.service`
  and `weftspun.service` as `active (running)`, not merely built.
  `curl http://127.0.0.1:4001/api/v1/health` and `/api/v1/models`
  both answered, over the Quadlet-managed container, with no Postgrex
  error in the journal. The app reached CockroachDB by container name
  (`weftspun-crdb`) over `weftspun.network`.

  Two host-specific faults surfaced only at this last step, past what a
  direct `podman run` (this RFD's first verification pass) reached.

  **Rootful Podman's bridge network could not reach the internet on
  this host. The kernel dropped it, and DNS was not the cause.**
  `weftspun-crdb-build.service` failed inside `apt-get update`, timing
  out on every mirror. DNS was the first suspect (`--dns=1.1.1.1`,
  still set on both `.build` units). It did not fix the failure.
  `sudo nft list ruleset` showed why.

  Docker's installer wrote a `FORWARD` chain with `policy drop`. Only
  two chains it jumps to accept anything: `ts-forward` (Tailscale) and
  `DOCKER-FORWARD`, which itself drops everything not on `docker0`.
  Podman's netavark bridge for `weftspun.network` is neither, so the
  host dropped every packet the build container sent outbound before
  it left the host. Rootless Podman never hit this chain. It routes
  through slirp4netns/pasta in user space, not the kernel bridge/forward
  path rootful Podman uses. That is why the same Dockerfiles built
  cleanly under rootless Podman earlier in this session.

  `DNS=1.1.1.1` on both `.build` units, scoped to the build container
  only, is the change on record. `sudo nft list ruleset` today shows
  no accept rule added for the `weftspun` bridge subnet, and the
  `FORWARD` policy this section describes is still `drop`. A later
  `deploy-weftspun-quadlet.sh` run built both images and started both
  services, and `systemctl status` confirms both `weftspun.service`
  and `weftspun-crdb.service` run today. This RFD records that
  outcome. It does not claim to explain why the DNS change alone was
  enough on a retry, when it was not enough on the first attempt.

  A host-wide `nft` `FORWARD` change may still be the more durable
  fix. Confirm `systemctl status weftspun.service` and `systemctl
  status weftspun-crdb.service` show `active (running)` after any
  future rebuild, the same caution RFD66606-1057 gives the dev container
  and the Pixal3D worker stage.
  :: details The problem
  Trust must come from isolation, not from network position.
  """
end
