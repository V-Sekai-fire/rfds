# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2486, "Tri2d cli shared algorithm repo", :prediscussion do
  prose ~S"""
  :: hook
  One validated constrained-Delaunay-triangulation CLI, two unrelated
  consumers: it gets its own repo, not a home inside either one.
  :: intrigue
  `tri2d_cli.cpp` wraps Geogram's real `GEO::CDT2d` behind a JSON
  stdin/stdout contract and was validated correct (a 10x10 square with
  a 2x2 hole triangulates to area 96.0). It now backs GarmentCodeData
  v2's `orig_lens` pipeline (Python, replacing CGAL) and was also
  ported into `interactor-sketch-mesh`'s `curvenet.elf` guest as
  `cn::cdt2d_triangulate`.
  :: exit
  Check that `V-Sekai-fire/tri2d-cli` exists, builds standalone with
  plain `cmake . && make`, and that neither GarmentCodeData nor
  `interactor-sketch-mesh` vendors its own copy of the CLI source.
  :: decision
  See `DETAILS.md` for the full argument.
  :: related
  See `DETAILS.md` for the full argument.
  """

  prose ~S"""
  :: details The problem
  Where does a triangulation two unrelated consumers share live?
  """

  details_title "Tri2d cli shared algorithm repo"

  madr do
    context ~S"""
    `tri2d_cli.cpp` only ever existed as scratch files on two machines:
    this Mac's `work/mac-port/tri2d/` and the Windows desk's
    `ccd-bench/tri2d/`, never committed to a repo. It wraps Geogram's
    real `GEO::CDT2d` (constrained Delaunay triangulation with hole
    removal) behind a small JSON-over-stdin/stdout CLI, validated with a
    control case: a 10x10 square boundary, a 2x2 hole, and 2 interior
    points triangulates to exactly area 96.0, with no triangle centroid
    landing inside the hole.

    It now has two independent consumers. GarmentCodeData v2's
    `orig_lens` regeneration pipeline (Python) shells out to the built
    binary in place of CGAL. `V-Sekai-fire/interactor-sketch-mesh`'s
    `curvenet.elf` godot-sandbox guest ported the identical
    point-flattening / constraint-insertion / hole-removal sequence into
    C++ as `cn::cdt2d_triangulate` (branch `feat/cdt2d-guest-function`,
    vmcall-verified on the Windows desk), reading native `float` vectors
    instead of JSON. Neither consumer's repo is a natural home for the
    other's use of the same algorithm.
    """

    drivers ~S"""
    - One validated algorithm; the validation (the area-96.0 control
      case) should not be re-proven independently inside each consumer.
    - GarmentCodeData is a Python dataset-generation repo; it should not
      carry a C++ library whose only other caller is a Godot guest ELF.
    - `interactor-sketch-mesh` is a godot-sandbox guest repo; it should
      not carry the standalone-CLI build path (`cmake . && make`,
      JSON-over-stdio) that only the Python side needs.
    - The vendored Geogram subset (BSD-3-Clause, Inria) has to be kept
      distinct from our own MIT code wherever it lands, so vendoring it
      twice (once per consumer) doubles the licensing surface for no
      benefit.
    """

    options ~S"""
    - Commit `tri2d_cli.cpp` into GarmentCodeData's own repo, and have
      `interactor-sketch-mesh` re-derive `cn::cdt2d_triangulate` from
      scratch each time it drifts.
    - Commit the CLI into `interactor-sketch-mesh` and have
      GarmentCodeData's pipeline depend on that repo as a submodule.
    - Place it as its own repo, `V-Sekai-fire/tri2d-cli`: the validated
      CLI, its vendored `geogram-subset` subtree, and the control test,
      with both consumers treating it as an external, versioned tool.
    """

    outcome ~S"""
    Chosen option: its own repo, `V-Sekai-fire/tri2d-cli`, because the
    algorithm and its validation belong to neither consumer and a
    shared repo is the only placement that lets both read the same
    validated source instead of two copies drifting apart.

    `V-Sekai-fire/tri2d-cli` carries:

    - `tri2d_cli.cpp` and `boolean_expression.cpp` (MIT, ours).
    - `vendor/geogram-subset/` (Geogram 1.9.9, BSD-3-Clause, Inria),
      with its own LICENSE and CITATION.cff kept inside that subtree.
    - A `CMakeLists.txt` that builds standalone with plain
      `cmake . && make`, no GarmentCode or Windows-desk directory
      assumptions.
    - A README with the exact JSON contract and the area-96.0 control
      case as the smoke test.

    GarmentCodeData's pipeline and `interactor-sketch-mesh`'s guest keep
    their own ports of the call sequence (Python subprocess call vs. a
    native C++ guest function); this repo is the one place the
    algorithm itself, and its validation, is proven once.
    """

    consequences ~S"""
    - Good: one validated triangulation, read by two consumers, instead
      of two copies that can silently diverge.
    - Good: the BSD-3-Clause vendor subtree is licensed once, correctly
      scoped, instead of twice.
    - Good: GarmentCodeData and `interactor-sketch-mesh` each stay
      focused on their own domain; neither carries the other's build
      path.
    - Bad: a third consumer, or a fix found in one port, still has to be
      manually checked against this repo's `tri2d_cli.cpp` rather than
      sharing a single call site; the guest's C++ port is a separate
      translation, not a build dependency on this repo.
    """

    confirmation ~S"""
    - `V-Sekai-fire/tri2d-cli` exists, public, MIT-licensed for its own
      code, with `vendor/geogram-subset/` kept under Geogram's
      BSD-3-Clause.
    - `cmake . && make` on a clean macOS or Linux checkout builds
      `tri2d_cli` with no other directories present.
    - Piping the 10x10-square/2x2-hole/2-interior-point control case
      into the built binary sums to area 96.0.
    """

    more_information ~S"""
    Relates to `interactor-sketch-mesh`'s `feat/cdt2d-guest-function`
    branch, which carries the C++ guest port of this same call
    sequence, and to GarmentCodeData v2's `orig_lens` regeneration
    pipeline, the Python consumer this CLI replaces CGAL for.
    """
  end
end
