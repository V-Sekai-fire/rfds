# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2468, "StableHLO: run-time i32 arithmetic", :prediscussion do
  feature "run-time i32 values become i32 tensors on the device instead of a refusal."

  scope "the StableHLO lowering in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can an i32 value computed at run time reach the device, instead of being refused because it
  was not already known when the graph was compiled?
  :: intrigue
  Today an i32 value is folded away on the host whenever the compiler already knows it, and
  refused the moment it is computed at run time: an argument, or anything derived from one.
  Gather's index arithmetic and dynamic masks need those values on the device, not on the host,
  and the five graphs the probes run (qwen, dit, sconv and the two Kimodo layers) all touch one.
  :: exit
  Run the generated cases, including zeros of both signs, infinities, NaN and denormals, against
  XLA CPU's own output from the Zen 2 desk as the reference, and confirm a case built to fail
  does fail.
  :: decision
  Hold run-time i32 values as i32 tensors on the device, and add element-wise kernels under XLA's
  wrapping semantics: add, subtract, multiply, compare, select, clamp, and convert to and from
  f32. Lift each refusal that exists only for lack of one of these kernels, case by case, so that
  every case in the generator is either bit-equal on the GPU or carries a measured reason in
  XFAIL, with all 11 desk gates kept green throughout.
  """

  details_title "StableHLO: run-time i32 arithmetic"

  prose ~S"""
  :: details Cases and reference
  tools/gen_stablehlo_cases.py exercises the special values a run-time i32 path must survive:
  zeros of both signs, infinities, NaN and denormals. XLA CPU's own output, taken from the Zen 2
  desk, is the bit-equal reference for every case; there is no other oracle in use here.

  :: details What ships
  - Run-time i32 values held as i32 tensors on the device, never folded away because they were
    not known at compile time.
  - Element-wise kernels: add, subtract, multiply, compare, select, clamp, and conversion to and
    from f32, each under XLA's own wrapping semantics rather than a saturating one.
  - Refusals lifted only where one of the kernels above now covers the case; a case no kernel
    covers keeps its refusal unchanged.

  :: details Acceptance
  - Every case in tools/gen_stablehlo_cases.py is bit-equal on the GPU, or carries a measured
    reason recorded in XFAIL.
  - A case built to fail does fail; a gate that cannot fail proves nothing.
  - All 11 desk gates still pass after the change lands.
  """
end
