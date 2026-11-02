# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2401, "the talk step carries voice as datagrams", :discussion do
  flight_level :l1
  scope "the talk step: voice encoded with Opus and sent as datagrams."

  prose ~S"""
  :: hook
  Players hear each other at their avatars' heads through voice sent as datagrams.
  :: intrigue
  When one packet is dropped and the expectation is kept, the result falls below the threshold.
  :: exit
  Run `tests/gate_voice_loopback.gd` and check that speech round-trips between the two clients.
  :: decision
  &{repo("interactor-voice")}: Opus 1.6.1 without `dnn/`, `celt/x86`, `celt/arm`,
  rnnoise, AEC3 or libsamplerate, with its own `opus_guest_config.h`;
  `voice_encode` on 960-sample frames at 48 kHz, `voice_push` and
  `voice_pull` over a jitter buffer with packet-loss concealment, lifted
  from `speech.cpp` onto std containers. The host sets
  `audio/driver/mix_rate=48000`, captures through `AudioEffectCapture`
  on a Mic bus, sends packets as `CH_VOICE` datagrams through the local
  `zone.elf`, and plays each remote player at their avatar's head bone
  through an `AudioStreamPlayer3D` fed by `voice_pull`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the talk step carries voice as datagrams"

  prose ~S"""
  :: details Check and control
  Check: `tests/gate_voice_loopback.gd` round-trips speech between the
  two clients; the Lean property decodes a frame and holds 15 dB SNR
  against its input. Control: one packet dropped with the expectation
  kept falls below the threshold.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2401", :provides, "voice-datagram-transport"
    relate "rfd-2401", :provides, "spatial-voice-at-head"
  end
end
