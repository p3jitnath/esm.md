# OpenIFS horizontal-wind tendency contract

Contract revision 1.0 freezes the complete GP_TNDLAGADIAB_UV body in OpenIFS 48.1.1. The physical input is [horizontal wind tendencies](../../../../../formulations/openifs/dynamics/wind_tendency.md), revision 1.0. The routine combines supplied pressure terms, explicit Coriolis acceleration and every Rayleigh damping branch. It does not calculate pressure, advance time or add the separate complete-Coriolis routine's terms.

## Branches and complete arithmetic

FP64 denotes 64-bit floating-point values. RN rounds to nearest FP64 with ties to an even final bit. Arithmetic rounds after each operation. Define $`U`$ and $`V`$ as the PGMV fields selected by YT0%MU and YT0%MV, $`f`$ as PRCORI, $`L`$ and $`M`$ as PGNORDL and PGNORDM, and $`r`$ as RKRF at the current level.

If LRFRIC is false or LEGWWMS is true, set both damping terms to positive zero. Otherwise, if LRFRICISOTR is true, set $`F_U=\mathrm{RN}((-r)U)`$ and $`F_V=\mathrm{RN}((-r)V)`$. Otherwise, if LRPLANE is false and NSTTYP equals 1, use the same $`F_U`$ with positive-zero $`F_V`$. The remaining branch uses the tilted or planar direction. Set $`r_U=r`$ and $`r_V=+0`$, then retain all following operations, including products with zero.

```math
A_U=\mathrm{RN}(\mathrm{RN}(r_UM)M),\quad
B_U=\mathrm{RN}(\mathrm{RN}(r_VL)L),\quad
C_U=\mathrm{RN}(A_U+B_U),
```

```math
A_V=\mathrm{RN}(\mathrm{RN}(r_UL)L),\quad
B_V=\mathrm{RN}(\mathrm{RN}(r_VM)M),\quad
C_V=\mathrm{RN}(A_V+B_V),\quad
N=\mathrm{RN}(\mathrm{RN}(\mathrm{RN}(r_U-r_V)M)L),
```

```math
F_U=\mathrm{RN}(\mathrm{RN}((-C_U)U)+\mathrm{RN}(NV)),\qquad
F_V=\mathrm{RN}(\mathrm{RN}(NU)-\mathrm{RN}(C_VV)).
```

For every branch, calculate all four outputs in the following order. Unary negation changes the sign bit exactly. Do not replace negation followed by addition with an algebraically simpler expression because signed-zero results can change.

```math
U_0=\mathrm{RN}((-S_L)+F_U),\qquad
U_t=\mathrm{RN}(U_0+\mathrm{RN}(fV)),
```

```math
V_0=\mathrm{RN}((-S_M)+F_V),\qquad
V_t=\mathrm{RN}(V_0-\mathrm{RN}(fU)).
```

Store $`U_t,V_t,U_0,V_0`$ in PTNDU, PTNDV, PTNDU_NOC and PTNDV_NOC. The physical-coordinate units are metres per second for wind, metres per second squared for pressure and output acceleration, inverse seconds for $`f`$ and $`r`$, and dimensionless values for north components. Preserve the caller's shared coordinate scaling. Forbid fusion, reassociation, approximate operations and fast-math. Preserve signed zeros, gradual underflow and FPCR.

## Storage and accepted inputs

NPROMA is positive, NFLEVG is nonnegative, and 1 <= KST <= NPROMA with KST - 1 <= KPROF <= NPROMA. Empty intervals and zero levels change no output. PGMV has shape (NPROMA,NFLEVG,NDIMGMV), and each selected wind index lies between 1 and NDIMGMV. Both pressure inputs and all four outputs have shape (NPROMA,NFLEVG). PRCORI and the two north arrays have length NPROMA. Array entries use aligned FP64 values in Fortran order, with the column varying first. Extents and address arithmetic fit signed 64-bit values.

When damping is enabled, its contiguous RKRF allocation covers indices 1 to NFLEVG. Its lower bound may be below 1. Every used input and required intermediate is finite, and damping rates are nonnegative. Directional physical cases use a unit north vector. Numerical edge checks may use other finite components to test rounding. With damping disabled, its allocation may be absent. The two north arrays may be absent outside the tilted branch. With no active entry, explicit numerical input arrays may be absent. An enabled coefficient allocation must still cover every level because the source prepares level coefficients even for an empty column interval.

All four outputs are separate from each other, all inputs and all objects. Only active columns change. Other output bytes remain untouched. Geometry, GMV, dynamics, physics, the coefficient allocation and all input arrays remain unchanged. Independent columns may use NEON pairs with an in-bounds scalar tail. Complete assembly can keep local damping values in registers rather than create the reference's temporary arrays.

## GNU Fortran interface

Export gp_tndlagadiab_uv_ on AArch64 for GNU Fortran 12.3. Registers x0 to x7 hold YDGEOMETRY, YDGMV, YDEPHY, YDDYN, KST, KPROF, PRCORI and PGNORDL. Incoming stack offsets 0, 8, 16, 24, 32, 40, 48 and 56 hold PGNORDM, PSGRTL, PSGRTM, PGMV, PTNDU, PTNDV, PTNDU_NOC and PTNDV_NOC. Every argument is an address. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

A storage-only probe measured the GNU layout. GEOMETRY occupies 17,096 bytes, with NPROMA at 5,144, NFLEVG at 5,224 and NSTTYP at 7,520. TGMV occupies 1,560 bytes, with NDIMGMV at 992 and YT0's MU and MV at 1,012 and 1,016. TDYN occupies 4,720 bytes, with LRFRIC at 2,132 and LRFRICISOTR at 2,136. Its RKRF descriptor begins at 2,368. Relative descriptor offsets 0, 8, 40, 48 and 56 hold the data pointer, element offset, unit stride, lower bound and upper bound. The contiguous element size and span are 8 bytes. The first used level is data plus 8 times (1 - lower bound). TEPHY occupies 448 bytes, with LEGWWMS at 24. Read LRPLANE from __yomct0_MOD_lrplane. Re-measure all layouts for another compiler or configuration.

## Verification and canonical bytes

Compare all output bits against unchanged strict-source Fortran. Independently check pressure-only forcing, Coriolis work, equal damping, directional damping and the sign of its kinetic-energy change. Include all branch priorities, plane and tilted-sphere selection, disabled damping with absent coefficients, unused north arrays, alternate wind indices, coefficient lower bounds below 1, zero rates and forces, partial and empty intervals, zero levels, odd widths, signed zeros, subnormal arithmetic, separate-rounding witnesses, read-only inputs and final protected-page tails.

Canonical small-check files concatenate complete PTNDU, PTNDV, PTNDU_NOC and PTNDV_NOC arrays in that order, including guards, as little-endian FP64. A protected-tail buffer has only a leading guard. Require zero differing bytes, unchanged FPCR, unchanged inputs and correct guards. Report the first case, mode, field, level, column and both bit patterns on mismatch.

Each forecast record begins with uint64 call number, int32 forecast step and twelve int32 values in the order NPROMA, KST, KPROF, NFLEVG, NDIMGMV, MU, MV, LRFRIC, LRFRICISOTR, LEGWWMS, LRPLANE and NSTTYP, followed by int64 coefficient lower and upper bounds. This fixed header occupies 76 bytes. Disabled damping or zero levels record zero bounds. Output records append complete PTNDU, PTNDV, PTNDU_NOC and PTNDV_NOC buffers. Input records append their incoming bytes in that order, then complete PRCORI, PSGRTL, PSGRTM and PGMV buffers when the interval and levels are nonempty, the two complete north arrays only for an active tilted branch, and coefficients at levels 1 to NFLEVG whenever damping is enabled and levels are nonempty. Exclude pointer addresses, clocks, padding and all output normalisation. Call complete Fortran on copied outputs and complete assembly on actual outputs. The driver supplies no numerical stage.

## Provenance

Emit assembly directly from this contract and build it with an assembler and linker. The probe measures storage only. Inspect compiler-generated solver instructions only after assembly emission for verification. Preserve source, contract, probe, assembly, verifier and raw trajectory hashes. Add only positive optimisation lessons supported by repeated quiet-node measurements.
