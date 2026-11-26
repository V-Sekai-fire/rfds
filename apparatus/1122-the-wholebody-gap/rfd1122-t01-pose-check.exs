# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# This file is the plan. `mix rfd.plan` validates its shape and renders nothing
# (operator, 2026-11-26).
defmodule Plan.Rfd1122T01PoseCheck do
  use RFD.Plan

  plan "Rfd1122T01PoseCheck" do
    meta(metersPerUnit: 1, upAxis: "Y", defaultPrim: "T01", doc: "T01's run, as data rather than a paragraph: twenty poses projected and looked at.

WHAT THE TASK ASKED. RFD 1122's first task is a gate -- of twenty projected poses, how many
would a character artist draw -- and it is on the critical path because a no here redirects
everything after it. It needs no renderer, no GPU and no install.

WHERE THE CLIPS WERE, having been reported missing once. `extract_poses.py` names three
sources and none is in git or in the organisation; they are on the shared drive
`0360 - Datasets Allowlist`. dataset-100style-godot-clips holds 810 glb under CC-BY-4.0 with a
CITATION.cff, which is the first time `mocapClips = 810` has agreed with a file count rather
than with a sentence.

ESSENTIAL TUPLE NORMAL FORM. Clip and bone names are interned once under /T01/Vocab and the
samples carry indices into them, so a name appears in exactly one place. The measurement prims
are satellites rather than nullable columns on the samples. Nothing derivable is stored: there
is no row count, because it is the length of the index arrays; no clip-name column, because
the index resolves it; and no per-clip mean, because the samples are here.

THE PROJECTION WAS WRONG FIRST, AND THE RETRACTION IS UNDER /T01/Findings. A front view was
drawn before anything measured which axis carries the stride.")

    string_list("apparatus", [
      "6-datasource/anny-render-corpus/extract_poses.py",
      "orthographic projection, PIL, no GPU"
    ])
    string("cameraGenerator", "sphere_hammersley_sequence, ported in render_view.py from TencentARC/Pixal3D @ cdbb2bb")
    string_list("outputs", [
      "twenty-poses-hammersley.png",
      "twenty-poses-side.png",
      "twenty-poses.png"
    ])
    string("ran", "2026-08-23")
    string("rfd", "107a")
    string("sampling", "every 40th clip of 810 sorted by name, middle frame of five")
    string("source", "G:/Shared drives/0360 - Datasets Allowlist/dataset-100style-godot-clips")
    string("sourceLicence", "CC-BY-4.0, CITATION.cff beside the clips")
    string("task", "T01_PoseLibraryPlausibility")

    scope("T01", [
      scope("Vocab", [
        doc("Interned once. A sample refers to a clip and a bone by index, so a rename is
one edit and a typo cannot make two spellings of one thing."),
        scope("Clips", [
          attr("name", "token[]", [
            "Aeroplane_BR",
            "ArmsBySide_BR",
            "BentKnees_BR",
            "Cat_SW",
            "Depressed_SW",
            "DuckFoot_SW",
            "Followed_SW",
            "HighKnees_SR",
            "LeanBack_SR",
            "LimpLeft_ID",
            "Monk_ID",
            "OnPhoneLeft_ID",
            "Penguin_ID",
            "RaisedLeftArm_ID",
            "Rocket_FW",
            "SlideFeet_FW",
            "StartStop_TR1",
            "Sweep_TR1",
            "Tiptoe_TR1",
            "Waving_TR1"
          ], [uniform: true])
        ]),
        scope("Bones", [
          doc("The twenty-one ANNY bones `extract_poses.py`'s BONE_MAP constrains.

CORRECTED: an earlier revision said \"not 104\" here and treated the twenty-one as the layout,
which is the old COCO-shaped answer. They are targets. ANNY's makehuman topology carries 104
bones and every one of these twenty-one names is among them, so a fit that places these leaves
the other eighty-three determined by the rig -- knuckles from the wrist, toes from the foot.
The 104-point sheet waits on that fit being done by ANNY's vertex-fitting procedure rather than
by the centroid alignment first attempted, which reached a mean residual of about a soda can's
width where a same-rig fit has previously reached a thousandth of a penny's thickness."),
          attr("name", "token[]", [
            "root",
            "spine05",
            "spine04",
            "spine03",
            "spine02",
            "neck01",
            "head",
            "clavicle.L",
            "upperarm01.L",
            "lowerarm01.L",
            "wrist.L",
            "clavicle.R",
            "upperarm01.R",
            "lowerarm01.R",
            "wrist.R",
            "upperleg01.L",
            "lowerleg01.L",
            "foot.L",
            "upperleg01.R",
            "lowerleg01.R",
            "foot.R"
          ], [uniform: true])
        ])
      ]),
      scope("Cameras", [
        doc("One viewpoint per pose, from `sphere_hammersley_sequence`, which is the camera
generator TRELLIS.2 and Pixal3D use and which `render_view.py` ports exactly.

WHY NOT AN AXIS. The first two sheets picked a world axis by hand, and the choice decided the
answer: a front view flattened the stride, and the side view fixed that one dataset while
leaving the same objection standing for the next. The sequence is parameterised by an integer,
so view i of twenty is a yaw and a pitch that nobody argued for and anybody can reproduce.

WHAT IT COSTS, MEASURED RATHER THAN GLOSSED. The sequence spans the whole sphere, so view 0 is
pitch -90, straight down. A figure seen from overhead is a legitimate sample of the sphere and
a useless angle for judging whether an artist would draw the pose. That is the generator doing
its job for 3D reconstruction and the wrong job for this gate; picking a band of pitches would
be a decision to record here, not a default to inherit quietly.

Angles are degrees. Parallel to /T01/Vocab/Clips by index, so camera i belongs to clip i."),
        attr("yawDegrees", "float[]", [
          0.0,
          1.8e2,
          9.0e1,
          2.7e2,
          45.0,
          225.0,
          135.0,
          315.0,
          22.5,
          202.5,
          112.5,
          292.5,
          67.5,
          247.5,
          157.5,
          337.5,
          11.25,
          191.25,
          101.25,
          281.25
        ]),
        attr("pitchDegrees", "float[]", [
          -9.0e1,
          -53.13,
          -36.87,
          -23.578,
          -11.537,
          0.0,
          3.823,
          7.662,
          11.537,
          15.466,
          19.471,
          23.578,
          27.818,
          32.231,
          36.87,
          41.81,
          47.167,
          53.13,
          60.074,
          68.961
        ])
      ]),
      scope("Quantities", [
        doc("Counts that a later reader would otherwise re-derive by hand, each one a fact
about the run rather than about the plan. `rowsExtracted` is absent on purpose: it is
clipsSampled x framesPerClip x bones, and a stored product is a second place for one fact."),
        attr("clipsAvailable", "int", 810),
        attr("clipsSampled", "int", 20),
        attr("framesPerClip", "int", 5),
        attr("bonesPerFrame", "int", 21),
        attr("strideFrames", "int", 60),
        attr("meanFootGapAlongStride", "float", 0.356),
        attr("meanFootGapAcrossBody", "float", 0.23)
      ]),
      scope("Findings", [
        prim("F01_AllTwentyAreUprightGait", [
          doc("Every one of the twenty is an upright figure mid-stride. The hundred styles
vary the gait -- Penguin, Monk, Tiptoe, Depressed, DuckFoot -- and not the configuration of the
body: nothing sits, crouches, leans on anything, or reaches. That is what RFD 1122 predicted
when it said the clips are locomotion, and it is now a picture rather than a claim.

The count this task exists to produce -- how many of the twenty a character artist would draw
-- is a human judgement and is deliberately not recorded here. What is recorded is the sheet
they judge and the sampling that produced it."),
          attr("kind", "token", "observation", [uniform: true]),
          attr("measurement", "string", "twenty figures drawn from twenty clips, one frame each")
        ]),
        prim("F02_TheFirstProjectionHidTheStride", [
          doc("RETRACTED: the first contact sheet was a front view, and it flattened the
thing being judged. Measured afterwards, mean foot separation is 0.356 m along Z -- about five stacked
soda cans -- against 0.230 m along X, three and a half of them, so the stride runs on the axis that projection dropped. Tiptoe_TR1 is the
clearest case: 0.032 m across, half a soda can, against 0.631 m along, nearly ten -- a figure standing still in one view
and mid-step in the other.

Both sheets are kept. The front view is the error, and deleting it would leave the next reader
free to repeat it."),
          attr("kind", "token", "retraction", [uniform: true]),
          attr("measurement", "string", "mean foot separation per axis, over twenty middle frames")
        ])
      ]),
      scope("Samples", [
        doc("One tuple per joint observation: which clip, which frame, which bone, and where
it was. Parallel arrays rather than a prim per row, because 2,100 prims would carry the same
data and cost a reader the ability to see it at once.

The first twenty rows are written here as the shape of the relation and its check; the full
extraction lives beside the apparatus as parquet, which is what the corpus rules ask for
tabular data. This layer is the record of the run, not a second copy of the corpus."),
        attr("clipIndex", "int[]", [
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ]),
        attr("frameIndex", "int[]", [
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2
        ]),
        attr("boneIndex", "int[]", [
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20
        ]),
        attr("position", "float3[]", [
          [-0.02800000086426735, 0.9470000267028809, 1.121000051498413],
          [-0.029999999329447746, 1.0240000486373901, 1.1180000305175781],
          [-0.03200000151991844, 1.1009999513626099, 1.1150000095367432],
          [-0.03400000184774399, 1.1779999732971191, 1.1119999885559082],
          [-0.035999998450279236, 1.2549999952316284, 1.1089999675750732],
          [-0.03799999877810478, 1.4359999895095825, 1.1039999723434448],
          [-0.03999999910593033, 1.5880000591278076, 1.3680000305175781],
          [-0.14000000059604645, 1.3899999856948853, 1.100000023841858],
          [-0.23000000417232513, 1.3600000143051147, 1.0980000495910645],
          [-0.28999999165534973, 1.1399999856948853, 1.059999942779541],
          [-0.3529999852180481, 0.9150000214576721, 1.0369999408721924],
          [0.05999999865889549, 1.3899999856948853, 1.100000023841858],
          [0.15000000596046448, 1.3600000143051147, 1.0980000495910645],
          [0.20999999344348907, 1.1399999856948853, 1.059999942779541],
          [0.27300000190734863, 0.9150000214576721, 1.0369999408721924],
          [-0.10999999940395355, 0.9300000071525574, 1.1150000095367432],
          [-0.11999999731779099, 0.5199999809265137, 1.090000033378601],
          [-0.34200000762939453, 0.14800000190734863, 1.0399999618530273],
          [0.029999999329447746, 0.9300000071525574, 1.1150000095367432],
          [0.03999999910593033, 0.5199999809265137, 1.090000033378601],
          [0.10000000149011612, 0.14800000190734863, 1.2999999523162842]
        ])
      ])
    ])

  end
end
