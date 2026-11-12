# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2341, "dev.next", :discussion do
  feature "the parked work that no numbered dev rung has claimed"
  scope "everything past dev.2 that waits for a rung of its own"

  prose ~S"""
  :: hook
  Parked work waits in one place, and no open rung changes to make room for it.
  :: intrigue
  Reducing churn is an absolute requirement. An ask added to an open rung moves its pins or
  edits its file, which the churn gate counts as a failure.
  :: exit
  Write a new ask into dev.next instead of an open rung, and check that the open rung's file and
  pins stay unchanged. The sections below list the parked items.
  :: decision
  dev.next holds every ask that no numbered rung has claimed. An idea
  that arrives while a rung is open is written here, and the open rung's
  definition does not change. An item leaves dev.next when a numbered
  rung is planned around it.
  :: related
  - RFD66606-2342, dev.1; RFD66606-2343, dev.2; RFD66606-2344, dev.3.
  """

  details_title "dev.next, parked and not designed"

  prose ~S"""
  :: details The parked items
  - An original mascot, swapped into the stand-in mascot's three slots
    (the tray icon, the popup, the requests in the world).
  - A thematic world that replaces the placeholder backstory and
    explains the dummy, the requests, the shared world and the
    persistence.
  - The vehicle story, chosen as a ladder of choices. You carry the
    atelier as a sample case and deploy it on any flat surface. The
    dress form is in the lid and the ledger is the lining. Closing the
    case writes the journal. Opening it replays the journal. AR comes
    first: the alpha blend mode with nothing drawn behind the case,
    which OXRSys already accepts with `passthrough_enabled`. VR is the
    same scene in the opaque mode. The case is the town (operator,
    2026-10-09): opened, it holds the procedural station town the pen
    already vendors (MIT) as a diorama you look into, like a tabletop
    Japanese town built in a wooden tray. It is not a case of building
    pieces carried through a full-size town. This is the station RFD66606-2343
    left for a later rung. The surface is found by MoGe-3 (MIT) when you set
    the case down. In AR it reads the colour stereo pair from the
    headset's colour camera module, on the expansion port. The built-in
    cameras are monochrome and are not used. In a social VR world we did
    not build, it reads the rendered eye pair. Its metric points and
    normals give the plane, and the second eye checks the first. Without
    root, the headset's runtime publishes one colour view as a loopback
    camera that the video group can read; it advertises 1920x1080 at 30
    fps and measured 1.4 to 3.8 fps. Its own camera API is off by
    default. MoGe-3 runs as a godot-sandbox guest ELF on ggml-rd, the
    shape RFD66606-2272 proved for segmentation. Its weights come
    through the weight pump, and no Python is in the running path. It
    spends no innovation token: it is one more guest on the route
    `zone.elf` and `curvenet.elf` already use. With no confident plane,
    the case falls back to the controller pose. Its dense graph is 1,406
    nodes. ggml-rd lacks only replicate padding and one antialiased
    resize. Its sparse 3D refiner has no ggml-rd kernels and is left
    out. Passthrough is tested sim-to-real in virtual worlds only. Two
    held-out sets are frozen before they render: path-traced rooms built
    from CC0 scanned furniture, and the station, whose build publishes
    every seat height. The station set matters because MoGe is unproven
    on stylized frames. Gate: the surface under the crosshair, scaled by
    the floor at the tracked eye height, lies within 3 cm of truth.
    Controls: a frame with no flat surface must fall back, and
    `GGML_RD_FAULT=1` must fail the fit. RFD66606-2313 parks the full
    loop over colour passthrough on this surface.
  - Lookdev: style frames for the world, the mascot, Maro in SCSS and
    the dummy. Image generation waits for a rung.
  - A mechanics search, ranked by best-of-breed sorting and valuation.
    A first pass on public evidence is running, and its result lands
    here.
  - Shared-world building gameplay, which follows from the world and the
    mechanics search.
  - The shared world of two, cut from the first dev.2 draft (operator,
    2026-10-12): the tray as zone host for two clients over ENet on
    localhost, the FDB-SQLite wardrobe that survives a zone restart, the
    three fabric-zone changes (`set_payload` and `zone_despawn`,
    `Journal::replay` on open, the payload in `pack_intent`), the stand-in
    mascot's 36 never-repeating requests with one constraint each, the backstory, the
    fourteen signs and the ledger board, two procedural audio cues, and the
    two-person playtest.
  - Wearing on Maro: the fit against her body mesh, the clothing hide in the
    same frame, no bone off rest scale, the pop-on, and Maro in the ported
    SCSS. No dev.2 gate reaches past MESH.
  - The avatar's tail opening (operator, 2026-10-17). The opening is
    cut in the cardigan, the outer layer, fitted tight around the tail's
    base, and the dress keeps a small slot under it. No flap, lap panel,
    ruffle trim or bow covers it, and the tail is kept. The cut is the
    tail base's sweep over the motion clips plus 5 mm. The tail's long
    strands still cross the cardigan in motion; that is open.
  - The Windows x86_64 executable, signing once a legal entity is chosen,
    spatial voice, controller walking and the first headset test.
  - The guest transport (QUIC, TLS and the session CA in guests) for
    friends over the internet.
  - The Hilbert AOI band ported into `zone.elf`, for neighbour zones.
  - Binary translation in the pen (dev.3 logbook). The pen's
    `tools/build.exs` sets `GODOT_SANDBOX_BINTR_UNITS`, compiles the
    units in parallel and links one library per guest, and the pen
    vendors an addon at or after the godot-sandbox commit the dev.3
    logbook names. Split into 24
    units, `usd` compiled and linked in 81 s; as one file it ran past
    7 min on one core. Gate: every guest the probe loads reports
    translated. Control: the probe with no `bintr/` fails by name.
  - The dev.3 gaps, each counted in the dev.3 logbook: the CASSIE dress
    replay (90 of 102 cycles) and a dress-layer control; the OpenXR
    alert that hangs a gate with no runtime; `--xr-mode off` in the
    world-grab usage line; a stall control in the pen's reliability
    gate; a churn tool with its planted pin bump; a windowed Windows
    export in the tray's `release.exs`; the tray's Dock tile.
  - RFD66606-2349's file check on the house recorder's recordings, which
    dev.3 did not run (dev.3 logbook, The verdict). The recorder's MKV
    carries CineForm frames, the
    codec a `.cfhd` holds. `av1mkv` builds on Windows only; the MKV reader
    in entities-godot's media I/O can read it on any desk (operator,
    2026-10-12).
  - A pin for every project a rung names, as a commit or as a tag-like
    branch that does not move by convention (operator, 2026-10-20:
    branches are preferred). The private manifest tracked 8 of its
    projects at `main`, the tray and the double engine among them, so a
    merge moved what a sync checks out and the churn gate counted nothing
    (dev.3 logbook, gate 8). `tools/churn_gate.exs` now reads a branch
    row's tip from the checkout, now and at open, and a moved tip fails by
    name, so `main` cannot serve as a rung's pin.
  - A loading screen in the pen (operator, 2026-10-12): the app shows it
    from launch until the world is ready, in place of the engine's boot
    splash, which every dev.3 recording opens on for up to 30 s. It is
    not white or drab (operator, 2026-10-12): it carries the world's own
    colour and something that moves, so a wait reads as the app. The pen
    is an upstream fork read-only from the private org, so it lands through the
    pen's own repo and a pin bump.
  - No magenta in the pen (operator, 2026-10-12: "magenta is ugly").
    The dev.3 recordings in flat mode (the orbit, gate 1 flat and the
    drop_seam control) show the engine's missing-texture magenta, so a
    material does not load there. A gate check fails a frame that carries
    it, with a planted missing texture as the control.
  - Gate recordings from the runtime's stream, not the screen (dev.3
    logbook, Recordings): four of eight screen captures miss the gate's
    subject. With it, an orbit that drives the camera the window draws
    from, so the contact sheet shows ten views.
  - A fast loop split from the soak (operator, 2026-10-12). Every gate's
    quick form runs on each change, about 2 min in all. The 30-minute
    soaks run once per rung, in the background, and never hold the
    logbook or the pull request; their result is appended when it lands.
    dev.3 spent about 70 min of its cycle on soaks run one after another.
  - Three tray checks that dev.3 left NOT RUN (operator, 2026-10-12):
    the first launch past the OS download warning, which needs a download
    that carries the mark of the web and a person to click Run anyway,
    and the install from a fresh account, on Windows and on macOS.
  - decider-pong, a Pong recording where a live model drives one paddle.
    It sits in the interactor tier, beside its pinned upstream decider.
    Two questions wait for a rung. Its
    Python breaks the languages rule, so it is ported to Elixir or to the
    engine, or it gets a named exemption. Its name lacks the
    interactor side prefix, which needs a rename by the user on the forge
    and one manifest line. RFD66606-2346 records how it was placed.
  :: details Parked work held in manifest issues
  Each item below has an issue on the private manifest, which holds the
  state and how to resume.

  - One set of repository settings across the two orgs, the pr-credit
    lease, and the private bootstrap's Nushell, Erlang and Elixir tools.
  - The Lean v4.34.1 move, 43 of 45 pull requests merged, and the CI
    circuit breaker.
  - The Sakuragaoka Station port: the blossom cluster LOD, the headset
    budget and the credit ledger.
  - XR Pilot fixes, one CI slot per repository, and the org's CI state.
  - An honest real-time Snake video, recorded with the house recorder in
    CineForm.
  - The forge READMEs still off the house shape, and the README churn
    gate run on this workspace.
  :: details The problem
  Parked work still needs one place to wait.
  """
end
