# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2446, "A2A hardening leaves five verification gaps open", :discussion do
  feature "a record of five checks a security pass never ran, so the pass is not called finished."

  scope "the MCP-to-A2A bridge server, and the Godot editor's MCP listener and its new A2A route."

  prose ~S"""
  :: hook
  Can a security pass call itself finished while five of its own claims stay unchecked?
  :: intrigue
  Eight pull requests closed a prompt-injection finding, moved a bridge server and an editor
  listener to the Agent2Agent protocol's 1.0 wire format, and closed a browser-origin hole in
  both of the listener's protocols. Every pull request carries tests that passed on one machine.
  :: exit
  Read the five gaps below before picking any of this work back up, and close one gap at a time.
  :: decision
  Five verification gaps stay open, and work on them does not resume until this record changes.
  - No diff against the operator's own A2A listener script, which was never recovered.
  - No run on the Windows desk or inside the resident editor session the operator described.
  - No run against the Agent2Agent protocol's conformance suite, for either system.
  - No real browser has exercised the new Origin refusal, only a forged command-line header.
  - Both systems' test commands still force a hidden display, against the windowed-test rule.
  :: related
  - No earlier RFD names either system; this is their first register entry.
  """

  details_title "A2A hardening leaves five verification gaps open"

  prose ~S"""
  :: details The five gaps, and what closes each one
  - Godot parity. The operator ran a resident editor with an uncommitted listener script added
    to its MCP addon, serving A2A at one address with a card and two commands. That script was
    never pushed anywhere and could not be found on any branch, so the listener that shipped is
    a clean-room build from the protocol specification, not a check against the original. Closes
    when that original script is pushed to a branch and the two are diffed line by line.
  - The Windows desk. Every check so far ran on a Mac, in a real window, never headless. Closes
    when the same checks run once on the desk, inside the resident editor session.
  - A conformance suite. Both systems were checked against the official client library and
    against each other, never against the protocol's own conformance suite. Closes when that
    suite is identified by name and run once against each system, with its own report kept.
  - A real browser. The Origin refusal was proven with a command-line client sending a forged
    header, never with a browser tab. Closes when an actual browser page, opened by a person,
    is shown the refusal.
  - The hidden-display test commands. Both systems' committed test commands still pass a flag
    that hides the window, against the rule that a Godot test runs where it can be watched.
    Every check in this pass ran windowed by hand instead, by overriding the command each time.
    Closes when the committed command itself drops the flag and still passes.
  """
end
