# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2435, "a garment is repaired as a distance-field surface", :discussion do
  flight_level :l1
  feature "a garment that crosses itself starts the cloth-fit solve as one clean surface."
  scope "the proxy garment that the cloth-fit solve fits, and how its result returns."

  prose ~S"""
  :: hook
  Can a garment that crosses itself start the cloth-fit solve clean?
  :: intrigue
  The pants cross themselves 1316 times across 53 shells. The solver takes one connected
  manifold mesh with no crossings, and a union of those shells did not give one. A surface
  of the garment's distance field might.
  :: exit
  Count the crossing pairs and the shells of the proxy. The solve takes it when they read 0 and
  1, and a planted second shell must read 2.
  :: decision
  - The garment is repaired as a proxy. The original keeps its UVs, skin weights and materials.
  - The proxy is a level surface of the unsigned distance to the garment. Open edges close
    and layers closer than the distance merge (operator, 2026-11-01).
  - The proxy takes skin weights from the garment through the robust weight transfer guest.
    The fitted displacement returns to the original through the cage stage.
  - The repair uses no CoACD hulls and no CSG union of the shells (operator, 2026-11-01).
  :: related
  - RFD66606-2424, where a sketch is placed on the avatar before any fit.
  """

  details_title "a garment is repaired as a distance-field surface"

  prose ~S"""
  :: details What the solver takes
  The cloth-fit solver's input spec asks for an avatar of one or more closed surfaces, because
  the avatar becomes a signed distance field. It asks for a garment that is a connected
  manifold triangle mesh. The solver also refuses a start where the garment crosses itself.

  The solver's own example solves. Its garment is one shell with no non-manifold edge, 144 open
  edges (a hem and a waist) and 0 crossing pairs. Its avatar is 32 shells that cross each other
  1394 times between shells. So the body may overlap itself, and the garment may not.

  :: details What an outfit piece looks like
  Measured with a throwaway script that welds at one hundred-thousandth of the bounding box and
  tests each edge against each triangle that shares no vertex. A planted crossing reads 1 and a
  planted separate pair reads 0.

  - The pants have 53 shells, no non-manifold edge, 399 open edges and 1316 crossing pairs. Of
    those, 1300 are between shells and 16 are inside one shell.
  - The skirt has 43 shells and 12 open loops.
  - The kimono has 346 shells, 128 open loops and 77 non-manifold edges.
  - The pants have 982 vertices that sit twice at one position, and no triangle collapses.

  :: details What did not work
  A union of the shells did not give a clean surface. Each shell became a solid: an inner copy
  offset along the vertex normals, joined to the shell by a strip on every open edge. A stock
  CSG union then ran on all 53 solids.

  - At 4 mm, about five credit cards stacked, 24 of the 53 solids came out inside out, because
    the small shells are thinner than the offset.
  - At 1 mm, about one credit card, all solids were valid. The union still had 295 non-manifold
    edges and 30969 crossing pairs, against 1316 before.

  Convex hulls from CoACD are closed and cover the garment, but the operator ruled them out for
  the repair. The pants gave 9 hulls in 6 seconds.

  :: details The distance field
  MuJoCo's mesh compiler builds an octree of signed distances. It finds the closest triangle
  through a bounding-volume hierarchy. It takes the sign from the angle-weighted pseudonormal of
  the closest vertex, edge or face, so it casts no rays and counts no windings. MuJoCo's GPU
  port only evaluates that field.

  The proxy uses the unsigned distance, so the sign never decides the surface. A level surface of
  it wraps every open edge and cannot cross itself. The distance is an argument that the operator
  picks. The solver's contact distance is 2 mm, about three credit cards stacked.

  :: details Rigging and carrying back
  The robust weight transfer guest takes the garment as source and the proxy as target. Its
  arrays are bone-major. It builds its Laplacian with intrinsic mollification (operator,
  2026-11-01). With two vertices at one position, a plain cotangent Laplacian gave non-finite
  weights for 480 of 484 outputs on a test grid, and the mollified one stayed finite.

  The cage stage binds the original to a cage and moves it with the fitted proxy. That gives a
  smooth field. Copying the nearest vertex's displacement does not.

  :: details What is not known
  - Whether a level surface at the contact distance keeps the garment's folds.
  - Whether it is one shell. The first step counts shells on the pants.
  - Whether the solver takes a garment of several shells. That needs the solver build on the
    Windows desk.
  - Whether the garments wind consistently. The unsigned field does not need it.
  - Where the nearest-triangle query runs as a guest, and its speed on a 54000-vertex piece.
  """
end
