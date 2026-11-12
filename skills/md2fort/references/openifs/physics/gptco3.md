# OpenIFS GPTCO3 contract

Contract revision 1.1 freezes the complete GPTCO3 body in OpenIFS 48.1.1. Its physical input is [column ozone](../../../../../formulations/openifs/physics/column_ozone.md), revision 1.0. The model supplies pressure-layer thicknesses and a scalar field. GPTCO3 integrates ozone mass fractions, and CPEDIA also uses the same complete body to integrate signed moisture-change rates. This diagnostic does not advance time.

## Method and ordered arithmetic

Let DP be pressure thickness in pascals, Q the supplied scalar, and G the positive gravitational acceleration in m/s² from __yomcst_MOD_rg. FP64 means 64-bit floating point. RN rounds to nearest FP64 with ties to an even final bit. Calculate I=RN(1/G) once. Set each active output to positive zero, then visit levels 1 to KFLEV in ascending order.

```math
T_j=\mathrm{RN}(\mathrm{RN}(Q_j\,DP_j)I),\qquad M_j=\mathrm{RN}(M_{j-1}+T_j),\qquad M_0=+0.
```

With an ozone mass fraction in kg/kg, the output uses kg/m². With a moisture-change rate in 1/s, the output uses kg/m²/s. Preserve both multiplications, every addition and their rounding points. Forbid fusion, reassociation, approximate division, reduced precision and fast-math. Preserve signed inputs, gradual underflow and FPCR. Independent columns may use NEON pairs with an in-bounds scalar tail. Physical checks use nonnegative mass fractions. The body also supports finite signed tracer entries for diagnostic agreement, without clipping them.

## Shapes and ABI

KPROMA is positive and KFLEV is nonnegative. Require 1 <= KSTART <= KPROMA and KSTART - 1 <= KPROF <= KPROMA. PDELP and PO3 have shape (KPROMA,KFLEV), stored as contiguous FP64 values in Fortran order, with column varying first. PDTCO3 has KPROMA FP64 entries. Buffers are 8-byte aligned, separate, and their extents and address arithmetic fit signed 64 bits. Used inputs and intermediates are finite. Physical layer thicknesses are nonnegative.

Change only columns KSTART to KPROF. Zero levels set active outputs to positive zero without reading PDELP or PO3. An empty interval changes no output. Unused array inputs may be absent. Preserve inactive output bytes and all inputs, including the gravity value.

Export gptco3_ on AArch64 for GNU Fortran 12.3. Arguments x0 to x6 are addresses of KPROMA, KSTART, KPROF, KFLEV, PDELP, PO3 and PDTCO3. Integers use 32 bits and G is an 8-byte module scalar. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

## Verification and bytes

Use unchanged strict-source Fortran as the discrete reference. Require zero differing output bytes, unchanged FPCR, unchanged inputs, correct guards and untouched inactive cells. Check a uniform ozone column independently against Q times total pressure depth divided by G, and check ozone-free columns, nonnegative mass and scaling with Q and G. General profiles use a higher-precision physical integral. Signed moisture-rate checks also compare the column output with the change in independently constructed water inventories over a fixed time interval. Their budget tolerance is 256 times FP64 machine epsilon times the sum of the initial and final water masses, plus 1e-300 kg/m². The physical tolerance is 128 times FP64 machine epsilon times the sum of absolute layer masses, plus 1e-300 kg/m².

Include partial and empty intervals, zero levels, one level, odd widths, the final column, signed zeros, subnormals, signed cancellation and a separate-rounding witness. Read-only input pages and protected final tails check the buffer contract. Report the first case or forecast step, column and both bit patterns on a mismatch.

Small canonical files concatenate complete PDTCO3 buffers with guards as little-endian FP64. Protected-tail buffers have only a leading guard. Each forecast record has uint64 call number, int32 step, four int32 values in KPROMA, KSTART, KPROF and KFLEV order, then the FP64 G value. This header occupies 36 bytes. Outputs append the complete KPROMA-entry PDTCO3 buffer. Input records append incoming PDTCO3, then the complete PDELP and PO3 arrays when levels and columns are active. The caller source and compact record identify the scalar quantity and its units. Keep inactive bytes, exclude padding and addresses, and compare complete routines on separate output buffers. The driver supplies no numerical stage.

Emit assembly directly from this contract and build it with an assembler and linker. Inspect compiler instructions after generation only for verification. Record source, contract, assembly, verifier and forecast-capture hashes. Retain only positive optimisation lessons supported by repeated quiet-node timings.
