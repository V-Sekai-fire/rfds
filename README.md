# manuals-weftspun

The workspace's design record: its RFDs, logbook and working agreements, with the Elixir project that renders and gates them.

## What it is for

Each RFD and each serial register is an Elixir source that checks its own shape while it compiles, and the Mix project renders the RFD sources to Markdown. The working agreements every project in the workspace follows are in `CLAUDE.md`. RFD66606-1000 owns the conventions and RFD66606-2232 owns the authoring format.

## Build and run

    mix rfd.render
    mix test

The remaining gates run as prek hooks.

## Write a new RFD

    mix rfd.next <slug>

It prints the next free serial, the register row to add, the file name and the branch name.

## Licence

Apache-2.0 OR MIT; see `LICENSE-APACHE` and `LICENSE-MIT`.
