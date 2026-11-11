# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2394, "the template_release fault is diagnosed, not guessed", :discussion do
  scope "the template_release fault in the Step 1 build, and how it is diagnosed."

  prose ~S"""
  :: hook
  The template_release fault is diagnosed with a backtrace, not guessed at.
  :: intrigue
  A guessed fault has no backtrace behind it, and the rung ships on the editor build.
  :: exit
  Run `tools/probe_load.gd` flat and headless on the debug-symbol template, under the two
  controls, and put the backtrace into `logbook-steam-frame-sizing.md`.
  :: decision
  - The `template_release` fault is diagnosed, not guessed: the debug-symbol template, flat and
    headless with `tools/probe_load.gd`.
  - The rung ships on the editor build.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the template_release fault is diagnosed, not guessed"

  prose ~S"""
  :: details Controls and the backtrace
  The probe runs under the two controls already seen (no
  addon; single engine with single DLL), its backtrace into
  `logbook-steam-frame-sizing.md`.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2394", :provides, "template-release-backtrace-diagnosed"
    relate "rfd-2394", :is_a, "experiment-record"
  end
end
