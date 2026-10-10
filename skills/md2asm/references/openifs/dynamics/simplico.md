# Complete OpenIFS SIMPLICO

Revision 1.2 adds combined forecast evidence and preserves the numerical contract frozen at revision 1.0 for the complete original `algor/external/linalg/simplico.F90:12–263` before direct AArch64 emission. Source SHA256: `abeedaccc89e72f614336335bd6096fb16c7ccee1fecbfe69ca8f23ae2f3c4f0`. The accepted compiler-entry trace records 550 calls, all from `SPCIMPFSOLVE:181–183`; that caller runs 25 times. These are call counts, not timing measurements.

## Physical meaning

The [atmospheric-motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), especially P03, explains pressure forces and rotation. A spectral coefficient gives the size of one smooth wave on the sphere. The integer $`m`$ counts variation around longitude; degree $`n`$ also includes variation with latitude. SIMPLICO solves the coupled pressure-wave and rotation terms that use the new state. This implicit update uses a matrix whose unknowns are the new divergence coefficients.

A vertical mode is a weighted combination of levels. Each mode has a pressure-wave coefficient $`v_\ell`$ in `PSIVP`, with units square metres per second squared in this convention. The spherical Laplacian coefficient is $`\lambda_n=-n(n+1)/a^2`$, in inverse square metres, where $`a`$ is Earth's radius in metres. `PBDT2` has units square seconds. Their product has no unit. Accepted SIGAM and SITNU supply the pressure/temperature coupling and vertical modes; this leaf neither reconstructs nor omits those stages.

Write the dimensionless input rotation arrays as $`\alpha_n,d_n,p_n,q_n`$. A complex number is $`x_R+i x_I`$, where $`i^2=-1`$. The real and imaginary modal divergence coefficients have units inverse seconds when the mode basis is dimensionless. SIMPLICO receives all coefficient bits from its caller.

## Independent original matrix

Let $`N=KSMAX`$, $`m=KM`$, $`h_\ell=\mathrm{PBDT2}\,v_\ell`$, and $`m\le n\le N`$. The right-hand side is $`y_{\ell n}`$ and the solution is $`x_{\ell n}`$. For positive wave, define the coefficients below; terms with indices below $`m`$ are absent.

```math
\begin{aligned}
C_{\ell n}&=1-h_\ell\lambda_n-i\alpha_n
+d_{n-1}q_np_{n-1}(1+i\alpha_{n-1})
+d_{n+1}p_nq_{n+1}(1+i\alpha_{n+1}),\\
L_n&=d_{n-1}q_{n-1}q_n(1+i\alpha_{n-1}),\\
U_n&=d_{n+1}p_np_{n+1}(1+i\alpha_{n+1}),\\
L_nx_{\ell,n-2}+C_{\ell n}x_{\ell n}+U_nx_{\ell,n+2}&=y_{\ell n}.
\end{aligned}
```

The first diagonal omits the lower-neighbour term; the second includes it. Unknowns outside $`m\ldots N`$ are absent. Input coefficient arrays extend through $`N+1`$ because the source evaluates upper expressions at the final degree. Physical tail values are zero.

For zero wave, remove imaginary terms and replace each $`d`$ in this matrix by one. The source clears every imaginary entry of `PY` and `PX`, including capacity padding. Even and odd degrees form two independent systems. When $`m=N`$, including $`m=N=0`$, only one degree and one sweep exist.

The independent oracle assembles this original dense matrix at 100 decimal digits and uses partial-pivot Gauss–Jordan elimination. It does not use the source parity recurrence or work array. It also freezes matrix residual checks. Zero rotation separately gives $`x=y/(1-\mathrm{PBDT2}v_\ell\lambda_n)`$; zero rotation and zero pressure-wave contribution give $`x=y`$ in defined components.

## Ordered FP64 arithmetic

`RN` means one binary64 operation rounded to nearest with ties to even. Every displayed multiplication, addition, subtraction and division is separate. A leading minus changes the sign bit before the following multiplication. Constants one and zero are exact. Contraction, reassociation, fused multiply-add, approximate arithmetic, reduced precision and fast-math are forbidden. The Arm floating-point control register must be zero at entry and return, with gradual underflow and signed zeros. Exception-status flags are not an output.

For parity $`r=0,1`$, put $`b=m+r`$ and $`e=N-\operatorname{mod}(N-m+r,2)`$. Only $`r=0`$ runs when $`m=N`$. Finish the first parity's forward and backward sweeps before starting the second. Forward degrees increase by two from $`b`$ to $`e`$; backward degrees decrease by two. Every degree processes levels `1:KFLEV` in increasing order. `X` denotes interim or returned `PX`; `W` is private work of the same shape.

Zero-wave first degree:

```text
g = RN(1 + RN(p[b]*q[b+1]))
if r=1: g = RN(g + RN(q[b]*p[b-1]))
sup_R = RN(p[b]*p[b+1])
G = RN(g - RN(RN(PBDT2*v[level])*lap[b]))
under = RN(1 / RN(G*G))
mu = RN((-G)*under)
X_R[b] = RN(mu*Y_R[b])
W_R[b] = RN(mu*sup_R)
```

Each later zero-wave forward degree keeps the same inverse/product order but uses:

```text
g = RN(RN(1 + RN(q[n]*p[n-1])) + RN(p[n]*q[n+1]))
sup_R = RN(p[n]*p[n+1])
sub_R = RN(q[n-1]*q[n])
G = RN(RN(g - RN(RN(PBDT2*v[level])*lap[n])) + RN(sub_R*W_R[n-2]))
Y_R_modified = RN(RN(sub_R*X_R[n-2]) + Y_R[n])
X_R[n] = RN(mu*Y_R_modified)
W_R[n] = RN(mu*sup_R)
```

Positive-wave first degree:

```text
g = RN(1 + RN(RN(d[b+1]*p[b])*q[b+1]))
delta = RN((-alpha[b]) + RN(RN(RN(d[b+1]*alpha[b+1])*p[b])*q[b+1]))
if r=1:
  g = RN(g + RN(RN(d[b-1]*q[b])*p[b-1]))
  delta = RN(delta + RN(RN(RN(d[b-1]*alpha[b-1])*q[b])*p[b-1]))
sup_R = RN(RN(d[b+1]*p[b])*p[b+1])
sup_I = RN(alpha[b+1]*sup_R)
G = RN(g - RN(RN(PBDT2*v[level])*lap[b]))
Delta = delta
Y_R_modified = Y_R[b]
Y_I_modified = Y_I[b]
```

Each later positive-wave forward degree uses:

```text
g = RN(RN(1 + RN(RN(d[n-1]*q[n])*p[n-1])) + RN(RN(d[n+1]*p[n])*q[n+1]))
delta = RN(RN((-alpha[n]) + RN(RN(RN(d[n-1]*alpha[n-1])*q[n])*p[n-1]))
       + RN(RN(RN(d[n+1]*alpha[n+1])*p[n])*q[n+1]))
sup_R = RN(RN(d[n+1]*p[n])*p[n+1])
sup_I = RN(alpha[n+1]*sup_R)
sub_R = RN(RN(d[n-1]*q[n-1])*q[n])
sub_I = RN(alpha[n-1]*sub_R)
G = RN(RN(RN(g - RN(RN(PBDT2*v[level])*lap[n])) + RN(sub_R*W_R[n-2]))
       - RN(sub_I*W_I[n-2]))
Delta = RN(RN(delta + RN(sub_I*W_R[n-2])) + RN(sub_R*W_I[n-2]))
Y_R_modified = RN(RN(RN(sub_R*X_R[n-2]) - RN(sub_I*X_I[n-2])) + Y_R[n])
Y_I_modified = RN(RN(RN(sub_I*X_R[n-2]) + RN(sub_R*X_I[n-2])) + Y_I[n])
```

Positive-wave inverse and products:

```text
under = RN(1 / RN(RN(G*G) + RN(Delta*Delta)))
mu = RN((-G)*under)
nu = RN(Delta*under)
X_R[n] = RN(RN(mu*Y_R_modified) - RN(nu*Y_I_modified))
X_I[n] = RN(RN(nu*Y_R_modified) + RN(mu*Y_I_modified))
W_R[n] = RN(RN(mu*sup_R) - RN(nu*sup_I))
W_I[n] = RN(RN(nu*sup_R) + RN(mu*sup_I))
```

The backward sweep first changes the sign of `X_R[e]` and also `X_I[e]` for positive wave. At each smaller degree, zero wave uses `RN(RN(W_R[n]*X_R[n+2])-X_R[n])`. Positive wave loads both next-degree components before storing either current component, then uses:

```text
X_R[n] = RN(RN(RN(W_R[n]*X_R[n+2]) - RN(W_I[n]*X_I[n+2])) - X_R[n])
X_I[n] = RN(RN(RN(W_I[n]*X_R[n+2]) + RN(W_R[n]*X_I[n+2])) - X_I[n])
```

Identical coefficient operands may be shared across levels. All degree coefficient setup remains present when `KFLEV=0`; there are no level-dependent work values in that case.

## Arm interface and bounds

All thirteen arguments are ordinary pointers, with no hidden lengths or array descriptors. Registers `x0:x7` receive `KM,KSMAX,KFLEV,KFLSUR,PALPHA,PDENIM,PFPLUS,PFMINUS`. Incoming stack offsets 0, 8, 16, 24 and 32 receive `PSIVP,PRLAPDI,PBDT2,PY,PX`. A forwarding caller needs a 48-byte outgoing area and 16-byte stack alignment. Integers are signed 32-bit; reals are binary64.

Let $`Q=N-m+1`$ and $`S=KFLSUR`$. Each rotation array holds $`Q+1`$ contiguous values indexed $`m:N+1`$. `PSIVP` holds `KFLEV` values; `PRLAPDI` holds $`N+1`$ values indexed from zero; `PBDT2` is scalar. `PY,PX,W` have shape $`(S,2,Q)`$. A zero-based level $`\ell`$, component $`c=0,1`$ and degree $`n`$ have byte offset $`8[\ell+S(c+2(n-m))]`$. All objects are distinct and nonoverlapping, with eight-byte alignment.

The domain is $`0\le m\le N\le\mathrm{INT32\_MAX}-2`$ and $`0\le KFLEV\le S`$. Every extent/index product must be representable in the source and a 64-bit address, and each object must cover its full declared capacity. Active arithmetic must be finite with nonzero squared denominators. These are caller preconditions, not repaired numerical branches. Work storage needs $`16SQ`$ bytes, with a harmless minimum allocation for size zero.

Positive wave leaves every `PY` bit unchanged and solves both active `PX` components; its capacity rows retain incoming bytes. Zero wave clears imaginary `PY/PX` cells at every row below `S` to positive zero, leaves real `PY` unchanged, solves active real `PX` and preserves its real padding. Zero levels and zero capacity are valid. Padding of Fortran `INTENT(OUT) PX` has no defined numerical value; untouched bytes are preserved and captured as opaque incoming storage. T21 has `KFLEV=KFLSUR=19`, so all returned field cells are defined.

The body preserves `x19:x29`, the low 64 bits of `v8:v15`, LR, SP and FPCR, and does not use `x18`. Allocation/deallocation only provide storage. Allocation failure may abort. No high-level implementation supplies a missing numerical stage.

## Frozen verification and byte encoding

`.runtime/openifs/simplico/preparation/corpus.json` records all pre-emission input and source hashes. Degrees 0, 1, 2, 3, 7, 21 and 63 cover first/interior/final waves, both parities, one-point systems, zero levels/capacity and padding. All 22 T21 waves have 19 levels. Additional physical cases cover zero time/rotation, no pressure-wave contribution, reversed interval, zero/negative amplitude, subnormal values and signed zeros.

The dense solution limit is `128*DBL_EPSILON*Q*kappa_bound*max(solution_norm,DBL_MIN)+16*DBL_TRUE_MIN`. Here `kappa_bound` is the dense matrix maximum absolute row sum divided by its minimum strict diagonal-dominance margin, which gives an independent inverse bound for the physical corpus. The original-matrix residual limit is `512*DBL_EPSILON*max(abs(rhs)+sum(abs(A*x)),DBL_MIN)+16*DBL_TRUE_MIN`. Both have right-hand-side units. Exact native/source acceptance is zero differing bytes; no limit is fitted after a failure.

The little-endian `SIMPIN01` header has 64 bytes: 32-bit revision/case count at 8/12, 64-bit payload/science counts at 16/24. Each 128-byte case header holds eight 32-bit words at 0: ID,N,m,levels,capacity,profile,flags,zero; four 64-bit words at 32: payload bytes, full field elements, matrix real words, payload real words; four binary64 words at 64: PBDT2,time,rotation,amplitude; four 64-bit words at 96: Q,rotation length,Laplacian length,limit count. Payload order is alpha,denim,plus,minus,PSIVP,Laplacian,incoming PY,incoming PX,expected PY,dense whole-PX truth,original matrices,per-level forward limits. Matrices are level/row/column/real-imaginary ordered; fields are level/component/degree ordered.

Returned records contain the unchanged case header and whole returned PY followed by whole returned PX. A 32-byte stage header holds eight 32-bit words: ID,stage,m,N,levels,capacity,defined work words,zero. Then capture whole PY/PX and current parity's defined work in increasing degree/component/active-level order. Stage 0 follows imaginary clears; odd stages follow forward sweeps; even stages follow backward sweeps. Never read undefined work values.

One verifier checks original public Fortran, an observation-only matched source copy, and canonical/observed direct variants. Read-only input pages, trailing inaccessible pages, prefix guards, full input bits, FPCR and direct preserved-register canaries cover storage and ABI. A nonnumerical hand-emitted bridge forwards all 13 pointers, including all five stack pointers, without hiding preserved registers. A genuine three-thread fixture uses separate fields. Standalone profiling hooks are disabled.

## Provenance and caller follow-up

Construction uses original source plus the frozen physics, arithmetic and ABI above. No SIMPLICO compiler numerical assembly or IR has been inspected before emission. Entry addresses and `addr2line` data only resolve call counts and source lines. Instruction audit and numerical acceptance follow complete literal emission.

`SPCIMPFSOLVE:109–110` allocates separate complete `NFLSUR*NSPEC2` PY/PX parents. At 139–183 it passes column `NASM0(m)` of each. Its source-scoped forecast relay must capture both whole parents and preserve exact offsets. `SPC2:278–280` supplies one-level buffers but is inactive in this trace. Do not add another SPCM relay. Forecast storage/layout and observer ABI will be frozen in a separately identified observer revision before that driver is built.

## Forecast observer revision 1.1

This observer revision changes no numerical equation, source input or native instruction. The frozen pre-emission contract remains separately archived. The parallel fixture now selects the existing nonempty T21 cases with waves 0, 1 and 21, so all three threads solve active fields.

A GNU 12.3 storage-only probe measures GEOMETRY as 17096 bytes, NASM0's rank-one integer descriptor at byte 3720, and RLAPDI's rank-one real descriptor at 4104. Integer dimensions NSMAX,NSPEC2,NFLEVL,NFLSUR occur at 5172, 5200, 5228 and 5236. The descriptors have 64 bytes, with data pointer at 0, offset at 8, element bytes at 16, dtype at 24, span at 32, stride at 40, lower bound at 48 and upper bound at 56. NASM0 has element bytes/span 4, type word 0x0000010100000000, stride 1 and lower bound 0. RLAPDI has element bytes/span 8, type0x0000030100000000, stride 1; SULAP:104 allocates it from -1 through NSMAX+2. Its data points to the allocated lower-bound element; the formal PRLAPDI pointer is the element at index 0, with no second descriptor-offset adjustment.

The sole added relay wraps the original eight ordinary SPCIMPFSOLVE pointers in unchanged order: geometry,rip,dyn,LDNHDYN,LDNHX,LDONEM,PSDIVP descriptor,PSPDIVP descriptor. It creates a nested thread-local capacity context and forwards to RTLD_NEXT. It does not calculate or supply a returned field. The forecast capture domain is a single-thread source caller, including all ancestor OpenMP teams; the native leaf itself remains verified in a genuine three-thread team. No duplicate SPCM relay is added. If the existing read-only spcm_forecast_scope query is present, its geometry match is required.

At a leaf call, the context checks its dimensions, NASM0(m), coefficient pointers and Laplacian view. The two complete caller parents have NFLSUR*NSPEC2 binary64 cells; the wave's byte offset is 8*NFLSUR*(NASM0(m)-1). It clones both complete parents, calls unchanged Fortran on those clones with identical view offsets, and calls native assembly on the originals. Then it compares every parent byte, including unused modes and capacity rows. It also checks original configuration objects, descriptors, all four complete 0:NSMAX+1 coefficient arrays, complete PSIVP and allocated RLAPDI, scalar inputs and FPCR. Unused input bytes are treated as opaque storage.

SIMPFC01 is a 160-byte little-endian forecast header. Sequence and source-solve visit are 64-bit words at8/16. Six 32-bit words at 24 hold m,N,levels,capacity,NSPEC2,Q. Eight 64-bit words at 48 hold starting column offset,parent elements,parent bytes,total coefficient payload elements,FPCR,PBDT2 bits,rotation-array capacity,Laplacian capacity. A signed 64-bit lower bound is at 112; parent rows,columns and formal-wave bytes occupy 120/128/136. LDNHDYN,LDNHX,LDONEM and zero are 32-bit words at 144. Returned records then contain the full PY parent followed by the full PX parent. Input records contain their incoming bytes, complete alpha/denim/plus/minus, PSIVP, allocated RLAPDI, NASM0 integer values, then the two normalized 64-byte geometry descriptors. Only address words in metadata are zeroed; numerical values remain unchanged.

Exported nonnumerical simplico_forecast_reference_begin/end hooks can distinguish future shadow-source dispatcher visits from genuine calls. They change accounting only. The source leaf called directly by this comparator bypasses its public interposer, so its comparison work does not become a genuine forecast visit.

## Combined forecast acceptance

The combined T21 historical forecast accepts all 550 original calls in 25 SPCIMPFSOLVE visits, with 25 calls for each wave number from zero through 21. The complete separate PY and PX parents each contain 19 by 506 values. Every returned parent byte matches the unchanged source across 84,691,200 canonical record bytes, including untouched modes and zero-wave imaginary storage. All configuration and coefficient allocations retain their input bytes, and FPCR is zero at every entry and return. All 26 paired streams and ten saved files directly compare with the strict Fortran baseline. The frozen critical verifier separately checks independent dense solutions and original-matrix residuals. Whole-forecast physical validation and comparative timing remain unfinished.

The [compact record](../../../../../src/openifs/README.md) identifies the frozen corpus, original source, accepted stage streams and exact command archive. The direct thirteen-argument forwarding bridge is embedded in the [critical driver](../../../../../src/openifs/README.md), with the existing [preserved-register checker](../../../../../src/openifs/README.md). Run these commands through srun in a quiet exclusive allocation, using a fresh ignored directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/simplico/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -march=armv8-a+simd -c src/openifs/dynamics/simplico.S \
  -o "$check_dir/assembly.o"
gcc -fPIC -march=armv8-a+simd -DSIMPLICO_ENTRY=simplico_stage_assembly_ \
  -DSIMPLICO_OBSERVER=simplico_native_stage_ \
  -c src/openifs/dynamics/simplico.S -o "$check_dir/stages.o"
gcc -fPIC -march=armv8-a+simd \
  -c bench/openifs/dynamics/vertical_abi.S -o "$check_dir/abi.o"
gfortran -O2 -mcpu=native -fPIC -fopenmp -ffp-contract=off -fno-fast-math \
  -ffree-line-length-none -cpp -I "$build_root/ifs_dp/module" \
  -I "$build_root/module/parkind_dp" -I "$build_root/module/fiat" \
  -c .runtime/openifs/simplico/preparation/staged-simplico.F90 \
  -o "$check_dir/reference.o"
gcc -O2 -mcpu=native -fPIC -fopenmp -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -c .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/simplico.c \
  -o "$check_dir/verifier.o"
gcc -fPIC -pie -fopenmp "$check_dir/verifier.o" "$check_dir/assembly.o" \
  "$check_dir/stages.o" "$check_dir/reference.o" "$check_dir/abi.o" \
  -L "$build_root/lib" -lalgor.DP -larpifs.DP -lfiat -lgfortran -lm -ldl \
  -Wl,-rpath,"$build_root/lib" -o "$check_dir/verify"
OMP_NUM_THREADS=1 "$check_dir/verify" .runtime/openifs/simplico/preparation \
  "$check_dir/result"
cmp "$check_dir/result/assembly.bin" "$check_dir/result/reference.bin"
cmp "$check_dir/result/assembly-stages.bin" "$check_dir/result/reference-stages.bin"
gcc -O2 -mcpu=native -fPIC -fopenmp -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -c .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/simplico_forecast.c \
  -o "$check_dir/forecast.o"
gcc -shared -fopenmp "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -L "$build_root/lib" -lalgor.DP -larpifs.DP -lfiat -lgfortran -lm -ldl \
  -pthread -Wl,-rpath,"$build_root/lib" -o "$check_dir/libverify-simplico.so"
```

Preload only the canonical native object and source-scoped forecast observer. Observation-only stage variants belong to the critical verifier. Retain the existing sole SPCM relay and one source-caller thread, then directly compare every captured stream and saved file.
