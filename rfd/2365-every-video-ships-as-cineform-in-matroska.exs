# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2365, "every video ships as CineForm in Matroska", :discussion do
  flight_level :l2
  scope "the format a video ships in and how it is recorded."

  prose ~S"""
  :: hook
  Every video ships as CineForm with FLAC in Matroska, so it plays on every desk.
  :: intrigue
  A WebM does not play on every desk, and no master is MJPEG.
  :: exit
  Check a new recording against the rule: it is CineForm with FLAC in Matroska with its `.cff`,
  and no WebM.
  :: decision
  Every video ships as CineForm with FLAC in Matroska, with its `.cff`, and no
  WebM is made.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "every video ships as CineForm in Matroska"

  prose ~S"""
  :: details Recording and delivery
  It is recorded as `.cfhd` through &{repo("contract-cineform-movie-writer")} at double
  precision and delivered by &{repo("interactor-av1mkv")}'s `deliver.exs`, which writes
  only those two files. No master is MJPEG. Nothing records
  through the encoder BLOCKLIST.md bars or through the desktop driver's own
  recorder: recordings are CineForm, the live stream is PyroWave, and the headset
  view comes from the compositor mirror.
  :: details The problem
  Videos are uploaded by hand, and a WebM does not play on every desk.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2365", :provides, "cineform-matroska-video"
    relate "rfd-2365", :is_a, "workspace-policy"
  end
end
