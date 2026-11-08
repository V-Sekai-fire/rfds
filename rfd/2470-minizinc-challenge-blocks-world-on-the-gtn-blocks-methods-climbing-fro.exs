# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2470,
    "MiniZinc Challenge: blocks-world on the GTN blocks methods, climbing from small " <>
      "instances",
    :prediscussion do
  feature "the ported blocks-world GTN climbs from small instances to the five official ones."

  scope "the blocks_gtn domain, its frontier harness, and the MiniZinc checker that grades it."

  prose ~S"""
  :: hook
  Can a plan the GTN (goal-task network) finds for the Challenge's blocks-world also be the
  minimum, checked by the Challenge's own tool, climbing from the smallest instance up?
  :: intrigue
  GTPyhop's blocks_gtn is already ported, with take, put and moveblocks as a KHR_interactivity
  graph, and shortestOf already finds the optimal six actions for the Sussman anomaly. A
  separate reference tool already matched a breadth-first minimum for n = 3 to 7 on 3 piles, in
  times climbing from about 15 ms to about 4 s, but the domain still has no pile limit, no
  climbing harness and no run against the real checker.
  :: exit
  Install MiniZinc, replay a solved instance through it, and confirm the checker accepts the
  plan as valid and minimum; a plan with one move removed must be refused by the same checker.
  :: decision
  Encode the model's pile limit, k piles with at most k cubes on the table, in the GTN domain,
  then climb: generate instances at n = 3, 4, 5 and up with the model's k, record solve time at
  each step, and stop at the frontier where the time makes the next step not worth running yet.
  Add a heuristic lower bound, for instance the count of cubes already out of place, to prune
  the five official instances (16 cubes on 4 piles), which are far past what iterative deepening
  alone can reach. Validate every plan against MiniZinc itself, installed locally, rather than
  against the reference tool alone.
  :: related
  - RFD66606-2339, where a persona answers from a goal-task network and exports a plan.
  - RFD66606-2292, the organization's own RECTGTN (Lean goal-task network) domain that renders
    this register.
  """

  details_title "MiniZinc Challenge: blocks-world on the GTN blocks methods"

  prose ~S"""
  :: details Already in place
  - tests/gtpyhop/blocks_gtn/ ports GTPyhop's blocks_gtn: actions take, put and moveblocks as a
    KHR_interactivity (the Khronos node-graph behaviour format) graph.
  - shortestOf, iterative deepening over the backtracking decomposition and exported as
    persona_plan_shortest, finds the optimal six actions for the Sussman anomaly, and refuses a
    smaller bound by name as limit.
  - On branch parked/minizinc-blocks-frontier, tools/minizinc/ holds an instance generator, an
    independent breadth-first minimum, and a replay against the model's rules. For n = 3 to 7 on
    3 piles, 20 random instances each matched the minimum and replayed validly, at a cost
    climbing from about 15 ms at n = 5 to about 4 s at n = 7.

  :: details What still has to land
  - The model's pile limit, k piles and at most k cubes on the table, encoded in the GTN domain
    itself rather than assumed.
  - The climbing harness: generate n = 3, 4, 5 and up at the model's k, record solve time, and
    stop at the frontier; the stopping point teaches which bound or heuristic to add next.
  - A heuristic bound, such as a lower bound on cubes out of place, to prune the rising search
    enough to reach the five official instances, each 16 cubes on 4 piles.
  - MiniZinc itself, installed locally (brew install minizinc; there is no cask by that name,
    and minizincide is the IDE, not the checker) so a plan is validated for real, not only by
    the independent breadth-first tool.
  - A local clone of the MiniZinc/mzn-challenge archive, about 570 MB at depth 1, to read the
    2022 blocks.mzn model this domain targets.

  :: details Source
  MiniZinc/mzn-challenge, 2022/blocks-world/blocks.mzn: n cubes, at most k piles, minimise moves.
  """
end
