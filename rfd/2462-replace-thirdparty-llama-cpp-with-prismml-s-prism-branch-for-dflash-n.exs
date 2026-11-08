# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2462,
    "Replace thirdparty/llama_cpp with PrismML's prism branch for DFlash n=6 and " <>
      "Bonsai 2 Heretic",
    :prediscussion do
  feature "swap the vendored llama.cpp for PrismML's prism branch to run DFlash n=6 on Heretic."

  scope "entities-godot's dev/language-model branch: thirdparty/llama_cpp and modules/llm."

  prose ~S"""
  :: hook
  Can entities-godot's language model branch adopt PrismML's prism branch whole, rather than by
  keyword-picked commits, and still build and run speculative decoding end to end?
  :: intrigue
  Work already moved a vendored llama.cpp tree onto PrismML's prism branch, which already
  carries DFlash and DFlash2 speculative decoding plus PQ2_0 quantization and its CPU, CUDA, and
  Metal kernels, roughly a hundred seventy commits behind upstream master. Picking commits by
  keyword already failed once: it missed the PQ2_0 repack commits, leaving a dependent AVX-512
  kernel commit with nothing to apply to, which is why the whole branch is taken instead.
  TurboQuant is unshipped by operator decision, so its cache types and defaults were stripped
  alongside the swap. None of this is pushed yet, and the engine's Metal build fails at the
  kernel embed step because the single metal file the old build step expected no longer exists.
  :: exit
  Fix the Metal kernel embed step for the new per-kernel layout, get a CPU and CUDA build green
  again, then run one end-to-end DFlash n=6 pass with the Heretic model on both the Mac and the
  desk and record acceptance rate and tokens per second.
  :: decision
  - Keep the prism branch vendored whole rather than cherry-picked, since a keyword-based pick
    of commits already lost a dependent kernel commit once.
  - Rework the Metal kernel build step and its build script for the new per-kernel-file layout
    before attempting another Metal build, instead of patching around the missing single file.
  - Run and record an end-to-end DFlash n=6 benchmark against Bonsai 2 Heretic on both the Metal
    and CUDA paths before calling the migration verified, since no acceptance rate or speed
    number exists yet.
  - Once a build is green on all three backends, archive the prior dev/language-model tip under
    an archived branch name and push the new tree in its place.
  """
end
