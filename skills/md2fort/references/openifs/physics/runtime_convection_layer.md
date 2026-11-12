# Runtime convection layer

This entry runs the selected `CONVECTION_LAYER` parent with live field dimensions and assembly-owned parameters. Convection transfers heat, water and momentum when air rises or sinks. The parent forwards the original typed field records to the complete accepted `CUCALLN` controller. That controller runs every selected numerical child in source order. The comparison driver supplies scientific inputs and observes results; it supplies no numerical stage.

The application binary interface (ABI) defines argument locations and saved registers. `int md2asm_runtime_owned_convection_layer(...)` receives the original 17 address arguments. Arguments 1 through 8 use x0 through x7; arguments 9 through 17 use incoming stack bytes 0 through 64. The stack is aligned to 16 bytes. Each complete record is mapped and eight-byte aligned, except the four-byte logical argument 4, which is four-byte aligned.

| Argument | Source name | Complete record bytes |
| --- | --- | ---: |
| 1 | YDSURF | 18224 |
| 2 | YDMODEL | 4275088 |
| 3 | KDIM | 192 |
| 4 | LDSLPHY | 4 |
| 5 | STATE | 1240 |
| 6 | TENDENCY_CML | 1240 |
| 7 | TENDENCY_DYN | 1240 |
| 8 | PAUX | 1992 |
| 9 | PPERT | 1584 |
| 10 | LLKEYS | 664 |
| 11 | PDIAG | 4104 |
| 12 | AUXL | 2336 |
| 13 | PERTL | 336 |
| 14 | FLUX | 5064 |
| 15 | PSURF | 13680 |
| 16 | GEMSL | 4680 |
| 17 | TENDENCY_LOC | 1240 |

Let P be `KDIM%KLON`, the number of columns, and L be `KDIM%KLEV`, the number of vertical levels. Integer admission requires 1≤P≤4096, 4≤L≤137 and PL≤65536. It also requires `align16(60PL+8P+16)≤1048576`, the one-MiB numerical work limit inherited from `CUDTDQN`. The active interval is 1≤KIDIA≤P and 0≤KFDIA≤P. KIDIA greater than KFDIA selects an empty interval. KIDIA=P+1 is refused because the complete `CUMASTRN` child has a stricter bound than the outer controller.

The caller supplies complete GNU array descriptors, whose base address, element size, rank, lower bounds and strides describe each field. Consumed fields are dense and use matching P and L dimensions. Their full mapped spans are nonwrapping and disjoint except the declared views of the same owner. `PSURF%PSD_VN` has at least the selected YACPR field-index plane. `GEMSL%ITRAC` is a scalar pointer to a live four-byte zero; it is not an inline integer. Inactive tracer arrays have zero size. These descriptor and ownership conditions are caller obligations; the raw entry checks top-level addresses, dimensions, work bounds, floating-point control and selected source controls.

The selected route uses nonlinear physics, prognostic clouds and enabled convective downdrafts. It requires LPHYLIN=false, LEPCLD=true, LMFDD=true and NRFTOTAL=0. Actual source-produced RVDIFTS is 1.5. Original `CUCALLN` skips the diagnostic-cloud `CUSTRAT` call when LEPCLD=true and LPHYLIN=false, so that unchanged child's separate coefficient limit is dormant. Linear physics, stochastic perturbations and active tracer transport remain outside this selected provider.

The live-owner factory uses the accepted header and SUDIM scalar producers, the actual 137-level vertical Geometry and its complete standard-atmosphere pressure profile. It follows source order: publish the initial one-second TSPHY value; run the accepted physics setup prefix, including SUCUMF and its thermal publications; run unchanged SUCLDP with that initial interval; then publish the current 450-second coefficients and final radiation controls NRADFR=8. The selected thermal source explicitly sets RVTMP2=0 to omit the moist heat-capacity correction. A later current-time value is not substituted into initial setup.

The accepted guarded step publisher writes the caller's current KSTEP, from 0 through 8, to both distinct owned clocks. Configuration clock 360 and namespace clock 360 keep 356 other bytes equal. The actual `__yomct3_MOD_nstep` alias is the namespace clock address plus 36, and the numerical controller's relocated global-offset-table cell points to that address. A global offset table is a linker's table of resolved symbol addresses. Physical 520 and dynamical 320 agree with their actual configuration records, while the accepted prefix owns thermal 1920. Separate original module storage is populated only for verification. The native numerical closure is local and uses symbol binding that keeps its own accepted providers.

Success returns 0 after all selected calculations. Under the selected inactive hook policy, unsupported entry admission returns 2 before writes or child calls. All Arm saved registers, the low 64 bits of d8 through d15, x18 and the stack pointer are preserved. FPCR, the floating-point control register, must be zero: this selects the frozen rounding and gradual-underflow rules. Numerical operations retain their natural FPSR exception flags. The parent has an 8192-byte frame, no parent heap allocation and no retained private pointer. Accepted children own their existing work allocation and release. Their inherited fatal errors remain outside supported input admission; this wrapper adds no child rollback service.

The linked hook policy is the accepted read-only false word __yomhook_MOD_lhook. The NRFTOTAL admission check follows the original profiling-entry position. Its atomic refusal therefore relies on this inactive owned hook policy. Other admission guards precede that position. The original source profiling order is unchanged.

The same shared source holds the original 17-to-76 argument map for both the new entry and the legacy entry. The existing first-element address helper is also shared. Expanding the includes preserves the complete legacy instruction stream and the complete legacy object. All 19 numerical closure objects, including the required private aliases, remain unchanged. The old default keeps its accepted fixed dimensions.

The initial gate compares 12 genuine source/native pairs at P=1,8,17 and L=137, using full, partial and empty active intervals, two protected buffer placements, selected surface planes 1 and 3, and steps 0,1,7,8. It compares 60,718,768 complete nominal owner and defined-status bytes with zero differences. Each case retains 97 complete owners, including all input records, nested arrays, parameter owners and clock records. Source and native reuse the same addresses with a full reset, so pointer words compare literally. No pointer encoding is removed. The status packet contains FPCR 8 bytes, FPSR 8 bytes and errno 4 bytes; unread padding and the original void return register are excluded.

All selected columns in these six new cases return LDCUM=0 and KTYPE=0, which means no convective plume is activated. These cases newly check the enclosing argument map, actual producer association, inactive return, flux identities and boundaries. The additional active-column check below extends this new caller coverage without repeating those inactive cases.

One additional warm, humid P=1, L=137 column uses the actual source-produced full-level and half-level pressure grid. Both genuine parent entries activate deep convection with LDCUM=1 and KTYPE=1, and the updraft mass flux is positive. This pair compares another 4,491,192 complete owner and defined-status bytes with zero differences and adds 2,208 independent flux relations. The combined new qualification therefore has 13 source/native pairs, 65,209,960 nominal comparison bytes and 210,096 independent relations. All earlier passing pairs and unchanged child proofs are reused.

The initial independent checker evaluates 207,888 pressure-weighted water, heat and momentum flux relations across both routes with 120-digit arithmetic. It also checks 254,016 preserved inactive words. For each level it integrates the net tendency using the pressure thickness divided by gravity, then accounts for liquid and frozen precipitation and condensate transfer. Source-written provisional humidity is checked on active columns and used in the heat-capacity relation. Unwritten private humidity outside that interval has no defined source value and is not counted as a complete output owner.

Sixteen critical admission refusals preserve 78,023,104 complete owner and defined-status bytes and make zero numerical child calls. They cover shape and cell limits, the one-MiB work limit, active bounds including P+1, selected cloud and physics controls, perturbations, null or misaligned outer pointers and FPCR. Every native ABI observation is zero. The original Fortran may change x18; its observed ABI mask is retained separately. Four earlier passing pairs are reused after an exact one-byte change to the new integer guard; all their admitted branches and numerical instructions are unchanged. The retained pointer-fixture failure and unwritten-private-trace checker finding are documented locally.

The numerical process uses an eight-GiB address-space limit, a 128-MiB stack limit, a two-GiB observed resident-memory cutoff and a 120-second cutoff. The conservative nested native stack bound is 12 MiB. Complete mapped fixture bounds and the actual observed memory are retained locally. This gate uses constructed weather columns with actual parameter and clock producers. It does not accept a loaded-weather CALLPAR, a complete setup, an autonomous forecast loop or a changed numerical child. The 137-level live-producer route is the newly checked case; other valid raw dimensions still require matching source-produced parameter records and the unchanged children's admitted domains.

The clock and interval interfaces are described in [current step publication](../setup/operational_step_clock_publication.md), [initial physics interval](../setup/initial_physics_interval.md) and [current time coefficients](../dynamics/operational_time_coefficients.md).
