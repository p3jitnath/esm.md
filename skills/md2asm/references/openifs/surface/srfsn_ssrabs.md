# Snow Shortwave Transport Contract

This revision-1 contract freezes the complete original `srfsn_ssrabs_mod::srfsn_ssrabs` body for [Sun's radiation through snow](../../../../../formulations/openifs/surface/snow_shortwave_transport.md). The source and its snow and soil consumer retain their original mathematics.

## Ordered Calculations

Process tile 5, then tile 7, with columns and layers in increasing order. The active layer index starts at one before both tile loops. Each snow column replaces it with its last layer whose mass exceeds $`10\,2^{-52}`$. A column with no such layer keeps the preceding index, as in the original source.

For every active layer, divide mass by density and apply the depth limits. Call the qualified opaque POWER boundary for density to the power four, multiply its result by `SSAG3`, add `SSAG1` and apply the grain cap. Call the same boundary with exponent one half, multiply density by `SSASNEXTCNST`, divide by the grain result and apply the extinction limits. Each solver product, sum and division rounds separately.

For the top layer, call the accepted scalar EXP on the negative extinction-depth product and limit its result below by $`10\,2^{-52}`$. Store radiation times this transmission. Compute the remaining radiation with the source's separate subtraction, product and subtraction. For deeper layers, compute transmission, store the absorbed fraction times the remaining radiation, then subtract that absorption. Store the final remainder in the channel below the active snow. Multiply each channel by the tile fraction and add it to the incoming output. A no-snow column clears every channel on both tile passes.

POWER is one original elementary-function boundary, described in [its separate contract](../power_math.md). It reproduces 20 internally single-rounded original steps with integers and uses no fused floating-point instruction. It does not change the separately rounded solver operations. EXP reuses the accepted [pressure mathematics](../pressure_math.md). Require FPCR zero, gradual underflow, preserved signed zeros and no solver contraction, reassociation, reduced precision or approximate division.

## ABI and Bounds

The Arm application binary interface, or ABI, passes twelve addresses. Registers `x0` through `x7` hold `KIDIA`, `KFDIA`, `KLON`, `KLEVSN`, `LLNOSNOW`, `PFRTI`, `PSSRFLTI` and `PSSNM1M`. Caller stack offsets 0, 8, 16 and 24 hold `PRSNM1M`, `YDSOIL`, the unused `YDCST` and `PSNOTRS`. Integers and logical values occupy four bytes. Arrays use GNU descriptors with positive row and column strides, eight-byte FP64 elements and four-byte logical elements. The first dummy element starts at `descriptor.data`, independent of the caller's lower bound.

Support 1 to 4096 columns and 1 to 64 layers, selected columns within the owner and an empty selected range. Tile arrays have at least seven columns, mass and density arrays have at least the declared layer count, and the output has exactly one more layer than the snow. Column strides keep array columns disjoint. Inputs may share storage, while the complete writable output owner is separate from inputs and metadata. Preserve every inactive element and every padding byte.

Consumed density lies from 1 to 1000 kilograms per cubic metre, snow mass is finite and nonnegative, tile fractions are finite in [0,1] with their sum at most one, and radiation is finite with magnitude at most one million watts per square metre. Active output channels start at zero. The soil object has 2416 bytes and the reused constant object has 128 bytes. Frozen soil offsets are recorded by the focused metadata probe, and unused soil fields remain unread.

The assembly preserves `x19` through `x29` and the return address, leaves `x18` and `d8` through `d15` unchanged, and restores its aligned 2048-byte stack frame. That frame stores at most 64 depth values, 64 extinction values and 65 transport values. No allocation or high-level numerical solver is used.

## Acceptance

The unchanged original passes 58 protected cases, 146896 complete output bytes and 25660 independent physical relations. The independent consumer identity checks that the sum of deeper absorption and bottom soil transmission equals transmission leaving the top layer within the frozen rounding budget. This also checks the complete incoming-radiation heat balance. The first returned channel is transmission leaving the top layer, rather than absorption in that layer.

Reuse those original physical checks and the immutable output corpus. New native acceptance requires the same complete owner bytes, independent layer and coupled-energy checks, preserved input bytes, prefix and suffix bounds, register obligations and unchanged FPCR. The shared POWER proof also passes all 4122 retained snow power operands and 8244 grain and extinction stage values with zero differences. The direct body and paired relay each pass the complete 58-case corpus with zero differing bytes. Six immediate-interface cases preserve the required registers and 4288 output bytes. Five invalid shape or stride cases reject before changing 600 shared output bytes. The paired relay additionally checks the coupled heat balance on every actual call and returns the assembly bytes. Whole-forecast acceptance and comparative performance are separate later gates.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_ssrabs_mod::srfsn_ssrabs | 2,150 | 2,476,800 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
