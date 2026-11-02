# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2169, "Abandon the strangler-fig studio core; the ladder is MaskScore", :published do
  feature "documentation retraction"
  scope "`rfd/1019-strangler-fig-studio-core`"

  prose ~S"""
  :: hook
  The strangler-fig studio plan is retired; MaskScore carries the ladder instead.
  :: intrigue
  RFD66606-1019 proposed growing an Elixir application beside the browser client and taking
  studio responsibilities from it one at a time. Every premise was walked back.
  :: exit
  Read RFD66606-2164 next for the Rung 1 corpus that is the current spine.
  :: decision
  Abandon RFD66606-1019 (strangler-fig studio core); the workspace laddered up via MaskScore
  (edit-reward corpus) with Gemma-4-12B as the reasoning core instead.
  :: section What replaces it
  Gemma-4-12B (QAT Q4_0, Apache-2.0, local) is the reasoning core. Gemma runs the vision and IPA
  panel today, produces the text-stub instructions, and RFD66606-2167 (voice-reward distillation)
  targets it as the fine-tune base. MaskScore constructs edit triples, RFD66606-1157 (EditScore
  reward model) scores them. The Rung 1 corpus (RFD66606-2164, 5 stubs shipped) and its schema
  module (RFD66606-2165.1) are the current spine. RFD66606-1173 (edit-reward corpus)'s Qwen3-VL
  wording is drift and needs its own update.
  :: related
  Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.1019
  Superseded by: urn:oid:1.3.6.1.4.1.66606.1.1.{1173,1157}
  """

  details_title "Abandon the strangler-fig studio core; the ladder is MaskScore"

  prose ~S"""
  :: details What the plan assumed
  The plan assumed a DGX plus CUDA backend, the JS catalog
  as authoritative first, and CockroachDB persistence.
  :: details Carried forward and abandoned
  Carried forward: facts-not-rows became ETNF (Essential Tuple Normal Form: no nulls,
  satellites); hexagonal ports became the 1-7 directory numbering.

  Abandoned: the Elixir studio core beside the JS client (no parity check ran); DGX plus CUDA plus
  Nx/EXLA (local desktop GPU is the only compute now, RunPod and Vast.ai blocklisted); JS catalog
  authoritative (per-model RFD66606-1038-1052 and RFD66606-1102 ship it differently); CockroachDB
  persistence (RFD66606-1067 walked it back; replaced with sqlite-fdb plus S3-compatible streaming
  backup RFD66606-2143, plus OpenBao RFD66606-2140).
  """

  rebac do
    verbs_from 2351
    relate "rfd-2169", :provides, "maskscore-ladder-decided"
  end
end
