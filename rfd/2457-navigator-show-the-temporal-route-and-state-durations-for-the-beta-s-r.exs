# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2457,
    "Navigator: show the temporal route and state durations for the beta's RFDs",
    :prediscussion do
  feature "the navigator should show each RFD's earliest and latest possible time and route."

  scope "the pages_tree.exs generator, the pages_navigator.js client and the pinned planner."

  prose ~S"""
  :: hook
  Can the navigator show a temporal route and state durations for the beta's RFDs when no RFD
  states a duration yet?
  :: intrigue
  The navigator plans the beta's route from the RFDs' own token edges, a cone of 33 RFDs and
  37 steps. The persona planner now produces temporal plans with a start, an end and a
  duration per step, a critical-path total, and, through a composite task that lists each step
  twice, the earliest and latest possible time for that step. The site does not use any of
  that yet. Without a stated duration every step collapses to zero length, so the total reads
  as an instant: of 44 committed RFDs, 39 landed in the PR that created them, leaving a median
  lead time that is useless as a stand-in.
  :: exit
  Draft durations for the 33 RFDs in the cone, bump the pinned planner release, then run the
  navigator against the new temporal plan.
  :: decision
  - Add a composite window-rfd-N method to the generator that decomposes into earliest-rfd-N
    and latest-rfd-N, where the latest side needs its own again methods since the held
    shortcut no longer applies once the steps are already done (proposed).
  - Pair each step's two appearances in the navigator client as its earliest and latest
    possible time, with the problem document stating today as its origin (proposed).
  - Decide the declaration form for a duration, or a start and end per action, within the
    existing rebac block and with no new DSL (proposed).
  - Bump the planner release pinned in the pages workflow to the latest tag of the persona
    planner, which carries temporal plans and the shortest-plan export (proposed).
  - Draft the 33 RFDs' durations from a reference-class estimate rather than the useless
    observed lead time, and report a range or a P50 or P80 finish instead of one
    critical-path total (proposed).
  """

  details_title "navigator temporal route for the beta's RFDs"

  prose ~S"""
  :: details The blocker
  No RFD states a duration, and the observed lead times are not a usable stand-in: 39 of the
  44 committed RFDs landed in the PR that created them, so the median lead time is 0 days.
  Left unfilled, every step in the generated domain is instantaneous and the plan's total
  reads as a zero-duration instant.
  :: details The two generator changes
  `scripts/pages_tree.exs` needs a composite `window-rfd-N` method that decomposes into
  `earliest-rfd-N` and `latest-rfd-N`. The latest side cannot reuse the `held` shortcut, since
  by that point the steps it would shortcut are already done, so it needs its own "again"
  methods. `scripts/pages_navigator.js` needs to pair each step's two appearances as its first
  possible and last possible time, and the problem document needs to state today as its
  `origin`, or every start and end point is left out.
  :: details The pinned release
  `.github/workflows/pages.yml` pins an older tag of
  `V-Sekai-fire/interactor-taskweft-persona`. The latest tag carries temporal plans and the
  shortest-plan export that this work depends on.
  :: details Estimating durations
  The literature on duration estimates covers the planning fallacy, reference classes,
  three-point estimates, PERT merge bias, Monte Carlo methods and resource-constrained
  scheduling. These point toward a range or a P50 or P80 finish for the critical path, in
  place of one single total.
  """
end
