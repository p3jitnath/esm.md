# Owned Vertical Startup Context

This assembly component owns the persistent vertical-coordinate subtree needed before the selected SUVV1 allocation path. It allocates its own Geometry container, configuration, coefficient outputs and 27 numerical buffers. It composes the qualified direct TCVER, SUVV1, SUDEFO_VV1 and ALLOC_INIT_TVAB children. No OpenIFS program, launcher, Fortran procedure, module data, type descriptor or vtable is part of its production link. This is a complete owned vertical allocation subtree, not complete Geometry, MODEL, FIELDS or forecast startup.

`md2asm_create_vertical_startup_context` receives the file A array in x0, B in x1, an output pointer word in x2 and a four-word int32 configuration in x3. A and B each contain twenty finite FP64 words, indexed zero through nineteen. A has units of pascals, while B has no units. Configuration order is level count, ECMWF flag, nonhydrostatic flag and two-dimensional flag. This selected interface accepts 19, 1, 0, 0. All four input/output buffers are eight-byte aligned, mapped for their complete bounds and disjoint. The caller retains A, B and configuration; the routine never changes them. FPCR must be zero.

The return in w0 is zero on success, one on allocation failure or two for unsupported input. The output pointer is published only after successful construction and otherwise retains its incoming bits. The returned context has 20,400 bytes, followed by no hidden record. Its ABI is:

| Byte offset | Complete extent | Role |
| --- | ---: | --- |
| 0 | 17,096 bytes | Geometry container, with only the declared vertical subtree constructed |
| 17,096 | 201 FP64 words | Owned DVALH namespace |
| 18,704 | 201 FP64 words | Owned DVBH namespace |
| 20,312 | One FP64 word | VVP00 reference pressure |
| 20,320 | One FP64 word | VP00 reference pressure |
| 20,328 | One FP64 word | TOPPRES reference pressure |
| 20,336 | Five pointer words | Addresses of those five output objects in source order |
| 20,376 | Four int32 words | Copy of the explicit configuration |
| 20,392 | Eight bytes | Private lifetime marker |

The new outer storage has an explicit zero initial state. This is an owned storage policy, not an imported state image or a claim that the original source assigns every Geometry byte. The source-declared empty allocation state covers all 38 descriptors in TVERTICAL_GEOM and the eight descriptors in YVABIO. The declaration default RLAPL2PI is zero. Descriptor words for an unallocated array are canonical empty metadata until a producer writes its associated descriptor. Source-unwritten TCVER scalars, padding, unused DVALH/DVBH tails and unrelated Geometry components start at zero in this new namespace. They are not numerical owners copied from a recorded forecast.

The constructor sets the selected level words, points LNONHYD_GEOM to its inline logical and YRCVER to its inline configuration, then calls the direct TCVER child. That child preserves source-unwritten controls such as RVFE_CENTRI. This checkpoint qualifies the allocation path only; later vertical/operator and full Geometry callers must establish every control they consume and construct the other Geometry components before use. The component does not turn the reserved zero regions into a complete model default-record implementation.

The five owned output addresses then go to the direct SUVV1 raw child. It preserves the original order of nineteen main allocations, default coefficients, reference pressure, initial-file coefficient override, main normalisation and eight I/O allocations. The actual file coefficients are caller inputs and differ from the unused default table. VVP00 and VP00 become 101325 Pa, and TOPPRES becomes 0.1 Pa. Twenty rounded divisions form main VALH; the qualified I/O child retains its ordered calculations. No fused multiply-add, reassociation, approximate operation or new numerical formula is introduced.

The 27 numerical buffers contain 19,568 bytes. Their allocator contents remain incoming storage where the source does not write them; production adds no payload fill. A verification-only allocator gives both the source and direct paths the same two incoming byte patterns, with guards around each complete allocation. This is separate from the new outer metadata namespace's declared zero initial state. Allocation failure releases every acquired numerical owner and the outer record, with no published context pointer.

`md2asm_release_vertical_startup_context` receives one live context in x0. It checks alignment and the private marker, releases its numerical owners and outer record, and returns zero. Invalid mapped context metadata returns two before deallocation. The caller must not use the pointer after success or pass arbitrary unmapped/freed addresses. Create preserves errno, allows the source child arithmetic to add FPSR flags and preserves x18 and all saved registers with a 96-byte aligned frame. Release preserves FPCR, FPSR, errno and saved registers with an 80-byte aligned frame. Only malloc, free and the errno-address service are external production calls.

Four source/direct cases pass 78,272 complete numerical-owner bytes and 81,600 complete context bytes after exact owned-address correspondence. They use real initial-file coefficients under two allocation patterns and separately scaled A profiles. All associated descriptors, complete namespaces, configuration, inputs, guards and allocation relationships agree. Eight native create/release ABI calls have mask zero, and all sixteen source/native calls preserve the required raw status; the separate original control has its already recorded x18 clobber. Eighty wider-precision pressure-normalisation relations pass. All 7,488 observed allocation guard bytes are intact.

Outer-allocation failure, first-child allocation failure and a separate failure after acquiring the first numerical owner leave no live allocation and retain the output pointer, with status preserved. Two unsupported inputs are rejected. The partial-acquisition check reused the successful source cases without rerunning them. The original strict-library fixture remains a separate verification executable and its loader environment is recorded locally.

Independent source and ABI review passes. The [standalone input parent](../input/standalone_initial_bootstrap.md) constructs this context from the original file coefficients without any OpenIFS or Fortran production dependency. Complete model construction and autonomous forecasting remain separate work.
