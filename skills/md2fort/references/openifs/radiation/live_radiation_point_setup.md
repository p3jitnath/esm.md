# Live Radiation Point Setup

The [assembly entry](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/radiation/live_radiation_point_setup.S) connects the accepted live radiation transform and Gaussian setup to the five point-coordinate fields. It follows the supported SUECRAD prefix from statements 1503 through 1619, ending before ZMU is deallocated. An owner is a buffer that the setup must later release. The driver supplies actual owned inputs and observes outputs, without supplying a numerical stage.

The [live Gaussian parent](live_radiation_gaussian_setup.md) retains its complete object. The [point-coordinate child](radiation_point_coordinates.md) also retains its complete object and ordered arithmetic. The new parent writes the six local integer fields in original source order, then the point child allocates GELAM, GELAT, GESLO, GECLO and GEMU. These hold longitude, latitude, longitude sine, longitude cosine and latitude sine. Angles use radians; sine and cosine values are dimensionless. The child later repeats the same six integer stores with identical values. Their first publication remains before allocation. The new parent emits no floating-point arithmetic.

The row count N is even and lies in 2 through 8192. Interpolation method NRADINT is 2 or 3. NSTENCILWIDE, the number of nearby cells used by the interpolation stencil, lies in 1 through 16. All four ranks of public MPI WORLD must use the actual completed partition and enter the same call order.

The application binary interface, or ABI, is:

| Argument | Meaning |
| --- | --- |
| x0, x1 | Writable radiation record and capacity, at least 1376 bytes. |
| x2, x3 | Borrowed completed public partition and capacity, at least 4096 bytes. |
| x4, x5 | Fresh zeroed ownership record and capacity, at least 160 bytes. |
| x6, x7 | Borrowed physical-constant record and capacity, at least 520 bytes. |
| Incoming stack byte 0 | Unsigned 64-bit NRADINT. |
| Incoming stack byte 8 | Unsigned 64-bit NSTENCILWIDE. |

All complete records and owners must be mapped, aligned, separate and nonwrapping under the two child contracts. Complete array descriptions and backing extents remain obligations carried from their qualified producers. FPCR, the floating-point control register, is zero. The same initialized physical record supplies pi at byte zero. Actual region coordinates come from completed partition bytes 932 and 936. ZMU and its complete length come directly from successful ownership bytes 16 and 24.

The original nine allocations remain first. The five point allocations follow them in their original order. Success returns zero. Allocation failure on any rank makes all ranks release their acquired point fields and nine earlier owners, restore the complete original radiation record and return one. Collective admission refusal returns two. Fresh ownership remains zero after failure. Added integer MPI agreements preserve FPCR, floating-point flags in FPSR and the C library error value errno; original calls retain their natural status. Public MPI failure aborts.

The release entry takes ownership and capacity in x0 and x1 on all four ranks. It first admits the complete point descriptors, then runs the accepted storage-release validation without freeing anything. One shared assembly include supplies that admission block to both the original storage release and the new private preflight. After both collective checks succeed, it frees the five point owners and nine earlier owners in reverse allocation order. All 14 owner bases and the ownership record are cleared. Invalid admitted metadata refuses before any owner is freed. Both new entries use 2048-byte aligned frames and preserve x18 and all required saved registers. The deepest creation also includes the earlier 2048-byte parent and 4096-byte storage frame.

Qualification uses one unchanged selected-source binary at N800 and N32, all four actual occupied regions, methods 2 and 3 with associated stencil endpoints 1 and 16, and incoming FPSR zero and 24. All 32 source and 32 direct calls match 105,651,328 complete record and owner bytes plus 768 immediate raw-status bytes. Another 512 packet bytes retain and compare actual region and stencil inputs. All 105,652,608 checked packet bytes have zero differences. Only known descriptor addresses are relocated; actual owner identities, sizes and physical strides are checked separately.

Each route passes 84,256 independent partition relations and 67,072 reused 90-digit Gaussian relations. Point checks cover 2,624,000 points and 18,368,192 geometry relations, with 39,024 additional sampled 90-digit trigonometric relations. The checker reads actual saved NLOENG inputs, which also match the direct inputs exactly. It calls no grid or numerical solver.

Five new allocation positions and one inherited representative produce 24 coordinated rollback calls. Three creation defects produce 12 collective refusals. Release-capacity and point/storage descriptor defects produce 20 collective refusals. All 128 direct parent ABI/status observations have zero masks; the reference's known x18 mask 2 remains explicit. Guards, borrowed inputs, handles and complete owner cleanup pass.

The source array copy has one separate, released temporary. A verification observer correction handles reuse of that temporary's address by a later owner. Numerical source, accepted child objects and the production object remain unchanged. Failed observer records stay local. The original main Fortran executable is unchanged, and no accepted source bank or upstream Geometry calculation is replayed. Production excludes verification observers and original OpenIFS numerical providers.

The next original stage deallocates ZMU at statement 1620. The current ownership record still owns that temporary, so early retirement needs a separate ownership revision. Model/radiation extent reductions, halo and latitude interpolation joins, communication descriptors and later SUECRAD stages remain separate. Complete SUECRAD, the autonomous forecast and comparative timing are unqualified.
