# Longwave Atmospheric Preparation Contract

Revision 1 implements RRTM_SETCOEF_140GP from OpenIFS 48.1.1. Its [physics note](../../../../../formulations/openifs/physics/longwave_atmospheric_inputs.md), revision 1.0, supplies LAI-1 through LAI-3. The [direct body](../../../../../src/openifs/physics/rrtm_setcoef_140gp.S) must calculate every gas amount, ratio, continuum factor and table index. A driver supplies no missing numerical stage.

## Method And Ordered Arithmetic

FP64 stores each real in 64 bits. RN means one separate FP64 operation with nearest rounding and an even result at an exact halfway point. Require FPCR, the Arm floating-point control register, to equal zero. Preserve gradual underflow and signed zeros. Use no fused arithmetic, reassociation, approximate division or reduced-precision operation. LOG is the natural logarithm, and EXP is its inverse exponential function. These functions reuse their already accepted non-fused routes and high-precision evidence.

Reuse the accepted genuine PREFLOG, TREF and seven-by-fifty-nine CHI_MLS reference tables. For every column, set LAYTROP and LAYSWTCH to integer zero. LAYLOW is integer one on return, including zero-layer work. Each layer obtains L = LOG(p), then clamps INT(RN(36−RN(5×RN(L+0.04)))) to integers one through fifty-eight. INT discards the fractional part towards zero. Unlike shortwave preparation, the pressure shift and other source constants use source JPRB precision directly.

Compute pressure fraction F = RN(5×RN(PREFLOG[J]−L)), then clamp it to [−1,1]. Use the two adjacent TREF rows to form z = RN(RN(T−TREF[row])/15), clamped temperature index INT(RN(3+z)) from one through four, and fraction RN(z−(index−3)). Store both temperature indices and fractions. The four final interpolation factors use the complete dependency order in the [shortwave preparation contract](srtm_setcoef.md), with this bounded F.

Form w = RN(N_w/N_d), s = RN(RN(p×RN(296/1013))/T), and f = RN(s/RN(1+w)). The lower branch uses L > 4.56, with one integer increment to the tropopause count. Its foreign temperature coordinate, index and fraction use (332−T)/36. Its self coordinate uses (T−188)/7.2, with index INT(coordinate)−7 clamped to one through nine. The upper branch uses foreign index three and fraction RN(RN(RN(T−188)/36)−1). Both branches compute a = RN(wf). Upper self fraction and self index owners retain their supplied bits.

Both branches store minor-gas density m = RN(p/T), and nitrogen factor RN(m×RN(N_b/RN(N_d+N_w))), where N_b is the supplied broadening-gas amount. The minor coordinate uses RN(RN(T−180.8)/7.2), with its integer index clamped to one through eighteen. Subtract this clamped index to obtain its stored fraction.

Each reference ratio is one RN division of two CHI_MLS values at the stored pressure row or the next row. Both branches store H2O/CO2 ratios. The lower branch also stores H2O/O3, H2O/N2O, H2O/CH4 and N2O/CO2, while preserving O3/CO2 owners. The upper branch stores O3/CO2 and preserves those other four ratio pairs. CHI_MLS has seven contiguous species per pressure row.

Scale selected water, carbon dioxide, ozone, nitrous oxide, methane and oxygen columns, plus the broadening column, with one RN multiplication by 1.E−20_JPRB. Carbon dioxide, nitrous oxide and methane amounts that compare equal to zero use RN(1.E−32_JPRB×N_d). Oxygen has no such replacement.

For LAI-3, compute reference amount R = RN(3.55E−24_JPRB×N_d), difference D = RN(stored CO2−R), and A = RN(D×272.63_JPRB). Compute E = EXP(RN(−1919.4_JPRB/T)). Return RN(RN(A×E)/RN(8.7604E−4_JPRB×T)). Preserve the call boundary and every multiplication. Finally rescale the self and foreign factors by the already rounded stored water amount, using one separate multiplication each.

## Forty-Nine-Address ABI

The application binary interface, or ABI, defines argument addresses and preserved registers. x0 through x7 contain the first eight addresses below. Incoming stack bytes zero through 320 contain the remaining forty-one addresses. The default direct entry is md2asm_rrtm_setcoef_140gp, with no scalar return. The genuine original is rrtm_setcoef_140gp_ at offset 0x862420.

Let B = KFDIA−KIDIA+1, H = KLEV and V = YDDIMV%NFLEVG. YDDIMV is a 32-byte object with V at its first INTEGER4 slot. Dummy matrices use the explicit first column label, so their pointers already address that selected column. Ordinary matrices have contiguous columns followed by layers. The molecular array has columns, thirty-five gases and then layers.

| Position | Argument | Owner |
| ---: | --- | --- |
| 1 | YDDIMV | 32-byte TDIMV input |
| 2 | KIDIA | One INTEGER4 input |
| 3 | KFDIA | One INTEGER4 input |
| 4 | KLEV | One INTEGER4 input |
| 5 | P_COLDRY | B × V FP64 input |
| 6 | P_WBROAD | B × V FP64 input |
| 7 | P_WKL | B × 35 × V FP64 input |
| 8 | P_FAC00 | B × V FP64 output |
| 9 | P_FAC01 | B × V FP64 output |
| 10 | P_FAC10 | B × V FP64 output |
| 11 | P_FAC11 | B × V FP64 output |
| 12 | P_FORFAC | B × V FP64 output |
| 13 | P_FORFRAC | B × V FP64 output |
| 14 | K_INDFOR | B × V INTEGER4 output |
| 15 | K_JP | B × V INTEGER4 output |
| 16 | K_JT | B × V INTEGER4 output |
| 17 | K_JT1 | B × V INTEGER4 output |
| 18 | P_COLH2O | B × V FP64 output |
| 19 | P_COLCO2 | B × V FP64 output |
| 20 | P_COLO3 | B × V FP64 output |
| 21 | P_COLN2O | B × V FP64 output |
| 22 | P_COLCH4 | B × V FP64 output |
| 23 | P_COLO2 | B × V FP64 output |
| 24 | P_CO2MULT | B × V FP64 output |
| 25 | P_COLBRD | B × V FP64 output |
| 26 | K_LAYTROP | B INTEGER4 output |
| 27 | K_LAYSWTCH | B INTEGER4 output |
| 28 | K_LAYLOW | B INTEGER4 output |
| 29 | PAVEL | B × V FP64 input |
| 30 | P_TAVEL | B × V FP64 input |
| 31 | P_SELFFAC | B × V FP64 output |
| 32 | P_SELFFRAC | B × V FP64 output |
| 33 | K_INDSELF | B × V INTEGER4 output |
| 34 | K_INDMINOR | B × V INTEGER4 output |
| 35 | P_SCALEMINOR | B × V FP64 output |
| 36 | P_SCALEMINORN2 | B × V FP64 output |
| 37 | P_MINORFRAC | B × V FP64 output |
| 38 | PRAT_H2OCO2 | B × V FP64 output |
| 39 | PRAT_H2OCO2_1 | B × V FP64 output |
| 40 | PRAT_H2OO3 | B × V FP64 output |
| 41 | PRAT_H2OO3_1 | B × V FP64 output |
| 42 | PRAT_H2ON2O | B × V FP64 output |
| 43 | PRAT_H2ON2O_1 | B × V FP64 output |
| 44 | PRAT_H2OCH4 | B × V FP64 output |
| 45 | PRAT_H2OCH4_1 | B × V FP64 output |
| 46 | PRAT_N2OCO2 | B × V FP64 output |
| 47 | PRAT_N2OCO2_1 | B × V FP64 output |
| 48 | PRAT_O3CO2 | B × V FP64 output |
| 49 | PRAT_O3CO2_1 | B × V FP64 output |

Inputs and outputs are disjoint, and output owners are mutually disjoint. FP64 addresses align to eight bytes, and INTEGER4 addresses align to four bytes. Preserve x18, x19 through x30 and the low halves of v8 through v15. The stack stays aligned to sixteen bytes.

## Inputs And Independent Acceptance

Support 0 ≤ B ≤ 4096 and 0 ≤ H ≤ V ≤ 512, with positive first labels and an empty interval when KFDIA = KIDIA−1. Used pressure, temperature and dry-air amount are positive and finite. Broadening and selected gas amounts are nonnegative and finite. Reference ratio denominators are positive. Intermediate arithmetic stays finite, with integer conversions in signed 32-bit range. Unused gas species and preserved output cells may carry arbitrary bits.

Before emission, check the original against independent high-precision density, molecular scaling, water-interaction, nitrogen-broadening and carbon-dioxide correction relations. Check exact reference ratios, source-defined integer/table bounds, four-factor partition sums and the count boundaries. Reuse accepted scalar math and genuine reference-table proofs.

Compare all forty output owners in ABI order, including upper self metadata, branch-unused ratios, vertical tails and empty work. Canonical bytes use little-endian INTEGER4 and FP64. Zero differing bytes is the acceptance limit. Protect inputs and both buffer placements, with changed labels, odd and capacity shapes, upper/lower branches, threshold neighbours, trace-gas zeros and zero layers. Check preserved registers and FPCR, then actual forecast calls and all ten saved files.

The physical and numerical contract was frozen before emission. The original passed twenty protected placements, 5,119,200 complete output bytes and 517,644 independent relations. The assembly passed the same placements and bytes with zero differences, 1,035,288 combined independent relations and its immediate forty-nine-address ABI. Seven paired calls also passed every returned owner and its physical checks.  No speed improvement is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 265,216,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
