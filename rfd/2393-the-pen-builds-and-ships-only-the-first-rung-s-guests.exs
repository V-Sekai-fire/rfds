# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2393, "the pen builds and ships only the first rung's guests", :discussion do
  flight_level :l1
  scope "which guests the pen builds and ships, and what leaves its build."

  prose ~S"""
  :: hook
  The pen builds and ships only the first rung's guests, and the next rung's guests leave its
  build.
  :: intrigue
  The pen's build loses the drape, fit, cage, headfit, motion and rfdetr ELFs in one PR, because
  `build.sh` runs drape's `gen.sh` unconditionally.
  :: exit
  Check a guest against the rule: it ships only if its `*.elf` is tracked at the pen's root and
  the header of its `main.cpp` describes it.
  :: decision
  - The guests &{repo("transport-meshing-pen")} ships are the `*.elf` files tracked at its root,
    each described by the header of its `main.cpp`. The ones it builds without shipping are the
    rest of `tools/build.exs`'s `@elfs`.
  - `motion.elf` and `rfdetr_seg.elf` build in &{repo("interactor-motion-guest")} and
    &{repo("interactor-rfdetr-seg-guest")}, not in the pen.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the pen builds and ships only the first rung's guests"

  prose ~S"""
  :: details The pen's build loses the next rung
  - The pen's build loses the next rung: `CMakeLists.txt` drops every
    `DRAPE_ROOT`, `LBFGSB_ROOT`, `GARMENT_FIT_ROOT`, `CAGE_ROOT`,
    `HEADFIT_ROOT`, `MOTION_GUEST_ROOT`, `RFDETR_SEG_ROOT`,
    `ANNY_KERNELS_ROOT`, `SINEW_ALIGN_ROOT` line and the `avbd`
    library. Xtools/build.exs`'s `@elfs` becomes
    `curvenet lasso usd probes dress_on rd_worker ggml_test` and its
    sysroot fetch moves to &{repo("repository-riscv64-sysroot")}.
    Xguests.yml` syncs the new manifest's names. The drape, fit, cage,
    headfit, motion and rfdetr ELFs and fixtures are deleted. One PR,
    because `build.sh` runs drape's `gen.sh` unconditionally.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2393", :provides, "pen-first-rung-guests-only"
    relate "rfd-2393", :is_a, "workspace-policy"
  end
end
