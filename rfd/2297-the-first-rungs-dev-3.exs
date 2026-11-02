# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2297, "the first rung's dev.3", :discussion do
  flight_level :l1
  feature "the dev rung that follows dev.2 on RFD66606-2293's release ladder"
  scope "the pen's `v<date>-dev.3` release"

  prose ~S"""
  :: hook
  dev.3 is one Windows executable with its pack inside, played on the Frame.
  :: intrigue
  dev.1 and dev.2 shipped the double editor, the addon and the guest ELFs, so a player needs
  a pen checkout to open them.
  :: exit
  Read RFD66606-2293 next for the release rules that hold here.
  :: decision
  dev.3 ships the game as one Windows x86_64 executable with its `.pck`
  embedded, exported at double precision, and plays it on the Frame.
  :: related
  - RFD66606-2293, the workspace, the ladder and dev.1; its release rules hold here.
  - RFD66606-2296, dev.2; RFD66606-2298, dev.next.
  - RFD66606-2376, the headset; RFD66606-2370, the visual comparisons.
  """

  details_title "the first rung's dev.3"

  details "dev.3: one Windows game with its pack inside, on the Frame", ~S"""
  Operator, 2026-10-02.

  - Windows x86_64: `meshing-pen-windows.exe` with its `.pck` embedded
    and the addon's `libgodot_riscv.windows.template_release.double.x86_64.dll`
    beside it, released as two plain assets with no archive around them.
    There is no macOS export; Linux players run the Windows build through
    the compatibility layer, so there is no Linux export.
  - The export runs headless on the pinned Linux double editor from
    `ENGINE_TAG`'s templates, unsigned, by `tools/export_dev3.exs` in
    `release.yml`'s `export` job on an ubuntu runner, inside the job's
    five minutes; each engine call runs under `timeout`.
  - The release job FAILs when any asset is a `.zip` or a `.dmg`; its
    control plants `x.zip` and must fail.
  - Gate: `tools/smoke_export.exs` launches the exported executable on the
    Windows desk until it quits and finds `dress_on`, `curvenet`, `usd` and
    `mujoco` loaded from the pack. Its control, the bare double
    `template_release` executable beside the same `.dll`, carries no pack
    and must fail. No run forces headless, and CI's Windows runner has only
    a software rasterizer, so CI counts the smoke as unchecked and the
    logbook carries the desk's result.
  - Orbit views (also called contact sheets, turnaround sheets or
    turntable renders) of the joy features, rendered by the exported game
    running `tools/orbit_views.sgd` on the Windows desk and on the Frame,
    each with its `.cff` and `.tsv` under the contract-orbit-views
    standard and checked with the `zero_views` control.
  - Playtest: the release uploaded to the Frame as a development title by
    `tools/frame/push.sh` and played by a named person through
    `run-xr.sh`, with `still.sh` and `clip.sh` under `logs/`; the persona
    plays the same executable through oxrsys on the Windows desk. The
    Frame run happens when the operator asks for it, and the Mac desk is
    told before the headset is touched.

  dev.2 shipped the double editor, the addon and the guest ELFs for a
  checkout to open instead.
  """

  details "Which features are likely to bring joy", ~S"""
  Each forecast uses RFD66606-2412's sense-of-wonder rubric and RFD66606-2295's
  tag form.

  | rung | feature | criteria | joy |
  | --- | --- | --- | --- |
  | dev.3 | a development title on the Frame | none | (unlikely, p=0.20) |
  | dev.3 | one executable, no checkout | none | (unlikely, p=0.15) |
  """

  rebac do
    verbs_from 2351
    relate "rfd-2297", :provides, "windows-single-exe-frame-build"
  end
end
