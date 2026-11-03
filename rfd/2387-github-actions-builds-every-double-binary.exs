# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2387, "GitHub Actions builds every double binary", :discussion do
  flight_level :l1
  scope "the workflow that builds and releases the double engine binaries."

  prose ~S"""
  :: hook
  GitHub Actions builds every double binary a rung runs or ships, so none of those is built by
  hand again.
  :: intrigue
  The release lands on the assembled engine, not on a side repository, so a binary names the
  exact tree it was built from.
  :: exit
  Check a double binary that a rung runs or ships against the rule: it comes from a release on an
  entities-zone release tag.
  :: decision
  - GitHub Actions builds every double binary that a rung runs or ships. A build on a desk from
    a dev branch is not covered (operator, 2026-11-03).
  - Releases go on entities-zone (operator, 2026-11-03). The workflow lives on the
    engine branch `dev/double-release` of &{repo("entities-godot")}, and
    entities-assembly merges it into `r0-base`, so every release carries it. The
    workflow changes only through that branch and the assembler (operator, 2026-11-03).
  - The engine fork keeps upstream's nine workflows off and pays no runner minutes for them.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2312, the release tag the assembler computes.
  """

  details_title "GitHub Actions builds every double binary"

  prose ~S"""
  :: details The double.yml matrix and the release
  `.github/workflows/double.yml` runs on each `v0.0.0-<UTC time>-<commit>` tag the assembler
  pushes to entities-zone, and on a dispatch with `release_tag` set. It builds the
  tagged tree in a matrix of `windows-x86_64` (llvm-mingw 20260922, `use_mingw=yes
  use_llvm=yes`), `linux-x86_64` and `macos-arm64`, each at `precision=double` for
  `target=editor` and `target=template_release` (`debug_symbols=yes` on the Windows template,
  for the fault below), with sccache on the runner's cache. It publishes the six binaries and
  their sha256s as a release on the tag.
  :: details Replaying a job on a desk
  The escript in &{repo("service-godot-build")} takes `--precision` and `--extra`, so the
  Windows job replays on a Windows desk when a runner is not at hand. The pen's `CITATION.cff`
  records the engine commit, the toolchain, the flag line and each sha256. The Frame pulls the
  Windows release with `curl` over `ssh frame` into `~/rfd2287/godot-dbl`. This Mac pulls the
  macOS one.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2387", :provides, "actions-builds-double-binaries"
    relate "rfd-2387", :is_a, "ci-gate"
  end
end
