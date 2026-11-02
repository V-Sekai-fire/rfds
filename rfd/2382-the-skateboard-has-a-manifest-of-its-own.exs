# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2382, "the Skateboard has a manifest of its own", :discussion do
  flight_level :l1
  scope "the Skateboard's own workspace repository and its manifest rows."

  prose ~S"""
  :: hook
  The Skateboard gets its own manifest repository, so one bootstrap syncs every row it needs.
  :: intrigue
  Which manifest is the live goal for the Skateboard, and which holds everything else? A row whose
  revision does not resolve is refused by name.
  :: exit
  Run `curl -fsSL <raw>/bootstrap.sh | sh` on a bare directory and check that it ends with
  `sync.exs --preflight` at zero blocking and every row on disk.
  :: decision
  - One repository, &{repo("contract-manifest-skateboard", planned: "2-contract")},
    default branch `main`, made by `gh repo create` under the
    `v-sekai-fire-persona` user and given the taskweft manifest's ruleset
    shape: PR plus merge queue, the six required contexts
    `manifest-comments`, `manifest-dupes`, `manifest-root`,
    `manifest-root-shepherd`, `manifest-xml`, `sync-preflight`, never
    `--admin`.
  - The manual's Sides paragraph names the new repository as the live
    goal manifest for the Skateboard and the taskweft one as the goal
    manifest of everything else.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the Skateboard has a manifest of its own"

  prose ~S"""
  :: details The workspace: contract-manifest-skateboard
  The repository's contents:

  - `default.xml`, the five gates and the preflight copied from the
    taskweft manifest (`check_manifest_{comments,dupes,root,xml}`,
    `sync.exs`, `.github/workflows/gates.yml`), each keeping its
    `--self-test`.
  - `bootstrap.sh`, `bootstrap.ps1`, `install.sh`, `install.ps1`,
    `bootstrap-pins.txt`, `pixi.toml`, `pixi.lock`, `check_bootstrap.py`
    and the bootstrap workflow copied from &{repo("contract-bootstrap")},
    with `bootstrap.sh`'s two defaults (`WEFTSPUN_RAW`,
    `WEFTSPUN_MANIFEST`) and `bootstrap.ps1`'s pointed at the new
    repository. `pixi.toml` loses the `web` feature and the
    `emsdk-install` task. The `llvm-mingw` pin moves to 20260922, the version
    the headset build used.
  - `default.xml` places the bootstrap repository at the same path the
    taskweft manifest gives it, with the seven `<linkfile>`s it carries
    today, so `bootstrap.sh`'s `repo sync` of that path and step 4's
    `cmp` of the pins hold without change.

  :: details The rows
  The rows, by side, every one at the revision the taskweft manifest
  pins today unless named:

  - 1-transport: &{repo("transport-meshing-pen")} at `main`;
    `weftspun-studio`, &{repo("transport-cineform-tui")},
    &{repo("transport-elixir-libgodot-connector")},
    &{repo("transport-central-launcher")}, &{repo("transport-usbip-frame")}.
  - 2-contract: &{repo("manuals-weftspun")} with its five linkfiles,
    &{repo("contract-guest-runtime")}, &{repo("contract-guest-common")},
    &{repo("contract-ggml-rd")}, `ggml`, `plausible-witness-dag`,
    `weftspun-agreements`, and the manifest itself.
  - 3-interactor: &{repo("interactor-curvenet")}, &{repo("interactor-lasso")},
    &{repo("interactor-usd-guest")}, &{repo("interactor-fabric-zone")} and
    &{repo("interactor-voice")} (step 4), &{repo("interactor-av1mkv")},
    &{repo("interactor-cineform")}, &{repo("interactor-mujoco-sandbox-demo")},
    &{repo("frame-controller-sim")}, &{repo("interactor-taskweft-godot-sandbox")},
    &{repo("sakuragaoka-station")} at &{pin("sakuragaoka-station")} (the
    three.js original, the parity oracle), and a &{repo("pyrowave")} fork
    at &{pin("pyrowave")} carrying `pwbench.cpp`.
  - 4-entities: &{repo("entities-godot")} at master and at the fabric tag
    (the port source for steps 4 to 7),
    &{repo("entities-godot-sandbox", planned: "4-entities")} at `b1118e`,
    &{repo("entities-sakuragaoka-station")} (the Godot port),
    &{repo("contract-cineform-movie-writer")}, &{repo("godot_openvr")} at its
    manifest revision, `godot-vrm`,
    &{repo("entities-godot-sandbox-gdscript-compiler")}.
  - 5-repository: &{repo("repository-riscv64-sysroot")};
    &{repo("character-mille-mire-feuille")} and
    &{repo("character-marocchino")} from the `chibifire-stages` remote,
    each with a `<linkfile>` of its committed glTF into the pen's
    gitignored `avatars/`.
  - 6-datasource: &{repo("datasource-cassie")}; &{repo("datasource-store")}
    (fabric-store, the SQLite VFS whose pages live in FoundationDB,
    with its `<linkfile>` of `fdb_vfs.c` into the SQLite secrets
    engine's `thirdparty/store/`) and &{repo("datasource-foundationdb")}.
  - 7-service: &{repo("service-godot-build")} (the workflows' home),
    &{repo("service-cineform")}, &{repo("service-openbao")},
    &{repo("service-bao-sqlite-fdb")} (the OpenBao secrets engine that
    runs catalogued SQL over fabric-store databases; the zone journals'
    home), &{repo("service-zone")} (the Fly app's
    Containerfile and `fly.toml`).
  - The dot repositories `.github`, `dot-claude`, `dot-vscode`,
    `fire-s-extension-pack`.

  :: details The allowlist
  The allowlist gains picoquic (MIT),
  picotls (MIT), mbedTLS (Apache-2.0), SQLite (public domain), spmemvfs
  (BSD), zstd (BSD-3) and Opus (BSD-3) for step 4.

  :: details Check and control
  Check: on a bare directory, `curl -fsSL <raw>/bootstrap.sh | sh`
  ends with `sync.exs --preflight` at zero blocking and every row on
  disk; `check_bootstrap.py --self-test` and the five gates'
  `--self-test` pass. Control: a row whose revision does not resolve
  is refused by `check_manifest_xml.py` by name.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2382", :provides, "skateboard-manifest-repo"
  end
end
