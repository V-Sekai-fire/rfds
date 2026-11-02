# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2368, "station parity is measured against a WARP render", :discussion do
  flight_level :l2
  scope "the reference render that the station port's parity is measured against."

  prose ~S"""
  :: hook
  A station change lands only when no view's full-resolution MAD rises against the WARP reference.
  :: intrigue
  ANGLE's Vulkan path draws seams the original does not intend, and D3D11 flips one 8-bit level
  from run to run.
  :: exit
  Check a station change against the reference: compare each view's full-resolution MAD with the
  WARP render of release `oracle-4112f57-h8-warp`.
  :: decision
  - Parity with the three.js original is measured at sphere-Hammersley views against
    `tools/oracle/shot.mjs` renders.
  - The reference is the original rendered through WARP, Windows' software rasterizer
    (`--angle warp`, release `oracle-4112f57-h8-warp`), because it is
    deterministic and seam-free.
  - A change lands only when no view's full-resolution MAD rises against the reference, unless
    the operator accepts the exception on issue 72.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "station parity is measured against a WARP render"

  prose ~S"""
  :: details The port's hashing
  The port hashes from integer corners.
  :: details The problem
  ANGLE's Vulkan path hashes the cloud noise's lattice corners from float sums differently on
  each side of a cell edge.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2368", :provides, "station-warp-parity-oracle"
  end
end
