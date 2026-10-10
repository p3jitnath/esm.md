# CUCCDIA Solver Contract

Revision 1.0 uses [convective cloud diagnostics](../../../../../formulations/openifs/physics/convective_cloud_diagnostics.md), equations CCD-1 and CCD-2. The original routine is CUCCDIA in `arpifs/phys_ec/cuccdia.F90`. [Direct assembly](../../../../../src/openifs/physics/cuccdia.S) supplies the complete calculation. There is no numerical child or external mathematical function.

## Inputs And Branches

The full column capacity is B, and H is the number of model levels. Both use four-byte signed integers. Accept 0 ≤ B ≤ 4096, 0 ≤ H ≤ 512 and a selected inclusive range 1 ≤ KIDIA ≤ KFDIA+1 ≤ B+1. Active convective columns require H ≥ 1 and cloud-top and cloud-base indices from one through H, with the top index no larger than the base index. Read only those active cloud-level entries. The time-step index is from zero through 2147483646, and the nonzero radiation frequency is from −4096 through 4096.

The GNU configuration objects have sizes TERAD 2040 bytes, TEPHLI 120 bytes and TEPHY 448 bytes. Read NRADFR at TERAD byte 12, LPHYLIN at TEPHLI byte 4, and LECUMF and LERADI at TEPHY bytes 8 and 36. Each logical value occupies four bytes. These objects supply metadata and remain unchanged.

When LPHYLIN is false and NRADFR differs from one, accumulate only if LECUMF and LERADI are true and MOD(KSTEP+1,NRADFR) differs from zero. MOD uses the signed integer remainder from division truncated towards zero. Otherwise, replace the diagnostic when LECUMF is true. In either branch, skip columns whose LDCUM flag is false. Preserve every output byte when a branch is inactive.

For accumulation, the new base is MAX(old base, supplied base) and the new top is MIN(old top, supplied top). If that top equals the sentinel value one, replace it with the supplied top. Replacement copies both supplied indices. The rain calculation always reads the supplied cloud base and top rather than the updated diagnostic indices.

## Frozen Arithmetic

Use FP64 with round-to-nearest, ties to even, gradual underflow and preserved signed zeros. Require FPCR zero. Forbid fused operations, contraction, reassociation, approximate arithmetic and reduced precision. Define RN as the rounding of one operation to FP64. All consumed humidity fractions lie from zero through one, upward mass and rain fluxes from zero through 2²⁰ kg/(m² s), and the stored diagnostic from zero through 2⁴⁰ kg/(m² s). All consumed values are finite.

Compute a = RN(q_b+l_b), b = RN(a−q_t), c = RN(q_b×0.05), d = MAX(b,c), e = RN(d×m) and F = MAX(e,R), in that order. The constant 0.05 has binary64 bits 3fa999999999999a. The maxima use the Arm `fmaxnm` rule, including positive zero when both signed zeros are compared. Compute the interval weight once as RN(1/REAL(MAX(NRADFR−1,1))). Accumulation rounds RN(F×w) before RN(P+that product). Replacement stores F directly.

Let u = 2⁻⁵³ and η = 2⁻¹⁰⁷⁴. The independent physical check compares the result with the exact rational form of CCD-1 and CCD-2. Its absolute allowance is 64u[|P|+|m|(|q_b|+|l_b|+|q_t|+0.05|q_b|)+|R|]+64η. It also checks a nonnegative water flux, the supplied-rain lower limit, the cloud-level rules and unchanged inactive columns. This bound does not alter the separate zero-byte acceptance limit.

## Calling Interface And Storage

The Arm application binary interface, ABI, defines arguments and preserved registers. Eighteen ordinary address arguments have the original order TERAD, TEPHLI, TEPHY, KIDIA, KFDIA, KLON, KLEV, KSTEP, KCBOT, KCTOP, LDCUM, PQU, PLU, PMFU, PRAIN, PARPRC, KTOPC, KBASEC. The first eight addresses arrive in x0 through x7, and the remaining ten occupy incoming stack bytes zero through 72. There are no hidden arguments or array descriptors.

PQU, PLU and PMFU are column-fast B-by-H FP64 arrays. PRAIN and PARPRC have B FP64 values. The cloud indices and logical flags have B four-byte values. Real addresses align to eight bytes and integer addresses to four. Outputs are disjoint from each other, consumed inputs and configuration objects. Inputs may overlap if they remain read-only.

Preserve x19 through x29, x30, the low halves of v8 through v15, reserved x18, FPCR and the sixteen-byte stack alignment. The 96-byte local frame saves x19 through x30 and uses no preserved floating-point register. Restore it before returning. Profiling is outside the numerical state. No driver may calculate a cloud flux or update an output in place of the assembly.

Canonical critical bytes contain all three output owners, including inactive columns and their guard padding, in PARPRC, KTOPC, KBASEC order. The live comparison keeps complete B-element owners in the same order. Compare every byte directly, including signed zeros and untouched payloads. Stop on the first differing call, field, cell and bit pattern. Critical bounds and ABI checks precede one combined forecast check, and accepted unchanged child evidence is reused.

## Verification State

The contract and independent error allowance are frozen before assembly emission. Source and object-layout evidence are retained locally in `.runtime/openifs/weather24h-cuccdia/`. The new body remains pending until independent physics, protected exact output comparisons, immediate ABI checks and its actual forecast route pass.

## Focused Acceptance

The complete direct body passes 256 protected original comparisons across 572,800 full owner bytes, with zero differing bytes. The independent check accepts 106,912 water and cloud relations, including ten nonzero subnormal outputs. Read-only inputs, both guard placements, empty and cropped columns, signed zeros, branch gates, the maximum column capacity, cloud-top ordering, and immediate saved-register and FPCR checks pass. The complete paired relay also passes all 256 small calls. No comparative speed is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 825,600 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
