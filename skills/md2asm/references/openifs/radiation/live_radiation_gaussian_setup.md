# Live Radiation Transform and Gaussian Setup

The [assembly entry](../../../../../src/openifs/radiation/live_radiation_gaussian_setup.S) joins radiation transform storage and Gaussian fields in one live call. It follows SUECRAD statements 1503 through 1560: SETUP_TRANS, nine original allocations, TRANS_INQ, ordinary Gaussian fields and four added polar rows. An owner is a buffer whose creator must later release it. The new parent contains integer checks and calls; both accepted child objects remain unchanged.

The Gaussian sine and cosine values are dimensionless, and latitude angles are in radians. The [storage contract](radiation_transform_storage.md) defines the nine owners and their descriptor layouts. The [preallocated Gaussian contract](preallocated_radiation_gaussian_fields.md) defines the ordered floating-point operations. The verification driver supplies live inputs and observes outputs, without supplying a numerical stage.

The radiation row count N is even and lies in 2 through 8192. Interpolation method NRADINT is 2 or 3. The actual completed public partition and all four ranks of MPI WORLD must enter the same call order. Records and complete owners must be mapped, aligned to eight bytes, separate and nonwrapping, with the bounds in the two child contracts. RPI at physical byte zero lies in [3,4), and the floating-point control register is zero.

The application binary interface, or ABI, is:

| Argument | Meaning |
| --- | --- |
| x0, x1 | Writable radiation record and capacity, at least 1376 bytes. |
| x2, x3 | Borrowed completed public partition and capacity, at least 4096 bytes. |
| x4, x5 | Fresh zeroed ownership record and capacity, at least 160 bytes. |
| x6, x7 | Borrowed physical-constant record and capacity, at least 520 bytes. |
| Incoming stack byte 0 | Unsigned 64-bit NRADINT. |

A collective integer check rejects a bad new mode or physical input before allocation. The parent then calls the unchanged storage child. That child retains SETUP_TRANS, NSTA, NONL, NPTRFRSTLAT, NFRSTLAT, NLSTLAT, RMU, ZMU, RSQM2, RLATIG, then TRANS_INQ in their original order. Its refusal or allocation failure returns without calling the Gaussian child.

After inquiry, the parent reads the new ZMU address and complete byte length from ownership bytes 16 and 24. It forwards those values with the same radiation and physical records to the unchanged preallocated Gaussian child. No new buffer or arithmetic is added. A returned child refusal makes all ranks release their new handle and nine owners, restore their complete original radiation records and return 2. The fresh ownership records remain zero. Success returns zero; an allocation failure retains the storage child's return 1. Public MPI failure aborts.

Both added integer agreements preserve FPCR, FPSR and errno, so original calls retain their natural status. The 2048-byte aligned frame includes the rollback record and preserves x18 and all required saved registers. Nested storage creation uses its unchanged 4096-byte frame. The existing storage release entry takes ownership in x0 and capacity in x1 on all four ranks and releases all nine owners in reverse order.

Qualification uses actual completed NS3/EW2 partition data at N800 and N32, both interpolation methods, and incoming FPSR zero and 24. All 32 source and 32 direct calls match 691,328 complete data bytes and 768 immediate raw-status bytes, with zero differences. Known descriptor addresses alone are relocated for comparison; exact owner identities, sizes and physical strides are checked separately. All 140 native ABI observations have zero masks; the reference's known x18 mask 2 remains explicit.

Independent point-coverage checks pass 84,256 relations per route, and reused 90-digit Gaussian laws pass 67,072 more per route. Nine one-rank allocation failures, eight collective admission defects, four release refusals and an actual one-rank Gaussian child refusal pass. All original records, borrowed inputs and guards are preserved where required, and all owners and handles are released.

The original Fortran array copy creates one N-times-8-byte temporary after inquiry, then releases it before return. The observer checks that temporary separately from the nine returned owners. Production still has exactly nine allocations. Verification observers supply guards and controlled failures and remain outside production. The production link uses the two exact accepted child objects and allowed public libraries, with no original OpenIFS numerical provider.

This prefix ends before statement 1562. Local stencil fields, five point-coordinate owners, original ZMU release, model/radiation extent reductions, halo and latitude interpolation, communication descriptors and later SUECRAD setup remain separate. No upstream Geometry replay or original main Fortran rebuild is used. Complete SUECRAD, the autonomous forecast and comparative timing are unqualified.
