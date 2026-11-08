# CUBASMCN Contract

[Physics input](../../../../../formulations/openifs/physics/midlevel_plume_base.md), revision 1. The canonical calculation is the original `cubasmcn` in `arpifs/phys_ec/cubasmcn.F90`. [Direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cubasmcn.S) replaces the complete numerical body.

## Domain and Interface

The GNU Fortran interface takes 26 addresses. The first is a 344-byte `TECUMF` configuration. Its FP64 `RMFLIA` mass-flux limit is at byte 64, its 32-bit logical `LMFMID` at byte 256 and its 32-bit integer `NJKT7` at byte 332. The five following 32-bit integers are `KIDIA`, `KFDIA`, `KLON`, `KLEV` and `KK`. Logical values are 0 or 1.

Let $`K=\mathrm{KLON}`$ and $`N=\mathrm{KLEV}`$. Support $`0\le K\le4096`$, $`2\le N\le1024`$ and $`1\le\mathrm{KK}<N`$, including an empty selected column range. The environment arrays `PTEN`, `PQEN`, `PQSEN`, `PVERVEL` and `PGEO` have shape $`K\times N`$. Half-level `PGEOH` has shape $`K\times(N+1)`$. The 32-bit logical `LDCUM` has $`K`$ entries. The 32-bit outputs `KTYPE` and `KCBOT` have $`K`$ entries, while `KLAB` has shape $`K\times N`$. The FP64 `PMFUB` output has $`K`$ entries. The other nine arguments are FP64 arrays with shape $`K\times N`$, including `PMFU`, `PLRAIN`, `PTU`, `PQU`, `PLU`, `PMFUS`, `PMFUQ`, `PMFUL` and `PDMFUP`.

Arrays use Fortran column order, with horizontal cells adjacent. Real owners need 8-byte alignment, integer owners need 4-byte alignment, and complete owners are separate. The environment cell is at zero-based index $`c+K(\mathrm{KK}-1)`$. Updated plume fields and `KLAB` are at $`c+K\mathrm{KK}`$. The half-level geopotential uses that same second index. The caller supplies complete owners, valid flags, positive temperature, water fractions in $`[0,1]`$, positive finite globals `RG` and `RCPD`, and finite arithmetic with positive resulting plume temperature. The configured limit is at least the FP64 value of $`10^{-6}`$.

The assembly follows AAPCS64, the Arm function-call convention. The first eight addresses arrive in `x0` through `x7`, and the remaining eighteen arrive on the caller's stack. It preserves `x19` through `x29`, the return address and `d8` through `d15`. Stack alignment remains 16 bytes. It reads the accepted GNU globals `__yomcst_MOD_rg` and `__yomcst_MOD_rcpd` through their normal linked addresses.

## Ordered Update

Round each listed multiplication, division, addition and subtraction separately in FP64. Use round to nearest with ties to even, gradual underflow, preserved signed zeros and FPCR zero. Do not contract operations into fused multiply-add.

Compute `ZRG = 1 / RG` and `ZORCPD = 1 / RCPD`. Visit columns `KIDIA` through `KFDIA`. A column starts a plume only when `LDCUM` is false, `KLAB` at `KK+1` is zero, `LMFMID` is true, `KK > NJKT7` and `PQEN > RN(0.80 * PQSEN)`. Here `RN` means one FP64 rounding.

For each activated column, compute `PTU = RN(RN(RN(RN(RCPD * PTEN) + PGEO) - PGEOH) * ZORCPD)`. Copy `PQEN` into `PQU`. Compute `M = min(RMFLIA, max(1e-6, RN((-PVERVEL) * ZRG)))`, store `M` in `PMFUB` and `PMFU`, then compute `PMFUS = RN(M * RN(RN(RCPD * PTU) + PGEOH))` and `PMFUQ = RN(M * PQU)`.

Store positive zero in `PLU`, `PLRAIN`, `PMFUL` and `PDMFUP`. Set `KCBOT = KK`, `KLAB = 1` and `KTYPE = 3`. Every other byte in all thirteen output owners remains unchanged, including unselected columns, other levels and skipped plume cells.

## Acceptance

Compare complete little-endian output owners in argument order, including all integer flags, untouched bytes and zero signs. The limit is zero differing bytes. Keep the unchanged inputs, configuration and globals intact. The independent verifier checks dry static energy, transported vapour and energy, and the floor and cap of mass flux using exact rational residuals with propagated FP64 rounding bounds. Critical cases cover activation flags, the strict humidity threshold, partial ranges, floor and cap, signed zeros, nonzero subnormal vapour, supported large shapes and empty ranges.

Original and native critical results and the paired forecast relay remain local under `.runtime/openifs/cubasmcn_source_7240564/`. The relay runs the original on cloned complete output owners, runs assembly on the real owners and returns assembly's bytes. Actual forecast acceptance is recorded after the shared batch finishes. No comparative timing or speed improvement is claimed here.

The original passed 19 focused cases with 779,108 complete output bytes and 16,472 independent physical relations. Assembly passed 38 guarded calls with 1,558,216 output bytes, 32,944 physical relations and 12 nonzero subnormal values. The complete paired relay passed the same 19 cases. All comparisons had zero differing bytes, and bounds, unchanged inputs, preserved registers and FPCR zero passed. These checks took place on job 7240564, node nid010555, CPU 64 with local memory. They are acceptance checks rather than timing measurements.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 34,400 genuine calls. The same-input comparison covers 1,205,376,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
