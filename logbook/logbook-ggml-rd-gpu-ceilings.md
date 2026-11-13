# ggml-rd GPU ceilings logbook
How fast ggml-rd's matmul is against the hardware's raw arithmetic rate and against ggml-vulkan, on the RTX 4090 and the Steam Frame's Adreno 750. Each entry names the apparatus, the method and the outcome. An entry that turned out to be wrong stays and says why.
## 2026-11-13: the slow band was the GPU clock, and the Frame's ceilings are 0.9 to 4.1 T ops/s
### Retraction
Earlier numbers in this session read ggml-rd as 7x to 72x slower than ggml-vulkan on the `dit` bf16 matmuls. Those ratios came from runs where the 4090 idled near 210 MHz and short probes ended before it ramped. The same shape ran at 17,500 or 1,300 GFLOPS depending on the process. Six separate launches of one shape gave 17,489 to 17,572 GFLOPS, so the kernel and the allocator were not the cause. With the SM clock locked at 2,400 MHz (`nvidia-smi -lgc 2400,2400`, power limit left at 275 W) the sweep is smooth and rises with size. Every ratio below uses locked runs.
### ggml-rd against ggml-vulkan, 4090, locked 2,400 MHz, bf16 x f32, N = 4096
| M x K | ggml-rd us/op | ggml-vulkan (no tensor cores) us/op | ggml-vulkan coopmat us/op |
|---|---|---|---|
| 1536 x 1024 | 1,220 to 1,958 | 483 | 128 |
| 1536 x 1536 | 1,976 | 688 | 161 |
| 4608 x 1536 | 4,903 | 1,536 | 476 |
| 8192 x 1536 | 7,135 to 7,957 | 2,646 | 905 |
ggml-rd runs about 3x behind ggml-vulkan without tensor cores and about 9x behind it with them. Apparatus: `mm_perf` in `guest/ggml_test/probes.cpp` for ggml-rd. For ggml-vulkan, `GGML_VK_PERF_LOGGER=1` on `ggml_graph_oracle`, with `GGML_VK_DISABLE_COOPMAT2` and `GGML_VK_DISABLE_COOPMAT` for the other columns. Cooperative matrix is not enabled by the engine's Vulkan driver, so ggml-rd cannot use it yet.
### Raw arithmetic ceilings
Apparatus: `fmapeak`, one compute shader per format, 128-thread groups x 4,096 groups, eight independent accumulator chains, best of five timed submits, output checked finite and nonzero. Integer formats use the packed 8-bit dot product (`dotPacked4x8AccSat`). The 4-bit and ternary kernels decode from packed words inside the loop with a per-iteration xor so the decode cannot be hoisted. bf16 is stored as raw bits and shifted into f32 before the multiply-add. Ops count 2 per multiply-add.
| Format | Adreno 750 (idle, 37 C) | RTX 4090 (locked 2,400 MHz) |
|---|---|---|
| f32 | 872 G | 64,556 G |
| f16 | 1,739 G | 76,944 G |
| bf16 (emulated) | 518 G | 13,947 G |
| int8 dot | 4,078 G | 25,400 G |
| 4-bit (unpack + dot) | 2,729 G | 19,329 G |
| ternary (unpack + dot) | 1,651 G | 9,693 G |
The 4090's f32 figure is 82% of its 78.6 T theoretical rate, which is the check that the harness measures what it claims. The integer checksums saturate to small constants (16 to 64) and only show the loops ran, not that each op was counted correctly. The 4-bit and ternary rates count decode work as part of the op, so they are rates for the whole path, not for the multiply alone. bf16 first returned NaN because random 16-bit patterns include NaN and Inf. The weights are now forced into [0.25, 0.5) so the recurrence converges.
### Steam Frame matmul against its ceiling
Stock ggml-vulkan returns wrong results on the Adreno 750 (987 of 991 `MUL_MAT` cases pass, and columns from 32 up are wrong). The device reports a 128-wide subgroup and the medium tile assumes a warp tile no larger than the block tile. Turning the medium tile off passes 991 of 991 at 196 GFLOPS. A medium tile of block size 256, 64 x 128, warp tile 64 x 64, 4 x 4 per thread is correct at the full 1536 x 4096 x 1536 shape at 259 GFLOPS (30% of the f32 ceiling, 15% of the f16 ceiling). It has not yet been run through the 991-case suite. Weight format (f32, f16, q8_0, q4_0, q4_K) made no difference to speed, so the small-tile kernel is bound by something other than the weights.
A 19.3 GFLOP matmul at 259 GFLOPS takes 75 ms against a 6.94 ms frame at 144 Hz. The f16 ceiling bounds the Frame GPU at about 1.7 TFLOPS for any kernel, which is at best 6.7x from here and still short of 2.8 TFLOPS needed to fit one such matmul in a frame.
### Not measured
- Whether the `fmapeak` loops are partly optimized away. The timing scales with iteration count, and the checksums do not prove it.
- The 259 GFLOPS tile on ggml's 991-case suite.
- ggml-rd and ggml-vulkan on the same `dit` graph end to end under a locked clock.
- Flash attention and the norms under a locked clock.
- Buffer device address. Both devices report it and the engine's driver enables it. `dit` host recording is 1.5 ms of 88.8 ms, so it cannot help there. `sconv` host recording is 10.5 ms of 20.4 ms. The descriptor share of that is unmeasured.
