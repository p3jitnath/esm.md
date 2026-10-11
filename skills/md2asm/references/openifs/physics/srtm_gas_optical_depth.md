# Shortwave Gas Optical Depth Contract

Revision 1 implements the complete SRTM_GAS_OPTICAL_DEPTH caller from OpenIFS 48.1.1. Its [physics note](../../../../../formulations/openifs/physics/shortwave_gas_optical_depth.md), revision 1.0, supplies SGO-1 and SGO-2. The caller must directly invoke all fourteen complete assembly band calculations and perform its own total-depth and scattering-fraction stages. A local driver may prepare inputs or compare outputs, but it must supply no omitted numerical stage.

## Numerical Method And Ordered Arithmetic

The accepted band contracts define gas absorption, molecular scattering and incoming solar flux. The bands run in order 16 through 29. Their spectral point counts are 6, 12, 8, 8, 10, 10, 2, 10, 8, 6, 6, 8, 6 and 12. Concatenate their points in that order to obtain 112 points.

Let RN mean one FP64 operation with nearest rounding and an even result at an exact halfway point. FP64 stores each real number in 64 bits. For each daylight column, copy the band's solar flux without arithmetic. At every layer and point, compute RN(scattering + absorption), store that total, then compute RN(scattering / stored total). Preserve this operand order and the division dependency. Signed zeros and gradual underflow remain active.

Require the Arm floating-point control register, FPCR, to equal zero. Use no fused multiply-add, contraction, reassociation, approximate division or reduced precision. Band table setup and every unchanged child proof are reused from their accepted records. Their complete assembly bodies form the numerical call closure, which means the full set of numerical functions reached by this caller.

## Twenty-Eight-Address ABI

The application binary interface, or ABI, specifies how a routine receives its inputs and preserves the caller's registers. x0 through x7 contain the first eight addresses below. Incoming stack bytes 0 through 152 hold the other twenty addresses in the listed order. The default native entry is md2asm_srtm_gas_optical_depth, with no scalar return value. The genuine original entry is srtm_gas_optical_depth_ at offset 0x8725a0 in the retained strict library.

Define B = KFDIA − KIDIA + 1 and H = KLEV. Every matrix is column-first contiguous. The supplied pointer already addresses its first selected column because each dummy array has explicit KIDIA through KFDIA bounds. KIDIA is an array label, not an offset to add to that pointer.

| Position | Argument | Contents and shape |
| ---: | --- | --- |
| 1 | KIDIA | One INTEGER4 value |
| 2 | KFDIA | One INTEGER4 value |
| 3 | KLEV | One INTEGER4 value |
| 4 | ONEMINUS | B FP64 values |
| 5 | PRMU0 | B FP64 values |
| 6 | LAYTROP | B INTEGER4 values |
| 7 | COLCH4 | B × H FP64 values |
| 8 | COLCO2 | B × H FP64 values |
| 9 | COLH2O | B × H FP64 values |
| 10 | COLMOL | B × H FP64 values |
| 11 | COLO2 | B × H FP64 values |
| 12 | COLO3 | B × H FP64 values |
| 13 | FORFAC | B × H FP64 values |
| 14 | FORFRAC | B × H FP64 values |
| 15 | INDFOR | B × H INTEGER4 values |
| 16 | SELFFAC | B × H FP64 values |
| 17 | SELFFRAC | B × H FP64 values |
| 18 | INDSELF | B × H INTEGER4 values |
| 19 | FAC00 | B × H FP64 values |
| 20 | FAC01 | B × H FP64 values |
| 21 | FAC10 | B × H FP64 values |
| 22 | FAC11 | B × H FP64 values |
| 23 | JP | B × H INTEGER4 values |
| 24 | JT | B × H INTEGER4 values |
| 25 | JT1 | B × H INTEGER4 values |
| 26 | OD | B × H × 112 FP64 values, output |
| 27 | SSA | B × H × 112 FP64 values, output |
| 28 | INCSOL | B × 112 FP64 values, output |

All FP64 owners align to eight bytes, and INTEGER4 owners align to four bytes. Inputs and the three output owners are disjoint. Outputs are mutually disjoint. Array size products fit signed 64-bit addresses. The routine preserves x19 through x30, x18 and the low 64 bits of v8 through v15. Its stack stays aligned to sixteen bytes.

## Storage And Admitted Inputs

Support 0 ≤ B ≤ 4096 and 0 ≤ H ≤ 512, with positive first labels and an empty range when KFDIA = KIDIA − 1. A daylight column requires H ≥ 2 and 1 ≤ LAYTROP < H so that every child solar lookup and next-row access is valid. Empty or all-night work may have zero layers and writes nothing.

Each child's declared table-index, gas-column and interpolation limits also apply. Daylight molecular totals, water, oxygen and carbon dioxide columns are positive. Methane and ozone are nonnegative. Interpolation and continuum factors are finite, with absolute values at most sixteen. Pressure and temperature indices select valid adjacent table entries. The supplied mixture cap is positive and strictly below one. The solar cosine is finite in [−1,1].

Require finite band absorption and scattering, nonnegative physical interaction depths and positive total depth in every daylight cell. These conditions define the physical domain of SGO-1 and SGO-2. Invalid states are reported without altering their bits. Night-column gas fields are unused by this caller and its children.

A private 32-byte TDIMV object supplies NFLEVG = H at byte zero. The bands share two B × H × 16 scratch planes and one B × 16 solar plane. A band finishes copying its active points before the next band overwrites scratch. Allocate only when a daylight column exists. This storage plan preserves the accepted child pitches and every rounded stage value. Allocation and release are storage helpers.

## Independent Acceptance And Output Bytes

Reuse each scientifically accepted child's calculation and table checks. For this new caller, obtain absorption A and scattering R from the genuine original band stages, then evaluate SGO-1 and SGO-2 with exact rational numbers. This compositional check joins independently verified child physics with the caller's own balance equations.

Let I = A + R be the exact total, T the stored rounded total and W the stored scattering fraction. Unit roundoff u = 2⁻⁵³ bounds relative FP64 rounding error for normal values, while η = 2⁻¹⁰⁷⁴ supplies the underflow allowance. The total-depth error allowance is d = uI + η. The division allowance is e = u(R/T) + η. Require abs(T − I) ≤ d, abs(W − R/I) ≤ e + Rd/(IT), and abs(T(1 − W) − A) ≤ d + Te. Also require T > 0 and 0 ≤ W ≤ 1. The exact fractions preserve all cancellation and subnormal terms without masking output bits.

Compare every byte of complete total-depth, scattering-fraction and solar owners, including untouched night cells and padding. Their canonical order is OD, SSA and INCSOL, each in column, layer and spectral-point storage order, with little-endian FP64 encoding. The acceptance limit is zero differing bytes. Preserve inputs, guards, metadata, registers and FPCR. Actual forecast pairs and the ten saved files must also agree before acceptance. Focused shapes include empty and all-night work, daylight and mixed columns, changed array labels, odd counts and the supported capacity limits.

The source physics and ABI were frozen before parent emission. Eighteen original calls at both protected buffer placements passed 291,174,912 complete returned bytes and 1,089,760 independent composition relations. This covers actual captured columns, changed labels, mixed and night columns, 4,096 columns, 512 layers and empty work. Inputs stay read-only, output padding is unchanged and FPCR is zero. The direct parent and its complete fourteen-band closure are now assembled. Native critical checks passed the same eighteen protected placements, 291,174,912 complete owner bytes with zero differences, 1,957,088 independent composition relations and the immediate twenty-eight-address ABI. The paired smoke passed two captured daylight calls, 559,104 returned bytes with zero differences and 103,936 live physical admissibility relations. The direct instructions preserve x18 and contain no fused or approximate floating-point operation. No speed improvement is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 1,789,132,800 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
