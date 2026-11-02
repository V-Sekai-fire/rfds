# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2376, "nothing runs in the headset unless the operator asks", :discussion do
  flight_level :l2
  scope "when anything may run, restart or capture in the headset the operator wears."

  prose ~S"""
  :: hook
  Nothing runs, restarts or captures in the headset unless the operator asks for that run.
  :: intrigue
  Nothing may capture the headset view while the operator is in a social session. X11 capture
  cannot see it, so a capture attempt there shows nothing.
  :: exit
  Before a run, a runtime restart or a capture in the headset, check that the operator asked for
  that run, and run tests and gates on the Windows desk or as renders on the Mac instead.
  :: decision
  - Tests and gates run on the Windows desk or as renders on the Mac, not in the headset the
    operator wears.
  - A run, a runtime restart or a capture in the headset happens only when the operator asks for
    that run, and nothing captures the headset view while the operator is in a social session.
  - The headset view comes from the compositor mirror (`/dev/video99`) with screen sharing on.
    X11 capture cannot see it.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "nothing runs in the headset unless the operator asks"

  prose ~S"""
  :: details Asleep
  Asleep, the headset drops off the LAN entirely, answering neither mDNS nor
  ARP, so a name that does not resolve means it is asleep, not broken.

  :: details Whose it is in the queue and the key
  The headset is the Mac desk's in the queue, so another desk coordinates with
  the Mac before touching it. A key appended to its `authorized_keys` starts on a
  new line with carriage returns stripped, because the file may end without a
  newline and a `.pub` written on Windows ends its lines with CRLF.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2376", :provides, "headset-runs-operator-gated"
  end
end
