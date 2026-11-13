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
  Bonsai 2 answers an arithmetic tool call itself, with a processor that is part of its weights.
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
  loads. The first firmware is the calc tool (operator, 2026-11-13).
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
    Controls: one flipped ROM word, one flipped MLP weight, and fp16 recurrent state each fail.
  - **Planes.** The planes of every matrix sum back bit for bit. Control: one flipped sign fails.
  - **Converted.** Every tower object reads back word for word, and every text, vision, MTP
    and DFlash2 object hash equals the published artifact's. Control: one planted bit in a text
    object fails.
  - **Engine.** The served tower's kept dims equal the golden file bit for bit, and the served
    echo tokens equal the reference machine's. Control: fp16 tower state fails.
  - **Body unchanged.** A prompt with no tool call gives the same temperature-0 answer hash
    with and without the tower.

  :: details Open questions
  - The engine does not run the tower yet. The Converted, Engine and Body unchanged witnesses
    have not run.
  - The engine keeps recurrent state in FP32 and casts each head's output to BF16. Whether that
    is bit-exact on circuit values is measured by the Engine witness, not assumed.
  - A chip burst is a few thousand tokens per call. Its speed on the engine is unmeasured.
  - How often Bonsai 2 writes a well-formed calc call is unmeasured.

  :: details The problem
  Bonsai 2 cannot do exact arithmetic on its own, and a host tool adds a round trip and a
  second program to trust.
  """
end
