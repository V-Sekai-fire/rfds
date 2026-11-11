# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2293, "the Skateboard's workspace, and the first rung's plan", :discussion do
  feature "RFD66606-2287's first rung, from a hand-built headset run to a session on the Frame"
  scope "a new skateboard manifest, the pen, the double build, and the rung's guests"

  prose ~S"""
  :: hook
  The first rung gets a manifest of its own and eight steps that ship as four releases.
  :: intrigue
  The rung ran once in the headset at 72 fps from a build made by hand outside every
  repository, with no zone, no CA and no voice.
  :: exit
  Read RFD66606-2287 next for the rung this plan builds.
  :: decision
  A new manifest,
  &{repo("contract-manifest-skateboard", planned: "2-contract")}, places
  only the rung's repositories with gates and bootstrap copied from the taskweft
  manifest. Eight steps land as four releases (dev, beta, rc, released),
  each playable on the Steam Frame through the Windows double build.
  Zones run as ghost servers on Fly's headless Linux double build. GPU
  stages run on a sidecar client. Every guest runs natively translated.
  :: related
  - RFD66606-2262, the ladder; RFD66606-2287, the rung; RFD66606-2263, the simulator gate.
  - RFD66606-2296, dev.2; RFD66606-2297, dev.3; RFD66606-2298, dev.next.
  - RFD66606-2256, the transport; RFD66606-2288 and RFD66606-2291, the capabilities.
  - RFD66606-2289, a placement is the manifest row; RFD66606-2142, the Bao PKI.
  - RFD66606-2382 to RFD66606-2412, the pieces of this plan, one RFD each.
  """

  details_title "the Skateboard's workspace, and the first rung's plan"

  prose ~S"""
  :: details Operator decisions
  - The out-of-band channel for the session root DER (a launch argument
    is the default).
  - Whether the taskweft manifest gets a row pointing at the new one,
    or is left untouched.
  - Which rulesets the new repository carries beyond the manifest's
    six contexts.
  - Fly: the dedicated IPv4 for the UDP service, the region (`sjc`,
    where Bao and FoundationDB are), the machine sizes, and who holds
    the root token for the one-time plugin registration and the
    `zone-fly` role.
  - The wineopenxr tweak in `proton-xrfix`, if the diff on the Frame
    does not explain itself.
  :: details The release ladder: dev, beta, rc, released
  The work lands as four releases, each a whole playable build before
  the next starts, in RFD66606-2262's sense: a person
  puts it on and does the thing it claims. A release is a tag on
  &{repo("transport-meshing-pen")} (`v<date>-dev.N`, `-beta.N`, `-rc.N`, then
  `v<date>`), a GitHub release on the pen carrying the rung's double
  engine and addon, the ELFs and their sha256s, a playtest recorded on
  the rung's platform (on the Frame, the release uploaded to the
  headset as a development title and played by a named person; on
  macOS, the persona locomotion run below), and every gate of the
  release green with its control, logged
  in `logbook-rfd2287-rung.md`. A
  release that is not playable is not cut. The Windows build is what
  climbs on the Frame. The headless Linux build is what the ghost
  servers run on Fly from rc on. Only the Frame's own Linux path is
  logged without gating.

  **dev.1** is RFD66606-2408, **dev.2** is RFD66606-2296, **dev.3** is RFD66606-2297 and
  **dev.next** is RFD66606-2298. RFD66606-2407 holds the macOS playtest that dev.1 and dev.2
  share,
  RFD66606-2409 the beta, RFD66606-2410 the rc and RFD66606-2411 the released build.
  :: details Verification, end to end
  0. Each release: the tag, the GitHub release with sha256s, `push.sh`
     onto the Frame, the named playtest and its `clip.sh` capture, the
     release's gates and controls in the logbook.
  1. A bare-directory bootstrap of the new manifest;
     `elixir .repo/manifests/sync.exs . --preflight` at zero blocking;
     the five gates and `check_bootstrap.py` with `--self-test`.
  2. `elixir tools/build.exs --gates=load,crossings` in
     &{repo("transport-meshing-pen")} on the double build, every ELF at
     `DOUBLE_PRECISION=ON` with its `bintr-<HASH>` library for both
     platforms; `tools/probe_load.gd` asserts every ELF translated.
     X--control=single_elf` and an ELF with no library both fail.
  3. Lean tests, `lake build && lake exe tests --write=$TMPDIR/nc.txt &&
     diff $TMPDIR/nc.txt native-checks.txt`, in
     the `tests/` directory of &{repo("interactor-lasso")},
     &{repo("interactor-fabric-zone")} and &{repo("interactor-voice")}.
  4. On the Frame: `tools/frame/run-xr.sh <tag> replay` in priority mode,
     then `PRIORITY=0`, `NOFEED=1`, `hidden`, `flat --expect=xr` and
     `--control=drop_seam` as controls; `run-xr.sh wear replay` with
     `--control=no_attach`; `gate_station.gd` with `drop_lot` and `seed_2`.
  5. Headless pen gates on the double build: `gate_replay.gd`,
     `gate_capability.gd`, `gate_fabric_two_clients.gd`,
     `gate_voice_loopback.gd`; the same two-client gate against
     `weftspun-zone` on Fly, and `fly checks list -a weftspun-zone`.
  6. `mix rfd.check && mix rfd.render && mix rfd.board --check && prek run
     --all-files` in &{repo("manuals-weftspun")};
     `python scripts/check_anti_entropy.py` read in full.
  :: details What this abandons
  Abandons RFD66606-2067: the ladder's tags are the pen's `v<date>-dev.N`, and
  the packaging repository its semver tags named is not placed.
  :: details The problem
  None of it
  is reproducible from a checkout, and every guest is single precision
  against a double engine.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2293", :provides, "skateboard-workspace-manifest"
    relate "rfd-2293", :provides, "first-rung-release-plan"
    relate "rfd-2293", :is_a, "release-rung"
    relate "rfd-2293", :spends, "pen-wear-release-ladder"
    relate "rfd-2293", :spends, "fly"
    relate "rfd-2293", :spends, "guest-elf-double"
    relate "rfd-2293", :spends, "first-rung-dev2-gaps-closed"
    relate "rfd-2293", :spends, "windows-single-exe-frame-build"
    relate "rfd-2293", :spends, "dev-next-backlog-holder"
    relate "rfd-2293", :spends, "dev1-station-visit"
    relate "rfd-2293", :spends, "beta-wear-what-you-draw"
    relate "rfd-2293", :spends, "rc-two-people-talking"
    relate "rfd-2293", :spends, "rung-live-reproducible-bare"
    relate "rfd-2293", :spends, "macos-oxrsys-dev-play"
    relate "rfd-2293", :owns, "rfd-2296"
    relate "rfd-2293", :owns, "rfd-2297"
    relate "rfd-2293", :owns, "rfd-2298"
    relate "rfd-2293", :owns, "rfd-2407"
    relate "rfd-2293", :owns, "rfd-2408"
    relate "rfd-2293", :owns, "rfd-2409"
    relate "rfd-2293", :owns, "rfd-2410"
    relate "rfd-2293", :owns, "rfd-2411"
  end
end
