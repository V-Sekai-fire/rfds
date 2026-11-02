# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2419,
    "Git Bash on Windows runs slash-switch commands under a path-conversion guard",
    :discussion do
  flight_level :l2
  scope "how a desk runs slash-switch commands from Git Bash on Windows."

  prose ~S"""
  :: hook
  Run slash-switch commands from Git Bash on Windows under a guard so switches stay switches.
  :: intrigue
  What happens when Git Bash rewrites your switches into paths? And when an empty title arrives as
  `\"\"` and `start` tries to run `\`?
  :: exit
  Run your next slash-switch command from Git Bash under
  `MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'`.
  :: decision
  From Git Bash on Windows, a command with `/`-switches runs under
  `MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'`, so the switches are not rewritten into paths.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "Git Bash on Windows runs slash-switch commands under a path-conversion guard"

  prose ~S"""
  :: details The start command and Godot priority
  `start "" ...` goes in a `.cmd` file: passed inline, the empty title arrives as `\"\"` and
  `start` tries to run `\`. Godot raises its own process to above-normal priority, so a desk run
  lowers it by PID once started.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2419", :provides, "gitbash-pathconv-guard"
  end
end
