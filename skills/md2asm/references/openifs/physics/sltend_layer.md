# Slow-Physics Record Interface

Revision 2 freezes the complete SLTEND_LAYER interface. A record groups related arrays and the information that describes their sizes. This interface reads the model records and passes their complete arrays to [slow-physics averaging](sltend.md). That child calculates every numerical stage. The physical inputs remain [state increments](../../../../../formulations/openifs/physics/physics_increment.md) and [cloud supersaturation](../../../../../formulations/openifs/physics/cloud_supersaturation.md).

## Fields And Output

A tendency is a change per second. Wind tendencies have units m/s², temperature tendencies have units K/s, and moisture tendencies have units s⁻¹. The interface supplies the initial state, dynamics rates, diffusion rates, saturation rates, cumulative rates and previous-step changes. It returns the extra local rates, saved rates and diagnostic fields defined in the unchanged child contract.

Let $`N`$ be the column count and $`L`$ the level count. Columns vary fastest in memory. Ordinary arrays contain $`NL`$ FP64 words, and interface pressure contains $`N(L+1)`$ words. Cloud arrays have five planes. Previous constituent arrays have NDIMSLP planes, saved wind and temperature arrays have NVTEND planes, and extra diagnostics have KFLDX planes. One FP64 word occupies eight bytes.

Compare all ten mutable child owners, including every unused cell and plane. Preserve the model records, dimensions, descriptors and immutable arrays. The output encoding and ordered arithmetic remain those of the complete child. The wrapper performs no floating-point calculation and does not add a time-update stage.

## Arm Interface

The original entry takes 13 address arguments. The direct entry md2asm_sltend_layer takes the same addresses and adds the read-only scalar context defined by SLTEND. This context supplies the current step, cloud-plane identifiers, the gas constant and gravity.

| Argument | Meaning |
| ---: | --- |
| 1 | Model settings |
| 2 | Grid dimensions and selected column interval |
| 3 | Full-level and interface pressure records |
| 4 | Initial physical state |
| 5–8 | Dynamics, diffusion, saturation and cumulative-rate records |
| 9 | Previous-step rate record |
| 10–11 | Saved wind/temperature and constituent arrays |
| 12 | Surface diagnostic record |
| 13 | Returned local-rate record |
| 14 | Read-only child context |

The application binary interface, or ABI, defines arguments and saved registers. The first eight addresses use x0 to x7. Six more addresses use eight-byte caller stack slots. The wrapper uses a 768-byte stack frame and preserves x19 to x29, x18, the low 64 bits of d8 to d15, SP and FPCR. Keep the stack aligned to 16 bytes and FPCR equal to zero. The wrapper preserves incoming numerical status flags and the library error indicator errno through the complete child.

Every record and ordinary buffer starts at an eight-byte aligned address. Supply valid whole records with the measured GNU Fortran FP64 descriptor layout. A descriptor gives the data address, element size, rank, stride and bounds. Rank is the number of array dimensions. Stride gives the distance between successive elements. The element size and span are eight bytes. The first stride is one, the second is $`N`$, and a third stride is $`NL`$.

When KFLDX is zero, only the extra-field descriptor PSD_XA may use a singleton second extent instead of L. Its first extent remains N and its third extent remains zero. The strides still describe its actual contiguous shape: one, N and N times the declared second extent. Thus N×1×0 and N×L×0 are supported. The zero-length data address can be null; the native route maps this unused argument to an aligned read-only dummy address without changing the caller descriptor. Nonempty descriptors keep all original extent, stride, alignment and overflow checks. The unchanged child requires diagnostic storage when its diagnostic controls are enabled; a nonempty calculation with zero extra fields and an enabled diagnostic still rejects before writes.

Support 0 to 4096 columns, 0 to 512 levels, 3 to 64 saved-rate planes, 0 to 64 constituent planes and 0 to 128 extra-field planes. Select columns from one through an endpoint between zero and $`N`$. Whole-array lower bounds can vary when their extents and contiguous strides remain valid. Interface pressure has one more level than the ordinary fields.

The measured records occupy 192 bytes for dimensions, 1,240 bytes for each state record, 1,992 bytes for auxiliary pressure, 376 bytes for previous rates and 13,680 bytes for surface fields. The model occupies 4,275,088 bytes and stores NVTEND at byte 1,577,520. Each caller must retain the complete valid nested model metadata required by SLTEND.

The wrapper checks record addresses, dimensions, consumed descriptor types, extents, strides, data alignment and address overflow before calling its child. Invalid controls stop before output writes. The caller must provide disjoint complete mutable owners and valid physical inputs as required by the child. The paired verifier checks those shared preconditions before the original and direct calculations.

## Generation And Evidence

The source interface and the unchanged child physics passed before direct emission. Ten protected original calls cover 391,680 complete output bytes and 8,246 independent relations. Ten direct calls preserve exactly the same bytes, fresh numerical flags and errno. Both buffer edges, shifted lower bounds, partial columns, empty intervals, zero levels and enabled diagnostic budgets pass.

Six paired calls, including a profiling-enabled caller, compare 218,688 complete bytes with zero differences and 4,620 independent relations. Fourteen new descriptor and machine-state rejection checks preserve 319,872 shared output bytes. The unchanged complete child proofs cover its numerical arithmetic, physical relations and supported maximum sizes.

The wrapper was written directly as AArch64 assembly and built with an assembler and linker. It links the unchanged complete direct SLTEND child, whose numerical children and mathematical helper are qualified assembly. The native route imports no OpenIFS Fortran numerical symbol, uses no compiler-generated assembly and has no omitted numerical stage supplied by a driver.

Actual forecast acceptance and speed measurements remain pending. This wrapper is not an additional routine in the audited 255-routine weather queue. Its local checks help replace the original record interface, while full forecast autonomy still requires removal of the remaining Fortran calculations and orchestration.

## Focused Zero-Plane Correction

The actual batch11r10 interface supplied PSD_XA shape 24×1×0 with KFLDX zero. The original wrapper passes this unused whole array to an explicit zero-plane child array; it does not require the level extent to equal L. Two original-first protected cases then pass shape 7×1×0 with null and nonnull data addresses, 45696 complete fixture bytes and 994 independent relations. Two native cases and two paired cases preserve those same complete bytes, fresh FPSR16, errno73, every record descriptor and the entire extra sentinel allocation. The live pair compares 9856 bytes from its nonempty declared owners; the zero-plane owner contributes zero bytes. A final paired call starts and executes from /tmp with 22848 complete fixture bytes and 497 relations.

Six focused invalid nonempty or empty descriptor cases and two enabled-diagnostic cases preserve every shared caller owner before rejection. The previous complete child, parent arithmetic, maximum-size, profiling and ABI proofs are reused. Only empty metadata admission and its unused pointer mapping changed. The old libraries and ready record remain intact; the immutable correction is .runtime/openifs/slow_physics_layer_7240564/empty-extra-fields-r2/ready.json. No forecast, timing, Git action or count change was performed for this correction.
