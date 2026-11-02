# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2383, "the assistant draws with the pen through SteamVR priority mode", :discussion do
  flight_level :l1
  scope "how the assistant draws with the pen through SteamVR priority mode."

  prose ~S"""
  :: hook
  The assistant draws with the pen through SteamVR priority mode, not through the app.
  :: intrigue
  With priority off, the Frame's own serials hold the hands and the pen draws zero strokes.
  :: exit
  Run `tools/frame/run-xr.sh <tag> replay` on the Frame and check that `gate_replay.gd` asserts
  both hands' tracker profile is `/interaction_profiles/htc/vive_controller`.
  :: decision
  - The assistant draws with the pen through SteamVR, not through the app.
  - Slots 2 and up stay hidden handed trackers at priority -1.
  - No SteamVR global setting is touched. The physical controllers lose the hand roles by
    priority alone.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the assistant draws with the pen through SteamVR priority mode"

  prose ~S"""
  :: details The hands: priority mode
  &{repo("frame-controller-sim")} carries the Windows driver on `main`,
  keeping the aarch64 `build.sh` beside `build-win.sh`, and gains a `priority`
  key in `driver/vpen/resources/settings/default.vrsettings`, read in
  `CServerDriver::Init`. With it on, slots 0 and 1 activate as
  `TrackedDeviceClass_Controller` with `Prop_ControllerRoleHint_Int32`
  LeftHand and RightHand, `Prop_ControllerHandSelectionPriority_Int32`
  above the Frame controllers' own (read off `vrserver.txt` and
  recorded), `Prop_ControllerType_String = "vive_controller"` and the
  installed `{htc}/input/vive_controller_profile.json`, whose
  components (`trigger/value|click`, `grip/click`,
  `application_menu/click`, `system/click`, `trackpad/x|y|click|touch`,
  `output/haptic`) are what the pen's action map binds: `trigger`,
  `menu_button` for `pen_bridge.finish`, `primary_click` for boundary
  mode.

  The feeder, `tools/vpen_replay.py` on the Frame, is `vpen_feeder.py`'s
  `open_shm`/`write_frame` with `replay_oxrsys.py`'s plan loop: slot 1
  holds the plan's `calib` until `gate_replay.gd` writes
  `replay_plan.json`, then plays each stroke with the trigger down, a
  trackpad click when a stroke's boundary flag changes, and the
  application menu at the end. Slot 0 is parked left. `--live` reads
  JSON pose lines on stdin for a model to write. It keeps `--selftest`
  with its wrong-value control.

  Check, on the Frame, through `tools/frame/run-xr.sh <tag> replay`:
  `gate_replay.gd` asserts both hands' tracker profile is
  `/interaction_profiles/htc/vive_controller` and `run-xr.sh` finds
  `vpen_0` and `vpen_1` holding LeftHand and RightHand in the
  `vrserver.txt` slice it cuts. Controls: `PRIORITY=0` (the Frame's
  serials hold the hands, zero strokes, FAIL) and `NOFEED=1` (priority
  on, feeder not started, the calibration never settles, FAIL on the
  wall clock).
  """

  rebac do
    verbs_from 2351
    relate "rfd-2383", :provides, "steamvr-priority-pen-drawing"
  end
end
