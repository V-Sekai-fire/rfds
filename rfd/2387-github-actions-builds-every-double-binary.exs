# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2387, "GitHub Actions builds every double binary", :discussion do
  flight_level :l1
  scope "the workflows that build and release the double engine binaries."

  prose ~S"""
  :: hook
  GitHub Actions builds every double binary, so no engine binary is built by hand again.
  :: intrigue
  The engine fork keeps upstream's nine workflows off and pays no runner minutes for them.
  :: exit
  Check a new double binary against the rule: it comes from a release on a tag `v<date>-double.N`.
  :: decision
  - GitHub Actions builds every binary. Nothing is built by hand again.
    &{repo("service-godot-build")} is the workflows' home, so the engine fork keeps upstream's
    nine workflows off and pays no runner minutes for them.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "GitHub Actions builds every double binary"

  prose ~S"""
  :: details The double.yml matrix and the release
  Its `.github/workflows/double.yml` checks out &{repo("entities-godot")} at the pinned commit and
  runs a matrix of `windows-x86_64` (llvm-mingw 20260922, `use_mingw=yes use_llvm=yes`),
  `linux-x86_64` and `macos-arm64`, each at `precision=double` for `target=editor` and
  `target=template_release` (`debug_symbols=yes` on the template, for the fault below), sccache on
  the runner's cache, and a release on a tag `v<date>-double.N` carrying the six binaries and
  their sha256s. The escript in the same repository gains `--precision` and `--extra` so the
  Windows job replays on a Windows desk when a runner is not at hand. The pen's `CITATION.cff`
  records the engine commit, the toolchain, the flag line and each sha256. The Frame pulls the
  Windows release with `curl` over `ssh frame` into `~/rfd2287/godot-dbl`. This Mac pulls the
  macOS
  one.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2387", :provides, "actions-builds-double-binaries"
  end
end
