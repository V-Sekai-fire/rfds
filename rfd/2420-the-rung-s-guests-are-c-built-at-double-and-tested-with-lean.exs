# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2420, "the rung's guests are C++ built at double and tested with Lean", :discussion do
  scope "how the rung's guest ELFs are built and tested."

  prose ~S"""
  :: hook
  The rung's guests are C++ built at double precision, and a Lean package tests them.
  :: intrigue
  What does a guest read when it is built at single precision? It misreads every value the engine
  hands it.
  :: exit
  Build each guest against the double-precision addon, and pair every property its test checks
  with a control that plants the defect and must be found.
  :: decision
  - The zone, client, CA, asset, lasso and voice ELFs are C++, built from the fabric's, the
    lasso's and the codec's own sources against the namespaced engine shim in
    contract-guest-runtime that the curvenet guest already uses.
  - Their tests are a Lean package beside them that links that C++ through a small FFI shim, as
    frame-eye-osc does. Lean is never in the running path.
  - Every property the tests check is paired with a control that plants the defect and must be
    found.
  - Every guest is built against the double-precision addon.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "the rung's guests are C++ built at double and tested with Lean"

  prose ~S"""
  :: details What is missing
  The vendored sandbox-api in contract-guest-runtime, fabric-zone and voice does not pass
  `DOUBLE_PRECISION` to its own library, and its `node2d.cpp` and `vector.cpp` fail to compile at
  double. `fit.elf`, `usd.elf` and `mujoco.elf` are single precision.
  :: details The problem
  A guest's `Variant` is 24 bytes at single precision and 40 at double, so a single-precision
  guest misreads every value the engine hands it.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2420", :provides, "lean-tested-cpp-guests"
    relate "rfd-2420", :spends, "guest-elf-double"
    relate "rfd-2420", :is_a, "guest-runtime"
  end
end
