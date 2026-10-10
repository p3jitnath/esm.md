# Shortwave Band 19 Water And Carbon Dioxide Contract

Documentation revision 1.1 preserves numerical revision 1.0, which freezes the complete original physical calculation, storage and ordered arithmetic before direct assembly generation. Band 19 covers wave numbers 4650 to 5150 cm$`^{-1}`$, or wavelengths about 1.94 to 2.15 micrometres. Absorption removes light from a beam. Rayleigh scattering redirects light through interactions with molecules. The old coefficient-reader header names band 16. The complete active body and its module identify the band-19 calculation used here.

## Physics And Units

Let $`C_w`$, $`C_m`$ and $`C_a`$ be scaled water, carbon dioxide and total molecular columns. A molecular column counts molecules above one square centimetre. The original conversion is $`C=A N`$, with $`N`$ in molecules/cm$`^2`$ and $`A=\mathrm{binary64}(\mathrm{binary32}(10^{-20}))=9.9999996826552254\times10^{-21}`$. One scaled unit is approximately $`10^{20}`$ molecules/cm$`^2`$. Preserve this rounded scale. Binary32 and binary64 store a real number in thirty-two and sixty-four bits, respectively.

A spectral point is a coefficient channel representing part of the band. Eight points are active inside storage for sixteen. Absorption and scattering coefficients use the inverse scaled-column unit. Solar flux uses W/m$`^2`$. Optical depths, interpolation fractions, continuum density factors and the mixture weight $`r=5.49281`$ have no unit. Optical depth measures a layer's attenuation of a beam.

Let $`k`$ be a one-based layer and $`T_j`$ the tropopause index for column $`j`$, separating the lower and upper atmosphere. The lower absorption table uses a mixed column $`C_x=C_w+rC_m`$. Its mixture coordinate is $`p=\min(C_w/C_x,c_j)`$, where $`c_j`$ is a positive cap below one. The forecast supplies $`c_j=\mathrm{RN}(1-10^{-6})`$. Here $`\mathrm{RN}`$ means one binary64 rounding.

Let $`L_a`$ be the lower absorption coefficient after interpolation across pressure, temperature and mixture. Let $`L_b`$ be the upper pressure and temperature coefficient. Let $`S`$ and $`F`$ be the self and foreign water continua, which represent additional broadening by water molecules and other air molecules. Let $`R`$ be the Rayleigh coefficient.

```math
\tau_g=\begin{cases}
C_xL_a+C_w(S+F), & k\le T_j,\\
C_mL_b, & k>T_j,
\end{cases}
\qquad \tau_r=C_aR.
```

The upper region uses carbon dioxide absorption and omits both water continua. The original rounded lower mixed column must be finite and at least the smallest positive normal binary64 value, about $`2.225\times10^{-308}`$. A zero water column with positive carbon dioxide is supported. A lower column with both absorbers zero makes the original division undefined and is outside this contract. Zero upper carbon dioxide gives zero absorption. Zero total molecules gives zero scattering.

## Original Coefficients And Connected Gas Preparation

Original `SRTM_KGB19` reads record 4 of `RADSRTM`. Its marker is at byte 435,224, its payload starts at byte 435,228 and has 104,960 bytes. The lower raw table has shape $`(9,5,13,16)`$ and occupies 74,880 bytes. The upper table has shape $`(5,47,16)`$ and occupies 30,080 bytes. The mixture index varies fastest in the lower table. Temperature varies fastest in the upper table. `KAC` aliases `ABSA(585,16)`, and `KBC` aliases `ABSB(235,16)`.

Original reduction uses the eight band-19 spectral groups and `RWGT` with offset 48. Each weighted coefficient product and each sum retains its source rounding and order. Each of the nine solar-mixture columns sums without those weights. The original Rayleigh coefficient is $`2.29\times10^{-9}`$ in the inverse scaled-column unit. Keep all raw, converted and reduced coefficient bytes, including unused channels.

`MODIFY_WV_CONTINUUM` can multiply the two water-continuum tables when the optional initialization value is one. The fresh source forecast records the unchanged original setup with a present value of zero. Direct raw-array, literal-array, alias and reduced-array comparisons pass, with 6,745 additional high-precision relations. Preserve the actual optional value rather than assume a default.

Carbon dioxide enters gas preparation as a mass mixing ratio. The source multiplies it by $`28.970/44.011`$ and the retained dry molecular column, then applies the original rounded scale. A scaled carbon dioxide zero receives $`\mathrm{binary64}(\mathrm{binary32}(10^{-32}))N_d`$, where $`N_d`$ is the retained dry molecular column. Preserve the water, carbon dioxide and total columns, continuum density inputs and rounded mixture cap in their original order.

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

## Column-Local Solar Selection And Write Order

Run the lower pass in increasing layer, then increasing column order. Each column has its own solar-selection integer, initially equal to its tropopause index. Reference pressure index three selects the source solar spectrum. When the current pressure index is below the reference and the next is at or above it, set that column's selection to the smaller of the next layer and its tropopause.

At the selected lower layer, use the same bounded mixture index and fraction as the gas calculation. Let $`U_{g,b}`$ and $`U_{g,b+1}`$ be adjacent solar columns at spectral point $`g`$. The source retains the three rounded operations below.

```math
\Delta=\mathrm{RN}(U_{g,b+1}-U_{g,b}),\qquad
E=\mathrm{RN}(f\Delta),\qquad
F_{g,\mathrm{solar}}=\mathrm{RN}(U_{g,b}+E).
```

The lower source writes gas, solar when selected, then Rayleigh depth at each of eight points. A later crossing can select another write, so the final solar output comes from the last selected write. The independent check uses a high-precision linear blend across the nine columns and separately proves that every solar slot consumed by the forecast is defined.

Run the upper pass in the same layer and column order. It writes gas, then Rayleigh depth, and changes no solar state. Keep the complete incoming bytes for night columns, extra layers, unused channels and any standalone case with no selected solar write. Column-local state must remain independent when tropopause indices and pressure crossings differ.

## Interface, Storage And Bounds

The application binary interface, ABI, defines function arguments and preserved registers. Twenty-six ordinary pointers arrive, with the first eight in `x0` to `x7` and eighteen in incoming stack bytes zero through 136. Integer scalars and indices occupy four bytes. Reals occupy eight. Preserve the stack pointer, `x18`, callee-saved registers, the low halves of `v8` to `v15` and FPCR. Call no numerical helper. The primary uses 352 fixed stack bytes and $`16\lceil4n/16\rceil`$ additional bytes for the column-local solar indices, where $`n`$ counts atmospheric columns. The extra storage contains only four-byte integers, is aligned to sixteen bytes and lives only during the call. For 4096 columns the complete frame is 16,736 bytes. Empty shapes return before this extra allocation.

Let $`n=KFDIA-KIDIA+1`$, $`H=KLEV`$, $`V=YDDIMV\%NFLEVG`$ and $`C=nV`$. Columns vary fastest in each array. Support $`0\le n\le4096`$, $`0\le H\le V\le512`$ and $`KIDIA\ge1`$. Also require $`KFDIA\le2^{31}-2`$, so the original four-byte Fortran loop index can advance once after its last column. The verifier uses an eight-byte integer to calculate the column count before accepting the labels. Empty shapes preserve every returned byte.

| Argument positions, starting at zero | Names and complete storage |
|---|---|
| 0 to 3 | `YDDIMV` has 32 bytes, followed by integer scalars `KIDIA`, `KFDIA`, `KLEV`. |
| 4 to 7 | `FAC00`, `FAC01`, `FAC10`, `FAC11`, each $`C`$ reals. |
| 8 to 10 | `JP`, `JT`, `JT1`, each $`C`$ integers. |
| 11 | `ONEMINUS`, with $`n`$ real mixture caps. |
| 12 to 14 | Water, carbon dioxide and total molecular columns, each $`C`$ reals. |
| 15 | `LAYTROP`, with $`n`$ integers. |
| 16 to 18 | `SELFFAC`, `SELFFRAC`, `INDSELF`, each $`C`$ values, with integer indices. |
| 19 to 21 | `FORFAC`, `FORFRAC`, `INDFOR`, each $`C`$ values, with integer indices. |
| 22 to 24 | Solar has $`16n`$ reals. Gas and Rayleigh each have $`16C`$ reals. |
| 25 | Solar zenith cosine `PRMU0` has $`n`$ reals in $`[-1,1]`$. |

For daylight with nonzero layers, require $`1\le T_j\le H`$. Also require $`T_j<V`$. This proves every lower next-pressure read fits, without assuming Fortran `AND` short-circuits. For zero layers the tropopause is zero. Lower pressure indices are 1 to 12, upper indices 13 to 58, and temperature indices 1 to 4. Lower self indices are 1 to 9. Lower foreign indices are 1 to 2. These bounds cover both adjacent coefficients, including the lower table's ninth mixture corner. Upper self and foreign fields are unused and retain arbitrary incoming bits.

Keep every byte of all ten globals, with total size 107,908 bytes. The lower and upper absorption aliases occupy 74,880 and 30,080 bytes. Self and foreign coefficients occupy 1,280 and 384 bytes. Solar uses 1,152 bytes for sixteen points and nine mixture columns, Rayleigh eight, reference index four, mixture weight eight, and each complete species array fifty-six.

Integers need four-byte alignment and reals eight. The complete derived object needs four-byte alignment. Outputs are disjoint from one another, all read-only inputs and all globals. Read-only inputs may overlap. Preserve complete inactive storage, including NaN payloads.

Selected factors and fractions are finite with magnitude at most $`2^{20}`$. Density factors are nonnegative and at most $`2^{20}`$. Molecular columns are nonnegative and at most $`2^{300}`$. Absorption and scattering coefficients are nonnegative and at most $`2^{100}`$. The positive mixture weight is at most $`2^{16}`$. The reference index lies from 1 to 13. These bounds prevent overflow. The lower mixture denominator must remain finite and at least the smallest positive normal binary64 value after its original rounded operations.

## Source Acceptance And Complete Output Bytes

Before generation, the unchanged source passes 148 critical records at two protected placements, with 296 calls, 3,652,352 complete returned bytes and 1,040,144 independent relations. The final set includes unequal adjacent coefficients, all eight mixture intervals, exact and nearby interval boundaries, cap limits, pure-absorber limits, independent multi-column solar crossings, table corners, extrapolation, signed zeros, 10,656 nonzero subnormal outputs, unused fields with preserved nonfinite bits, night storage, extra layers and empty shapes. The complete source corpus and all incoming output bytes remain archived.

The fresh original forecast has 6,400 calls on eight columns and nineteen layers. Complete source-only replay directly matches all 255,795,200 returned bytes. Physical checks cover 80,691,200 relations. Independent connected gas, continuum and cap checks cover 10,547,200 relations across 972,800 layer columns. All 6,745 coefficient relations pass. Every one of ten saved files directly matches the canonical total of 618,140 bytes.

Independent mixture checks cover 3,825 critical lower layers, including 575 cap replacements and 182 negative-zero fractions. They also cover all 768,000 actual lower layers. All eight intervals are visited in both sets. Original `INT` and `MOD` results match the proved conversion and subtraction bits. These results precede assembly and timing.

Each input record starts with a 32-byte little-endian header for call, phase, site and shape. It then stores the whole 32-byte object, complete globals, arguments 4 to 21 in interface order, zenith cosines and all three incoming output buffers. Its complete size is $`107972+364C+148n`$ bytes. Output repeats the header, then full solar, gas and Rayleigh storage, with size $`32+128n+256C`$.

Compare every complete source and assembly return from the same complete inputs. Replay every frozen actual input, including unused incoming storage, and compare all returned bytes with the frozen source. A fresh forecast must also directly compare all saved files. Trace any cross-run unused differences to their complete incoming bytes. Accept zero differing bytes without masking, rounding for comparison or normalising values. Hashes identify immutable artifacts.

## Initialization And Generation

The isolated observer relays unchanged original `SRTM_INIT` and records the optional flag. A parent build may define `SRTM19_OMIT_INIT_RELAY` when the accepted band-29 observer supplies the same unchanged setup with flag zero. Preserve isolated setup evidence. The parent still captures all band-19 globals, inputs and returns. This option changes no numerical initialization or primary arithmetic.

Emit the complete primary directly as AArch64 text from this frozen contract and original science. Do not use numerical compiler assembly or intermediate representations for construction. Assemble and link separately from language controls and independent scientific checks. Timing requires a coordinated quiet exclusive-node block.

## Verified Direct Body

The first complete direct body has 321 instructions and 1,284 code bytes. It keeps each column's lower solar state in its declared local stack storage. All 296 protected critical calls and all 6,400 frozen actual calls pass the immediate register, stack and floating-point checks. Every complete returned byte equals the original source return. The independent first-body review finds no source, physical or ABI blocker.

Root independently repeats the current public recipe after refining its input-label guard. All 6,696 original ABI checks pass. Three extreme invalid headers reject before reading a payload. Two complete original records at the maximum valid column labels pass four protected ABI checks across 4,992 returned bytes. The first assembly and every original corpus byte remain unchanged.

The isolated native forecast passes every complete source and assembly pair, all 255,795,200 returned bytes and all ten saved files. All 96,256,000 actually read numerical input bytes and every complete global match the original pre-emission capture. A fresh run has 51,397,259 different unused returned bytes. Each of these equals that run's complete incoming byte. They belong to storage that the original caller does not consume for this band. Complete raw captures remain unchanged, and the comparison accepts no masked, rounded or normalised bits.

The combined forecast preserves all 36 earlier verification libraries and adds the current public parent comparator. Its 46 complete paired streams pass across 6,748,998,408 bytes, and all ten saved files pass across 618,140 bytes. For band 19, all actually read numerical inputs, complete globals and active outputs agree with the original source archive. Its independent incoming storage retains 54,610,831 different unused returned bytes, each equal to its own incoming byte. The sole original setup relay belongs to band 29 and records the same present flag zero.

No comparative timing is accepted for this body. Use a coordinated quiet exclusive allocation before measuring performance.

## Reproduce The Accepted Checks

Use the preserved source release and a verified exclusive allocation. The authoring job was 7207705 on nid011311. Enter an allocated shell from the project root with the command below, replacing the job number when needed. Build and run the following recipe inside that shell.

```sh
srun --jobid=7207705 --overlap --exact -N1 -n1 -c17 --cpu-bind=map_cpu:16 --mem-bind=local bash
```

Choose a new output folder for each run. The recipe stops if that folder already exists. It copies the public C files to fixed compiler input basenames. This keeps the full executable and library bytes reproducible. The parent library omits only the original initialization relay and requires the accepted band-29 relay with present flag zero.

```sh
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol19_7207705"
check="$release/new-public-reproduction"
mkdir "$check"
cp bench/openifs/physics/srtm_taumol19.c "$check/critical-source.c"
cp bench/openifs/physics/srtm_taumol19_forecast.c "$check/forecast.c"
gcc -fPIC -march=armv8-a+simd -c src/openifs/physics/srtm_taumol19.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror -Wno-misleading-indentation -Wno-parentheses -DSRTM19_ABI_OBSERVER "$check/critical-source.c" "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/preparation/critical-corpus-v1.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-v1.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm19-source-7207705/t21/test_fc/srtm19-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm19-source-7207705/t21/test_fc/srtm19-fortran.bin "$check/replay-fortran.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math "$check/forecast.c" "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm19.so"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM19_OMIT_INIT_RELAY "$check/forecast.c" "$check/assembly.o" -lm -ldl -o "$check/libverify-srtm19-parent.so"
cmp "$release/native/assembly.o" "$check/assembly.o"
```
