# Selected complete physics configuration

This component owns the selected state effects of `SU0PHY` in `arpifs/setup/su0phy.F90`, including its `SUDVISI` visibility settings, `SUSCM` extraction settings and four shared settings written by `SUFPC`. It composes the accepted TEPHY producer with source-derived stores for the remaining records. It accepts the live input text and uses no original OpenIFS data, method table, type object or callable. This component does not initialise all later `SUPHY` parameter records or complete an autonomous forecast.

The selected route is ECMWF physics, configuration 1, three-dimensional hydrostatic dynamics, no ARPEGE conversion, no AROME, no single-column mode and no wave coupling. The remaining fixed flags are `LARPEGEF=LAROME=LOBSC1=LSCREEN=LSFXLSM=LAQUA=LHELDSUAREZ=L131TL=LREPRO4DVAR=false`, with `NFPOS=2` and a GRIB input (`NGRIBFILE=1`). These are this producer's supported configuration, rather than reads from original global variables. The live incoming choices are `LSLAG`, `LUVPOUT` and the owned TMSE member `NSURFEXCTLMAX`.

## Interface and storage

The C ABI is `int md2asm_initialize_selected_physics_configuration(const void *text, uint64_t length, const uint64_t records[34], const int32_t controls[2], int32_t counts[5])`. Arguments use x0 through x4. The text has 1 through 262,144 bytes. Controls contain `{LSLAG,LUVPOUT}`, each 0 or 1. Counts return `{NNOGW,NEDRP,NFSD,NUVP,NAEROUT}` and must be bound to the owned GFL configuration by the enclosing caller. These counts remain computed from the actual TEPHY settings.

The 272-byte record table contains 17 pairs `{owned_data_address,capacity_in_bytes}` in the order below. It is read-only and aligned to 8 bytes. Capacities must cover the complete record sizes below. The table describes raw data records; it contains no procedure or method-table addresses. Controls align to 8 bytes and counts to 4 bytes. Record addresses align to 8 bytes, except the two records containing only 32-bit NCL and EGWDWMS controls, which align to 4 bytes. The parent rejects record intersections and intersections with text, table, controls or counts before any output write. The records must contain valid incoming data and metadata, including any array descriptors kept for later stages.

| Index | Owned record | Complete bytes | Original MODEL component |
| --- | --- | ---: | --- |
| 0 | TPHY | 1,096 | YRML_PHY_MF%YRPHY |
| 1 | TMSE | 40 | YRML_PHY_MF%YRMSE |
| 2 | TRCOEF | 368 | YRML_PHY_RAD%YRRCOEF |
| 3 | TEWCOU | 1,024 | YREWCOU |
| 4 | TARPHY | 88 | YRML_PHY_MF%YRARPHY |
| 5 | TSIMPHL | 168 | YRML_PHY_MF%YRSIMPHL |
| 6 | TPHNC | 100 | YRML_PHY_SLIN%YRPHNC |
| 7 | TPHLC | 80 | YRML_PHY_SLIN%YRPHLC |
| 8 | TELWRAD | 32 | YRML_PHY_RAD%YRELWRAD |
| 9 | TEPHY | 448 | YRML_PHY_EC%YREPHY |
| 10 | TECLDP | 2,776 | YRML_PHY_EC%YRECLDP |
| 11 | TNCL | 8 | YRML_PHY_SLIN%YRNCL |
| 12 | TEGWDWMS | 4 | YRML_PHY_SLIN%YREGWDWMS |
| 13 | TSRFTLAD | 232 | YRML_PHY_SLIN%YRSRFTLAD |
| 14 | TEPHLI | 120 | YRML_PHY_SLIN%YREPHLI |
| 15 | SCM extraction settings | 1,024 | Explicit owned replacement for YOMSCM data |
| 16 | Shared output settings | 24 | Explicit owned replacement for four YOMFPC data items |

The first 15 record layouts were measured with typed GNU Fortran 12 queries. Every source-unwritten byte remains unchanged, including complete associated descriptors, scalar fields and padding. TMSE's `NSURFEXCTL` is copied from its live incoming `NSURFEXCTLMAX`. This stage does not allocate or free arrays, initialise the whole MODEL or construct missing array owners. The enclosing owned storage layer retains those responsibilities.

The SCM record holds 32-bit `{LGSCM,NFRSCM,NSCM_SPACE_S,NSCM_ADD_SAMPL}` at bytes 0, 4, 8 and 12. FP64 `{GSCM_LON1,GSCM_LON2,GSCM_LAT1,GSCM_LAT2,GSCM_RADIUS}` occupy bytes 16 through 55. The 241 signed 32-bit `NSCMTS(0:240)` values occupy bytes 56 through 1,019; bytes 1,020 through 1,023 remain unchanged. The shared output record holds `LTRACEFP` at 0, `LFPPACKING` at 4, FP64 `RWIDOM` at 8 and `LOCEDELAY` at 16; bytes 20 through 23 remain unchanged.

## Ordered setup and input scope

The parent first validates every record and input range. It then requires the first uppercase-exact `NAMPHY`, `NAMDVISI`, `NAMARPHY`, `NAPHLC`, `NAMTRAJP`, `NAMSIMPHL`, `NAMRCOEF` and `NAMSCM` groups to be present and empty, allowing whitespace and comments. A marker is the first nonblank text within ten source columns. Lowercase duplicate markers are skipped, following original `POSNAME` selection. Member names in the accepted NAEPHY and NAMFPC readers remain case insensitive.

A private revision of the qualified output-request reader validates the actual request-only NAMFPC subset. It retains the accepted value conversion and supported request fields, while making group markers uppercase-exact and bounded to ten columns. It rejects shared-variable overrides and other unsupported keys before output mutation. The accepted TEPHY child then applies the supported eight NAEPHY members and its source consistency rules. Only after that child succeeds does the remaining store stage commit its source constants and derived integer values. Return 0 means success; return 2 means unsupported input, with all output bytes unchanged.

The remaining store table contains 358 literal store rows. These are source expressions and typed member offsets, not a captured namespace image. It keeps default REAL32 rounding before conversion to FP64 for `RMINEVP=10.0E-15`. `SUDVISI` uses its non-AROME coefficient branch. `SUSCM` writes all 241 time-selection words. `SUFPC` writes `{LTRACEFP=false,LFPPACKING=false,RWIDOM=HUGE(FP64),LOCEDELAY=true}`. Its local scientific-choice record has no selected state effect because `LMSE=false`; the supported NAMFPC subset leaves the four shared choices at their source values.

No selected expression reads physical constants. The source TSTEP reads occur only inside the disabled precipitation-diagnostic branches. These dependencies are therefore not replaced with hidden global reads or copied input-state packets. The owned constants and clock remain upstream producers for the complete forecast.

## ABI and status

The integer store and empty-group children preserve x18 and all callee-saved registers. The parent saves x19 through x28 and frame/link registers. Its 5,808-byte frame includes the 5,696-byte validation record. Private NAMFPC validation adds 6,240 bytes, for a maximum 12,048-byte stack use. The unchanged TEPHY child adds 576 bytes on its separate call route. Stack alignment is 16 bytes throughout.

Entry FPCR must equal zero, selecting round-to-nearest with gradual underflow. The utility preserves FPCR, FPSR and errno; it adds no floating-point operation to imitate omitted I/O. The original namelist and diagnostic services clear a seeded errno to zero in the retained source calls. That source I/O effect is recorded separately. An enclosing owned constants→configuration comparison starts with errno zero and returns identical complete records and immediate `{FPCR=0,FPSR=16,errno=0}` without a status adjustment after either configuration call.

## Verification and remaining scope

Four genuine whole `SU0PHY` cases compare all 7,632 returned record bytes at the same addresses, plus all 20 count bytes, with zero differences. They cover the actual input, mixed incoming flags, changed live semilagrangian/output controls, a distinct SURFEX maximum and lowercase duplicate groups before their uppercase targets. The eight immediate call observations give native ABI mask zero and exact numerical status. Twenty-two atomic rejection cases and a live buffer ending at a protected page pass. Two separate natural enclosures add complete source/direct cases after the unchanged owned constants producer, including fresh owned storage. All six cases compare 45,792 complete record bytes and 120 count bytes. The assembly-only `_start` proof emits 8,196 bytes exactly equal to the fresh source result, constants, counts and status; its executable has no dynamic section or undefined symbols.

Original formatted logging, hook calls, unit lookup, namelist-unit positioning and Fortran I/O are omitted from production. The direct parser consumes the supplied live bytes instead. Later physics-parameter setup, the whole MODEL default constructor, remaining state owners, time-loop control and full autonomous forecast admission remain separate work. Existing 685-owner and saved-file comparison rules are unchanged.
