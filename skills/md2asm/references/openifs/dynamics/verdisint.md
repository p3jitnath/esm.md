# VERDISINT vertical operators

Revision 1.2 freezes the defined GNU FP64 vertical interface for the [physical formulation](../../../../../formulations/openifs/dynamics/vertical_operators.md). The complete dependency set is [VERINT](verint.md), [VERDER](verder.md) and the [ordered matrix function](strict_matrix.md). Original utility/verdisint.F90, utility/verint.F90 and utility/verder.F90 are preserved in the local source manifest. This is a new arithmetic baseline; older CrayBLAS forecasts remain separate.

## Grid, units and complete selection

Let L=KFLEV be the number of full levels, P=KPROMA the horizontal pitch, N the input-column count, M the output-row count, and IND the first physical input column. Eta increases from zero at the top to one at the ground and is dimensionless. Supplied matrices determine all input and output locations. SUNH_VERTFESPLINE constructs ordinary integral rows at VFE_ETAF(1:L+1), which are full levels followed by the ground, rather than locations inferred only from old helper comments. There is no time update.

Resolve IBC from optional KBC when present. Otherwise use TCVER%NVFE_INTBC for ITOP, IBOT and INGW, or NVFE_DERBC for DEGW, HDER, FDER and DDER. Require LVERTFE true. Known operation strings have four uppercase bytes. CDBC has two bytes, each zero or one; its first digit describes the top and second the bottom, with zero prescribing the value and one prescribing its first derivative. IBC is an integer from zero through three.

First apply the following source size decisions. Then integrals with IBC=1 or 3 change IND to zero and N to L+2. Finally CDBC=00 forces IND=0 and N=L+2 for every operation. Preserve this order.

| Operation | Initial IND | Initial N | M | Integral type |
| --- | ---: | --- | --- | --- |
| ITOP | 1 | L | L+1 | 0 |
| IBOT | 1 | L | L+1 | 1 |
| INGW | 0 | L+1 | L+1 | 1 if IBC=0, otherwise 0 |
| DEGW | 0 | L+2 for IBC=1/3, otherwise L+1 | L+1 | none |
| HDER | 0 for IBC=1/3, otherwise 1 | L+2 for IBC=1/3, otherwise L | L+1 | none |
| FDER, DDER | 0 for IBC=1/3, otherwise 1 | L+2 for IBC=1/3, otherwise L | L | none |

Select the matrix from the complete source decision table. A matrix suffix xx is the supplied CDBC. HDER first requires RDERBH00 allocated, even when its final matrix is a replacement. Every selected matrix must be allocated and have exactly M rows and N columns.

| Operation | IBC | CDBC | Selected matrix |
| --- | --- | --- | --- |
| INGW | 0 | any | RINTE |
| INGW | 1/2/3 | any | RINTGW |
| ITOP, IBOT | 0 | any | RINTE |
| ITOP, IBOT | 1/3 | 00 | RINTBF00 |
| ITOP, IBOT | 1/3 | 01/10/11 | RINTBF11 |
| ITOP, IBOT | 2 | 00 | RINTBF00 |
| ITOP, IBOT | 2 | 01/10/11 | RINTBF11_IMPL |
| DEGW | any | any | RDERGW |
| HDER | any | 00 | RDERBH00 |
| HDER | 2 | 01 | RDERBH01_IMPL |
| HDER | 3 | 01 | RDERBH01 |
| FDER | 0 | any | RDERI |
| FDER | 1/3 | any | RDERBFxx |
| FDER | 2 | 01/10/11 | RDERBFxx_IMPL |
| DDER | 0 | any | RDDERI |
| DDER | 1 | 00 | RDDERI |
| DDER | 1/3 | 01 | RDDERBF01 |
| DDER | 2 | 11 | RDDERBF11_IMPL |
| DDER | 3 | 11 | RDDERBF11 |

The source explicitly aborts HDER with 10/11, HDER with 01 and IBC=0/1, FDER with 00 and IBC=2, DDER with 10/11 and IBC=1, DDER with selectors other than 11 and IBC=2, and DDER with 00/10 and IBC=3. Preserve these 18 rejection cases and unallocated-matrix rejection.

## Defined domain and source defects

Support P>=1, L>=1, 1<=KSTART<=P and KSTART-1<=KPROF<=P. KPROF is the inclusive last point, not a count. Nonempty derivatives require KSTART=1; this contract also uses one for empty derivative calls. Integrals permit any valid start outside parallel regions and require KSTART=1 inside them. Integral KCHUNK is positive when present and defaults to one. Derivatives ignore it. Used inputs, coefficients, products, sums and bottom differences are finite FP64, including signed zeros and subnormal values. Buffer-size and address arithmetic fit signed 64-bit values.

Among the 112 operation/IBC/CDBC combinations, 57 have defined source results under the stated allocation and row restrictions. They are ITOP/IBOT with any IBC and CDBC=01/10/11; DEGW with IBC=0/2 and CDBC=01/10/11; every HDER/00 plus HDER/01 with IBC=2/3; FDER with IBC=0 and CDBC=01/10/11, IBC=1/3 and any CDBC, or IBC=2 and CDBC=01/10/11; and DDER with IBC=0 and CDBC=01/10/11, IBC=1 and CDBC=01, IBC=2 and CDBC=11, or IBC=3 and CDBC=01/11.

The other 37 combinations have undefined source behavior and are explicitly rejected by the direct interface. They are every INGW, every ITOP/IBOT with 00, DEGW with IBC=1/3 or 00, FDER with IBC=0 and 00, and DDER with IBC=0/1 and 00. Integral local boundaries are never copied from PIN, and the 00 branches consume uninitialised local values. Every INGW consumes an uninitialised local boundary. Some requested N values also exceed the allocated matrix's columns. Allocatable assignment can resize ZOPER but does not correct the N passed to a helper. No replacement value or corrected boundary is invented for these cases.

The defined ITOP/IBOT branches with CDBC=01 or 10 preserve the source choice of RINTBF11 or its implicit version. With IBC=1/3, the local top and bottom values are both positive zero, and the matrix interprets them as homogeneous derivative constraints. These branches do not implement general mixed value/derivative boundaries suggested by 01 or 10. IBC=0 uses RINTE for every nonzero selector. The confirmed T21 path uses 11 and IBC=3. General mixed integral boundaries require an upstream scientific correction and a new contract.

These restrictions preserve the defined numerical source rather than repairing upstream science. Supporting the rejected combinations requires a source correction, independently verified boundary and inverse-operator definitions, and a new contract. In this OpenIFS tree, inverse/half spline setup alternatives are aborting stubs. The supplied DEGW matrix remains a defined linear-map interface, but its actual inverse-grid science cannot be certified from those stubs.

## Complete arithmetic stages

For integrals, copy active interior PIN(:,1:L) bits to private FP64 ZIN. With IBC=1/3 and CDBC different from 00, set active local columns zero and L+1 to positive zero. IBC=2 selects an implicit L-column matrix and uses only copied interior values; the source's unused endpoint writes do not affect its result. IBC=0 also uses only the interior. Derivatives use original PIN(:,IND:IND+N-1); their source ZIN copy is unused.

Apply VERINT to the complete selected integral matrix or VERDER to the derivative matrix. Both include the complete ordered matrix reduction with separately rounded product and sum for each increasing input column. ITOP returns Q. IBOT obtains every Q first, then returns RN64(Q(p,r)-Q(p,M)), including positive zero at the ground. Derivatives return Q with no extra arithmetic. No driver supplies a stage. An immutable matrix can be read directly instead of copying its identical bytes into ZOPER.

Use FPCR=0 and preserve it. Preserve signed zeros and gradual underflow. Forbid fused operations, contraction, reassociation, approximate arithmetic, reduced precision and fast-math. Profiling hooks are outside the numerical body; the VERINT parallel-state query remains required.

## Storage and measured GNU ABI

PIN has P*(L+2) eight-byte FP64 values in Fortran column order, with physical column zero at its pointer. Address (p,j) is PIN+8*((p-1)+P*j). POUT row one is at its pointer, with address (p,r)=POUT+8*((p-1)+P*(r-1)). ITOP, IBOT, HDER and DEGW require P*(L+1) output values. FDER and DDER require only P*L; GPXX really supplies that smaller allocation although the wrapper dummy declares L+1. Preserve all inactive output bytes and all input, coefficient and configuration bytes. Outputs are separate from all other objects, and arrays are aligned to eight bytes.

The storage-only GNU 12.3 probe establishes four-byte integers, eight-byte JPRB/JPRD, TVFE size 2176 and TCVER size 216. TCVER default integral and derivative IBC offsets are 36 and 40, and LVERTFE is at 52. TVFE begins with a 64-byte rank-one descriptor and then contains 24 rank-two descriptors of 88 bytes.

| Matrix | Byte offset | Source allocation rows, columns |
| --- | ---: | --- |
| RINTE | 64 | L+1, L |
| RINTBF00 | 152 | L+1, L+2 |
| RINTBF11 | 240 | L+1, L+2 |
| RDERI | 328 | L, L |
| RDERB | 416 | L, L+2; not selected |
| RDERBF00/01/10/11 | 504/592/680/768 | L, L+2 |
| RDERBH00/01 | 856/944 | L+1, L+2 |
| RDDERI | 1032 | L, L |
| RDDERBF01/11 | 1120/1208 | L, L+2 |
| RINTBF11_IMPL | 1296 | L+1, L |
| RDERBF01/10/11_IMPL | 1384/1472/1560 | L, L |
| RDERBH01_IMPL | 1648 | L+1, L |
| RDDERBF01/10/11_IMPL | 1736/1824/1912 | L, L |
| RINTGW/RDERGW | 2000/2088 | L+1, L+1 |

Within each rank-two descriptor, the data pointer is at zero, element size at 16, and span at 32. Dimension-one stride/lower/upper fields are 40/48/56; dimension-two fields are 64/72/80. Require eight-byte element size and span, first stride one and second stride M, and extents M,N. Descriptor lower bounds do not change contiguous stored element order. The element-offset word at eight is not a byte offset.

Export verdisint_ by default, with VERDISINT_ENTRY, VERINT_ENTRY and VERDER_ENTRY available at assembly time for isolated comparison symbols. Registers x0 through x7 contain addresses of TVFE, TCVER, CDOPER, CDBC, P, KSTART, KPROF and L. Incoming stack offsets 0/8/16/24 contain PIN, POUT, optional KBC and optional KCHUNK pointers; null means an absent optional. Offsets 32/40 contain the hidden character lengths by value as eight-byte size_t, exactly four and two. Preserve x19 through x29, the link register and required low halves of v8 through v15; keep SP aligned to 16 bytes and leave x18 unused.

## Input corpus, output encoding and acceptance

Before emission, freeze the formulation and all four contracts, source manifest, measured ABI/layout, dispatch dossier, analytical coefficient fixtures, and captured T21 matrix/grid hashes in a local freeze record. Assembly is emitted directly from these Markdown equations, stages, dimensions and ABI, with no compiler solver instructions or intermediate representations used to construct its body. Compiler output can be inspected afterwards to audit the unchanged comparison.

One critical C verifier covers all 57 defined numerical selections, all 112 emitted dispatch records and their 18 source aborts and 37 undefined classifications, allocated-matrix failures, optional/default IBC, integral chunks, helper row restrictions, empty work, and exact capacity bounds. One real ABOR1 call establishes the common rejection path, while read-only dispatch metadata checks every classified combination without repeating expensive failure diagnostics. Independent rational interpolation matrices use eta=1/2 for L=1, eta=1/4,3/4 for L=2, and eta=1/4,1/2,3/4 for L=3. Boundary-conditioned matrices are derived by exact rational polynomial interpolation with value or derivative constraints, separate from OpenIFS coefficient construction. Fields include compatible constants and polynomials through degree four; incompatible homogeneous endpoints are not used as analytical targets. Rectangular half-level test outputs are eta=0,3/8,5/8,1 for L=3.

The fixed corpus also uses actual L=19, P=1/8/19/24/506, chunks1/24 and partial final chunks, captured T21 matrix/grid bits, signed positive and negative moisture rates, hydrostatic isothermal pressure, water and dry-mass budgets, signed zero, minimum subnormal and cancellation witnesses. Buffer guards and protected array ends check actual L-column derivative output and final input tails. The actual inverse DEGW interface is checked as a separately declared linear-map fixture; no unavailable upstream inverse-grid construction is inferred.

Compare direct and unchanged renamed Fortran complete outputs and guard bytes with zero differing bytes. Preserve input, object and matrix bytes. On a mismatch, report the first call, operation, IBC, CDBC, stage, point, row and both FP64 bit patterns. Independent analytical fixtures must have absolute error at most 4096*DBL_EPSILON*max(1,abs(expected)); actual T21 constant integrals must have absolute error at most 1e-11 times max(1,abs(input scale)). The actual compatible constant and isothermal fields use that constant-integral limit. The actual homogeneous-endpoint quartic has a declared absolute discretisation-error limit of 1e-6 for its unit input scale; the old coefficient capture has an independently evaluated error of 4.49e-7 or less. This finite-element approximation is not claimed to reproduce degree four exactly. Finite admissibility, integral direction and ground positive zero are mandatory, regardless of exact agreement.

The verifier's canonical output is deterministic little-endian call records. Each 64-byte header contains uint64 call number, uint32 entry identifier, uint32 flags, eight int32 values P/start/end/L/N/M/IBC/chunk, four operation bytes, two CDBC bytes, uint16 reserved zero, and uint64 appended-value count. Entry identifiers one through four identify matrix, VERINT, VERDER and VERDISINT. Flags describe the declared guarded/protected/parallel fixture class; flag bits zero/one/two mean guarded/protected/parallel; bits three/four report present optional KBC/KCHUNK, and bit five selects a relative analytical tolerance scaled by max(1,abs(expected)). Append every FP64 output value in Fortran storage order, including inactive values, followed by two leading and two trailing guards for guarded calls. Failed/rejected subprocess cases have no numerical record. Exclude pointers, clocks, allocation addresses and timing.

Build a separate public Fortran baseline library and renamed reference objects using only the private direct matrix dependency. After independent checks, create a new complete Fortran forecast archive and compare genuine mixed-run visits and every saved output file against it. Keep earlier archives unchanged. The trace-only old forecast establishes selection and storage, not acceptance of the old system BLAS arithmetic. No benchmark, tuning result or performance conclusion is authorized here.

## Read-only verification metadata

Revision 1.1 adds the hidden object verdisint_dispatch_metadata_, which holds the existing 112 eight-byte dispatch records in operation order ITOP, IBOT, INGW, DEGW, HDER, FDER, DDER, then increasing IBC and CDBC=00,01,10,11. Each record contains uint16 matrix descriptor offset, uint8 IND, uint8 N-L, uint8 M-L, uint8 integral type, uint8 status and uint8 reserved zero. Status zero is defined, one is undefined source, and two is an explicit source abort. The verifier reads this immutable object and checks all source classifications and every defined matrix/shape against the frozen corpus. This addition changes no numerical instruction, selected matrix, arithmetic dependency or input bit.

Intentional failure children use RLIMIT_CORE=0, preserve the real ABOR1/MPL_ABORT path and require SIGABRT or its declared exit status. A verifier-only diagnostic hook replaces LinuxTraceBack output with compact text, so traceback symbol resolution does not consume the allocation memory. This hook is absent from every solver and baseline library. Source profiling uses __yomhook_MOD_lhook=0 in standalone numerical checks, as permitted by the profiling exclusion above.

The standalone driver calls the real Fiat OML_INIT subroutine outside parallel regions before children or teams are created; OML_IN_PARALLEL is only a state query and does not initialize that runtime. This runtime initialization adds no numerical stage. Default-selector fixtures set the unused integral or derivative default to a different IBC, so selecting the wrong TCVER field cannot pass. Protected fixtures use first and second matrix lower bounds -2 and 7 with the correctly measured element-offset word, which checks contiguous data independently of lower bounds.

Revision 1.2 changes only verification runtime handling. One actual undefined-branch rejection uses the common ABOR1 path, zero core size, a one-megabyte diagnostic-file limit, a ten-second diagnostic timeout, and explicit child reaping. All 112 immutable dispatch records remain checked, and the genuine valid parallel numerical fixture remains included. Failed diagnostic runs are preserved separately; they are not accepted runs. Numerical instructions, arithmetic and the frozen binary corpus are unchanged.

## Complete forecast comparison

A caller-scoped C interposer exposes the original VERDISINT, VERINT and VERDER entries and their direct-entry counterparts. Internal numerical object symbols are renamed only to complete_assembly names; their instruction bytes are unchanged. Complete source dispatch uses the accepted public original-Fortran library, while exposed direct helper stages use the accepted unchanged renamed helper reference objects. No global DGEMM symbol is intercepted and no numerical stage is supplied by the driver.

Use one mutex around top-level calls and thread-local nesting state. Optional vertical_forecast_reference_begin/end hooks only mark source-shadow phases in other complete-routine drivers. Count unmarked top-level original or direct dispatch visits as genuine. Nested direct helper calls are private checks, and marked source-shadow visits are comparison-only. Capture every used matrix byte, every complete input allocation, every incoming and final output byte, and immutable configuration. Verify all input, coefficient, scalar, character, TVFE and TCVER bytes after each implementation; verify FPCR zero before and after each stage. Normalize only descriptor pointer words in captured configuration metadata; compare original pointer words for immutability, and preserve every numerical input and output bit.

The three streams are vertical-fortran.bin, vertical-assembly.bin and vertical-inputs.bin. Every record begins with a 256-byte little-endian header: magic VRTF0001 at0; uint64 record, genuine-visit and parent-record identifiers at8/16/24; uint32 stage and flags at32/36; int32 step at40; twelve int32 values P,start,end,L,N,M,IBC,type,chunk,descriptor_offset,IND,reserved at44; operation and boundary bytes at92/96; a NUL-padded64-byte caller symbol at100; uint64 output/input/matrix/configuration byte counts at168/176/184/192; four int64 matrix lower/upper bounds at200; two int64 strides at232; and uint64 FPCR at248. All unused header bytes are zero. Stage1 is VERDISINT,2 is VERINT and3 is VERDER. Flags bit0 means genuine,bit1 parallel,bit2 explicit KBC,bit3 explicit KCHUNK andbit4 comparison-only.

The paired output streams append the complete final POUT allocation to each header, including inactive bytes. The input stream appends complete PIN, complete incoming POUT, complete selected matrix and normalized configuration, in that order. Wrapper PIN has P*(L+2) values; wrapper POUT has P*(L+1) for integral/half/inverse results or P*L for full derivatives. Helper PIN has P*N values and POUT has P*M. Wrapper normalized configuration contains2176 TVFE bytes then216 TCVER bytes; helper records have no separate configuration. Private helper records finish before their parent dispatcher record, and parent identifiers preserve that relationship. Pointer addresses, clocks and profiling counts are excluded from deterministic metadata.
