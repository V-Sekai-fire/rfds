# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2472, "KHR_interactivity: what the interpreter does not build yet", :prediscussion do
  feature "the Lean KHR_interactivity interpreter's gap against the extension's own text."

  scope "Persona/Khr.lean, the Lean module that builds and runs a KHR_interactivity graph."

  prose ~S"""
  :: hook
  Which of the extension's own nodes and types does the interpreter not build yet, and which
  checks does it only do while a graph runs rather than before it starts?
  :: intrigue
  Persona/Khr.lean already follows the extension's text for typed int and bool, 32-bit wrap,
  flow/for re-reading endIndex, socket order by string, variable/set with index-named sockets,
  pointer/get with isValid, and math/switch. Floats, float vectors, matrices and quaternions are
  not built at all, a float type simply rejects the graph, and a long list of nodes, reference
  template parameters and static type checking are missing too. A plan or a goal from elsewhere
  in this workspace can carry an unbounded integer; the extension's own integers are 32-bit
  two's complement, and that gap sits underneath every node listed here.
  :: exit
  Build one missing node, give it a positive and a negative control, and confirm a graph that
  used to reject it now runs it, while a graph with the wrong socket type for it still refuses.
  :: decision
  Build the missing pieces in the order they block a real graph: first the float and float
  vector types (so a float type stops rejecting the whole graph), then flow/doN, multiGate,
  waitAll, throttle, setDelay and cancelDelay, then the remaining events beyond event/onStart,
  then variable/interpolate and pointer/interpolate, then the integer operations div, rem, sign,
  clamp, the shifts, clz, ctz and popcnt, then pointer/set's err flow, matrices and quaternions,
  and reference template parameters including the doubled-bracket escape for a literal bracket.
  Move every socket type check that runs today only while a node executes to a static pass
  before the run starts, so a mistyped graph is refused before any node fires.
  :: related
  - RFD66606-2339, where a persona answers from a goal-task network and exports a plan as a
    KHR_interactivity graph.
  - RFD66606-2292, the organization's own RECTGTN (Lean goal-task network) domain this
    interpreter's planner side composes in.
  """

  details_title "KHR_interactivity: what the interpreter does not build yet"

  prose ~S"""
  :: details Already built
  Typed int and bool, 32-bit wrap, flow/for re-reading endIndex, socket order by string,
  variable/set with index-named sockets, pointer/get with isValid, and math/switch, each
  following the extension's own text.

  :: details Types not built
  Floats and float vectors, matrices and quaternions; a graph that declares a float type is
  rejected outright today rather than run.

  :: details Nodes not built
  flow/doN, multiGate, waitAll, throttle, setDelay, cancelDelay; every event other than
  event/onStart; variable/interpolate and pointer/interpolate; the integer operations div, rem,
  sign, clamp, the shifts, clz, ctz and popcnt; and pointer/set's err flow.

  :: details Syntax not built
  Reference template parameters written as {name}, and the doubled-bracket escape used for a
  literal bracket inside a pointer template.

  :: details Checking that runs too late
  Every socket's type is checked only while a node runs, not before the run starts, so a
  mistyped graph can run partway before it is caught.

  :: details The integer width gap underneath
  The planner's own integers, outside a KHR_interactivity graph, are unbounded. The extension's
  own integers are 32-bit two's complement. Every node above inherits this gap until it is
  closed once, at the boundary, rather than node by node.
  """
end
