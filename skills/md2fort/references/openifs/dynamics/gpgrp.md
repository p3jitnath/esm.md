# OpenIFS GPGRP contract

Contract revision 1.0 freezes the complete GPGRP body in OpenIFS 48.1.1. The physical input is [pressure force](../../../../../formulations/openifs/dynamics/pressure_force.md), revision 1.0. GPRT supplies the thermal product and its gradients, while GPHPRE and GPGRXYB supply the layer coefficients. GPGRP supplies the positive gradient used with a negative sign in the wind equation.

## Method and arithmetic

The upstream geometry selects either conventional layers or finite elements, which describe the vertical field with smooth functions. Preserve that selection and the supplied coefficients. This pointwise calculation introduces no new grid or time step. FP64 denotes 64-bit floating-point values. RN64 rounds to nearest FP64 with ties to an even final bit.

For conventional layers, calculate both horizontal directions with these separate rounding points. H denotes RT, G denotes its supplied horizontal derivative, B is the geopotential gradient at the lower layer boundary, alpha is the layer coefficient and D is the supplied derivative of alpha plus log pressure.

```math
a=\operatorname{RN}_{64}(\alpha G),\qquad
b=\operatorname{RN}_{64}(DH),\qquad
c=\operatorname{RN}_{64}(a+b),\qquad
S=\operatorname{RN}_{64}(B+c).
```

The earlier Fortran copy of B to the output may be combined with this calculation because the inputs and outputs do not overlap. Do not change the inner sum's parentheses.

For finite elements, B is the full-level geopotential gradient, C is M_RTGR and P is the supplied surface-pressure gradient. Preserve the following product order.

```math
a=\operatorname{RN}_{64}(HC),\qquad
b=\operatorname{RN}_{64}(aP),\qquad
S=\operatorname{RN}_{64}(B+b).
```

H uses m²/s², alpha has no unit, D has inverse horizontal-coordinate units and C has Pa⁻¹. P uses Pa per unit of the horizontal coordinate. B, G and S use m²/s² per unit of that coordinate. Keep the forecast's coordinate scaling. Forbid fusion, reassociation, approximate arithmetic and fast-math, preserving signed zeros and gradual underflow.

## Storage and input rules

The geometry supplies positive NPROMA and nonnegative NFLEVG. Require 1 <= KST <= NPROMA and KST - 1 <= KEND <= NPROMA. Zero levels or an empty interval change no output. All arrays use 8-byte-aligned FP64 values in Fortran order, with extents and addresses that fit signed 64-bit arithmetic. Every used input and required intermediate is finite. Gradients may have either sign.

PRT, PRTL, PRTM, PHIFL, PHIFM, PSGRTL and PSGRTM have shape (NPROMA,NFLEVG). PREL and PREM have NPROMA entries. PHIHL and PHIHM have shape (NPROMA,0:NFLEVG), and the conventional calculation uses rows 1 to NFLEVG. PXYB and PXYBDER have shapes (NPROMA,NFLEVG,NDIM), with their own configured NDIM values. Every used field index is a positive integer within its corresponding NDIM. Read indices from the upstream module objects, rather than assuming one field order.

The conventional mode uses PRTL, PRTM, M_ALPH, M_ALPHPLL, M_ALPHPLM, PHIHL and PHIHM. The finite-element mode uses PREL, PREM, M_RTGR, PHIFL and PHIFM. PRT is used in both modes. Inputs unused by the selected mode may be absent and must not be read. Both outputs are separate from every input and each other. Inactive entries retain their incoming bits. Inputs, geometry and field-index objects remain read-only. Vector pairs operate only on independent columns, with an in-bounds scalar tail.

## GNU Fortran interface

Export gpgrp_ for GNU Fortran 12.3 on AArch64. Registers x0 to x7 hold YDGEOMETRY, KST, KEND, PRT, PRTL, PRTM, PREL and PREM. Incoming stack offsets 0, 8, 16, 24, 32, 40, 48 and 56 hold PXYB, PXYBDER, PHIHL, PHIHM, PHIFL, PHIFM, PSGRTL and PSGRTM. All arguments are addresses, and integers and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Exclude profiling hooks from the numerical body.

The independently compiled layout probe measures a 17,096-byte geometry object. NPROMA is at byte offset 5,144 and NFLEVG at 5,224. Its configuration pointer is at 3,264. The pointed-to 216-byte TCVER object has LVERTFE at offset 52. The 32-byte __intdyn_mod_MOD_yytxyb object has M_ALPH at 12, M_RTGR at 16 and NDIM at 28. The 40-byte __intdyn_mod_MOD_yytxybder object has M_ALPHPLL at 16, M_ALPHPLM at 20 and NDIM at 36. These offsets apply only to the frozen build and must be measured again for another compiler or configuration.

## Verification and output

Compare the complete body with unchanged strict-source Fortran. Independently check zero gradients, constant pressure gradients, sign changes and product-rule balances. Cover both modes, alternate valid field indices, partial and empty intervals, zero levels, odd widths, a final-column tail, signed zeros, subnormal inputs, separate-rounding witnesses and protected input pages. Require zero differing bytes for both complete output arrays, including inactive entries and guards, and unchanged input bytes. Report the first case, direction, level, column and both bit patterns on a mismatch. Check FPCR before execution and after return.

Canonical small-check files concatenate both output buffers and their leading and trailing guards in case order as little-endian FP64. Protected-tail cases have only a leading guard because the next address is an inaccessible page. Forecast records contain call number, step, dimensions, selected mode, field indices and both complete outputs. Input records preserve all used inputs and incoming outputs, with pointer addresses and timing excluded. Each record's 104-byte header contains an 8-byte call number, 4-byte step, four 4-byte dimensions, a 4-byte mode, the eight 4-byte PXYB index values and ten 4-byte PXYBDER index values. Input records append both incoming outputs and then the used arrays in argument order. The mode identifies the used arrays. The forecast comparison calls the full assembly and Fortran bodies on separate outputs and supplies no omitted numerical stage.

## Provenance

Emit assembly directly from this contract and build it with an assembler and linker. The Fortran layout probe measures storage only. Compiler-generated solver instructions must not be used for assembly generation. Archive source, contract, assembly, layout, verifier and output hashes. Accept performance or skill lessons only after repeated quiet-node measurements.
