# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2486, "Tri2d cli shared algorithm repo", :prediscussion do
  prose ~S"""
  :: hook
  A validated 2D constrained-Delaunay triangulation already backs a
  Python dataset pipeline and a godot-sandbox guest. Which repo should
  carry it?
  :: intrigue
  tri2d_cli wraps Geogram's real CDT2d behind a JSON stdin/stdout
  contract. GarmentCodeData v2's orig_lens pipeline (Python, replacing
  CGAL) shells out to it, and the sketch-mesh guest ported the same
  call sequence into its own curvenet guest as a native function.
  :: exit
  Check that the new repo exists, builds standalone with plain
  cmake . && make, and that neither GarmentCodeData nor the
  sketch-mesh guest vendors its own copy of the CLI source.
  :: decision
  See DETAILS.md for the full argument.
  :: related
  See DETAILS.md for the full argument.
  """

  prose ~S"""
  :: details The problem
  Where does a triangulation two unrelated consumers share live?
  """

  details_title "Tri2d cli shared algorithm repo"

  madr do
    context ~S"""
    tri2d_cli existed only as scratch files on two machines, this
    Mac's local port and the Windows desk's build, never committed to
    a repo. It wraps Geogram's real CDT2d (constrained Delaunay
    triangulation with hole removal) behind a small
    JSON-over-stdin/stdout CLI, validated against a known-area control
    case (see confirmation below).

    It has two independent consumers. GarmentCodeData v2's orig_lens
    regeneration pipeline (Python) shells out to the built binary in
    place of CGAL. The sketch-mesh repo's curvenet godot-sandbox guest
    ported the same point-flattening, constraint-insertion and
    hole-removal sequence into C++ as a native guest function,
    vmcall-verified on the Windows desk, reading native float vectors
    instead of JSON. Each consumer's repo serves a different domain
    from the algorithm itself.
    """

    drivers ~S"""
    - The validation is the control case checked in confirmation. It
      should be proven once, in one repo, not re-proven inside each
      consumer.
    - GarmentCodeData is a Python dataset-generation repo. Its only
      other caller is a Godot guest ELF, so a C++ triangulation
      library sits outside its domain.
    - The sketch-mesh repo is a godot-sandbox guest repo. The
      standalone-CLI build path (cmake . && make, JSON-over-stdio)
      serves only the Python side, so it sits outside that repo's
      domain too.
    - The vendored Geogram subset (BSD-3-Clause, Inria) needs to stay
      distinct from our own MIT code wherever it lands. Vendoring it
      twice doubles the licensing surface for no benefit.
    """

    options ~S"""
    - Commit tri2d_cli into GarmentCodeData's own repo, and have the
      sketch-mesh guest re-derive its native function from scratch
      each time it drifts.
    - Commit the CLI into the sketch-mesh repo and have GarmentCodeData's
      pipeline depend on that repo as a submodule.
    - Place it as its own repo: the validated CLI, its vendored
      geogram-subset subtree, and the control test, with both
      consumers treating it as an external, versioned tool.
    """

    outcome ~S"""
    Chosen option: its own new repo. The algorithm and its validation
    belong to neither consumer, and a shared repo lets both read the
    same validated source instead of two copies drifting apart.

    The new repo carries:

    - tri2d_cli.cpp and boolean_expression.cpp (MIT, ours).
    - a vendored geogram-subset tree (Geogram 1.9.9, BSD-3-Clause,
      Inria), with its own LICENSE and CITATION.cff kept inside that
      subtree.
    - A CMakeLists.txt that builds standalone with plain
      cmake . && make, no GarmentCode or Windows-desk directory
      assumptions.
    - A README stating the JSON contract and the control case from
      confirmation as its smoke test.

    GarmentCodeData's pipeline and the sketch-mesh guest keep their own
    ports of the call sequence, a Python subprocess call and a native
    C++ guest function. This repo is where the algorithm itself is
    proven once.
    """

    consequences ~S"""
    - Good: one validated triangulation, read by two consumers, instead
      of two copies that can silently diverge.
    - Good: the BSD-3-Clause vendor subtree is licensed once, correctly
      scoped, instead of twice.
    - Good: GarmentCodeData and the sketch-mesh guest each stay focused
      on their own domain. Neither carries the other's build path.
    - Bad: a third consumer, or a fix found in one port, still has to
      be manually checked against this repo's tri2d_cli.cpp. The
      guest's C++ port is a separate translation, not a build
      dependency on this repo.
    """

    confirmation ~S"""
    - The new repo exists, public, MIT-licensed for its own code, with
      the vendored geogram-subset tree kept under Geogram's
      BSD-3-Clause.
    - cmake . && make on a clean macOS or Linux checkout builds
      tri2d_cli with no other directories present.
    - The control case: a 10x10 square boundary, a 2x2 hole, and 2
      interior points, piped into the built binary, sums to area
      96.0, with no triangle centroid landing inside the hole.
    """

    more_information ~S"""
    Relates to the sketch-mesh repo's guest port of this same call
    sequence, and to GarmentCodeData v2's orig_lens regeneration
    pipeline, the Python consumer this CLI replaces CGAL for.
    """
  end
end
