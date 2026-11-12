# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2337, "a garment fit at MESH on the GPU L-BFGS-B", :discussion do
  feature "the pen's MESH stage moves a garment that clips the body out of it"
  scope "the fit in the drape guest, its kernels, and the pen's MESH stage"

  prose ~S"""
  :: hook
  Can the pen's skirt leave the body without a wider clearance on the strokes?
  :: intrigue
  On the statue avatar's body, the scripted skirt's surface sits 12 to 17 mm inside the cone its
  rings are sized for, about an AA battery's width, between the front and back seams.
  :: exit
  Read the gates and controls below, then run the pen's check that no garment vertex is inside
  the body on the fitted skirt.
  :: decision
  - MESH ends with a fit. A garment surface that clips the body is moved out of it by the
    fit, not by a wider clearance on the strokes (operator, 2026-10-27).
  - The fit follows the intersection-free retargeting fork's start: the body begins shrunk
    along its vertex normals, so the drawn surface is outside it, and grows back to full size
    in steps.
  - Each step is one solve by &{repo("contract-lbfgsb")} on the GPU: the shape term keeps the
    drawn surface's shape, and the IPC barrier keeps every vertex outside the body at that
    step's size. Every iterate stays intersection-free.
  - The fit runs in the guest of &{repo("interactor-drape")}, which already drives the solver
    on RenderingDevice and holds the IPC kernels. `drape.elf` comes back to
    &{repo("transport-meshing-pen")} (operator, 2026-10-27).
  - The pen's check that no garment vertex is inside the body reads the fitted mesh. The
    scripted skirt's ring clearance goes back to 1 cm, a little more than a pencil's width.
  :: related
  - RFD66606-2293, which cut the fit from the pen; RFD66606-2294, where compute runs.
  """

  details_title "a garment fit at MESH on the GPU L-BFGS-B"

  prose ~S"""
  :: details The problem
  Nine of 1910 vertices end up 3 to 12 mm inside the body, from two pennies to nearly a AA
  battery's width. A 2 cm ring clearance, two AAA batteries side by side, hides it
  without moving the surface.

  :: details The solve
  For grow fraction `a` from 0 to 1 in `N` steps, the body is `B(a) = B − (1 − a) d0 n`, with
  `n` the area-weighted vertex normals of the body and `d0` the shrink depth. At each step
  the solver minimises over the garment vertices `x`:

  ```
  E(x) = ks * sum over edges (|xi − xj| − lij)^2
       + kl * sum over vertices |L x − L x0|^2
       + kappa * sum over vertices, candidate triangles of B(a): b(d^2)
  ```

  `lij` and `L x0` are the drawn surface's edge lengths and Laplacian coordinates, and `b` is
  the IPC log barrier of the drape kernel, zero beyond `dhat`. The step starts from the last
  step's result.
  :: details What exists, and what is new
  - L-BFGS-B on the GPU: contract-lbfgsb `vec_rd`, in the drape guest, run by its solver tests.
  - IPC point-triangle barrier: drape `IpcPointTriangle.lean`, gradient and Hessian, no energy.
  - IPC step bound: drape `IpcStepClamp.lean`, written, not emitted or wired.
  - Shape term and normal shrink: new.
  - Fit entry points in the guest: new.
  New in the kernels:
  - The barrier's energy, summed per vertex, because a line search compares energies.
  - The step bound inside the line search: the solver's largest step is capped so no
    vertex moves more than a fraction of its distance to the body.
  Candidate triangles for each vertex come from the body mesh on the guest's CPU, once per
  step.
  :: details Gates and controls
  - No vertex inside: 0 inside, by winding number, after the fit. Control that must fail: the
    fit off, where the statue skirt has 9 inside.
  - Every iterate outside: 0 inside after every step. Control: the step bound off.
  - The start: 0 inside against the shrunk body. Control: `d0` = 0 on the statue skirt.
  - The shape kept: the move of each vertex is reported. No control, because it is a
    measurement.
  Each runs on the scripted skirt (two avatars), the replayed skirt and dress, and the two
  hand-drawn skirts. The fit runs on RenderingDevice only. The solver's vector ops keep their
  CPU-against-GPU unit tests.
  :: details What is not known
  - `ks`, `kl`, `kappa`, `dhat`, `d0` and `N`: measured on the fixtures first.
  - Time per fit on the GPU for about 2000 garment vertices.
  - Whether float32 vectors converge with the barrier near a 1 mm `dhat`, about a card's
    thickness.
  - The statue's body is open (870 boundary edges, 28 components): whether its normals give a
    clean shrink.
  """
end
