# SPCIMPFPOST: spectral Coriolis correction

Revision 1.2 records full T21 acceptance with the source-scoped observer, preserving the complete numerical operator frozen in revision 1.0. Revision 1.0 freezes the complete original SPCIMPFPOST operator before direct AArch64 emission. The basic physics is horizontal motion in [atmospheric motion P03](../../../../../formulations/openifs/dynamics/atmospheric_motion.md). A spectral coefficient is the amplitude of a spherical wave. The zonal wave number $`m`$ counts its variation around longitude, while the total degree $`n`$ counts its variation over the whole sphere.

## Physical meaning and scope

Coriolis acceleration deflects moving air because the Earth rotates. Taking the horizontal curl of that acceleration links vorticity, which measures local rotation, to divergence, which measures local spreading. This routine applies the vorticity correction after another routine solves the implicit divergence equation. It completes two neighbour passes and has no omitted numerical dependency. It does not advance the entire forecast.

Divergence $`D`$ and vorticity $`V`$ have units of inverse seconds. Their separate real and imaginary coefficients describe the two parts of a complex wave amplitude. Let $`N`$ be NSMAX, $`L`$ be NFLEVL, $`m`$ be KM, $`k`$ be KSTA, $`b`$ be RBTS2 and $`t`$ be TDT in seconds. The weight $`b`$ has no unit. Earth's rotation rate $`\Omega`$ is ROMEGA in inverse seconds. Thus the coefficients below have no unit, and the corrected vorticity retains inverse seconds.

The original 185-line source is `arpifs/adiab/spcimpfpost.F90`, with SHA256 `08153edac036bfd6642917c66362a4f6af32ed699318d88ebb7c88c296e64499`. The unchanged SPCM caller has 550 observed visits in the accepted T21 source trace. Its configured geometry has $`N=21`$ and $`L=19`$, and its one-task partition enumerates $`m=0,\ldots,21`$. These mode values follow from source and configuration; the earlier trace did not log each KM argument.

## Mathematical response

**C01. Coefficients**

~~~math
F=2bt\Omega,\qquad
a_n=\frac{Fm}{n(n+1)},\qquad
d_n=\frac{1}{1+a_n^2},\qquad
e_n=\sqrt{\frac{n^2-m^2}{4n^2-1}},
~~~

~~~math
p_n=\frac{Fn e_{n+1}}{n+1},\qquad
q_n=\frac{F(n+1)e_n}{n}.
~~~

The square root gives the coupling between neighbouring spherical degrees. The factors $`p_n`$ and $`q_n`$ multiply the upper and lower neighbours. For $`m=0`$, the source explicitly sets $`a_0=d_0=e_0=p_0=q_0=+0`$ and starts its coefficient loop at degree 1. It also sets $`p_N=+0`$ and the source-defined trailing entries $`a_{N+1},d_{N+1},p_{N+1},q_{N+1}`$ to $`+0`$. It never reads $`e_{N+1}`$ because the upper-factor loop ends at $`N-1`$.

**C02. Real zero-wave correction**

For $`m=0`$, the first pass subtracts $`d_nq_nD^R_{n-1}`$ from $`V^R_n`$ for $`n=2,\ldots,N`$. The second pass subtracts $`d_np_nD^R_{n+1}`$ for $`n=1,\ldots,N-1`$. Every imaginary vorticity coefficient and both degree-zero vorticity slots keep their exact input bytes.

**C03. Complex positive-wave correction**

For $`m>0`$, a lower neighbour gives

~~~math
V^R_n \leftarrow V^R_n-d_nq_n(D^R_{n-1}-a_nD^I_{n-1}),\qquad
V^I_n \leftarrow V^I_n-d_nq_n(D^I_{n-1}+a_nD^R_{n-1}),
~~~

for $`n=m+1,\ldots,N`$. The following upper pass uses $`p_n`$ and neighbour $`n+1`$ for $`n=m,\ldots,N-1`$. Both passes use the same input-only divergence field. Each vertical level is independent. At $`m=N`$ both neighbour ranges are empty, so every returned vorticity byte remains unchanged.

## Ordered binary64 arithmetic

$`RN(x)`$ means one IEEE binary64 rounding to nearest with ties to even. Each operation below rounds separately. Correct division and square root are required; fused operations, contraction, reassociation, approximate reciprocals, reduced precision, fast-math and signed-zero normalisation are forbidden. FPCR must be zero on entry and unchanged on return, giving gradual underflow and the required rounding mode.

First compute $`B=RN(b*t)`$, $`u=RN(2*B)`$, $`F=RN(u*\Omega)`$ and $`A=RN(F*REAL(m))`$. The source separately recomputes the same ordered $`F`$ for its factor arrays; one stored rounded value may serve both uses because its operands and rounding points are identical. Integer-to-binary64 conversion is exact for the supported 32-bit integers.

For each $`n`$ from $`ILO`$ to $`N`$, where $`ILO=1`$ for $`m=0`$ and $`ILO=m`$ otherwise, compute $`x=REAL(n)`$ and $`z=REAL(m)`$. Form $`x_1=RN(x+1)`$, $`a_n=RN(A/RN(x*x_1))`$, $`d_n=RN(1/RN(1+RN(a_n*a_n)))`$ and $`e_n=SQRT_RN(RN(RN(RN(x*x)-RN(z*z))/RN(RN(RN(4*x)*x)-1)))`$. In particular, the denominator multiplies $`4*x`$ before multiplying by $`x`$.

For $`n=ILO,\ldots,N-1`$, form $`p_n=RN(RN(RN(F*x)*e_{n+1})/RN(x+1))`$ and $`q_n=RN(RN(RN(F*RN(x+1))*e_n)/x)`$. Compute $`q_N`$ with that same expression using $`x=REAL(N)`$, then write the explicit zeros. Preserve all setup stages even when the output loops are empty. Scratch entries below $`m`$ remain unused; they are not declared outputs.

The lower pass completes every degree before the upper pass starts. Within a pass, traverse degrees upward and then levels from 1 to $`L`$. For each degree, let $`c=RN(d_n*q_n)`$ in the lower pass or $`c=RN(d_n*p_n)`$ in the upper pass. Reusing this rounded coefficient across independent levels is valid. For $`m=0`$, compute $`V^R=RN(V^R-RN(c*D^R))`$. For $`m>0`$, compute $`r=RN(D^R-RN(a_n*D^I))`$, then $`V^R=RN(V^R-RN(c*r))`$; next compute $`s=RN(D^I+RN(a_n*D^R))`$ and $`V^I=RN(V^I-RN(c*s))`$. Each expression uses the named neighbour. Do not combine the two passes or replace either subtraction with addition of a negated expression.

Profiling hooks are outside the numerical output contract and are disabled in the critical verifier. The original forecast source retains its configured hooks during its separate comparison call.

The production body supplies the complete coefficient setup and both passes. Its only external services are allocation, release and a fatal allocation-failure path, plus reading the ROMEGA module scalar. No driver or language numerical dependency supplies a solver stage.

## Shapes, storage and allowed mutation

The safe source domain has $`1<=N<=2147483645`$, $`0<=m<=N`$, $`L>=0`$ and $`k>=1`$. The largest complex slot $`J=k+2(N-m)+1`$ and every integer intermediate must fit signed 32-bit arithmetic. The NSMAX=0 source setup computes a zero divided by zero in its last lower factor; that undefined branch is excluded and needs an upstream scientific decision. KEND is a present by-reference 32-bit integer that the body never reads. The normal caller sets $`KEND=J`$, but changing that unused integer must not change outputs.

Both GNU assumed-shape rank-two descriptors must cover logical levels $`1:L`$ and all used slots through $`J`$. For $`L=0`$ an actual zero-row descriptor is allowed and no field element is read or written. For nonempty arrays, signed element strides $`s_1,s_2`$ must give distinct cells and valid addresses. With extents $`E_1,E_2`$ and $`g=\gcd(\lvert s_1\rvert,\lvert s_2\rvert)`$, injectivity is guaranteed by $`E_1<=\lvert s_2\rvert/g`$ or $`E_2<=\lvert s_1\rvert/g`$; a dimension of length one does not need a nonzero stride. All pointer calculations and $`40(N+2)`$ scratch bytes must fit address arithmetic and have allocated storage.

The descriptor base points to logical cell $`(1,1)`$. The address of $`(l,j)`$ is $`base+8((l-1)s_1+(j-1)s_2)`$, even for negative strides. Dummy lower bounds are one, as confirmed with positive and negative actual-array sections. A full physical span starts at $`base+8h`$, where $`h=min(0,(E_1-1)s_1)+min(0,(E_2-1)s_2)`$; its last offset uses max in place of min. Complete physical spans, including storage holes, are declared verifier outputs. Divergence and vorticity must have no overlapping accessed storage, consistent with the original input and input/output arguments.

Only vorticity slots named by C02 or C03 at levels $`1:L`$ may change. Divergence, descriptor bytes, scalars, geometry, integration settings and dynamics configuration remain immutable. Other vorticity cells, row padding, holes, whole neighbouring waves and guards preserve every input bit. Used inputs and every used intermediate must be finite; inactive storage can contain arbitrary bits.

The original SPCM passes YDSP%DIV and YDSP%VOR without slicing. SPECTRAL_FIELDS_MOD makes these two distinct field views inside YDSP%SP3D. Before a forecast comparator is built, its caller observer must measure the parent descriptor and capture the complete SP3D allocation while preserving both view offsets. The driver must check all other parent fields for allowed mutation. Whole-parent comparisons in a parallel caller require a documented single-thread scope; numerical kernel parallel checks use independent caller allocations.

## GNU 12.3 Arm ABI

The measured type sizes are GEOMETRY 17096 bytes, TDYN 4720 bytes and TRIP 175976 bytes. NSMAX is a four-byte field at GEOMETRY+5172; NFLEVL is at GEOMETRY+5228. RBTS2 is an eight-byte field at TDYN+2496 and TDT is at TRIP+208. The source and output of the storage-only probe are archived in preparation/layout.f90 and layout.json.

The eight arguments are all pointers: $`x0=GEOMETRY`$, $`x1=TRIP`$, $`x2=TDYN`$, $`x3=KM`$, $`x4=KSTA`$, $`x5=KEND`$, $`x6=DIV descriptor`$ and $`x7=VOR descriptor`$. There are no character lengths, optional arguments or incoming stack arguments. The entry symbol is `spcimpfpost_assembly_`.

A GNU binary64 rank-two descriptor is 88 bytes. Its fields are base at 0, offset at 8, element size at 16, type word at 24, span at 32, first stride/lower/upper at 40/48/56 and second stride/lower/upper at 64/72/80. Element size and span are eight; the measured type word is `0x0000030200000000`. The native body reads signed strides and the base, and its valid-domain contract supplies extents. A scalar path handles every supported shape and remainder without a look-ahead read.

Preserve $`x19:x29`$, the low 64 bits of $`v8:v15`$, link register and 16-byte stack alignment. Do not use platform register $`x18`$ or change FPCR. A directly written, nonnumerical tail-call bridge loads all eight arguments without touching preserved registers, so register canaries reach the actual solver entry.

## Frozen checks and byte encoding

The frozen corpus has 168 cases and 8654856 bytes, with SHA256 $`858a7786b3569bfca45c4ba3f16087a5f87fabebdb8272f9d9e1cf8787e31c6d`$. It contains $`N=1,2,3,7,21,63`$; zero and positive wave numbers, all 22 configured T21 waves, $`L=0,1,2,3,7,19`$; shifted intervals; positive and negative independent strides; row padding; empty descriptors; two changed unused KEND values; pure real and imaginary impulses; zero divergence; signed zeros; subnormal inputs; zero and signed integration parameters; and one true outer OpenMP fixture. The generator records all scalar bits, shapes, allocation capacities and input record hashes before emission.

The independent response uses 100-digit Decimal arithmetic to evaluate the combined complex equation from the mathematical coefficients. It does not replay the ordered binary64 passes. Its error limit is fixed before execution: $`64*DBL_EPSILON*max(S,DBL_MIN)+4*DBL_TRUE_MIN`$, where $`S=|V_initial|+|lower correction|+|upper correction|`$ in inverse seconds. The limit follows from the short separately rounded operation chains and accounts for cancellation and gradual underflow. DBL_EPSILON is the spacing 2^-52 near one, DBL_MIN=2^-1022 is the smallest normal binary64 value and DBL_TRUE_MIN=2^-1074 is the smallest positive subnormal value. A unit in the last place, called an ulp, is the spacing between nearby representable numbers. The coefficient identities use the same spacing bound with their dimensionless expected magnitude. Impulses isolate each coupling direction, and zero-force cases check the physical identity while exact-byte checks retain signed-zero effects.

One critical verifier calls the original strict-source body and the complete native body with input-only pages and protected trailing pages. A paired observation variant records only coefficients that the source defines and complete output spans after setup, after the lower pass and after the upper pass. Observation calls perform no numerical solver operation. Independent checks cover returned values and coefficients; exact comparisons cover complete returned spans, inactive bits, guards, all recorded stages, preserved registers, input/configuration immutability and FPCR.

Input encoding is `POSTIN01` with a 64-byte little-endian header. Each 192-byte record header stores case, dimensions, signed strides, capacities, logical-base offsets, all scalar bits, profile and parallel marker. It is followed by complete DIV and incoming VOR spans, independent final values, independent cancellation scales and five independent coefficient values per degree $`m:N`$. Returned streams use `POSTOUT1` deterministic records containing the same scalar metadata and complete VOR spans. Stage streams record case, phase and source-defined coefficient entries for phase zero or the complete VOR span for phases one and two. Pointer addresses, timer values and nondeterministic metadata do not enter canonical bytes.

Acceptance requires zero differing bytes between strict original Fortran and direct assembly at every exposed stage and the final full buffer. A failure identifies case, stage, physical cell and both bit patterns before any timing. Hashes identify archives; they do not replace direct byte comparison. Critical verification and forecast acceptance are separate milestones, and no timing or performance claim is established here.

## Generation provenance

The direct body must be emitted from this frozen Markdown contract and assembled and linked as AArch64 source. Preparation read the original source, existing physics and storage probes. A requested coverage supplement incidentally displayed one pre-existing frontend SQRT expression before emission, at its report line 11093. This exposure is recorded in preparation/provenance-preparation.json; do not claim that every compiler representation was unseen. No compiler numerical instructions or full IR dump were opened, and neither is used to construct the body. All remaining compiler numerical inspection is deferred until after emission. Parent owns full forecasts, Git and shared documentation.

## Source-scoped forecast observer, revision 1.1

The separate forecast comparator owns the sole SPCM relay. The original call has GEOMETRY, MODEL, CDCONF, SPECTRAL_FIELD and TGMV pointers in x0:x4, followed by the eight-byte GNU hidden character length in x5. A storage-only call with CDCONF='A' and length one confirmed that ABI. The relay forwards every argument unchanged through RTLD_NEXT and restores any previous thread-local scope when the source call returns. It performs no numerical operation.

The read-only query is `int spcm_forecast_scope(const void *geometry,const double **sp3d,size_t *sp3d_elements)`. Both output pointers can be null. The query returns one only while the same geometry has an active valid SPCM scope, and it does not change model state. SPCIMPFINIT uses this query and owns no second relay.

The measured SPECTRAL_FIELD object is 2992 bytes. Its allocatable SP3D rank-three descriptor is at byte 88 and occupies 112 bytes. VOR and DIV rank-two descriptors are at bytes 1520 and 1608. CREATE_SPEC allocates the full SP3D as NFLEVL by NSPEC2 by NS3D with lower bounds one, strides 1, NFLEVL and NFLEVL*NSPEC2. The parent query reports that complete allocation. It verifies descriptor dimensions and contiguity before permitting a numerical comparison; a missing or changed scope is rejected before copying a parent buffer.

The original SPCM passes the complete VOR and DIV field views. The comparator confirms both descriptor bases, extents and strides against those views, then clones the complete SP3D allocation once. It redirects both shadow descriptors into that same clone with the original byte offsets. This preserves every shared-parent relationship while the two formal fields have disjoint accessed storage. The original source runs on the clone, and the complete native body runs on the live allocation. All cells outside the source-defined active VOR slots, including every DIV cell and every other SP3D field, keep their input bits. Full original geometry, dynamics, integration objects, spectral-field object, argument descriptors, scalar integers, ROMEGA and FPCR are compared before and after both calls.

Full-parent capture is scoped to one thread in the SPCM caller, as used by this T21 forecast. A parallel numerical body can update separate caller allocations; those genuine outer OpenMP calls passed the critical verifier. Concurrent writes by different wave numbers to one captured parent would need a different observer protocol and are excluded from this full-parent comparator.

Each returned record has a 256-byte POSTFC01 header followed by every allocated SP3D byte. It stores the record and SPCM visit numbers, m/KSTA/KEND/N/L, complete parent dimensions and bytes, DIV/VOR offsets, the TDT/RBTS2/ROMEGA bits, FPCR, formal shapes and signed strides, source configuration character and hidden length. Input records add the incoming whole parent and its 112-byte descriptor plus two 88-byte field descriptors. Only descriptor pointer addresses are zeroed in this deterministic metadata; all numerical input and returned bits are preserved. The live raw descriptor bytes are still checked for immutability. Assembly and Fortran output records must match byte for byte.

The observer has no global DGEMM interposition, numerical solver operation, timing loop or missing-stage substitute. The native and critical objects, corpus and accepted stage/output streams are unchanged from revision 1.0.

The forecast header has these little-endian offsets. Signed strides and offsets retain their exact integer values; scalar parameters retain their exact binary64 bits.

| Byte offset | Size | Content |
| --- | ---: | --- |
| 0 | 8 | POSTFC01 magic |
| 8, 16 | 8 each | Record number, original SPCM visit number |
| 24, 28, 32, 36, 40, 44 | 4 each | m, KSTA, KEND, NSMAX, NFLEVL, parent field count |
| 48, 56, 64 | 8 each | Parent rows, columns, total allocated bytes |
| 72, 80 | 8 each | DIV and VOR base offsets inside the parent |
| 88, 96, 104, 112 | 8 each | TDT, RBTS2, ROMEGA bits, FPCR |
| 120, 128, 136, 144 | 8 each | DIV rows/columns, VOR rows/columns |
| 152, 160, 168, 176 | 8 each | DIV row/column and VOR row/column element strides |
| 184 | 8 | Input descriptor metadata bytes, fixed at 288 |
| 192 | 1 | Original SPCM configuration character |
| 193 | 7 | Reserved zeros |
| 200 | 8 | Original GNU hidden character length |
| 208 | 48 | Reserved zeros |

After the header, each output record contains the full SP3D allocation. Each input record contains the full incoming SP3D followed by the normalized parent, DIV and VOR descriptors in that order. The two recorded field offsets restore their shared-parent views during replay.

## Full forecast acceptance

The fresh full T21 run accepts all 550 genuine calls in 25 SPCM visits. Each wave number from zero through 21 has 25 calls, including 25 zero-wave corrections and 25 empty-neighbour calls at the last wave number. Every record contains the entire shared SP3D allocation, with 19 levels, 506 coefficient slots and three fields. The 127,045,600 canonical returned bytes and complete incoming descriptors preserve every field and inactive bit. All 22 paired numerical streams and ten saved forecast files compare directly with zero differing bytes. This acceptance uses own exclusive job 7189435 on nid010825, CPU 0 and local memory placement. Whole-forecast physical validation and comparative timing remain unfinished. The [compact record](../../../../../bench/openifs/dynamics/spcimpfpost.json) preserves the actual checks, commands and archive hashes.
