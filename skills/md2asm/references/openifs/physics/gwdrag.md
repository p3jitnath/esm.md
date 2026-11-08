# Mountain Wave Wind Drag Contract

This contract implements complete `GWDRAG` from [mountain-wave wind drag](../../../../../formulations/openifs/physics/mountain_wave_drag.md). The direct entry is `md2asm_gwdrag` in [mountain_wave_drag.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/mountain_wave_drag.S). Complete private [GWSETUP](gwsetup.md) and [GWPROFIL](gwprofil.md) children supply all setup and stress-profile calculations.

## Domain

There are 1–4,096 explicit columns and 6–512 levels, numbered downwards. Columns change fastest in contiguous FP64 arrays. Pressure faces have shape `(columns,levels+1)` and source indices `0..levels`. Full fields have shape `(columns,levels)`. The active range may be partial or empty. Every atmospheric bound and derived mean interval follows the complete GWSETUP contract. Zero exterior pressure at face zero is admitted.

Active mountain height variation is finite in `0..1e7` metres, and slope is finite in `0..1e6`. Height variation above 50 metres selects a wave-active column. Only those columns consume atmosphere and direction. All active shape ratios follow the child's finite domain before its clamp.

The linear-physics flag is zero or one. The selected drag coefficient, wake coefficient and tendency cap are finite in `0..1e6`. Only the selected drag coefficient is consumed. The pressure threshold lies in `0..1e8` pascals. `1<=NGWDTOP<=levels` supplies a valid pressure face and stress index, and `0<=NGWDLIM<=levels+1` selects capped layers. Complete owner bounds and these new values are checked before caller writes. The private setup child checks its complete input and source-derived mean interval before changing the caller's shape ratio.

## Ordered Equations

FP64 operations round separately to nearest with ties to even, with FPCR zero. The parent selects `PHSTD>50`, chooses `RLPDRAG` or `GKDRAG`, and calls complete private GWSETUP. Ground stress then keeps the source order

```math
h_{\mathrm{eff}}=2\max(0,3h-\Phi_{\mathrm{block}}/g),\qquad
\tau_0=\kappa\rho_0s h_{\mathrm{eff}}^2/9/h\,U_0d\sqrt{S_0}.
```

Here $`h`$ is mountain height variation in metres, $`s`$ is dimensionless slope, $`\kappa`$ is the selected drag coefficient, $`U_0`$ is the safeguarded low wind norm and $`d`$ is its dimensionless direction factor. Density $`\rho_0`$ is in kilograms per cubic metre, stability $`S_0`$ is in inverse seconds squared, and geopotential $`\Phi`$ is in square metres per second squared. Masked ground stress is zero. Complete private GWPROFIL then transports and limits this stress.

The parent clears all three active coefficient fields. It divides stress divergence by face-pressure thickness and low wind norm. Below the configured pressure threshold, it spreads the top stress difference using `NGWDTOP` and the squared full top pressure interval. Both wind coefficients preserve the rotated low wind and direction-factor division. Layers above `NGWDLIM` retain the original sign and cap each coefficient magnitude.

At or below the blocking level, explicit coefficients become zero. The method forms the source shape factors, separately squares the qualified cosine of the child angle, and forms its complementary sine-square. It evaluates the direction ratio, wake coefficient, leakiness and wind norm before multiplying the complete nonnegative wake term. Integer squares use ordinary multiplication. Every active, masked and boundary branch is included. Accepted unique arctangent and sine/cosine helpers preserve original scalar rounding. Every cosine operand has magnitude below eight radians.

## ABI And Bytes

The entry takes 19 addresses. Registers `x0..x7` contain `YDEPHLI`, `YDEGWD`, `KIDIA`, `KFDIA`, `KLON`, `KLEV`, `PAPHM1` and `PAPM1`. Stack arguments continue with `PGEOM1`, `PTM1`, `PUM1`, `PVM1`, `PHSTD`, `PGAMMA`, `PTHETA`, `PSIG`, `PSOTEU`, `PSOTEV` and `PSOBETA`. Integers occupy four bytes. Other owners require eight-byte alignment.

Measured GNU TEPHLI has 120 bytes, with `LPHYLIN=4` and `RLPDRAG=96`. TEGWD has 96 bytes. New parent offsets are `NGWDLIM=4`, `NGWDTOP=8`, `GKWAKE=40`, `GTENLIM=72` and `GRFPLM=80`. Other consumed metadata reuse accepted child records.

Four complete output owners contain `PGAMMA` and the three full coefficient arrays. Canonical output has `columns*(24*levels+8)` bytes. Every output is separate from other outputs and read-only owners. Inactive columns remain unchanged. The entry preserves `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR, with 16-byte stack alignment. One private allocated block holds every child field and mask. Profiling may remain enabled in the original control.

## Evidence

Before generation, the original passes 18 protected placements over 149,296 complete output bytes, with 13,072 independent 110-digit relations and 67,168 unchanged inactive bytes. New physics checks cover surface stress, stress divergence, wind direction, signed caps and wake drag. Their frozen bound is `4096*epsilon*levels*uncancelled term scale`, with $`\epsilon=2^{-52}`$. Nearly equal stresses use the sum of their input magnitudes in that error scale. Complete child and scalar-maths proofs are reused. Every output byte must match the unchanged original. The native body passes the same 18 protected placements with zero differing bytes over all 149,296 output bytes and 26,144 source-and-native physical relations. Immediate 19-address ABI and paired routes each pass two cases over 2,320 bytes. Eight invalid inputs preserve 3,712 shared output bytes before rejection. A separate masked NaN case passes source, native and paired routes over 3,104 bytes each. The report is written after every complete call while preserving returned floating-point status and the error indicator. The first active forecast packet also passes original, native and paired replay over 11,136 complete bytes per route with zero differences and 4,803 independent 110-digit relations across eight wave columns. The physical check keeps the same error limit.  Local records are under `.runtime/openifs/gwdrag_source_7240564/`.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| gwdrag | 2,150 | 23,942,400 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
