# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2351, "one ledger of BORING-TOKENs and INNOVATION-TOKENs for three orgs", :discussion do
  feature "a token is what the stack cannot run without: nineteen, seven INNOVATION-TOKENs and
twelve BORING-TOKENs"
  scope "the token ledger in the private working agreements and the private plan, the
private blocklist, and the repos of V-Sekai-fire, chibifire-stages and the private org"

  prose ~S"""
  :: hook
  Which of the nineteen tokens are INNOVATION-TOKENs, and which are BORING-TOKENs?
  :: intrigue
  The stack crashes without any of the nineteen, and only seven of them are new risk.
  :: exit
  Check a new technology against the rule: a token is a substrate, and the tech stack crashes
  without it. Write it BORING-TOKEN if its failures are widely known, INNOVATION-TOKEN if not.
  :: decision
  A token is a substrate: delete it and the tech stack crashes. The name keeps it apart from a
  credential (operator, 2026-11-01). The ledger has nineteen tokens. Each is a BORING-TOKEN,
  whose failures are widely known and which runs as shipped, or an INNOVATION-TOKEN, which is
  our own build, a fork or a use nobody has run. The INNOVATION-TOKENs are guest ELFs on the
  pinned double engine as row 1, which also runs the pen, `zone.elf`, the ggml-rd models,
  `slug.elf`, voice, the USD guest and the Lean tests, then SQLite on FoundationDB pages as row
  2, Bao as row 3 (our fork with an FDB storage backend), FEX as row 6, the Fedora cross-build
  image as row 12, osxcross as row 15 and the taskweft persona engine as row 18. The BORING-
  TOKENs are Fly as row 4, which hosts the store, Bao and the KMS key that unseals Bao, then
  Tailscale as row 5, Proton as row 7, Windows as row 8, pixi as row 9, prek as row 10, GitHub
  as row 11, LLVM as row 13, llvm-mingw as row 14, SteamVR as row 16, Godot Engine as row 17 and
  Elixir as row 19. The operator ruled Elixir and Proton BORING-TOKENs on 2026-11-01.
  CockroachDB is retired (operator, 2026-10-18), and the guest BEAM is unship (operator,
  2026-10-29). The count was three, then two INNOVATION-TOKENs, and is nineteen tokens of which
  seven are INNOVATION-TOKENs. The ledger changes between rungs, not in an open one, and the
  operator moved the two documents on 2026-10-30 rather than wait for a rung to claim them.
  """

  details_title "one ledger of BORING-TOKENs and INNOVATION-TOKENs for three orgs"

  prose ~S"""
  :: details The measured gap
  The upstream orgs ran a second database. Of 312 repos that use a non-boring
  technology, 182 fit inside one INNOVATION-TOKEN when each technology is its own.
  :: details How the ledger was found
  The operator requested it on 2026-10-18: study the three orgs and
  consolidate the INNOVATION-TOKENS with frontier learning, with no limit on the
  count. Each org is a level. Each repo that uses a non-boring technology
  is a problem: 298 in V-Sekai-fire, 10 in the private org (the local
  checkouts, because the token cannot list the org) and 4 in
  chibifire-stages. A problem passes when every technology it uses is in
  one INNOVATION-TOKEN. Repos were tagged against 33 technologies from their names,
  descriptions, topics and languages.

  A step tries one move, "technology X rides on INNOVATION-TOKEN Y". The level with
  the most regret picks it. The move is kept only when total passes rise
  and at least two repos use both. Two planted moves with no relation
  (Ink onto OpenBao, Janet onto CockroachDB) were controls, and both were
  rejected.

  :: details What it measured
  - Passes rose from 182 to 263 of 312 (58% to 84%): 23 moves kept, 11 rejected.
  - Per level at the end: V-Sekai-fire 251 of 298, the private org 8 of
    10, chibifire-stages 4 of 4.
  - Kept onto the guest INNOVATION-TOKEN: the pen, `zone.elf`, ggml-rd (and the
    Python reference models and Slang kernels behind it), MuJoCo,
    OpenUSD, voice, Rust guests, `slug.elf`, the double engine with
    xr-pilot and CineForm, and Lean as tests.
  - Kept onto the BEAM: taskweft, MCP, holographic reduced representations.
  - Not merged, for want of shared repos: CockroachDB, the casync chunk
    store, OpenBao and parquet into the store. Retiring CockroachDB was
    an operator decision, not a measured one.

  :: details What is still split
  - Elixir and guest code meet in 29 repos (taskweft compiled to a
    guest, the Godot build service, the MCP guest, the private org's
    double-engine repository). That boundary decides two big INNOVATION-TOKENS or
    one.
  - Terraform, Ink, Janet, TLA+, gaussian splats, hypercore and
    Go each sit alone. Each is a candidate to retire or park.
  - The tagging reads metadata, not code. Two third-party engine
    scripting tags landed in the guest INNOVATION-TOKEN on a loose keyword. The
    moves were written by the agent. The measurement only checked them
    against shared repos.

  :: details The parts added on 2026-11-01, classified
  The operator asked for the ledger to name these parts and ruled that each is a token
  (operator, 2026-11-01). The class of each follows the test in the decision.
  - Row 3, Bao, is an INNOVATION-TOKEN. The zone talks to the store directly, and reaches Bao
    rarely, to get or renew the credential it presents to the store.
  - Row 4, Fly, is a BORING-TOKEN. Delete it and the store, Bao and the KMS key that unseals Bao
    go with it.
  - Row 5, Tailscale, is a BORING-TOKEN. Delete it and the game cannot be updated, so the
    transactions of a CRUD update are affected.
  - Row 6, FEX, is an INNOVATION-TOKEN, and row 7, Proton, is a BORING-TOKEN (operator,
    2026-11-01). Delete either and the win64 build stops running on the Steam Frame, the Steam
    Deck or the Mac test, so the campus beta of RFD66606-2360 crashes on those targets.
  - Windows (row 8), pixi (9), prek (10) and GitHub (11) are BORING-TOKENs. The build and gate
    tools count as the tech stack.
  - The Fedora cross-build image (row 12) and osxcross (row 15) are INNOVATION-TOKENs. LLVM
    (row 13) and llvm-mingw (row 14) are BORING-TOKENs. Each is its own substrate, so deleting
    one stops a cross-build.
  - The SteamVR runtime (row 16) and Godot Engine (row 17) are BORING-TOKENs, and the taskweft
    persona engine (row 18) is an INNOVATION-TOKEN. Godot Engine and the pinned double engine of
    row 1 are separate tokens (operator, 2026-11-01).
  - Elixir (row 19) is a BORING-TOKEN (operator, 2026-11-01). It runs every gate and the
    ledger's own tools, and its failure stops them, so it counts under the tool ruling.
  - GitHub's identity-token login rides row 3, because it is a login to Bao.

  :: details What is not known
  - How many INNOVATION-TOKENs the stack may hold. The old limit was two, and seven now stand.
  - Whether the classes of the rows the operator did not rule on one by one stand as written.

  :: details Related RFDs
  - RFD66606-2341, dev.next, where this waits; RFD66606-2309, frontier learning.
  - RFD66606-2006 and RFD66606-2075, abandoned.
  - The private blocklist, the CockroachDB row.

  :: details CockroachDB, retired
  - The private org: a row in the private blocklist.
  - Weftspun: a manuals pull request, merged.
  - Moved to SQLite on FoundationDB, all merged 2026-10-18: the zone
    backend contract (its leftover CockroachDB deploy and notes), the
    taskweft MMOG agent and the residual FSQ recommender (both tested in
    CI on a real FoundationDB), and the multiplayer fabric hosting
    service (compose only, never run: no desk runs containers).
  - Also moved, merged 2026-10-18: weftspun-character-taxonomy. Its
    image no longer starts a CockroachDB node, and CI finds its test
    database's keys in FoundationDB. The smoke-test scripts in the
    multiplayer fabric meta repo wait for a merge with no CI.
  - Archived: the fabric's CockroachDB service, the Dokku CockroachDB
    service, the vertex interactor, the fabric's container service, the
    fabric gateway transport and the fabric infra service (the Terraform
    for the Fly app, whose daily backup found no started machine on
    2026-10-18).
  - The pinned taskweft dependency still pulls postgrex.
  - The analysis script was Python in a scratch directory. It is not kept
    here, by the languages rule.

  :: details The BEAM row, unship (operator, 2026-10-29)
  No guest runs BEAM bytecode, and no `beam.elf` exists in the tree. The
  only novel piece of the row is RFD66606-2330's static riscv64 BEAM, and
  that is the piece to unship. Counting the BEAM as an INNOVATION-TOKEN spent the slot
  that merging the pen and the shared world freed.

  :: details The two rows, moved (operator, 2026-10-30)
  - The private plan: "The three innovation tokens" is two. The ledger
    table's pen row and zones row are one guest row, which absorbs the
    "already paid" RISC-V row, and the store row is INNOVATION-TOKEN 2.
  - The private working agreements: "There are three, and all three are
    spent" is two, naming guest ELFs on the pinned double engine as the
    INNOVATION-TOKEN the pen and `zone.elf` share.
  - The operator moved both on 2026-10-30, outside a rung, rather than
    waiting for one to claim them, and RFD66606-2341's item left
    dev.next.
  :: details The problem
  Elixir runs every tool and is a BORING-TOKEN.
  """

  rebac do
    verb :provides, "the subject, once accomplished, mints the object token"
    verb :spends, "the subject is accomplished only by spending the object token"
    verb :is_a, "the subject is a kind of the object, as a subclass is of its class"
    verb :owns, "the subject is composed of the object, as an object owns the parts it has"
    verb :controls, "the subject decides what the object does"
    verb :delegated_to, "the subject hands its control to the object"
    verb :has_capability, "the subject may use the object capability"

    verb :is_member_of,
         "the subject belongs to the object group, and inherits what the group holds"

    verb :supervisor_of, "the subject answers for the object's work"
    verb :partner_of, "the subject and the object share a goal as peers"
    relate "datasource-store", :provides, "fdb-sqlite"
    relate "private-lab", :provides, "fex"
    relate "elixir", :spends, "pixi"
    relate "weftspun", :owns, "fdb-sqlite"
    relate "weftspun", :owns, "fex"
    relate "weftspun", :owns, "guest-elf-double"
    relate "weftspun", :has_capability, "bao"
    relate "weftspun", :has_capability, "fly"
    relate "weftspun", :has_capability, "tailscale"
    relate "weftspun", :has_capability, "proton"
    relate "weftspun", :has_capability, "pixi"
    relate "weftspun", :has_capability, "prek"
    relate "weftspun", :has_capability, "cross-build-image"
    relate "weftspun", :has_capability, "elixir"
  end
end
