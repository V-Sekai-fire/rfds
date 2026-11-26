# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# This file is the plan. `mix rfd.plan` validates its shape and renders nothing
# (operator, 2026-11-26).
defmodule Plan.FourloopsEtnf do
  use RFD.Plan

  plan "FourloopsEtnf" do
    meta(metersPerUnit: 1, upAxis: "Z", defaultPrim: "FourLoopsEtnf")

    string("plan", "fourloops-etnf")
    string_list("relationKindVocabulary", [
      "interned",
      "spine",
      "satellite",
      "measured"
    ])
    string_list("sources", [
      "6-datasource/anny-render-corpus/score_edits.py",
      "6-datasource/anny-render-corpus/render_view.py",
      "6-datasource/anny-render-corpus/render_corpus.py",
      "3-interactor/pose-consensus/python/soma_referee.py",
      "3-interactor/voxhammer-image-mesh-editing/server.py",
      "CLAUDE.md",
      "rfd/1144-image-to-omnigen2/DETAILS.md",
      "rfd/1147-what-editscore-costs-and-returns/DETAILS.md"
    ])
    string("state", "build")
    string_list("stateVocabulary", [
      "exists",
      "build",
      "measure",
      "stub",
      "blocked"
    ])

    scope("FourLoopsEtnf", [
      attr("thesis", "string", "Four pipelines propose something, score it against whatever conditioned it, repair, and go round again. They share one shape, so they share one schema. This layer is every input the four take, written as relations: interned vocabularies, satellites instead of nullable columns, no NULLs, and nothing stored that can be computed. The interesting half is what is deliberately absent, and it is under Absent rather than left out."),
      scope("Interned", [
        attr("sectionNote", "string", "Typed once, referenced by id everywhere else. The repeated-text failure these prevent is two rounds claiming to answer the same question in two slightly different wordings."),
        prim("Loops", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "loop_id"),
          attr("columns", "string[]", [
            "loop_id int8 PK",
            "name string"
          ]),
          attr("rowCount", "int", 4),
          attr("rows", "string[]", [
            "1 keypoints to ANNY",
            "2 image to OmniGen2",
            "3 stylized to OmniGen2",
            "4 latent to Pixal3D"
          ])
        ]),
        prim("Models", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "model_id"),
          attr("columns", "string[]", [
            "model_id int16 PK",
            "repo string",
            "revision string",
            "adapter_id int16"
          ]),
          attr("noAdapterSentinel", "int", -1),
          attr("sentinelNote", "string", "-1 is a value, not a null. A model with no adapter is a fact about the model, and a NULL is a fact about the row not having been filled in.")
        ]),
        prim("Precisions", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "precision_id"),
          attr("columns", "string[]", [
            "precision_id int8 PK",
            "name string"
          ]),
          attr("rowCount", "int", 2),
          attr("rows", "string[]", [
            "bf16",
            "nf4"
          ])
        ]),
        prim("Instructions", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "instruction_id"),
          attr("columns", "string[]", [
            "instruction_id int32 PK",
            "text string"
          ]),
          attr("note", "string", "Typed once. A score carries the id, never the text.")
        ]),
        prim("RepairArms", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("state", "token", "stub", [uniform: true]),
          attr("primaryKey", "string", "arm_id"),
          attr("columns", "string[]", [
            "arm_id int8 PK",
            "name string"
          ]),
          attr("rows", "string[]", [
            "voxhammer",
            "omnigen2"
          ])
        ]),
        prim("Joints", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "joint_id"),
          attr("columns", "string[]", [
            "joint_id int8 PK",
            "name string"
          ]),
          attr("rowCount", "int", 17),
          attr("note", "string", "The detector vocabulary. RF-DETR emits 17.")
        ]),
        prim("AnnyKeypoints", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "anny_point_id"),
          attr("columns", "string[]", [
            "anny_point_id int8 PK",
            "name string"
          ]),
          attr("rowCount", "int", 23),
          attr("note", "string", "The render asset vocabulary. ANNY's coco.pth emits 23, the extra six being foot points.")
        ]),
        prim("JointSubset", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("columns", "string[]", [
            "anny_point_id int8 FK",
            "joint_id int8 FK"
          ]),
          attr("rowCount", "int", 17),
          attr("note", "string", "The subset is data, not a slice written into three different scripts. A shared name would let a 23-row array reach a 17-row consumer and be silently truncated at the tail, which is exactly where the feet are."),
          rel("maps", [
            "/FourLoopsEtnf/Interned/AnnyKeypoints",
            "/FourLoopsEtnf/Interned/Joints"
          ])
        ]),
        prim("Regions", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "region_id"),
          attr("columns", "string[]", [
            "region_id int8 PK",
            "name string"
          ]),
          attr("rowCount", "int", 5)
        ]),
        prim("CameraGenerators", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "generator_id"),
          attr("columns", "string[]", [
            "generator_id int8 PK",
            "name string",
            "view_count int16",
            "derives string"
          ]),
          attr("rowCount", "int", 2),
          attr("rows", "string[]", [
            "1 sphere_hammersley_sequence 0 sphere_hammersley_sequence(view_index, view_count)",
            "2 grid96 96 weft_loop.grid_cameras()[view_index]"
          ]),
          attr("note", "string", "TWO GENERATORS, AND THE SECOND ARRIVED WITHOUT THIS ROW, WHICH IS THE DEFECT THIS FIXES. `view_scores` keyed on `hammersley_index` and `Absent/CameraPose` said a camera is derivable from the sequence. That is true of one generator and false of the other: a grid camera is the pose at that index of an enumerated 4 by 8 by 3 table, and no argument to the sequence produces it. An index without the generator that issued it does not name a camera. view_count is 0 for the sequence because it is a parameter of the sweep rather than of the generator, and 96 for the grid because the grid IS 96.")
        ]),
        prim("Topologies", [
          attr("kind", "token", "interned", [uniform: true]),
          attr("primaryKey", "string", "topology_id"),
          attr("columns", "string[]", [
            "topology_id int8 PK",
            "name string",
            "vertex_count int32"
          ]),
          attr("makehumanVertices", "int", 19158),
          attr("corpusBodyVertices", "int", 13718),
          attr("note", "string", "render_corpus.py requires the 19,158-vertex makehuman topology; the corpus builder's body submodel is 13,718 and the keypoint weights are indexed against the first. One direction fails loudly, the other does not, and a topology_id foreign key on any vertex-indexed relation is what keeps it from being a guess.")
        ])
      ]),
      scope("Spine", [
        attr("sectionNote", "string", "Three relations everything else reaches by foreign key, plus the latent the fourth loop passes."),
        prim("Runs", [
          attr("kind", "token", "spine", [uniform: true]),
          attr("primaryKey", "string", "run_id"),
          attr("columns", "string[]", [
            "run_id int64 PK",
            "loop_id int8 FK",
            "control_artifact_id char64 FK",
            "baseline float32"
          ]),
          attr("note", "string", "baseline is the floor the run is read against. A number without a baseline is not a measurement, so the floor is a column rather than a remark."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Interned/Loops",
            "/FourLoopsEtnf/Spine/Artifacts"
          ])
        ]),
        prim("Rounds", [
          attr("kind", "token", "spine", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8",
            "artifact_id char64 FK",
            "repaired_from int8",
            "seconds float32"
          ]),
          attr("firstRoundParentSentinel", "int", -1),
          attr("sentinelNote", "string", "repaired_from is -1 on a first round. A value like -1 for no parent is a value; a NULL is not."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Spine/Runs",
            "/FourLoopsEtnf/Spine/Artifacts"
          ])
        ]),
        prim("Artifacts", [
          attr("kind", "token", "spine", [uniform: true]),
          attr("primaryKey", "string", "artifact_id"),
          attr("columns", "string[]", [
            "artifact_id char64 PK",
            "media_type string",
            "byte_length int64"
          ]),
          attr("addressing", "string", "sha256 content address"),
          attr("note", "string", "The key is the hash, so the same bytes are the same row however many stages produced them.")
        ]),
        prim("Latents", [
          attr("kind", "token", "spine", [uniform: true]),
          attr("primaryKey", "string", "latent_id"),
          attr("columns", "string[]", [
            "latent_id char64 PK",
            "run_id int64 FK",
            "byte_length int64"
          ]),
          attr("note", "string", "Stages pass latents; VAE decode happens once, at final output. Never encode(decode(z))."),
          rel("foreignKeys", "/FourLoopsEtnf/Spine/Runs")
        ])
      ]),
      scope("Satellites", [
        attr("sectionNote", "string", "Three satellites rather than one wide table. The alternative is one generations relation eight columns wide, five of them null on every row, with no way to tell not applicable from not recorded."),
        prim("Omnigen2Generations", [
          attr("kind", "token", "satellite", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "model_id int16 FK",
            "precision_id int8 FK",
            "steps int16",
            "guidance_image float32",
            "guidance_text float32"
          ]),
          rel("on", "/FourLoopsEtnf/Spine/Rounds"),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Interned/Models",
            "/FourLoopsEtnf/Interned/Precisions"
          ])
        ]),
        prim("CycleganGenerations", [
          attr("kind", "token", "satellite", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "style string",
            "checkpoint_sha256 char64"
          ]),
          rel("on", "/FourLoopsEtnf/Spine/Rounds")
        ]),
        prim("Pixal3dGenerations", [
          attr("kind", "token", "satellite", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "seed int64",
            "view_count int16"
          ]),
          rel("on", "/FourLoopsEtnf/Spine/Rounds")
        ]),
        prim("ArmSelections", [
          attr("kind", "token", "spine", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "arm_id int8 FK",
            "spread float32",
            "mean float32"
          ]),
          attr("note", "string", "The choice is recorded rather than implied by which artifact appeared next. The router is a relation, not a branch."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Spine/Rounds",
            "/FourLoopsEtnf/Interned/RepairArms"
          ])
        ]),
        prim("ArmUnavailable", [
          attr("kind", "token", "satellite", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "reason string"
          ]),
          attr("note", "string", "A tuple exists when the router picked an arm that could not execute. Falling through to the other arm would leave no trace at all, and a geometry failure would be recorded as an appearance failure that was repaired."),
          rel("on", "/FourLoopsEtnf/Satellites/ArmSelections")
        ])
      ]),
      scope("Measured", [
        attr("sectionNote", "string", "Emitted, one measurement per tuple. Nothing here is set by hand, so a run's whole history is a selection rather than a parse of a JSON file."),
        prim("Scores", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "run_id, round_index, instruction_id"),
          attr("columns", "string[]", [
            "run_id int64 FK",
            "round_index int8 FK",
            "instruction_id int32 FK",
            "prompt_following float32",
            "consistency float32",
            "perceptual_quality float32",
            "overall float32"
          ]),
          attr("absence", "string", "A refusal has no tuple."),
          attr("absenceNote", "string", "A null overall enters an average as a zero and turns a refusal into a measurement of failure rather than the absence of a measurement."),
          attr("scaleMin", "float", 0.0),
          attr("scaleMax", "float", 1.0e1),
          attr("overallDerivation", "string", "geometric mean of the three components"),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Spine/Rounds",
            "/FourLoopsEtnf/Interned/Instructions"
          ])
        ]),
        prim("Sweeps", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "sweep_id"),
          attr("columns", "string[]", [
            "sweep_id int64 PK",
            "fit_id int64 FK",
            "generator_id int8 FK",
            "view_count int16"
          ]),
          attr("note", "string", "THE CHAIN THIS COMPLETES IS POSE TO GENERATOR TO VIEWS, AND IT WAS NOT WRITTEN DOWN. A fit produced a pose, something turned that pose into a set of cameras, and the scores hung off artifacts with nothing saying which pose or which generator they came from. Both generators were built and used before this row existed. One sweep is one fit seen through one generator, so the generator and the count sit here once rather than on every scored view."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Measured/Fits",
            "/FourLoopsEtnf/Interned/CameraGenerators"
          ])
        ]),
        prim("ViewScores", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "sweep_id, view_index"),
          attr("columns", "string[]", [
            "sweep_id int64 FK",
            "view_index int16",
            "artifact_id char64 FK",
            "latent_id char64 FK",
            "overall float32"
          ]),
          attr("note", "string", "The sweep, the index, and no camera at all. Yaw, pitch, radius and eye stored beside the index are free to disagree with whatever produced them the first time anybody changes the view count. `hammersley_index` and `view_count` stood here and are gone: a column named after one generator cannot hold the other's index, and the count is a property of the sweep rather than of each scored view."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Measured/Sweeps",
            "/FourLoopsEtnf/Spine/Artifacts",
            "/FourLoopsEtnf/Spine/Latents"
          ])
        ]),
        prim("Observations", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "observation_id"),
          attr("columns", "string[]", [
            "observation_id int64 PK",
            "artifact_id char64 FK"
          ]),
          rel("foreignKeys", "/FourLoopsEtnf/Spine/Artifacts")
        ]),
        prim("ObservedPoints", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "observation_id, joint_id"),
          attr("columns", "string[]", [
            "observation_id int64 FK",
            "joint_id int8 FK",
            "x float32",
            "y float32",
            "confidence float32"
          ]),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Measured/Observations",
            "/FourLoopsEtnf/Interned/Joints"
          ])
        ]),
        prim("Fits", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "fit_id"),
          attr("columns", "string[]", [
            "fit_id int64 PK",
            "observation_id int64 FK",
            "stature_px float32"
          ]),
          rel("foreignKeys", "/FourLoopsEtnf/Measured/Observations")
        ]),
        prim("FitResiduals", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "fit_id, region_id"),
          attr("columns", "string[]", [
            "fit_id int64 FK",
            "region_id int8 FK",
            "residual float32"
          ]),
          attr("absence", "string", "An absent region is NOT_RUN."),
          attr("absenceNote", "string", "A referee region that did not run writes no tuple, and that missing tuple is the verdict. A silent skip reads exactly like a pass only when the skip is unnamed."),
          rel("foreignKeys", [
            "/FourLoopsEtnf/Measured/Fits",
            "/FourLoopsEtnf/Interned/Regions"
          ])
        ]),
        prim("RefereeVerdicts", [
          attr("kind", "token", "measured", [uniform: true]),
          attr("primaryKey", "string", "fit_id"),
          attr("columns", "string[]", [
            "fit_id int64 FK",
            "verdict token"
          ]),
          attr("verdicts", "string[]", [
            "FITS",
            "IMPOSSIBLE",
            "HANDS_UNTRUSTED",
            "NOT_RUN"
          ]),
          rel("foreignKeys", "/FourLoopsEtnf/Measured/Fits")
        ])
      ]),
      scope("Absent", [
        attr("sectionNote", "string", "Columns that are not here, and the derivation each one would have duplicated. Absence is recorded rather than left to be noticed."),
        prim("CameraPose", [
          attr("columns", "string[]", [
            "yaw",
            "pitch",
            "radius",
            "eye"
          ]),
          attr("derivedFrom", "string", "camera_generators[sweeps.generator_id].derives, applied to view_index and sweeps.view_count"),
          attr("wasWrong", "string", "This read `sphere_hammersley_sequence(hammersley_index, view_count)` and named one generator. A grid camera is not reachable from that function at any arguments, so the absence was only justified while one generator existed."),
          rel("wouldHaveSatOn", "/FourLoopsEtnf/Measured/ViewScores")
        ]),
        prim("ScoreDelta", [
          attr("columns", "string[]", [
            "delta"
          ]),
          attr("derivedFrom", "string", "scores.overall minus runs.baseline"),
          rel("wouldHaveSatOn", "/FourLoopsEtnf/Measured/Scores")
        ]),
        prim("ViewStatistics", [
          attr("columns", "string[]", [
            "view_mean",
            "view_variance"
          ]),
          attr("derivedFrom", "string", "aggregate over view_scores for one artifact"),
          rel("wouldHaveSatOn", "/FourLoopsEtnf/Measured/ViewScores")
        ]),
        prim("BestRound", [
          attr("columns", "string[]", [
            "best_round_index"
          ]),
          attr("derivedFrom", "string", "argmax of scores.overall over a run"),
          rel("wouldHaveSatOn", "/FourLoopsEtnf/Spine/Runs")
        ]),
        prim("HouseholdString", [
          attr("columns", "string[]", [
            "household_equivalent"
          ]),
          attr("derivedFrom", "string", "the residual and the anchor table, at print time"),
          attr("note", "string", "Where a script prints measurements repeatedly, it gets a helper rather than a stored column."),
          rel("wouldHaveSatOn", "/FourLoopsEtnf/Measured/FitResiduals")
        ])
      ]),
      scope("Rules", [
        attr("sectionNote", "string", "The four clauses, each recorded against the column it changed here rather than satisfied in the abstract."),
        prim("InternedVocabularies", [
          attr("order", "int", 1),
          attr("bitAt", "string", "instructions is a relation, and a score carries an instruction_id."),
          attr("otherwise", "string", "The instruction text repeated on every score row, which is how two rounds end up claiming to answer the same question in two slightly different wordings."),
          rel("evidence", [
            "/FourLoopsEtnf/Interned/Instructions",
            "/FourLoopsEtnf/Measured/Scores"
          ])
        ]),
        prim("SatellitesNotNullableColumns", [
          attr("order", "int", 2),
          attr("bitAt", "string", "Three generator satellites. OmniGen2 has steps and two guidance scales, CycleGAN has a style and a checkpoint hash, Pixal3D has a seed and a view count."),
          attr("otherwise", "string", "One generations table eight columns wide, five of them null on every row, and no way to tell not applicable from not recorded."),
          rel("evidence", [
            "/FourLoopsEtnf/Satellites/Omnigen2Generations",
            "/FourLoopsEtnf/Satellites/CycleganGenerations",
            "/FourLoopsEtnf/Satellites/Pixal3dGenerations"
          ])
        ]),
        prim("NoNulls", [
          attr("order", "int", 3),
          attr("bitAt", "string", "A refused score writes no scores tuple. A referee region that did not run writes no fit_residuals tuple, which is NOT_RUN. repaired_from is -1 on a first round."),
          attr("otherwise", "string", "A null overall, which enters an average as a zero and turns a refusal into a measurement of failure rather than the absence of a measurement."),
          rel("evidence", [
            "/FourLoopsEtnf/Measured/Scores",
            "/FourLoopsEtnf/Measured/FitResiduals",
            "/FourLoopsEtnf/Spine/Rounds"
          ])
        ]),
        prim("NoDerivableColumns", [
          attr("order", "int", 4),
          attr("bitAt", "string", "view_scores stores hammersley_index and view_count and no camera at all."),
          attr("otherwise", "string", "Yaw, pitch, radius and eye stored beside the index, free to disagree with the sequence that produced them the first time anybody changes the view count."),
          rel("evidence", "/FourLoopsEtnf/Absent/CameraPose")
        ])
      ]),
      scope("LoopInputs", [
        attr("sectionNote", "string", "What each loop adds to the schema. " <>
          "The loops themselves are in fourloops-plan.exs."),
        prim("L1KeypointsToAnny", [
          attr("order", "int", 1),
          attr("state", "token", "build", [uniform: true]),
          rel("adds", [
            "/FourLoopsEtnf/Measured/Observations",
            "/FourLoopsEtnf/Measured/ObservedPoints",
            "/FourLoopsEtnf/Measured/Fits",
            "/FourLoopsEtnf/Measured/FitResiduals",
            "/FourLoopsEtnf/Measured/RefereeVerdicts",
            "/FourLoopsEtnf/Interned/JointSubset"
          ])
        ]),
        prim("L2ImageToOmniGen2", [
          attr("order", "int", 2),
          attr("state", "token", "build", [uniform: true]),
          rel("adds", [
            "/FourLoopsEtnf/Interned/Instructions",
            "/FourLoopsEtnf/Measured/Scores"
          ]),
          rel("satellite", "/FourLoopsEtnf/Satellites/Omnigen2Generations")
        ]),
        prim("L3StylizedToOmniGen2", [
          attr("order", "int", 3),
          attr("state", "token", "build", [uniform: true]),
          attr("scoredAgainst", "string", "the stylized source, not the original"),
          attr("note", "string", "Scoring against the original adds the style transfer and the edit together and reports the sum as one number."),
          rel("adds", [
            "/FourLoopsEtnf/Interned/Instructions",
            "/FourLoopsEtnf/Measured/Scores",
            "/FourLoopsEtnf/Spine/Artifacts"
          ]),
          rel("satellite", "/FourLoopsEtnf/Satellites/CycleganGenerations")
        ]),
        prim("L4LatentToPixal3D", [
          attr("order", "int", 4),
          attr("state", "token", "stub", [uniform: true]),
          attr("gap", "string", "one arm stubbed"),
          rel("adds", [
            "/FourLoopsEtnf/Spine/Latents",
            "/FourLoopsEtnf/Measured/ViewScores",
            "/FourLoopsEtnf/Satellites/ArmSelections"
          ]),
          rel("satellite", "/FourLoopsEtnf/Satellites/Pixal3dGenerations")
        ])
      ]),
      scope("StageWrites", [
        attr("sectionNote", "string", "Every relation is written by one stage. " <>
          "The ten are the ten in fourloops-plan.exs."),
        prim("Keypoints", [
          attr("state", "token", "blocked", [uniform: true]),
          attr("blockedOn", "string[]", [
            "rfdetr"
          ]),
          attr("note", "string", "Nothing checked out here carries rfdetr, so the fit can take 17 points from anywhere but not from a photograph."),
          rel("writes", [
            "/FourLoopsEtnf/Measured/Observations",
            "/FourLoopsEtnf/Measured/ObservedPoints"
          ])
        ]),
        prim("AnnyFit", [
          attr("state", "token", "exists", [uniform: true]),
          attr("note", "string", "The round trip that measures this stage is stated once, in " <>
            "fourloops-plan.exs under Stages/AnnyFit. Restating it here was a second " <>
            "place for one fact to live."),
          rel("writes", "/FourLoopsEtnf/Measured/Fits")
        ]),
        prim("Render", [
          attr("state", "token", "exists", [uniform: true]),
          attr("note", "string", "Plus the sidecar the hash comes from. The sweep is written here rather than by the scorer, because a sweep exists once the frames do: a fit, one generator, one view count. Scoring reads it and does not create it, which is what stops a scored view from being the only record that a sweep happened."),
          rel("writes", [
            "/FourLoopsEtnf/Spine/Artifacts",
            "/FourLoopsEtnf/Measured/Sweeps"
          ])
        ]),
        prim("EditScore", [
          attr("state", "token", "exists", [uniform: true]),
          attr("note", "string", "And nothing on a refusal, which is the point."),
          rel("writes", [
            "/FourLoopsEtnf/Measured/Scores",
            "/FourLoopsEtnf/Measured/ViewScores"
          ])
        ]),
        prim("OmniGen2", [
          attr("state", "token", "exists", [uniform: true]),
          rel("writes", "/FourLoopsEtnf/Satellites/Omnigen2Generations")
        ]),
        prim("CycleGan", [
          attr("state", "token", "exists", [uniform: true]),
          rel("writes", "/FourLoopsEtnf/Satellites/CycleganGenerations")
        ]),
        prim("Pixal3D", [
          attr("state", "token", "exists", [uniform: true]),
          rel("writes", [
            "/FourLoopsEtnf/Spine/Latents",
            "/FourLoopsEtnf/Satellites/Pixal3dGenerations"
          ])
        ]),
        prim("VoxHammer", [
          attr("state", "token", "stub", [uniform: true]),
          attr("wouldWrite", "string", "the repaired latent"),
          attr("planSteps", "int", 7),
          attr("blockedOn", "string[]", [
            "not-implemented",
            "takes-mesh-not-latent"
          ]),
          attr("note", "string", "The server dispatches its seven-step plan and raises NotImplementedError on every step outside stub mode. It also takes a mesh rather than the latent, so the arm passes through /extract first.")
        ]),
        prim("Referee", [
          attr("state", "token", "exists", [uniform: true]),
          rel("writes", [
            "/FourLoopsEtnf/Measured/RefereeVerdicts",
            "/FourLoopsEtnf/Measured/FitResiduals"
          ])
        ]),
        prim("Harness", [
          attr("state", "token", "exists", [uniform: true]),
          attr("note", "string", "The router runs here, so the tuple recording that a picked arm could not execute is written here too."),
          rel("writes", [
            "/FourLoopsEtnf/Spine/Runs",
            "/FourLoopsEtnf/Spine/Rounds",
            "/FourLoopsEtnf/Satellites/ArmSelections",
            "/FourLoopsEtnf/Satellites/ArmUnavailable"
          ])
        ])
      ]),
      scope("Measurements", [
        attr("sectionNote", "string", "What the first real run measured. Everything else was written before a card was switched on; two EditScore calls have now run, and they moved one number and killed one assumption."),
        prim("EditScoreMatchingInstruction", [
          attr("what", "string", "a matching instruction"),
          attr("promptFollowing", "float", 1.0e1),
          attr("consistency", "float", 9.2),
          attr("perceptualQuality", "float", 2.0),
          attr("overall", "float", 4.29),
          rel("measuredBy", "/FourLoopsEtnf/StageWrites/EditScore")
        ]),
        prim("EditScoreNonsenseInstruction", [
          attr("what", "string", "a nonsense instruction, same pair"),
          attr("promptFollowing", "float", 0.0),
          attr("consistency", "float", 1.0e1),
          attr("perceptualQuality", "float", 2.0),
          attr("overall", "float", 0.0),
          attr("role", "string", "negative control"),
          attr("note", "string", "A check that passes on known-broken input is decoration. The nonsense instruction is the input that must score zero."),
          rel("measuredBy", "/FourLoopsEtnf/StageWrites/EditScore")
        ]),
        prim("PeakVram512", [
          attr("measuredGib", "float", 6.7506),
          attr("citedGib", "float", 6.75),
          attr("resolution", "string", "512x512"),
          attr("confirmed", "bool", true),
          attr("note", "string", "The one number here that was confirmed rather than corrected."),
          rel("measuredBy", "/FourLoopsEtnf/StageWrites/EditScore")
        ])
      ]),
      scope("Hazards", [
        prim("RouterScale", [
          attr("state", "token", "build", [uniform: true]),
          attr("defect", "string", "A constant compared against an assumed range."),
          attr("scaleMin", "float", 0.0),
          attr("scaleMax", "float", 1.0e1),
          attr("wrongTwice", "string", "First as a variance against 0.15, which almost never fired; then as a standard deviation on a range ten times larger, where it fires on almost anything."),
          attr("statistic", "token", "spread-over-mean", [uniform: true]),
          attr("calibrated", "bool", false),
          attr("remedy", "string", "The router becomes scale-free, spread over mean, and the threshold is set from measured view scores rather than from a third guess."),
          rel("appliesTo", "/FourLoopsEtnf/Satellites/ArmSelections")
        ]),
        prim("SingleHandPickedView", [
          attr("defect", "string", "A shape wrong along one axis scores well from the view that hides it, so a single hand-picked front view cannot separate that case from a flat appearance failure."),
          attr("remedy", "string", "Views come from sphere_hammersley_sequence."),
          rel("appliesTo", "/FourLoopsEtnf/Measured/ViewScores")
        ]),
        prim("TwoJointCounts", [
          attr("detectorJoints", "int", 17),
          attr("assetPoints", "int", 23),
          attr("defect", "string", "A shared name would let a 23-row array reach a 17-row consumer and be silently truncated at the tail, which is exactly where the feet are."),
          attr("remedy", "string", "Separate vocabularies with a mapping relation between them."),
          rel("appliesTo", "/FourLoopsEtnf/Interned/JointSubset")
        ]),
        prim("TwoTopologies", [
          attr("renderVertices", "int", 19158),
          attr("corpusBodyVertices", "int", 13718),
          attr("defect", "string", "One direction fails loudly. The other does not."),
          attr("remedy", "string", "A topology_id foreign key on any vertex-indexed relation."),
          rel("appliesTo", "/FourLoopsEtnf/Interned/Topologies")
        ]),
        prim("ArmCannotRun", [
          attr("state", "token", "stub", [uniform: true]),
          attr("defect", "string", "Falling through to the other arm would leave no trace at all, and a geometry failure would be recorded as an appearance failure that was repaired."),
          attr("remedy", "string", "arm_unavailable is a satellite on arm_selections: a tuple exists when the router picked an arm that could not execute."),
          rel("appliesTo", "/FourLoopsEtnf/Satellites/ArmUnavailable")
        ])
      ])
    ])

  end
end
