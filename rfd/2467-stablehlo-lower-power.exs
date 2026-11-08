# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2467, "StableHLO: lower power", :prediscussion do
  feature "the StableHLO lowering accepts power for a RoPE frequency table computed at run time."

  scope "the power case in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can a power kernel on the GPU match XLA CPU's call into the C runtime's `powf` bit for bit?
  :: intrigue
  A RoPE frequency table computed inside the program, `10000 ** (−i / d)`, emits
  `stablehlo.power`. XLA CPU calls the C runtime's `powf` for it, UCRT on the Windows desk.
  :: exit
  Cases in `tools/gen_stablehlo_cases.py` cover power, including zeros of both signs,
  infinities, NaN and denormals, compared bit for bit against XLA CPU's output from the Zen 2
  desk.
  :: decision
  - Translate the runtime's `powf` algorithm to a host model, the route `ExactSinCos.lean`
    already took for sin and cos.
  - Check that host model against `powf` over a wide sweep before emitting it as a kernel.
  - Add power cases to `tools/gen_stablehlo_cases.py` with the special values above; a case that
    cannot reach bit-equality carries a measured reason in `XFAIL`.
  - A planted control case must fail its gate, and all 11 desk gates still pass.
  :: related
  - RFD66606-2372, the guest ELF and ggml-rd compute route this kernel runs on.
  """
end
