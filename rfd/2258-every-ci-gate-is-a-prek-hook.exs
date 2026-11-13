# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2258, "every CI gate is a prek hook", :committed do
  feature "One CI job runs prek, and every gate the workflow ran is a
hook a desk can run the same way"
  scope "`.github/workflows/checks.yml`, `.pre-commit-config.yaml` and
ruleset 23145233 in this repository"

  prose ~S"""
  :: hook
  One CI job runs prek, and a desk runs every gate the same way.
  :: intrigue
  Nine jobs repeated checks prek could run, and the ruleset required nine names that had to
  match the workflow by hand.
  :: exit
  Run a `ci-*` hook locally with `GATE_BASE` set; the sections below hold what was measured.
  :: decision
  The workflow has one job, `prek`. Gates that need only the tree
  are ordinary hooks. Gates that need a base ref or a code-host
  token are `ci-*` hooks in the manual stage, which the job calls by
  id with `GATE_BASE` and `GH_TOKEN` set; a local commit never runs
  them. An unset `GATE_BASE` fails the hook. The merge queue
  requires no check (operator, 2026-11-13), so both steps of the job
  are run on the desk before a pull request is enqueued.
  :: related
  - RFD66606-2245, the red merge that made gates required.
  - RFD66606-2232, the render every gate reads.
  """

  details_title "every CI gate is a prek hook"

  prose ~S"""
  :: details What is measured
  Locally through prek 0.5.3, `ci-comment-ladder`,
  `ci-trope-density`, `ci-spdx` and `ci-rfd-canary` pass on
  `main/main`, and `ci-comment-ladder` fails with `GATE_BASE` unset.
  On the pull request that landed it, `prek` passed.
  :: details Warnings kept honest
  jose 1.11.12, pulled in by ex_mcp, uses bare `catch`, which OTP 29
  deprecates. The job silences that one warning only when jose, OTP
  and Elixir read 1.11.12, 29 and 1.20.4, and any other tuple leaves
  the warnings on with a notice naming what it found.
  :: details The problem
  Nine jobs repeated checks prek could run, each rendering the RFDs
  again, and the ruleset required nine names that had to match the
  workflow by hand. The list the working agreements stated had
  already drifted from the ruleset.
  """
end
