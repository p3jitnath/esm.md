# GWPROFIL Contract

[Physics input](../../../../../formulations/openifs/physics/gravity_wave_stress_profile.md), revision 1. The canonical numerical body is the original `gwprofil` in `arpifs/phys_ec/gwprofil.F90`. [Direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/gwprofil.S) replaces the complete body.

## Domain and Interface

The GNU interface takes 21 addresses. The first two point to a 120-byte `TEPHLI` object and a 96-byte `TEGWD` object. `TEPHLI` has the 32-bit `LPHYLIN` flag at byte 4 and FP64 `RLPDRAG` at byte 96. `TEGWD` has FP64 `GRCRIT`, `GKDRAG`, `GSSEC` and `GTSEC` at bytes 24, 32, 48 and 56. Four 32-bit integers follow, in order `KIDIA`, `KFDIA`, `KLON` and `KLEV`.

Let $`K=\mathrm{KLON}`$ and $`N=\mathrm{KLEV}`$. Support $`0\le K\le4096`$, $`2\le N\le1024`$, valid selected columns and empty ranges. The six 32-bit arrays are `LDGWD`, `KKCRITH`, `KCRIT`, `KKENVH`, `KKNU` and `KKNU2`, each with $`K`$ entries. The next six FP64 arrays are `PAPHM1`, `PRHO`, `PSTAB`, `PVPH`, `PRI` and `PTAU`, each with $`K(N+1)`$ entries. The last three FP64 arrays, `PDMOD`, `PSIG` and `PHSTD`, each have $`K`$ entries. All arrays have horizontal cells adjacent. Pressure starts at Fortran level 0, while the other five arrays start at level 1. Complete output owners are separate from other arguments. Real addresses need 8-byte alignment, and integer addresses need 4-byte alignment.

The original parent `GWSETUP` clamps stability to `GSSEC`, projected wind to its positive security value and Richardson number to `GRCRIT`. Use those caller guarantees. Density is positive, terrain factors and stress are nonnegative, `GSSEC > 0`, `GTSEC >= 0`, and the selected drag factor and `GRCRIT` are positive. Require finite intermediates and strictly increasing pressure with level. Active columns have $`1\le\mathrm{KKCRITH}\le\mathrm{KKENVH}\le N+1`$, $`1\le\mathrm{KKNU}\le N`$, $`2\le\mathrm{KKNU2}\le N+1`$ and $`0\le\mathrm{KCRIT}\le N`$.

The assembly follows AAPCS64, the Arm function-call convention. Addresses 1 through 8 arrive in `x0` through `x7`, and the remaining thirteen arrive on the stack. It preserves `x19` through `x29`, the return address and `d8` through `d15`, with 16-byte stack alignment. No numerical child or external math helper supplies part of the calculation.

## Ordered Update

Use FP64, the 64-bit representation of a real number, with round to nearest and ties to even. Gradual underflow preserves subnormal values, numbers below the smallest normal FP64 value. Preserve signed zeros and use FPCR zero. Each multiplication, addition, subtraction, division and square root has its own rounding point. Integer powers of two mean one rounded self-multiplication. Fused multiply-add, approximate roots and reassociation are excluded.

Select `KDRAG = RLPDRAG` when `LPHYLIN` is true, otherwise `GKDRAG`. For each active selected column, form `ORO = ((PSIG * PDMOD) / 4) / max(PHSTD, 1)` and save the incoming ground stress `PTAU(N+1)`. The original also copies the incoming `KKNU+1` stress into a temporary slot whose value is never read before that slot is overwritten. This copy has no output effect.

Visit levels `j=N` through `2` in decreasing order. When `j >= KKNU2`, copy the saved ground stress. Otherwise compute `NORMAL = (((KDRAG * PRHO) * sqrt(PSTAB)) * PVPH) * ORO` and `D = PTAU(j+1) / max(NORMAL, GSSEC)`. This floor is a numerical guard inherited from the original.

After these calculations, set stress to positive zero when the lower stress is strictly less than `GTSEC` or `j <= KCRIT`. Otherwise compute `S = sqrt(PRI)`, `A = sqrt(PSTAB * D) / PVPH`, `B = 1 + A * S` and `RIW = (PRI * (1 - A)) / (B * B)`.

If `RIW < GRCRIT`, compute `DEL = ((4 / S) / GRCRIT + 1 / (GRCRIT * GRCRIT)) + 4 / GRCRIT`, `B = 1 / GRCRIT + 2 / S`, `ALPHA = 0.5 * (-B + sqrt(DEL))` and `DNEW = (PVPH * ALPHA) * (PVPH * ALPHA) / PSTAB`. Both products use the same rounded `PVPH * ALPHA` intermediate. The candidate stress is `NORMAL * DNEW`. Otherwise it is `NORMAL * D`. Store the minimum of that candidate and `PTAU(j+1)`.

Save the newly formed stresses at `KKENVH` and `KKCRITH`. For each strict interior level `KKCRITH < j < KKENVH`, compute `DP = PAPHM1(j-1) - PAPHM1(KKENVH-1)` and `SPAN = PAPHM1(KKCRITH-1) - PAPHM1(KKENVH-1)`, then store `TAUENV + (((TAUCRIT - TAUENV) * DP) / SPAN)`. The saved endpoints prevent an update from changing a later endpoint read. All other stress bytes, including level 1, the ground level, inactive columns and unselected columns, remain unchanged.

## Acceptance

Compare the complete little-endian `PTAU` owner, including untouched cells and zero signs, with zero differing bytes required. The independent verifier checks nonnegative stress, upward nonincrease, critical-level zeroing before interpolation, the quadratic equation for critical displacement and convex interpolation in pressure. Exact rational residuals carry the accepted rounding bounds. Bounds are rounded outward on the accepted $`2^{-2200}`$ lattice to keep long columns efficient.

Focused cases cover blocked and unblocked layers, both drag factors, breaking and stable waves, critical and small-stress branches, interpolation endpoints, terrain floors, the Richardson-number floor, partial ranges, signed zeros, nonzero subnormal stress, large shapes and empty ranges. Native calls additionally check protected input owners, buffer bounds, preserved registers and FPCR zero.

Evidence and tools stay local under `.runtime/openifs/gwprofil_source_7240564/`. The paired relay runs the genuine original on a complete cloned stress owner, runs assembly on the real owner and returns assembly's bytes. Forecast acceptance is recorded after the shared batch. No comparative timing or speed improvement is claimed.

The original passed 22 focused cases with 131,472 complete stress bytes, 53,760 independent physical relations and 15 nonzero subnormal values. Assembly passed 44 guarded calls with 262,944 stress bytes, 107,520 physical relations and 30 nonzero subnormal values. The complete paired relay passed all 22 cases. Every comparison had zero differing bytes. Bounds, unchanged inputs, preserved registers and FPCR zero passed on job 7240564, node nid010555, CPU 64 with local memory. These are acceptance results rather than comparative timings.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 8,256,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
