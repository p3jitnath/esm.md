# Hybrid Vertical Coordinate Owners

A hybrid vertical coordinate describes a layer-interface pressure as $`p=A+Bp_s`$, where $`A`$ is measured in pascals, $`B`$ is dimensionless and $`p_s`$ is surface pressure in pascals. An owner is an allocated numerical buffer that its caller must release once. This component constructs the eight numerical arrays in the original TVAB record from supplied A and B interface coefficients. It is the numerical and storage child called by SUVV1 after input selection.

## Source And Inputs

The source is YOMVERT::ALLOC_INIT_TVAB at arpifs/module/yomvert.F90 lines 360–397. SUVV1 calls it with all input-file vertical levels at line 285. Its caller still owns the earlier choice between source defaults, NAMVV1 values and the initial-file coefficients. This component accepts those live coefficients as inputs and does not replace that choice with a constructed model-state packet.

The raw entry md2asm_initialize_hybrid_coordinate_owners receives a writable 512-byte TVAB record in x0, the level count N in w1, an input A array in x2, an input B array in x3 and reference pressure P0 in d0. The supported count is 0 through 256. Both arrays contain N+1 contiguous FP64 values indexed 0 through N, and all consumed coefficients must be finite. P0 must be positive and finite. The record and inputs are eight-byte aligned, the record is disjoint from both input arrays, and each of its eight initial data pointers is null. All extents and address ends must be representable.

## Storage And Ownership

The record contains eight 64-byte GNU 12.3 rank-one allocatable descriptors in declaration order VALH, VBH, VAH, VC, VAF, VBF, VDELA and VDELB. Allocation follows the source order VAH, VBH, VALH, VC, VDELA, VDELB, VAF and VBF. The first three and the two full-level mean arrays have lower bound 0 and upper bound N. VC, VDELA and VDELB have lower bound 1 and upper bound N. Every array has unit element stride and eight-byte elements.

The entry obtains each owner through malloc and leaves its numerical preimage intact until the source writes it. VAF(0) and VBF(0) are source-unwritten incoming storage. They remain unchanged, including their exact bits. An empty owner uses the same minimum one-byte allocation as the original control. The successful caller owns all eight allocations. md2asm_release_hybrid_coordinate_owners receives the record in x0, frees the allocations in source order and clears only their data pointers. Allocation failure releases every acquired owner and clears all eight data pointers; descriptor bounds written earlier can remain.

The constructor returns zero in w0 on success, one for allocation failure or two for an unsupported input before mutation. The release leaf permits null individual data pointers so it can clean a partially built record. Neither entry frees any input coefficient storage. C malloc and free are the only external children.

## Ordered Calculations

First copy VAH(j)=A(j) and VBH(j)=B(j), then compute VALH(j)=VAH(j)/P0 for j=0 through N. For each j=1 through N, compute VC(j)=VAH(j)×VBH(j−1)−VAH(j−1)×VBH(j), rounding the two products separately before subtraction. Then compute VAF(j)=0.5×(VAH(j)+VAH(j−1)) and VBF(j)=0.5×(VBH(j)+VBH(j−1)), rounding each sum before multiplication. Finally compute VDELA(j)=VAH(j)−VAH(j−1) and VDELB(j)=VBH(j)−VBH(j−1).

VAH, VAF, VDELA and VC have units of pascals; VALH, VBH, VBF and VDELB are dimensionless. No fused instruction, reassociation or approximate arithmetic is used. FPCR must be zero, which selects round-to-nearest with ties to even and gradual underflow. Incoming FPSR bits remain set, and the source calculations can add flags. The Arm64 ABI defines arguments and preserved registers. Both entries preserve x18 and all required registers, maintain 16-byte stack alignment and restore no numerical result after return.

## Required Evidence

The separate original body must receive the same complete coefficients and matched incoming allocation bytes. The focused check compares every returned numerical byte, all descriptor words with explicit ownership correspondence, unchanged inputs and bounds, and complete released records. It covers the actual 19-level initial-file coefficients, empty and one-level edges, cancellation and the maximum supported count. The known-allocation byte fill is a verification input only and is absent from production libraries. An independent pressure calculation checks reconstructed interfaces, layer means and coefficient differences. Native binding and complete forecast admission remain separate.

## Original Native Interface

The original entry __yomvert_MOD_alloc_init_tvab receives a pointer to KLEV in x0, the first A and B coefficients in x1 and x2, and the fresh TVAB record in x3. Its 32-byte frame preserves all required registers and 16-byte stack alignment. It loads the live reference-pressure word VP00 as one explicit compatibility data input, then calls the raw direct constructor. A nonzero raw status terminates with exit code 121. Successful calls increase the integer-only md2asm_hybrid_coordinate_native_count_get counter. The selected SUVV1 route calls this constructor once for the model I/O coordinate. The separate output-system route calls it once more for its own coordinate record, giving two observed native calls.

The adapter calls no original procedure, constructor, type descriptor or virtual method. The raw child receives only the input coefficient arrays, pressure, count and owned output record. The native bridge still borrows the original VP00 data address, so complete bootstrap must supply its own equivalent configured pressure. The raw cleanup is available to that bootstrap, but this candidate does not export the original DEALLOC_TVAB name or claim a forecast call to it.

The complete critical check passes six source cases and 24 immediate ABI/status calls, including 12 native raw calls. All 19251 allocated bytes agree, including the three minimum one-byte allocations for empty owners. The declared numerical extents contain 19248 bytes. All complete released records agree. Independent 110-digit pressure identities pass six input cases and 114 physical layer-mean checks. Native adapter and original jump-slot evidence are recorded separately beside this contract.

The [complete forecast comparison](../../../../../src/openifs/README.md#verification) passes for this selected route, with every final owner and saved file compared. Original startup and remaining runtime services still prevent an autonomous-executable claim.
