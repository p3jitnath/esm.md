# Longwave Layer Transport Contract

Revision 1 covers the complete native entry `md2asm_longwave_layer` and the original interface `calc_reflectance_transmittance_lw`, from the frozen OpenIFS two-stream radiation source. The [physical input](../../../../../formulations/openifs/radiation/longwave_layer_energy.md) defines $`\tau,a,b,B_t,B_b,R,T,S_u,S_d`$. The layer calculates all four outputs itself and performs no forecast time update.

## Supported inputs and interface

An application binary interface (ABI) specifies arguments, registers, and stack use. This AArch64 entry receives ten ordinary pointers; each positive-length array contains consecutive FP64 values, which are 64-bit floating-point numbers.

| Position | Address location | Pointee and meaning | Access |
| --- | --- | --- | --- |
| 1 | `x0` | `ng`, one signed 32-bit entry count | Read |
| 2 | `x1` | `od[ng]`, optical depth $`\tau`$ | Read |
| 3 | `x2` | `gamma1[ng]`, coefficient $`a`$ | Read |
| 4 | `x3` | `gamma2[ng]`, coefficient $`b`$ | Read |
| 5 | `x4` | `planck_top[ng]`, source $`B_t`$ | Read |
| 6 | `x5` | `planck_bot[ng]`, source $`B_b`$ | Read |
| 7 | `x6` | `reflectance[ng]`, output $`R`$ | Replace |
| 8 | `x7` | `transmittance[ng]`, output $`T`$ | Replace |
| 9 | Incoming `[sp]` | `source_up[ng]`, output $`S_u`$ | Replace |
| 10 | Incoming `[sp+8]` | `source_dn[ng]`, output $`S_d`$ | Replace |

For $`1\le\mathtt{ng}\le4096`$, each array must have at least $`8\mathtt{ng}`$ accessible bytes and 8-byte alignment. All four output arrays must be disjoint from each other, the input arrays, and `ng`. The count pointer must be readable and 4-byte aligned. A nonpositive count returns without array access or writes; a count above 4096 rejects.

Every active input must be finite and lie from zero through $`10^6`$, with $`a>b\ge0`$ and the rounded product $`(a-b)(a+b)>10^{-12}`$. The assembly checks all entries before its first output write. For $`\tau\le0.001`$, it also requires $`k\tau\le1`$ and $`a-b-b(a-k)\tau\ge0`$, evaluated with the stated FP64 multiplication and subtraction order. For the latter guard, calculate $`w=a-k`$, $`v=bw`$, $`v=v\tau`$, and $`h=(a-b)-v`$, preserving the already rounded difference $`a-b`$. In exact arithmetic, these conditions make thin transmission and absorption nonnegative. The source case $`a=b=0.83,\ \tau=0.001`$ gives negative approximate emission and remains excluded; no model setting is changed to admit it.

The entry uses a 192-byte stack frame and retains 16-byte stack alignment. It preserves `x18`, `x19`–`x29`, the return address, and the ABI-required low 64 bits of `v8`–`v15`. Only the build-selected `EXP_SYMBOL` mathematical helper is called during an accepted calculation; rejected inputs call `abort`.

## Complete ordered calculation

Process spectral entries in increasing index order. Each operation below rounds separately to FP64. First calculate $`p=a-b`$, then $`m=a+b`$, then $`q=p\,m`$, then $`k=\sqrt{\max(q,10^{-12})}`$. The retained floor matches the original routine. The branch threshold is the FP64 value with bits `0x3f50624dd2f1a9fc`; equality selects the thin branch.

For a thin layer, calculate $`R=b\tau`$. Calculate $`v=k\tau`$, $`n=1-v`$, $`w=a-k`$, $`z=\tau w`$, $`d=1+z`$, and $`T=n/d`$, in that order. Then calculate $`h=1-R`$, $`A=h-T`$, $`f=A(0.5)`$, $`s=B_t+B_b`$, and $`S_u=f s`$; copy its bits to $`S_d`$. This uses the mean thermal source and does not claim to solve the continuous equations exactly.

For a thick layer, calculate $`v=k\tau`$, negate it, call the qualified exponential helper to obtain $`E=\exp(-v)`$, and calculate $`E_2=E E`$. Calculate $`u=k+a`$, $`w=k-a`$, $`z=w E_2`$, $`d=u+z`$, and $`F=1/d`$. Calculate $`h=1-E_2`$, $`j=b h`$, and $`R=j F`$; then calculate $`j=2k`$, $`j=j E`$, and $`T=j F`$.

For thick-layer emission, calculate $`\Delta=B_b-B_t`$, $`m=a+b`$, $`d=\tau m`$, and $`C=\Delta/d`$. Calculate $`U_t=C+B_t`$, $`U_b=C+B_b`$, $`D_t=(-C)+B_t`$, and $`D_b=(-C)+B_b`$. Calculate $`j=R D_t`$, $`h=U_t-j`$, $`j=T U_b`$, and $`S_u=h-j`$. Then calculate $`j=R U_b`$, $`h=D_b-j`$, $`j=T D_t`$, and $`S_d=h-j`$. Store $`R,T,S_u,S_d`$ into their separate arrays for that entry.

The floating-point control register, FPCR, must equal zero: round to nearest with ties to even, gradual underflow, and no enabled floating-point traps. Multiplication and addition remain separate; fused operations, contraction, reassociation, approximate division or square root, reduced precision, and fast-math are forbidden. Input and output signed zeros are preserved according to the original operations. The prewrite guard restores the incoming floating-point status register, FPSR, before numerical work, so accepted calculations retain the source's sticky flags and the mathematical helper's error indicator, `errno`.

## Focused evidence and limits

The retained source check passes 36 cases and 396 independent relations using 120-digit thermal boundary integrals. It covers zero and subnormal depth, both sides of the thin threshold, equal and unequal thermal sources, large depth, and a supported near-conservative case. For thin layers, define $`M=a+b`$ and $`Q=(M\tau)^2\exp(2M\tau)`$. The declared absolute approximation bounds are $`2Q`$ for reflection, $`3Q`$ for transmission, and $`2B_{\max}Q`$ for each emission, in addition to independently propagated rounding bounds. Thick cases compare the source formula with the integral identity and propagated rounding bounds.

Eight focused native calls, including six protected nonempty cases and two empty-range cases, return 138,432 bytes and retain 173,064 read-only bytes with zero differences, preserved ABI registers, exact status, and 1,794 actual exponential calls. Nine prewrite rejection checks leave 1,980 complete owner bytes unchanged. The strict root-floor boundary adds one guard check while reusing the unchanged numerical, physics and ABI results. The sealed paired relay passes two protected calls over 288 returned bytes and 368 read-only bytes, with zero differences, 80 independent live energy relations, five actual private exponential calls, preserved ABI registers, and exact sticky FPSR and `errno`, including FPSR value 24 from underflow and inexact and `ERANGE` value 34. Fresh original and native library routes agree.

Acceptance requires zero differing raw bytes in every returned array and no changed read-only bytes; hashes identify artifacts and do not replace comparison. Outputs remain consecutive FP64 values in spectral-entry order, with no rounding, masking, or normalisation. The first genuine source packet passes independent thermal-boundary integrals. The live verifier checks every complete original return against transfer and thermal-energy relations before the native call, establishing the visited conditional domain. No performance measurement or autonomous forecast claim is made.

## Accepted Forecast Calls

The complete direct stage passes 292,394 genuine native calls and 1,309,925,120 complete returned bytes with zero differences. All ten saved forecast files agree across 618,140 bytes. The recorded independent physics and interface checks remain required within this contract. Other forecast stages remain in Fortran.
