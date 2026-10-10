# SPCIMPFINIT: implicit Coriolis preparation

Revision 1.1 records full T21 acceptance and its observer binding while preserving the complete numerical body frozen in revision 1.0. It uses revision 1.0, equation P03, of the unchanged [atmospheric motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md). The formulation SHA256 is 0702e45875a201c21b48e75eea536e84e73e7d42124ef20a4f8d9785a89bda7c. The unchanged OpenIFS source is `arpifs/adiab/spcimpfinit.F90`, SHA256 736af817369e838582a10c52c226ba9702531669c8c6da457b524a461c9a62dd, identified by the [source record](../../../../../bench/openifs/EVIDENCE.md#source). The freeze time and input/output hashes are in the ignored `.runtime/openifs/spcimpfinit/freeze.json`.

## Physical meaning

Earth's rotation deflects horizontal motion through the Coriolis term in P03. This routine prepares the corresponding implicit calculation, which puts part of that force into the equations for the new state. It works with spectral coefficients: numbers that describe a field as a sum of waves on the sphere. The zonal wave number `m` counts the longitude variation, while the total degree `n` also describes latitude variation and satisfies `0 <= m <= n`. The truncation `N` is the largest retained degree. A real and an imaginary coefficient represent the two parts of each complex wave; they are not the eastward and northward velocity components.

At each model level, `R_n` and `I_n` are the incoming vorticity coefficients, in inverse seconds. The returned coefficients `R'_n` and `I'_n` have the same units. The auxiliary array supplies a correction to the right-hand side of the divergence equation, also in inverse seconds. This routine neither advances the complete forecast nor performs a spectral transform. Its array factor is exact for the stated discrete operator; no finite-element vertical integration is involved.

Let `b=RBTS2` be a dimensionless time weight, `t_d=TDT` the time interval in seconds, and `Omega=ROMEGA` the rotation frequency in inverse seconds. Define the dimensionless factors below. For `m=0,n=0`, the source assigns the singular mode's helper factors directly to positive zero.

**C01. Coriolis factors**

```math
c=2bt_d\Omega,\qquad
\alpha_n=\frac{cm}{n(n+1)},\qquad
d_n=\frac{1}{1+\alpha_n^2},\qquad
\epsilon_n^m=\sqrt{\frac{n^2-m^2}{4n^2-1}}.
```

For `m>0`, the two-by-two system below is solved for each retained degree. For `m=0`, the source skips this transformation, so every vorticity bit remains unchanged.

**C02. Inverse vorticity system**

```math
\begin{pmatrix}1&\alpha_n\\-\alpha_n&1\end{pmatrix}
\begin{pmatrix}R'_n\\I'_n\end{pmatrix}
=
\begin{pmatrix}R_n\\I_n\end{pmatrix},
\qquad
R'_n=d_n(R_n-\alpha_n I_n),\quad
I'_n=d_n(I_n+\alpha_n R_n).
```

This inverse changes the phase of a complex coefficient and scales its squared magnitude by `1/(1+alpha_n^2)`. That is a property of this preparation block, not a claim that the complete Coriolis forecast step loses that amount of kinetic energy.

**C03. Neighboring degree correction**

```math
f_n^-=\frac{c(n+1)\epsilon_n^m}{n},\qquad
f_n^+=\frac{cn\epsilon_{n+1}^m}{n+1},\qquad
A_n=f_n^-V'_{n-1}+f_n^+V'_{n+1},
\qquad V'_n=R'_n+\mathrm{i}I'_n.
```

The factors connect neighboring spherical degrees. The lower contribution is absent at `n=m`, and the upper contribution is absent at `n=N`. The source sets `f_N^+=0`. For the constant mode `m=n=0`, it sets `f_0^-=f_0^+=0`, so both auxiliary slots return positive zero. Both parts of `A_n` are calculated. The source retains supplied imaginary zero-wave-number values rather than dropping those storage cells.

## Supported source domain

The integers use GNU `JPIM`, a signed 32-bit representation. The supported domain is `1 <= N <= INT32_MAX-1`, `0 <= m <= N`, `L=NFLEVL >= 0`, and `KSTA >= 1`. The final selected imaginary column is `KSTA+2*(N-m)+1`; every intermediate integer in the source index calculation must fit signed 32 bits, and this final column must lie inside both actual arrays. Empty level counts are supported: no array element is read or written when `L=0`, although the source still prepares the factors. `N=0` is excluded because source line 132 divides by the zero degree after the special zero-mode initialization. Modes outside `0..N` are excluded because they do not define the required helper-array entries.

`KEND` is passed by reference but never read by the numerical body. It may hold any signed 32-bit value. The actual caller normally supplies the final selected column; critical cases also give inconsistent values to preserve the source's observable behavior. The range is controlled by `N,m,KSTA`, not by `KEND`.

Every coefficient and every vorticity element read by the source must be finite. All prescribed intermediate products, sums, differences, quotients, squares, square roots and final elements must stay finite, and every square-root argument must be nonnegative. The time weight, interval and rotation frequency can have either sign or either signed zero. This allows algebraic sign-reversal, zero-force and gradual-underflow cases as well as ordinary positive physical inputs. Inactive storage can contain arbitrary bits, including NaN payloads, because the numerical body must preserve those bytes. Allocation must succeed for the finite supported shape; failed memory allocation is outside the numerical domain.

Both rank-two descriptors describe FP64 real data with eight-byte elements and span eight. Their nonzero signed strides may be positive or negative. Each complete logical array must have distinct element addresses, and each physical address span must fit the available allocation and signed 64-bit address arithmetic. If the absolute strides are `a,b` and their greatest common divisor is `g`, injectivity is required by `rows-1 < b/g` or `columns-1 < a/g`. The two writable array views must not overlap. Rows beyond `L`, columns outside the selected wave block, and holes between strided elements remain unchanged. Data and scalar/object pointers have at least eight-byte alignment, except the three 32-bit integer arguments, which need four-byte alignment.

## Frozen ordered FP64 arithmetic

`RN(x)` means one rounding to FP64 with round-to-nearest, ties to even, and gradual underflow. Parentheses below are arithmetic dependencies, not permission to reassociate a product. All source multiplications, additions, subtractions, division and square root remain separate rounding operations. Positive zero literals retain their exact bits. No fused multiply-add, expression contraction, reassociation, approximate quotient/root, reduced precision or fast-math is allowed. FPCR must be zero at entry and return.

Source lines 98–115 prescribe the following factor preparation, with exact conversion of the supported integers to FP64:

```math
B=\operatorname{RN}(b t_d),\quad
F=\operatorname{RN}(\operatorname{RN}(2B)\Omega),\quad
H=\operatorname{RN}(Fm),\quad
q_n=\operatorname{RN}(n+1),\quad
D_n=\operatorname{RN}(nq_n),
```

```math
\alpha_n=\operatorname{RN}(H/D_n),\quad
s_n=\operatorname{RN}(\alpha_n\alpha_n),\quad
d_n=\operatorname{RN}(1/\operatorname{RN}(1+s_n)),
```

```math
e_n=\operatorname{RN}
\left(
\operatorname{RN}(nn)-\operatorname{RN}(mm)
\right),\quad
h_n=\operatorname{RN}
\left(
\operatorname{RN}(\operatorname{RN}(4n)n)-1
\right),\quad
\epsilon_n^m=
\operatorname{RN}\left(
\sqrt{\operatorname{RN}(e_n/h_n)}
\right).
```

The loop starts at `n=m` for `m>0` and at `n=1` for `m=0`. The latter branch first writes `alpha_0=d_0=epsilon_0=+0`. Source lines 117–118 write `alpha_(N+1)=d_(N+1)=+0`. These private endpoint factors do not replace an active `d_n`.

Source lines 120–134 give `f_0^-=f_0^+=+0` in the zero-mode branch and then calculate the active factors with the following rounding:

```math
f_n^+
=
\operatorname{RN}
\left(
\operatorname{RN}(\operatorname{RN}(Fn)\epsilon_{n+1}^m)/q_n
\right),
\qquad
f_n^-=
\operatorname{RN}
\left(
\operatorname{RN}(\operatorname{RN}(Fq_n)\epsilon_n^m)/n
\right).
```

The ordinary factor loop ends at `N-1`. The source separately sets `f_N^+=+0`, calculates `f_N^-` with the same lower-factor formula, and sets both `N+1` factors to positive zero. No value of `epsilon_(N+1)` is required.

Source lines 138–148 first traverse `n=m..N`, then level `j=1..L`, for `m>0`. They preserve the old real and imaginary pair until both expressions below have been evaluated. The temporary imaginary result is calculated first; real is stored before imaginary.

```math
I'_n=\operatorname{RN}
\left(
d_n\operatorname{RN}
\left(
I_n+\operatorname{RN}(\alpha_n R_n)
\right)
\right),
\qquad
R'_n=\operatorname{RN}
\left(
d_n\operatorname{RN}
\left(
R_n-\operatorname{RN}(\alpha_n I_n)
\right)
\right).
```

Source lines 150–157 then clear the two auxiliary slots for every degree `m..N` and every level, writing positive zero. Lines 161–168 traverse `n=m+1..N` and add the lower neighbor to that zero in one complete pass. Lines 170–177 subsequently traverse `n=m..N-1` and add the upper neighbor in another complete pass. Each part has one multiplication and one addition with an intermediate rounding:

```math
A\leftarrow\operatorname{RN}
\left(
A+\operatorname{RN}(f_n^-V'_{n-1})
\right),
\qquad
A\leftarrow\operatorname{RN}
\left(
A+\operatorname{RN}(f_n^+V'_{n+1})
\right).
```

These assignments apply separately to the real and imaginary slots. The positive-zero initialization and both additions are retained even when a factor is zero. They preserve source signed-zero behavior.

## Storage and Arm ABI

The GNU 12.3 storage-only probe is archived as `.runtime/openifs/spcimpfinit/layout.f90`, `layout.c`, `layout.log` and `layout.json`. It calculates no spectral update. The geometry object is 17,096 bytes, the dynamics object is 4,720 bytes, and the runtime/time object is 175,976 bytes. The source reads `NSMAX` at geometry byte 5172, `NFLEVL` at byte 5228, `RBTS2` at dynamics byte 2496, and `TDT` at time-object byte 208. Geometry `NFLSUR` and `NSPEC2` at bytes 5236 and 5200 describe the caller capacity, but this kernel does not use them to replace descriptor bounds.

Each GNU rank-two descriptor occupies 88 bytes. It contains the data pointer at byte 0, offset at 8, element length at 16, type/version/rank metadata at 24–31, span at 32, and dimension triples `(stride,lower,upper)` at bytes `(40,48,56)` and `(64,72,80)`. A valid FP64 real descriptor has type bytes `08000000000000000000000002030000` at 16–31. The data pointer names the first actual selected element, including for a reverse slice. The assumed-shape dummy uses lower bounds one, so element `(j,k)` is at `data + 8*((j-1)*stride1+(k-1)*stride2)`. Incoming actual lower bounds and offset must not shift this data pointer a second time. The numerical corpus checks distinct lower bounds and both stride signs.

The direct entry is `spcimpfinit_assembly_`, with the original eight by-reference arguments:

| Register | Argument and bounds |
| --- | --- |
| `x0` | Read-only geometry object |
| `x1` | Read-only runtime/time object |
| `x2` | Read-only dynamics object |
| `x3` | Read-only 32-bit `m` |
| `x4` | Read-only 32-bit `KSTA` |
| `x5` | Read-only 32-bit `KEND`, unused by the arithmetic |
| `x6` | Read-only vorticity descriptor; selected data are read and updated for `m>0` |
| `x7` | Read-only auxiliary descriptor; selected data are overwritten |

There are no incoming stack arguments or hidden lengths. The module scalar `__yomcst_MOD_romega` supplies the rotation frequency. It is an immutable input to a call. The native body preserves `x19..x29` and the low 64 bits of `v8..v15`, keeps the stack 16-byte aligned, and leaves the reserved register `x18` untouched. Any private helper arrays belong to that invocation. Heap services `malloc/free` may provide storage; they supply no arithmetic stage. There are no called numerical dependencies. Correctly rounded FP64 `FDIV` and `FSQRT` implement the source quotient and root.

The verifier's assembly canary bridge receives these eight prepared arguments, calls the raw numerical entry directly, and reads all callee-saved canaries before restoring its own saved registers. No C callback or C epilogue stands between the tested entry and the canary reads.

## Frozen input corpus and independent science

The [critical verifier](../../../../../bench/openifs/EVIDENCE.md#local-reproduction), SHA256 2e63795b6dc2a66ed58542a4e4d76fdec5690d7d5c7f1d7595db39a2b70c9936, defines the complete deterministic corpus before native emission. Its reference-only preparation passed 197 source calls, with 47 zero-wave-number calls, 150 positive-wave-number calls, and 24 empty-level calls. It checks 51,668 independent values. Both writable physical spans end at a protected page in every case, and preceding guards and inactive elements retain their raw bytes.

The corpus includes `N=1,2,3,5,8` with every wave number; empty, one, three and five levels; all 22 `T21` wave blocks at 19 levels in the full 506-column allocation; higher degrees `127,32767,65535`; one-mode endpoints; different array strides and capacities; negative strides and shifted lower bounds; and inconsistent unused `KEND` values. It includes real/imaginary basis waves, mixed and constant histories, four-stage repeated inverse histories, signed zeros, gradual underflow, zero/reversed Coriolis factors, finite large factors with small vorticity, and zero-factor cases with the largest finite FP64 input. A genuine two-thread native fixture uses separate writable allocations with the same immutable physical inputs; its two entry calls are counted separately from the 197 reference cases.

The ordinary rotation input is `0x1.31da7d4fedf5fp-14` inverse seconds. It follows the original default Earth statements at `yomcst.F90:260,286–289`, with `RDAY=86400` seconds. The ordinary `RBTS2=0.6` and `TDT=3600` seconds are frozen case inputs, not a claim about every forecast call. Alternative inputs are fully defined in the verifier. Exact runtime scalar bits must be recorded by the scoped forecast comparator rather than inferred from printed decimal configuration.

Independent checks use long double to solve C02 and C03 directly from the frozen input values, without reproducing the source's rounding schedule or neighbor passes. They check `R'_n+alpha_n*I'_n=R_n`, `I'_n-alpha_n*R'_n=I_n`, both closed inverse components, and `(R'_n)^2+(I'_n)^2=(R_n^2+I_n^2)/(1+alpha_n^2)`. Basis inputs identify the exact lower and upper neighbor support. The zero zonal branch must preserve every vorticity bit. The constant auxiliary mode and a single retained mode must return positive zero in both parts.

The independent roundoff limit is fixed before generation at `4096*DBL_EPSILON*W + U`, where `W` is the sum of the magnitudes in the checked relation and `U` bounds lost FP64 subnormal terms. For the inverse/components, `U=64*DBL_TRUE_MIN*(1+abs(alpha))`; for squared magnitude it is `128*DBL_TRUE_MIN*(1+abs(R')+abs(I'))`; for the auxiliary map it is `128*DBL_TRUE_MIN*(1+abs(fminus)+abs(fplus))*(1+abs(alpha))`. All quantities use the stated SI units as numerical input values. This limit permits accumulated rounding and underflow, while exact source/native output tolerance remains zero. A separate diagnostic counts inputs that distinguish source-rounded multiplication/subtraction from a fused candidate. It does not supply the independent physics reference.

Reference preparation disables the source profiling hook and explicitly sets FPCR zero. It is labeled preparation: its second output stream is a copy of the Fortran output and does not claim native acceptance. The frozen reference output is `preparation/reference.bin`, SHA256 4a821ca815efba03e14e616e59430a5e022cb50410b309b059016f6ee5a19cfd; the canonical input stream is `preparation/input-corpus.bin`, SHA256 1062a642853b5f42ce74f4197ba15c9b277c048fa70bf519a07bd66bf1337f33. Earlier input preparation, the unused-helper compile rejection and their logs remain in the ignored archive.

## Complete returned bytes and forecast scope

Each critical output record begins with a 256-byte little-endian `SPCF0001` header, followed by the vorticity physical span with its 32-byte leading guard, then the auxiliary span with its guard. The header identifies the case/stage, dimensions, both signed strides, scalar bits and span lengths; it contains no pointer addresses or clock values. Numeric bits, signed zeros, inactive padding and NaN payloads are not rounded, masked or normalized. The same ordered record is written for source and native. Critical canonical inputs additionally include both 88-byte descriptors with only address metadata cleared; the fixed-zero object initialization and all scalar input bits are defined in the verifier. All complete input objects, descriptors, integer scalars and the module rotation input must remain unchanged.

The configured caller is `SPCM` at `arpifs/control/spcm.F90:253`. It allocates `ZSPAUX(NFLSUR,NSPEC2)` at line 241 and passes `YDSP%VOR` plus that complete auxiliary descriptor. `spectral_fields_mod.F90:273` allocates `YDSP%SP3D(NFLEVL,NSPEC2,NS3D)`, and line 313 aliases the vorticity view to one plane in that parent. The whole parent is needed to preserve all shared field offsets and verify every inactive field. The auxiliary argument is an input/output array: unselected incoming bytes, including other wave blocks awaiting their own call, are preserved rather than filled by this routine.

The POST comparator owns the sole logging-only `SPCM` relay. INIT consumes `int spcm_forecast_scope(const void *geometry,const double **sp3d,size_t *sp3d_elements)`; nullable outputs are supported, and the query returns one only inside a matching active geometry scope. The relay forwards the original five pointers `GEOMETRY,MODEL,CDCONF,YDSP,YDGMV` plus the GNU character length in `x5`, restoring nested scope on return. INIT clones the entire physical `SP3D` parent and the separate complete auxiliary allocation, preserving the vorticity view offset. It compares all returned parent and auxiliary bytes, allowing writes only to the selected vorticity cells for `m>0` and selected auxiliary cells in either branch. Original objects/scalars/descriptors remain read-only.

The accepted trace establishes 550 original entries from `SPCM`, with both wave-number branches inferred from `N=21,NUMP=22` and the single-task source partition. Individual wave arguments were not recorded in that earlier trace. Future genuine entries and source-shadow comparisons must be counted separately. There is no numerical dependency to double count for this routine. The comparator supports the actual serialized `OMP_NUM_THREADS=1` caller capture; independent native critical work checks a genuine outer parallel fixture.

## Generation provenance and acceptance

The direct body is emitted from this ordered contract and the original source equations with the measured storage layout. No compiler-produced solver instructions are used for construction. The required dependency supplement contained one compiler frontend square-root expression, which broad metadata extraction displayed during preparation. This exposure is explicitly archived in `preparation-exposure.json` and excluded from construction. No compiler solver machine instructions or other numerical intermediate representation was read before emission.

The critical milestones require zero differing bytes against the immutable strict Fortran archive, independent science within the frozen limit, complete inactive/guard preservation, genuine parallel agreement, direct callee-saved-register checks, and FPCR zero. Post-emission instruction inspection must reject prohibited arithmetic, reduced precision and reserved-register use. The original source, the physical note and all accepted comparison archives remain unchanged. The caller-scoped forecast acceptance below is separate from these unchanged critical checks. Comparative timing remains unfinished.

## Full forecast acceptance and reproduction

All 550 genuine INIT calls pass in the fresh combined T21 forecast, with 25 zero-wave and 525 positive-wave calls. The observer checks 590,425 independent relations and 721,050 finite active values. The 169,206,400 full allocation bytes and 550 deterministic 512-byte headers give 169,488,000 canonical returned bytes. They include every shared SP3D field and the separate complete AUX allocation. All 23 paired streams and ten saved files directly match the strict Fortran baseline. This checkpoint runs through own exclusive job 7189435 on nid010825, with CPU 0 and local memory placement.

The observer compares the source image with the unchanged EC_PHYS_DRV image, so the equivalent bin/../lib loader spelling is accepted. Its first pathname-only guard stopped at call zero before numerical execution. The failed run and original observer are archived, and the assembly body, corpus and critical outputs are unchanged. The [compact record](../../../../../bench/openifs/EVIDENCE.md#routine-records) identifies the accepted artifacts and command archive. Whole-forecast physics and comparative timing remain unfinished.

The [ABI bridge](../../../../../bench/openifs/EVIDENCE.md#local-reproduction) checks preserved registers and FPCR immediately after the numerical call. Rebuilding its retained local source produces the identical accepted object. Run the commands below through srun in a quiet exclusive allocation, using the frozen strict OpenIFS build and a new ignored output directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/spcimpfinit/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -c src/openifs/dynamics/spcimpfinit.S -o "$check_dir/assembly.o"
gcc -c bench/openifs/dynamics/spcimpfinit_abi.S -o "$check_dir/abi.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fopenmp \
  -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/spcimpfinit.c \
  "$check_dir/assembly.o" "$check_dir/abi.o" -L "$build_root/lib" \
  -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$build_root/lib" \
  -o "$check_dir/verify"
OMP_NUM_THREADS=1 "$check_dir/verify" "$check_dir/assembly.bin" \
  "$check_dir/fortran.bin" "$check_dir/input-corpus.bin"
cmp "$check_dir/assembly.bin" "$check_dir/fortran.bin"
cmp "$check_dir/fortran.bin" .runtime/openifs/spcimpfinit/preparation/reference.bin
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC \
  -Wall -Wextra -Werror -c .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/spcimpfinit_forecast.c \
  -o "$check_dir/forecast.o"
gcc -shared -Wl,-Bsymbolic "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -ldl -lpthread -lm -o "$check_dir/libverify-spcimpfinit.so"
```

Preload INIT before the accepted POST observer, followed by the other verified comparator and strict reference libraries. POST supplies the sole SPCM relay and read-only scope query. Keep one forecast thread for whole-parent observation, and compare every emitted stream and saved file directly before recording acceptance.
