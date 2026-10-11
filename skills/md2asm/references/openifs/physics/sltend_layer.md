# Slow-Physics Record Interface

Revision 1 freezes the complete SLTEND_LAYER interface. A record groups related arrays and the information that describes their sizes. This interface reads the model records and passes their complete arrays to [slow-physics averaging](sltend.md). That child calculates every numerical stage. The physical inputs remain [state increments](../../../../../formulations/openifs/physics/physics_increment.md) and [cloud supersaturation](../../../../../formulations/openifs/physics/cloud_supersaturation.md).

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

Support 0 to 4096 columns, 0 to 512 levels, 3 to 64 saved-rate planes, 0 to 64 constituent planes and 0 to 128 extra-field planes. Select columns from one through an endpoint between zero and $`N`$. Whole-array lower bounds can vary when their extents and contiguous strides remain valid. Interface pressure has one more level than the ordinary fields.

The measured records occupy 192 bytes for dimensions, 1,240 bytes for each state record, 1,992 bytes for auxiliary pressure, 376 bytes for previous rates and 13,680 bytes for surface fields. The model occupies 4,275,088 bytes and stores NVTEND at byte 1,577,520. Each caller must retain the complete valid nested model metadata required by SLTEND.

The wrapper checks record addresses, dimensions, consumed descriptor types, extents, strides, data alignment and address overflow before calling its child. Invalid controls stop before output writes. The caller must provide disjoint complete mutable owners and valid physical inputs as required by the child. The paired verifier checks those shared preconditions before the original and direct calculations.

## Generation And Evidence

The source interface and the unchanged child physics passed before direct emission. Ten protected original calls cover 391,680 complete output bytes and 8,246 independent relations. Ten direct calls preserve exactly the same bytes, fresh numerical flags and errno. Both buffer edges, shifted lower bounds, partial columns, empty intervals, zero levels and enabled diagnostic budgets pass.

Six paired calls, including a profiling-enabled caller, compare 218,688 complete bytes with zero differences and 4,620 independent relations. Fourteen new descriptor and machine-state rejection checks preserve 319,872 shared output bytes. The unchanged complete child proofs cover its numerical arithmetic, physical relations and supported maximum sizes.

The wrapper was written directly as AArch64 assembly and built with an assembler and linker. It links the unchanged complete direct SLTEND child, whose numerical children and mathematical helper are qualified assembly. The native route imports no OpenIFS Fortran numerical symbol, uses no compiler-generated assembly and has no omitted numerical stage supplied by a driver.

Actual forecast acceptance and speed measurements remain pending. This wrapper is not an additional routine in the audited 255-routine weather queue. Its local checks help replace the original record interface, while full forecast autonomy still requires removal of the remaining Fortran calculations and orchestration.
