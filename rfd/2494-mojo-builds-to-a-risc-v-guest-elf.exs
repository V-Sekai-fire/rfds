# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2494, "mojo builds to a risc-v guest elf", :discussion do
  feature "a Mojo program with its standard library runs as a sandbox guest."

  scope "the Mojo guest sample: build, runtime stand-ins, public function and limits."

  prose ~S"""
  :: hook
  Can Mojo be a guest language here, with its standard library and async tasks, when Modular
  ships no RISC-V build of the runtime Mojo's startup calls?
  :: intrigue
  Mojo emits a RISC-V object and links no cross-compiled executable. Its startup calls 28
  runtime entry points. Modular publishes those sources, but some headers they include are
  missing from the tree. The sandbox host also refuses an ELF that does not name its Variant size.
  :: exit
  Run the sample in the engine's Sandbox build. It prints through the standard library, adds up
  three async tasks and answers a vmcall for add_numbers(3, 4) with 7. Then run the limits tests.
  :: decision
  - A Mojo guest is an object linked statically by clang and lld against the committed riscv64
    sysroot (operator, 2026-11-14).
  - Modular's runtime is forked, not rewritten: one file is used as published over stand-ins for
    its unpublished headers, and the async runtime is its thread pool with one worker (operator,
    2026-11-14).
  - The guest names its Variant size, 40 bytes for a double-precision host, in its own section.
  - The public function is registered while main runs. The Variant glue is C, the logic Mojo.
  - Each limit of the guest is a witness property that is red until the limit is lifted, with a
    control that stays green (operator, 2026-11-14).
  - Mojo is a guest language beside SafeGDScript, which stays first for new guest code
    (operator, 2026-11-14).
  :: related
  - RFD66606-2391, guests are built at double precision, which the Variant size follows.
  - RFD66606-2492, whose session rules name the guest languages.
  - RFD66606-2420, C guests built at double and tested with Lean.
  - RFD66606-2372, heavy compute runs in a sandbox guest.
  """

  details_title "mojo builds to a risc-v guest elf"

  prose ~S"""
  :: details What was run
  The sample is its own repository in our organisation, started on 2026-11-14.
  - The Mojo compiler is pinned to a 1.3.0 nightly. RISC-V emission was missing from nightlies
    after 1.0.0b3.dev2026071006 and through at least 1.1.0.dev2026081505, and works in the pin.
  - It ran in the engine's double-precision Sandbox build in a real window, and in the safe-Rust
    libriscv port, which has no Sandbox host. A Godot build without the Sandbox class fails it.
  :: details The limits
  The tests are in its tests directory. They run in the Rust port, and the string test also runs
  in the engine, because a string lives in the host. Every property holds today: int, bool, float,
  string and object Variants, one worker, parallelize on one worker, and a spin lock under tasks.
  The Wait_Timeout test passes in the engine, where the guest reads Godot's clock, and is skipped
  in the Rust port, which has no host clock. A vmcall of an echo function returns each of the
  five types unchanged in the engine. A host that passes native arguments gets its own function,
  add_numbers_native, which returns 7 for 3 and 4. Only that function has a native form. Nothing
  is red. A timed wait polls the clock and each poll is charged to the instruction budget, so the
  engine test sets the budget to no limit.
  """
end
