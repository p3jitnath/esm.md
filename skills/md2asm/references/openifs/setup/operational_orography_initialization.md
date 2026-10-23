# Operational Orography Initialisation

Orography describes the ground surface. This direct assembly component implements the complete selected SUOROG stage for the 9 km TCo1279 grid. Its input is ground geopotential, meaning gravitational potential energy per unit mass, in square metres per square second. It computes that field and its two horizontal derivatives, in metres per square second, while preserving the source equations and each 64-bit floating-point rounding point.

The original order is spectral loading in SUSPEC, SUOROG, then grid-point loading in SUGRIDF. SUOROG calls SPEREE for the scalar inverse transform, followed by SPEUV with KINP=2 for the derivatives. The admitted route has spherical geometry and false LGRADGP and LNONHYD_GEOM controls. It uses the accepted assembly-owned transform setup and needs no Atlas conversion. Original OpenIFS remains a separate verification reference.

## Interface and Owners

`int md2asm_initialize_operational_orography(geometry, geometry_bytes, spectral, spectral_bytes, controls, control_bytes)` receives its six arguments in registers x0 through x5 and returns status in w0. Geometry contains 17,096 bytes. Spectral contains 1,639,680 FP64 words, or 13,117,440 bytes. It is the second SP2D plane from the accepted spectral loader, identified by surface parameter 129. Controls contains four int32 words in 16 bytes, ordered LELAM=0, LGRADGP=0, MYSETV=1 and NPRTRV=1. An int32 is a four-byte integer. Geometry and real arrays align to eight bytes, and controls aligns to four. Complete consumed spans are mapped, nonwrapping and disjoint from writable output storage.

Geometry supplies a live positive transform handle NRESOL, NPROMA=17 points per block, NGPBLKS=388217, NGPTOT=6599680, NSMAX=1279, NSPEC2=1639680 and NUMP=1280. It already owns the [true-extent terrain storage](orography_owner_storage.md#operational-grid). The first 388216 blocks contain 17 points each, and the last contains eight. Each 384-byte block record holds OROG, OROGL and OROGM in its first three descriptors. A descriptor records an array's address, bounds and spacing. The other three fields remain unassociated.

The caller also supplies accepted [Laplacian maps](serial_laplacian_setup.md). MYMS at Geometry 3912 lists wave numbers zero through 1279. NASM0 at 3720 supplies the original packed start `1+m*(2561-m)`. RLAPDI at 4104 has lower bound −1, upper bound 1281 and offset 1. Preserve its complete stored words and original degree indexing. The new blocked terrain bases at Geometry 14088, 14176 and 14264 must initially be null. All upstream owners remain alive through calculation and release.

## Calculation and Lifetime

First call public ECTRANS INV_TRANS on the original scalar coefficients. Prepare two temporary spectral fields in original wave-number and degree order, multiplying positive zero and each original terrain word separately by the live RLAPDI word. For zonal wave number zero, assign both imaginary words positive zero as SPEUV does. Call INV_TRANS again on these vorticity and divergence fields to obtain the two derivatives. Preserve both library calls, argument positions and their order, including all signed-zero results. No fused operations, reassociation or approximate arithmetic are used.

A private 184,627,200-byte allocation contains the scalar grid, two temporary spectral fields and two derivative grids, beginning at bytes 0, 52797440, 65914880, 79032320 and 131829760. After both transforms, allocate three blocked fields of 52,797,512 bytes each with shape (17,388217). Publish their original GNU array descriptors, then copy physical points into both the existing true-extent arrays and the blocked fields in source order. Each layout receives 158,392,320 defined numerical bytes. The final nine words in each blocked field remain source-unwritten, preserving 216 incoming bytes per call.

Status 0 transfers the three blocked owners to the caller. Status 1 releases every new allocation and preserves the incoming Geometry and existing terrain values. Status 2 refuses an unsupported checked input before public mutation. `md2asm_release_operational_orography(geometry)` frees only these three new owners and clears their bases. Call it before the terrain-storage release frees the true-extent arrays and records. The caller retains Geometry and must not reuse released storage.

The constructor uses a 1,024-byte frame and release uses 64 bytes, both aligned to 16 bytes. Both preserve x18 and the Arm ABI saved registers. FPCR controls rounding, FPSR records arithmetic exception flags, and errno stores C library errors. FPCR must be zero, selecting round-to-nearest with ties to even and gradual underflow. Actual arithmetic and library calls retain their natural exception flags and errno. The only production services are public INV_TRANS, malloc and free. No original OpenIFS routine, global constructor or verification wrapper supplies a calculation.

## Acceptance and Limits

Four complete calls cover actual terrain and an independent constant field under two incoming allocation patterns. All 1,267,139,424 numerical bytes match the original exactly, including 864 untouched tail bytes. Complete terrain and Geometry metadata also match under explicit corresponding owner addresses. All 1,863,509,120 packet bytes have zero differences under that declared mapping. Inputs, bounds, guards and both storage layouts pass. All 22 native ABI observations, four allocation failures, three refusals and complete cleanup pass. Natural nominal FPCR/FPSR/errno states are 0/16/777 and 0/24/777. Original source changes to x18 remain recorded separately.

The independent constant geopotential is 1024 square metres per square second and its derivatives are zero. Public Fourier transforms introduce rounding, so each scalar point must lie within a source-derived row bound while both derivatives remain numerical zero. Let $`N`$ be the row's longitude count, $`M`$ the smallest power of two greater than $`2N-2`$, and $`u=2^{-53}`$ the FP64 rounding unit. Define the accumulated-rounding bound and intermediate factors below. The same conservative envelope covers ordinary Fourier rows.

```math
\gamma(q)=\frac{qu}{1-qu},\qquad
\eta=\frac{4(N-1)^2}{N}\gamma(3)+2u,\qquad
r=\gamma(64\log_2 M+64).
```

```math
B_N=1024M\left[(1+2\eta)^2(1+r)^3(1+\gamma(16))^2(1+\gamma(4))-1\right].
```

Evaluate $`B_N`$ exactly and round it outward once. It includes the stored phase coefficients, three Fourier stages, square-root normalization and final products. Independent 160-bit calculations check every consumed sine and cosine argument for all 1,280 actual row lengths through 5,136. The largest scalar bound is 0.0004644617612428229 square metres per square second. Both constant profiles pass 39,598,080 physical relations, with exact agreement of both layouts. This physical bound does not relax the separate zero-byte-difference requirement.

The original and native checks finish normally within their explicit limits and remain below 24 GiB resident memory. These are component qualification checks. They do not establish a complete operational forecast, a transform-library proof or a performance comparison. Original references, tools, raw records and the full independent error derivation remain local.
