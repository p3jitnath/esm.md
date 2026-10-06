# OpenIFS GPPWC contract

Contract revision 1.1 freezes the complete GPPWC numerical body in local OpenIFS 48.1.1. Its physical input is [column water](../../../../../formulations/openifs/dynamics/column_water.md), revision 1.0.

## Method and arithmetic

Treat the supplied water fraction as constant within each pressure layer. Number layer boundaries from 0 at the top to KFLEV at the bottom. FP64 is the 64-bit floating-point format. RN64 rounds to the nearest FP64 value, with ties rounded to an even final bit.

First calculate the correctly rounded inverse of upstream RG. Set the top water mass to positive zero. At each active column, visit layers in increasing order and preserve these rounding points.

```math
r_g=\operatorname{RN}_{64}(1/g),\qquad W_0=+0,
```

```math
d_k=\operatorname{RN}_{64}(p_k-p_{k-1}),\qquad
a_k=\operatorname{RN}_{64}(q_kd_k),
```

```math
b_k=\operatorname{RN}_{64}(a_kr_g),\qquad
W_k=\operatorname{RN}_{64}(W_{k-1}+b_k).
```

For water fractions, the output has units kg/m². Pressure is in pascals, gravity in m/s² and fractions in kg/kg. OpenIFS also calls this same integral with signed correction fields and with a water fraction multiplied by wind, as shown in JMGFIXER and CPEDIA. For these calls, PQ is a general finite layer quantity and the output has its unit multiplied by kg/m². The ordered calculation remains the same. Keep separate multiplication and addition, signed zeros and subnormal values. Forbid fusion, reassociation, fast-math and approximate division. A direct division of the layer contribution by gravity would change the frozen arithmetic.

Columns are independent, while each layer uses the previous rounded water mass. Scalar or two-lane NEON execution may change the column traversal while keeping this dependency. Every vector remainder must stay inside its input and output buffers.

## Inputs and interface

KPROMA is positive. Require 1 <= KSTART <= KPROMA and KSTART - 1 <= KPROF <= KPROMA. KFLEV is nonnegative. An empty active interval changes no output. With zero layers and an active interval, the top row still becomes positive zero.

PQ has shape (KPROMA, KFLEV). PRXP and PWCH have shape (KPROMA, 0:KFLEV). Arrays use Fortran column order and 8-byte-aligned FP64 entries. Their byte counts and addresses fit signed 64-bit arithmetic. Inputs are read-only, outputs do not overlap inputs, and inactive columns retain their incoming bits. Pressure is finite, nonnegative and nondecreasing downwards. Layer quantities are finite and may be signed. A physical water fraction lies between zero and one, while a signed correction or transport component follows its caller's units and bounds. Gravity is positive and every required intermediate is finite.

Export gppwc_ with the GNU Fortran interface. All seven arguments arrive as addresses in x0 to x6, in the order KPROMA, KSTART, KPROF, KFLEV, PWCH, PQ and PRXP. Integers are signed 32-bit values. Read the exact RG through __yomcst_MOD_rg. Preserve the Arm ABI's x19 to x29, link register, stack alignment and required portions of v8 to v15. Do not use x18. The complete update belongs in the assembly routine, with profiling hooks excluded.

## Verification and output

Compare all output and input bytes against the unchanged strict-source Fortran routine. Include zero layers, empty and partial intervals, odd widths, a single final column, dry air, constant and varying fractions, zero pressure thickness and signed zero. A protected page after the final entry must reject any extra vector-lane access.

Independently check constant-fraction columns against W = q(p - p_t)/g, dry columns against positive zero and layer increments against their supplied quantity signs and pressure bounds. Include negative constant corrections and mixed signed layers, while retaining the physical water-fraction cases. Require zero differing bytes, including guards and inactive cells. Report the first case, boundary, column and bit patterns on a mismatch. Verify FPCR before execution.

Canonical small-check output concatenates each case's complete PWCH buffer, including inactive entries and two guard entries, as little-endian FP64. The protected-page case appends its two boundary values. Keep clocks and pointer addresses outside these bytes.

## Forecast capture

The forecast driver copies the incoming output, calls the original strict-source Fortran routine on that copy, and calls the complete assembly routine on the forecast output. It compares every boundary byte, checks unchanged inputs and verifies pressure order, finite layer quantities, top water mass and each layer contribution's sign.

Each little-endian record starts with an 8-byte call number, 4-byte forecast step, four 4-byte dimensions in interface order, a 4-byte schema value of 1 and FP64 gravity. Output records append the complete PWCH array, including inactive columns. Input records append incoming PWCH, PQ and PRXP in that order, preserving untouched bytes for replay. The header occupies 40 bytes. Timing, profiling and pointer addresses are excluded.

## Provenance

Emit assembly directly from this contract, and build it with an assembler and linker. Inspect compiler output only for arithmetic and interface verification. Archive source, contract, generated assembly, verifier and trajectory hashes. Accept performance and optimisation lessons only after repeated measurements on the own quiet exclusive node.
