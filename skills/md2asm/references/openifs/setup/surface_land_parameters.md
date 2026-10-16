# Selected Surface Land Parameters

The assembly owns the complete selected SUSSOIL, SUSVEG and SUVEXC producers and their complete CPTAVE and SRFROOTFR numerical children. These routines set soil water and heat properties, snow constants, vegetation properties and surface exchange constants. The selected shape has four soil layers, five snow layers, twenty vegetation types and nine surface tiles. Original OpenIFS functions, module storage, constructors, method tables and prepared state packets do not supply a production stage.

The application binary interface is `int md2asm_initialize_surface_land_parameters(controls136, TCST128, TDIM16, records48)`, with arguments in x0 through x3. The 48-byte table holds address/capacity pairs for TSOIL 2416 bytes, TVEG 776 bytes and TEXC 144 bytes. All seven complete input/table/output ranges must be mapped, eight-byte aligned, nonwrapping and mutually disjoint. The floating-point control register, FPCR, is zero: round to nearest with ties to even and gradual underflow. Return zero means success, one means allocation failure with complete private cleanup and unchanged caller records, and two means unsupported input before any caller mutation. The caller owns the outer records.

TCST comes from the owned SUSCST producer. Only RTT at zero, RPI at eight and RETV at 48 are consumed. RTT is finite and between 200 and 350 kelvin; RPI is between three and four; RETV has no negative sign bit and is between zero and two. TDIM contains NCSS four at zero, NTILES nine at four, NMONTH twelve at eight and NCSNEC five at twelve. The enclosing SUSURF_CTL must own these dimension stores before this call.

The read-only controls contain the following values. Logical values use four-byte integers zero or one; NSNMLWS is an integer from one through three. The first four FP64 controls are finite values from zero through one, including both signed zeros. The roughness lengths pass through as raw bits, including payloads that later disabled branches must not read. RPLRG is one half, one or two.

| Offset | Named value | Representation |
| --- | --- | --- |
| 0, 4, 8, 12 | LEVGEN, LESSRO, LESN09, LESNML | Four logical values |
| 16 | NSNMLWS | Integer |
| 20, 24, 28, 32, 36 | LELAIV, LECTESSEL, LEAGS, LEFARQUHAR, LEAIRCO2COUP | Five logical values |
| 40, 44, 48, 52 | LEOCWA, LEOCCO, LEOCSA, LEOCLA | Four logical values |
| 56, 60, 64 | LWCOU, LWCOU2W, LWCOUHMF | Three logical values |
| 68, 72 | LSCMEC, LROUGH | Two logical values |
| 76 | Input padding | Four uninterpreted bytes |
| 80, 88, 96, 104 | RTHRFRTI, RALFMINPSN, completed RCIMIN, RLAIINT | Four FP64 values |
| 112, 120 | REXTZ0M, REXTZ0H | Two raw FP64 representations |
| 128 | RPLRG | FP64 gravity scale |

The owned SU0PHY records supply the soil, snow, vegetation, ocean and wave controls. Owned SUDYNCORE supplies RPLRG, and the owned selected runtime supplies LSCMEC. The owned SUCT0 namespace supplies LROUGH and REXTZ0M/H; those three fields remain source-unwritten there, so the upstream selected zero namespace explicitly provides false and two positive zeros. This component copies the supplied values and does not invent their producer.

RCIMIN is the value after the SUPHEC minimum-ice guard. The enclosing caller must update the live owned TEPHY record before this batch. A negative value becomes 0.005 for dynamic sea ice without one-way ocean coupling, or 0.02 otherwise. The selected uncoupled path uses 0.02. Updating only the soil copy would leave upstream physics state wrong and does not satisfy this contract.

The three records contain 35 allocated arrays with 3544 numerical data bytes. Fresh input descriptors are entirely zero, matching the genuine fresh declared representation. Scalars and alignment bytes can have arbitrary matched incoming values. Typed queries establish every component offset; the assembly builds GNU12 descriptor metadata from named fields, bounds and strides. A rank-one descriptor has 64 bytes, and the rank-two root descriptor has 88 bytes. Metadata contains the owned base, element length and span eight, version and attribute zero, real type, rank, source offset and declared dimensions. No captured descriptor image enters production.

| Record | Array family | Source bounds | Owners |
| --- | --- | --- | --- |
| TSOIL | RCWPSISM, RMVGALPHA, RWCONSM, RMFACM, RNFACM, RLAMBDAM, RWSATM, RWCAPM, RWPWPM, RWRESTM, RDMAXM, RDMINM, RQWEVAPM, RQWSBCRM | 0 through 7 | 14 |
| TSOIL | RLAMBDADRYM, RLAMSAT1M, RRCSOILM | 1 through 7 | 3 |
| TSOIL | RDAT, RDAW, RDAI | 1 through 4 | 3 |
| TSOIL | RSNDTDESTC_ML, RLEVSNMIN, RLEVSNMAX, RLEVSNMIN_GL, RLEVSNMAX_GL | 1 through 5 | 5 |
| TVEG | RVCOV, RVLAI, RVLAMSK, RVLAMSKS, RVTRSR, RVZ0M, RVZ0H, RVRSMIN, RVHSTR | 0 through 20 | 9 |
| TVEG | RVROOTSA | Soil level 1 through 4, vegetation type 0 through 20 | 1 |

Allocation is private until all numerical work succeeds. The parent allocates the persistent owners in source allocation order, using a private copy of each outer record. Original temporary soil arrays are represented by named read-only source tables and private stack work. All numerical calculations keep source-relative order: CPTAVE, soil fields, vegetation with SRFROOTFR at its genuine call point, then SUVEXC. Independent literal stores and successful private allocations can precede arithmetic because their intermediate state is not exposed. Failure frees all new owners before return and does not expose private state.

The release ABI is `int md2asm_release_surface_land_parameters(records48)`. Its table and three output ranges satisfy the same alignment, capacity and separation rules. They contain a result from this constructor or its already released result. Release frees all 35 data owners, clears only their base words and preserves descriptor tails, scalars and padding. It returns zero and accepts an already released result. Reinitialization requires the caller to establish fresh zero descriptors again. Invalid table ranges return two. The constructor and release preserve x18, x19 through x29, the stack pointer, required low halves of v8 through v15, FPCR and incoming errno. They retain arithmetic exception flags. The parent frame is 3472 bytes; its largest owned nested path is 4240 bytes, including the 512-byte soil frame and a 256-byte numerical child. Release uses 256 bytes. External library stack work is separate.

The raw `md2asm_soil_texture_average_fields(output144)` returns zero and writes six arrays of three FP64 values: saturation water content, field capacity, wilting point, saturated conductivity, saturation potential and the Clapp–Hornberger exponent. `md2asm_vegetation_root_fraction_fields(output640, depth32)` returns zero and writes four layers for twenty types in Fortran column order. Both require valid aligned disjoint buffers and FPCR zero; they do not repeat parent guards. Internal complete field entries are void functions: `md2asm_soil_parameter_fields(TSOIL,TCST,controls)`, `md2asm_vegetation_parameter_fields(TVEG,TSOIL,TCST,TDIM,controls)` and `md2asm_surface_exchange_parameter_fields(TEXC,controls)`. They require all declared owners already allocated by this parent.

The water curve uses the source retention and conductivity laws with seven fixed soil textures. The thermal calculation uses those water capacities and source material constants. Root fractions integrate two exponential depth profiles, retain the ordered interior differences and last-layer sum, then apply the source overrides for types eight, twelve, fourteen, fifteen and twenty. Type eight still executes its source exponential work before the override. The default vegetation type zero copies type eight. No fused operation, reassociation, approximate reciprocal or reduced-precision calculation is permitted. Public scalar LOG, POW and EXP resolve to the same system libm functions as their actual genuine libsurf call edges. Heap storage uses public malloc/free, and errno storage uses the public C runtime.

Two unsuffixed source literals have special precision: 0.947 in the seven-type thermal array formula and 2.796E−3 in SSAGSNSMAX round to default FP32 before promotion to FP64. The scalar thermal formula uses its distinct FP64 0.947 literal. REPDU2 retains the product of two rounded FP64 0.1 values, which differs from the literal 0.01. Every difference remains visible in the source gate.

The source leaves seven TSOIL switches unchanged: LESNWD, LESNRF, LESNRSN, LESNWP, LESNFA, LESNCF and LESNAS at offsets 456 through 480. TVEG.LFACO2BIOFLUX at 772 is also unchanged. TSOIL padding at 4 through 7 and 492 through 495, and TEXC padding at 44 through 47, retain their incoming bytes. Those source-unwritten fields are undefined until a later genuine producer writes them and are never read as physical inputs by this batch.

One grouped gate compared all 144 CPTAVE bytes plus three complete land cases: 3336 outer bytes and 3544 numerical owner bytes per case, for 20,784 compared bytes with zero differences. The complete outer comparison joins only the 35 typed owner base words to their corresponding new allocations; every descriptor tail and every numerical or retained byte is compared directly. Original and native raw records are archived separately without masking or normalization. The selected controls and two changed switch/scale/preimage profiles pass. Native ABI checks return zero; the genuine parent retains its observed x18 violation, mask two. Natural FPCR, exception flags and errno match; raw success adds the inexact flag to the incoming flags.

Independent checks use 220-digit arithmetic and 189 physical relations. Maximum relative error is 8.46e−16 for water curves and 4.53e−14 for maximum diffusivity; the root-profile maximum absolute error is 1.42e−16. Source minimum diffusivity rounds to zero through cancellation, while its mathematical values are positive and at most 3.86e−27 square metres per second. This source limitation is retained explicitly. Nineteen meaningful rejects leave all caller bytes and status unchanged. Seven buffers end before protected pages. Allocation failures at owners one, eighteen and thirty-five free every new owner and leave all outer records unchanged; release and repeated release pass.

A separate assembly entry constructs its named inputs, calls the already accepted owned SUSCST producer, allocates all land owners, writes a 6880-byte raw stream and releases them. A PATH-only execution matches the genuine complete records through the same 35 owner identities. Its only dynamic libraries are libc and libm; its only undefined APIs are malloc, free, __errno_location, log, pow and exp. It has no original OpenIFS or Fortran runtime dependency. No full forecast, timing run or unchanged child qualification is included. Complete SUSURF, its remaining parameter children, photosynthesis and later forecast physics remain separate work.

The independent source and ABI review passes without a numerical rerun. Enclosing SUSURF setup and complete forecast admission remain separate.
