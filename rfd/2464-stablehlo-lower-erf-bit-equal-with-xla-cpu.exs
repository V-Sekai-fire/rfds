# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2464, "StableHLO: lower erf, bit-equal with XLA CPU", :prediscussion do
  feature "the StableHLO lowering accepts stablehlo.erf and matches XLA CPU bit for bit."

  scope "the erf case in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can an erf kernel on the GPU match XLA CPU's own approximation bit for bit, not libm's?
  :: intrigue
  JAX's exact GELU (`approximate=False`) lowers through `erf`, arriving as `chlo.erf` or as an
  expanded polynomial depending on the JAX version. ggml-rd has `gelu_erf_f32`, but it needs
  checking against XLA's erf bit for bit.
  :: exit
  Cases in `tools/gen_stablehlo_cases.py` cover erf, including zeros of both signs, infinities,
  NaN and denormals, compared bit for bit against XLA CPU's output from the Zen 2 desk.
  :: decision
  - Check which form jax 0.12 emits for `approximate=False`, `chlo.erf` or an expanded
    polynomial, before choosing the lowering path.
  - Model XLA's erf approximation on the host and sweep all 2^32 f32 inputs against XLA CPU, the
    same route `tanh` and `exp`/`log` already took.
  - Emit the matched kernel in place of `gelu_erf_f32`, and add erf cases to
    `tools/gen_stablehlo_cases.py` with the special values above.
  - A case that cannot reach bit-equality carries a measured reason in `XFAIL`, a planted control
    case must fail its gate, and all 11 desk gates still pass.
  :: related
  - RFD66606-2372, the guest ELF and ggml-rd compute route this kernel runs on.
  """
end
