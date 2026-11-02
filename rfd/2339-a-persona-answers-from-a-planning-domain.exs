# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2339, "a persona answers from a planning domain", :discussion do
  flight_level :l1
  feature "a persona answers from a goal-task network instead of from weights"
  scope "the persona repository, the planner it requires as a library, and its register row"

  prose ~S"""
  :: hook
  A persona answers from a goal-task network, so a goal gives an exact plan with no sampling.
  :: intrigue
  A request in words reaches a persona only by way of whoever authors the domain. A domain
  with a thin vocabulary answers a thin set of goals.
  :: exit
  Read RFD66606-2292 next, the organization domain this workspace's RFDs render into.
  :: decision
  - A persona answers from a goal-task network rather than from weights: a domain and a
    goal go in, an exact plan comes out, and no sampling is involved (operator, 2026-10-30).
  - The persona is the instinct model: Lean 4 code, named for its latency against a
    language model (operator, 2026-10-29).
  - The planner is a library, not a reference. The persona requires the RECTGTN domain
    over GitHub, as the character domain does, and composes in its shared GTN space.
  - Its inputs are a code or a number. A code is the vocabulary: one level count a
    dimension, packed mixed-radix, the shape residual FSQ stacks its stages in.
  - A code the codebook does not hold, a variable the domain does not declare, and a goal
    the domain cannot reach are refused by name.
  :: related
  - RFD66606-2292, the organization domain this workspace's own RFDs render into.
  - RFD66606-2232, the renderer that turns an RFD into a planning problem.
  """

  details_title "a persona answers from a planning domain"

  prose ~S"""
  :: details Where it lives
  It is its own repository on the interactor side, placed when it is created, and the
  planner revision it builds against is recorded in its manifest.
  :: details What landed
  The persona is a Lean package of its own: a domain of state variables, a codebook and
  actions, a goal over the planner's own node space, and a search that composes the plan.
  The landing subject is "Compose the persona in Lean over the planner library".

  Its gate is a witness exe with a positive and a negative control per invariant: the
  codebook's size, basis and mixed-radix index; a code past its level and a code of the
  wrong arity both refused; a plan that executes to the goal; and three refusals, an
  unreachable goal, an undeclared variable and zero fuel.
  :: details The codebook is the vocabulary
  Eight levels over four dimensions is 4096 codes a stage, and four stages of those is
  281474976710656 codes from thirty-two small integers. A code is what a goal argument
  binds, and a number is the other half of the surface.

  The codec is the one this workspace already certifies for the residual-FSQ recommender:
  a mixed-radix index over per-dimension levels, injective and bounded at the real scale.
  :: details References
  The codebook's shape and the stages it stacks come from this lineage.
  - Zeghidour et al., SoundStream (doi 10.1109/TASLP.2021.3130651)
  - Défossez et al., EnCodec (doi 10.48550/arXiv.2210.13438)
  - Mentzer et al., Finite Scalar Quantization (doi 10.48550/arXiv.2309.15505)
  - Zhu et al., Robust Residual FSQ (doi 10.48550/arXiv.2508.15860)
  - Liu et al., VQTalker (doi 10.48550/arXiv.2412.09892)
  :: details The design's other half
  The persona is the half that answers from a program. The other half is a
  language model, and the design keeps a place for it until the model has a
  home (operator, 2026-10-29).
  :: details Code as data, and what a persona says back
  A caller gives category and numeric instructions, and the persona walks the
  programs it holds: "you did not even weight paint", then what face tracking
  costs. The caller is given options, and a choice fits the input shape rather
  than arriving in words. A failure and a success each point at a guide, baked
  in or linked (operator, 2026-10-29).
  :: details What is not known
  - How a persona composes with this workspace's rendered problems, which the organization
    domain answers today through the planner's Elixir consumer.
  - The temporal reading of a domain that declares no reads and no writes: the plan order
    is exact, and the timeline parallelizes what the domain leaves undeclared.
  :: details The problem
  A persona cannot answer
  a question that is not a goal.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2339", :provides, "persona-goal-task-planner"
    relate "rfd-2339", :is_a, "model-pipeline-stage"
  end
end
