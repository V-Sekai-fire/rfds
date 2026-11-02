# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2391, "guests are built at double precision", :discussion do
  flight_level :l1
  scope "the double-precision build of the guests."

  prose ~S"""
  :: hook
  Guests are built at double precision so they match the double host.
  :: intrigue
  A committed single-precision `curvenet.elf` loaded by the check must print `RESULT: FAIL`.
  :: exit
  Run `tools/probe_load.gd` and check that `variant_bytes() == 40` for curvenet and lasso when
  `OS.has_feature("double")` holds.
  :: decision
  - Guests at double, in &{repo("contract-guest-runtime")}'s vendored
    sandbox-api: `target_compile_definitions(sandbox_api PUBLIC
    DOUBLE_PRECISION_REAL_T)` under the option; `node2d.cpp` returns
    `real_t`; `vector.cpp`'s wrappers take `real_t`, checked against
    the host's `ECALL_VEC3_OPS` handler in the placed source for what
    `fa0` carries. The pen's `build.sh` passes `-DDOUBLE_PRECISION=ON`.
    Xgodot_lite` stays float, since the host boundary is `api.hpp`'s
    `Variant` and `PackedFloat32Array` is float either way. `lasso` and
    `curvenet` export `variant_bytes()`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "guests are built at double precision"

  prose ~S"""
  :: details Check and control
  Check: `tools/probe_load.gd` loads `lasso.elf` (seven PASS lines with
  their controls) and asserts `OS.has_feature("double")` implies
  `variant_bytes() == 40` for curvenet and lasso. Xtools/test.sh` and
  the replay pass on the double editor and template builds in CI on
  linux x86_64 and on the Frame through `run-xr.sh`. Control:
  `--control=single_elf` loads a committed single-precision
  `curvenet.elf` and must print `RESULT: FAIL`. `linux.yml` gains
  `feat/*` and stays as the single-precision arm.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2391", :provides, "guest-elf-double"
    relate "rfd-2391", :provides, "guests-double-precision-build"
  end
end
