# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2287, "the first rung: draw it and wear it in a headset", :discussion do
  flight_level :l1
  feature "A person in a headset draws an outfit with the pen and wears it,
while a second person in the same zone sees it and talks with them; a
worker zone makes the garment, and its ghost materializes in their zone"
  scope "entities-godot master built with precision=double, the godot-sandbox addon at
the same precision, transport-meshing-pen, and the zone, client, CA, asset, lasso, voice and
garment-stage guest ELFs. The Steam Frame runs as a PC VR headset streamed from the desk."

  prose ~S"""
  :: hook
  A person in a headset draws an outfit and wears it, and a second person sees it.
  :: intrigue
  RFD66606-2262 asks whether people make and wear what they draw where others see it. Only
  people in the world answer that.
  :: exit
  Read RFD66606-2262 next, the ladder this rung sits on.
  :: decision
  The first rung is two people in one zone, each with their own avatar: one in a headset, one on a
  desktop. They see each other and talk. The engine is base Godot built with double precision and
  the godot-sandbox addon, and it relays UDP and nothing else.
  A worker zone owns the garment
  while it makes it. Its ghost materializes in the players' zone, and then its ownership hands
  over to that zone. One zone owns it at every frame. The garment attaches rigidly to the avatar's
  bones. The headset is the Steam Frame on a PC VR stream from the desk. The Frame's
  standalone mode and the Steam Deck run the win64 build through FEX (RFD66606-2360, operator,
  2026-11-01).
  :: related
  - RFD66606-2262, the ladder; RFD66606-2136, the precedent; RFD66606-2263, step 2's test.
  - RFD66606-2256, the transport; RFD66606-2271, guests with Lean tests; RFD66606-2288,
    capabilities.
  - RFD66606-2420 to RFD66606-2427, the rung's build, headset, interface, setting, fitting,
    avatars and timing, one RFD each.
  """

  details_title "the first rung: draw it and wear it in a headset"

  prose ~S"""
  :: details What the rung abandons
  Abandons RFD66606-2211, RFD66606-2001 and RFD66606-2075: the engine is base Godot. Zones are
  `zone.elf`.
  :: details What computes
  Everything that computes is a C++
  guest ELF on ggml-rd or compute-rd: the WebTransport stack (RFD66606-2256), the zones, the
  certificate authority, the voice codec and the dress-on loop.
  :: details Why the engine stays base Godot
  The fabric already proves one owner per entity across zones. The rung
  carries that rule into a guest, so the engine stays base Godot.
  :: details The critical path
  Each step starts when the one before it runs. Each names its
  repository, what is missing, and its check.

  1. **Build.** Base Godot `master` with `precision=double` for x86_64
     Linux and Windows, and the godot-sandbox addon rebuilt at double
     precision. The headset runs the Windows build through its
     compatibility layer. A desktop OpenXR runtime also streams to it,
     and that stream is PyroWave, an intra-only wavelet codec in
     Vulkan compute whose exact rate control holds a frame to its byte
     budget. CineForm stays the recording codec. The Windows double
     editor build holds 72 fps in the headset. The exported
     `template_release` build faults in a `StringName` copy once the
     sandbox addon loads, and the Linux x86_64 build lacks XCursor and
     xkbcommon in the compatibility layer's root filesystem.
     Check: an OpenXR session starts on each path and the pen scene
     draws in it. Transport-meshing-pen's headless gates pass on the double build.
     A path that fails is logged with its error, and the rung goes
     ahead on the other. (&{repo("entities-godot")}, the godot-sandbox addon)
  2. **Draw.** Strokes become a curvenet in the headset through
     `curvenet.elf` in the pen's sandbox, in the xr-grid scene, with
     the lasso from `lasso.elf` for picking far targets. Check:
     RFD66606-2263's replay still passes. The Lean tests link the lasso's C++
     and check it picks the target nearest the cone's axis, with a
     control that swaps two targets' distances.
     (&{repo("transport-meshing-pen")}, &{repo("interactor-lasso")})
  3. **Wear.** The garment attaches rigidly to the avatar's bones; a
     mirror shows it. Check: a still from the headset's view.
     (&{repo("transport-meshing-pen")})
  4. **Transport and lock-down.** picoquic with h3zero, TLS 1.3 through
     picotls on mbedTLS, in the guest; the host relays UDP through
     `PacketPeerUDP` and never sees plaintext. Connections are direct.
     `ca.elf` makes the session's root key in guest memory and issues
     one-hour certificates for zones and players, names limited to
     `*.zone.fabric.internal`. Every end accepts only that root. A
     guest's VM carries its memory, so every VM transfer (serializing
     it, snapshotting it, moving it to another zone, or a host read of
     its memory) needs a capability: a macaroon that a ReBAC check
     mints (RFD66606-2288). `ca.elf` gets no transfer capability. Check,
     each with its control: a certificate from another CA is refused,
     an expired one is refused, an out-of-pattern name is not issued,
     and a transfer with no capability is refused while the same
     transfer goes ahead once its capability is minted.
     (&{repo("interactor-fabric-zone")})
  5. **Zone.** `zone.elf`, all of `modules/multiplayer_fabric` as a
     guest (entity pools, STAGING, ghosts, the SQLite journal and the
     predictive BVH), hosting the headset and desktop clients with a
     humanoid pose payload for both avatars. Check: each client sees
     the other's pose. The Lean tests search for a frame with two
     owners or none, with a control that plants a double hand-off.
     (&{repo("interactor-fabric-zone")})
  6. **Worker zone.** A second `zone.elf` takes a stroke set and runs
     `curvenet.elf`, its kernels on compute-rd, and stores the garment
     with `asset.elf` (casync). The garment's ghost, carrying its hash,
     materializes in the players' zone, each client fetches it by the
     hash, then its ownership hands over. Check: exactly one zone owns
     the garment at every frame. A fetched garment's chunks match its
     index, with a control that corrupts one chunk and must be caught;
     RFD66606-2426 times the handover.
  7. **Talk.** `voice.elf`, the Opus codec as a guest, sends its packets
     as WebTransport datagrams, played at the speaker's avatar. Check:
     speech round-trips between the two clients; the Lean tests check
     a decoded frame against its input, with a dropped-packet control.
     (&{repo("interactor-voice")})
  8. **Evidence.** One session, the person in the headset and the
     operator on the desktop, recorded as CineForm, with the zone
     logs.

  If the end of the rung's window arrives short, the steps land in this
  order and the rest wait: build, draw, wear, then transport and zone,
  then talk.
  :: details What the rung leaves out
  | Left out | Why | The rung that takes it |
  | --- | --- | --- |
  | Fit and drape | the fit takes about 10 minutes | the next rung, on the worker zone |
  | Moving through the world | needs the retargeted, grounded clips | the next rung |
  | The shared Bao signing the CA | needs one signing grant (RFD66606-2142) | the next rung |
  | VRM export | delivery, not the rung's question | the shareable release |
  """

  rebac do
    verbs_from 2351
    relate "rfd-2287", :provides, "headset-draw-wear-rung"
    relate "rfd-2287", :spends, "guest-elf-double"
    relate "rfd-2287", :spends, "fex"
    relate "rfd-2287", :spends, "webtransport-guest-signer"
    relate "rfd-2287", :spends, "guest-macaroon-capabilities"
    relate "rfd-2287", :spends, "lean-tested-cpp-guests"
    relate "rfd-2287", :spends, "steam-frame-headset-sizing"
    relate "rfd-2287", :spends, "xr-grid-cassie-interface"
    relate "rfd-2287", :spends, "sakuragaoka-plaza-setting"
    relate "rfd-2287", :spends, "sketch-keypoint-body-fit"
    relate "rfd-2287", :spends, "apache-avatar-pair"
    relate "rfd-2287", :spends, "per-leg-handover-timing"
    relate "rfd-2287", :spends, "handover-timing-planted-levels"
    relate "rfd-2287", :is_a, "release-rung"
    relate "rfd-2287", :owns, "rfd-2420"
    relate "rfd-2287", :owns, "rfd-2421"
    relate "rfd-2287", :owns, "rfd-2422"
    relate "rfd-2287", :owns, "rfd-2423"
    relate "rfd-2287", :owns, "rfd-2424"
    relate "rfd-2287", :owns, "rfd-2425"
    relate "rfd-2287", :owns, "rfd-2426"
    relate "rfd-2287", :owns, "rfd-2427"
  end
end
