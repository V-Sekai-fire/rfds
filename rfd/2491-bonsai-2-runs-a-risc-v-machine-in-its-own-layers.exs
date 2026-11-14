# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2491, "Bonsai 2 runs a RISC-V machine in its own layers", :discussion do
  feature "a Bonsai 2 server answers a calc tool call from inside its own artifact: eleven Gated
DeltaNet layers hold a 32-bit RISC-V processor, and the server's recurrent state is its memory"
  scope "the chip tower as a component of the Bonsai 2 `.ninfer` artifact, the qwenputer compiler
that writes it, the ninfer-all converter and engine that store and run it, and the calc firmware"

  prose ~S"""
  :: hook
  Can Bonsai 2 answer an arithmetic tool call with no program outside its own weights?
  :: intrigue
  A tool call leaves the model: the host parses it, runs a program and writes the answer back.
  A compiler can instead write a processor as transformer layers, and then no host runs anything.
  :: exit
  Export the tower, check it against the reference machine, convert, then run the witnesses.
  :: decision
  The Bonsai 2 artifact carries a chip tower: an RV32IM processor with the Zba extension, compiled
  by qwenputer into eleven Gated DeltaNet layers of Bonsai 2's head geometry. The tower is its own
  component beside the text tower. The ternary body is stored unchanged, object for object.

  The server runs every token through the tower. The tower names the next token where it owns the
  position, and the body names it everywhere else. A firmware is a recurrent state the server
  loads, selected with `--chip`. The first firmware is the calc tool (operator, 2026-11-13).
  :: related
  - RFD66606-2311 (Bonsai 2 serving), whose artifact and server this extends.
  - RFD66606-2462 (the prism llama.cpp branch), a second runtime the same export can feed.
  """

  details_title "Bonsai 2 runs a RISC-V machine in its own layers"

  prose ~S"""
  :: details How the machine sits in the model
  qwenputer (MIT) compiles a circuit into the two sublayers of a Gated DeltaNet layer. An MLP unit
  is a lookup, and a recurrent head is a table whose rows a one-hot key overwrites. No weight is
  trained. The processor's registers, ROM and RAM are the heads' state rows.

  A run looks like this in the token stream. The body writes a tool call in its own syntax. The
  tower copies each token of the call into a text buffer. At the closing tag the tower takes over
  and emits chip tokens, one record per instruction. Each byte the firmware prints comes back as
  the body's own token for that byte, so the body reads a tool response it wrote itself. Chip
  tokens run through the tower only. The body's layers, cache and positions see the text alone.

  :: details Why the tower is a separate component
  Upstream widens the host model and puts the processor in the added residual dims. Bonsai 2
  cannot take that route:

  - The body is Hadamard-rotated ternary in 1024-column blocks. Zero padding, mute columns and
    rescaled norm gains do not survive that packing word for word.
  - The engine's kernels are registered for the body's hidden size.
  - The chip token rows hold values such as 2^40, which are not ternary.

  So the tower keeps its own residual stream of 1280 dims, its own token table and its own
  states, and the body stays byte-identical. This is upstream's own fast decoding path, which
  already runs the chip layers as a second view with a second cache.

  The circuit is compiled for Bonsai 2's head geometry (16 key heads, 48 value heads, head
  dim 128, conv kernel 4), so the engine's recurrent kernels run it. The MLP is cut from the
  body's 17408 units to the 8576 the circuit uses.

  :: details The tower export
  `chipformer.rv.export_tower` in the qwenputer fork reads the host's config and tokenizer and
  writes a directory: `config.json` with architecture `ChipTower`, and `model.safetensors` with
  the eleven layers under their usual names, the token table and each firmware's parked state.
  A host token keeps its id and chip token t has id 248320 + t. Every tensor passes the
  compiler's bf16 check on the way out.

  :: details The converter
  `--source chip=DIR` and `--components ...,chip` add the tower to recipe `bonsai2_27b_ternary`.
  Tower parameters are stored in direct formats (bf16, and fp32 for the states and the decay
  constants) by method `exact_direct`, which refuses a value the format would round. Each
  parameter is its own object. The converter refuses a tower whose head geometry or token offset
  differs from the text model's.

  :: details The published artifact
  The artifact with the tower is `models/chip/bonsai2-27b-heretic-chip.ninfer` in the public
  dataset that holds the artifact of RFD66606-2311. Its SHA-256 is in
  `models/chip/SHA256SUMS` beside it. The tower's source and the golden stream are in
  `sources/tower-27b/`. The dataset's `NOTICE` names qwenputer and the libraries
  the calc firmware is linked with.

  The conversion reads the tower from a path inside the checkout, so the artifact and its
  report name no host directory, and the job that publishes them stops if one does. Every
  object of the published file equals the object of the file the served witness ran on.

  The steps an operator follows are `v-sekai/chip-tower-sop.md` in the ninfer-all fork, the
  repository interactor-language-ninfer.

  :: details Ternary planes
  Every tower matrix is a sum of ternary planes: weights in {-1, 0, +1} with one scale per
  row and group of 128 columns, or per column and group of 128 rows where that needs fewer
  planes. Each weight sits in one plane, so the sum equals the matrix bit for bit. Of the 89
  matrices, 82 need at most two planes and none needs more than seven.

  The scales are not binary16 values: they range from 2^-41 to 2^125. A ternary tower therefore
  needs a plane format with bf16 scales and no Hadamard rotation, which the artifact container
  does not have yet. Until it does, the tower is stored dense.

  :: details Witnesses
  Each one carries a control that must fail.

  - **Compiled.** The circuit for Bonsai 2's geometry has eleven layers, and every emitted
    tensor is a bf16 value. Control: a weight that is not a bf16 value raises.
  - **Reference tower.** In stock Qwen3.5 modules, the residual after the chip layers equals the
    circuit evaluator's on every kept dim at every position, token by token and as a chunked
    prefill, with the firmware state loaded after the prompt as a server loads it. The output
    code names the reference machine's next token wherever the machine owns the position.
    Measured with the calc firmware: 17,387 positions token by token and 261,213 positions as a
    prefill, each with no inexact position and no wrong token.
    Controls: one flipped ROM word, one flipped MLP weight, and fp16 recurrent state each fail.
  - **Planes.** The planes of every matrix sum back bit for bit. Control: one flipped sign fails.
  - **Converted.** Every tower object reads back word for word, and every text, vision, MTP
    and DFlash2 object hash equals the one in an artifact converted without the tower. Measured:
    1,513 parameters compared and none differs, and all 178 tower parameters hold their source's
    words. Control: one planted bit in a text object fails.
  - **Engine ops.** One token at a time through the engine's public ops, the kept dims equal
    the golden file bit for bit over 17,792 positions. Controls: fp16 tower state fails, and one
    flipped weight bit fails.
  - **Engine runtime.** The tower loaded from the converted artifact by the engine's own loader
    gives the same result: no inexact position, 17,104 owned positions, no wrong token. The same
    two controls fail.
  - **Served.** `ninfer-serve --chip calc-bridge` at temperature 0, twelve arithmetic prompts:
    21 bursts and 80,468 chip tokens, each served token equal to the reference machine's when it
    is fed the model's own call tokens. All twelve values equal Python's, and a power too large
    for the firmware returns its `error`. Controls: without `--chip` the call comes back
    unanswered, and with the ROM word the parked machine runs next spoiled in a copy of the
    artifact, every burst differs from the reference.
  - **Body unchanged.** A prompt with no tool call gives the same temperature-0 answer hash
    with `--chip`, without it, and on the engine before this work, for the same prompt text.

  :: details Serving
  `--chip NAME` selects a firmware and adds the calc tool to a request that declares none. The
  answered call is returned inline in the content: the call, the tool response the firmware
  printed, then the model's answer. `--chip-trace FILE` writes each burst's tokens.

  A `--chip` server has one request lane and one device. It runs with no drafter or with the
  DFlash2 drafter at up to 11 draft tokens. Any other combination stops at startup. A request
  whose echo is cut by the output limit ends with the limit reason.

  On one RTX 4090 a burst runs at 500 chip tokens per second. Text decodes at 93 to 99 tokens
  per second with `--chip` and DFlash2 at five draft tokens, at 69 to 71 with `--chip` and no
  drafter, and at 171 to 190 on the server of RFD66606-2311 without the tower.

  :: details Drafting beside the tower
  A DFlash2 round commits at most one token more than its draft tokens. While a tool call is
  open, the server gives a round a budget of one token, so the round carries no draft and the
  closing tag is the last token of its round. The burst starts there. The echo is forced
  through the text model by the path the thinking-budget close uses, and that path also
  appends the drafter's context.

  The budget of one starts in the round after the opening tag. A round that held the opening
  tag, the closing tag and one more token would commit text before the echo. The shortest
  well-formed call is 12 tokens, and a round at 11 draft tokens holds 12, so no well-formed
  call fits. A malformed call shorter than a round is detected and counted, not prevented.

  Served with DFlash2 at five draft tokens, 47 bursts and 121,346 chip tokens equal the
  reference machine's, 34 of 34 prompts equal Python, no round commits more than one token
  while a call is open, and no owned position is skipped. Controls: with the budget of one
  switched off by a test option, 234 rounds commit more than one token while a call is open,
  and with the ROM word spoiled every burst differs.

  :: details Open questions
  - The n-gram drafter, MTP and DFlash are refused beside the tower. The n-gram drafter is the
    larger part of the speed that a `--chip` server still gives up.
  - A malformed call shorter than a round can pass its closing tag. Preventing it needs a
    partial commit of a round, which the engine does not have.
  - Each prompt token and each decoded token steps the tower by itself, also on a prefix-cache
    hit. Chunked calls would cost less, and whether the chunked ops are bit-exact on the tower is
    unmeasured.
  - A burst runs inside one engine unit, so a cancel is seen only after it.
  - Thinking mode, streaming, the other endpoints, structured output and histories that hold
    earlier calls have not run with `--chip`.
  - How often Bonsai 2 writes a well-formed calc call on its own is unmeasured.
  - The tower is stored dense. The plane format above is not built.
  :: details The problem
  Bonsai 2 cannot do exact arithmetic on its own, and a host tool adds a round trip and a
  second program to trust.
  """
end
