# Gas Reading And Unit Conversion Contract

Revision 1.0 implements [P01 and P02](../../../../../formulations/openifs/physics/gas_concentration_units.md) for `radiation_gas::get_gas` and `radiation_gas::set_units_gas` in `radiation/module/radiation_gas.F90`. Unit code zero means mass ratio and code one means volume ratio. The direct assembly supplies all requested cells and metadata updates.

## Ordered Conversion

RN means one FP64 operation rounded to nearest, with ties to even. Reuse the unchanged `IGasMolarMass(0:12)` table. The source's air mass uses a default-REAL literal promoted into FP64, with exact bits `0x403cf851e0000000`. This differs slightly from a newly rounded FP64 decimal 28.970 and must be preserved.

For a read, start with the supplied optional scale `a`, or one when absent. For a storage update, start with `RN(1/new_scale)`, or one when the optional new scale is absent. Convert volume to mass as `RN(RN(factor*Mgas)/Mair)`. Convert mass to volume as `RN(RN(factor*Mair)/Mgas)`. When unit codes already match, retain the starting factor. Finally form `factor=RN(factor*stored_scale)`.

A read returns positive zero for an absent gas. Otherwise it copies the selected stored cells exactly when the factor is one, and stores `RN(value*factor)` for every cell when it differs from one. Reading leaves the object unchanged. A storage update does nothing for an absent gas. For a present gas it multiplies every cell in that gas plane when needed, then writes the requested unit code and new storage scale. The default new scale is exactly one.

When the optional gas code is absent in a storage update, visit `icode(1:ntype)` in order and apply the complete single-gas update to each code. This retains the original recursive method's numerical order. Reuse the same rounded reciprocal because every child receives the same new scale. The native base-type body supplies the loop directly. A stored well-mixed flag does not change these calculations, because the original accesses the same allocated concentration plane.

Require FPCR zero, gradual underflow and preserved signed zeros. Fused arithmetic, reassociation and approximate instructions are forbidden. Supported unit codes are zero and one, gas codes are one through 12, and scale factors are finite and positive. Results must remain finite. Optional arguments use null pointers when absent.

## Arm ABI And Owners

The GNU class wrapper contains its data pointer at byte zero and virtual-method table pointer at byte eight. The base gas object has 416 bytes. Its unit codes begin at byte zero, FP64 scales at byte 48, allocated rank-three concentration descriptor at byte 144, presence flags at byte 256, well-mixed flags at byte 304, gas count at byte 352, column count at byte 356, level count at byte 360 and gas-code list at byte 364.

The allocated FP64 array is contiguous with one-based bounds and dimensions `(ncol,nlev,12)`, with column first. Object dimensions agree with the descriptor, and the data pointer is at object byte 144. The caller provides aligned disjoint owners and valid base-type metadata. No derived-type override is supported by this fixed base-type replacement.

The read ABI supplies class, gas-code pointer, unit-code pointer, rank-two output descriptor, optional scale pointer and optional start-column pointer in `x0` through `x5`. The default start column is one. The output level count equals the object's level count, and its columns fit the selected input range. A read destination has at least one column. Zero levels produce an empty numerical owner.

Output descriptors use their first logical cell pointer at byte zero, first stride at byte 40 and second stride at byte 64. A zero first stride means one. Both dimension extents use upper minus lower plus one, clamped to zero. Signed and padded output strides are supported. Only requested cells change, and all holes and neighbours remain unchanged.

The storage-update ABI supplies class, unit pointer, optional gas pointer and optional scale pointer in `x0` through `x3`. Canonical results comprise the complete concentration owner and object metadata. Descriptor and class-routing pointers, flags, counts and gas codes stay unchanged. Both native entries use caller-saved registers only and make no external call, leaving the stack, callee-saved registers and FPCR unchanged.

## Acceptance And Paired Control

Require zero differing bytes across read output owners, updated concentration owners and updated metadata against the strict original. Independent higher-precision checks use molar conservation from P01 and the stored-scale identity from P02, with operation-count rounding bounds and gradual-underflow terms. Cover all gases, both conversion directions, matching units, scale cancellation, absent gases, selected and all-gas updates, signed zero, subnormal values, slices, zero levels and output strides.

The original all-gas update dispatches through a method table. Its local shadow control must use a copied base-type table with the storage-update slot bound to the strict original, so a recursive control call cannot enter the replacement. Temporary shadow routing is outside numerical output and must remain unchanged during each call. Critical acceptance stays separate from live forecast acceptance. Actual records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Critical Results

The critical gas controls passed 384 read cases and 400 update cases over 4,655,904 complete owner and metadata bytes, with zero differences and 79,104 independent mass, mole and scale relations. The paired preload check passed the same cases, including all-gas updates through the strict shadow method table.

## Accepted Forecast Calls

The 2026-10-10 forecast passed get_gas 6,400 calls, set_units_gas 6,400 calls over 103,833,600 complete returned bytes with zero differences. All ten saved files match over 618,140 bytes. It used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child and math checks are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
