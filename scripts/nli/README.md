# Proposing token edges from RFD prose (parked)

`rfd_ast.py` parses each sentence of the rendered `rfd/<serial>-slug/README.md` and `DETAILS.md` into a dependency
tree and verb frames with spaCy (`en_core_web_trf`), and scores claims such as "RFD A depends on RFD B" with an NLI model.
`rfd_caps.py` matches each paragraph to the capability tokens other RFDs provide by shared lemmas, then scores
"RFD X uses <token meaning>". Both write proposals for a human to review and never edit an RFD.

Environment (outside this repository): spaCy 3.8.7, `en_core_web_trf` 3.8.0 and
`MoritzLaurer/DeBERTa-v3-large-mnli-fever-anli-ling-wanli` (MIT). On 400 ANLI round 3 and 400 MNLI-m items it scored
0.63 and 0.897, against 0.48 and 0.935 for `sileod/deberta-v3-large-tasksource-nli`, 0.378 and 0.917 for
`cross-encoder/nli-deberta-v3-large`, and 0.30 and 0.89 for `facebook/bart-large-mnli`.

Findings on the 33 RFDs in the beta's cone: lemma overlap finds 36 of the 48 declared edges (75% recall) at about 18%
precision. The NLI score separates real edges from false ones only weakly (AUC 0.63, against 0.62 for overlap alone
and 0.69 for both), because RFD prose rarely states a dependency in one entailable sentence. Use the output to find
candidates, then read the RFD. Most new candidates are sibling slices mentioning each other, which RFDs 2436 to 2440
make independent on purpose.
