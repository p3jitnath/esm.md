# Vertical Spline Interpolation Setup

This stage builds the complete vertical spline tables from `arpifs/interpol/suvsplip.F90`. A cubic spline is a curve formed from cubic polynomial pieces whose values and first two derivatives agree where the pieces meet. The original `SUINTERPOLATOR` calls this setup before `SUVSLETA` whenever the model has more than one vertical level, including when the later spline interpolation flag is false. Its selected diagnostic-print branch is a compile-time false constant.

The vertical coordinate eta is dimensionless. The accepted vertical setup owns the full-level coordinates `VETAF(0:N+1)` and half-level coordinates `VETAH(0:N)`. Here N is the number of full levels. The source constructs the interior interval lengths from consecutive full levels and extends its end intervals with twice the distance from the first or last full level to the corresponding half level. All consumed coordinates must be finite and strictly increasing, and these two end distances must be positive.

The direct C interface is `int md2asm_initialize_vertical_spline_interpolation(Geometry,geometry_capacity,MODEL,model_capacity)`. Geometry and MODEL arrive in x0 and x2, with byte capacities in x1 and x3. These caller-owned records are aligned to eight bytes, disjoint and mapped for at least 17,096 and 4,275,088 bytes respectively. The supported level count is 2 through 255. Geometry's accepted VETA pointer and contiguous FP64 array descriptors supply both borrowed coordinate arrays. Their lower bounds are zero and their upper bounds are N+1 and N. The input records and borrowed arrays stay live throughout the call.

The setup owns three arrays with the exact source bounds and column-major order. `RVSPTRI(1:N,-1:1)` holds the lower, central and upper bands of the spline sampling matrix after elimination of the two endpoint values. `RVSPC(1:10)` holds the endpoint elimination constants and the two end full-level spacing reciprocals. `RFVV(1:4,-1:N+2,1:4)` holds the four polynomial coefficients for each of four adjacent intervals. Together their numerical payloads use 152N+592 bytes. Their descriptors are at MODEL byte offsets 1,571,256, 1,571,344 and 1,571,408 respectively.

For an interval displacement x, each polynomial uses four stored coefficients a, b, c and d, in this order.

```math
B(x)=a+bx+cx^2+dx^3.
```

The source's local four-interval calculation sets the polynomial coefficients with its fixed height constant 4/6. It then forms a sampling matrix from their values at the full levels. The first and last matrix rows impose natural endpoint conditions, which set the second derivative of the complete spline to zero at each end. Eliminating the two endpoint coefficients leaves the three bands stored in `RVSPTRI` and the constants stored in `RVSPC`.

The complete ordered FP64 differences, integer powers, products, sums, signs and divisions are frozen. Each multiplication and addition has its own rounding point, with no fused multiply-add or reassociation. Every source-written array element and descriptor field is compared exactly, including zero signs and the untouched MODEL bytes. The source has no active matrix-inversion or numerical child call in this stage, and the direct stage calls only the ordinary external memory allocator and deallocator.

The entry allocates the three source owners in their original order, then two private work arrays for intervals and the sampling matrix. Its fixed stack frame is 512 bytes. The source setup computations complete before the entry publishes any descriptor. Return zero means success, one means allocation failure and two means an unsupported or invalid interface. A rejected input or failed allocation leaves MODEL unchanged and releases any acquired buffers. Caller and callee register duties follow the Arm procedure-call standard, with x18 preserved and FPCR required to be zero for the frozen rounding and underflow settings.

The companion `int md2asm_release_vertical_spline_interpolation(MODEL,model_capacity)` uses x0 and x1. It releases the three arrays in reverse source order and clears their base pointers. MODEL remains live until release completes, and repeated release is allowed. The production entry calls this release after the horizontal and vertical interpolation releases and before the earlier diagnostic owners.

Qualification uses the unchanged complete original source with a typed Geometry and MODEL fixture. At least one fixture uses the coordinates produced by the current accepted vertical setup. The exact gate covers complete MODEL bytes and all three payloads. Separate mathematical checks cover polynomial continuity, endpoint derivatives and the reduced sampling operator. Critical storage checks cover allocation failure, buffer ends and the application binary interface. Full forecast output agreement remains a separate required gate.

The accepted small, four-level, current 19-level and 255-level profiles match 17,100,352 complete MODEL bytes and 44,928 numerical owner bytes, with zero differences. All 6,712 independent mathematical relations, register and immediate floating-point status checks, buffer guards, five allocation-failure positions, reverse and repeated release, and two invalid-extent refusals pass. These component results do not establish complete autonomous forecast agreement.
