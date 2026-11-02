# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2371, "a residual is fixed down a ladder, never smudged", :discussion do
  flight_level :l2
  scope "how a residual in a visual diff is fixed."

  prose ~S"""
  :: hook
  A residual in a diff is fixed down a measured ladder, never hidden by a blur or a mask.
  :: intrigue
  What if a residual vanished because an image was blurred, a threshold loosened or a region
  masked?
  :: exit
  Check a proposed fix against the rule: measure it with the diff's own metric before and after,
  rung by rung.
  :: decision
  - A residual is fixed, never smudged: nothing blurs an image before the diff, loosens a
  threshold
    or masks a region.
  - Fixes go down a ladder, each rung measured with the diff's own metric before and after: exact
    fixes at the source, then missing structure, then registration, then fitted parameters.
  - What remains is reported beside its floor, and a later change may not raise it.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a residual is fixed down a ladder, never smudged"

  prose ~S"""
  :: details The rungs
  Registration is where a camera that does not match is fixed in the camera and never by warping
  an
  image. The last rung is parameters fitted to the oracle with &{repo("contract-lbfgsb")} on the
  GPU, coarse to fine, written back into the source assets and checked on views the fit did not
  use.

  :: details What stays
  Antialiasing and distance fades that belong to the renderer stay.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2371", :provides, "residual-fix-ladder"
    relate "rfd-2371", :is_a, "workspace-policy"
  end
end
