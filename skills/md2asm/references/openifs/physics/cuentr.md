# CUENTR Contract

[Physics input](../../../../../formulations/openifs/physics/plume_air_exchange.md), revision 1. The canonical calculation is the complete original `cuentr` in `arpifs/phys_ec/cuentr.F90`. [Direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cuentr.S) includes the stochastic perturbation branch.

## Domain and Interface

The GNU Fortran interface takes 18 addresses. The first two are the accepted 344-byte `TECUMF` and 3,192-byte `TSPP_CONFIG` objects. The FP64 `TECUMF.DETRPEN` coefficient is at byte 48. The SPP object has its 32-bit `LSPP` flag at byte 0, `SM.NRFTOTAL` at byte 216, `PPTR.DETRPEN` at byte 504 and the 64-byte rank-one `SM.PN` array descriptor at byte 352.

The descriptor describes a contiguous array of 184-byte `SPP_PERT` objects. It stores the data address at byte 0, element offset at byte 8, element size at byte 16, span at byte 32, unit stride at byte 40 and lower and upper bounds at bytes 48 and 56. Member `MU(1)` is at byte 56, `XMAG(1)` at byte 24 and 32-bit `MP` at byte 136. A positive `PPTR.DETRPEN` is a valid index into this complete array, with at most 128 elements. The selected `MP` points to a valid random-field column, with `0 <= NRFTOTAL <= 512`. `LSPP` false or a nonpositive perturbation pointer disables that perturbation.

Five 32-bit integer scalars follow, in order `KIDIA`, `KFDIA`, `KLON`, `KLEV` and `KK`. Let $`K=\mathrm{KLON}`$ and $`N=\mathrm{KLEV}`$. Support $`0\le K\le4096`$, $`2\le N\le1024`$ and $`1\le\mathrm{KK}<N`$, including valid empty selected ranges. The 32-bit arrays `KCBOT`, `KTYPE` and `LDCUM` each have $`K`$ entries. `LDWORK` is a 32-bit logical scalar. Logical values are 0 or 1.

The five FP64 input arrays are `PQSEN(K,N)`, `PAPH(K,N+1)`, `PGEOH(K,N+1)`, `PMFU(K,N)` and `PGP2DSPP(K,NRFTOTAL)`. The last two FP64 owners are `PDMFEN(K)` and `PDMFDE(K)`. All arrays have horizontal cells adjacent. Complete outputs do not overlap other arguments or the perturbation array. Real owners need 8-byte alignment and integer owners need 4-byte alignment. `KTYPE`, `PQSEN` and `PAPH` have no numerical use in this body.

Require positive finite global `RG`, nonnegative finite `DETRPEN`, nonnegative plume mass and layer geopotential difference, valid cloud-base and perturbation indices, and finite arithmetic. The rounded exponent lies in $`[-700,700]`$. This calculation uses the accepted strict scalar `EXP` route from `.runtime/openifs/strict-math/libpressure-math.so`. Both the original and assembly use that same route, whose independent accuracy checks are reused and extended only for this entry's exponent cases.

The assembly follows AAPCS64, the Arm function-call convention. The first eight addresses arrive in `x0` through `x7`, and the remaining ten arrive on the stack. It preserves `x19` through `x29`, the return address and `d8` through `d15`. The stack stays 16-byte aligned. A stochastic branch calls only the accepted scalar `exp` symbol.

## Ordered Update

Use FP64, the 64-bit representation of a real number, with separate rounding after each operation. Round to nearest with ties to even, preserve signed zeros and subnormal values, and use FPCR zero. Subnormal values are smaller than the smallest normal FP64 value. Do not use fused multiply-add, reassociation or approximate arithmetic.

When `LDWORK` is false, retain every output byte. Otherwise compute `ZRG = 1 / RG` and resolve the optional perturbation configuration. For each selected column, first set `PDMFEN` and `PDMFDE` to positive zero. When `LDCUM` is true, compute `DZ = (PGEOH(KK) - PGEOH(KK+1)) * ZRG` and `MF = PMFU(KK+1) * DZ`. If `KK < KCBOT`, the column can exchange air.

Use `C = DETRPEN` when perturbation is disabled. Otherwise, read the configured scalar `MU(1)`, `XMAG(1)` and selected random field, compute `X = MU(1) + XMAG(1) * PGP2DSPP` with separate multiplication and addition, then compute `C = DETRPEN * EXP(X)`. Store `PDMFEN = 0 * MF` and `PDMFDE = C * MF` with separately rounded products. The source's zero product can retain a negative-zero sign, so it must be computed. Ineligible columns keep the initial positive zeros, and unselected columns retain their incoming bytes.

## Acceptance

Compare both complete little-endian output owners, including untouched columns and zero signs, with zero differing bytes required. Keep the complete configuration, perturbation array and all input owners unchanged. Independent physical checks use exact geopotential thickness to check mass exchange and its nonnegative direction. A 230-digit decimal interval encloses the physical exponential and carries its rounding uncertainty into that balance.

Critical cases cover disabled work, inactive columns, cloud-base equality, disabled and active perturbations, shifted perturbation-array bounds, both random-field indexing and coefficient limits, zero height, signed zeros, nonzero subnormal mass, exponent limits, partial ranges, large shapes and empty ranges. Native checks add protected input owners, bounds, preserved registers and FPCR zero.

Evidence and tools stay local under `.runtime/openifs/cuentr_source_7240564/`. The paired relay runs the original on cloned complete output owners, then runs assembly on the real owners and returns assembly's bytes. Actual forecast acceptance is recorded after the shared batch finishes. No comparative timing or speed improvement is claimed.

The original passed 21 focused cases with 66,400 complete output bytes, 12,402 independent physical relations and 5 nonzero subnormal values. Assembly passed 42 guarded calls with 132,800 bytes, 24,804 physical relations and 10 nonzero subnormal values. The paired relay passed all 21 cases with unchanged complete configuration and perturbation metadata. All byte comparisons had zero differences. Protected input owners, bounds, preserved registers and FPCR zero passed on job 7240564, node nid010555, CPU 64 with local memory. These are acceptance checks rather than comparative timings.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 34,400 genuine calls. The same-input comparison covers 13,209,600 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
