# SIGAM hydrostatic operator

Revision 1.4 records the complete SIGAM operator and its accepted forecast calls. The numerical operator remains frozen at revision 1.0, with the independent unit-amplitude science limit recorded at revision 1.2. Numerical inputs and assembly are unchanged. The basic physics is [hydrostatic balance, P02](../../../../../formulations/openifs/dynamics/hydrostatic_balance.md), with its horizontal use explained by [pressure force](../../../../../formulations/openifs/dynamics/pressure_force.md). No new physical formulation is required.

## Physical meaning and source

SIGAM supplies the linear hydrostatic part of the semi-implicit forecast. A semi-implicit method treats selected fast terms with an implicit time update, while other terms use explicit values. SIGAM is an operator within that method; it does not advance time itself.

Temperature input T has units of kelvin for a spectral column. Surface input Pi is a perturbation of the logarithm of surface pressure and has no unit. RD is the dry-air gas constant in joules per kilogram per kelvin. The supplied coefficient mu, named SIRPRG in the source, is RD times the reference temperature and has units of square metres per second squared. Output G is the potential contribution Gamma T plus mu Pi, in square metres per second squared.

LASSIE instead passes horizontal gradients. Its temperature input has units of kelvin per metre, its surface input has units of inverse metres, and its output is a potential gradient in metres per second squared. The source name PD is reused work storage; its header description as divergence does not describe this returned operator.

The canonical source is OpenIFS 48.1.1 arpifs/adiab/sigam.F90, copied unchanged to the ignored preparation directory. Its SHA-256 is 6d56f81fd6b769530b1a1916d0ea208057309ec4f02f18f09c653f5892f83c0a. Source setup in sudyn.F90 supplies SIRPRG=RD*SITR. Setup in susi.F90 obtains SILNPR and SIALPH from GPHPRE at the reference surface pressure. The arrays and their bits are operator inputs, and this routine does not recompute them.

The only numerical dependency is [the accepted complete vertical operator](verdisint.md). The original Fortran reference uses the same privately scoped ordered matrix dependency as that accepted operator. This is the strict vertical baseline, identified by libstrict-vertical-reference.so SHA-256 20c17f295a8fd699aa166a28d22b9e71dfa8581bb34dae88aabbd987a2b05ba4. It makes no claim to match the former system BLAS reduction.

## Shapes, boundaries and mutation

Let L be KFLEVG, C be KNLON, a be KLEV and b be KLON. Both strides are positive integer element counts. Levels increase downwards. The one-based address index is:

~~~math
I(l,c)=1+(l-1)a+(c-1)b,\qquad
1\le l\le L,\quad 1\le c\le C.
~~~

All addressed output cells must be distinct. With h=gcd(a,b), this holds when L is at most b/h or C is at most a/h. Grid storage uses a equal to the allocated horizontal pitch and b=1; spectral storage uses a=1 and b=L. The test also includes a general disjoint layout.

The formal PT and PD extent is H=max(0,1+(L-1)a+(C-1)b) elements. PSP has C elements. The caller supplies disjoint input and output storage, aligned to eight bytes. Every inactive PD cell within the allocated buffer retains its incoming bits. PT, PSP, all coefficient arrays, every configuration byte and RD remain unchanged. Fortran explicit-shape association does not add array descriptors to these three argument pointers.

Finite-element calls require L and C positive, the accepted IBOT/11 domain, IBC in 0 through 3, and positive NPROMA. Conventional calls also support C=0 or L=0 with no PD writes and no dependency call. Negative dimensions, overlapping output indices, overflowed extents, absent used allocations, and unsupported finite-element dispatch are outside this contract; they are not silently repaired.

SIALPH and SILNPR are GNU rank-one allocated contiguous arrays with lower bounds at most one and upper bounds at least L. Finite-element RDETAH has the same bounds requirement and contiguous allocated storage, as declared in TVETA. Lower bounds can differ between arrays. The selected vertical matrix is a contiguous allocated rank-two array with arbitrary valid lower bounds and the exact dimensions required by its accepted dispatch. IBC 0 uses RINTE, IBC 1 and 3 use RINTBF11 with two zero endpoint columns, and IBC 2 uses RINTBF11_IMPL.

Every used value and every intermediate result is finite. Signed perturbations, signed zeros and subnormal values are supported. Positive hydrostatic reference coefficients define the physical identities, while the arithmetic-edge fixtures protect representable signed inputs. Address extents and scratch sizes must fit signed 64-bit arithmetic, and scratch allocation must succeed. The actual source integer index must fit a signed 32-bit JPIM.

## Ordered binary64 arithmetic

RN denotes one correctly rounded binary64 operation using round-to-nearest with ties to even and gradual underflow. Each multiplication, addition and subtraction below is separate. No fused multiply-add, contraction, reassociation, reduced precision, approximate operation, fast-math or output normalization is allowed. FPCR is zero at entry and return.

### Conventional vertical discretisation

For each column, set the bottom accumulator A at level L to positive zero. Visit levels L down to one. Define alpha(l)=SIALPH(l) and lambda(l)=SILNPR(l). At each level, preserve the old accumulator before computing the next accumulator and output:

~~~math
u_l=\operatorname{RN}(RD\,T_{l,c}),\qquad
v_l=\operatorname{RN}(u_l\,\lambda_l),\qquad
A_{l-1}=\operatorname{RN}(A_l+v_l),
~~~

~~~math
w_l=\operatorname{RN}(\alpha_l\,RD),\qquad
x_l=\operatorname{RN}(w_l\,T_{l,c}),\qquad
y_l=\operatorname{RN}(A_l+x_l),\qquad
p_c=\operatorname{RN}(\Pi_c\,\mu),\qquad
G_{l,c}=\operatorname{RN}(y_l+p_c).
~~~

The output uses the old accumulator A_l, which represents the complete layers below the current layer. The two temperature products have different first operands and must not be merged. The direct body retains the live accumulator in a register because the source scratch accumulator is not returned. It preserves every rounding point and the descending reduction order.

### Finite-element discretisation

Let r(l)=RDETAH(l), the reciprocal coordinate-layer width, and let eta increase from zero at the model top to one at the surface. Construct every interior integrand value and both endpoint rows inside the direct routine:

~~~math
u_l=\operatorname{RN}((-RD)\,T_{l,c}),\qquad
v_l=\operatorname{RN}(u_l\,\lambda_l),\qquad
F_{c,l}=\operatorname{RN}(v_l\,r_l),\qquad
F_{c,0}=+0,\quad F_{c,L+1}=+0.
~~~

Negate RD before the first multiplication. The dependency call is VERDISINT(VFE,CVER,'IBOT','11',C,1,C,L,F,Q,KBC absent,KCHUNK=NPROMA). Its ordered matrix products visit input columns in increasing order, beginning each dot product at positive zero, with a separate multiply and add. The bottom boundary computes Q(c,i)=RN(S(c,i)-S(c,L)), where S is the matrix integral at each row. This stage includes the matrix selection, boundary rows and nested integral call.

~~~math
p_c=\operatorname{RN}(\Pi_c\,\mu),\qquad
G_{l,c}=\operatorname{RN}(Q_{c,l-1}+p_c).
~~~

F has C times (L+2) values in column-major order. Q has C times (L+1) values. The direct routine allocates this live scratch, initializes all required F values, calls the complete accepted dependency, forms every output and frees the scratch. No comparison driver supplies a missing numerical stage.

The dependency accepts KSTART=1 for calls inside a parallel region; SIGAM always passes one. The driver must initialize the OML runtime outside parallel regions before creating a genuine parallel fixture. Production callers already do so. Profiling hooks are excluded from the numerical reference and disabled in the standalone driver.

## AArch64 ABI and storage

The entry symbol is sigam_assembly_. Arguments are ordinary by-reference Fortran arguments: x0 is GEOMETRY, x1 is TDYN, x2 points to KLEV, x3 points to KLON, x4 is PD, x5 is PT, x6 is PSP and x7 points to KNLON. The pointer to KFLEVG is at incoming stack byte zero. There are no hidden character lengths.

The GNU 12.3 storage-only probe gives GEOMETRY size 17096 bytes and TDYN size 4720 bytes. GEOMETRY holds YRVETA, YRVFE and YRCVER pointers at byte offsets 3248, 3256 and 3264; NPROMA is a four-byte integer at offset 5144. TDYN holds SIRPRG at 2560, the SIALPH descriptor at 2600 and SILNPR at 2664. TVETA holds its RDETAH descriptor at 256. CVER holds LVERTFE at 52 and the default integration boundary at 36.

A rank-one GNU descriptor has base pointer, element offset, element size, type word, span, stride, lower bound and upper bound at byte offsets 0,8,16,24,32,40,48,56. Here element size and span are eight, the type word is hexadecimal 0000030100000000, and the allocated stride is one. Logical element j is at base plus eight times (element_offset+j). The rank-two vertical descriptor and its fields follow the accepted dependency contract.

The nested call passes VFE,CVER,'IBOT','11',C,1,C,L through x0 to x7. Its outgoing stack holds F,Q,NULL,NPROMA pointer,hidden length4,hidden length2 at offsets 0,8,16,24,32,40. This uses 48 bytes and preserves 16-byte stack alignment.

The body preserves x19 through x29, the link register and the lower 64 bits of v8 through v15, leaves reserved x18 unused, and preserves FPCR. It uses scalar Arm binary64 arithmetic and the accepted dependency. Shipping numerical code is emitted directly in assembly and built with an assembler and linker. Compiler numerical instructions and intermediate representations are not consulted before emission.

## Frozen critical verification

The ignored preparation corpus revision1 has 51 records and 835536 bytes. Its SHA-256 is c13df6ceba2c0af75f72cbd7990b2a772a3c5232e772351f5f3f645b78c85158. The complete allocated PD spans contain 375464 returned bytes per implementation. Configuration bits, lower bounds, dimensions, source and module hashes are frozen alongside it before emission.

Each corpus record begins with a 128-byte SIGF0001 header. Little-endian words at offsets 8 through 64 encode case number,branch,IBC,L,C,a,b,NPROMA,pattern,flags,coefficient lower bound,matrix lower bounds,RDETAH stride and lower bound. RD and mu occupy bytes 80 and 88, H occupies 96, matrix rows and columns occupy 104 and 108, and the physical tolerance and identity code occupy 112 and 120. Reserved bytes are zero. Payloads store complete PT,PSP,SIALPH,SILNPR,RDETAH,selected matrix and independent target spans as unaltered binary64 values.

The small-grid integral matrix represents a piecewise-constant profile with a half-cell contribution at each full level. Constant temperature gives G=RD*T*(1-eta)+mu*Pi. A linear midpoint profile has an independently computed closed arithmetic-series integral, which tests the descending layer contribution and the half-cell term without reproducing the source recurrence. Pure pressure with zero temperature gives mu*Pi independently of level. Targets are calculated with 100-digit decimal arithmetic and then rounded once for storage.

The corpus includes levels1,2,3,7,19 and columns1,3,7,17,24,65,506, all four integral boundary codes, inactive holes, lower bounds1 and -2, arbitrary matrix lower bounds, signed-zero/subnormal/cancellation patterns, the conventional empty cases and a genuine parallel finite-element call. The finite-element actual-grid fixtures reuse every matrix and coordinate bit accepted from the completed twenty-routine forecast.

For the nineteen-level grid, construct constant and quartic negative integrands by dividing their analytical profiles by RD*lambda*r in high precision when generating inputs. Constant integration is checked against scale*(1-eta) with absolute error divided by the absolute profile amplitude limited to 1e-11. The quartic profile eta^2*(1-eta)^2 is checked against scale*(1/30-eta^3/3+eta^4/2-eta^5/5), with normalized error equal to absolute(native minus analytical target) divided by the absolute declared profile amplitude, limited to 1e-6. The amplitude has the output potential unit and is the signed dyadic scale supplied by each fixture, so this error measures a unit-amplitude profile. The same normalized rule with limit 1e-11 applies to the actual-grid constant profile. A zero-amplitude profile is checked separately against exact analytical zero. This bound follows from the linear integral operator: its independently measured unit-profile discretisation error scales with amplitude. Small-grid closed identities use tolerance 4096 times binary64 epsilon.

The verifier protects trailing pages and immutable input pages, checks all inactive output cells, snapshots all configuration and coefficient bytes, checks preserved registers and FPCR, and compares the complete PD buffers to the unchanged original-source reference with zero differing bytes. A diagnostic call-target variant may record F and Q before and after the unchanged accepted dependency, comparing each stage to original-source observations; it supplies no numerical result itself. Shipping source and ordered arithmetic remain the same.

## Forecast allocation proof and accounting

The accepted source-marker trace contains 4326 genuine SIGAM calls: 4300 from LASSIE,25 from SPCSI and one from SUBMAT. These are observed call counts, not a timing estimate. Every configured call uses the finite-element path.

LASSIE declares each gradient field as NPROMA by NFLEVG and each surface field as NPROMA. It passes pointers shifted by KST-1. A caller-scoped relay records KST,KPROF and the geometry, forwards all 19 original arguments unchanged through RTLD_NEXT, and restores prior thread-local state afterwards. Inside SIGAM, the full field base is the shifted pointer minus eight times KST-1; whole NPROMA by NFLEVG fields and NPROMA surface arrays are captured, including leading inactive rows and final padding. The original LASSIE argument order begins GEOMETRY,GMV,YGFL,DYN,DYNA.

SPCSI declares its local output as NFLEVG by (KEND-KSTA+1) and passes a contiguous temperature section of that extent and a surface section of the same column count. SUBMAT declares two NFLEVG by NFLEVG arrays and one NFLEVG surface array. For these spectral layouts, H equals the exact participating allocation or contiguous section extent, so no padding is inferred.

The forecast comparator captures full reviewed output spans and immutable input/coefficient/configuration records, with deterministic metadata and pointer words normalized only in captured configuration metadata. In-memory immutability checks retain actual pointer bits. It brackets its unchanged-source shadow call with the existing optional vertical reference-depth hooks, so nested shadow calls do not inflate genuine dispatcher counts. It does not interpose global DGEMM. Unreviewed capacity layouts must fail explicitly before copying, rather than extending a formal span beyond its proven allocation.

The fresh T21 forecast accepts 4,326 genuine SIGAM calls, comprising 4,300 LASSIE, 25 SPCSI and one SUBMAT call. All calls use finite elements and preserve 305,578,584 complete returned bytes against the unchanged-source shadow. All nineteen paired routine streams and ten saved forecast files compare directly with zero differing bytes. This untimed run uses own exclusive job 7189435 on nid010825, CPU 0 and local memory placement. The accepted eight-point vertical dependency changes implementation only, retaining the frozen arithmetic. The [compact record](../../../../../bench/openifs/EVIDENCE.md#routine-records) identifies source hashes, commands and raw evidence.


## Forecast capture revision1.3

The single LASSIE relay exports the read-only query lassie_forecast_scope(geometry,ks,ke,gmv,gmv_elements,gmvs,gmvs_elements). Its result is one only while a matching geometry has an active thread-local LASSIE scope. Every output pointer in the query can be NULL. The relay records original parent pointers and restores the prior scope after nested calls; it supplies no result or numerical stage. TGMV has size 1560 and stores NDIMGMV and NDIMGMVS at offsets 992 and996, independently measured by a storage-only GNU12.3 probe.

The full PGMV allocation has NPROMA*NFLEVG*NDIMGMV values. PGMVS has NPROMA*NDIMGMVS values. LACDYN declares its four gradient outputs as separate NPROMA by NFLEVG work arrays and passes them directly to LASSIE. LASSIE then passes the active KST offset to SIGAM. The comparator validates the shifted view against these original arguments before copying. SPCM declares or allocates the spectral temperature first dimension as NFLEVG, while SPCSI passes a contiguous column section; its output ZSDIV has exactly NFLEVG*ISPCOL values. SUBMAT uses the exact square and vector capacities already stated.

The comparator coalesces overlapping reviewed parent ranges into shared source-shadow allocations. The original relative pointer offsets are retained for PD,PT and PSP, including writable views inside PGMV or PGMVS. Every cell outside explicitly active PD writes remains immutable. Used temperature and surface inputs must be disjoint from those writes; other fields in the same parent allocation are retained and compared, rather than treating the whole parent as a separate immutable input. The returned streams contain every byte of these complete parent ranges, including inactive rows and final padding. A source-owned caller name check accepts only SPCSI and SUBMAT outside the recorded LASSIE scope; other allocation layouts fail before copying.

Each SGMF0001 forecast record has a 256-byte header. It stores sequence at8,forecast step at16,mode at20,IBC at24,caller class at28,KLEV/KLON/C/L at32/36/40/44,NPROMA/KST/KPROF/range count at48/52/56/60,five complete parent byte counts at64,five role masks at104,three view-to-parent indices at128,and three relative view offsets at144. The four used coefficient byte counts occupy168 through192; RD,SIRPRG,FPCR and configuration capture bytes occupy200,208,216,224. Unused and reserved words are zero.

Range roles are PGMV=1,PGMVS=2,PD=4,PT=8,PSP=16. Coalesced ranges combine these bits. View indices and offsets preserve alias information without recording virtual addresses. Both output streams append the full ranges in the same stable role order. The separate input stream appends the incoming full ranges,used SIALPH only for the conventional branch,SILNPR,RDETAH and the matrix only for the finite-element branch,then 2608 bytes of deterministic used configuration metadata. This configuration metadata contains SIRPRG,three normalized rank-one descriptors,the normalized 2176-byte TVFE,the 216-byte TCVER and geometry dimension words; unused branch descriptors are zero. All pointer words in captured descriptors are zero, while raw in-memory snapshots retain pointer bits for immutability checks.

The library exports sigam_ and lassie_ plus the shared read-only query. Its direct body calls the accepted verdisint_assembly_ entry, which the existing complete vertical comparison library already exposes and forwards to the accepted native dispatcher. Source-shadow calls are bracketed by both existing vertical reference-depth hooks. Parent integration must load that accepted vertical comparison library and original-source strict vertical library; the SIGAM library does not define or interpose DGEMM. Only native calls change the real output storage. The library records counts by source branch and caller class, full bytes, zero differences and FPCR.

The critical ABI check uses a directly written argument adapter that changes no preserved integer or vector register. It places the ninth argument on an aligned outgoing stack and saves only its return address. The existing canary harness therefore checks x19 through x29 and the low 64 bits of v8 through v15 at the actual SIGAM entry, without a C function frame restoring a damaged register before observation. This strengthens the verifier and changes no numerical object or frozen input.
