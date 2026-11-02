# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2232, "RFD authoring as an Elixir DSL", :discussion do
  feature "one `rfd/NNNN-slug.exs` per RFD and one `SERIALS*.exs` per site, compiled by `rfd_dsl`; the Markdown and the `.usda` registers are renderings of them and are not tracked"
  scope "the Mix project at the repository root, every `rfd/*.exs`, `SERIALS.exs` and
`SERIALS-vsekai-fabric.exs`"

  prose ~S"""
  :: hook
  An RFD is an Elixir file, and the compiler refuses a malformed one before it is written.
  :: intrigue
  The shape was enforced after the fact by Python gates reading Markdown, and 143 problems
  accumulated before one pass fixed them.
  :: exit
  Add a new RFD as `rfd/NNNN-slug.exs` plus a `serial` line, then run `mix rfd.serials`.
  :: decision
  An RFD is an Elixir module that uses `RFD.DSL`: one `rfd` block with `state`, `feature`,
  `scope`, `flight_level`, `decision`, `problem`, `references`, `related`, `details` sections and
  `drafted_by`. The block builds an `RFD.Doc` and validates it against RFD66606-1000 while the
  file compiles, so a state outside the list, a missing Decision or a README over 40 lines is a
  compile error that names the rule.
  :: references
  - RFD66606-1000, the shape
  - RFD66606-2177, the flight_level tag on the register
  """

  details_title "RFD authoring as an Elixir DSL"

  prose ~S"""
  :: details The register and the render
  A site's serial register is a module that uses `RFD.Register`: `allocated`, `unused` and
  `deleted` blocks of `serial`, `never_written` and `retired` rows.
  `mix rfd.render` writes README.md, DETAILS.md and `SERIALS*.usda`, the shape the
  gates and `pen-66606.usda` read, and those files are ignored by git.
  :: details Why Elixir
  The taskweft domains beside many RFDs are already Elixir, so the authoring form that can
  refuse a malformed document before it is written is the language the repository already runs.
  :: details The flight level
  RFD66606-2177: the register carries `flight_level`, so the DSL writes it to the register
  row, not the README.
  :: details Layout
  One file per RFD, `rfd/NNNN-slug.exs`, rendered into `rfd/NNNN-slug/`.
  A directory exists in git only when it carries apparatus beside the
  document (a USD layer, a skill, a script); README.md, DETAILS.md and
  `index.md` under `rfd/` are build artifacts and `.gitignore` names them.
  The registers are `SERIALS.exs` (site 1, frozen) and
  `SERIALS-vsekai-fabric.exs` (site 2, where new serials come from), rendered
  to the `.usda` beside them. A new RFD is a new `.exs` and a new `serial`
  line in the site's `allocated` block; `mix rfd.serials` refuses a source
  with no row, a row with no source, a slug that disagrees with the file
  name, and a deleted serial that has a source.
  :: details What the render is checked against
  `mix test` at the root runs the positive cases and the negative
  controls: an unknown state, a missing Decision, a 40-line overflow, a
  serial listed twice, a serial from another site, a retired row naming no
  serial, a renumbering and a revived serial are each refused. The rendered
  tree then passes `check-rfd-structure.py`, `check-rfd-serials.py`,
  `check_tropes.py` and `check_rfd_canary.py` unchanged, which is the
  compatibility claim: the DSL emits what the existing pipeline consumes.
  CI and the prek hooks render before any gate reads the tree, and the
  diff-based gates scope themselves by the changed `.exs` sources.
  :: details What the conversion found
  Importing 306 RFDs lost no line of prose (`mix rfd.import` refuses a
  lossy import). Importing the two registers refused four rows: serial
  2143 named both `fdb-backup-fans-out-to-r2` on main and
  `close-out-gates-red-green-scout` from a merged branch, so the second
  took the next unused serial, 2233; serial 2169 was allocated and deleted
  at once; 2184 and 2186 carried slugs their directories had left behind;
  and 2232 had been appended into the deleted scope. A prose tell (an
  em-dash join, a pompous copula, an `exact` on a soft noun) in any field a
  reader sees is a compile error, like the other shape rules.
  :: details The MADR template as a block
  The seven MADR headings are a `madr` block rather than seven `details`
  strings: `context`, `drivers`, `options`, `outcome`, `consequences`,
  `confirmation`, `more_information`. The DSL owns the headings, so a
  spelling cannot drift, and it refuses a section given twice, a run out of
  the template's order, a block missing its context or its outcome, a second
  block and an empty one. A body is a string or a list of strings, and
  `consequences` also takes `good:` and `bad:` lists. `details/2` stays for
  a section outside the template, in declaration order beside the block.
  The RFDs that carry nothing but the template render the same bytes through
  it as they did through the strings. The block nests one level and `mix
  format` re-indents a heredoc to its call, so a file whose body lines
  already run past the formatter's `line_length` stays on `details` strings:
  RFD66606-2062 carries an inventory table of 124 such lines.
  :: details Related RFDs
  RFD66606-1000 (the README limit and the spine), RFD66606-2177, RFD66606-2026 (commit
  style the rendered files ride on).
  :: details What the DSL does not do
  It does not read the register from the RFD sources: a serial is a fact the
  register records once, and a deleted serial has no source to derive it
  from. It does not write: the endpoint answers, and a change is a pull
  request.
  :: details The problem
  The register was a hand-edited layer nothing compiled:
  it carried one serial on two directories, one serial allocated and deleted at once, and two
  slugs that no longer matched their directories.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2232", :provides, "rfd-elixir-dsl-compiler"
    relate "rfd-2232", :spends, "rfd-state-lifecycle"
    relate "rfd-2232", :spends, "elixir"
    relate "rfd-2232", :is_a, "ci-gate"
  end
end
