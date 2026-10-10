# Shortwave Band 16 Water And Methane Contract

Revision 1.0 freezes the complete original physical calculation, storage and ordered arithmetic before direct assembly generation. Band 16 covers wave numbers 2600 to 3250 cm$`^{-1}`$, or wavelengths about 3.08 to 3.85 micrometres. Absorption removes light from a beam. Rayleigh scattering redirects light through interactions with molecules. The old coefficient-reader header gives a different upper wave number and omits upper methane absorption. The complete active body and its module define the science used here.

## Physics And Units

Let $`C_w`$, $`C_m`$ and $`C_a`$ be scaled water, methane and total molecular columns. A molecular column counts molecules above one square centimetre. The original conversion is $`C=A N`$, with $`N`$ in molecules/cm$`^2`$ and $`A=\mathrm{binary64}(\mathrm{binary32}(10^{-20}))=9.9999996826552254\times10^{-21}`$. One scaled unit is approximately $`10^{20}`$ molecules/cm$`^2`$. Preserve this rounded scale.

A spectral point is a coefficient channel representing part of the band. Six points are active inside storage for sixteen. Absorption and scattering coefficients use the inverse scaled-column unit. Solar flux uses W/m$`^2`$. Optical depths, interpolation fractions, continuum density factors and the mixture weight $`r=252.131`$ have no unit. Optical depth measures a layer's attenuation of a beam.

Let $`k`$ be a one-based layer and $`T_j`$ the tropopause index for column $`j`$, separating the lower and upper atmosphere. The lower absorption table uses a mixed column $`C_x=C_w+rC_m`$. Its mixture coordinate is $`p=\min(C_w/C_x,c_j)`$, where $`c_j`$ is a positive cap below one. The forecast supplies $`c_j=\mathrm{RN}(1-10^{-6})`$. Here $`\mathrm{RN}`$ means one binary64 rounding.

Let $`L_a`$ be the lower absorption coefficient after interpolation across pressure, temperature and mixture. Let $`L_b`$ be the upper pressure and temperature coefficient. Let $`S`$ and $`F`$ be the self and foreign water continua, which represent additional broadening by water molecules and other air molecules. Let $`R`$ be the Rayleigh coefficient.

```math
\tau_g=\begin{cases}
C_xL_a+C_w(S+F), & k\le T_j,\\
C_mL_b, & k>T_j,
\end{cases}
\qquad \tau_r=C_aR.
```

The upper region uses methane absorption and omits both water continua. The lower mixed column must be positive. A zero water column with positive methane is supported. A lower column with both absorbers zero makes the original division undefined and is outside this contract. Zero upper methane gives zero absorption. Zero total molecules gives zero scattering.

## Original Coefficients And Connected Gas Preparation

Original `SRTM_KGB16` reads record 1 of `RADSRTM`. Its first marker is at byte zero, its payload starts at byte four and has 104,960 bytes. The lower raw table has shape $`(9,5,13,16)`$ and occupies 74,880 bytes. The upper table has shape $`(5,47,16)`$ and occupies 30,080 bytes. The mixture index varies fastest in the lower table. Temperature varies fastest in the upper table. `KAC` aliases `ABSA(585,16)`, and `KBC` aliases `ABSB(235,16)`.

Original reduction uses the first six spectral groups and `RWGT` with offset zero. Each weighted coefficient product and each sum retains its source rounding and order. Solar sums without those weights. The original Rayleigh coefficient is $`2.91\times10^{-10}`$ in the inverse scaled-column unit. Keep all raw, converted and reduced coefficient bytes, including unused channels.

`MODIFY_WV_CONTINUUM` can multiply the two water-continuum tables when the optional initialization value is one. The fresh source forecast records the unchanged original setup with a present value of zero. Direct raw-array, literal-array, alias and reduced-array comparisons pass, with 5,011 additional high-precision relations. Preserve the actual optional value rather than assume a default.

Methane enters gas preparation as a mass mixing ratio. The source multiplies it by $`28.970/16.043`$ and the retained dry molecular column, then applies the original rounded scale. A scaled methane zero receives $`\mathrm{binary64}(\mathrm{binary32}(10^{-32}))N_d`$, where $`N_d`$ is the retained dry molecular column. Preserve the water, methane and total columns, continuum density inputs and rounded mixture cap in their original order.

The legacy moist-air correction is approximate. Let $`q`$ be water mass divided by moist-air mass, $`M_d=28.970`$ g/mol, $`M_w=18.0154`$ g/mol, $`w=qM_d/M_w`$ and $`a=M_d/M_w-1`$. Against a full moist-air mixture, the ideal-real continuum-factor ratios and total-column ratio are below.

```math
\frac{S_{\mathrm{factor,source}}}{S_{\mathrm{factor,mixture}}}
=1-\frac{q}{1+w},
\qquad
\frac{F_{\mathrm{factor,source}}}{F_{\mathrm{factor,mixture}}}
=1+\frac{qw}{(1-q)(1+w)},
\qquad
\frac{C_{a,\mathrm{source}}}{C_{a,\mathrm{mixture}}}
=\frac{A/10^{-20}}{1-a^2q^2}.
```

The self ratio applies when $`q>0`$. At zero humidity both self factors are zero, with continuous ratio limit one. The foreign ratio is one. For $`0\le q\le0.05`$, self and foreign composition factors can differ by 4.63 percent and 0.392 percent. Actual forecast maxima are 2.4334 percent and 0.10167 percent. These factor differences precede gas-column, default-real literal and rounding effects. The actual ideal-real total-column and Rayleigh bias is at most about 0.023716 percent. Preserve the rounded original sequence and its separate mass-balance checks. These approximations do not establish exact moist-air mass conservation.

## Ordered Mixture And Table Arithmetic

Use binary64, round to nearest with ties to even, gradual underflow and preserved zero signs. The Arm floating-point control register, FPCR, is zero before and after each call. Forbid contraction, fused multiply-add, reassociation, approximate arithmetic, reduced precision and fast-math.

The lower mixture preparation has the exact rounded sequence below.

```math
m=\mathrm{RN}(rC_m),\qquad
C_x=\mathrm{RN}(C_w+m),\qquad
p=\mathrm{RN}(C_w/C_x).
```

Replace $`p`$ with the incoming cap when $`p\ge c_j`$. Then form $`u=\mathrm{RN}(8p)`$, $`b=\operatorname{INT}(u)`$, $`J_s=b+1`$, $`f=\operatorname{MOD}(u,1)`$ and $`v=\mathrm{RN}(1-f)`$. `INT` truncates towards zero. `MOD` keeps the numerator's zero sign. Require $`0\le u<8`$ and $`0\le b\le7`$.

In this domain, $`f=u-\mathrm{binary64}(b)`$ is exact. For $`b\ge1`$, the two nonzero operands differ by less than a factor of two, so their subtraction is exactly representable. For zero, subtraction preserves the required sign, including negative zero. Source-only checks independently compare this subtraction with `fmod` bit for bit on every critical and actual lower-layer input. This domain proof permits `fcvtzs`, `scvtf` and `fsub` in the complete primary, without a numerical helper.

Input factors appear in source order $`f_{00},f_{10},f_{01},f_{11}`$. Define lower zero-based table rows $`i_0=9(5(JP-1)+JT-1)+(J_s-1)`$ and $`i_1=9(5JP+JT1-1)+(J_s-1)`$. The first pressure and temperature bracket reads rows $`i_0,i_0+9,i_1,i_1+9`$. The next mixture bracket reads each of these rows plus one.

For $`h=0,1`$, multiply the coefficient by its factor in the original order, then add from left to right.

```math
p_{0,h}=\mathrm{RN}(A_{i_0+h}f_{00}),\qquad
p_{1,h}=\mathrm{RN}(A_{i_0+9+h}f_{10}),\qquad
p_{2,h}=\mathrm{RN}(A_{i_1+h}f_{01}),\qquad
p_{3,h}=\mathrm{RN}(A_{i_1+9+h}f_{11}),
\qquad
B_h=\mathrm{RN}\!\left(\mathrm{RN}\!\left(\mathrm{RN}(p_{0,h}+p_{1,h})+p_{2,h}\right)+p_{3,h}\right).
```

```math
L_a=\mathrm{RN}\!\left(\mathrm{RN}(vB_0)+\mathrm{RN}(fB_1)\right),
\qquad
D_a=\mathrm{RN}(C_xL_a).
```

For a continuum, let $`d`$ be its density factor, $`x`$ its fraction and $`b_0,b_1`$ its adjacent coefficients. Self and foreign tables have ten and three rows, respectively. Preserve every rounding below.

```math
Q=\mathrm{RN}\!\left(d\,\mathrm{RN}\!\left(b_0+
\mathrm{RN}\!\left(x\,\mathrm{RN}(b_1-b_0)\right)\right)\right),
\qquad
\tau_g=\mathrm{RN}\!\left(D_a+\mathrm{RN}\!\left(C_w\,\mathrm{RN}(S+F)\right)\right).
```

Keep the two four-product sums, their mixture blend, the mixed-column multiplication and the separate water-continuum multiplication. These operations must retain their order.

Upper rows are $`i_0=5(JP-13)+JT-1`$ and $`i_1=5(JP-12)+JT1-1`$. Read $`i_0,i_0+1,i_1,i_1+1`$. Each upper product uses its factor first. Form the same three left-to-right rounded additions, then $`\tau_g=\mathrm{RN}(C_mL_b)`$. In both regions, scattering is $`\tau_r=\mathrm{RN}(C_aR)`$.

Fractions and pressure-temperature factors can extrapolate outside zero to one. Require the four-factor sum to equal one within $`64\,2^{-52}`$, then independently verify finite nonnegative physical depths. The independent lower reference expands eight interpolation weights and checks the ideal mixture, rather than repeating the two rounded source brackets.

## Shared Solar Selection And Write Order

Run the lower pass in increasing layer, then increasing column order. It writes gas and then Rayleigh depth for each of six points. Run the upper pass in the same layer and column order. A single solar-selection integer starts at $`H`$ before the whole upper pass. It is shared across columns.

In an active upper layer, the source compares the previous pressure index with reference index 18 and the current pressure index with the same reference. A crossing replaces the shared selection with the current one-based layer. At the selected layer, copy all six fixed solar coefficients. The upper source writes gas, then solar when selected, then Rayleigh depth.

Keep this shared state and traversal. Every daylight upper layer must have a previous layer. A full forecast caller must also prove that every consumed daylight solar slot is written. A standalone critical case can deliberately make no solar write and must preserve its complete incoming solar storage. Night columns, extra layers and unused channels retain every incoming output bit.

## Interface, Storage And Bounds

The application binary interface, ABI, defines function arguments and preserved registers. Twenty-six ordinary pointers arrive, with the first eight in `x0` to `x7` and eighteen in incoming stack bytes zero through 136. Integer scalars and indices occupy four bytes. Reals occupy eight. Preserve the stack pointer, `x18`, callee-saved registers, the low halves of `v8` to `v15` and FPCR. Call no numerical helper.

Let $`n=KFDIA-KIDIA+1`$, $`H=KLEV`$, $`V=YDDIMV\%NFLEVG`$ and $`C=nV`$. Columns vary fastest in each array. Support $`0\le n\le4096`$, $`0\le H\le V\le512`$ and $`KIDIA\ge1`$. Empty shapes preserve every returned byte.

| Argument positions, starting at zero | Names and complete storage |
|---|---|
| 0 to 3 | `YDDIMV` has 32 bytes, followed by integer scalars `KIDIA`, `KFDIA`, `KLEV`. |
| 4 to 7 | `FAC00`, `FAC01`, `FAC10`, `FAC11`, each $`C`$ reals. |
| 8 to 10 | `JP`, `JT`, `JT1`, each $`C`$ integers. |
| 11 | `ONEMINUS`, with $`n`$ real mixture caps. |
| 12 to 14 | Water, methane and total molecular columns, each $`C`$ reals. |
| 15 | `LAYTROP`, with $`n`$ integers. |
| 16 to 18 | `SELFFAC`, `SELFFRAC`, `INDSELF`, each $`C`$ values, with integer indices. |
| 19 to 21 | `FORFAC`, `FORFRAC`, `INDFOR`, each $`C`$ values, with integer indices. |
| 22 to 24 | Solar has $`16n`$ reals. Gas and Rayleigh each have $`16C`$ reals. |
| 25 | Solar zenith cosine `PRMU0` has $`n`$ reals in $`[-1,1]`$. |

For daylight with nonzero layers, require $`1\le T_j\le H`$. This proves each upper previous-pressure read fits, without assuming Fortran `AND` short-circuits. Lower pressure indices are 1 to 12, upper indices 13 to 58, and temperature indices 1 to 4. Lower self indices are 1 to 9. Lower foreign indices are 1 to 2. These bounds cover both adjacent coefficients, including the lower table's ninth mixture corner. Upper self and foreign fields are unused and retain arbitrary incoming bits.

Keep every byte of all ten globals, with total size 106,884 bytes. The lower and upper absorption aliases occupy 74,880 and 30,080 bytes. Self and foreign coefficients occupy 1,280 and 384 bytes. Solar uses 128 bytes, Rayleigh eight, reference index four, mixture weight eight, and each complete species array fifty-six.

Integers need four-byte alignment and reals eight. The complete derived object needs four-byte alignment. Outputs are disjoint from one another, all read-only inputs and all globals. Read-only inputs may overlap. Preserve complete inactive storage, including NaN payloads.

Selected factors and fractions are finite with magnitude at most $`2^{20}`$. Density factors are nonnegative and at most $`2^{20}`$. Molecular columns are nonnegative and at most $`2^{300}`$. Absorption and scattering coefficients are nonnegative and at most $`2^{100}`$. The positive mixture weight is at most $`2^{16}`$. The reference index lies from 13 to 59. These bounds prevent overflow. The lower mixture denominator must remain positive and finite after its original rounded operations.

## Source Acceptance And Complete Output Bytes

Before generation, the unchanged source passes 148 critical records at two protected placements, with 296 calls, 3,652,352 complete returned bytes and 870,860 independent relations. The final set includes unequal adjacent coefficients, all eight mixture intervals, exact and nearby interval boundaries, cap limits, pure-absorber limits, shared multi-column solar crossings, table corners, extrapolation, signed zeros, 7,992 nonzero subnormal outputs, unused fields with preserved nonfinite bits, night storage, extra layers and empty shapes. Both original corpus revisions remain archived.

The fresh original forecast has 6,400 calls on eight columns and nineteen layers. Complete source-only replay directly matches all 255,795,200 returned bytes. Physical checks cover 67,891,200 relations. Independent connected gas, continuum and cap checks cover 10,547,200 relations across 972,800 layer columns. All 5,011 coefficient relations pass. Every one of ten saved files directly matches the canonical total of 618,140 bytes.

Independent mixture checks cover 3,825 critical lower layers, including 575 cap replacements and 182 negative-zero fractions. They also cover all 768,000 actual lower layers. All eight intervals are visited in both sets. Original `INT` and `MOD` results match the proved conversion and subtraction bits. These results precede assembly and timing.

Each input record starts with a 32-byte little-endian header for call, phase, site and shape. It then stores the whole 32-byte object, complete globals, arguments 4 to 21 in interface order, zenith cosines and all three incoming output buffers. Its complete size is $`106948+364C+148n`$ bytes. Output repeats the header, then full solar, gas and Rayleigh storage, with size $`32+128n+256C`$.

Compare every complete source and assembly return from the same complete inputs. Replay every frozen actual input, including unused incoming storage, and compare all returned bytes with the frozen source. A fresh forecast must also directly compare all saved files. Trace any cross-run unused differences to their complete incoming bytes. Accept zero differing bytes without masking, rounding for comparison or normalising values. Hashes identify immutable artifacts.

## Initialization And Generation

The isolated observer relays unchanged original `SRTM_INIT` and records the optional flag. A parent build may define `SRTM16_OMIT_INIT_RELAY` when the accepted band-29 observer supplies the same unchanged setup with flag zero. Preserve isolated setup evidence. The parent still captures all band-16 globals, inputs and returns. This option changes no numerical initialization or primary arithmetic.

Emit the complete primary directly as AArch64 text from this frozen contract and original science. Do not use numerical compiler assembly or intermediate representations for construction. Assemble and link separately from language controls and independent scientific checks. Timing requires a coordinated quiet exclusive-node block.

## Direct Body Acceptance

The unchanged first body has 296 instructions, a 352-byte stack frame and twenty-six ordinary pointers. It contains the complete lower mixed water and methane interpolation, water continua, upper methane interpolation, shared solar selection and Rayleigh scattering. It uses ordinary binary64 operations, with no numerical helper, fused multiply-add or reduced precision.

The direct body passes all 148 critical input records at two protected placements, with 296 checked calls, 3,652,352 complete output bytes and 870,860 independent relations. All 6,400 complete original-input replays pass 255,795,200 returned bytes and 67,891,200 relations. Every preserved register and the floating-point control register passes. The fresh isolated forecast directly matches every same-input source and assembly return, then all ten saved files across 618,140 bytes.

The fresh run retains 204,374,546 differing incoming bytes. Of these, 12,802 belong to unused object fields and the remainder belongs to incoming output storage. Every complete read-only mathematical array and global matches the source run. Cross-run returns differ in 129,888,939 unused gas and Rayleigh bytes, and each such byte equals its own preserved incoming byte. All raw storage remains archived. Complete paired comparisons and frozen replay provide acceptance, without masking or changing any bits.

Both independent original-science and first-body reviews pass. The legacy moist-air approximation and default-real scale remain unchanged, with their separate physical error bounds stated above. No comparative timing is accepted.

The reviewed combined forecast adds this body to forty-five previously accepted bodies. All forty-four complete same-input stream pairs pass 6,421,238,408 bytes, and all ten saved files pass 618,140 bytes, with zero differences. Band 16 also matches 790,374,400 original read-only mathematical input, global and header bytes and 95,846,400 active physical output bytes. Complete fresh inputs differ by 217,209,091 bytes, including opaque object storage and unused incoming output slots. Their returned unused differences exactly preserve their incoming bits. Full fresh input and full fresh return identity are therefore not claimed. Every raw bit remains in the archives. A separate root run of this public recipe passes all 296 protected and 6,400 frozen calls, with whole primary object, verifier and both libraries directly identical.

## Reproduction

Run this block through srun on an assigned CPU in your own verified quiet exclusive allocation with local memory placement. The ignored release supplies immutable inputs. Copying the two public C files into the ignored check folder keeps the original compiler file names, so complete executable and library bytes can also be compared. These copies contain only forwarding and verification code.

The isolated library records unchanged original initialization. Use the optional parent library only when the accepted band-29 observer already records the same present setup flag of zero. This removes a duplicate observation relay and changes no numerical setup.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol16_7207705"
check="$release/public-reproduction"
mkdir -p "$check"
cp bench/openifs/physics/srtm_taumol16.c "$check/critical-source.c"
cp bench/openifs/physics/srtm_taumol16_forecast.c "$check/forecast.c"
gcc -fPIC -march=armv8-a+simd -c src/openifs/physics/srtm_taumol16.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror -Wno-misleading-indentation -Wno-parentheses -DSRTM16_ABI_OBSERVER "$check/critical-source.c" "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/preparation/critical-corpus-v1.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm16-source-7207705/t21/test_fc/srtm16-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm16-source-7207705/t21/test_fc/srtm16-fortran.bin "$check/replay-fortran.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math "$check/forecast.c" "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm16.so"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM16_OMIT_INIT_RELAY "$check/forecast.c" "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm16-parent.so"
cmp "$release/native/assembly.o" "$check/assembly.o"
cmp "$release/native/critical" "$check/critical"
cmp "$release/native/libverify-srtm16.so" "$check/libverify-srtm16.so"
cmp "$release/native/libverify-srtm16-parent.so" "$check/libverify-srtm16-parent.so"
```
