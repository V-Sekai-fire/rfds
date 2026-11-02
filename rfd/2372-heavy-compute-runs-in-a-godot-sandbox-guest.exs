# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2372, "heavy compute runs in a godot-sandbox guest", :discussion do
  flight_level :l2
  scope "where heavy compute runs."

  prose ~S"""
  :: hook
  Heavy compute runs in a godot-sandbox guest, never as a host pipeline or a GDScript loop.
  :: intrigue
  A native ggml engine module, a GDExtension ggml API and a standalone runtime are all off the
  route.
  :: exit
  Check a new heavy compute job against the rule: put it in a riscv64 guest ELF or on ggml-rd
  with compute-rd.
  :: decision
  - Heavy compute runs in a godot-sandbox guest: a riscv64 guest ELF on the CPU, which is also the
    parity oracle, or kernels on ggml-rd with compute-rd, authored in Lean and lowered through
    Slang
    to SPIR-V (RFD66606-2265).
  - It never runs as a host Python or C++ pipeline or as a GDScript loop.
  - ggml runs only in such a guest (RFD66606-2290).
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2265, compute-rd kernels with a CPU oracle.
  - RFD66606-2290, ggml only in guests.
  - RFD66606-2268, EditScore's decision model, which builds on ggml-rd.
  """

  details_title "heavy compute runs in a godot-sandbox guest"

  prose ~S"""
  :: details What stays allowed
  Fragment shaders that render are fine, and Python bindings serve upstream contributions and
  their
  tests, never a pipeline.

  :: details What is off the route
  A native ggml engine module, a GDExtension ggml API or a standalone runtime is off the route,
  and
  a standalone CLI may stay as a CPU oracle for a gate.

  :: details Diffusion
  Diffusion in ggml runs on ggml-rd with compute-rd as well, since EditScore's decision model
  builds
  on it (RFD66606-2268).
  """

  rebac do
    verbs_from 2351
    relate "rfd-2372", :provides, "sandbox-guest-heavy-compute"
    relate "rfd-2372", :is_a, "guest-runtime"
  end
end
