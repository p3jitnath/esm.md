# Semi-Implicit Vertical Mode Setup

This stage builds the fixed matrices used to treat fast pressure waves. A vertical mode is a pattern of motion through the model layers. The model separates these patterns, solves their pressure response and combines them again. This component preserves the selected OpenIFS 48.1.1 SUBMAT and later SUSI calculations. The earlier [reference-pressure component](reference_pressure_coefficients.md) supplies its unchanged physical coefficients.

## Inputs And Ownership

The caller supplies owned Geometry and MODEL records with at least 17,096 and 4,275,088 mapped bytes. Both have eight-byte alignment, nonwrapping ranges and disjoint storage. Geometry NFLEVG at byte 5,224 gives the number of vertical levels, from one through 255. FP64 means an eight-byte floating-point value. FPCR, the Arm floating-point control register, is zero throughout the computation.

The source-derived LSIDG and LESIDG controls are false, and the vertical stability-analysis option is false. Thus the original conditional SUHEG, SUEHEG and SUDYN_STABILITY calls are inactive. The source global domain and un-stretched grid establish these choices. This interface refuses an active option before mutation. It does not change those physical controls. The complete source reference-pressure stage, owned physical constants and owned vertical geometry must already be valid. In particular, Geometry points to live VETA, VFE and CVER records, and the seven pressure-coefficient owners remain mapped for their complete declared bounds. They remain read-only here.

SIPR, the reference surface pressure, and SIDELP, the layer pressure weights, are finite and positive in pascals. VNORM is the finite positive dimensionless normalisation value from SUDYN. All five mode owners use ordinary GNU array descriptors, unit first stride, one-based bounds and contiguous column-major storage. The complete owners are disjoint from the parent records, from each other and from every borrowed pressure owner. Every numerical input and supported intermediate is finite.

| Owner | MODEL descriptor byte | Shape | Purpose |
| --- | ---: | --- | --- |
| SIB | 1,567,640 | levels by levels | Vertical pressure-response matrix |
| SIMO | 1,567,728 | levels by levels | Normalised mode patterns |
| SIMI | 1,567,816 | levels by levels | Inverse mode matrix |
| SIVP | 1,567,904 | levels | Ordered eigenvalues |
| SIBI | 1,569,224 | levels by levels | Inverse pressure-response matrix |

An eigenvalue states how strongly a matrix acts on its matching mode pattern. These pressure-response eigenvalues have the units of squared wave speed, square metres per square second. SIBI has the reciprocal matrix units. The normalised mode matrices are dimensionless.

## Source Order And Arithmetic

First allocate the five owners in the table order, after the seven pressure owners, as in SUALDYN lines 89–112. Their payloads remain unwritten at allocation. Publish all five descriptors only after every allocation succeeds. On failure, release temporary owners in reverse order and preserve the complete incoming MODEL.

SUBMAT forms an identity matrix, with one on its diagonal and positive zero elsewhere. It calls the complete accepted SITNU and SIGAM bodies on this basis, then copies the result to SIB. These children retain their existing physical proofs, vertical operators and frozen ordered matrix products. The normal mode stage then copies SIB to private storage and calls the separately qualified eigenvalue service. Original EIGSOL and RG remain verification references only.

SCORDO uses the original XUTRII strict-greater bubble comparison. Equal real eigenvalues keep their incoming order. Copy both frequency parts and their matching mode columns through private storage, then reverse the columns into SIMO and the real values into SIVP, exactly as in SUSI.

For each mode, sum its squared values times SIDELP in increasing level order. Each multiplication and addition rounds separately. Divide the sum by SIPR, then by VNORM, then take its square root. Divide each mode value by that root. If its final level is negative, negate every value in the mode. Preserve signed zeros and the original comparison rules. Form SIMI next, check the original imaginary-part condition, then form SIBI. The inactive Helmholtz and stability branches retain their original place in this schedule.

Both inverses preserve MINV_CALLER scaling. Sum absolute diagonal values in order and divide by the matrix order. When this mean is positive, divide each input by it before inversion and divide the inverse by it afterward. Preserve the original row-then-column assignment order. The selected MINV_8 route computes the largest ordered absolute column sum, calls the same public DGETRF, DGECON and DGETRI services from LAPACK, a standard linear algebra library, and retains their condition test against 100 times the smallest positive normal FP64 value. No original OpenIFS inverse wrapper supplies a production stage.

## Assembly Interfaces

The application binary interface, or ABI, defines argument registers and saved-register duties. `int md2asm_allocate_semi_implicit_mode_storage(Geometry, geometry_capacity, MODEL, model_capacity)` and `int md2asm_initialize_semi_implicit_modes(Geometry, geometry_capacity, MODEL, model_capacity)` use x0 through x3. `int md2asm_release_semi_implicit_mode_storage(MODEL, model_capacity)` uses x0 and x1. Status returns in w0. Zero succeeds, one reports private allocation failure and two refuses an unsupported input before output mutation. Status three reports an eigenvalue or inverse failure after numerical work has begun. Existing accepted child allocation failures retain their declared fatal behaviour.

The internal `md2asm_invert_scaled_mode_matrix` requires an admitted order and complete input, output, matrix scratch, real work for four times the number of levels, pivot and integer-work buffers. Its seven register arguments are the order by value and these six addresses. The parent supplies their separate bounded ranges. It is not a general unvalidated matrix interface.

The parent eigenvalue service is `md2asm_semi_implicit_eigenvalues`, with the original ten by-reference addresses NM, N, A, WR, WI, MATZ, Z, IV1, FV1 and IERR. The first eight use x0 through x7. FV1 and IERR occupy incoming stack offsets zero and eight. Its independently sourced EISPACK eigenvalue library and exact identity evidence are separate requirements.

Allocation, computation, the inverse helper and release use 160-byte, 512-byte, 256-byte and 48-byte frames, each aligned to 16 bytes. They preserve x18, every used saved integer register, the return address and the required saved vector halves. They use ordinary malloc and free. Numerical work uses scalar FP64 with separate rounding, including explicit division and square root. Borrowed inputs and all other MODEL bytes remain unchanged. Release clears only the five owner-address words, in reverse order, and accepts repeated calls.

## Accepted Checks And Limits

One joint genuine-source gate covers one- and three-level conventional atmospheres and the retained 19-level finite-element grid. All 25,650,528 compared MODEL bytes and 24,112 complete mode-owner bytes agree exactly. Nonzero descriptor and allocation preimages establish source-defined stores and unwritten bytes. Native saved-register masks are zero. The source computational wrapper changes x18, recorded as mask two. Immediate FPCR, FPSR and errno agree.

The reference uses the already accepted original SITNU, SIGAM and vertical source bodies with their frozen ordered matrix service. A raw vendor matrix product has a different arithmetic route and is retained separately, not substituted for this reference. Existing executed canonical launch and binding records establish this same ordered setup route. This is evidence of procedure selection, rather than a comparison with a saved canonical SIB payload. Independent 96-digit arithmetic checks 1,159 eigenrelations, pressure-weighted norms, mode signs and inverse identities. Their explicit condition-aware limits and detailed residuals remain local.

Eighteen critical refusals preserve the incoming records and owners. Each of the five owner-allocation failure positions rolls back completely. Failure of the first private computation allocation leaves every output unchanged. Reverse and repeated release pass. These results establish the selected setup component. They do not establish a complete autonomous forecast or a performance result.

### Runtime Public Matrix Connection

The [runtime wrapper](../../../../../src/openifs/setup/runtime_semi_implicit_modes.S) connects the same five arrays to the selected public matrix services. Its allocation and calculation entries are `md2asm_allocate_runtime_susi_mode_storage` and `md2asm_initialize_runtime_susi_modes`. Arguments x0 through x4 are Geometry, its mapped byte count, MODEL, its mapped byte count and the additional heap budget. Require at least 20,400 Geometry bytes and 4,275,088 MODEL bytes, with the alignment and separation rules above. The release entry `md2asm_release_runtime_susi_mode_storage` takes MODEL and its mapped byte count. These wrappers use temporary integer registers, have no frame and add no floating-point instruction.

For $`L`$ levels, the five retained arrays need $`8(4L^2+L)`$ bytes. Calculation needs at most $`64L^2+136L+128`$ additional heap bytes, excluding retained arrays. Refuse an insufficient budget or one above 64 GiB before entering the existing body. At 137 levels these requests are 601,704 and 1,219,976 bytes. Direct assembly uses at most 1,408 stack bytes, with separate allowance for public libraries. Allocate pressure before modes, then calculate pressure before modes. Release modes before pressure. Keep all borrowed records alive and preserve the source-selected false LSIDG, LESIDG and stability controls.

The shared `md2asm_public_dgemm_serialized` service reaches the selected public serial Sci DGEMM body. DGETRF, DGECON and DGETRI use the same selected library as the original control. Load public libm and serial Sci before FIAT and resolve symbols eagerly. The existing eigen wrapper retains independently sourced Netlib EISPACK. Assembly owns the physical constants, and original OpenIFS routines supply no production stage.

One genuine 137-level component with 17-point blocks and one thread passes nine allocation, calculation, release and refusal observations. All defined MODEL bytes and complete mode arrays match across 14,028,592 literal bytes with zero differences, with twenty checked allocation-address relations. The unchanged 96-digit checks pass 56,581 eigenrelations, weighted norms, sign conditions and inverse identities. FPCR, FPSR, errno and result match. Native saved-register masks are zero. The original calculation retains its declared x18 exception. Every reached owner is released.

The post-calculation runtime scan of borrowed inputs was not recorded. Their read-only requirement uses unchanged qualified child interfaces and reviewed caller spans and alias bounds. Release checks did execute. Levels 1 through 255 remain the declared admission range, while this public-matrix numerical evidence covers the stated 137-level case. Earlier private-matrix cases remain separate. Complete parent, forecast and performance acceptance remain pending.
