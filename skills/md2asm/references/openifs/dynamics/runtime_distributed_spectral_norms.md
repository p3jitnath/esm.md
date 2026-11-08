# Runtime Distributed Spectral Norms

A spectral field represents an atmospheric pattern as a set of waves. A norm measures the field's overall size. The [assembly parent](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/dynamics/runtime_distributed_spectral_norms.S) collects the distributed wave values in the original order, then uses [direct arithmetic](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/dynamics/runtime_spectral_norm_arithmetic.S) to calculate the same norms as SPNORM. Field units and the source kinetic-energy weighting remain unchanged.

## Interface And Bounds

The entry md2asm_compute_runtime_distributed_spectral_norms takes Geometry20400, Model4275088, spectral2992, partition4096, controls24, persistent24, results and context16 in x0 through x7. The context contains the unsigned result capacity and private allocation budget in bytes. The budget is positive and at most64GiB. Complete records are mapped, nonwrapping and separate. Pointer records have eight-byte alignment, controls have four-byte alignment and FPCR must be zero. The1024-byte frame preserves x18, x19throughx30 and the Arm application binary interface, which defines argument placement and saved registers.

Let $`N`$ be the maximum wave degree and $`L`$ the global number of vertical levels. The supported source bounds are degree1through8191, levels1through512 and one through65536processes. Local wave and level counts can be zero. Geometry supplies degree5172, local waves5212, global levels5224, local levels5228, coefficient count5200 and pressure-owner flag7208. The phase7 partition and public MPI world must match the same Geometry. Phase7 means that its coefficient maps are ready.

Controls24 retains NSPPR, LELAM, LREFGEN, LREFOUT, NPROC and LDSPOR as six integers. All are zero except the actual process count NPROC. Model contains one thermal field and no spectral tracers. Terrain norms and formatted diagnostics require their separate route. The typed wave, coefficient-start and inverse-Laplacian maps are Geometry3912,3720and4168. The level map is spectral1264. Three complete rank-two fields are at1520,1608and1696, and the pressure vector is at2400. Their complete GNU array descriptions retain the source bounds, types and dense strides, which give the spacing between elements. Every selected wave's final read must fit its coefficient extent.

## Ordered Calculation And Ownership

For each selected wave and level, add the source-weighted squared real and imaginary coefficients in degree order. Wave zero uses its real coefficient once. Other waves use both parts with weight two. Preserve the source smallest-normal floor. The kinetic route retains the inverse-Laplacian metric and combines the already rounded vorticity and divergence sums in source order. These operations retain every FP64 rounding point. The internal matrix helper receives Geometry, the rank-two field, the kinetic logical, local level count and output matrix. The average helper receives the matrix, global level count, kinetic logical, per-level output and global wave count, returning the mean in d0.

Each process sends its local integer maps and four numerical matrices as bytes. Root receives one process at a time in increasing rank order. It checks that every global level-wave cell has exactly one owner and every pressure wave has exactly one owner. It drains all admitted packets even when a map is rejected. There is no floating-point MPI reduction. MPI is the public communication library. Empty processes still join every status agreement.

The result capacity $`B`$, in bytes, must satisfy

```math
B \ge 48 + 32L + 32L(N+1).
```

Five means begin at0, four level vectors begin at40, the pressure level is at40+32L and four complete level-wave matrices begin at48+32L. Only root writes results and the divergence mean at persistent0. Other persistent and nonroot result bytes retain their incoming values.

Each process owns one zeroed work allocation. Root also owns one complete temporary result. Work contains a local packet and kinetic scratch, plus one receive packet and coverage records on root. The complete simultaneous allocation must fit the supplied budget. Free communication work and complete final status agreement before publishing caller outputs. Keep the temporary result through its final copy, then free it. Every returned refusal frees its acquired owners and preserves caller results.

Return zero for success, one for allocation failure, two for invalid controls, bounds, capacity, budget or map coverage, and three for a public MPI failure. Natural FPSR and errno remain visible. No original OpenIFS procedure, constructor or data owner supplies a production stage.

## Evidence And Limits

The finite check passes108observations over four source/native process steps, with123,337,368complete nonaddress bytes exact,744typed pointer relations and14,136independent physical relations. Six distributed parent shapes cover empty local waves and levels, degree1,3and1279, levels1,3,5,137and512, and2by2and4by1process layouts. Arithmetic children additionally cover degree8191 and global wave count8192. Seven collective refusals cover capacity, budget, phase, duplicate coverage, missing pressure ownership and both private allocation failures. ABI, raw status, guards, owner release and all four independent process cleanup checks pass. These results accept this single-thread component. Full operational norms, the six-thread route and the complete saved forecast remain unverified.
