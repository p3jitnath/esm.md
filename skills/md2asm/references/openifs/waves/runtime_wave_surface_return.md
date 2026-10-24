# Runtime Wave Surface Return

WVRG2XF returns local wave-model values to the atmosphere's blocked surface fields. This wrapper restores the original two profiling calls around the accepted [bit-copy calculation](returned_surface_field_copy.md). Profiling records where a program spends time. The public FIAT library provides these calls, while assembly owns their arguments and order. No wave equation is calculated here, and this component does not select a permitted WAM library boundary.

The source is [runtime_wave_surface_return.S](../../../../../src/openifs/waves/runtime_wave_surface_return.S), from `arpifs/phys_ec/wvrg2xf.F90` and the [wave formulation](../../../../../formulations/openifs/waves/ocean_waves.md). The entry `md2asm_runtime_return_wave_surface_fields` returns an integer status. Its six address arguments use registers x0 through x5. The first five retain the original source order.

| Register | Argument |
| --- | --- |
| x0 | TSURF surface record, 18224 bytes |
| x1 | Read-only wave-field array |
| x2 | Read-only four-byte field count |
| x3 | Read-only four-byte local point count |
| x4 | Read-only four-byte block width |
| x5 | Read-only 24-byte context |

Context words at bytes zero and eight give the complete surface-record and input-field capacities. Byte 16 holds the address of a false four-byte hook flag, aligned to eight bytes. A hook is an optional call for recording program activity. This route supports a disabled hook. The context and FP64 owners are eight-byte aligned, and scalar counts are four-byte aligned. Every consumed span is mapped and nonwrapping. Keep all records, field metadata and complete arrays alive and disjoint from returned storage through the call.

The caller establishes the complete accepted leaf contract before entering this wrapper. It admits one through nine fields, zero through 6599680 local points and a block width from one through 1024. Live count arguments select the shape without rebuilding the solver or main Fortran reference. Dense destination descriptors and the field-selection map retain the leaf's bounds. Each input field has one FP64 value per local point, stored in column order. The copy preserves its physical units and every stored bit, including signed zeros, subnormal values and NaN payloads.

The call order is FIAT `GSTATS(1426,0)`, the unchanged direct copy leaf, then `GSTATS(1426,1)`. Assembly stores the event number and switches in read-only data. The parent performs no floating-point arithmetic or allocation. Its 96-byte stack frame preserves x18, x19 through x29, the return address and the low halves of v8 through v15, with sixteen-byte stack alignment. FPCR, the floating-point control register, must be zero. FIAT owns only its public profiling internals and must first receive valid public-library configuration. This gate uses the actual eighteen-address `gstats_setup_` interface for a one-process map and disabled statistics. Enabled profiling and enabled hooks remain outside its accepted scope.

Return zero after a complete copy. Return two before public calls for an invalid checked pointer, alignment, wrapping scalar or context span, enabled hook, or nonzero FPCR. Mapping validity and complete leaf preconditions remain caller obligations. A child refusal preserves the destination and still receives both profiling boundaries, so this wrapper does not promise that every refusal leaves profiling state unchanged.

Two new original-source, two production and two observed wrapper calls pass a small remapped partial block and an empty interval. Each route compares all 1024 destination bytes exactly, including unused columns and final padding. The three routes pass 171 independent bit assignments in total. Complete input, metadata and guard bytes remain unchanged, and native ABI masks are zero. Raw FPCR zero, FPSR 24 and errno 777 agree without adjustment. The observed calls record exactly event 1426 with switches zero then one and see the destination before and after its actual copy. Seven new refusal cases preserve their complete destination and guards. Six stop before profiling, while a short-field child refusal retains the paired profiling calls.

The production jump slot resolves directly to the actual FIAT library. Its dependency list contains no original OpenIFS library. The complete accepted copy object is reused, with its earlier operational-point-count, independent-bit, ABI and refusal evidence, without repeating that large bank. The original reference hook is explicitly disabled to match the declared source case. No main Fortran rebuild, WAM numerical call, complete coupled forecast or comparative timing is claimed.
