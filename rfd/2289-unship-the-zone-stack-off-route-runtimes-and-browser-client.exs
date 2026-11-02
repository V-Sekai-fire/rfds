# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2289, "Unship the zone stack, the off-route runtimes and the browser client", :published do
  feature "documentation retraction"
  scope "the 42 RFDs this document retracts"

  prose ~S"""
  :: hook
  Forty-two RFDs with no placed code move to abandoned.
  :: intrigue
  RFD66606-2287 is the active rung. No project on this desk cites these 42 in code
  or commits.
  :: exit
  Before you cite one of the 42 abandoned RFDs, read RFD66606-2287, the rung that replaced their
  route. Their full text stays in git.
  :: decision
  Abandon 42 RFDs off RFD66606-2287's critical path that no placed code
  implements. Each moves to `abandoned` with this document. Its details
  go, and its full text stays in git at `a6eb679`.

  - The zone stack: zone-server-h2o, the MUD shell, the slot-map and FDB
    benchmark, and godot-loop-slice. RFD66606-2287 puts zones in `zone.elf`
    guests, and RFD66606-2288 carries 2092's guest gate.
  - Runtimes off the godot-sandbox, ggml-rd and compute-rd route.
    Diffusion reaches the GPU through that route, because it is
    EditScore's basis and EditScore becomes a decision model (RFD66606-2268).
  - The browser studio client, its dev setup and its asset edge.
  :: related
  - RFD66606-2285, the same walk-back; RFD66606-2242, the retracted native ggml modules.
  """

  details_title "Unship the zone stack, the off-route runtimes and the browser client"

  prose ~S"""
  :: details The retracted OIDs
  - Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1006,1008,1022,1023,1031,1042,1043,1056,1061,1077}
  - Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1148,1169,1172}
  - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2002,2004,2005,2010,2014,2066,2070,2072,2073,2074}
  - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2076,2077,2078,2079,2080,2081,2082,2083,2084,2085}
  - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2086,2091,2092,2108,2110,2116,2120,2163,2214}
  :: details The groups
  - Zone stack: 2002, 2004, 2005, 2010, 2014, 2066, 2070, 2072, 2073,
    2074, 2076 to 2086, 2091, 2092, 2108, 2110, 2116, 2120. The manifest
    places none of zone-server-h2o, the MUD shell or godot-loop-slice.
  - Off-route runtimes: 1031 (a standalone trellis2cpp binary), 1042 and
    1043 (standalone model images), 1148 (LiteRT), 1169 and 2163
    (llama-mtmd-cli), 1172 (an NPU or a desk GPU outside the sandbox),
    2214 (a GDExtension `Ggml.load_model()`).
  - Browser studio client: 1006, 1008, 1022, 1023, 1056, 1061, 1077. The
    JavaScript client the first four and 1061 extend is not placed.
  :: details How the 42 were chosen
  Of 249 open RFDs, 226 sit outside RFD66606-2287, its eight citations and
  their fifteen, and the curvenet RFD66606-2265, RFD66606-2266, RFD66606-2269 and RFD66606-2274.
  Code files and commit messages across every checked-out project except this one cite 52 of the
  226 by number, and those stay open.

  Each of the other 174 had its named artifacts searched for in the
  placed tree: 62 found nothing, 9 found a runtime off the route, 38 found
  code, 32 found stubs, 26 are process rules, and 7 live in a checkout
  absent from this desk. The operator kept 2213, 2244 and 2268 as
  the guest stack's planned work and picked the three groups above from the
  rest. The negative controls are RFD66606-1010, RFD66606-1013, RFD66606-1095 and RFD66606-1103,
  abandoned by RFD66606-2285 for having no code: each scores zero cites.

  The 26 manifest paths absent from this desk, most of them engine
  branches, are unchecked.
  :: details The problem
  A search of the placed tree finds no implementation,
  or one on a runtime the workspace does not use.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2289", :provides, "zone-stack-unshipped"
    relate "rfd-2289", :is_a, "workspace-policy"
  end
end
