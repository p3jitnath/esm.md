# OpenIFS GPGRXYB contract

Contract revision 1.2 freezes the complete GPGRXYB body in OpenIFS 48.1.1. Its physical input is [pressure-gradient coefficients](../../../../../formulations/openifs/dynamics/pressure_gradient_coefficients.md), revision 1.0. The upstream pressure stage supplies the layer quantities. GPGRXYB calculates their horizontal pressure weights and gradients without recalculating pressure or advancing time.

## Supplied quantities and method

Let $`p_u,p_l`$ be positive upper and lower boundary pressures, $`p_f`$ the supplied full-level pressure, and $`\Delta p=p_l-p_u`$. All pressures use pascals. The hybrid coefficients give $`\Delta B=B_l-B_u`$ and $`C=A_lB_u-A_uB_l`$. $`\Delta B,B_l`$ are dimensionless, while $`C`$ uses pascals.

| PXYB field | Symbol | Units | Role |
| --- | --- | --- | --- |
| M_RDELP | $`e`$ | 1/Pa | Reciprocal layer pressure depth |
| M_LNPR | $`d`$ | 1 | Selected pressure depth weight |
| M_RPP | $`q`$ | 1/Pa² | Reciprocal boundary-pressure product |
| M_ALPH | $`a`$ | 1 | Selected full-level pressure weight |
| M_RTGR | $`t`$ | 1/Pa | Selected pressure-gradient coefficient |
| M_RPRE | $`h`$ | 1/Pa | Reciprocal lower boundary pressure |

The finite-element mode represents vertical variation with basis functions. It supplies $`d=\Delta p/p_f`$ and $`t=B_f/p_f`$. Conventional mode NDLNPR=0 supplies $`d=\log(p_l/p_u)`$, $`a=1-p_ud/\Delta p`$ and $`t=\Delta B/\Delta p+Cd/(\Delta p)^2`$. Modes 1 and 2 use the upstream approximate pressure weights, with the same GPGRXYB arithmetic for their normal interior layers. The source's top-boundary closure remains part of the upstream pressure stage.

## Ordered arithmetic and outputs

FP64 denotes 64-bit floating-point values. RN rounds to nearest FP64 with ties to an even final bit. The finite-element mode uses

```math
D=\mathrm{RN}(\mathrm{RN}(\mathrm{RN}(\Delta B\,e)-t)d).
```

Every conventional mode uses $`D=\mathrm{RN}((-C)q)`$. With NDLNPR=0, calculate $`P=\mathrm{RN}(B_lh)`$ and $`A=\mathrm{RN}(P-t)`$. With NDLNPR=1 or 2, calculate $`A=\mathrm{RN}(\mathrm{RN}(Da)/d)`$ and $`P=\mathrm{RN}(A+t)`$. Preserve unary negation and every intermediate rounding point. Denominators used by the approximate modes are nonzero.

PREL and PREM are the supplied surface-pressure gradients in the two horizontal directions. Store RN(D PREL) and RN(D PREM) in M_LNPRL and M_LNPRM. If LDCOEF is true, also store D in M_COEFD. Conventional modes then store RN(P PREL), RN(P PREM), RN(A PREL) and RN(A PREM) in M_ALPHPLL, M_ALPHPLM, M_ALPHL and M_ALPHM, in that order. If LDCOEF is true, store A and P in M_COEFA and M_COEFAPL. The finite-element mode leaves all alpha-related outputs untouched. A, P and D use inverse pascals, while the gradient units follow the supplied horizontal coordinate.

Forbid fusion, reassociation, approximate division and fast-math. Preserve signed zeros, gradual underflow and FPCR. Output fields used by a call have distinct valid indices. Independent columns may use NEON pairs with an in-bounds scalar tail. Per-cell fusion may retain coefficients in registers because outputs are not inputs and each cell keeps the source's store order.

## Shapes and storage

NPROMA is positive, KFLEV is nonnegative, and 1 <= KD <= NPROMA with KD - 1 <= KF <= NPROMA. Empty intervals and zero levels change no array. PREL and PREM have length NPROMA. PXYB and PXYBDER use caller-supplied field capacities, with shape (NPROMA,KFLEV,capacity). These capacities need not equal the routine's module field counts when optional fields are unused. The active forecast caller CPG_GP_HYD allocates PXYB0 with YYTXYB0%NDIM and ZXYBDER0 with YYTXYBDER0%NDIM. Each used field index must fit both the module count and the actual caller capacity. Capture the complete actual allocation, including every unused field inside it. Entries are aligned FP64 values in Fortran order, with column varying first. Extents and address arithmetic fit signed 64-bit values.

Use VDELB only in finite-element mode, VC in every conventional mode, and VBH only for conventional NDLNPR=0. Each used contiguous allocation covers indices 1 to KFLEV, allowing a lower bound below 1. Unused allocations may be absent. All used field indices lie inside their declared field counts, while unused indices may be invalid and must not select data. Conventional NDLNPR is 0, 1 or 2. Finite-element mode ignores NDLNPR. All used inputs and required intermediates are finite. Explicit arrays and coefficient allocations may be absent when no entry is active.

Output storage is separate from every input and configuration object. Only active columns and selected fields change. Other output bytes remain untouched. All inputs, allocation descriptors and module index objects remain unchanged.

## GNU Fortran interface

Export gpgrxyb_ on AArch64 for GNU Fortran 12.3. Registers x0 to x7 hold KPROMA, KD, KF, KFLEV, LDCOEF, YDVAB, YDCVER and PREL. Incoming stack offsets 0, 8 and 16 hold PREM, PXYB and PXYBDER. All arguments are addresses. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

The storage-only probe measures TVAB as 512 bytes and TCVER as 216 bytes. LVERTFE is at byte offset 52 and NDLNPR at offset 4 in TCVER. The VBH, VC and VDELB descriptors start at TVAB byte offsets 64, 192 and 448. The input and output index objects occupy 32 and 40 bytes. TVAB's eight allocation descriptors use the measured GNU rank-one layout. Each descriptor contains its data pointer at offset 0, element offset at 8, 8-byte element length and span, unit stride at 40, lower bound at 48 and upper bound at 56. The first used value is data plus 8 times (1 - lower bound). Read field indices from __intdyn_mod_MOD_yytxyb and __intdyn_mod_MOD_yytxybder. Re-measure object layouts for another compiler or configuration.

## Independent science and exact bytes

Check finite-element depth gradients by the quotient rule and conventional logarithmic depth gradients by the derivative of log pressure. Check NDLNPR=0 alpha and full-level terms from their hydrostatic definitions. Approximate modes use pressure weights that approach continuum derivatives as layers become thin. For normal interior pressures, define $`z=\sqrt{p_u/p_l}`$, $`E=(1-z)/(1+z)`$ and $`D_*=B_l/p_l-B_u/p_u`$. The exact derivative of their approximate depth weight is $`(z+1/z)D_*/2`$. Their prescribed depth coefficient differs from this derivative by $`-(1-z)^2D_*/(2z)`$. Check the derivative independently by perturbing surface pressure by 1/32 Pa on each side of its supplied value, with a derivative tolerance of 1e-18 1/Pa plus 1e-10 times its magnitude. Check that the prescribed derivative difference tends to zero for thin layers. Their alpha coefficient differs from the derivative of $`1-z`$ by $`zED_*/2`$. Their combined coefficient differs from the derivative of $`1-z+\log\sqrt{p_up_l}`$ by $`(1-z)D_*/2`$. Check these independently derived errors and their thin-layer limits. The independent derivative tolerance is 1e-16 in the output's units plus 1e-12 times the expected magnitude. Exact Fortran agreement still permits zero differing bits. This stage's checks do not establish every upstream top-boundary closure or whole-forecast science.

Compare every output bit with unchanged strict-source Fortran. Include all three conventional modes and finite-element mode, both LDCOEF values, alternate field maps, unused invalid indices and absent allocations, lower bounds 1, 0 and -1, partial and empty intervals, zero levels, odd widths, signed zeros, subnormals, separate-rounding witnesses, read-only pages and final protected tails. Require zero differing bytes, correct guards, untouched fields and unchanged FPCR. Report the first case, mode, field, level, column and both bit patterns on failure.

Canonical small-check files concatenate the complete PXYBDER buffer, including guards, as little-endian FP64 in Fortran field order. Protected-tail buffers have only a leading guard. Each forecast record begins with uint64 call number, int32 forecast step, seven int32 values in NPROMA, KD, KF, KFLEV, LVERTFE, NDLNPR and LDCOEF order, two int32 actual input/output field capacities, the eight-int32 input-index object, the ten-int32 output-index object, and six int64 coefficient bounds in VDELB, VC and VBH lower/upper order. This fixed header occupies 168 bytes. Unused bounds are zero. Output records append complete PXYBDER arrays. Input records append incoming PXYBDER, then complete PREL, PREM and PXYB arrays when entries are active, followed by each used coefficient's values at levels 1 to KFLEV in VDELB, VC and VBH order. Exclude addresses, clocks, padding and normalisation. The driver compares complete routines on separate outputs and supplies no numerical stage.

## Provenance

Emit assembly directly from this contract and build it with an assembler and linker. The independent probe measures storage only. Inspect compiler-generated solver instructions only after emission for verification. Preserve source, contract, probe, assembly, verifier and raw trajectory hashes. Add only positive optimisation lessons supported by repeated quiet-node measurements.
