# SRTM_TAUMOL17 Solver Contract

Revision 1 preserves the complete original band-17 calculation in OpenIFS 48.1.1. Water vapour and carbon dioxide absorb shortwave radiation from 3250 to 4000 cm⁻¹. This unit counts wave cycles per centimetre. Twelve representative spectral points cover that interval, while the original storage holds sixteen points. The [radiation formulation](../../../../../formulations/openifs/physics/radiation.md) gives the basic physical balance. This contract gives the numerical method, complete storage and verification rules used by [md2asm](../../../SKILL.md).

## Physical Quantities and Preparation

A molecular column counts molecules above a unit area. Let $`N_w,N_c,N_{\mathrm{all}}`$ be the source-scaled water, carbon dioxide and total molecular columns, in approximately $`10^{20}`$ molecules/cm². An absorption coefficient has the inverse column unit. Optical depth is their dimensionless product and measures how strongly a layer removes radiation. Solar flux is energy flow in W/m².

The gases form the combined column $`C`$ and water fraction $`p`$ below. The ratio weight $`r`$ is dimensionless.

```math
C=N_w+rN_c,\qquad p=\frac{N_w}{C},
\qquad r=0.364641.
\tag{SW17-C1}
```

The supplied mixture cap `P_ONEMINUS` lies strictly below one. The lower and upper tables contain nine and five mixture nodes, respectively. The lower branch includes a water self continuum, which describes interactions between water molecules, and a foreign continuum, which describes interactions with other molecules. The upper branch includes the foreign continuum. The scattering coefficient $`R`$ has the inverse source-column unit.

```math
\tau_R=N_{\mathrm{all}}R,\qquad R=6.86\times10^{-10}.
\tag{SW17-C2}
```

The unchanged caller obtains molecular columns from `radiation_ifs_rrtm` and `RRTM_PREPARE_GASES`, then obtains interpolation fields from `SRTM_SETCOEF`. The gas preparation converts the carbon dioxide mass ratio with dry-air and carbon dioxide molecular masses 28.970 and 44.011 g/mol. Water begins as specific humidity $`q`$, the water mass divided by total moist-air mass. These preparation stages remain outside this leaf, with their original outputs frozen as its inputs.

The original default-real scale is $`A=\operatorname{FP64}(\operatorname{FP32}(10^{-20}))=9.9999996826552254\times10^{-21}`$. The exact-zero carbon dioxide replacement uses `FP64(FP32(1.E-32))` times the dry column. Preserve these converted literals and every separate rounding point. The source also converts its default-real 7.2 K self-temperature spacing to 7.1999998092651367 K.

For pressure $`P`$ in hPa, temperature $`T`$ in K and source water-to-dry molecule ratio $`w`$, define $`S=296/1013`$ K/hPa. The dimensionless continuum density factors have the following real-valued form. Signed temperature fractions allow the original extrapolation beyond adjacent tabulated temperatures.

```math
F_f=\frac{PS}{T(1+w)},\qquad F_s=wF_f.
\tag{SW17-C3}
```

The retained wet-air preparation is approximate. With dry and water molecular masses $`M_d=28.970`$ and $`M_w=18.0154`$ g/mol, it uses $`w=qM_d/M_w`$ and $`M=M_d(1-w)+M_ww`$, then divides by $`M(1+w)`$. For a layer air mass $`m`$, the following quantities describe its ideal-real bias.

```math
D=1+q-C_q q^2,\qquad
C_q=\frac{(M_d-M_w)M_d}{M_w^2},\qquad
a=\frac{M_d}{M_w}-1.
\tag{SW17-C4}
```

The inferred dry and water masses are $`m/D`$ and $`qm/D`$. Their total fractional mass bias is $`C_q q^2/D`$. The water-column factor is $`(A/10^{-20})/D`$, while the total-column and Rayleigh-depth factor is $`(A/10^{-20})/(1-a^2q^2)`$. These relations describe the retained model and do not replace its rounded arithmetic.

The physical water-to-dry molecule ratio is $`w_{\mathrm{phys}}=w/(1-q)`$. At equal pressure and temperature, the source and physical continuum composition factors have the ratios below.

```math
\frac{F_{s,\mathrm{source}}}{F_{s,\mathrm{physical}}}
=1-\frac{q}{1+w},\qquad
\frac{F_{f,\mathrm{source}}}{F_{f,\mathrm{physical}}}
=1+\frac{qw}{(1-q)(1+w)}.
\tag{SW17-C5}
```

For $`q>0`$, the self ratio applies directly. At zero humidity both self factors vanish, and the ratio has continuous limit one. The foreign ratio equals one there. Across $`0\le q\le0.05`$, the largest self underestimate is 4.627901% and foreign overestimate is 0.3916833%. The connected capture covers $`9.999999999940612\times10^{-9}\le q\le0.025324884844875363`$, where the corresponding extrema are 2.433391% and 0.1016726%. These are composition-factor effects. Column approximation, literal conversion and rounding remain separate.

## Ordered Arithmetic

`RN` means one binary64 operation rounded to nearest, with a halfway result rounded to the even significand. Binary64 stores a real number in 64 bits. Preserve signed zeros and gradual underflow. The Arm floating-point control register must equal zero. Multiplication and addition stay separate, with no fused operation, reassociation, approximate division or reduced precision.

A daylight cell has `PRMU0 > 0`, where `PRMU0` is the cosine of the solar zenith angle. First form its combined column and capped mixture fraction.

```math
v=\mathrm{RN}(rN_c),\quad
C=\mathrm{RN}(N_w+v),\quad
p=\mathrm{RN}(N_w/C),\quad
p=\begin{cases}p&p<p_{\max}\\p_{\max}&p\ge p_{\max}.\end{cases}
\tag{SW17-C6}
```

Use $`s=9,b=8,\ell=1`$ for the lower branch and $`s=5,b=4,\ell=13`$ for the upper branch. The supplied tropopause index divides the branches, including that index in the lower branch. The mixture position gives an adjacent-node index $`j`$ and fraction $`f`$.

```math
x=\mathrm{RN}(bp),\qquad j=1+\operatorname{INT}(x),\qquad
f=\operatorname{MOD}(x,1).
\tag{SW17-C7}
```

`INT` truncates towards zero. The accepted domain has $`0\le x<b`$. For a nonzero integer part, the subtraction $`x-\operatorname{FP64}(\operatorname{INT}(x))`$ is exact because the operands differ by at most a factor of two. For a zero integer part, retain the original $`x`$ bits, including negative zero. This reproduces the original `MOD` bits over the declared domain.

Let $`J_P,J_T,J_{T1}`$ be the supplied pressure and temperature indices. The table indices below are one-based.

```math
I_0=[5(J_P-\ell)+(J_T-1)]s+j,\qquad
I_1=[5(J_P-\ell+1)+(J_{T1}-1)]s+j.
\tag{SW17-C8}
```

Let $`T_a`$ be the selected absorption table and $`g`$ the spectral point. The dimensionless factors $`F_{00},F_{10},F_{01},F_{11}`$ weight the four pressure and temperature corners. Each coefficient is the first multiplication operand. Preserve both four-product sums in this left-to-right order.

```math
\begin{aligned}
a_0&=\mathrm{RN}(T_a(I_0,g)F_{00})\\
a_1&=\mathrm{RN}(a_0+\mathrm{RN}(T_a(I_0+s,g)F_{10}))\\
a_2&=\mathrm{RN}(a_1+\mathrm{RN}(T_a(I_1,g)F_{01}))\\
L&=\mathrm{RN}(a_2+\mathrm{RN}(T_a(I_1+s,g)F_{11}))\\
b_0&=\mathrm{RN}(T_a(I_0+1,g)F_{00})\\
b_1&=\mathrm{RN}(b_0+\mathrm{RN}(T_a(I_0+s+1,g)F_{10}))\\
b_2&=\mathrm{RN}(b_1+\mathrm{RN}(T_a(I_1+1,g)F_{01}))\\
U&=\mathrm{RN}(b_2+\mathrm{RN}(T_a(I_1+s+1,g)F_{11})).
\end{aligned}
\tag{SW17-C9}
```

Blend the adjacent mixture sums, then multiply by the combined column.

```math
z=\mathrm{RN}(1-f),\quad
v_0=\mathrm{RN}(zL),\quad v_1=\mathrm{RN}(fU),\quad
B=\mathrm{RN}(v_0+v_1),\quad M=\mathrm{RN}(CB).
\tag{SW17-C10}
```

The one-based continuum indices are $`i_s,i_f`$, with dimensionless temperature fractions $`f_s,f_f`$. `SELF` and `FORE` denote the self and foreign tables. Each interpolation preserves the rounded difference and product.

```math
\begin{aligned}
d_s&=\mathrm{RN}(\mathrm{SELF}(i_s+1,g)-\mathrm{SELF}(i_s,g))\\
S_g&=\mathrm{RN}(\mathrm{SELF}(i_s,g)+\mathrm{RN}(f_s d_s))\\
d_f&=\mathrm{RN}(\mathrm{FORE}(i_f+1,g)-\mathrm{FORE}(i_f,g))\\
F_g&=\mathrm{RN}(\mathrm{FORE}(i_f,g)+\mathrm{RN}(f_f d_f)).
\end{aligned}
\tag{SW17-C11}
```

The lower branch uses dimensionless density factors $`F_s,F_f`$, then multiplies their combined continuum contribution by water.

```math
S'=\mathrm{RN}(F_s S_g),\quad F'=\mathrm{RN}(F_f F_g),\quad
W=\mathrm{RN}(N_w\,\mathrm{RN}(S'+F')),\quad
\tau_G=\mathrm{RN}(M+W).
\tag{SW17-C12}
```

The upper branch reads only foreign continuum fields and multiplies water by its density factor first. Both branches use the same separately rounded Rayleigh product.

```math
W_f=\mathrm{RN}(\mathrm{RN}(N_wF_f)F_g),\quad
\tau_G=\mathrm{RN}(M+W_f),\quad
\tau_R=\mathrm{RN}(N_{\mathrm{all}}R).
\tag{SW17-C13}
```

Compute that Rayleigh product once per cell and copy its bits to all twelve active points.

### Shared Solar Selection

Complete the entire lower pass before the upper pass. Each pass visits layers first and columns second, in increasing order. Set the single shared `I_LAYSOLFR` selector to the active layer count. During the upper pass, a previous pressure index below `LAYREFFR` and a current index at or above it change the selector to the current one-based layer. The captured `LAYREFFR` is 30.

A selector change affects later columns in the same layer and later layers. At each matching layer, write solar flux from the current upper mixture fraction. Let $`S_\odot`$ denote the five-node reference solar table, in W/m².

```math
d_\odot=\mathrm{RN}(S_\odot(g,j+1)-S_\odot(g,j)),\qquad
S_{\mathrm{out}}=\mathrm{RN}(S_\odot(g,j)+\mathrm{RN}(f d_\odot)).
\tag{SW17-C14}
```

Track the last actual write for every column through this shared order. Every consumed daylight solar slot in the forecast must have a source-defined write. A standalone case without such a write retains its incoming solar bits and does not claim a newly computed physical flux. The previous-layer pressure read must be valid even when the Fortran condition does not short-circuit.

## Coefficients and Complete Storage

The original `RADSRTM` file has 1,332,584 bytes and SHA-256 `068ab620ee7a42d0a4dc26240a595b96fe40e027b5c612983f58d01dbb8577e7`. Band 17 uses record 2. Its marker starts at byte 104,968 and its 225,280-byte payload starts at 104,972, with SHA-256 `b7347002e885f7a825352964d08687f94c71b3e03c3833f84575472ca82d8bd3`. Both markers and all thirteen record boundaries pass.

The payload contains `KA_D(9,5,13,16)` then `KB_D(5,5,13:59,16)`. Their converted binary64 bits agree with the raw values. Original `SRTM_CMBGB17` reduction uses `RWGT(IPRSM+16)` and twelve groups of sizes 1, 1, 1, 1, 1, 2, 1, 2, 1, 2, 1 and 2. Absorption and continua retain the original increasing-order weighted sums, while each solar column uses an unweighted sum. The 100-digit independent check passes 21,348 reductions, with maximum relative rounding residual $`1.920\times10^{-16}`$.

The optional `SRTM_INIT` flag can activate `MODIFY_WV_CONTINUUM` when it is exactly one, before reduction. The captured argument is present and zero. Preserve the unchanged original setup and its actual flag, together with every raw, literal, converted and reduced coefficient byte.

| Complete global | Shape | Bytes |
| --- | --- | ---: |
| `ABSA`, alias of reduced `KAC` | $`585\times16`$ | 74,880 |
| `ABSB`, alias of reduced `KBC` | $`1175\times16`$ | 150,400 |
| `SELFREFC` | $`10\times16`$ | 1,280 |
| `FORREFC` | $`4\times16`$ | 512 |
| `SFLUXREFC` | $`16\times5`$ | 640 |
| `RAYL`, `STRRAT` | One binary64 each | 16 |
| `LAYREFFR` | One int32 | 4 |
| `NSPA`, `NSPB` | Fourteen int32 values each | 112 |
| Total | Ten allocations in this order | 227,844 |

Let $`n=KFDIA-KIDIA+1`$, $`H=KLEV`$, $`V=YDDIMV\%NFLEVG`$ and $`C_n=nV`$. Columns vary fastest. Zero-based cell and spectral-output indices are $`j+nk`$ and $`j+n(k+Vg)`$.

| Argument positions, counted from zero | Complete allocation | Intent and mutation |
| --- | --- | --- |
| 0 | Original `TDIMV`, 32 bytes | Read-only, including unused fields |
| 1–3 | `KIDIA`, `KFDIA`, `KLEV`, four bytes each | Read-only |
| 4–7 | Four FP64 factor planes, $`C_n`$ elements each | Read-only |
| 8–10 | Three int32 pressure/temperature planes, $`C_n`$ each | Read-only |
| 11 | FP64 mixture cap, $`n`$ elements | Read-only |
| 12–14 | FP64 water, CO2 and total columns, $`C_n`$ each | Read-only |
| 15 | int32 tropopause vector, $`n`$ elements | Read-only |
| 16–17 | FP64 self factor/fraction, $`C_n`$ each | Read-only |
| 18 | int32 self index, $`C_n`$ elements | Read-only |
| 19–20 | FP64 foreign factor/fraction, $`C_n`$ each | Read-only |
| 21 | int32 foreign index, $`C_n`$ elements | Read-only |
| 22 | FP64 solar buffer, $`16n`$ elements | Active writes, otherwise retained |
| 23–24 | FP64 absorption/scattering, $`16C_n`$ each | Active writes, otherwise retained |
| 25 | FP64 zenith cosine, $`n`$ elements | Read-only |

The original `TDIMV` has eight int32 fields. Only its first field, `NFLEVG`, selects storage, but all 32 bytes remain in each input. All sixteen spectral points remain in complete incoming and returned buffers. The source changes only daylight columns, active layers and twelve active points. Night cells, extra layers, unused points and unwritten solar cells retain every incoming bit, including signed zeros and arbitrary NaN bit patterns.

## Bounds and Arm Interface

Check complete capacities before either numerical body. Form $`n`$ in signed 64-bit arithmetic before narrowing, requiring `KIDIA >= 1`, `KFDIA <= 2147483646`, $`0\le n\le4096`$ and $`0\le H\le V\le512`$. The column-label limit keeps the original int32 loop increment defined. Empty shapes are supported. Every nonempty integer or real allocation needs four-byte or eight-byte alignment, respectively, without address wrap. Output allocations are disjoint from each other, all read-only inputs and globals. Read-only inputs may share storage.

A finite zenith cosine lies in [−1,1]. For daylight cells, the mixture cap lies strictly between zero and one, molecular columns are finite and nonnegative up to $`2^{300}`$, and the mixed column is normal, finite and positive. All factors and signed temperature fractions have magnitude at most $`2^{20}`$, with nonnegative continuum density factors. Night numerical fields are not inspected.

Temperature indices lie from one through four. Lower pressure indices lie from one through twelve and self indices from one through nine. Upper pressure indices lie from thirteen through fifty-eight. Foreign indices lie from one through three in both branches. Every adjacent table entry must fit. Only lower cells read the self fields. For daylight $`H>0`$, require $`1\le K_{\mathrm{LAYTROP}}\le H`$. For $`H=0`$, require a zero tropopause. The forecast additionally requires $`K_{\mathrm{LAYTROP}}<H`$ and a tracked upper solar write.

Active coefficients and solar values are finite and nonnegative up to $`2^{100}`$. The positive mixture weight is at most $`2^{16}`$. The reference layer lies from thirteen through fifty-nine. Pressure-temperature factors sum to one within $`64\epsilon`$, where $`\epsilon=2^{-52}`$. Signed extrapolation remains allowed. Active optical depths must satisfy independent physical checks and be finite and nonnegative.

The application binary interface, or ABI, defines argument and register use. `srtm_taumol17_assembly_` receives twenty-six ordinary pointers. The first eight arrive in `x0` through `x7`, and eighteen more use eight-byte entry-stack slots at offsets zero through 136. It returns no value and changes only declared output cells.

The first complete AArch64 body has 351 instructions, 1,404 function bytes and a fixed 352-byte frame aligned to sixteen bytes. It preserves `x19` through `x30`, the stack pointer and FPCR, leaves `x18` untouched and does not use `d8` through `d15`. It calls no numerical helper. The separate nonnumerical ABI observer forwards all arguments and checks saved integer and floating registers immediately after every native return. The primary was emitted directly from the frozen equations and ordered contract, then assembled and linked without numerical compiler assembly or intermediate representation.

## Canonical Records and Physical Checks

Every binary record uses little-endian int32, uint64 and binary64 values. Its 32-byte header contains the call number, phase and source marker, then `KIDIA,KFDIA,H,V`. The incoming record continues with all 32 `TDIMV` bytes, the ten complete globals, arguments 4 through 21, the zenith vector and all three incoming output buffers. The returned record contains its unchanged header, then complete solar, absorption and scattering buffers.

The input and return sizes are $`227908+364C_n+148n`$ and $`32+128n+256C_n`$ bytes. All 6,400 forecast entries use eight columns and nineteen active/stored layers, giving 1,820,288,000 incoming and 255,795,200 returned bytes. They come from unchanged `SRTM_GAS_OPTICAL_DEPTH` at strict-library return offset `0x873110`, with 256 calls in each of 25 phases.

Independent binary128 checks expand eight corner weights rather than repeat the source's two rounded sums. They check both gas-mixture passes, both lower continua, upper foreign continuum, scattering, last solar writes and untouched storage. Let $`u=2^{-1074}`$ be the smallest positive binary64 value. The absorption allowance is $`512\epsilon`$ times the absolute expanded terms, plus $`256u(1+N_w+rN_c)(1+F_f+F_s)`$, with $`F_s=0`$ in the upper branch. The scattering allowance is $`16\epsilon|\tau_R|+4u`$. Solar allowance is $`512\epsilon`$ times the sum of the five nonnegative reference values, plus $`256u`$. Exact clone and replay comparisons always require zero differing bytes.

The source-only gas/continuum connection passes 10,547,200 independent relations over 972,800 complete cells. The 440 critical records cover thirteen shapes, all mixture bins and adjacent table corners, eight physical profiles, signed zeros, subnormal depths, night storage, extra layers, maximum capacities and shared multi-column solar crossings. Two protected placements pass 880 native calls. Two valid terminal-label records add four calls, and ten invalid shapes reject before payload access. The complete original-input replay adds 6,400 calls. All 7,284 immediate ABI checks pass, with six complete source comparisons across 883,077,888 bytes.

The single isolated native forecast exits zero. Its 6,400 complete same-input source/native pairs pass 255,795,200 bytes. A further protected replay of every fresh incoming record passes all 6,400 calls and 206,438,400 independent relations, with three complete direct stream pairs. All ten saved files directly match both the original source case and the canonical forecast across 618,140 bytes.

The fresh and original captures contain 1,560,422,400 identical consumed input bytes. They retain 12,802 differing unused object bytes and 125,781,564 differing incoming output bytes. Of those output differences, 74,757,146 bytes are overwritten and 51,024,418 are retained. Every retained return equals its own incoming storage, while all 191,692,800 active physical output bytes agree. Complete cross-run input and return identity is therefore false. No bit is masked, rounded or normalised.

## Reproduction

The following direct recipe builds the unchanged primary and single protected verifier, checks critical and terminal cases, replays every original input, then compares the complete rebuilt object and libraries with the accepted first artifacts. Run it from the repository root in the own exclusive allocation. Use a new output folder for each later reproduction. Large inputs, original OpenIFS sources, libraries and logs stay in ignored `.runtime/`. No comparative timing is accepted.

```sh
srun --jobid=7207705 --overlap --exact -N1 -n1 -c17 --cpu-bind=map_cpu:16 --mem-bind=local bash -lc '
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
cd /lus/lfs1aip2/projects/u6yq/users/p3jitnath/esm.md
release="$PWD/.runtime/openifs/srtm_taumol17_7207705"
check="$release/public-reproduction-r1"
mkdir "$check"
cp bench/openifs/physics/srtm_taumol17.c "$check/critical.c"
cp bench/openifs/physics/srtm_taumol17_forecast.c "$check/forecast.c"
gcc -c -mcpu=neoverse-v2 src/openifs/physics/srtm_taumol17.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -fno-fast-math -ffp-contract=off -DSRTM17_ABI_OBSERVER "$check/critical.c" "$check/assembly.o" -o "$check/verify" -L .runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -Wl,--no-as-needed -l:libarpifs.DP.so -ldl -lm
"$check/verify" guarded "$release/preparation/critical-corpus-v1.bin" "$check/critical-source.bin" "$check/critical-native.bin" > "$check/critical.log" 2>&1
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-source.bin"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-native.bin"
"$check/verify" guarded "$release/preparation/terminal-column-label-corpus.bin" "$check/terminal-source.bin" "$check/terminal-native.bin" > "$check/terminal.log" 2>&1
cmp "$release/preparation/terminal-column-label-fortran.bin" "$check/terminal-source.bin"
cmp "$release/preparation/terminal-column-label-fortran.bin" "$check/terminal-native.bin"
"$check/verify" replay .runtime/openifs/runs/strict-srtm17-source-7207705/t21/test_fc/srtm17-inputs.bin "$check/replay-source.bin" "$check/replay-native.bin" > "$check/replay.log" 2>&1
cmp .runtime/openifs/runs/strict-srtm17-source-7207705/t21/test_fc/srtm17-fortran.bin "$check/replay-source.bin"
cmp .runtime/openifs/runs/strict-srtm17-source-7207705/t21/test_fc/srtm17-fortran.bin "$check/replay-native.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -fno-fast-math -ffp-contract=off "$check/forecast.c" "$check/assembly.o" -o "$check/libverify-srtm17.so" -ldl -lm
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -fno-fast-math -ffp-contract=off -DSRTM17_OMIT_INIT_RELAY "$check/forecast.c" "$check/assembly.o" -o "$check/libverify-srtm17-parent-omit-init.so" -ldl -lm
cmp "$release/native/assembly.o" "$check/assembly.o"
cmp "$release/native/libverify-srtm17.so" "$check/libverify-srtm17.so"
cmp "$release/native/libverify-srtm17-parent-omit-init.so" "$check/libverify-srtm17-parent-omit-init.so"
cat "$check/critical.log"
cat "$check/terminal.log"
cat "$check/replay.log"
'
```

The default forecast library forwards unchanged original `SRTM_INIT` and records its present zero flag. A combined forecast uses the `SRTM17_OMIT_INIT_RELAY` variant, leaving the accepted band29 observer as the sole original setup relay. Retain all prior numerical libraries and the pressure-math control in their original order, with `OMP_NUM_THREADS=1` and `OMP_DYNAMIC=FALSE`. Whole-forecast independent physics, all intermediate states and comparative timing remain separate work.
