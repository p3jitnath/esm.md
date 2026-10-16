# Owned vertical spline operators

This layer fills the five numerical operator owners already allocated by the accepted SUVV1 assembly. It performs the selected hydrostatic, new-spline SUVERTFE to SUNH_VERTFESPLINE calculation by calling the qualified raw operator graph five times. It also owns the independent RDERB copy created by the source assignment after RDERBF00. It does not allocate a second copy of any existing SUVV1 owner.

The application binary interface is `int md2asm_initialize_vertical_spline_owners(const double eta[21], void *const operators[5], void *derivative_descriptor)`. The three addresses enter in x0 through x2. Operators contains the five caller-owned, disjoint payload addresses in source calculation order: RINTBF11, RDERBF00, RDERBF01, RDERBF10 and RDERBF11. The integral owner has 20 by 21 FP64 values and each derivative owner has 19 by 21. The first matrix index changes fastest. Eta has the actual qualified 19-level values, strictly increasing from positive zero to one. All pointers have eight-byte alignment and complete mapped extents. Numerical-domain membership is inherited from the raw selected operator contract.

In the accepted owned Geometry namespace, these payload addresses are the first words of the following existing descriptors. Geometry is not an argument to this raw interface. Its owned caller supplies the explicit addresses and passes its empty RDERB descriptor storage. No original module, type, vtable or callable address is supplied.

| Operator | Geometry descriptor byte offset | TVFE-relative byte offset | Shape |
| --- | ---: | ---: | --- |
| RINTBF11 | 1088 | 240 | 20 by 21 |
| RDERBF00 | 1352 | 504 | 19 by 21 |
| RDERBF01 | 1440 | 592 | 19 by 21 |
| RDERBF10 | 1528 | 680 | 19 by 21 |
| RDERBF11 | 1616 | 768 | 19 by 21 |
| New independent RDERB copy | 1264 | 416 | 19 by 21 |

The derivative descriptor is 88 writable bytes in the caller-owned TVFE record, whose Geometry offset is 848. Its data-pointer word must be zero at entry. On success this layer writes the complete GNU rank-two real descriptor: element size and span eight, version zero, rank two, real type three, allocation attribute zero, strides one and 19, bounds one to 19 and one to 21, and canonical element offset minus 20. These are array sizes, strides, address and ownership metadata. The new allocation has 3192 bytes, copied bit for bit from computed RDERBF00, and has an independent address. The five earlier owners retain their original descriptor metadata and existing context-release responsibility.

A temporary 61856-byte workspace is allocated before calculation and freed before return. The five operators are computed in source order. After the second one, allocate and copy RDERB, then compute the other three. The child never reads temporary allocation preimages as numerical input. Original printing, profiling and the integral eigenvalue calculation are diagnostic only; the source only prints those eigenvalues and never feeds them into any operator or decision. Their omission must retain complete source-defined owners and immediate returned floating-point status in the genuine upper-control check.

Return zero means complete. Return two rejects pointers, alignment, nonempty new-owner storage or eta metadata before mutation. Return one means allocation failure, and return three means numerical-child failure. Failures after computation starts can leave earlier existing payloads partly computed; callers must discard that setup. The layer frees temporary and newly allocated storage and clears the new data-pointer word on failure. It never frees or clears any of the five existing owners. Other words of a failed new descriptor may retain bounds. The caller must call `md2asm_release_vertical_spline_copy(descriptor)` before releasing the existing vertical context. That separate method frees only this new owner and clears its pointer; a null pointer is already released. Invalid descriptor addresses return two.

Both methods preserve errno, FPCR, x18 and required saved registers. Calculation requires FPCR zero and preserves incoming FPSR sticky flags while adding source numerical flags. The setup frame is 128 bytes aligned to 16 bytes; its maximum nested frame is 6976 bytes. Release has a 48-byte aligned frame. Production calls only the qualified assembly operator graph and libc malloc, free, errno access and domain-error exit services. Complete genuine SUNH_VERTFESPLINE owner/metadata/status and ABI checks are separate from the source/ABI peer and autonomous forecast admission. No new body credit is assigned locally.
