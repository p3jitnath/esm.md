# Additional Physics Work Records

A work record holds temporary arrays and pointer views that select one grid block. These services reproduce the storage methods of seven original types. Forecast calculations that fill those arrays remain unchanged. Values keep the units used by their original producer and consumer. Allocation and descriptor arithmetic use integer instructions.

| Original type | Record bytes | Owned fields and views | Original source |
| --- | ---: | ---: | --- |
| FLUX_TYPE | 5064 | 57 | arpifs/module/ecphys_flux_type_mod.F90 |
| AUX_DIAG_TYPE | 4104 | 49 | arpifs/module/ecphys_aux_diag_type_mod.F90 |
| DDH_SURF_TYPE | 912 | 7 | arpifs/module/ecphys_surface_type_mod.fypp |
| AUX_DIAG_LOCAL_TYPE | 2336 | 27 | arpifs/module/ecphys_aux_diag_type_mod.F90 |
| SURF_AND_MORE_LOCAL_TYPE | 2096 | 20 | arpifs/module/ecphys_surface_type_mod.fypp |
| KEYS_LOCAL_TYPE | 664 | 9 | arpifs/module/ecphys_aux_type_mod.F90 |
| PERTURB_LOCAL_TYPE | 336 | 4 | arpifs/module/ecphys_perturb_type_mod.F90 |

The methods are INIT, UPDATE_VIEW and FINAL. There are 21 methods and 173 owned fields. INIT allocates each field in source order. UPDATE_VIEW associates each public pointer with its selected block. FINAL frees owned storage in its own source order and nulls the field pointer. AUX_DIAG_TYPE has different allocation and finalisation orders, which are kept as separate fixed tables. These seven types have no borrowed field slots. PERTURB_TYPE and its model branches remain outside this batch.

The raw names are `md2asm_<original_type_in_lower_case>_init`, `md2asm_<original_type_in_lower_case>_update_view` and `md2asm_<original_type_in_lower_case>_final`. INIT takes x0 record, x1 Geometry, x2 shape settings and w3 persistent. It returns w0 zero on success or one on allocation failure. UPDATE_VIEW takes x0 record and w1 block index. FINAL takes x0 record. Both return no value. Buffers are mapped, eight-byte aligned and alive for the complete call. Geometry spans 17,096 bytes. The record spans the size above. New INIT calls have no existing live owned allocations. FINAL may follow a partly completed INIT.

Shape settings contain contiguous int32 values. FLUX_TYPE uses NLEV, NLEVS, NACTAERO and NPAERODIAG. AUX_DIAG_TYPE, AUX_DIAG_LOCAL_TYPE and PERTURB_LOCAL_TYPE use NLEV. SURF_AND_MORE_LOCAL_TYPE uses NLEVSN, NTILES, NTSW and NLWEMISS. KEYS_LOCAL_TYPE does not read x2. DDH_SURF_TYPE takes the original DIMENSION_TYPE object through x2. Its individual member offsets and complete object size are recorded in source_tables_and_layout.json. The source constants IKVTYPES, IKDHVVEGS and IKDHFVEGS have the individually queried values two, seven and one.

Block width NPROMA and block count are read from Geometry bytes 5144 and 5160. Both are positive. Persistent is the canonical logical value zero or one. All level and component extents are nonnegative, their int32 sums do not overflow and byte products fit the address space and allocator size. The input block lies from one through the block count. A thread-local field selects its sole stored block. DDH_SURF_TYPE accepts PERSISTENT but does not forward it to CREATE_TEMPORARY. Its seven fields remain thread local for either argument value. This source behaviour is preserved.

A rank-two field stores block width and block count. Rank three adds the level extent. Rank four adds the component extent before block count. Field metadata spans 112 plus 72 times rank bytes. Its PTR and DATA descriptors retain the original GNU layout and contiguous one-based dimensions. Dtype is three for FP64, one for int32 and two for logical32. Numerical bytes are undefined immediately after allocation. The existing numerical producer fills them. No initial weather values are invented.

Fixed source tables list every field and view by its individual typed offset. They retain level and component expressions, allocation order and finalisation order. The private controller accepts only these built-in tables. The accepted registry allocator supplies FP64 fields. Previously qualified int32 leaves supply diagnostic integer fields. A separate logical32 specialization changes only dtype while preserving four-byte elements, flags, shapes and ownership. Its nine logical fields are qualified against genuine original methods.

FLUX_TYPE has 37 views whose second index starts at zero. AUX_DIAG_LOCAL_TYPE has three. Their view offset gains one second-dimension stride, the second lower bound becomes zero and its upper bound decreases by one. Numerical bytes do not change during remapping. PERTURB_LOCAL_TYPE%ZDISSGW requests ZERO=.TRUE. in GET_VIEW. Its method writes positive-zero FP64 bits over that complete selected view, including every allocated row. Other bytes remain unchanged. The enclosing temporary_storage_services control obtains its four perturbation-local views separately and does not call this UPDATE_VIEW method. Its existing route remains a separate context responsibility.

Native entries retain original module symbols and argument order. SELF is a GNU class descriptor whose first word points to the record. REGISTRY starts with its Geometry pointer. Scalar integer arguments and optional PERSISTENT are passed by address. Missing PERSISTENT selects false. DDH_SURF_TYPE ignores its value as described above. All seven INIT interfaces use at most seven register arguments. UPDATE_VIEW receives SELF and a block-index pointer. FINAL receives SELF. The native INIT adapter uses a 64-byte frame with 16-byte stack alignment and aborts after a nonzero raw return. No original procedure fallback is used.

The private raw controller uses a 192-byte frame with 16-byte stack alignment. It preserves x18, x19 through x29, the return address, FPCR, FPSR and errno around allocation, views and cleanup. INIT failure frees every created owner and metadata, then returns one. Genuine original methods are built without reserving x18 and can change it under their original platform ABI. Verification records that returned value separately. Both routes return the same FPCR, FPSR and errno. Every direct raw and native route preserves incoming x18.

No type here has a nonzero declared default. AUX_DIAG_LOCAL_TYPE declares ZRAINFRAC_TOPRFZ null, with its descriptor base at byte 200. IEXT3D has no declared value and is not written by these methods. Caller construction must retain the null declaration and must not describe source-undefined metadata as physical zero data. An assembly-owned fresh context may clear its metadata before INIT. Each method leaves record bytes outside its source write set unchanged.

The counter object `md2asm_additional_work_record_native_counters` holds 21 uint64 words in the type order above, with INIT, UPDATE_VIEW and FINAL for each type. Only native adapters increment them. These private field-view leaves do not call the existing physics state-view counter route. A forecast must establish actual calls before selecting its counter gate. The enclosing context can leave PERTURB_LOCAL_TYPE UPDATE_VIEW at zero through its explicit source route.

The critical check uses three cases per type. It covers absent optional PERSISTENT, a persistent 24 by 19 by 86 owner ending at the final block and empty extents. It compares complete defined PTR and DATA headers, flags, views, unchanged record bytes, every numerical owner byte, all inputs and guards. Distinct allocations are related by corresponding owner addresses. No numerical byte is masked or repaired. Verification-only markers fill both new owners before checking views. The perturbation zero request is compared with its complete expected write extent.

The retained result has 21 passing source cases and 126 immediate source or direct ABI calls, with zero defined metadata or numerical differences. Source status is observed separately. The original source can change x18 under its platform ABI. Direct entries preserve that register. Independent source review and the selected complete forecast check pass. Build commands, original controls and typed queries remain local beside this contract.

The forecast uses initialization and release for the perturbation-local record and all three methods for the other six records. Its four manual perturbation views use separate view leaves. The perturbation-local update has standalone checks only and is not counted as a forecast replacement.

The [complete forecast check](../../../../../src/openifs/README.md#verification) passes for the selected route. Its declared upstream data and branch limits remain in force.
