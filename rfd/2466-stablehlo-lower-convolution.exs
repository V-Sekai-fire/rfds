# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2466, "StableHLO: lower convolution", :prediscussion do
  feature "the StableHLO lowering accepts convolution for the sconv and dit graphs."

  scope "the convolution case in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can `stablehlo.convolution` map onto ggml-rd's existing conv kernels for the dimension
  numbers the sconv and dit graphs actually use?
  :: intrigue
  sconv and dit need `stablehlo.convolution`. ggml-rd has `conv2d`, `conv_2d_dw`,
  `conv_transpose_2d` and an im2col path, but none of them is wired to the dimension numbers,
  padding, strides, dilation and feature groups those graphs use.
  :: exit
  Cases in `tools/gen_stablehlo_cases.py` cover convolution, including zeros of both signs,
  infinities, NaN and denormals, compared bit for bit against XLA CPU's output from the Zen 2
  desk.
  :: decision
  - Map the dimension numbers, padding, strides, dilation and feature groups that sconv and dit
    use onto `conv2d`, `conv_2d_dw`, `conv_transpose_2d` or the im2col path, and refuse the rest.
  - Treat the functional bar as the first target, since bit-equality likely meets the same
    summation-order question `dot_general` already met.
  - Add convolution cases to `tools/gen_stablehlo_cases.py` with the special values above; a
    case that cannot reach bit-equality carries a measured reason in `XFAIL`.
  - A planted control case must fail its gate, and all 11 desk gates still pass.
  :: related
  - RFD66606-2372, the guest ELF and ggml-rd compute route this kernel runs on.
  """
end
