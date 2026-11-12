# Meridional Interpolation Setup

A meridian runs from the north pole to the south pole. The existing solver interpolates between four neighbouring latitude rows. This setup prepares the latitude-dependent coefficients used by that calculation and its smoothing terms. It implements all four owners and the complete irregular-latitude branch of `arpifs/interpol/suhslmer.F90`, called by SUINTERPOLATOR after its vertical setup.

## Frozen Inputs and Arithmetic

Geometry owns the number of latitude rows NDGLG, local lower and upper bounds NDGSAH and NDGENH, the global-row offset NFRSTLOFF and the existing RLATIG latitude array. Latitudes are FP64 radians, strictly decreasing in the consumed interval. MODEL owns the dimensionless smoothing strength SLHDEPSH. Its named producer is `md2asm_default_selected_dynamics_controls`, which assigns its source zero at TDYNA offset 136. The owned LRPLANE flag must be false. No captured production coordinate or output coefficient is used.

For each local row j, let g=j+NFRSTLOFF. The source writes coefficients only when 0≤g≤NDGLG. Its four nodes are x0=RLATIG(g−1), x1=RLATIG(g), x2=RLATIG(g+1) and x3=RLATIG(g+2). Define the six differences d1=x0−x1, d2=x0−x2, d3=x0−x3, d4=x1−x2, d5=x1−x3 and d6=x2−x3. The three RIPI coefficients are −1/((d1 d4)d5), 1/((d2 d4)d6) and −1/((d3 d5)d6). Each subtraction, multiplication and division has its own FP64 rounding point in this order.

RSLD, RSLDW and R3DTW retain the complete original source expressions and their storage order. RSLD has three auxiliary smoothing coefficients. The other two owners have one 3×3 matrix per latitude row. Their full equations are frozen by the retained original source body and this stage's source-scope receipt. Source-unwritten halo rows retain their allocation bytes. No whole array is zero-filled.

## Interface and Ownership

`int md2asm_initialize_meridional_interpolation(Geometry, geometry_capacity, MODEL, model_capacity, LRPLANE_pointer)` receives five arguments in x0 through x4. The mapped records must be aligned to eight bytes, disjoint, non-wrapping and at least 17,096 and 4,275,088 bytes. The borrowed flag is one mapped aligned 32-bit word. The Arm floating-point control register must be zero. Geometry's existing typed latitude descriptor is at byte 4744. Its eight-byte FP64 elements have unit stride and bounds that include every consumed g−1 through g+2.

The selected supported domain has NDGLG from 2 through 4096 and at most 16384 output rows. All counts and bounds come from the live records. SLHDEPSH must be finite. All consumed latitudes must be finite and strictly decreasing. The caller retains the borrowed latitude owner, its typed record and declared extents through the call. Invalid input returns two before allocation or mutation.

The four allocations occur in original source order. RIPI and RSLD have shape (rows,3), with lower bounds (NDGSAH,1). RSLDW and R3DTW have shape (3,3,rows), with lower bounds (1,1,NDGSAH). Their MODEL descriptors start at 1572616, 1572704, 1572792 and 1572904. Each descriptor offset is minus the sum of lower bound multiplied by stride for all dimensions. All four owners must initially be absent. Allocation is transactional, so a failed malloc frees earlier temporary owners and returns one without changing MODEL. Successful setup returns zero.

`int md2asm_release_meridional_interpolation(MODEL, model_capacity)` frees the four owners in reverse order and clears their data pointers. Repeated release is safe. The caller must pass owners created by this stage. Call setup after the complete Geometry and vertical interpolation producers and before forecast calculations. Release horizontal owners before vertical owners. Neither entry calls an original OpenIFS routine. Production calls only malloc and free. Setup uses a 256-byte frame, and release uses a 64-byte frame. Both entries preserve x18, the required callee-saved integer and vector registers and the 16-byte aligned stack.

## Accepted Checks

Four profiles cover the current owned 32-row latitude output, a changed irregular grid, shifted local bounds and completely source-unwritten rows. The genuine complete SUHSLMER source and assembly agree on 17,100,352 MODEL bytes and 10,560 owner bytes, with zero differing bytes. The verification fixture retains the current latitude producer and exact input-byte lineage. It supplies no production stage.

Independent checks use exact rational arithmetic to test cubic and quadratic polynomial reproduction, affine smoothing identities and the relation between the two diffusion matrices. They pass 1,333 relations for each implementation. Immediate floating-point control, floating-point status and errno agree, and the native ABI mask is zero. Eighteen malformed-input cases preserve MODEL without allocation. All four allocation-failure positions roll back, and reverse and repeated release pass. Protected pages cover both ends of the consumed latitude input and the ends of all four output owners. Full saved-output agreement remains a separate parent forecast gate.
