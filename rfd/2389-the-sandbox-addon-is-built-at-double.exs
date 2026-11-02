# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2389, "the sandbox addon is built at double", :discussion do
  flight_level :l1
  scope "the double-precision sandbox addon build, its release and its vendoring."

  prose ~S"""
  :: hook
  The sandbox addon is built at double from a pinned commit and recorded in CITATION.cff.
  :: intrigue
  Which double binaries can be trusted when some in taskweft-godot-sandbox are unrecorded?
  :: exit
  Check the addon's commit, flags and sha256 in `CITATION.cff` against the build command in
  RFD66606-2389.
  :: decision
  The addon at double is built from &{repo("entities-godot-sandbox", planned: "4-entities")} at
  `b1118e` plus its binary-translation emitter, by `addon.yml` in the same workflows' home. It is
  released on a tag and vendored into `addons/godot_sandbox/bin` under the names the
  `.gdextension` already maps, with commit, flags and sha256 in `CITATION.cff`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the sandbox addon is built at double"

  prose ~S"""
  :: details The build command and the unrecorded binaries
  The build is
  `scons platform=windows arch=x86_64 target=template_release precision=double use_mingw=yes
  use_llvm=yes`,
  the linux x86_64 and macos arm64 twins. The unrecorded double binaries in
  `taskweft-godot-sandbox` are not copied.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2389", :provides, "sandbox-addon-double-pinned"
    relate "rfd-2389", :spends, "actions-builds-double-binaries"
    relate "rfd-2389", :is_a, "ci-gate"
  end
end
