# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2473, "Planner search: heuristics for the shortest plan", :prediscussion do
  feature "the planner's backtracking search finds the shortest plan without an exhaustive scan."

  scope "the planner's bound-raising search and the domains it solves."

  prose ~S"""
  :: hook
  Can the planner find the shortest plan for 16 cubes without scanning every bound in turn?
  :: intrigue
  `shortestOf` raises a bound on the number of actions until a plan reaches its goals, through
  a backtracking decomposition. That search is exhaustive at each bound, so the whole search is
  exponential: fine for the Sussman anomaly at six actions, too slow for 16 cubes.
  :: exit
  Run the blocks-world domain at 16 cubes under a wall-clock budget. A plan that returns within
  budget, at the same length an exhaustive search would find, passes.
  :: decision
  Add three heuristics to the bound-raising search, each kept only if it holds plan length
  unchanged while cutting search time:
  - A lower bound supplied by the domain (admissible, so the rising bound starts higher and
    prunes branches that cannot reach a shorter plan).
  - Memoising failed (state, bound) pairs, so a branch already shown to fail at a bound is never
    re-explored at that bound.
  - Ordering alternatives by a heuristic, so the search tries the branch most likely to reach the
    goal first, before the branches it would otherwise explore in declaration order.
  Each heuristic ships behind its own control: a planted domain that breaks admissibility, a
  planted stale memo entry, and a planted heuristic that always ranks last, each of which must
  make its gate fail.
  """
end
