# Formats every RFD's taskweft RECTGTN domain/problem/plan file.
# Moved here from weftspun-3d-studio's own root .formatter.exs when
# decisions/ itself moved to this repository.
# `*/*` reached scripts/ when the logbook merged in, and its .exs files were
# never mix-formatted. Each half keeps the convention it arrived with.
[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "[0-9][0-9][0-9][0-9]-*/*.{ex,exs}",
    "rfd/*.exs"
  ],
  line_length: 98,
  # RFD.DSL and RFD.Register fields (the latter for a base revision's SERIALS*.exs) read as
  # declarations: `state :discussion`, not `state(:discussion)`.
  locals_without_parens: [
    rfd: 3,
    rfd: 4,
    register: 2,
    layer: 1,
    thesis: 1,
    allocated: 1,
    unused: 2,
    deleted: 1,
    deleted: 2,
    serial: 2,
    serial: 3,
    never_written: 1,
    retired: 2,
    state: 1,
    feature: 1,
    scope: 1,
    flight_level: 1,
    decision: 1,
    problem: 1,
    references: 1,
    related: 1,
    drafted_by: 1,
    details: 2,
    madr: 1,
    context: 1,
    drivers: 1,
    options: 1,
    outcome: 1,
    consequences: 1,
    confirmation: 1,
    more_information: 1,
    details_title: 1,
    details_preamble: 1,
    preamble: 1,
    front_matter: 1,
    compact_head: 1,
    abandoned_at: 1,
    attest_in: 1,
    details_pointer: 1,
    section: 2,
    prose: 1,
    rebac: 1,
    verb: 2,
    relate: 3,
    relate: 4,
    deny: 4,
    capability: 2,
    verbs_from: 1,
    renders_into: 1,
    renders_into: 2
  ]
]
