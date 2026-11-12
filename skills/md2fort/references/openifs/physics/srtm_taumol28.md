# SRTM_TAUMOL28 Solver Contract

Revision 1 fixes the complete numerical body for ultraviolet band 28. The original 188-line Fortran routine treats ozone and oxygen absorption from 38,000 to 50,000 cm⁻¹, where the unit counts wave cycles per centimetre. It also computes molecular scattering and the solar energy assigned to six spectral points. A spectral point is one representative part of the band used by the radiation calculation.

This is an implementation contract for `md2fort`. It keeps the original science, coefficient data and operation order. The short physical formulation remains separate. Read the [writing convention](../../../../../standards/ASD-STE100-CONV.md) for the documentation style.

## 1. Physical Quantities and Units

A molecular column counts molecules above a unit area. Let $`N_3`$ denote the scaled ozone column, $`N_2`$ the scaled oxygen column and $`N_{\mathrm{all}}`$ the scaled total molecular column. Their numerical unit is approximately $`10^{20}`$ molecules/cm², with the original scale conversion defined below. Absorption and Rayleigh coefficients have the inverse column unit, so their products are dimensionless optical depths. Optical depth measures how strongly a layer removes radiation from a beam. Solar flux has units W/m².

| Source name | Meaning | Unit |
| --- | --- | --- |
| `P_COLO3` | Ozone molecular column $`N_3`$ | Source-scaled molecules/cm² |
| `P_COLO2` | Oxygen molecular column $`N_2`$ | Source-scaled molecules/cm² |
| `P_COLMOL` | Total molecular column $`N_{\mathrm{all}}`$ | Source-scaled molecules/cm² |
| `STRRAT` | Relative contribution of oxygen to the combined column | Dimensionless |
| `ABSA`, `ABSB` | Lower and upper absorption coefficients | Inverse source-scaled column |
| `RAYL` | Molecular Rayleigh scattering coefficient | Inverse source-scaled column |
| `P_TAUG`, `P_TAUR` | Absorption and scattering optical depths | Dimensionless |
| `SFLUXREFC`, `P_SFLUXZEN` | Reference and returned solar flux | W/m² |
| `PRMU0` | Cosine of the solar zenith angle | Dimensionless |

Ozone and oxygen form a combined column and a mixture fraction. The mixture fraction tells the coefficient table which gas composition to use.

```math
C=N_3+rN_2,\qquad p=\frac{N_3}{C},
\qquad r=6.67029\times10^{-7}.
\tag{SW28-C1}
```

The source limits the fraction to a supplied value `P_ONEMINUS` strictly below one. This keeps the two adjacent mixture table entries inside their complete allocation. The lower table has nine mixture nodes, while the upper table has five nodes.

Scattering follows the total molecular column.

```math
\tau_R=N_{\mathrm{all}}R,\qquad R=2.02\times10^{-5}.
\tag{SW28-C2}
```

The caller later adds absorption and scattering to obtain the total optical depth. Band 28 does not evaluate a water continuum. The imported original data and every active statement establish that scope.

### Retained Gas Preparation

The original forecast path uses `radiation_ifs_rrtm`, then `RRTM_PREPARE_GASES` and `SRTM_SETCOEF`. Oxygen begins as the fixed dry-air molecular fraction $`0.209488`$. Ozone begins as a mass mixing ratio, converted with the source molecular masses $`28.970`$ and $`47.9982`$ g/mol before multiplication by the retained dry column. The separate legacy `SRTM_SRTM_224GP_MCICA` route is preserved as provenance but is not substituted for this captured caller.

The source scale is $`A=\operatorname{FP64}(\operatorname{FP32}(10^{-20}))`$, because the original `1.E-20` literal has the default real kind. It equals $`9.9999996826552254\times10^{-21}`$. The prescribed exact-zero oxygen replacement uses the similarly converted `1.E-32` literal multiplied by the dry column. Preserve these original rounded operations. The total scaled column is the separately rounded sum of the scaled dry and water columns.

Gas preparation retains its original approximate moist-air correction. It does not enforce exact moist-mass conservation. If $`q`$ is the water mass divided by total moist-air mass, the already verified preparation uses $`w=qM_d/M_w`$ and $`M=M_d(1-w)+M_ww`$, then divides by $`M(1+w)`$. The masses $`M_d=28.970`$ and $`M_w=18.0154`$ have units g/mol.

In exact real arithmetic, define $`D=1+q-C_q q^2`$, where $`C_q=(M_d-M_w)M_d/M_w^2`$. The inferred dry and water masses are respectively $`m/D`$ and $`qm/D`$ for a layer air mass $`m`$. Their total relative mass bias is $`C_q q^2/D`$. The source total molecular column has the ideal-real ratio $`1/(1-a^2q^2)`$ to the physical moist mixture, where $`a=(M_d-M_w)/M_w`$. These algebraic comparisons describe the retained approximation. They do not replace the original rounded products, divisions and sums, and the literal scale error is separate.

All 6,400 captured band inputs are connected directly to the original gas outputs. The check verifies 972,800 layer-column cells and 5,888,000 independent relations. It checks oxygen, ozone and total-column scale bits, with no change to the wet approximation. The source mixture fraction ranges from 0.1183391927 to 0.9830809908.

## 2. Ordered Binary64 Arithmetic

`RN` means one binary64 operation rounded to nearest, with an exact halfway result rounded to the even significand. Preserve gradual underflow and the sign of zero. The Arm floating-point control register must equal zero. Every operation below is separate. Do not contract a multiply and addition, change their order, use a reciprocal approximation or use a smaller precision.

For each active layer and daylight column, first form the mixed column, capped mixture and source integer indices. A daylight column has `PRMU0 > 0`.

```math
u_2=\mathrm{RN}(rN_2),\quad
C=\mathrm{RN}(N_3+u_2),\quad
p=\mathrm{RN}(N_3/C),\quad
p=\begin{cases}p& p<p_{\max}\\p_{\max}&p\ge p_{\max}.\end{cases}
\tag{SW28-C3}
```

Use $`s=9`$ and $`b=8`$ in the lower pass. Use $`s=5`$ and $`b=4`$ in the upper pass. The lower pass contains layers at or below the supplied tropopause index, which marks the change between the two tables. The upper pass contains the remaining active layers.

```math
x=\mathrm{RN}(bp),\qquad
j=1+\operatorname{INT}(x),\qquad
f=\operatorname{MOD}(x,1).
\tag{SW28-C4}
```

`INT` truncates towards zero. The verified domain has $`0\le x<b`$, so the result lies from zero through $`b-1`$. For this domain, `MOD(x,1)` has exactly the same binary64 bits as $`x-\operatorname{FP64}(\operatorname{INT}(x))`$, including negative zero. Multiplication by four or eight is exact here. For a positive integer part, the subtraction is exact because its operands differ by at most a factor of two. For an integer part of zero, subtraction preserves the source signed zero.

The table uses one-based source indices. Let $`J_P,J_T,J_{T1}`$ be the pressure and two temperature indices. Let $`\ell=1`$ for the lower table and $`\ell=13`$ for the upper table.

```math
I_0=\bigl[5(J_P-\ell)+(J_T-1)\bigr]s+j,\qquad
I_1=\bigl[5(J_P-\ell+1)+(J_{T1}-1)\bigr]s+j.
\tag{SW28-C5}
```

Let $`T`$ be the selected table and $`F_{00},F_{10},F_{01},F_{11}`$ its supplied pressure-temperature factors. Form each four-product sum in the displayed left-to-right order. The table coefficient is the first operand of each multiplication.

```math
\begin{aligned}
a_0&=\mathrm{RN}(T(I_0,g)F_{00})\\
a_1&=\mathrm{RN}(a_0+\mathrm{RN}(T(I_0+s,g)F_{10}))\\
a_2&=\mathrm{RN}(a_1+\mathrm{RN}(T(I_1,g)F_{01}))\\
L&=\mathrm{RN}(a_2+\mathrm{RN}(T(I_1+s,g)F_{11}))\\
b_0&=\mathrm{RN}(T(I_0+1,g)F_{00})\\
b_1&=\mathrm{RN}(b_0+\mathrm{RN}(T(I_0+s+1,g)F_{10}))\\
b_2&=\mathrm{RN}(b_1+\mathrm{RN}(T(I_1+1,g)F_{01}))\\
U&=\mathrm{RN}(b_2+\mathrm{RN}(T(I_1+s+1,g)F_{11})).
\end{aligned}
\tag{SW28-C6}
```

Blend the adjacent mixture coefficients, then multiply by the complete combined column.

```math
h=\mathrm{RN}(1-f),\quad
v_0=\mathrm{RN}(hL),\quad
v_1=\mathrm{RN}(fU),\quad
v=\mathrm{RN}(v_0+v_1),\quad
\tau_G=\mathrm{RN}(Cv).
\tag{SW28-C7}
```

The original factors sometimes describe a small extrapolation, so a factor can be negative. Their sum must remain one within the independent check's rounding allowance. Preserve the signed factors. The captured source minimum and maximum are −1.5854138628 and 2.5593447427. Scientific acceptance checks the resulting complete absorption against the independently expanded eight-corner formula and requires finite, nonnegative active optical depths.

### Shared Upper Solar Selection

Complete the entire lower pass before the upper pass. In both passes, visit layers first and then columns in increasing order. The upper solar selector is one shared integer, not one value per column. It begins at $`H`$, the number of active layers.

For each daylight upper-layer visit, read both the previous and current pressure indices. If the previous index is below `LAYREFFR = 58` and the current index is at least 58, replace the shared selector by the current one-based layer index. This change affects later columns and later layers. Every active previous-layer read must be valid even when a Fortran compiler does not short-circuit the logical condition.

When the current layer equals the shared selector, write the six active solar values. A column can receive more than one write. Its final values come from its last actual write in this original shared order.

```math
d=\mathrm{RN}(S(g,j+1)-S(g,j)),\qquad
v=\mathrm{RN}(fd),\qquad
S_{\mathrm{out}}(g)=\mathrm{RN}(S(g,j)+v).
\tag{SW28-C8}
```

Each consumed daylight solar cell must receive an original source-defined upper write. The preflight check follows the complete shared order and rejects a missing write before either source or assembly execution. Night columns, unused spectral channels and extra allocated layers retain every incoming storage bit.

## 3. Complete Data and Coefficient Provenance

Fortran arrays store the column index fastest, then layer, then spectral point. Let $`n=KFDIA-KIDIA+1`$, $`V=YDDIMV\%NFLEVG`$, $`H=KLEV`$ and $`C_{\mathrm{cells}}=nV`$. Source arrays hold all 16 spectral points, although the imported `YOESRTM` active count is six. The separate `YOESRTA28` count of 16 is table storage capacity.

| Complete global | Shape | Bytes |
| --- | --- | --- |
| Lower `ABSA` alias of `KAC` | $`585\times16`$ | 74,880 |
| Upper `ABSB` alias of `KBC` | $`1175\times16`$ | 150,400 |
| Reduced `SFLUXREFC` | $`16\times5`$ | 640 |
| `RAYL` | One binary64 value | 8 |
| `LAYREFFR` | One signed 32-bit integer | 4 |
| `STRRAT` | One binary64 value | 8 |
| `NSPA`, `NSPB` | 14 signed 32-bit integers each | 112 total |
| Complete numerical globals | Eight complete allocations | 226,052 |

The retained `RADSRTM` file has 1,332,584 bytes and SHA-256 `068ab620ee7a42d0a4dc26240a595b96fe40e027b5c612983f58d01dbb8577e7`. All 13 big-endian record markers and the final file boundary agree. Band 28 reads record 12. Its marker begins at byte 1,068,888, and its payload begins at 1,068,892. The 225,280-byte payload has SHA-256 `2b97c99a199f8f9ebd4207145aaab431ea5c6ea7db4c85b08ef095aca0a5d30c`.

That record contains complete `KA_D(9,5,13,16)` followed by `KB_D(5,5,13:59,16)`. The source converts them to its declared real kind before reduction. The captured raw record, converted arrays and complete reduced arrays are all preserved and compared directly.

The reduced absorption uses `RWGT(IPRSM+192)` and six groups of sizes 1, 1, 2, 2, 4 and 6. Each group starts from positive zero and adds its weighted products in increasing raw-point order. All five solar columns use the same groups, with unweighted sums in the original order. The independent 80-digit calculation checks 10,590 reduction relations, while a separate ordered binary64 comparison checks every reduced source bit.

The original `MODIFY_WV_CONTINUUM` routine does not import or modify band 28. The original initialization observer still records the actual optional setting, which is present and zero. Preserve all 17 raw, converted, reduced and grouping allocations in the 680,052-byte provenance record. No unexplained numerical table is supplied by a comparison driver.

## 4. Interface, Bounds and Mutation

The application binary interface, or ABI, states how arguments and saved registers pass between routines. This routine has 20 ordinary pointer arguments and no hidden string or array descriptor. The first eight pointers arrive in `x0` through `x7`. Twelve further pointers occupy eight-byte stack slots at offsets zero through 88.

| Position | Argument | Complete allocation | Intent |
| --- | --- | --- | --- |
| 0 | `YDDIMV` | Eight signed 32-bit fields, 32 bytes | Read only |
| 1–3 | `KIDIA`, `KFDIA`, `KLEV` | One signed 32-bit integer each | Read only |
| 4–7 | `P_FAC00`, `P_FAC01`, `P_FAC10`, `P_FAC11` | $`nV`$ binary64 values each | Read only |
| 8–10 | `K_JP`, `K_JT`, `K_JT1` | $`nV`$ signed 32-bit integers each | Read only |
| 11 | `P_ONEMINUS` | $`n`$ binary64 values | Read only |
| 12–14 | `P_COLMOL`, `P_COLO2`, `P_COLO3` | $`nV`$ binary64 values each | Read only |
| 15 | `K_LAYTROP` | $`n`$ signed 32-bit integers | Read only |
| 16 | `P_SFLUXZEN` | $`16n`$ binary64 values | Partial mutation |
| 17–18 | `P_TAUG`, `P_TAUR` | $`16nV`$ binary64 values each | Partial mutation |
| 19 | `PRMU0` | $`n`$ binary64 values | Read only |

Every nonempty allocation must be present. Integers need four-byte alignment and real arrays need eight-byte alignment. Each range must fit its complete declared capacity without address wrap. Read-only allocations can share storage with one another. The three mutable output allocations must be disjoint from each other, all read-only allocations and the coefficient globals. Preserve the complete incoming contents of each output allocation, including bytes that the source does not change.

The accepted shape has $`0\le n\le4096`$ and $`0\le H\le V\le512`$. Require `KIDIA >= 1` and `KFDIA <= 2147483646`. Compute the column count in signed 64-bit arithmetic before checking or narrowing it. This prevents invalid label subtraction from overflowing. The terminal-label limit also makes the original signed 32-bit loop increment defined. An empty column range is allowed.

For each daylight active layer, require finite molecular columns from zero through $`2^{300}`$, a normal positive finite combined column, and finite factors with absolute value at most $`2^{20}`$. A daylight mixture cap lies strictly between zero and one. The zenith cosine is finite and lies from −1 through one.

Temperature indices lie from one through four. Lower pressure indices lie from one through 12. Upper pressure indices lie from 13 through 58. These bounds include every adjacent temperature, pressure and mixture table entry. A daylight upper branch must have a valid previous layer. For a nonempty consumed daylight result, the supplied tropopause must be positive and smaller than the active-layer count, and the complete shared solar check must find a write.

Every active table value and solar reference is finite, nonnegative and at most $`2^{100}`$. `STRRAT` is positive and at most $`2^{16}`$. The reference layer lies from 13 through 59. Freeze the source values for actual forecasting. Critical cases also use independently checked finite tables to test physical limits and table boundaries.

The accepted first body uses a fixed 304-byte aligned stack frame. It saves `x19` through `x30`, keeps all 20 argument pointers, and stores bounded scalar loop state. It uses no dynamic scratch array. It must preserve the stack pointer and all required saved register bits, leave `x18` untouched, and avoid the saved floating-point registers `d8` through `d15`. The separate 256-byte ABI observer forwards all 20 pointers, checks the saved integer and low 64-bit floating registers, checks the stack position, and checks the unchanged zero floating-point control register. That observer supplies no numerical work.

## 5. Complete Input and Output Encoding

All frozen records use the target's little-endian signed 32-bit integers and IEEE binary64 bytes. The 32-byte header contains a 64-bit call number, two signed 32-bit phase and site fields, then `KIDIA`, `KFDIA`, `KLEV` and `NFLEVG`. Actual records use the original call order and 25 phases, each with 256 calls.

The complete incoming record then contains all 32 `TDIMV` bytes, all 226,052 numerical-global bytes, arguments 4 through 15 in interface order, `PRMU0`, then complete incoming solar, absorption and scattering output allocations. The complete returned record contains the unchanged header followed by all three complete output allocations.

```math
B_{\mathrm{in}}=226116+324nV+148n,\qquad
B_{\mathrm{out}}=32+128n+256nV.
\tag{SW28-C9}
```

The source-only forecast holds all 6,400 records, with 1,769,907,200 incoming bytes and 255,795,200 returned bytes. Every incoming bit remains part of the input, even when the source leaves that location unused. A source/native comparison must run both bodies from the same complete record and compare every returned byte. A new forecast may have different unused incoming bytes, so full cross-run equality must be checked rather than assumed.

Never round, mask or normalise output bits to conceal a mismatch. Compare complete arrays directly and report the first record, field, byte and source/native bit patterns. Identify archived artifacts with hashes, while direct byte comparison establishes equality. Compare all ten saved forecast files directly to the unchanged strict-vertical canonical forecast.

## 6. Source-Only Scientific Acceptance

The original source executes before any primary assembly emission. Independent checks expand all eight mixture, temperature and pressure corner weights in higher precision, rather than reusing the source's two rounded four-product brackets. They check both complete gas mixtures, scattering, five-node solar interpolation, zero and unit limits, physical admissibility, shared solar ordering and every unchanged storage byte.

The 330-record critical corpus has 13 shapes, six physical coefficient profiles and four composition or factor variants, followed by 18 additional shared-solar crossing cases. It includes every lower and upper mixture interval, pure-gas limits, cap limits, negative zero, nonzero subnormal coefficients, positive and negative zero outputs, bounded negative extrapolation, night columns, empty dimensions, extra allocated layers, maximum column count and maximum layer capacity. The shared cases use different column tropopauses and pressure crossings.

Both protected boundary placements pass 660 original-source calls, 139,304,064 complete returned bytes and 34,323,192 independent relations. The largest permitted column labels pass a further four protected calls. Ten invalid extreme shape cases are rejected by both the capacity check and the serialized parser before any array or original body access.

All 6,400 complete original forecast inputs pass protected source replay. Their 255,795,200 returned bytes match the frozen source forecast directly, including all inactive storage. The actual source forecast also passes 67,584,000 independent relations and all ten saved files, totalling 618,140 bytes.

A separate index check verifies 194,910 critical and 972,800 actual mixtures. It checks every integer bound and proves bitwise agreement between source `MOD` and the bounded subtraction, including 55,272 negative-zero critical fractions. Actual upper fractions reach 0.9830809908, so the highest adjacent upper node is exercised.

Scientific checks use explicit tolerances only for the independent higher-precision relations. Exact source/native and frozen replay acceptance always requires zero differing bytes. Both returned clones must receive the independent checks after native emission. Keep every original source, coefficient capture, failure, frozen corpus and original return immutable.

## 7. Generation and Measurement Rules

Emit one complete AArch64 body directly from this fixed contract and the original active statements. Assemble and link it without numerical compiler assembly, intermediate representation or a high-level replacement kernel. The comparison driver may clone buffers and check outputs, but it may not supply omitted absorption, scattering, mixture indexing or solar work.

Use the declared Neoverse-V2 target, binary64 operations and exact integer conversion. The body may use an exact bounded subtraction for `MOD` only after the source-only proof above. It must retain both complete passes and the shared solar state. Independent peer reviews of the original science and frozen references must close before emission, with a new scientific gate for any unsettled dependency.

After emission, run the protected critical and terminal-label corpus, the complete original-input replay and the immediate ABI checks. Then run a fresh isolated full forecast, comparing complete same-input source/native returns and all ten saved files. Preserve the first body and every comparison artifact. No comparative timing is accepted by these verification checks.

Every read, build and simulation runs through the own exclusive allocation 7207705 on node `nid011311`, with CPU16 and local memory placement. Timing requires a separately coordinated quiet-node block, accepted before and after load checks, repeated paired workloads and verified final states outside the timer. Preserve the original source-only measurements as verification evidence, without treating their run duration as a performance result.

## 8. Accepted Body and Reproduction

The complete first assembly body contains 213 instructions, occupies 852 function bytes and uses the fixed 304-byte frame. It computes both complete ozone–oxygen absorption passes, molecular scattering and the shared upper solar update. Its first source and object stayed unchanged through every check. Four adjacent coefficient pairs supply the two ordered four-product brackets, while each bracket keeps its original separate rounding points.

The 330 critical records pass 660 protected assembly calls, and two valid terminal-label records pass four more. Every complete original forecast input passes a further 6,400 protected calls. All 7,064 immediate ABI checks pass, together with complete byte comparisons and independent physical checks of both returned clones. The single C driver includes the frozen nonnumerical ABI observer when built with `SRTM28_ABI_OBSERVER`.

The isolated forecast passes all 6,400 complete same-input source–assembly pairs over 255,795,200 returned bytes. All ten saved files directly match the canonical forecast over 618,140 bytes. The complete numerical input planes, coefficient globals and used object field also match the source-only capture, across 1,513,932,800 checked bytes. The fresh incoming archive retains 55,992,141 differing unused bytes, including 12,802 unused object bytes and 55,979,339 unused output bytes. Every unused return equals its own incoming storage, and every active physical output agrees. This evidence therefore qualifies complete equality by input record, while preserving all raw cross-run differences.

Run these exact commands from the repository root through the assigned exclusive allocation. They build the public assembly and single verifier, replay the protected critical, terminal and complete original inputs, then compare the whole rebuilt object and both libraries with their accepted private copies. Use a new output folder on later repetitions so previous evidence stays immutable. The copied C basenames retain the existing library metadata. No comparative timing has been accepted for this body.

```sh
srun --jobid=7207705 --overlap --exact -N1 -n1 -c17 --cpu-bind=map_cpu:16 --mem-bind=local bash -lc '
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
cd /lus/lfs1aip2/projects/u6yq/users/p3jitnath/esm.md
release="$PWD/.runtime/openifs/srtm_taumol28_7207705"
check="$release/public-reproduction"
mkdir "$check"
cp .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol28.c "$check/critical-future-verifier.c"
cp .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol28_forecast.c "$check/future-forecast-verifier.c"
gcc -c -mcpu=neoverse-v2 src/openifs/physics/srtm_taumol28.S -o "$check/assembly.o"
gcc -DSRTM28_ABI_OBSERVER -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror -Wno-misleading-indentation -Wno-parentheses "$check/critical-future-verifier.c" "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/verify"
"$check/verify" guarded "$release/preparation/critical-corpus-v1.bin" "$check/critical-source.bin" "$check/critical-native.bin" > "$check/critical.log"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-source.bin"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-native.bin"
"$check/verify" guarded "$release/preparation/terminal-column-label-corpus.bin" "$check/terminal-source.bin" "$check/terminal-native.bin" > "$check/terminal.log"
cmp "$release/preparation/terminal-column-label-fortran.bin" "$check/terminal-source.bin"
cmp "$release/preparation/terminal-column-label-fortran.bin" "$check/terminal-native.bin"
"$check/verify" replay .runtime/openifs/runs/strict-srtm28-source-7207705/t21/test_fc/srtm28-inputs.bin "$check/replay-source.bin" "$check/replay-native.bin" > "$check/replay.log"
cmp .runtime/openifs/runs/strict-srtm28-source-7207705/t21/test_fc/srtm28-fortran.bin "$check/replay-source.bin"
cmp .runtime/openifs/runs/strict-srtm28-source-7207705/t21/test_fc/srtm28-fortran.bin "$check/replay-native.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror -Wno-misleading-indentation -Wno-parentheses "$check/future-forecast-verifier.c" "$check/assembly.o" -ldl -lm -o "$check/libverify-srtm28.so"
gcc -shared -fPIC -DSRTM28_OMIT_INIT_RELAY -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror -Wno-misleading-indentation -Wno-parentheses "$check/future-forecast-verifier.c" "$check/assembly.o" -ldl -lm -o "$check/libverify-srtm28-parent-omit-init.so"
cmp "$release/native/assembly.o" "$check/assembly.o"
cmp "$release/native/libverify-srtm28.so" "$check/libverify-srtm28.so"
cmp "$release/native/libverify-srtm28-parent-omit-init.so" "$check/libverify-srtm28-parent-omit-init.so"
cat "$check/critical.log"
cat "$check/terminal.log"
cat "$check/replay.log"
'
```

For a combined forecast, use `libverify-srtm28-parent-omit-init.so`, built with `SRTM28_OMIT_INIT_RELAY`. The accepted band 29 observer must provide the sole unchanged original initialization relay and its present zero flag. The default isolated library preserves its own original setup record. Both variants retain the complete band 28 coefficients and all incoming and returned storage without changing any numerical setup.

Keep the strict ordered-vertical and accepted pressure-math controls, with `OMP_NUM_THREADS=1` and `OMP_DYNAMIC=FALSE`. Use the comparator before the original strict Fortran library. Its capture prefix is `srtm28`, and its original caller return site is `0x873188`. Every compared call comes from the unchanged `SRTM_GAS_OPTICAL_DEPTH` caller in forecast phases zero through 24. Complete raw archives include all sixteen points, night columns and unused allocated layers.

Independent source and first-body reviews remain in the immutable local release. The pre-emission freeze pins 255 source-only references and 2,794,821,932 bytes. Assembly generation used the fixed equations, ordered arithmetic and ordinary pointer interface directly, with no numerical compiler assembly or intermediate representation. The verification drivers supply complete inputs and checks, while every required optical calculation stays inside the primary.
