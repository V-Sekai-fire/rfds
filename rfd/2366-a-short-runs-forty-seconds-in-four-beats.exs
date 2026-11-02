# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2366, "a short runs forty seconds in four beats", :discussion do
  flight_level :l2
  scope "the length and the four-beat script of a short."

  prose ~S"""
  :: hook
  A short runs exactly 40 seconds in four beats: hook, intrigue, delivery and exit.
  :: intrigue
  A hook that needs the sound fails the viewer, and a short that is about us gives them nothing
  to do.
  :: exit
  Script the next short in the four beats before recording it, then count its frames against the
  length rule.
  :: decision
  A short runs exactly 40 seconds and is scripted before recording in four beats:
  hook, intrigue, delivery and exit (HIDE).
  The length is 40 times the frame rate in
  Movie Maker frames, counted from the first rendered frame. The engine renders
  the captions, and no external tool re-encodes the file.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a short runs forty seconds in four beats"

  prose ~S"""
  :: details The four beats
  The hook fills the first 3 s as on-screen text that works with the sound off and
  promises without answering. One line of intrigue makes the viewer feel the
  problem. The delivery is the one thing they came for. The exit gives them
  something to do. It is never about us.

  :: details Marketing media
  Marketing media and samples are marked with `https://github.com/v-sekai-fire`:
  it is the `url` in each `.cff`, the web statement in its XMP and the line on
  its exit card, and each follows the four-beat script in this RFD.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2366", :provides, "forty-second-hide-short"
  end
end
