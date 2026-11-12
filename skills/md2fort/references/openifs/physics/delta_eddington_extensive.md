# Aerosol Delta Scaling Contract

Use [aerosol_forward_scattering.md](../../../../../formulations/openifs/physics/aerosol_forward_scattering.md), revision 1, equations P01–P02. Preserve `radiation_aerosol_optics::delta_eddington_extensive` from OpenIFS 48.1.1's `radiation_delta_eddington.h`.

## Ordered calculation

RN means one FP64 rounding to nearest, with ties to even. Read the three old values. If old scattering depth is positive, compute $`g=\operatorname{RN}(q/s)`$, otherwise set positive zero. Compute and round each multiplication, subtraction, addition and division below separately.

```math
\begin{aligned}
f&=\operatorname{RN}(gg),\\
a&=\operatorname{RN}(sf),\\
\tau'&=\operatorname{RN}(\tau-a),\\
h&=\operatorname{RN}(1-f),\\
s'&=\operatorname{RN}(sh),\\
b&=\operatorname{RN}(s'g),\\
d&=\operatorname{RN}(1+g),\\
q'&=\operatorname{RN}(b/d).
\end{aligned}
```

Store total depth first, then scattering depth, then the weighted directional value. The last multiplication uses the new scattering depth. Keep signed zeros and gradual underflow. FPCR, the floating-point control register, must be zero. Fused arithmetic, reassociation and approximate division are forbidden.

## Interface

`md2asm_openifs_delta_eddington_extensive` takes three separate mutable FP64 addresses in x0, x1 and x2. Each address supplies exactly eight readable and writable bytes aligned to eight bytes. The caller owns array loops and wavelength-band selection. All input values must be finite and within the physical range declared in P02.

The complete leaf uses only caller-saved floating-point registers d0–d6. It preserves x18, all callee-saved registers and the incoming stack pointer. It has no frame or helper call. All returned bits are the three scalar values in total, scattering and weighted-direction order.

## Verification

The original passes 75 critical cases and 375 independent physical relations, including zero depth, no scattering, fully forward scattering, partial scattering and subnormal depths. Exact rational arithmetic independently rounds the source operations. Signed-zero signs are checked separately because a rational number does not store a zero sign. Sentinel neighbours remain unchanged, and FPCR is zero.

Physical checks require nonnegative depths, scattering no greater than total depth and weighted scattering no greater than scattering depth. They also check absorption and directional-transport preservation. Their rounding bound is 32 FP64 machine epsilons times the largest input magnitude plus 64 smallest subnormals. Output-byte comparisons always require zero differences. Native critical and same-input forecast checks passed. Comparative timing is not yet available.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 13,619,200 actual calls over 326,860,800 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
