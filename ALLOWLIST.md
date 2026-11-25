# Allowlist

Default deny. A source, model, runtime, dataset or tool is usable only if it is named here or
placed in the live goal manifest's `default.xml`; anything else is added here, with its licence
and role, before it is used. What was denied and why is in [`BLOCKLIST.md`](BLOCKLIST.md).

- **Placed projects:** every project `default.xml` places, on its side and pinned revision;
  `rf-detr-keypoint-data` and anything else derived from `val2017` is validation only.
- **Compute:** GPUs the operator owns, including Thunderbolt-attached eGPUs; the CPU only for
  orchestration and the DFC runtime; Metal and Core ML on macOS.
- **Rendering and runtime:** Godot 4 with its Vulkan renderer (MoltenVK on macOS), shipped as a
  native binary from `entities-godot-sandbox`; Mitsuba 3 GPU variants.
- **Inference:** ggml (RFD66606-2188) with the Vulkan backend; Gemma 4 (E2B, E4B); rf-detr keypoint
  and segmentation heads.
- **Language serving:** ninfer-all (Apache-2.0, our fork of `iamwavecut/ninfer-all`, kept in the
  repository `interactor-language-ninfer`), the CUDA
  engine and converter that serve Ternary Bonsai 2 27B (RFD66606-2311).
- **In-weights machine:** qwenputer (MIT, `divagr18/qwenputer`, used from our fork), a compiler
  that writes an RV32IM processor as Gated DeltaNet layers. Its circuit compiler, reference
  machine and calc firmware build the chip tower a Bonsai 2 server runs (RFD66606-2491;
  operator, 2026-11-13).
- **XR computer use:** interactor-xr-pilot (Apache-2.0 OR MIT, `V-Sekai-fire/interactor-xr-pilot`),
  an MCP server in Lean 4 with a panelspun window that lets an agent screenshot and drive an OpenXR
  app as an OXRSys client: head, controllers and buttons out, PyroWave decoded on the GPU in
  (operator, 2026-10-03).
- **Local agent:** Hermes Agent (MIT, `NousResearch/hermes-agent`) and its TUI, driving
  `gemma-4-12B-it-heretic-QAT` (Apache-2.0, `SC117/gemma-4-12B-it-heretic-QAT-GGUF`, from
  `google/gemma-4-12B-it`) served by LM Studio on this desk (operator, 2026-10-01).
- **Collision:** MuJoCo (Apache-2.0) as a godot-sandbox guest ELF from
  `interactor-mujoco-sandbox-demo`, for stroke-crossing detection in the CASSIE curvenet pass —
  capsule collision on host-supplied strokes through `mj_crossings`, no dynamics. A curve-geometry
  role distinct from the RFD66606-2238 MuJoCo Warp physics and pose-training use. The same guest also
  holds the Sakuragaoka Station port's colliders and walks the player through them (ray and contact
  queries, bit-deterministic and migratable); Godot's own physics is not used there (operator,
  2026-10-01).
- **Muscle skeleton:** MS-Human-700 (Apache-2.0, the `ms_human_700` model of
  `google-deepmind/mujoco_menagerie`): 80 bodies and 700 muscles on spatial tendons, compiled from
  its stock XML inside the same MuJoCo guest. It is the skeleton an ANNY avatar follows in the
  presence slice (RFD66606-2436): body transforms, tendon paths, foot contact points and inverse
  dynamics. This role is beside the collision uses of the row above, and it trains nothing
  (operator, 2026-11-13).
- **Frame codec:** Zstandard 1.5.7 (BSD-3-Clause, the BSD side of its dual licence,
  `facebook/zstd`), the version the engine bundles, by git subtree in a godot-sandbox guest. It
  codes each frame of 12 entity packets against a fixed dictionary file, as the engine's own
  delta encoder does, so a gate can measure the bytes without an engine build (RFD66606-2436;
  operator, 2026-11-13).
- **World services surface:** `fireflyk64/udon2godot` (BSD-2-Clause), read as the reference for
  the world services a game implements for converted world scripts: 114 public functions in seven
  files. The presence slice exposes that surface under our own names and nothing more. Its engine
  shim and its converter are not covered. The licence text and copyright line stay with any ported
  file (operator, 2026-11-13).
- **Matting:** BiRefNet_HR-matting (MIT), weights `ZhengPeng7/BiRefNet_HR-matting` from Hugging
  Face, draws the edge of a person mask over the RF-DETR instance; the MoGe-3 depth-edge check,
  not the matte, accepts the mask (RFD66606-2273).
- **Eye tracking:** `frame-eye-osc` (MIT), a Lean 4 program from `V-Sekai-fire/frame-eye-osc`
  that runs on the headset, reads the eye-tracking service's shared memory and sends OSC to the
  social-VR client (RFD66606-2271).
- **Marker suit:** the SOMA-2606.09246 muscle-anatomy code (MIT, `edualvarado/SOMA`), read and run only:
  its suit template, marker detection, triangulation and tracking, for the ChArUco capture suit
  (RFD66606-2332). Its SKIM captures are not covered until their terms are read (operator,
  2026-10-22).
- **Image generation and editing:** OmniGen2 through its native image-input pipeline;
  CycleGAN for photo-to-anime style transfer.
- **Masks from boxes:** SAM 2.1 hiera base+ (Apache-2.0, `facebookresearch/sam2`) as a ggml graph
  and a godot-sandbox guest in `interactor-hair-cards-guest`; Ternary Bonsai 2 gives the hair,
  face and person boxes it is prompted with. SAM 3 stays out (operator, 2026-11-20).
- **Hair cards:** HairDeck (Apache-2.0, `hyz317/HairDeck`): its card, colour and chain models as
  guests, no Blender and no PyTorch at run time. Its image models read DINOv3 features (DINOv3
  License, Meta, 2025-08-19: commercial use allowed, redistribution only under that agreement,
  no military or weapons use), so a release names that agreement beside the encoder's weights.
- **3D part labels:** GeoSAM2 (Apache-2.0 code and weights, `VAST-AI-Research/GeoSAM2`), SAM 2.1
  carried across views of a mesh; the source of its training objects is not named. PartField,
  P3-SAM, PartSAM and Point-SAM do not clear RFD66606-1028 (licence files read 2026-11-20).
- **Parts by instruction:** Alchemy3D-Instruct (Apache-2.0: the code's LICENSE, and the project's
  model card `libadi/Alchemy3D`, which names Instruct among its variants; the variant's own
  repository carries no card) with Qwen3.5-2B (Apache-2.0) on TRELLIS.2. Its Python pipeline
  calls nvdiffrast and nvdiffrec, which NVIDIA licenses for research and evaluation only, so
  those two stay out of anything shipped: a port uses the engine's own mesh export in their place.
- **Design system:** `contract-design-chibifire` (MIT): design tokens in the Design Tokens
  Community Group format, colours defined in OKLab, with CSS and a Godot theme; its faces are
  Marcellus, Cormorant Garamond, IBM Plex Sans and IBM Plex Mono (OFL-1.1, unmodified).
- **Body, pose and skinning:** ANNY, SOMA-X (the route to ANNY instead of SMPL),
  ANNY/SOMA-2603.16858's own pose library, synthetic poses, a licence-clean third-party motion set
  as a verified control; Delta Mush and Direct Delta Mush; FACS action-unit names for facial
  blendshapes.
- **Training data:** constructed synthetic renders from assets we hold (Live2D drawables, ANNY
  rigs, BVH poses); licence-filtered COCO `train2017`; `alfredplpl/anime-with-caption-cc0`
  captions only; generated synthetic data under the four conditions above; the cosplay photo
  library for validation only.
- **Quantization:** QAT with a quantized forward during training.
- **Environments and dependencies:** `pixi`, or an embedded interpreter pinning its deps in
  source; `default.xml` for dependencies.
- **Packaging:** nFPM (MIT, `goreleaser/nfpm`, v2.47.0) to turn built files into .deb and .rpm
  natively, as sinew-mocap's packaging does, and WiX Toolset v4 (MS-RL, `wixtoolset/wix`, 4.0.6)
  for the per-user Windows MSI, built through CMake's CPack WIX generator; build tools in CI, never
  shipped. nFPM replaces fpm here (operator, 2026-10-03). WiX replaces makeappx and signtool, and
  MSI rather than MSIX: an MSIX installs only once a certificate signs it and the user trusts that
  certificate, which a double-click cannot do (operator, 2026-10-04).
- **Mesh processing:** meshoptimizer (MIT, `zeux/meshoptimizer`) for simplification and its
  voxel remesher; xatlas (MIT, `jpcy/xatlas`) for UV unwrapping. Together they run remesh,
  simplify, unwrap and retexture on avatar meshes at build time, to cut polygon, skinned-mesh
  and material counts.
- **Stroke rendering:** Line3D from Cozy Cube's `lines_and_trails_3d` addon (MIT,
  `codeberg.org/MajorMcDoom/cozy-cube-godot-addons`), vendored into a project's `addons/`, draws
  pen strokes as camera-facing ribbons in Godot (operator, 2026-10-04).
- **Vector shapes:** slughorn (MIT, imported as `V-Sekai-fire/interactor-slughorn`) with its
  ThorVG (MIT) and Clipper2 (BSL-1.0) submodules, turning SVG into Slug curve and band data
  and baked meshes inside `slug.elf`, a godot-sandbox guest. The Slug patent was dedicated to
  the public domain on 2026-03-17 (operator, 2026-10-01).
- **Formats and figures:** `.usda`, ZStandard parquet, usdz as a delivery container, PSD,
  glTF with Khronos, VRM and `VSEKAI_` extensions, the CineForm SDK as the codec, hand-authored inline SVG for figures.
- **glTF behaviour:** the Khronos glTF 2.0 Interactivity extension, `KHR_interactivity` (CC-BY-4.0,
  `KhronosGroup/glTF`), the behaviour-graph vocabulary a taskweft domain and its RFD are described
  in, in place of the IEC 61131-3 function-block-diagram vocabulary (operator, 2026-10-29).
- **Still images:** OpenEXR (BSD-3-Clause, `AcademySoftwareFoundation/openexr`), its Python
  bindings 3.5.1 pinned where they are used, for scene-linear stills: orbit-view sheets
  (`contract-orbit-views`) and renders whose color is measured; a PNG made from one is a preview
  (operator, 2026-10-02: "please use openexr if possible").
- **Live streaming:** PyroWave (MIT, `Themaister/pyrowave`) with the Granite subset it checks
  out (MIT, `Themaister/Granite`), an intra-only wavelet codec whose Vulkan compute shaders are
  packed through Slang's `slangmosh` into SPIR-V; its macOS port uses hand-written MSL. For the
  desktop-to-headset stream; CineForm stays the recording codec (RFD66606-2287).
- **OpenXR runtime:** oxrsys (MPL-2.0, forked from `demonixis/oxrsys`), the desktop OpenXR runtime
  that streams to the Steam Frame over PyroWave, with its SteamVR driver and Android and Apple
  headset clients; it lives in `oxrsys/` of `V-Sekai-fire/interactor-xr-pilot`, merged with its
  history, and `V-Sekai-fire/interactor-oxrsys` is archived (operator, 2026-10-01; merged 2026-10-04).
- **OpenXR conformance:** the OpenXR CTS (Apache-2.0, `KhronosGroup/OpenXR-CTS`), its release
  `conformance_cli` run against oxrsys on this desk to measure the runtime's conformance; a test
  harness, never shipped (operator, 2026-10-03).
- **Desktop UI:** interactor-panelspun (Apache-2.0 OR MIT, `V-Sekai-fire/interactor-panelspun`),
  the docking panel framework XR Pilot's window and OXRSys tray are built on in place of Qt, vendored
  into interactor-xr-pilot's `third_party/` by git subtree. It carries SDL3 (zlib, `libsdl-org/SDL`) for windows, input and
  Vulkan surfaces, and ThorVG (MIT, `thorvg/thorvg`) for its software-canvas panels and text, both
  in its own `third_party/` by git subtree; its UI text is the Inter typeface (OFL-1.1,
  `rsms/inter`), embedded in the library (operator, 2026-10-03).
- **OpenVR driver API:** the OpenVR SDK (BSD-3-Clause, `ValveSoftware/openvr`, release v2.15.6) as
  the reference for an OXRSys SteamVR driver, entered clean-room: the driver lists only the
  interfaces, entry points and constants it uses in `.sigs` files, the pattern of Chromium's
  `tools/generate_stubs`, and generates its declarations and loader stubs from them; the SDK's
  headers are never vendored or included. OpenVR-only games reach OXRSys's PyroWave stream through
  SteamVR this way; OpenComposite stays blocked (operator, 2026-10-03).
  Alongside it: ALVR (MIT, `alvr-org/ALVR`) as a design reference only, cited and never copied;
  Chromium's `tools/generate_stubs` (BSD-3-Clause) to generate the declarations and stubs; and
  SteamVR as the PC VR runtime the driver loads into and is tested in on this desk.
- **Broadcast software:** OBS Studio and its plugins, without a row each: proprietary and GPL
  licences are fine, AGPL stays banned (operator, 2026-09-30; confirmed 2026-10-01).
- **Profiling:** samply (MIT OR Apache-2.0, `mstange/samply`), a sampling system profiler, records
  where a run's time goes, startup included; a dev tool, never shipped (operator, 2026-10-04).
- **Shader compilation:** Slang (Apache-2.0 with LLVM exception, `shader-slang/slang`), one
  kernel compiled to SPIR-V, Metal and a CPU library, so GPU and CPU are measured on one source.
- **Sign-in:** `wax_` (Apache-2.0, `tanguilp/wax`) verifies Uro's WebAuthn passkeys, and
  `nimble_totp` (Apache-2.0, `dashbit/nimble_totp`) makes its authenticator-app codes. Each was
  picked over a self-owned version because it has more hours in production (operator, 2026-10-01).
- **Root store:** the macOS Secure Enclave through Security.framework, Windows' NCrypt Platform
  Crypto Provider and DPAPI, and Linux `systemd-creds` (LGPL-2.1-or-later, 256 or later) with
  tpm2-tss (BSD-2-Clause) where systemd loads it for the TPM path, each sealing the offline-root
  seed of `tools/offline_ca.exs` (`V-Sekai-fire/interactor-fabric-zone`) to a key its own desk
  holds, with 2-of-3 Shamir shares on paper as the only written copy (operator, 2026-10-05).
- **Observability:** VictoriaMetrics, VictoriaLogs and VictoriaTraces (Apache-2.0,
  `VictoriaMetrics/*`), as release binaries pinned by sha256: the metrics, log and trace stores.
  Uro's OTLP traces go straight to VictoriaTraces (operator, 2026-10-01: "spin up victory metrics
  suite").
- **Protocol buffers:** `protoc` and its upb C generators (BSD-3-Clause, `protocolbuffers/protobuf`,
  as conda-forge's `libprotobuf` through pixi) with the upb runtime, generating the OTLP encoders a
  Godot guest ELF uses from the OTLP `.proto` files (Apache-2.0,
  `open-telemetry/opentelemetry-proto`) (operator, 2026-10-01: "can you codegen c using the official
  tool? it's faster").
- **Test assets:** procedurally generated geometry with analytic ground truth.
- **Sketching reference:** `V-Sekai/interactor-cassie` (MIT), the CASSIE sketching app's C#
  source, read as the reference the curvenet graph port is checked against; read only, never run,
  vendored or shipped (operator, 2026-10-05).
- **Verified C generation:** Trust-Lean (MIT, `V-Sekai-fire/trust-lean`, our fork of
  `lambdaclass/trust-lean`, pinned by tag), Lean 4 code generation that emits C with proofs, for
  the transport kernels and the RECTGTN planner's search (RFD66606-2304). Fixes land on our fork and
  nothing is sent upstream (operator, 2026-10-05).
- **Proof library:** Mathlib (Apache-2.0, `leanprover-community/mathlib4`) as Trust-Lean's
  dependency, at build time only, never shipped (operator, 2026-10-05).
