# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2311, "serving bonsai 2 with ninfer-all and dflash2", :committed do
  feature "each card serves Ternary Bonsai 2 27B through ninfer-all with a DFlash2 drafter of five
tokens, and this RFD is how to set that up again from nothing on any Fedora 44 host"
  scope "the ninfer-all fork (repository interactor-language-ninfer), the t2 `.ninfer` artifact,
one systemd unit per card on Fedora 44 (native or WSL2), the mTLS front and the client's single
router port"

  prose ~S"""
  :: hook
  Each card serves Bonsai 2 through ninfer-all with a DFlash2 drafter, set up from nothing.
  :: intrigue
  No RFD decided how a card serves Bonsai 2, and the setup lived in agents' notes, tied to
  whichever machine held the cards that week.
  :: exit
  Build the engine and the host as the sections below say, then run the witnesses.
  :: decision
  A Bonsai 2 language server is ninfer-all serving the t2
  `bonsai2-27b-heretic.ninfer` artifact with `--spec dflash2 --draft-tokens 5`,
  one server per card, each a systemd unit on Fedora 44, native or in WSL2.
  Each server binds loopback only and takes an API key. stunnel with mutual
  TLS is the only way in from off the host. Clients reach every server
  through one router port. Fedora 44 is the only supported OS (operator,
  2026-10-17).
  :: related
  - RFD66606-2308 (Mac ninfer port), which uses this server as its reference.
  - RFD66606-2319 (endpoint certificates), where the front's certificate comes
    from.
  - RFD66606-2310 (eye-landmark scorer), which calls this server.
  """

  details_title "serving bonsai 2 with ninfer-all and dflash2"

  prose ~S"""
  :: details The choice
  The operator chose the engine and drafter on 2026-10-12
  ("The ninfer with dflash won") after the A-B-A run in the details.

  :: details Blocklist
  - BLOCKLIST.md, "Speculative decoders other than MTP-3" and "1-bit
    PTQ1_0 bodies", both for the ggml language server.

  :: details Sources
  Drafted on 2026-10-12 from an A-B-A run on one RTX 4090. Rewritten on
  2026-10-17 to describe the setup rather than the machines it ran on, after
  the operator unshipped the fork's Windows support and kept Fedora 44,
  native or WSL2.

  :: details The measurement
  One RTX 4090, the same launcher flags on every arm (`--max-context 262144`,
  `--kv-dtype rk8v4`, `--vision`, one request at a time), three repetitions,
  temperature 0, 512 generated tokens, speeds read from the server's own
  `timings`. Arms ran A-B-A so the repeated arm shows drift. Decode in tokens
  per second:

  | Arm | chat | code | story |
  | --- | --- | --- | --- |
  | ninfer-all, DFlash2 K=5 | 218-232 | 314-360 | 176-187 |
  | prebuilt engine, MTP-3 | 206-226 | 279-282 | 176-184 |
  | ninfer-all, MTP-3 | 193-206 | 239-267 | 164-172 |

  - Prefill on ninfer-all is about 10% faster at 3k prompt tokens.
  - Story is a tie inside the spread. ninfer-all with MTP-3 is the slowest
    arm, so the gain needs both the engine and the drafter.
  - Temperature-0 text differs between the two engines and between the two
    drafters inside ninfer-all.
  - The prebuilt engine cannot run DFlash2 on this artifact without
    `--lm-head-draft`, and with it DFlash2 was slower than its MTP-3 on every
    workload.

  :: details The artifact
  `bonsai2-27b-heretic.ninfer`, format `t2_g128_fp16`, with the vision tower,
  the MTP head and the DFlash2 head inside it. The converter is pure Python
  and runs on the CPU, with recipe `bonsai2_27b_ternary` from the Heretic
  PQ2_0 body and the Bonsai-trained MTP and DFlash2 heads. The four sources
  and the artifact are published in the public dataset
  `chibifire/ninfer-bonsai2-heretic` (operator, 2026-10-12), with a sha256 to
  check a download against.

  Every input is Apache-2.0: Qwen3.8-27B, Ternary Bonsai 2 27B, the Heretic
  v2 modification, the MTP and DFlash2 heads and the weights they adapt. The
  dataset carries their licence and notice files, a root `NOTICE` that names
  each author and states the conversion, and an Apache-2.0 card.

  A published artifact names no host path. A workflow in the fork converts on
  a clean runner and fails on any of the runner's directories in the artifact
  or its report, after a planted path is caught.

  The prebuilt engine reads only `t5_g128_fp16`, and ninfer-all reads only
  `t2_g128_fp16`. An artifact from one family does not load in the other. The
  artifact cannot take `--lm-head-q6`; with it the server exits at startup.

  :: details Building the engine
  `v-sekai/build.nu` in the fork builds on Fedora 44, native or WSL2, inside
  the fork's pixi `build` environment, which carries the compilers, CUDA,
  git, strip and gh. The host needs only curl to fetch pixi; git runs through
  `pixi exec`. The output is `dist/linux` (the programs and their library
  closure) and `dist/tools-linux/ninfer-install`.

  - One build compiles for one CUDA architecture; CMake refuses a list.
  - An sm_86 build runs on an RTX 3090 and an RTX 4090, so one build serves
    both cards of a two-card host.
  - In WSL2 the build drops the Windows entries from `PATH`, because CMake's
    package search over the 9p bridge takes minutes per lookup.

  :: details The host layout
  - `/opt/ninfer/bin` and `/opt/ninfer/lib` come from `dist/linux` and are
    checked against its `SHA256SUMS`. `/opt/ninfer/models` holds the
    artifact, checked against the dataset's sha256.
  - A system user `ninference` runs the servers. The key is
    `NINFER_API_KEY=` in `/etc/ninfer/env`, root-only, read by systemd.
  - One unit per card, `ninfer-serve-<card>.service`, enabled, restarting
    on any exit. It sets `CUDA_DEVICE_ORDER=PCI_BUS_ID` and picks the card
    with `--device`, adds `/opt/ninfer/lib` to the library path (and
    `/usr/lib/wsl/lib` in WSL2), and runs:

        ninfer-serve /opt/ninfer/models/bonsai2-27b-heretic.ninfer
          --device <n> --host 127.0.0.1 --port <port> --api-key ${NINFER_API_KEY}
          --model-id bonsai-27b --max-context 262144 --kv-capacity 262144
          --kv-dtype rk8v4 --vision --max-concurrency 1
          --spec dflash2 --draft-tokens 5 --no-thinking

  - The binary takes the key only on its command line, so a shell on the
    host sees it in `/proc`, `ps` and `systemctl status`. Mask `--api-key`
    whenever processes or units are listed.
  - In WSL2 the distribution stops when no Windows process holds it, and its
    units stop with it. A logon task keeps one process running in it.

  :: details Reaching it
  stunnel accepts on the host's tailnet address, one port per card, and
  forwards to the server's loopback port. It requires a client certificate
  under the chibifire Root and agent CA, and checks the client's host name
  against an allowlist. Its own certificate comes from RFD66606-2319. In WSL2 the
  tailnet address belongs to Windows, so stunnel runs there and forwards to
  the loopback port that WSL2 forwards into the distribution.

  On the client, a stunnel client maps each server to a local port, and a
  LiteLLM proxy (`v-sekai/router/` in the fork) puts all of them behind one
  port and one key. Its `bonsai` model goes to the least busy live server
  and skips one that is down; a name per card selects one server. Hermes
  calls only the router.

  :: details Witnesses
  Each one carries a control that must fail.

  - **Ready.** `GET /v1/models` through the tunnel returns 200 with the key,
    and 401 without a key and with a wrong one.
  - **Spec.** The unit's command line, key masked, carries `--spec dflash2
    --draft-tokens 5`, and the server log reports draft acceptance above zero.
  - **Vision.** `v-sekai/vision_zero_shot_probe.py` against the tunnel names
    the red circle, the blue square and the text 42. A text-only server
    returns an error on the same request.
  - **mTLS.** The allowlisted client gets an HTTP answer. No certificate,
    and a certificate for a second client under the same CA, are both
    refused, the second with a subject-check failure.
  - **Answer.** The same temperature-0 code prompt gives the same answer
    hash on a rerun and after a reinstall on the same card.
  - **Speed.** Three reps of a 512-token code answer at temperature 0 land
    inside the card's previous runs. A number without that baseline is not
    reported.

  :: details Pitfalls
  - Check that the files the running server holds still exist before a
    restart. A server keeps serving from a deleted model file, and the
    restart then fails with `startup failed | inspecting artifact`.
  - `CUDA_DEVICE_ORDER=PCI_BUS_ID` changes which card a device index names.
    Read `nvidia-smi` in the same order before choosing `--device`; a build
    for a newer architecture fails on an older card with `no kernel image`.
  - Wait for the ready line `listening on` with a journal cursor taken before
    the restart, not with a timestamp.
  - An A/B that swaps `--spec` restores the unit in the same script on
    failure, because a server that dies at startup leaves its card down.

  :: details Open questions
  - The decider benchmark behind the MTP-3 blocklist row has not been run on
    ninfer-all. Until it is, the row and this RFD measure different
    workloads, and neither says which drafter makes better decisions.
  - MTP's upstream advantage is a second request lane
    (`--max-concurrency 2`). Every arm here served one request at a time.
  - DFlash2 at six and seven draft tokens is measured on one card only.
  - The unit and stunnel files are written by hand on each host and are in
    no repository.
  :: details The problem
  Every move of the cards rebuilt it by hand.
  """
end
