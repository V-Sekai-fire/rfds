# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2465, "StableHLO: lower gather with indices computed at run time", :prediscussion do
  feature "the StableHLO lowering accepts gather with run-time i32 index arithmetic."

  scope "the gather case in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can an embedding lookup's `stablehlo.gather` run with its i32 indices computed at run time,
  not only known at compile time?
  :: intrigue
  An embedding lookup (`w[i]`) emits `stablehlo.gather` with i32 index arithmetic (add, compare,
  select, clamp) on values that arrive as arguments, but today i32 values are only accepted when
  they are known at compile time.
  :: exit
  Cases in `tools/gen_stablehlo_cases.py` cover gather, including zeros of both signs,
  infinities, NaN and denormals, compared bit for bit against XLA CPU's output from the Zen 2
  desk.
  :: decision
  - Carry run-time i32 values on the device once run-time i32 arithmetic lands, rather than only
    compile-time-known values.
  - Reduce the common gather forms, a row lookup and `take_along_axis`, to `ggml_get_rows`.
  - Refuse the general gather form with `UNIMPLEMENTED` rather than approximate it.
  - Add gather cases to `tools/gen_stablehlo_cases.py` with the special values above; a planted
    control case must fail its gate, and all 11 desk gates still pass.
  :: related
  - RFD66606-2372, the guest ELF and ggml-rd compute route this kernel runs on.
  """
end
