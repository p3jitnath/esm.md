# Shortwave Band 20 Water And Methane Contract

Revision 1.0 freezes the original physical calculation, complete storage and ordered arithmetic before assembly generation. Band 20 covers wave numbers 5150 to 6150 cm$`^{-1}`$, or wavelengths about 1.63 to 1.94 micrometres. Absorption removes light from a beam, while Rayleigh scattering redirects light through interactions with molecules.

## Physics And Units

Let $`C_w`$, $`C_m`$ and $`C_a`$ be the scaled water, methane and total molecular columns. A molecular column counts molecules above one square centimetre. The original conversion is $`C=A N`$, where $`N`$ is in molecules/cm$`^2`$ and $`A=\mathrm{binary64}(\mathrm{binary32}(10^{-20}))`$. One scaled unit is approximately $`10^{20}`$ molecules/cm$`^2`$. Preserve $`A=9.9999996826552254\times10^{-21}`$.

A spectral point is one coefficient channel that represents part of this band. Ten points are active inside storage for sixteen. Absorption and Rayleigh coefficients use the inverse scaled-column unit. Solar flux uses W/m$`^2`$. Interpolation fractions, density factors and optical depths have no unit. Optical depth measures a layer's attenuation of a beam.

Let $`L`$ be the four-corner pressure and temperature absorption value. Let $`S`$ and $`F`$ be the self and foreign water continua, which describe additional broadening by water molecules and other air molecules. Let $`K_m`$ be the methane coefficient and $`R`$ the Rayleigh coefficient.

```math
\tau_g=\begin{cases}
C_w(L+S+F)+C_mK_m, & k\le T,\\
C_w(L+F)+C_mK_m, & k>T,
\end{cases}
\qquad \tau_r=C_aR.
```

Here $`k`$ is the one-based layer and $`T`$ is the column's tropopause index, which separates the lower and upper atmosphere. Solar selection starts at $`T`$. It changes to $`\min(k+1,T)`$ when the current pressure index is below the reference and the next reaches it. Each column owns its selection. Solar copies occur only in lower layers. Night columns, extra layers and unused points retain every incoming output bit.

## Original Coefficients And Gas Preparation

Original `SRTM_KGB20` reads both water tables from record 5 of `RADSRTM`. Its marker is at byte 540,192, its payload starts at byte 540,196, and the payload has 38,400 bytes. The lower and upper tables have 65 and 235 rows, respectively, with sixteen points each. Temperature varies fastest. `KAC` aliases `ABSA`, and `KBC` aliases `ABSB`.

The original source sets solar, methane, continuum and Rayleigh constants. `MODIFY_WV_CONTINUUM` multiplies the two water-continuum tables only when the optional setup value is one. The fresh source forecast directly records a present value of zero. Keep the full setup source and actual raw, converted and reduced arrays. Reduced coefficients sum rounded weighted products in source order with weight offset 64. Solar sums without those weights.

Methane enters gas preparation as a mass mixing ratio. The source multiplies it by $`28.970/16.043`$ and by the retained dry molecular column, then applies the original rounded scale. A scaled methane zero receives $`\mathrm{binary64}(\mathrm{binary32}(10^{-32}))N_d`$, where $`N_d`$ is the dry molecular column. Preserve water and total columns in the same original order.

The original moist-air correction is approximate. Keep its arithmetic and the independently measured error from gas preparation. Let $`q`$ be water mass divided by moist-air mass and $`w=q(28.970/18.0154)`$ in ideal real arithmetic. Against the full moist-air mixture, the continuum factor ratios are below.

```math
\frac{S_{\mathrm{factor,source}}}{S_{\mathrm{factor,mixture}}}
=1-\frac{q}{1+w},
\qquad
\frac{F_{\mathrm{factor,source}}}{F_{\mathrm{factor,mixture}}}
=1+\frac{qw}{(1-q)(1+w)}.
```

The self ratio applies for $`q>0`$. At zero humidity both self factors are zero, with continuous ratio limit one. The foreign ratio is one. For $`0\le q\le0.05`$, these factors can differ by 4.63 percent and 0.392 percent. Frozen forecast maxima are 2.4334 percent and 0.10167 percent. These composition-factor differences precede gas-column, literal-conversion and rounding effects. They do not establish exact moist-air mass conservation.

## Ordered Arithmetic

Use binary64, round to nearest with ties to even, gradual underflow and preserved zero signs. FPCR, the Arm floating-point control register, is zero before and after each call. Let $`\mathrm{RN}`$ mean one binary64 rounding. Forbid contraction, fused multiply-add, reassociation, approximate arithmetic, reduced precision and fast-math.

Input factors appear in order $`f_{00},f_{10},f_{01},f_{11}`$. Lower zero-based offsets are $`i_0=5(JP-1)+(JT-1)`$ and $`i_1=5JP+(JT1-1)`$. Upper offsets are $`i_0=5(JP-13)+(JT-1)`$ and $`i_1=5(JP-12)+(JT1-1)`$. Read the four coefficients at rows $`i_0,i_0+1,i_1,i_1+1`$.

```math
p_0=\mathrm{RN}(f_{00}a_0),\quad p_1=\mathrm{RN}(f_{10}a_1),\quad
p_2=\mathrm{RN}(f_{01}a_2),\quad p_3=\mathrm{RN}(f_{11}a_3),
\qquad L=\mathrm{RN}(\mathrm{RN}(\mathrm{RN}(p_0+p_1)+p_2)+p_3).
```

For a continuum, let $`d`$ be its density factor, $`x`$ its fraction and $`b_0,b_1`$ its adjacent coefficients. Preserve this rounded interpolation. Self and foreign tables have ten and four rows, respectively.

```math
B=\mathrm{RN}\left(d\,\mathrm{RN}\left(b_0+
\mathrm{RN}\left(x\,\mathrm{RN}(b_1-b_0)\right)\right)\right).
```

Lower absorption is $`\mathrm{RN}(\mathrm{RN}(C_w\,\mathrm{RN}(\mathrm{RN}(L+S)+F))+\mathrm{RN}(C_mK_m))`$. Upper absorption is $`\mathrm{RN}(\mathrm{RN}(C_w\,\mathrm{RN}(L+F))+\mathrm{RN}(C_mK_m))`$. Scattering is $`\mathrm{RN}(C_aR)`$. Fractions and factors can extrapolate. Require the four-factor sum to equal one within $`64\,2^{-52}`$ and independently check nonnegative physical depth.

Independent columns may finish their own layers because their solar selection and outputs do not interact. Preserve ordered operations within each layer and every source write. The complete primary supplies absorption, both continua, scattering and solar selection.

## Interface And Bounds

The application binary interface, ABI, defines arguments and preserved registers. Twenty-five ordinary pointers arrive, with the first eight in `x0` to `x7` and seventeen in incoming stack bytes zero through 128. Scalars and indices have four bytes, and reals have eight. Preserve the stack pointer, `x18`, callee-saved registers, the low halves of `v8` to `v15` and FPCR. Call no numerical helper.

Let $`n=KFDIA-KIDIA+1`$, $`H=KLEV`$ and $`V=YDDIMV\%NFLEVG`$. Columns vary fastest. Support $`0\le n\le4096`$, $`0\le H\le V\le512`$ and $`KIDIA\ge1`$. Empty shapes retain all output bytes.

| Argument positions, starting at zero | Names and complete storage |
|---|---|
| 0 to 3 | `YDDIMV` has 32 bytes, followed by integer scalars `KIDIA`, `KFDIA`, `KLEV`. |
| 4 to 7 | `FAC00`, `FAC01`, `FAC10`, `FAC11`, each $`nV`$ reals. |
| 8 to 10 | `JP`, `JT`, `JT1`, each $`nV`$ integers. |
| 11 to 13 | Water, methane and total columns, each $`nV`$ reals. |
| 14 | `LAYTROP`, with $`n`$ integers. |
| 15 to 17 | `SELFFAC`, `SELFFRAC`, `INDSELF`, each $`nV`$ values, with integer indices. |
| 18 to 20 | `FORFAC`, `FORFRAC`, `INDFOR`, each $`nV`$ values, with integer indices. |
| 21 to 23 | Solar has $`16n`$ reals, while gas and Rayleigh each have $`16nV`$. |
| 24 | Solar zenith cosine `PRMU0` has $`n`$ reals in $`[-1,1]`$. |

For daylight with nonzero layers, require $`1\le T\le H`$ and $`T<V`$. The latter proves every lower next-pressure read fits, without assuming Fortran `AND` short-circuits. Lower pressure indices are 1 to 12, upper indices 13 to 58, and temperature indices 1 to 4. Lower self indices are 1 to 9. Foreign indices are 1 to 3 in both regions. Prove every consumed daylight solar slot is defined.

Integers need four-byte alignment and reals need eight. Complete outputs are disjoint from each other, inputs and globals. Read-only inputs may overlap. Preserve all 40,572 global bytes, all 32 object bytes and every unused word, including NaNs. Selected factors and fractions are finite with magnitude at most $`2^{20}`$, nonnegative densities at most $`2^{20}`$, nonnegative columns at most $`2^{300}`$, and nonnegative coefficients at most $`2^{100}`$. These bounds prevent overflow. Physical acceptance also requires nonnegative finite returned depths.

## Source Checks And Output Bytes

Before generation, the complete source passes 40 critical records at two protected placements, with 80 calls, 914,432 returned bytes and 224,364 independent relations. The final set includes 11,500 nonzero subnormal returned values and 6,660 negative zeros, table corners, both continua, absorber limits, night storage, empty shapes and varied solar crossings. The earlier set remains archived.

The fresh original forecast has 6,400 calls on eight columns and nineteen layers. Complete source-only replay directly matches all 255,795,200 returned bytes. Optical checks cover 78,540,800 relations. Gas and continuum checks cover 10,496,000 more relations over 972,800 layer columns. All 3,171 coefficient relations pass, and ten saved files directly match the canonical 618,140 bytes. These source results precede assembly and timing.

Each input record starts with a 32-byte little-endian header for call, phase, site and shape. It stores the whole 32-byte object, globals, arguments 4 to 20, zenith cosines and three incoming output buffers. With $`C=nV`$, its size is $`40636+364C+140n`$ bytes. Output repeats the header, then complete solar, gas and Rayleigh storage.

Compare every complete return from the same full inputs, then replay every frozen actual input and directly compare saved files. Accept zero differing bytes. Trace cross-run unused-storage differences to their incoming bytes. Never mask, round for comparison or normalise values. Hashes identify artifacts.

## Isolated And Combined Initialization

The isolated observer relays unchanged original `SRTM_INIT` and records its optional flag. A parent build may define `SRTM20_OMIT_INIT_RELAY` when the accepted band-29 observer records the same unchanged setup with flag zero. Keep the isolated observer and record immutable. The parent still captures complete band-20 coefficients and inputs. This option changes no numerical setup or primary arithmetic.

Emit the complete primary directly as AArch64 text from this contract and original science. Numerical compiler assembly and intermediate representations are excluded from construction. Assemble and link it separately from controls and scientific checks. Timing requires a coordinated quiet exclusive-node block.

## Verified Direct Body

The unchanged first direct body has 273 instructions and a 320-byte frame. It passes eighty protected physics and immediate ABI calls, then all 6,400 complete frozen-input replays, with zero differing bytes. The isolated forecast also directly compares every complete paired returned state across 255,795,200 bytes and all ten saved files across 618,140 bytes. All source artifacts remain unchanged. No comparative timing is accepted.

Every mathematical input, full global and active incoming output bit is identical between source and fresh native captures. The full incoming archives retain 51,195,997 differing unused bytes, including 12,802 opaque object bytes. The 51,183,195 differing cross-run returned bytes exactly equal the corresponding preserved incoming gas and Rayleigh storage. Whole incoming arrays and returned states remain archived. Same-input whole returns and the full frozen-input replay compare directly, without normalising or omitting any bits.

## Reproduction

Run this block through srun on an assigned CPU in your own verified quiet exclusive allocation with local memory placement. The ignored release supplies immutable source inputs. The first build records the original setup option. The optional parent build omits only that record relay when the accepted band-29 observer already records unchanged original initialization with flag zero.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol20_7207705"
check="$release/reproduction"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -c src/openifs/physics/srtm_taumol20.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM20_ABI_OBSERVER .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol20.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/preparation/critical-corpus-v1.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm20-source-7207705/t21/test_fc/srtm20-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm20-source-7207705/t21/test_fc/srtm20-fortran.bin "$check/replay-fortran.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol20_forecast.c "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm20.so"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM20_OMIT_INIT_RELAY .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol20_forecast.c "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm20-parent.so"
```

Documentation revision 1.1 records the unchanged numerical revision 1.0 and first direct body. Root reproduction passes eighty protected calls and every original-input replay. The fresh primary, complete public verifier and both complete public observer libraries directly match. The selected forty-five-body combined forecast passes forty-three complete paired streams across 6,165,443,208 bytes and all ten saved files across 618,140 bytes. Every band20 mathematical input and full global also matches the original source capture, as do all 159,744,000 active physical output bytes. Differences in unused returned storage exactly equal its preserved incoming bytes and remain fully archived. The sole band29 relay records the unchanged original setup with a present flag of zero. No comparative timing is accepted.
