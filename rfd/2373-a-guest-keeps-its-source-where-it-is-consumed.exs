# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2373, "a guest keeps its source where it is consumed", :discussion do
  flight_level :l2
  scope "where a guest's source lives and where its stages went."

  prose ~S"""
  :: hook
  A guest's source lives in the repository that consumes it, split the way curvenet splits it.
  :: intrigue
  A vmcall takes at most seven arguments, an eighth failing with a register overflow.
  :: exit
  Check a new guest against the rule: `main.cpp` marshals and sees only `api.hpp`, and
  `*_api.cpp` sees the library.
  :: decision
  - A guest's source lives in the repository that consumes it and follows curvenet's split:
    `main.cpp` marshals and sees only `api.hpp`, and `*_api.cpp` sees the library.
  - Mesh arrays cross in the layout of &{repo("contract-guest-common")}'s `mesh_wire.h`.
  - A vmcall takes at most seven arguments, an eighth failing with a register overflow, and each
    call returns inside the sandbox's `execution_timeout`.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a guest keeps its source where it is consumed"

  prose ~S"""
  :: details Where interactor-dress-on went
  The stages of the archived interactor-dress-on live in their own repositories:
  &{repo("contract-guest-runtime")}, &{repo("contract-guest-common")},
  &{repo("contract-ggml-rd")}, &{repo("contract-lbfgsb")},
  &{repo("contract-anny-kernels")}, &{repo("contract-sinew-align")}, and
  &{repo("interactor-drape")}, `-curvenet`, `-garment-fit`, `-cage`, `-headfit`,
  `-lasso`, `-motion-guest`, `-rfdetr-seg-guest`, `-usd-guest`, `-av1mkv`.
  &{repo("transport-meshing-pen")} builds the guest ELFs from those sibling checkouts.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2373", :provides, "guest-source-at-consumer"
    relate "rfd-2373", :is_a, "guest-runtime"
  end
end
