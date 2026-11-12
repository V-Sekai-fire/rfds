# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2342, "dev.1, the tray icon", :committed do
  feature "a tray icon with the stand-in mascot's face on macOS and Windows, the first dev
rung"
  scope "the tray's `v<date>-dev.1` release"

  prose ~S"""
  :: hook
  The tray icon ships first: one Godot scene with a borrowed mascot's face.
  :: intrigue
  Install, integrity, silence and uninstall must work before anything is drawn.
  :: exit
  Run the gates in `tools/gate_dev1.exs` against OXRSys.
  :: decision
  dev.1 ships one Godot scene, built with the pinned double editor and
  exported with its templates for macOS and Windows. A borrowed mascot's
  face is the icon. A click opens a popup with the version, a headset
  line, a zone line, a disabled "Draw" button and the mascot playing Idle.
  :: related
  - RFD66606-2343, dev.2, the first playable core.
  - RFD66606-2341, dev.next.
  - The FOSS release ladder this rung follows as defined: weftspun
    RFD66606-2262 (releases).
  - The private blocklist, the private pitfalls list and the private licence audit.
  """

  details_title "dev.1, the tray icon"

  prose ~S"""
  :: details dev.1: the feature
  One Godot scene, built with the pinned double editor and exported with
  its templates for macOS and Windows. The stand-in mascot's face is the
  icon. Clicking it opens a popup with:

  - the version;
  - a "headset: connected / not found" line;
  - a "zone: none" line;
  - a disabled "Draw" button;
  - a viewport where the mascot's glb plays Idle with its own materials.

  The tray becomes the zone host and the desktop client's launcher in
  dev.2, so it comes first.

  - macOS: a menu-bar status item via
    `DisplayServer.create_status_indicator`, guarded by
    `has_feature(FEATURE_STATUS_INDICATOR)`; ad-hoc signed; a DMG.
  - Windows: a system tray icon via the same API; a zip.

  The mascot is borrowed third-party work under MIT, not ours. It is the
  stand-in for dev.1 and dev.2, and no public asset shows it.
  :: details The pins, frozen from open to tag
  This file names every pin when the rung opens, and nothing moves until
  the rung tags. Bumps happen between rungs, as one batch, recorded in
  the logbook.

  - Engine: our Godot build fork's release v20260930-double.1, at the
    engine ref its release notes name, with the macOS arm64 editor and
    templates and the Windows x86_64 templates.
  - OXRSys and `xr_pilot_mcp`: our XR pilot interactor at the commit the
    logbook names.
  - The headset probe: the pen's OpenXR probe, from our meshing pen at the
    commit the logbook names.
  - The mascot: the borrowed stand-in (MIT), from the private character repo.
  :: details The reliability gate
  Every client logs frame times. At most 1 frame in 100,000 may exceed
  twice its budget (27.8 ms at 72 Hz), with zero crashes and zero
  disconnects across the playtest. It is measured on OXRSys and on the
  flat client. Control: a planted 30 ms stall every 10,000 frames must
  fail by count.
  :: details Gates and controls
  The tray's `tools/gate_dev1.exs` runs these against OXRSys.

  1. Install and launch from a fresh user account. The icon appears
     within 5 s. The version matches the tag. Control: a wrong version
     string must fail by name.
  2. Integrity. Signing waits on a signing identity, so dev.1 ships
     ad-hoc signed on macOS and unsigned on Windows, with one documented
     first-launch override. A SHA-256 per artifact is published and
     checked. Control: a tampered artifact must fail its hash by name.
  3. "headset: connected" only when an OpenXR session can be created on
     OXRSys. Control: `XR_RUNTIME_JSON` at a missing file must give
     "not found".
  4. Zero outbound connections in a 10-minute idle capture. Control: the
     off-by-default update check, switched on, must show exactly one.
  5. Uninstall leaves nothing behind. Control: a planted stray file must
     be named.
  6. The mascot's Idle plays in the popup, and the reliability gate holds
     over a 30-minute idle run. Controls: the glb removed must fail by
     path; the planted stall must fail by count.
  7. Churn: zero pin moves and zero edits to this RFD between open and
     tag. Control: a planted pin bump must fail by name.
  :: details The playtest
  The user, a teammate and one trusted outsider each install on a Mac or
  PC they own, from the release page, with no help beyond the written
  first-launch override. Pass: three icons running at day's end. Every
  install question is logged.
  :: details Which features are likely to bring joy
  Each forecast uses the sense-of-wonder rubric of RFD66606-2412 and
  the tag form of RFD66606-2295.

  | rung | feature | criteria | joy |
  | --- | --- | --- | --- |
  | dev.1 | tray icon | one override, hash-checked, silent | (remote, p=0.05): plumbing |
  | dev.1 | the mascot idles in the popup | the glb plays | (unlikely, p=0.20) |
  :: details The release
  `v<date>-dev.1` on the tray: a private release with the artifacts and
  their hashes, and `logbook/logbook-dev1.md` in the private manifest.

  After the tag: the three installs, the logbook, the counted gaps, one
  batch of pin bumps, and RFD66606-2343 (dev.2) opened with its pins
  frozen.
  :: details The problem
  In dev.2 the tray is the zone host and the desktop client's launcher.
  So the plumbing ships first, with a face.
  """
end
