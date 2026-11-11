# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2302, "guest work runs in frame slices", :discussion do
  feature "No work blocks the engine's main loop longer than one 144 Hz frame, and every
load, test and solve has a stated wall-clock budget"
  scope "the godot-sandbox host calls into guest ELFs, the pen's scene load, its tests and
gates, and each guest solve"

  prose ~S"""
  :: hook
  Every guest call fits a frame slice, and every load, test and solve has a budget.
  :: intrigue
  A guest call returns when it is done, so a long solve stalls every frame behind it.
  :: exit
  Read `logbook-guest-frame-budget.md` for the station scene and dress flow measurements.
  :: decision
  No work blocks the main loop longer than one 144 Hz frame, 6.94 ms.
  Guest work runs in slices: the host first asks nicely, through a
  yield request the guest polls at its safe points, then suspends the
  guest by instruction limit and resumes it the next frame. A scene
  loads to its first frame in 5 s or less, every test or gate run is
  capped at one minute, and each solve, one guest call or one stroke
  commit, times out at 60 s.
  :: related
  - RFD66606-2287, the rung whose headset runs at 144 Hz; RFD66606-2263, the replay gate.
  - RFD66606-2390, native translation, which shrinks every slice's count.
  - RFD66606-2274, the MuJoCo guest; RFD66606-2265, curvenet off the main thread.
  """

  details_title "guest work runs in frame slices"

  prose ~S"""
  :: details Asking, then suspending
  The guest exposes a yield flag it reads at safe points, between
  strokes, between cycles, between solver iterations, and returns
  with its state kept when the flag is set. A guest that does not
  yield in time is suspended by the sandbox's instruction limit
  (`Sandbox.set_instructions_max`, with `execution_timeout` as the
  wall-clock bound), which stops it as abruptly as a kill but keeps
  the machine state, and the host resumes it on the next frame. The
  first path costs nothing to resume; the second is the guarantee.
  :: details Thread groups are not a slice
  `Node.process_thread_group = SUB_THREAD` runs a node's `_process` on
  a worker thread, and the frame still waits for it. The station
  build placed in a sub-thread `_process` held frame 2 for 19.7 s.
  Thread groups run independent sandboxes in parallel within one
  frame; they do not hide a long call.
  :: details The budgets
  | What | Budget | On overrun |
  | --- | --- | --- |
  | One main-loop step | 6.94 ms, one frame at 144 Hz | the guest is suspended until next frame |
  | Scene load to first frame | 5 s | the load fails by name |
  | One test or gate run | 1 minute | the run fails, never a silent skip |
  | One solve: a guest call or a stroke commit | 60 s | the solve times out and fails |

  The station scene and the dress flow measured on 2026-10-04 are in
  `logbook-guest-frame-budget.md`.
  :: details The problem
  Moving the call to a sub-thread does not help: a
  frame ends only when every thread group's `_process` returns.
  """
end
