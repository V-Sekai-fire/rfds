# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2471,
    "MiniZinc Challenge: precedence-scheduling problems on the temporal plan",
    :prediscussion do
  feature "the temporal plan expresses the Challenge's precedence-only scheduling problems."

  scope "the persona's temporal plan representation, read against four candidate problem sets."

  prose ~S"""
  :: hook
  After the planning puzzles, can the same temporal plan express a problem that needs only
  precedence and durations, with no resources at all?
  :: intrigue
  Four problem families on the Challenge's list look like a fit by name alone: project-planning
  (2012, 2015), road_construction (2014, 2017), ship-schedule (2011, 2012, 2014) and
  train-scheduling (2024). None of their models has been read yet, so fit is a guess today. The
  temporal plan already carries start, end and duration per step, release times and deadlines,
  and a critical-path total, but it has no resources, so any model with a cumulative constraint
  is out of reach before a single model is read.
  :: exit
  Read one family's model in full and classify it: expressible on the temporal plan as is, or
  out of reach because it needs a resource, an all-different, a cumulative or a packing
  constraint the plan does not carry.
  :: decision
  Read each of the four candidate families' models, starting with the smallest, and classify
  each as expressible or out of reach by the same rule the planning puzzles used. For a family
  that is expressible, climb from its smallest instance, validate every plan against MiniZinc
  itself, and accept only a plan that is both valid and optimal. A family that needs a resource,
  an all-different, a cumulative or a packing constraint is set aside rather than forced onto a
  plan that cannot carry it.
  :: related
  - RFD66606-2339, where a persona answers from a goal-task network and exports a plan.
  - RFD66606-2292, the organization's own RECTGTN (Lean goal-task network) domain that renders
    this register.
  """

  details_title "MiniZinc Challenge: precedence-scheduling problems on the temporal plan"

  prose ~S"""
  :: details The candidate families
  - project-planning (2012, 2015)
  - road_construction (2014, 2017)
  - ship-schedule (2011, 2012, 2014)
  - train-scheduling (2024)

  None of their models has been read yet; whether each is expressible on the temporal plan is a
  guess from the name alone, not yet a finding.

  :: details What the temporal plan already carries
  Start, end and duration per step (an unspecified start and end are left out of a problem; a
  missing duration means the step is instantaneous), release times and deadlines, and a
  critical-path total. It carries no resources, so a model with a cumulative constraint cannot
  be expressed on it as it stands.

  :: details Acceptance
  The same rule the planning puzzles used: valid and optimal, checked against MiniZinc itself,
  climbing from the smallest instance of a family up, never starting at the largest.

  :: details Source
  The problem list is at minizinc.org/challenge/globals/.
  """
end
