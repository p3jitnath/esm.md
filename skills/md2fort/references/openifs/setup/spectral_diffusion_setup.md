# Spectral Diffusion Setup

This component constructs the selected horizontal diffusion setup from the original SUDYN, SUHDIR, SUALDYNB and SUHDF_EC equations. Diffusion damps the smallest resolved patterns, while a stronger upper-level layer limits noise near the model top. The cubic-grid case also adds spectral viscosity, a damping term that grows smoothly toward the highest wave number. The production path uses directly written AArch64 assembly and live owned input records. Original OpenIFS routines remain verification controls only.

The four C interfaces return zero on success and two for unsupported input. `md2asm_initialize_spectral_diffusion_controls` and `md2asm_calculate_spectral_diffusion_coefficients` take Geometry, its capacity, MODEL, its capacity, a three-element FP64 constant buffer and its capacity in registers x0 through x5. Constants are RHOUR in seconds, VP00 in pascals and dimensionless RPLRADI, in that order. They come from the accepted owned physical, vertical and dynamical namespaces. `md2asm_allocate_spectral_diffusion_storage` takes the first four arguments. `md2asm_release_spectral_diffusion_storage` takes MODEL and its capacity. Geometry has at least 17,096 bytes, MODEL has at least 4,275,088 bytes, and the constant buffer has 24 bytes. Complete consumed spans are mapped, aligned to eight bytes, nonwrapping and disjoint. Owned input array payloads also cover their declared typed bounds. RHOUR, VP00 and RPLRADI are finite and positive. The live time step TSTEP is finite and positive. Source-produced HDIRVOR, HDIRDIV and HDIRT each exceed one second in the selected calculation. FPCR is zero.

The selected configuration is global ECMWF hydrostatic semi-Lagrangian dynamics with inactive semi-Lagrangian diffusion. The existing first-empty NAMDYN and NAMDYNA admission and owned empty-NAMDYNCORE constructor run before these calls. The supported domain has two through 59 vertical levels, the same number of local levels, wave numbers 21 through 255 and a cubic grid with NDGLG greater than NSMAX plus one. The live first hybrid-pressure coefficient VAH(1) exceeds 21 Pa, selecting the original nonmesosphere branch. The spectral tracer count is zero and the live humidity and ozone descriptors both have false spectral-field flags. The local-to-global level map is read from its real owner and each entry must be a supported global level.

Run the source control producer before any consumer of KLSPONGE. It retains the SUDYN section 1.04 stores, the original SUHDIR resolution thresholds, separate division, nearest-integer conversion and radius scaling, followed by the selected source level resets and reciprocal coefficients. These values are derived from the live grid and constants. No observed coefficient table supplies a result. Other MODEL fields and alignment bytes retain their incoming values.

The storage stage allocates RDIVOR, RDIDIV, RDITG, RDIGFL and RDISP in their original order. The first two have shape (levels, 0 through NSMAX), the third uses the global level count, and RDIGFL has an additional zero-extent tracer dimension. RDISP spans wave numbers zero through NSMAX. Even the empty tracer array receives a real source-compatible owner. All five complete descriptors publish together after every allocation succeeds. Failure frees all private temporary owners without changing MODEL. Allocation leaves every payload byte unwritten. Release frees owners in reverse order, clears their base pointers and permits another release.

The calculation consumes the unchanged selected controls from the control stage, including LHDIFFM false and LSPECVIS true. Its descriptor admission checks are partial and do not replace the owned-storage and mapped-span prerequisites. Allocation or scratch failure returns two. The arithmetic stage first constructs the original vertical profile. It uses base two for the 19-level case and base 1.3 for other supported level counts, with the source integer-power dependencies and the cap at 16. It then resets RBEGSPONGE to one and computes the original cubic sponge coefficient for each wave number and mapped level. Every square root, division, real power, multiplication and addition retains its source dependency and rounding point, including the zero-weighted term and the final unit-weighted power term in the shape function. The accepted exact power and exponential assembly children remain unchanged.

The original ZZDIR multiplication is retained even when its later use is inactive. The source spectral-viscosity term is calculated after all sponge coefficients. It is zero through the integer half-resolution threshold. Above that threshold it uses the original exponential, squared normalized wave number and inverse time step. Add this term to vorticity, divergence and temperature coefficients in the source loop order. Surface-pressure diffusion remains positive zero. The empty tracer owner has no numerical payload. Source diagnostic divisions are retained for their floating-point status, without adding formatted diagnostic output to the production path.

All stages preserve x18, the Arm saved integer and floating-point registers, stack alignment and FPCR. The control, allocation, calculation and release frames have 80, 192, 288 and 64 bytes. The shape child uses another 96 bytes, in addition to the accepted power child. Ordinary malloc and free own storage. The calculation has one private level-profile allocation and does not publish it. Input refusal occurs before mutation, while an allocation failure leaves all public state intact. Numerical FPSR events and errno are recorded at the ABI boundary.

Acceptance uses complete genuine source control, descriptor and owner bytes under the same patterned allocation preimage, plus an independent physical check of the sponge and viscosity identities. It also checks the real level map, source thresholds, meaningful buffer bounds, every owner allocation failure, the calculation scratch failure and immediate Arm ABI state. Only process-specific owner address words are removed during record comparison. No numerical value or source-unwritten byte is rounded, masked or replaced. The complete autonomous forecast remains a separate integration gate.

## Accepted Checks

Three complete genuine source profiles cover the current 19-level input, a four-level conventional grid and a 59-level reversed local-to-global map. They match all 38,475,792 MODEL bytes across the control, storage and arithmetic phases, plus 105,816 final coefficient-owner bytes. Immediate FPCR, FPSR and errno agree in each source and native stage. Native Arm ABI masks are zero. The complete source calculation retains its separately recorded external-source-service x18 mask of two.

A final current-input check places all four nonempty coefficient output ends, both consumed input ends and the private calculation scratch at protected memory boundaries. It again matches the complete 4,275,088-byte MODEL and 10,208 coefficient-owner bytes. All five owner allocation failures, the scratch failure, 19 atomic refusals and repeat release pass. Every protected mapping is released.

The independent check passes 3,841 physical and coefficient relations on the exact current source and native output. It uses the squared spherical-Laplacian eigenvalue, a 96-digit exponential viscosity calculation, the live mapped vertical profile, exact positive-zero mean-mode rates and non-positive continuous modal-energy tendency. Its largest residual is 0.03253 of the stated floating-point conditioning bound. This check does not change an output value. No full forecast or performance measurement is part of this component gate.


## Runtime Control-Only Entry

Define `MD2ASM_RUNTIME_DIFFUSION_CONTROLS` when assembling this source to export only `md2asm_initialize_runtime_spectral_diffusion_controls(G, Gbytes, MODEL, Mbytes, constants, Cbytes)`, with six arguments in x0–x5. This mode creates no diffusion arrays and omits the coefficient and storage entries. The default build is byte-identical to the previously qualified object, whose coefficient and storage limits remain unchanged.

Geometry has at least 17,096 mapped bytes, MODEL has at least 4,275,088 mapped bytes, and constants has at least 24 mapped bytes. The records align to eight bytes, have no address wrap and are pairwise separate. Constants are finite positive FP64 values `{RHOUR, VP00, RPLRADI}`, measured in seconds, pascals and a dimensionless scale. Require global layer count NFLEVG from 1 through 256, maximum spectral wave number NSMAX from 21 through 4,096, latitude count NDGLG greater than NSMAX+1 and at most 8,192, and positive longitude count NDLON. The local spectral layer count NFLEVL is not read by this control mode. Actual global/local counts 137/69 and 137/68 are therefore allowed here.

Retain the selected hydrostatic, semi-Lagrangian MODEL flags and the two valid in-MODEL humidity/ozone references from the default control contract. Each referenced zero control at relative byte 56 must remain inside MODEL. This mode does not read the MYLEVS layer map or hybrid-pressure VAH array. Their separate coefficient requirements are not imposed on control metadata. It writes the same 80 typed scalar fields as the selected source route, preserving every other MODEL byte. Its frame remains 80 bytes with sixteen-byte alignment, and its two private helpers make no external call. Return zero succeeds; return two rejects unsupported input before output mutation or floating-point arithmetic. Preserve x18, saved registers, FPCR, errno and incoming FPSR while adding natural arithmetic flags.

The complete original SUHDIR selector now includes the following upper spectral thresholds. Each row applies from its threshold up to the next higher row and gives the vorticity, divergence, temperature and humidity diffusion time in seconds. The previously qualified lower rows remain exact.

| Minimum NSMAX | Diffusion time in seconds |
| --- | --- |
| 3,999 | 240 |
| 2,047 | 450 |
| 1,279 | 600 |
| 799 | 1,200 |
| 511 | 1,800 |
| 319 | 2,100 |

The source sponge-layer setting KLSPONGE is 16 below 60 global layers, 8 from 60 through 90, 10 from 91 through 136, and 14 from 137 onward. The top-vorticity flag becomes true at 137 layers. Preserve all source literal kinds, separate divisions, reciprocal stores and rounding points.

A bounded gate compared 19 direct cases with a verification helper containing selected original SUDYN control statements and complete SUHDIR. It covers both sides of the six upper thresholds, all four layer settings, actual global/local counts 137/69 and 137/68, and the supported maximum dimensions. Nine refusals cover critical bounds and short capacities. Complete records, all 80 scalar fields, reciprocal identities, immediate ABI/status, protected bounds and cleanup agree. Two internal MODEL pointers use their corresponding owner and offset; every other byte compares directly. Whole SUDYN and unchanged numerical banks were not replayed, and the main Fortran executable was not rebuilt.

These results accept the runtime control entry. They do not extend the default coefficient/storage bounds of NSMAX at most 255 and global layers at most 59, or accept a complete setup, live forecast, or another resolution's forecast. Those providers must be extended from their consumed runtime metadata before a general forecast route is claimed. Unchanged numerical banks were reused without replay.

## Runtime Coefficient And Storage Mode

Build the same source with `MD2ASM_RUNTIME_DIFFUSION_FIELDS` to select the separately qualified runtime field interfaces. Diffusion reduces small-scale noise. This mode retains the original high-atmosphere pressure damping, which is needed by the 137-layer model. The default build and runtime-control build keep their separate bounds and arithmetic.

The entries are `md2asm_allocate_runtime_spectral_diffusion_storage`, `md2asm_calculate_runtime_spectral_diffusion_coefficients` and `md2asm_release_runtime_spectral_diffusion_storage`. They use the default allocation, calculation and release argument registers and record capacities. The calculation reads RHOUR in seconds, VP00 in pascals and dimensionless RPLRADI from the same 24-byte constant input. All owners stay mapped, correctly aligned and separate through their last reader. Capacity checks cannot establish that an arbitrary address is mapped, so that remains a caller obligation.

Let G be the global layer count, L the process-local layer count, N the largest spectral wave number and R the latitude count. Their live signed 32-bit fields obey these bounds.

```math
1 \leq G \leq 2\,147\,483\,646,\qquad 0 \leq L \leq G,\qquad 1 \leq N \leq 46\,340,\qquad N+1<R \leq 46\,341.
```

Longitude count is positive. These product bounds preserve the original signed integer n(n+1). Byte sizes and array positions use 64-bit integers without address wrap. The local map has exactly L integers from 1 through G and no target read when L is zero. TVAB has 512 bytes, with contiguous FP64 hybrid-pressure B and A descriptions at 64 and 128. Both arrays cover indices zero through G. These field bounds do not widen the separate upstream coordinate and control providers or establish complete-forecast support.

The selected source branch has hydrostatic ECMWF semi-Lagrangian dynamics, cubic-grid selection, spectral viscosity, no spectral tracer fields and disabled classical/semi-Lagrangian diffusion. Source-produced diffusion times are finite and greater than one second. The time step and physical constants are finite and positive. The live sponge threshold and depth are finite. REXPDH is four. Where the original top-vorticity branch is reached, its truncation lies from 1 through 46,340 and its bottom layer lies from zero through G. All five output descriptions must have their declared source shapes and valid separate owners.

| Owner | FP64 shape |
| --- | --- |
| RDIVOR and RDIDIV | L by N+1 |
| RDITG | G by N+1 |
| RDIGFL | L by N+1 by zero |
| RDISP | N+1 |

Allocation retains the source order and undefined payloads. Every empty allocation owns at least one byte. Complete GNU descriptions publish only after all five acquisitions succeed. Private failure frees partial owners in reverse order. Release follows the same reverse order and clears only the five bases. The incoming layer map and hybrid-pressure A and B owners remain borrowed.

The original pressure branch applies when half of A(1), rounded in FP64, is at most 10.5 Pa. Here A, the half-level pressure H and the layer pressure P are in pascals, B is dimensionless, and P0 is the input VP00. The dimensionless sponge threshold b selects where damping starts. Form each expression with its original separate operations and average the adjacent rounded half-level pressures.

```math
H_j=A_j+B_jP_0,\qquad P_j=0.5(H_j+H_{j-1}),\qquad z_j=\max\left\{b,\ 1+7.5\left[3-\log_{10}\left(\frac{P_j}{1\,\mathrm{Pa}}\right)\right]\right\}.
```

The pressure profile retains its complete range. The other branch retains the accepted level-based profile and source reset of b to one. Nonpositive or nonfinite pressure refuses after freeing private profile storage and before any public coefficient write.

The complete ordered PDISPEL expression stays unchanged. Wind coefficients use the local map, while temperature spans all global layers. Retain the original pressure-dependent divergence terms and later top-vorticity overwrite with its HDIRDIV divisor and default-REAL conversion. Global one-layer work starts from the original zero coefficients. Empty local wind work leaves global temperature work active. Spectral viscosity uses the original N/2 threshold below N=1,999 and N-800 from that value onward. Its original diagnostic divisions retain their source local index into the global temperature array. Every address uses the corresponding local or global leading extent.

The new runtime route calls the same public `log10` and `exp` functions as the unchanged original reference, with actual loaded bindings checked. These are allowed mathematical-library interfaces. The directly emitted power child remains unchanged. No original OpenIFS routine or state supplies a production stage. Keep separate FP64 operations, nearest-even rounding, gradual underflow, signed zeros, natural flags and errno. The application binary interface preserves x18, saved registers, stack alignment and FPCR. Frames remain 192 bytes for allocation, 288 for calculation and 64 for release, with the accepted private shape and power depths in addition. Public library internals are outside these private frame bounds.

Six source/native cases pass all 42 calls with zero differing output bytes. They cover the retained 19-layer profile, actual 137-layer pressure inputs with a reordered 17-layer local map, both selected below-91 pressure branches, N=1,999, empty local wind arrays and one global layer. Complete defined MODEL records, descriptions and payloads match with only the declared owner-address correspondence. Immediate FPCR, FPSR and errno agree. Six critical refusals preserve their declared public state, including an explicitly initialized payload preimage for invalid pressure. All 168 saved files total 191,291,832 bytes. The independent 96-digit physical check passes 727,857 relations for pressure damping, viscosity, mean preservation and non-positive modal-energy change. Native ABI checks, input preservation, complete normal release, guard and file-handle cleanup, restored verification globals and process termination pass. These are component results. Full source-ordered setup, wider upstream providers and a complete autonomous forecast remain separate work, and no timing is claimed.
