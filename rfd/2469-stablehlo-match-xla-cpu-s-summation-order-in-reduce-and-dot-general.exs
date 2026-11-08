# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2469,
    "StableHLO: match XLA CPU's summation order in reduce and dot_general",
    :prediscussion do
  feature "reduce and dot_general reproduce XLA CPU's own order of summation, not only its sum."

  scope "the StableHLO lowering in guest/pjrt-rd/stablehlo.cpp and its generated test cases."

  prose ~S"""
  :: hook
  Can the lowering reproduce XLA CPU's own order of adding floats, not only the value that order
  happens to land on?
  :: intrigue
  Eight cases are not bit-equal on the RTX 4090 today: dot_batched, mlp_pre, mlp_f32,
  reduce_sum_random, mean_last, softmax_f32, rms_norm_f32 and causal_attention. Each stays within
  the functional bar, a rel-L2 around 1e-7 and at most a few dozen ulp, but none is bit-equal.
  reduce with add sums in an irregular tree that changes with the shape, and dot_general runs as
  a fusion whose accumulation tree also depends on the shape; cases with the order written out,
  or whose partial sums are exact, are already bit-equal, so the gap is the order, not the
  arithmetic.
  :: exit
  Reveal one new shape's tree, add it to the table, confirm that shape's case turns bit-equal,
  and confirm removing the table brings the old difference back.
  :: decision
  Reveal XLA's accumulation tree for each reduce and dot shape the five graphs use, on the Zen 2
  desk with this jax build, and record the trees in a table keyed by shape. Emit each tree as a
  sequence of slices and adds, or as a kernel that takes the tree as data, and fall back to
  today's order, with the case kept in XFAIL, for any shape the table does not cover. The table
  is tied to one CPU and one XLA build, the way rsqrt_zen2 already is, so it records both.
  """

  details_title "StableHLO: match XLA CPU's summation order in reduce and dot_general"

  prose ~S"""
  :: details The eight cases
  dot_batched, mlp_pre, mlp_f32, reduce_sum_random, mean_last, softmax_f32, rms_norm_f32 and
  causal_attention: each is within the functional bar today, a rel-L2 around 1e-7 and at most a
  few dozen ulp, but not bit-equal. pinned_sum_tree, softmax_pinned and causal_softmax_pinned
  already pin the order and are already bit-equal, which is the evidence that order, not
  arithmetic, is the whole gap.

  :: details The two trees to reveal
  - reduce with add: an irregular summation tree that changes with the shape, matching an
    unrolled chain of adds reassociated by LLVM. tools/reveal_sum_order and the notes in
    STABLEHLO.md describe how it is read back out.
  - dot_general: a fusion whose accumulation tree also depends on the shape, revealed the same
    way, on the same desk and jax build.

  :: details Acceptance
  - The eight cases above are bit-equal on the GPU, or each keeps a measured reason in XFAIL.
  - Removing the table brings back the old differences; that is the control this decision must
    fail without.
  - The added cost in dispatches and time for the five graphs is measured and written down.
  - All 11 desk gates still pass.
  """
end
