# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT

defmodule Serials.VSekaiFabric do
  use RFD.Register

  register "VSekaiFabric" do
    layer arc: "urn:oid:1.3.6.1.4.1.66606.1.2",
          site: 2,
          site_name: "v-sekai-fabric",
          category: 1,
          category_name: "documents",
          pen: "urn:oid:1.3.6.1.4.1.66606",
          rule: "rfd/2000-conventions/index.md",
          note:
            {:reactivated,
             "Reactivated 2026-08-31 when site 1 was frozen. The site was decommissioned on 2026-08-29 and moved into request-for-discussion, which is where its register now lives; the 2026-08-29 sentence promising no new allocations was retracted in pen-66606.usda sitesDecommissioned. From 2026-08-31 forward this is the workspace source of new RFD serials -- new RFDs get 2NNN numbers here."}

    thesis "Every serial this site has allocated. A serial is appended once. It is never removed and never reused, because it is the last arc of an OID and an arc names one document for as long as it exists. A slug follows its directory, because a retitle renames a document and does not renumber it."

    allocated do
      serial 2009, "ghcr-package-ownership-same-repo"
      serial 2012, "amend-pr-before-it-enters-the-queue"
      serial 2013, "archival-file-naming-convention"
      serial 2016, "checking-sccache"
      serial 2021, "require-pr-and-merge-queue-on-main"
      serial 2026, "commit-messages-sentence-case"
      serial 2028, "hexagonal-core-ports-adapters"
      serial 2059, "bad-news-reports-lead-with-the-bottom-line"
      serial 2064, "kebab-case-repos-snake-case-local-checkouts"
      serial 2134, "cluster-tls-is-decided-before-data"
      serial 2137, "rfd-reports-share-one-sheet"
      serial 2140, "openbao-on-foundationdb"
      serial 2142, "bao-pki-zerotrust-service-tls"
      serial 2143, "fdb-backup-fans-out-to-r2"
      serial 2144, "fdb-dr-runbook-first-run"
      serial 2145, "certificate-lifetimes"
      serial 2146, "bao-is-the-secret-store"
      serial 2159, "fbd-compiler-two-implementations"
      serial 2168, "retract-wholebody-detector-keep-renderer", flight_level: :l1
      serial 2169, "abandon-strangler-fig-studio-core"
      serial 2170, "allosaurus-squad-localization-langs", flight_level: :l2
      serial 2171, "atelier-workshop-shuttle-vocabulary", flight_level: :l2
      serial 2172, "tenseless-continuous-present-voice", flight_level: :l2
      serial 2173, "qwen3-vl-to-gemma-migration-index"
      serial 2174, "abandoned-citation-index"
      serial 2175, "abandon-rented-compute-rfds"
      serial 2176, "committed-cites-terminal-index"
      serial 2177, "flight-levels-taxonomy"
      serial 2179, "drop-whisper-models"
      serial 2180, "drop-gemma-auto"
      serial 2181, "drop-allosaurus-rus"
      serial 2182, "identity-triangle-operator-market-customer", flight_level: :l2
      serial 2185, "hierarchical-oid-part-registry"
      serial 2195, "weftspun-bao-tailscale-sidecar"
      serial 2196, "huggingface-dataset-viewer-rules"
      serial 2200, "rebac-agent-roles"
      serial 2201, "coordinate-agents-ceremony"
      serial 2202, "rebac-bao-enforcement"
      serial 2209, "cc-by-nc-blocklist-entry"
      serial 2216, "threejs-blocklist"
      serial 2229, "interchangeable-parts-consolidation", flight_level: :l3
      serial 2232, "rfd-dsl-in-elixir", flight_level: :l2
      serial 2233, "close-out-gates-red-green-scout"
      serial 2235, "taskweft-acp-agent"
      serial 2240, "citation-metadata-and-review-interchange"
      serial 2247, "property-testing-in-every-language"
      serial 2255, "bao-ssh-tunnel"
      serial 2256, "webtransport-inside-a-sandbox-guest"
      serial 2257, "tooling-runs-in-the-linux-subsystem"
      serial 2258, "every-ci-gate-is-a-prek-hook"
      serial 2259, "how-a-session-shapes-its-work"
      serial 2260, "credentials-shared-by-path-in-bao"
      serial 2261, "mbedtls-is-the-tls-library"
      serial 2262, "make-it-with-the-pen-and-wear-it-together", flight_level: :l3
      serial 2263, "the-skateboards-simulator-gate"
      serial 2287, "the-first-rung-draw-and-wear-it-in-a-headset"
      serial 2288, "guest-capabilities-as-macaroons"
      serial 2289, "unship-the-zone-stack-off-route-runtimes-and-browser-client"
      serial 2291, "capability-rebac-is-a-dsl-feature", flight_level: :l2
      serial 2292, "the-organization-is-one-rectgtn-domain"
      serial 2293, "the-skateboards-workspace-and-the-first-rungs-plan"
      serial 2294, "agent-knowledge-lives-in-rfds-not-in-desk-memory", flight_level: :l2
      serial 2295, "agent-replies-state-calibrated-confidence", flight_level: :l2
      serial 2296, "the-first-rungs-dev-2"
      serial 2297, "the-first-rungs-dev-3"
      serial 2298, "the-first-rungs-dev-next"
      serial 2302, "guest-work-runs-in-frame-slices"
      serial 2306, "operating-the-shared-windows-vr-desk"
      serial 2307, "recording-the-xr-pilot-stream-to-cineform"
      serial 2311, "serving-bonsai-2-with-ninfer-all-and-dflash2"
      serial 2312, "release-tags-are-go-pseudo-versions"
      serial 2316, "bao-holds-a-bounded-set", flight_level: :l2
      serial 2319, "a-serving-hosts-certificate-comes-from-agent-ca-v2"
      serial 2320, "an-agent-drives-the-oxrsys-simulator-through-cua-driver"
      serial 2321, "the-autobattler-fields-frames-that-wear"
      serial 2333, "a-desk-reaches-foundationdb-only-through-bao"
      serial 2337, "a-garment-fit-at-mesh-on-the-gpu-l-bfgs-b"
      serial 2339, "a-persona-answers-from-a-planning-domain", flight_level: :l1
      serial 2340, "a-campus-where-a-party-of-four-draws-and-wears", flight_level: :l1
      serial 2341, "dev-next"
      serial 2342, "dev1-the-tray-icon"
      serial 2343, "dev2-the-first-playable"
      serial 2344, "dev3-the-verification-of-dev-2"
      serial 2345, "video-intermediate-cineform-flac-mkv"
      serial 2346, "decider-pong-in-the-workspace"
      serial 2347, "decider-pong-second-opinion-and-win"
      serial 2348, "taskweft-superset-workspace"
      serial 2349, "recording-a-live-run"
      serial 2351, "one-token-ledger-for-three-orgs"
      serial 2353, "bao-runs-three-replicas-on-the-fdb-machines", flight_level: :l2
      serial 2354, "bao-unseals-itself-through-a-seal-bao-on-fly", flight_level: :l2
      serial 2355, "consumers-cache-bao-reads-in-memory", flight_level: :l2
      serial 2356, "workspace-services-stay-dns-only", flight_level: :l2
      serial 2357, "a-narrow-unit-holds-a-wide-number-as-a-sum-of-parts", flight_level: :l2
      serial 2358, "a-party-is-one-player-and-three-seats", flight_level: :l1
      serial 2359, "the-shopkeeper-keeps-the-books-for-each-conversation", flight_level: :l1
      serial 2360, "the-campus-ships-one-beta", flight_level: :l1
      serial 2361, "a-section-names-its-own-gate", flight_level: :l2
      serial 2362, "a-prose-rule-ships-after-it-runs-against-the-corpus", flight_level: :l2
      serial 2363, "a-person-moves-by-world-grab-or-by-controllers", flight_level: :l2
      serial 2364, "the-whole-stack-deploys-offline-on-one-laptop", flight_level: :l2
      serial 2365, "every-video-ships-as-cineform-in-matroska", flight_level: :l2
      serial 2366, "a-short-runs-forty-seconds-in-four-beats", flight_level: :l2
      serial 2367, "the-station-port-renders-in-godot-from-baked-meshes", flight_level: :l2
      serial 2368, "station-parity-is-measured-against-a-warp-render", flight_level: :l2
      serial 2369, "the-standalone-headset-draws-at-most-700k-triangles", flight_level: :l2
      serial 2370, "a-visual-comparison-is-a-labelled-contact-sheet", flight_level: :l2
      serial 2371, "a-residual-is-fixed-down-a-ladder-never-smudged", flight_level: :l2
      serial 2372, "heavy-compute-runs-in-a-godot-sandbox-guest", flight_level: :l2
      serial 2373, "a-guest-keeps-its-source-where-it-is-consumed", flight_level: :l2
      serial 2374, "everything-in-a-godot-sandbox-runs-binary-translated", flight_level: :l2
      serial 2375, "the-game-ships-to-the-headset-as-a-windows-build", flight_level: :l2
      serial 2376, "nothing-runs-in-the-headset-unless-the-operator-asks", flight_level: :l2
      serial 2377, "a-translation-links-into-the-addon-one-bake-per-platform", flight_level: :l2

      serial 2378, "desktop-libraries-build-in-wsl-and-cross-build-from-the-mac",
        flight_level: :l2

      serial 2379, "desktop-zips-ship-as-release-assets", flight_level: :l2
      serial 2380, "the-skintokens-packages-live-in-a-model-repository", flight_level: :l2
      serial 2381, "a-windows-host-answers-four-system-calls-as-linux-does", flight_level: :l2
      serial 2382, "the-skateboard-has-a-manifest-of-its-own", flight_level: :l1

      serial 2383, "the-assistant-draws-with-the-pen-through-steamvr-priority-mode"

      serial 2384, "the-station-is-ported-to-godot-module-by-module-against-a-reference"

      serial 2385, "the-proton-tweak-on-the-frame-is-reproduced-by-script", flight_level: :l1
      serial 2386, "this-mac-is-the-desktop-client", flight_level: :l1
      serial 2387, "github-actions-builds-every-double-binary", flight_level: :l1

      serial 2388, "the-servers-linux-double-build-comes-only-from-the-workflow",
        flight_level: :l1

      serial 2389, "the-sandbox-addon-is-built-at-double", flight_level: :l1
      serial 2390, "every-elf-guest-ships-with-its-native-translation", flight_level: :l1
      serial 2391, "guests-are-built-at-double-precision", flight_level: :l1
      serial 2392, "df32-holds-guest-geometry-far-from-the-origin"
      serial 2393, "the-pen-builds-and-ships-only-the-first-rung-s-guests"
      serial 2394, "the-template-release-fault-is-diagnosed-not-guessed"
      serial 2395, "the-draw-step-runs-the-pipeline-and-lassoes-a-target", flight_level: :l1
      serial 2396, "the-wear-step-attaches-the-garment-to-the-avatar-s-hips", flight_level: :l1

      serial 2397, "the-transport-step-puts-a-certificate-authority-and-capabilities-in-guests",
        flight_level: :l1

      serial 2398, "the-zone-step-ports-the-fabric-zone-into-a-guest", flight_level: :l1
      serial 2399, "the-zone-journal-lives-in-bao-over-foundationdb", flight_level: :l1
      serial 2400, "the-worker-zone-dispatches-and-a-sidecar-computes", flight_level: :l1
      serial 2401, "the-talk-step-carries-voice-as-datagrams", flight_level: :l1
      serial 2402, "the-ghost-servers-run-on-fly-as-weftspun-zone", flight_level: :l1
      serial 2403, "the-zone-reaches-bao-by-a-certificate-bao-issues"
      serial 2404, "the-evidence-step-records-one-session", flight_level: :l1
      serial 2405, "the-rung-s-setup-uses-a-fixed-set-of-credentials"
      serial 2406, "the-desk-s-stored-github-credentials-are-destroyed", flight_level: :l1
      serial 2407, "dev-1-and-dev-2-play-on-macos-through-oxrsys", flight_level: :l1
      serial 2408, "dev-1-one-person-visits-the-station", flight_level: :l1
      serial 2409, "beta-one-person-wears-what-they-draw"
      serial 2410, "rc-two-people-in-one-zone-talking", flight_level: :l1

      serial 2411, "released-the-rung-is-live-and-reproducible-from-a-bare-machine",
        flight_level: :l1

      serial 2412, "each-feature-carries-a-joy-forecast"

      serial 2413, "a-desk-works-from-the-placed-tree-and-turns-a-repeated-procedure-into-a-tool",
        flight_level: :l2

      serial 2414, "no-workflow-or-background-subagent-runs-unless-the-operator-asks",
        flight_level: :l2

      serial 2415, "test-marks-go-only-in-test-scenes", flight_level: :l2
      serial 2416, "a-large-area-is-parked-one-top-level-entry-at-a-time", flight_level: :l2
      serial 2417, "github-activity-stays-in-our-two-organisations", flight_level: :l2
      serial 2418, "our-line-of-an-upstream-branch-is-dev-branch-on-the-fork", flight_level: :l2

      serial 2419, "git-bash-on-windows-runs-slash-switch-commands-under-a-path-conversion-guard",
        flight_level: :l2

      serial 2420, "the-rung-s-guests-are-c-built-at-double-and-tested-with-lean"

      serial 2421, "the-headset-is-the-steam-frame-on-a-pc-vr-stream"

      serial 2422, "the-interface-follows-xr-grid-and-cassie-and-common-openxr-practice"

      serial 2423, "the-setting-is-a-port-of-the-sakuragaoka-station-plaza", flight_level: :l1
      serial 2424, "a-free-space-sketch-is-fitted-to-the-avatar-from-keypoints", flight_level: :l1
      serial 2425, "both-avatars-are-free-apache-2-0-models", flight_level: :l1
      serial 2426, "the-garment-handover-is-timed-per-leg", flight_level: :l1
      serial 2427, "frontier-learning-picks-the-garment-handover-timing-runs", flight_level: :l1
      serial 2428, "every-model-follows-a-six-step-migration-recipe", flight_level: :l2
      serial 2429, "the-maskscore-pipeline-runs-from-a-container-to-hf", flight_level: :l2

      serial 2430, "the-gacha-critical-path-is-ten-rungs-from-a-prompt-to-a-public-roll",
        flight_level: :l2

      serial 2431, "internal-assets-are-openusd-and-transmission-is-gltf-vrm-or-usdz",
        flight_level: :l2

      serial 2432, "a-module-ships-as-a-plain-docker-image-around-the-shared-native-binary",
        flight_level: :l2

      serial 2433, "the-catalog-is-the-backend-api-and-runs-on-any-renderingdevice-gpu",
        flight_level: :l2

      serial 2434, "consumers-wrap-the-shared-ggml-runtime-through-a-gdextension-surface",
        flight_level: :l2

      serial 2435, "a-garment-is-repaired-as-a-distance-field-surface", flight_level: :l1
      serial 2436, "presence-is-an-independent-native-slice", flight_level: :l1
      serial 2437, "voice-is-an-independent-native-slice"
      serial 2438, "draw-and-wear-is-an-independent-native-slice"
      serial 2439, "party-seats-are-an-independent-native-slice"
      serial 2440, "the-shop-books-are-an-independent-native-slice"
      serial 2441, "github-job-logs-in-to-bao-with-its-identity-token"
      serial 2442, "latency-is-the-metric-for-64-hz-entity-state"
      serial 2443, "entityserver-serves-64-hz-entity-state-beside-feedserver"
      serial 2444, "seamless-zone-transfer-is-an-independent-native-slice"
      serial 2445, "the-lesson-surface-is-an-independent-native-slice"
      serial 2446, "a2a-hardening-open-verification-gaps"
      serial 2447, "campus-beta-1-see-each-other", flight_level: :l1
      serial 2448, "campus-beta-2-hear-each-other"
      serial 2449, "campus-beta-3-draw-and-wear"
      serial 2450, "campus-beta-4-adventure-party-and-shop"
      serial 2451, "campus-beta-5-seamless-zone-transfer"
      serial 2452, "campus-beta-6-lesson-surface"
      serial 2453, "settle-the-open-questions-in-rfd66606-2441"
      serial 2454, "amend-rfd66606-2399-and-rfd66606-2403-so-the-zone-reaches-the-store-di"
      serial 2455, "rename-the-last-innovation-token-phrase-in-rfd66606-2341"
      serial 2456, "rename-the-ledger-text-in-the-private-working-agreements-plan-and-bloc"
      serial 2457, "navigator-show-the-temporal-route-and-state-durations-for-the-beta-s-r"
      serial 2458, "declare-the-real-alternatives-between-rfds-so-choice-and-backtracking"
      serial 2459, "review-the-ai-drafted-token-edges-provides-spends-owns-is-a"
      serial 2460, "store-off-the-loop-passive-compaction-thread-transfer-from-rust-iourin"
      serial 2461, "store-b-tree-cursor-reads-on-hot-read-paths-secondary-transfer-from-ru"
      serial 2462, "replace-thirdparty-llama-cpp-with-prismml-s-prism-branch-for-dflash-n"
      serial 2463, "stablehlo-lower-tanh-bit-equal-with-xla-cpu"
      serial 2464, "stablehlo-lower-erf-bit-equal-with-xla-cpu"
      serial 2465, "stablehlo-lower-gather-with-indices-computed-at-run-time"
      serial 2466, "stablehlo-lower-convolution"
      serial 2467, "stablehlo-lower-power"
      serial 2468, "stablehlo-run-time-i32-arithmetic"
      serial 2469, "stablehlo-match-xla-cpu-s-summation-order-in-reduce-and-dot-general"
      serial 2470, "minizinc-challenge-blocks-world-on-the-gtn-blocks-methods-climbing-fro"
      serial 2471, "minizinc-challenge-precedence-scheduling-problems-on-the-temporal-plan"
      serial 2472, "khr-interactivity-what-the-interpreter-does-not-build-yet"
      serial 2473, "planner-search-heuristics-for-the-shortest-plan"
      serial 2474, "suit-markers-dead-on-gate-must-read-every-marker"
      serial 2475, "suit-markers-tag-bench-and-the-marker-frontier-variants-against-input"
      serial 2476, "suit-markers-raise-yield-per-island-toward-2310-without-the-id-cap"
      serial 2477, "suit-markers-structured-light-decoding-with-anonymous-corners-and-latt"
      serial 2478, "anny-soma-x-rf-detr-keypoints-hairdeck-muscle-supermimic-and-the-pose"
      serial 2479, "maple-dress-cloth-fit-leftovers"
      serial 2480, "settle-the-single-writer-baseline-lone-writer-against-the-m-1-pair"
      serial 2481, "separate-this-mac-from-the-cluster-bare-commit-loop-on-the-wsl-desk"
      serial 2482, "build-a-50-200-mb-feed-shaped-table-before-any-read-or-cluster-shape-c"
      serial 2483, "find-the-group-commit-knee-rows-per-sqlite-transaction-against-commits"
      serial 2484, "load-the-challenge-seed-into-a-store-once-verified-by-counts-and-hashe"
      serial 2485, "find-what-produces-the-100-730-ms-commits"
      serial 2486, "tri2d-cli-shared-algorithm-repo"
      serial 2487, "animation-mixer-migration", flight_level: :l1
      serial 2488, "cage-wrapped-surface-net"
      serial 2489, "body-measurements-from-base-model"
      serial 2490, "what-the-fabric-is-for-and-what-it-is-not", flight_level: :l2
    end

    deleted do
      serial 2000, "conventions"
      serial 2001, "zonefabric-roadmap-vs-mas-bandwidth-fps"
      serial 2002, "taskweft-value-narrowing-primitives-and-refs"
      serial 2003, "castspell-sandbox-package-and-manifest-encoding"
      serial 2004, "castspell-libgodot-sandbox-runtime-scope"
      serial 2005, "gltf-interactivity-value-type-taxonomy-correction"
      serial 2006, "cockroachdb-with-mtls-role-separation"
      serial 2007, "godot-double-precision-template-release-for-zone"
      serial 2010, "maglev-cycle-1-gateway-handshake"
      serial 2014, "art-game-loop-steel-thread"
      serial 2022, "spatial-audio-patched-resonance-audio"
      serial 2025, "tenseless-continuous-present-voice"
      serial 2029, "cassie-desktop-curvenet-authoring"
      serial 2031, "content-build-merged-double-precision-mcp"
      serial 2034, "deterministic-cores-integer-seeded-rng"
      serial 2035, "first-party-curated-content-zone-baker-budgets"
      serial 2037, "generated-behavior-sandboxed-riscv"
      serial 2038, "genre-generic-naming-no-trademarks"
      serial 2039, "hexagon-budgeter-core"
      serial 2041, "hexagon-loot-core"
      serial 2042, "hexagon-presence-core"
      serial 2043, "hexagon-progression-core"
      serial 2045, "loot-action-core-loop-mvp-vertical-slice"
      serial 2046, "server-authoritative-simulation-deferred-rollback"
      serial 2047, "webtransportd-core-transport-adapter"
      serial 2048, "android-template-temurin-jdk21"
      serial 2049, "fabric-channels-as-reliability-classes"
      serial 2050, "five-second-transaction-limit"
      serial 2054, "mcp-runtime-bridge-deployed-builds"
      serial 2055, "r128-fixed-point-as-lean-library"
      serial 2056, "systemd-quadlet-verification-queue"
      serial 2057, "vertical-slice-repository-map"
      serial 2062, "repository-and-capability-inventory"
      serial 2063, "repo-markdown-single-source-of-truth-for-project-state"
      serial 2066, "game-loop-cluster-sequence"
      serial 2067, "release-tag-progression-dev-beta-rc"
      serial 2069, "defer-loot-slice-hardening-until-needed"
      serial 2070, "loop-slice-telemetry-to-the-observability-collector"
      serial 2071, "yagni-times-structure-to-need"
      serial 2072, "actor-lite-worker-pool"
      serial 2073, "async-fdb-callback-chain"
      serial 2074, "binary-value-encoding-for-fdb"
      serial 2075, "fdb-over-cockroachdb-for-zone-state"
      serial 2076, "macaroon-xdp-security"
      serial 2077, "pert-critical-path-zonefabric"
      serial 2078, "plausible-witness-dag-feature-ablation"
      serial 2079, "sandboxed-godot-in-zone-server-h2o-via-raw-libriscv"
      serial 2080, "slotmap-entity-storage"
      serial 2081, "three-layer-verification-strategy"
      serial 2082, "zonefabric-scaling"
      serial 2083, "zone-server-h2o-replaces-godot-fabriczone"
      serial 2084, "zstd-compression-for-zone-state"
      serial 2085, "the-gyre-mud-setting-on-the-loot-action-shell"
      serial 2086, "defer-nogod-gossip-zone-authority"
      serial 2087, "avatar-ik-sinew-mocap-align-over-mink"
      serial 2088, "picoquic-picotls-transport-for-zone-server-h2o"
      serial 2089, "flyio-over-podman-quadlets"
      serial 2090, "uro-burrito-release"
      serial 2091, "the-gyre-mud-domain-and-mode-selector"
      serial 2092, "rebac-gates-libriscv-guest-access"
      serial 2094, "minimum-ugc-game-loop-guest-composition"
      serial 2095, "two-guest-classes-domain-abi-and-bubblewrap"
      serial 2099, "server-authority-on-fly"
      serial 2100, "tick-rate-send-rate-and-the-bone-budget"
      serial 2102, "the-whole-deployment-on-15-usd"
      serial 2105, "archive-self-host-era-support-repos"
      serial 2107, "janet-scripting-over-a-c-taskweft-core"
      serial 2108, "local-cabi-guests-and-in-tick-fanout"
      serial 2110, "h2o-libriscv-as-a-rivet-actor"
      serial 2112, "lexical-for-the-slash-command-interface"
      serial 2116, "elixir-epoll-zone-server-in-the-h2o-style"
      serial 2120, "the-gyre-became-a-settlement-game"
      serial 2122, "the-client-is-native"
      serial 2123, "a-second-webtransport-implementation"
      serial 2124, "elixir-error-tuples-in-every-reply"
      serial 2125, "an-interactor-in-another-process"
      serial 2126, "two-see-through-interactors"
      serial 2127, "a-service-is-not-a-side"
      serial 2128, "the-release-ladder-is-not-automated"
      serial 2129, "cost-and-latency-are-two-budgets"
      serial 2130, "state-what-a-repository-is-made-of"
      serial 2132, "a-permission-cannot-be-granted-sideways"
      serial 2133, "the-pool-rents-from-the-spot-book"
      serial 2138, "interactor-shuttle-merges-spot-broker-and-uro"
      serial 2139, "maskscore-qaft-budget"
      serial 2147, "bao-is-critical-infrastructure"
      serial 2151, "coap-oscore-nif-for-taskweft"
      serial 2158, "lean4-fbd-compiler-self-hosted-on-riscv"
      serial 2163, "maskscore-text-stub-gemma-vlm"
      serial 2186, "omnigen2-to-lumina2-lora-transfer-qaft"
      serial 2187, "identity-anny-via-omnigen2"
      serial 2194, "atelier-shuttle-portfolio-widget"
      serial 2208, "decision-point-control-surface"
      serial 2211, "base-tree-entities-godot-sandbox"
      serial 2212, "motion-bricks-as-native-godot-module"
      serial 2214, "model-bundle-sqlite-range-fetch-zstd"
      serial 2217, "ggml-webgl2-backend-evaluation"
      serial 2218, "ggml-webgpu-backend"
      serial 2227, "workspace-ggml-models-on-platform-web-webgpu"
      serial 2228, "webgpu-native-drop-platform-web", flight_level: :l2
      serial 2230, "ggml-adapters-in-godot-sandbox"
      serial 2231, "drop-webgpu-use-vulkan", flight_level: :l2
      serial 2008, "webtransport-over-quic-for-game-traffic"
      serial 2015, "bounded-llm-steering-queue"
      serial 2017, "compiling-godot-engine"
      serial 2018, "feature-classification-poc-baseline-stretch"
      serial 2019, "gitassembly-tag-release"
      serial 2020, "pin-engine-to-frozen-godot-4-7"
      serial 2023, "webtransport-http3-transport"
      serial 2024, "windows-background-services-nssm"
      serial 2027, "umbrella-package-installs-all-components"
      serial 2030, "cicd-runners-as-queueing-system"
      serial 2032, "core-codegen-lean-slang"
      serial 2033, "core-contract-pure-reducer-byte-state"
      serial 2036, "forward-renderer-baked-light"
      serial 2040, "hexagon-combat-core"
      serial 2044, "lean4-kernel-cores-flat-c-host-adapters"
      serial 2051, "headless-openxr-testing-with-monado"
      serial 2052, "http3-listener-session-findings"
      serial 2053, "integral-entity-transform-wire"
      serial 2058, "webtransport-persistent-framed-stream"
      serial 2060, "org-scoped-github-app-token-for-gh-access"
      serial 2065, "fabric-platform-central-elixir-burrito-casync"
      serial 2068, "sccache-github-actions-cache-for-godot-builds"
      serial 2093, "compile-taskweft-to-linear-automata"
      serial 2096, "guest-transport-measured-on-fly"
      serial 2097, "pubsub-belongs-in-userspace"
      serial 2098, "rollback-snapshot-budget"
      serial 2101, "zstd-delta-on-the-wire"
      serial 2103, "uro-on-ecto-foundationdb"
      serial 2106, "split-the-archive-into-its-own-repo"
      serial 2109, "two-tiers-with-foundationdb-as-the-store"
      serial 2111, "convert-the-deployment-words"
      serial 2113, "foundationdb-on-windows-built-from-source"
      serial 2114, "prove-the-store-by-breaking-it"
      serial 2115, "a-planner-domain-document-is-a-cheap-layer-surface"
      serial 2117, "retire-the-h2o-tier-record-set"
      serial 2118, "a-baker-replaces-the-godot-editor"
      serial 2119, "salvage-you-can-hold"
      serial 2121, "amend-rfd-2111-against-the-tree"
      serial 2135, "checks-run-where-the-credentials-already-are"
      serial 2136, "the-gacha-critical-path"
      serial 2141, "fdb-tls-rotation-without-data-loss"
      serial 2148, "grafcet-as-taskwefts-authoring-surface"
      serial 2149, "grafcet-static-analysis-in-lean4"
      serial 2150, "rectgtn-on-openplc4-over-coap-oscore"
      serial 2152, "or-divergence-plcopen-emit"
      serial 2153, "fbd-to-nodegraph-converters"
      serial 2154, "openplc4-to-godot-sandbox"
      serial 2155, "gdscript-fbd-transpiler"
      serial 2156, "safegdscript-compile-step"
      serial 2157, "fbd-to-elf-compiler-in-lean4"
      serial 2160, "openusd-as-taskweft-intermediate"
      serial 2161, "vn-avatar-cleanroom-on-maskscore"
      serial 2162, "maskscore-usdz-skinning-and-15-edit-emit"
      serial 2164, "maskscore-speech-stub-panel-and-cloning"
      serial 2165, "maskscore-unified-8-stub-emit"
      serial 2166, "maskscore-cineform-mkv-bundle"
      serial 2167, "maskscore-voice-reward-distillation"
      serial 2178, "qaft-4bit-across-the-stack"
      serial 2183, "retrain-omnigen-for-layer-decomposition"
      serial 2184, "omnigen2-sdcpp-port-lean4-verified"
      serial 2188, "one-ggml-across-workspace"
      serial 2189, "stick-figure-sanity-check-for-pose-corpus"
      serial 2190, "multi-camera-rig-extrinsics-calibration"
      serial 2191, "unrolled-solver-residual-measurement"
      serial 2192, "rfdetr-keypoint-weights-licence-verification"
      serial 2193, "editscore-as-constructed-synthetic-reproducibility-bar"
      serial 2197, "maskscore-rung-1-bootstrap-hf-restructure"
      serial 2198, "lladao-speed-work-for-dressing-overlay"
      serial 2199, "hailo-real-4bit-qat"
      serial 2203, "anny-soma-first-subset-corpus-shape"
      serial 2204, "rectgtn-fleet-coordination"
      serial 2205, "taskweft-in-bao"
      serial 2206, "video-call-vrm-portrait"
      serial 2207, "nord-palette-for-demos"
      serial 2210, "atelier-godot-web-shipping-surface"
      serial 2213, "vrm-via-godot-sandbox-elf"
      serial 2215, "one-binary-two-heads"
      serial 2234, "dress-on-pipeline"
      serial 2236, "fbd-teacher-in-three-steps"
      serial 2237, "body-scan-controller"
      serial 2238, "g1-sim-to-real-environment"
      serial 2239, "traits-and-one-binary"
      serial 2241, "audio-pose-from-speaking-faces"
      serial 2242, "ggml-consumers-as-native-godot-modules"
      serial 2243, "assembly-one-cycle-blockers"
      serial 2244, "one-deformation-operator"
      serial 2245, "webgpu-allowed-inside-godot-engine"
      serial 2246, "editscore-omnigen-bootstrap-for-unmapped-parts"
      serial 2248, "the-avatar-body-is-a-closed-solid"
      serial 2249, "cloth-by-vertex-block-descent"
      serial 2250, "cloth-fit-as-one-burrito-binary"
      serial 2251, "image-to-godot-character-as-an-fbd"
      serial 2252, "llm-module-splits-and-drafts"
      serial 2253, "a-character-creator-on-anny"
      serial 2254, "order-independent-transparency-for-cad"
      serial 2264, "mesh-repair-by-voxel-remesh"
      serial 2265, "curvenet-on-compute-rd"
      serial 2266, "simulator-runtime-on-linux"
      serial 2267, "persona-npcs-in-ported-scenes"
      serial 2268, "the-recommender-is-a-decision-model"
      serial 2269, "curvenet-parity-gate-is-interval-arithmetic"
      serial 2271, "headset-eye-tracking-to-social-vr-without-a-bridge"
      serial 2272, "rf-detr-segmentation-as-a-sandbox-guest-on-ggml-rd"
      serial 2273, "accepting-person-masks-depth-before-judge"
      serial 2274, "curvenet-crossings-via-mujoco-guest"
      serial 2275, "unified-expressions-by-fitting-a-parametric-head"
      serial 2276, "kusudama-governs-a-ggml-rd-persona-policy"
      serial 2277, "curvenet-cage-refit-and-unified-expressions-in-modular-avatar"
      serial 2278, "voxel-remeshing-for-cages-and-solids"
      serial 2279, "one-deform-surface-over-curvenets"
      serial 2280, "pixal3d-latents-as-mesh-tokens"
      serial 2281, "face-shapes-from-three-sources"
      serial 2282, "pose-correctives-as-bones"
      serial 2283, "play-mode-verification-by-recording"
      serial 2284, "a-quest-variant-by-sandbox-guests"
      serial 2285, "unship-the-web-demo-and-xr-paths"
      serial 2286, "a-phone-face-bridge-to-social-vr"
      serial 2290, "trim-the-independent-ggml-runtimes"
      serial 2300, "sinew-sim-rung-ladder"
      serial 2301, "sinew-sim-dev4-kimodo-soma-motion"
      serial 2303, "xr-technical-requirements-checklist"
      serial 2304, "one-lean-4-rectgtn-library-generates-the-planner"
      serial 2305, "one-credit-system-with-ports-and-adapters"
      serial 2308, "ninfer-kernels-in-slang-inside-mlx"
      serial 2309, "frontier-learning-for-the-alyx-planner"
      serial 2310, "eye-landmarks-from-a-frontier-learned-render-domain"
      serial 2313, "the-full-loop-over-colour-passthrough"
      serial 2314, "the-skintokens-space-viewer-runs-as-sandbox-guests"
      serial 2315, "web-shaders-are-baked-by-the-browser-that-runs-them"
      serial 2317, "a-browser-joins-a-webtransport-server-with-a-bao-ticket"
      serial 2318, "the-avatar-space-is-built-smallest-joy-first"
      serial 2322, "a-mac-dashboard-and-theatre-mode"
      serial 2323, "frontier-learning-picks-the-stores-adversarial-runs"
      serial 2324, "omnigen2-editscore-desktop-offline-small-fast"
      serial 2325, "second-hand-garments-for-the-avatar"
      serial 2326, "the-zone-sends-every-entity-in-view-under-a-byte-budget"
      serial 2327, "keypoints-supports-and-contacts"
      serial 2328, "finger-skin-weights-from-a-fitted-anny-hand"
      serial 2329, "learned-gait-phase"
      serial 2330, "elixir-on-a-guest-through-a-small-beam"
      serial 2331, "flex-20-min-2026-10-21"
      serial 2332, "a-marker-suit-measures-the-skin-soma-x-predicts"
      serial 2334, "decider-examples-from-traces"
      serial 2335, "ggml-stablehlo-bit-exact-on-pjrt"
      serial 2336, "pixal3d-as-a-ggml-rd-guest"
      serial 2338, "a-skin-fit-to-four-influences-on-the-gpu-l-bfgs-b"
      serial 2350, "inventory-in-a-private-journal"
      serial 2352, "second-hand-garments-for-the-avatar"
    end
  end
end
