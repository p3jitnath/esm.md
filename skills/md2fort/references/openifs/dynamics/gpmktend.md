# OpenIFS GPMKTEND contract

Contract revision 1.0 freezes the complete GPMKTEND body in OpenIFS 48.1.1. Its physical input is [state-change rates](../../../../../formulations/openifs/dynamics/state_rates.md), revision 1.0. The dynamics supplies the later state, and this routine converts its difference from the earlier state into the rate required by the physics.

## Method and arithmetic

Treat the change between the two supplied states as constant over PTSPHY seconds. FP64 denotes 64-bit floating-point values, and RN64 rounds to nearest FP64 with ties to an even final bit. Calculate the reciprocal once, then preserve these two rounding points for each active wind, temperature or selected tracer entry.

```math
r=\operatorname{RN}_{64}(1/\Delta t),\qquad
d=\operatorname{RN}_{64}(X_1-X_9),\qquad
S=\operatorname{RN}_{64}(dr).
```

Overwrite PUT1, PVT1 and PTT1 with their tendencies. Visit YCOMP descriptors in increasing order. When LT1 is true, MP1 selects the later tracer field and MP9_PH selects its earlier field. Update PGFLT1 at MP1 with the same subtraction and multiplication, then copy that rounded value to PGFL_DYN at MP1. An inactive descriptor changes no tracer output. Preserve descriptor order even if two active descriptors select the same later field, because the second update then uses the first update's rounded output.

Inputs use metres per second for wind, kelvin for temperature and kilograms per kilogram for mass-fraction tracers. Outputs have the corresponding unit per second. Other configured tracers retain their own caller units. Preserve signed zeros, gradual underflow and correctly rounded division. Forbid fusion, reassociation, approximate division and fast-math. Replacing reciprocal multiplication with direct division changes the frozen arithmetic.

## Buffers and configuration

The geometry supplies positive NPROMA and nonnegative NFLEVG. Require 1 <= KST <= NPROMA and KST - 1 <= KEND <= NPROMA. Zero levels or an empty interval change no array. PTSPHY is positive and finite, its reciprocal is finite, and every used state and required intermediate is finite.

The six wind and temperature arrays have shape (NPROMA,NFLEVG). PGFL has shape (NPROMA,NFLEVG,NDIM), while PGFLT1 and PGFL_DYN have shape (NPROMA,NFLEVG,NDIM1). Arrays use 8-byte-aligned FP64 entries in Fortran order. Extents and address arithmetic fit signed 64-bit values. NDIM and NDIM1 are nonnegative, and NUMFLDS lies between 0 and 2163. Each active descriptor has 1 <= MP1 <= NDIM1 and 1 <= MP9_PH <= NDIM. Inactive descriptors may contain unused invalid indices, which must not be accessed.

The five output buffers are separate from each other, all read-only inputs and the geometry and descriptor objects. Only active columns and selected tracer fields change. Other output entries retain their incoming bits. With no active tracer, empty tracer buffers must not be read or written. Geometry, descriptors and earlier states remain unchanged. Independent columns may use NEON pairs with an in-bounds scalar tail.

## GNU Fortran interface

Export gpmktend_ for GNU Fortran 12.3 on AArch64. Registers x0 to x7 hold YDGEOMETRY, YGFL, KST, KEND, PTSPHY, PUT1, PVT1 and PTT1. Incoming stack offsets 0, 8, 16, 24, 32 and 40 hold PGFLT1, PUT9, PVT9, PTT9, PGFL and PGFL_DYN. All arguments are addresses. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

The layout probes supply the frozen byte offsets. Geometry occupies 17,096 bytes, with NPROMA at 5,144 and NFLEVG at 5,224. TYPE_GFLD occupies 1,359,136 bytes, with NUMFLDS at 0, NDIM at 48 and NDIM1 at 64. Its fixed YCOMP array starts at 3,848, and each component occupies 368 bytes. LT1 is at component offset 92, MP1 at 188 and MP9_PH at 184. These offsets must be measured again for another compiler or configuration. YGFL is the actual argument object, rather than the address of the module's pointer slot.

## Verification and canonical output

Compare every output byte against unchanged strict-source Fortran. Independently check unchanged states, constant known rates and repeated constant-rate trajectories, with wind, temperature and mass-fraction units distinguished. Include positive and negative changes, non-power-of-two intervals, alternate field maps, active and inactive descriptors, repeated output-field mappings, no tracers, zero dimensions, partial and empty intervals, odd widths, signed zero, subnormal arithmetic and inaccessible pages after final tails.

Check every read-only input, descriptor and geometry buffer, and every inactive output and guard. Require zero differing bytes and unchanged FPCR. Report the first case, field, level, column and both bit patterns on a mismatch. Canonical small-check files concatenate complete PUT1, PVT1, PTT1, PGFLT1 and PGFL_DYN buffers in that order, including guards, as little-endian FP64. Protected-tail buffers have only a leading guard.

For forecast verification, copy all five incoming outputs, call strict Fortran on the copies and call complete assembly on the forecast outputs. Capture both complete result sets without rounding or masking. Each record begins with a 48-byte little-endian header containing the uint64 call number, int32 forecast step, seven int32 values in the order NPROMA, KST, KEND, NFLEVG, NDIM, NDIM1 and NUMFLDS, then FP64 PTSPHY. The header continues with NUMFLDS ordered triples of int32 LT1, MP1 and MP9_PH. Output files append complete PUT1, PVT1, PTT1, PGFLT1 and PGFL_DYN buffers in that order. Input files append their incoming bytes in the same order, followed by complete PUT9, PVT9, PTT9 and PGFL buffers. No padding separates fields. Exclude pointer addresses and clocks. The driver supplies no numerical stage.

## Provenance

Emit assembly directly from this contract and build it with an assembler and linker. The independent Fortran probes measure storage only. Do not use compiler-generated solver instructions for assembly generation. Archive source, contract, assembly, verifier, layout and trajectory hashes. Accept performance lessons only after repeated quiet-node measurements.
