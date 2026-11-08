# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2476, "Suit markers: raise yield per island toward 2310 without the id cap", :prediscussion do
  feature "island charting raises marker yield per island above the current id-pool cap."

  scope "island charting (xatlas or a custom charter) and the fold test that screens markers."

  prose ~S"""
  :: hook
  Can an island hold more than 2,600 markers without widening past the id pool of 3,917 that
  the 6x6, distance-9-or-greater family provides?
  :: intrigue
  Run b places 2,600 markers, which is the id cap of that family, even though the pool itself
  has room for 3,917. Marker squares cover only 24.6% to 28.3% of island area, well under the
  50% cap (markers sit only in white squares), so the limit today is island layout, not the id
  pool or the per-square area cap.
  :: exit
  Re-chart islands with one of the candidate options and show more than 2,600 markers placed at
  the same read rate as run b, with no marker id reused twice on one garment.
  :: decision
  Raise yield per island by changing how islands are charted, trying in order: an xatlas crease
  patch with a size window, a custom charter, and larger islands via `maxChartArea` and
  `maxBoundaryLength`. Screen candidate markers with a 3D fold test before placement: the largest
  normal deviation within 37 mm separates unread from read markers at a median of 76 degrees
  versus 31 degrees. Dropping every marker over 90 degrees keeps only 90.3% of markers, so the
  90-degree cutoff alone is not the gate; it is a pre-filter ahead of the dead-on gate, since it
  would not have caught the camera 74 fault on its own.
  :: related
  - RFD66606-2467, the dead-on gate that the fold-test pre-filter feeds markers into.
  """
end
