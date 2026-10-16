# Selected Vertical Coordinate Construction

This component implements the complete SUVV1 path used by the retained T21 input. It constructs vertical-coordinate storage before SUVERT calculates the vertical operators. An owner is a buffer that this component allocates and its caller must eventually release. The source is arpifs/setup/suvv1.F90. The qualified SUDEFO_VV1 and ALLOC_INIT_TVAB children remain separate numerical sources.

## Selected Input Path

The supported Geometry has NFLEVG=NIOLEVG=19 and hydrostatic dynamics. Vertical finite elements are enabled, with the new operators, spline type 3, order 4 and integral and derivative boundary controls both equal to 3. Finite elements describe the vertical variation with local basis functions. LECMWF is true, the file supersede control is one, and NAMVV0 is empty, so LLFORCE_READ remains false. The initial-file pv key supplies 20 A coefficients and 20 B coefficients. No constructed model-state packet supplies these inputs.

The file coefficients differ from the source default table. The constructor calls the default child, copies its defaults to DVALH and DVBH and sets the reference pressures, then applies the original initial-file override itself. It retains the original coefficient comparisons and endpoint checks, converts the selected coefficients to the main geometry arrays and constructs the eight I/O owners. Initial-file reading and the earlier dimension and configuration constructors remain separate upstream dependencies.

## Raw Interface And Ownership

md2asm_initialize_vertical_coordinate_setup receives writable Geometry of 17,096 bytes in x0, the input-file A and B arrays in x1 and x2, and a table of five output addresses in x3. The output table points to DVALH, DVBH, VVP00, VP00 and TOPPRES, in that order. The first two output arrays each contain 201 FP64 words; the routine changes only their first 20. Each other output is one FP64 word. A and B each contain 20 contiguous finite FP64 values and remain unchanged. All buffers are mapped for their complete extents, eight-byte aligned and disjoint, except the declared legacy associations inside Geometry. The caller owns Geometry, all input and output buffers and the output-address table.

Geometry%LNONHYD_GEOM must point to its inline false logical word, and Geometry%YRCVER must point to its previously constructed inline configuration record. All 27 affected data pointers must initially be null. Other geometry objects and source-unwritten metadata retain their incoming bytes. The typed layout record vertical_owner_layout.json identifies the true allocatable descriptors. JPRB, JPRD and JPRH all have width eight bytes, and JPMXLE is 200 in this build.

The entry returns zero on success, one after an allocation failure with all acquired owners released, or two before any record or output change for an unsupported configuration or coefficient endpoint. On allocation failure, source-written descriptor bounds, legacy associations and NVFE_INTERNALS may remain. Every owned data pointer is cleared. md2asm_release_vertical_coordinate_setup releases only the 27 numerical owners and clears their data pointers. It does not release any caller buffer. This complete direct cleanup does not claim execution of an original forecast destructor.

## Storage And Source Order

The first 19 allocations follow the original TVAB, TVETA and TVFE order. They include the main A and B arrays, dimensionless normalised A, eta-coordinate arrays, 17 internal knots and five operator matrices. The constructor sets NVFE_INTERNALS=19+2−4 immediately before the knot allocation, then associates the legacy YRVAB, YRVETA and YRVFE pointers with their inline records. It constructs the eight I/O coordinate owners last. The 27 complete numerical extents contain 19,568 bytes.

A GNU rank-one array descriptor contains 64 bytes, and a rank-two descriptor contains 88 bytes. A descriptor gives the data address, element width, type, bounds and strides. Each FP64 element has eight bytes. Rank-one strides are one element, and rank-two column strides equal the first extent. Descriptor offsets use the original lower bounds. Allocation order, all associated descriptor bytes and all legacy pointer targets are checked against the typed source control.

Eta, knot and matrix values remain incoming allocation bytes until their later producer writes them. Main VC, VAF, VBF, VDELA and VDELB values also remain untouched where SUVV1 only allocates storage. The I/O child leaves VAF(0) and VBF(0) untouched. Production code adds no fill, imported state packet or output repair. A small verification-only allocator gives source and direct buffers the same initial bytes so every returned storage byte can be compared. The original compiler also allocates its two private 20-word work arrays; the direct entry keeps these arrays in its own stack frame.

## Arithmetic And Status

The default child supplies VVP00=101325 Pa. VP00 copies that exact word, and TOPPRES=0.1 Pa. A has units of pascals, and B is dimensionless. After coefficient selection, VAH and VBH copy A and B, while VALH(j)=VAH(j)/VP00 uses one FP64 division at each interface. The I/O child preserves its separately rounded determinant, mean and difference calculations. The source endpoint tolerance is 100 times FP64 epsilon, where epsilon is the spacing from one to the next larger FP64 value. Contraction, reassociation and approximate arithmetic remain forbidden.

The entry obeys the AArch64 application binary interface, preserves x18 and all saved registers, and uses a 448-byte frame with 16-byte alignment. FPCR must be zero. Incoming FPSR bits remain set, and source arithmetic may add flags. The raw prepared-input interface preserves incoming errno. Its only production callees are C malloc, free and errno-address services and the two direct assembly children. Original allocation and geometry printouts and optional DR_HOOK profiling are omitted diagnostics; no forecast calculation is omitted.

## Completed Checks And Limits

Three raw source cases pass all 58,704 returned owner bytes, 9,720 complete module-output bytes and 102,576 complete Geometry and released-record bytes, with 12 immediate ABI and status calls. They use actual file coefficients under two initial allocation byte patterns and a separately scaled A profile. All associated descriptors, owned-address relationships, legacy associations, untouched storage, input buffers and guards agree. The new main normalisation is also checked against a wider-precision pressure identity, reusing the qualified I/O child's independent hybrid-pressure checks.

Independent source and ABI review passes. The raw constructor is also exercised through the [owned vertical context](vertical_startup_context.md) and [standalone initial-input executable](../input/standalone_initial_bootstrap.md). This component does not close SUVERT or autonomous startup.
