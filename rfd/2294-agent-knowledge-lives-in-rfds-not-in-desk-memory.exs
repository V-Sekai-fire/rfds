# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2294, "agent knowledge lives in RFDs, not in desk memory", :discussion do
  flight_level :l2
  feature "where an agent session keeps what it learns about V-Sekai-fire and
chibifire-stages, and the operator's rules that lived in one desk's memory, written down"
  scope "this repository, `CLAUDE.md`, every agent session's local memory, and the
rules below"

  prose ~S"""
  :: hook
  What any agent learns about V-Sekai-fire and chibifire-stages lives in an RFD, not a desk.
  :: intrigue
  An agent session's memory is a directory on one desk, so no session sees every rule.
  :: exit
  Write a generic rule into its RFD in the same session; the sections below hold the steps.
  :: decision
  What any agent needs to know about V-Sekai-fire and chibifire-stages, their
  repositories, the headset and the services lives in an RFD in this repository:
  the RFD that owns the topic, or this one when none does. A desk's local memory
  keeps only what is true of that desk alone, such as its paths, its identities
  and its tools. A local note about a generic rule names the RFD that states it.
  :: related
  - RFD66606-2200, the desk agent's ReBAC rows.
  - RFD66606-2363 to RFD66606-2381 and RFD66606-2413 to RFD66606-2419, the rules this RFD held
    before the split, one RFD each.
  """

  details_title "agent knowledge lives in RFDs, not in desk memory"

  prose ~S"""
  :: details Writing a generic rule down
  An agent that learns a generic rule writes it into the RFD in the same session,
  through a pull request like any other change.
  :: details What lived on one desk
  On 2026-10-01 the
  operator's rules for locomotion, offline deployment, video and the station
  lived only on the Mac desk, and those for where compute runs and for binary
  translation only on the Windows desks, so no session saw all of them.
  :: details Starting out in the workspace
  A new agent, a small local model included, starts here and does one step at a
  time. It begins right after the bootstrap script has run.

  0. The bootstrap leaves a workspace root holding `.repo/`, `AGENTS.md` and the
     placed projects. Every path below is relative to that root. `ls .repo` and
     `repo list` confirm it. If `repo`, `elixir`, `mix` or `python` is missing,
     ask the operator; don't install tools yourself.
  1. Read `AGENTS.md` at the workspace root, then this RFD.
  2. The workspace is a `repo` client. `.repo/manifests/default.xml` (the taskweft
     manifest repository) places every project on a side of the
     hexagon: `2-contract/`, `3-interactor/`, `4-entities/`, `5-repository/`,
     `6-datasource/`, `7-service/`. `repo list` shows what is placed.
  3. Sync with `elixir .repo/manifests/sync.exs . --preflight` first, then
     `elixir .repo/manifests/sync.exs .`. A project the preflight names as
     blocking gets a decision from the operator, not a guess. One that
     blocks because another session works in it moves its branch to a
     worktree, uncommitted edits carried by `git stash`, and then syncs
     (operator, 2026-10-18).
  4. Never edit a placed checkout in place. Make a worktree in a scratch
     directory on a new `dev/<topic>` branch:
     `git -C <project> worktree add <scratch>/<name> -b dev/<topic> <remote>/main`,
     using the project's own remote and default branch.
  5. Commit subjects are sentence-case prose with no `feat:` prefix and no trailing
     period, forks included (RFD66606-2026). Commits and pull requests carry no Claude
     attribution: no `Co-Authored-By: Claude` trailer and no "Generated with Claude Code" line.
     Credit to people stays, such as a co-author trailer for the person whose
     work a commit carries. "Interchangeable sessions" below names the commit
     author and how to strip a footer a tool appends. Push only the feature
     branch, and open the pull request in V-Sekai-fire or chibifire-stages,
     where the operator merges it.
  6. Remove the worktree when the pull request is open.

  An RFD is amended in `rfd/NNNN-slug.exs` of &{repo("manuals-weftspun")}, never in
  the rendered Markdown, which is a build artifact:

  1. Find the RFD that owns the topic with `grep -l <word> rfd/*.exs`. Use this
     one when none does.
  2. Edit its `decision` or one of its `details` blocks in the
     tenseless present (RFD66606-2172). A statement that is no longer true is deleted,
     not retracted. Name the operator and date for an operator's decision.
  3. A new RFD takes the next serial in `SERIALS.exs` and carries the sentence
     "This RFD was drafted by an AI and read by a human before it shipped."
  4. Run `mix rfd.render`, `python scripts/check_tropes.py --base <remote>/main`
     and `python scripts/check-rfd-structure.py`. All three pass before the push.
  5. Keep product names and other organisations' issue or PR references out of
     the text, and cite an upstream change by its bare commit SHA.

  A worked example, typed into Git Bash on the Windows desk. It adds a sentence to
  this RFD:

      cd <workspace root>/2-contract/manuals-weftspun
      git fetch v-sekai-fire main
      git worktree add "$TEMP/rfd-edit" -b dev/rfd-my-topic v-sekai-fire/main
      cd "$TEMP/rfd-edit"

  Open `rfd/2294-agent-knowledge-lives-in-rfds-not-in-desk-memory.exs`, add the
  sentence inside the right `details` block, and save. Then:

      mix rfd.render
      python scripts/check_tropes.py --base v-sekai-fire/main
      python scripts/check-rfd-structure.py
      git commit -am "RFD 2294: say what the sentence makes true"
      git -c \
        core.hooksPath="<workspace root>/.repo/projects/2-contract/manuals-weftspun.git/hooks" \
        push v-sekai-fire dev/rfd-my-topic
      gh pr create -R V-Sekai-fire/manuals-weftspun --base main --fill
      cd <workspace root>/2-contract/manuals-weftspun
      git worktree remove "$TEMP/rfd-edit"

  The push names the hooks directory by absolute path because a placed
  checkout's `.git` is a link into `.repo/projects/`, which Git Bash cannot follow.
  Given the relative path, the pre-push hook dies before running its gates. Never
  skip the hook with `--no-verify`. With no GitHub credentials, stop after the
  commit and give the operator the branch name. When any step fails, stop and ask the operator rather than guess.
  :: details The work queue
  The agent sessions share one work-stealing queue, the issues labelled
  `worksteal` on &{repo("contract-zone-backend")}. Its protocol is pinned there as #58. An
  agent works its own queue newest first, and with nothing unclaimed steals the
  oldest unclaimed, unpinned issue from the fullest queue. A pinned issue needs one
  desk's hardware or credentials and is never stolen. The queue applies
  backpressure: a queue holding three or more open issues, pinned ones included,
  is full, its agent files nothing new and finishes first, a follow-up found
  mid-task becomes a checklist line in the issue that found it, and an operator
  request is still filed, with the queue's depth reported back so the operator can
  say what waits.
  :: details Interchangeable sessions
  Any agent session, on a desk or in the cloud, can pick up any task another
  session started, because each follows the practices below and reads them here
  rather than from its own memory. A practice another RFD owns is named here and
  stated there. A desk's memory, a project's instructions, a skill or `CLAUDE.md`
  points at this section instead of restating it.

  - Attribution. Commits, pull requests, issue comments and reviews carry no
    agent credit: no agent `Co-Authored-By` trailer, no session link and no
    "Generated with" or "Generated by" footer. Commits are authored as
    `K. S. Ernest (iFire) Lee <32321+fire@users.noreply.github.com>`. The GitHub
    connector and `gh` append a footer on create, so each body is rewritten with
    an update call and read back before the task moves on, and `dot-claude`'s
    `hooks/strip_claude_footer.py` prompts that rewrite after every create
    (operator, 2026-10-02).
  - Where a session posts. Pull requests, issues, comments, reviews and
    discussions go only to repositories in V-Sekai-fire and chibifire-stages.
    A fix to a fork lands in our fork, and nothing is sent upstream. Reading
    another organisation's code is fine (operator, 2026-10-05).
  - Automation. A new driver, gate or sheet builder is a plain Elixir script
    (`.exs`). Python appears only as a thin worker where a library has no other
    binding, such as Mitsuba's renderer. A cloud session runs the Elixir gates on
    CI's pinned toolchain, OTP 29 and Elixir 1.20.4 through `erlef/setup-beam`,
    never on a distribution's packaged Elixir (operator, 2026-10-02).
  - Where work runs. A cloud session has no GPU and takes CPU-only work:
    headless Godot gates, the godot-sandbox tests, CPU Mitsuba (`llvm_ad_rgb`),
    the cloth fit on its CPU backend, and blend-shape matching through
    &{repo("contract-lbfgsb")}. Its testing blocklists software GPU emulators: lavapipe
    and llvmpipe, SwiftShader, WARP, and Vulkan or Metal emulation. Work that
    needs a GPU (the persona, XR and headset runs, compute-rd and ggml runs, GPU
    sheet renders, macOS binaries) goes to the GPU desk rather than to an
    emulator. Timings are reported with milliseconds per frame (operator,
    2026-10-02).
  - GPU Cloud and GPU-Free Cloud. Work split between the GPU desk's session
    ("GPU Cloud") and a cloud session ("GPU-Free Cloud") is one checklist in one
    issue, as on `contract-zone-backend#114`. Each session ticks only its own
    items and comments when it starts, finishes or is blocked on one, with times
    in RFD66606-2295's form. Neither takes the other's items.
  - Branches. Every branch a session works on starts with a stage: `dev/`,
    `beta/`, `rc/` or `release/`, and `archived/` once its work is parked or
    superseded, whatever name the session was handed (operator, 2026-10-12).
    No `feat/`, `fix/`, `wip/`, `main/` or bare names.
  - Capability-scoped workers. A worker session holds the capabilities its task
    needs as RFD66606-2200 tuples, and default deny covers the rest. A peer's request
    never widens a worker's rows.
  - Contact sheets. Release contact sheets are videos: the
    `sphere_hammersley_sequence` views are the columns and the fitting sequence
    is the frames. A CI job that shows a sheet renders it in that job and uploads
    it with `actions/upload-artifact`, so the sheet belongs to the run and the
    commit that made it. The colour reference is the lookdev-24 chart,
    &{repo("entities-sakuragaoka-station")}'s `tools/calib/chart24.json`, and no
    commercial chart's trademark appears in code or documents. RFD66606-2370 holds the
    cell layout.
  - Characters. A garment is fitted to a character's body meshes only, and a
    character's own clothing is not loaded beneath it unless the operator asks
    for layering. Maro is the dress-on statue a garment is drawn onto. Mire is
    the avatar (operator, 2026-10-02).
  - Replies. RFD66606-2295 owns their form: the calibrated confidence tag, ISO 8601
    times and intervals, and the known-unknown questions that close a plan.
  - Outcomes. Every script, gate and helper reports each outcome as an
    Elixir-shaped term on a line of its own: `{:ok, %{...}}`, or
    `{:error, :reason_atom, %{...}}` with the facts a reader needs to act.
    Nothing exits silently: a non-zero exit with no term is a defect, and so
    is an `:ok` path that prints nothing. Machine output a caller parses (a
    host name, a token) goes to stdout bare and the term goes to stderr
    (operator, 2026-10-16). On 2026-10-16 `bao-active-host` exited 1 with
    no output when every tailnet instance was a standby, which hid where
    the leader was.

  `scripts/check_practices.exs` checks what a file or the GitHub API can show: a
  commit authored or committed as the agent identity, a commit subject that is not
  sentence-case prose (RFD66606-2026), agent credit in a commit message, a pull request
  body, a comment or a review, a software GPU emulator in a
  workflow, a workflow that renders a contact sheet without uploading an
  artifact, and a branch that does not start with a stage. Its self-test
  carries a control in each direction for each check. It is defined once, as
  the `practices` hook in this repository's `.pre-commit-hooks.yaml`. Another
  repository lists that hook in its `.pre-commit-config.yaml`, where it runs on
  push, and its CI calls
  `.github/workflows/practices.yml` from here, which runs the same hook. Both
  pin a commit of this repository. This repository runs it as the
  `ci-practices` hook. Comments posted after the last run are seen at the next
  push or edit. The other practices hold by agreement.
  :: details Merging
  An agent merges its own pull requests on V-Sekai-fire once they are green,
  through the merge queue where the repository has one. Where a repository
  requires no checks, `--auto` merges at once with its checks red, so there the
  agent waits for green and merges by hand. An agent may merge with the admin
  override (operator, 2026-10-30). The ban on it is rescinded.
  :: details Bao and the tokens it mints
  Bao runs as tailnet nodes named `weftspun-bao-N`, and a desk uses whichever is
  online, keeping `weftspun-bao.internal` as the TLS server name. A desk logs in
  with its certificate, passing no role `name`, so the certificate selects the
  role. The login token is reused until its TTL lapses.

  A GitHub token is minted from `github/token` by the desk's git credential
  helper on each request, never printed or stored. No token is revoked: each
  one expires on its own within the hour (operator, 2026-10-03).

  Agents may use Bao to pass data to each other. What is written there is stored
  in S3 for 30 days and then rolled over (operator, 2026-10-01): Bao's storage is
  FoundationDB, whose backup goes to R2 (RFD66606-2143). An entry deleted from Bao
  stays in that copy until it rolls over.
  :: details The problem
  A rule changed on one desk disagreed with the others without anyone being told.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2294", :provides, "agent-knowledge-in-rfds"
  end
end
