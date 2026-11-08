# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2463, "StableHLO: lower tanh, bit-equal with XLA CPU", :prediscussion do
  feature "the StableHLO lowering accepts stablehlo.tanh and matches XLA CPU bit for bit."

  scope "the tanh case in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can a tanh kernel on the GPU match XLA CPU's own polynomial bit for bit, not libm's?
  :: intrigue
  JAX's GELU with `approximate=True` emits `stablehlo.tanh`, which the lowering refuses today.
  ggml-rd already has a `tanh_f32` kernel, but XLA CPU does not call libm for tanh: it uses its
  own polynomial approximation, as it does for exp and log.
  :: exit
  Cases in `tools/gen_stablehlo_cases.py` cover tanh, including zeros of both signs, infinities,
  NaN and denormals, compared bit for bit against XLA CPU's output from the Zen 2 desk.
  :: decision
  - Read XLA's tanh polynomial in `polynomial_approximations.cc` and model it on the host, the
    route `ExactExpLog.lean` already took for exp and log.
  - Sweep all 2^32 f32 inputs against that host model and XLA CPU, then emit the matched kernel
    in place of `tanh_f32`.
  - Add tanh cases to `tools/gen_stablehlo_cases.py` with the special values above; a case that
    cannot reach bit-equality carries a measured reason in `XFAIL`.
  - A planted control case must fail its gate, and all 11 desk gates still pass.
  :: related
  - RFD66606-2372, the guest ELF and ggml-rd compute route this kernel runs on.
  """
end
