# OpenIFS GPADDSLPHY contract

Contract revision 1.0 freezes the complete GPADDSLPHY body in OpenIFS 48.1.1. Its physical input is [physics increments](../../../../../formulations/openifs/physics/physics_increment.md), revision 1.0. This routine adds known physical rates to the state buffers used by the transport step. It does not calculate the rates or carry out transport.

## Complete update

FP64 denotes 64-bit floating-point values. RN64 rounds to the nearest FP64 value with ties to an even final bit. If LDLFSTEP is true, leave all output bytes unchanged and access no rate buffer. Otherwise, visit levels 1 to NFLEVG and columns KST to KEND. MU_SAVTEND, MV_SAVTEND and MT_SAVTEND select the wind and temperature fields of PSAVTEND. For each field, use the following two rounding points.

```math
p=\operatorname{RN}_{64}(S_X\,\mathrm{PTMST}),\qquad
X'=\operatorname{RN}_{64}(X+p).
```

Visit YCOMP descriptors in increasing order. If LPHY is true, MPSLP selects the same field in PGFLSLP and PSLB1GFL0. Apply the same rounded multiplication and addition. Inactive descriptors change no tracer output. Preserve repeated MPSLP mappings, so that each selected descriptor adds its own rounded increment to the current output.

Wind states use metres per second, temperature uses kelvin and mass fractions use kilograms per kilogram. Input tendencies use the corresponding units per second. Other configured tracers retain their caller units. Forbid fused arithmetic, reassociation, approximate operations and fast-math. Preserve signed zeros, gradual underflow and FPCR.

## Storage and accepted inputs

NPROMA is positive, NFLEVG is nonnegative, and 1 <= KST <= NPROMA with KST - 1 <= KEND <= NPROMA. NFLSA <= 1 and NFLEN >= NFLEVG. Let NS = NFLEN - NFLSA + 1. It is nonnegative. The three wind and temperature outputs have shape (NPROMA,NS), with the second index beginning at NFLSA. PSLB1GFL0 has shape (NPROMA,NS,NDIMSLP). PGFLSLP has shape (NPROMA,NFLEVG,NDIMSLP), and PSAVTEND has shape (NPROMA,NFLEVG,NVTEND). Each output's first active level therefore begins NPROMA times (1 - NFLSA) entries after its base address.

All arrays use 8-byte-aligned FP64 values in Fortran order, with column varying first. Extents and address arithmetic fit signed 64-bit values. NUMFLDS lies between 0 and 2163, and NDIMSLP is nonnegative. With an active update, NVTEND is positive and each used wind or temperature index lies between 1 and NVTEND. Each active LPHY descriptor has 1 <= MPSLP <= NDIMSLP. Inactive descriptors may contain unused invalid indices. PTMST is finite and nonnegative, and used inputs and all required intermediates are finite.

Output buffers are separate from each other, all rate buffers and all configuration objects. Only levels 1 to NFLEVG, active columns and selected tracer fields change. Leading and trailing vertical boundary storage, inactive columns and unselected tracers retain their incoming bits. Geometry, configuration, descriptors and rates remain unchanged. Empty buffers and unused rates may be absent when the selected mode accesses no entry. Independent columns may use NEON pairs with a bounded scalar remainder.

## GNU Fortran interface

Export gpaddslphy_ on AArch64 for GNU Fortran 12.3. Registers x0 to x7 contain YDGEOMETRY, YDSLPHY, YGFL, LDLFSTEP, KST, KEND, PTMST and PSAVTEND. Incoming stack offsets 0, 8, 16, 24 and 32 contain PGFLSLP, PSLB1U0, PSLB1V0, PSLB1T0 and PSLB1GFL0. Every argument is an address. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

A storage-only Fortran probe measured these offsets. GEOMETRY occupies 17,096 bytes, with NPROMA at 5,144, NFLEVG at 5,224, NFLSA at 5,244 and NFLEN at 5,248. TSLPHY occupies 360 bytes, with NVTEND at 64, MU_SAVTEND at 344, MV_SAVTEND at 348 and MT_SAVTEND at 352. TYPE_GFLD occupies 1,359,136 bytes, with NUMFLDS at 0 and NDIMSLP at 72. YCOMP starts at 3,848, with 368 bytes per component, LPHY at 100 and MPSLP at 204. Re-measure these values for another compiler or configuration.

## Verification and canonical bytes

Require zero differing bytes against unchanged strict-source Fortran. Independently check zero rates, constant heating and wind increments, tracer increments and a short repeated constant-rate trajectory. Include both first-step modes, absent unused rates, alternate field maps, repeated tracer mappings, inactive descriptors with invalid unused indices, no tracers, lower and upper vertical boundary storage, zero levels, empty and partial intervals, odd widths, signed zeros, subnormal arithmetic and a separate-rounding witness. Use read-only input pages and inaccessible pages after final tails.

Canonical small-check files concatenate complete PSLB1U0, PSLB1V0, PSLB1T0 and PSLB1GFL0 arrays in that order, with guards, as little-endian FP64. A protected-tail array has only a leading guard. Check inactive outputs, vertical boundaries, input bytes, guards and FPCR. Report the first case, field, tracer, level, column and both bit patterns on failure.

Each forecast record begins with uint64 call number, int32 forecast step and ten int32 values in the order NPROMA, KST, KEND, NFLEVG, NFLSA, NFLEN, NVTEND, NDIMSLP, NUMFLDS and LDLFSTEP, followed by FP64 PTMST and three int32 wind and temperature field indices in MU, MV and MT order. This fixed header occupies 72 bytes. Append NUMFLDS ordered pairs of int32 LPHY and MPSLP. Output records append complete PSLB1U0, PSLB1V0, PSLB1T0 and PSLB1GFL0 arrays. Input records append incoming outputs in that order, then PSAVTEND and PGFLSLP when the update uses them. Include no pointer addresses, clocks, padding, rounding or masking. The driver calls the complete Fortran body on copied outputs and the complete assembly body on the actual outputs, without supplying a numerical stage.

## Provenance

Emit assembly directly from this frozen contract and build it with an assembler and linker. Storage probes supply no numerical update. Compiler-generated solver instructions are used only for verification after emission. Archive the scientific source, contract, probe, assembly, verifier and canonical trajectories with their hashes. Accept optimisation lessons only after repeated quiet-node measurements.
