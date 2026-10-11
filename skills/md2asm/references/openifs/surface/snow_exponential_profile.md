# Snow Exponential Profile Contract

Revision 1 implements the complete SURFWS_FGPROF entry from the [physics note](../../../../../formulations/openifs/surface/snow_exponential_profile.md). It produces the temperature and density profiles, applies every ordered safety and middle-layer write, sets glacier boundaries and fills inactive layers.

## Ordered Profile

Process a column only when its no-snow mask is false, its active-layer count exceeds one and total depth reaches the warm-start threshold. Read the selected temperature and density decay coefficients from the supplied 27-column banks. Define epsilon as 100000 times FP64 machine epsilon. For a difference d, its regularised denominator is SIGN(MAX(epsilon, ABS(d)), d), retaining the sign bit even at negative zero.

For shallow snow below 0.20 metres, the temperature anchor distance is total depth. For deeper snow whose top temperature reaches the supplied middle temperature, use active depth and cap the anchor temperature at melting. Otherwise use the rounded sum of active and soil-adjustment depths. Subtract one from the epsilon-clipped exponential at the anchor distance, regularise the result, divide the bottom-minus-top temperature difference by it, then subtract that rounded amplitude from the anchor temperature.

Density uses the difference between the unmodified middle and top depth exponentials. Divide mean-minus-top density by its regularised difference, then subtract amplitude times the unmodified top exponential from top density. Keep these exponentials distinct from the epsilon-clipped layer exponentials.

At each active layer, form the temperature exponential, clip it below epsilon, multiply by amplitude, add the anchor and cap at melting. In warm-start modes two and three, write the supplied middle temperature to the next-to-bottom active layer for depths at least 0.50 metres, otherwise to the supplied middle layer. This write repeats at each iteration. Replace the current temperature by the middle temperature if it is below 100 kelvin.

Then form the clipped density exponential, multiply and add its anchor, write mean density to the supplied middle layer and clamp the current layer first to the minimum and then the maximum density. A later iteration can overwrite an earlier middle-layer clamp. Glacier columns set the final two active densities to 300 during every iteration, then set the bottom temperature to capped soil temperature and all allocated densities to 300. Finally, inactive temperatures repeat the final active temperature and inactive densities become 100, including the glacier branch.

Use the accepted unchanged EXP route from the local strict-math qualification. Preserve each unary sign, product, difference, division, sum and write dependency. Every exponential argument is formed in this body. The original repeated EXP evaluations with identical operands have identical immutable results; the assembly may keep that rounded value in a register.

## Interface And Bounds

The Arm application binary interface passes 31 addresses. In order they are first and last columns, total columns, allocated layers, active layers, middle layers, warm-start and glacier thresholds, no-snow mask, mean snow temperature, snow mass, mean density, soil temperature, total depth, active depth, temperature depths, density depths, soil-adjustment depth, bottom and top temperature, middle temperature, top and maximum density, temperature coefficients and selected index, density coefficients and selected index, two profile outputs, constants and soil settings.

Real storage uses eight-byte aligned GNU FP64 vector or matrix descriptors. Integer and logical vectors have four-byte aligned elements. Descriptor bases address the first logical element, a zero first stride means one and signed independent strides are supported. The two output matrices are independent and preserve inactive columns, skipped columns, padding and descriptor bytes. No driver supplies a profile or correction stage.

Support 1 to 4096 columns and 2 to 512 allocated layers. Active layers are from zero through the allocated count. A processed column has a valid middle layer within its active count and both selected indices from one through 27. The consumed inputs and ordered intermediates are finite, consumed depths and masses are nonnegative, density limits are positive and ordered, and temperatures are positive. The shallow branch consumes total depth and leaves active and soil-adjustment depth bytes unused. The deep warm branch consumes active depth and leaves soil-adjustment depth bytes unused. The deep cold branch consumes both depths. Initialisation can preserve an earlier active-depth value for shallow snow, so admission checks only the depth fields selected by the branch. Unused mean-snow-temperature input bytes are not consumed. Module sizes and the accepted RTT and RHOMINSND offsets are reused; only the newly consumed NSNMLWS field is probed at byte 488 of TSOIL. TCST is 128 bytes with RTT at byte zero. TSOIL is 2416 bytes with RHOMINSND at byte 1832.

Preserve the floating-point control register, FP64 nearest-even rounding, gradual underflow and the Arm saved registers. Forbid fused operations, reassociation, approximation and fast math. Build the complete direct AArch64 body with an assembler and linker. The fixed 640-byte stack frame saves x19 through x29, the return address and d8 through d15.

## Acceptance

First check the original entry against independent long-double exponential curves and every final override, skipped column and continuation value. Include rounded exponential error and cancellation in the frozen profile budget, since a small regularised denominator can amplify exponential rounding. The bound is 32768 times FP64 epsilon times the profile coefficients and relation scale, plus the propagated two-ulp exponential error divided by the regularised denominator. This checks the stated discrete profile without claiming uniform relative accuracy near a zero denominator.

Then require zero differing complete returned owner bytes, protected input and output bounds, preserved descriptor bytes, the immediate 31-address ABI and FPCR. Cover every depth and mode branch, glacier and seasonal profiles, underflow, zero and small decay rates, signed strides, empty intervals, partial columns and full active tails. A paired adapter runs the complete assembly and keeps the unchanged original only as its same-input shadow control. Actual forecast acceptance and timing remain separate gates.

The original physical check passed before emission. The full native check passed 1,730 protected calls, 212,669,808 complete returned bytes and 10,079,604 independent profile and override relations with zero differences. Its immediate ABI and FPCR check passed. Removing two uncalled descriptor helpers changes no arithmetic; sixty-six focused calls validate the final object over 60,192 bytes and 2,604 relations. Sixty-six paired calls pass the same 60,192 bytes with zero differences. Detailed records remain local, and no actual forecast acceptance or timing is claimed here.

The unchanged body also passes the captured shallow input that exposed an admission error in the older paired guard. Four focused original/native/paired calls pass 7,680 complete returned bytes, 256 independent original/native relations and 128 paired relations. Unused shallow depths and deep warm adjustment depths can contain a quiet NaN, which is a stored value that represents no real number, without changing the returned bytes. Four consumed negative or nonfinite depth checks reject before writes and preserve all 21,184 public bytes per case. One further paired call preserves the captured incoming floating-point status over 1,920 returned bytes and 32 live relations. Fresh status, immediate ABI, read-only inputs and loading from another working directory pass. The physical checks and their limits remain unchanged; the prior complete proofs are reused.

With profiling enabled, the unchanged DR_HOOK timer can set the inexact floating-point status bit even when no profile column is processed. This bit shows that an arithmetic result required rounding. With the model process initialized, the source status is 16 and native status is zero over unchanged owners; with profiling disabled both are zero. Two focused profiled paired calls pass 3,840 complete bytes and 32 independent relations. Whole-routine status is recorded for diagnosis while profiling is enabled. The relay preserves every incoming, source and native sticky status bit; a sticky bit remains set until software clears it. The unprofiled status comparison and the separate qualified EXP boundary checks remain unchanged. Exact bytes, physical limits, immediate ABI and FPCR still form the primary routine gate.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfws_fgprof_mod::surfws_fgprof | 86 | 165,120 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
