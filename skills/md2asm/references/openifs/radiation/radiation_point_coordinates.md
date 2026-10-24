# Runtime Radiation Point Coordinates

This SUECRAD component builds the coordinates of the local radiation-grid points. A process owns part of the grid, described by source-produced row and longitude maps. The five new fields hold longitude, latitude, longitude sine, longitude cosine and latitude sine. Angles use radians and sine and cosine values have no units.

The direct [assembly](../../../../../src/openifs/radiation/runtime_radiation_point_coordinates.S) retains the original row and longitude order. For longitude index j on a row with m points and latitude sine mu, it writes

```math
\lambda=\frac{((j-1)\,2)\,\pi}{m},\qquad
\phi=\arcsin(\mu),\qquad
s=\sin(\lambda),\qquad c=\cos(\lambda).
```

Each multiplication and division rounds separately in FP64. Each point calls the public asin, sin and cos mathematical functions in that order, then copies mu. The six source local-row scalars retain their original formulas. NSTENCILWIDE gives the width of the source interpolation stencil, which is the nearby grid region used by interpolation.

Creation takes eight arguments in x0 through x7. These are the mapped 1376-byte radiation record and capacity, the complete ZMU buffer and bytes, the live 520-byte physical record and capacity, and a 16-byte control record and capacity. Controls hold MY_REGION_NS, MY_REGION_EW, NSTENCILWIDE and reserved zero as int32 values. The caller binds the region coordinates to the completed public partition. RPI, the physical value of pi, is read at physical-record offset 0. Records and FP64 buffers need eight-byte alignment. Controls and integer maps need four-byte alignment.

The live even latitude-row count N ranges from 2 through 8192. NDLON and each row length range from 1 through 2N+16, NSMAX ranges from 0 through 2N, and each region-axis count ranges from 1 through 64. NSTENCILWIDE ranges from 1 through 16. The nonnegative int32 local point count must equal the complete selected map sum. The caller supplies canonical complete GNU int32 descriptors for NLOENG, NFRSTLAT, NLSTLAT, NSTA and NONL, with the physical row pitch N+R+3, where R is the number of north–south regions, named N_REGIONS_NS in the source. Every borrowed record and owner must be fully mapped, disjoint and stable. The entry checks consumed map bases, selected regions, pitch, row limits, longitude ranges and point count before allocation. Complete descriptor headers, backing extents and disjointness are proof obligations carried from their qualified producers.

The fresh output descriptors are GELAM at 712, GELAT at 776, GESLO at 904, GECLO at 840 and GEMU at 1224. Allocation follows that order. Each owner has one FP64 word per local point, bounds 1 through NGPTOT, offset -1 and unit stride. An empty owner has one physical byte and zero logical elements. All five allocations complete before publication. Their greatest admitted individual size is 1,074,790,400 bytes, and all five are live together. Allocation failure frees earlier owners in reverse order and leaves public inputs unchanged. Return 0 means success, 1 means allocation failure, and 2 means unsupported input. The 256-byte aligned frame preserves x18, saved integer registers and the used saved FP64 registers. FPCR must be zero, and natural flags and errno propagate.

Release takes the radiation record and capacity in x0,x1. It validates all five descriptor shapes before freeing owners in reverse order and clearing their base words. Its 80-byte aligned frame preserves required registers, numerical status and errno. Repeated empty release succeeds. The caller retains the maps, ZMU, physical constants, controls and radiation record.

One unchanged original selected-source binary and one direct object agree on 6,571,018 complete data bytes and 192 raw-status bytes. Checks cover the 800-row region with 163,600 points, a nonempty 32-row region with 400 points, a sparse empty public region and an explicitly empty interval. Independent geometry checks cover 1,148,024 relations per route, with 2,646 additional 90-digit trigonometric relations. All nominal and critical register checks, 15 atomic input refusals, five partial-allocation cleanup paths, three release refusals, owner guards and borrowed-input checks pass. All owners are released, with natural FPCR 0, FPSR 24 and errno 777 for the declared incoming state.

The verifier reuses accepted complete public maps and extended Gaussian values. The physical fixture supplies the frozen RPI word 0x400921fb54442d18. Production must bind live region, stencil and physical owners. No old numerical producer or original main program is replayed or rebuilt. These component checks do not complete the source halo calculation, SUECRAD, RADDRV or a forecast. The earlier transform packet's separate 800-row post-output reference cleanup limit remains unchanged.
