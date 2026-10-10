# OpenIFS Shortwave Water Absorption and Continua

Numerical revision 1.0 freezes the complete SRTM_TAUMOL23 body before direct assembly generation. The routine describes water absorption and molecular scattering in part of the Sun's radiation, from 8,050 to 12,850 cm$`^{-1}`$, or wavelengths of about 0.778 to 1.242 micrometres. Absorption removes energy from a light ray, while scattering changes its direction. The unchanged original source and full caller remain the reference. The [OpenIFS rules](../../../../../bench/openifs/README.md) apply.

## Physics and Units

Let $`C_{\rm w}`$ and $`C_{\rm m}`$ be the water and total molecular columns in units of $`10^{20}`$ molecules cm$`^{-2}`$. A column counts molecules along a ray through a layer. A spectral point $`g`$ represents a part of the radiation band. Its water line coefficient $`k_{i,g}`$, self coefficient $`s_{i,g}`$, foreign coefficient $`b_{i,g}`$ and Rayleigh scattering coefficient $`r_g`$ use cm$`^2`$ per $`10^{20}`$ corresponding molecules, so their products with columns are dimensionless optical depths.

A continuum is absorption spread across wavelengths. The self continuum represents interactions between water molecules, and the foreign continuum represents interactions between water and other molecules. Their density factors $`S`$ and $`B`$ are dimensionless. Four dimensionless pressure and temperature factors $`f_i`$ estimate the water line coefficient. Fractions $`x`$ and $`y`$ estimate the self and foreign coefficients from two adjacent temperature rows.

Below or at the tropopause, which marks the lower atmosphere's upper boundary, the absorption depth $`\tau_{{\rm A},g}`$ has three terms. The source adjustment $`G=1.029`$ applies only to the water line term. The source omits water absorption above the tropopause in this band. Molecular scattering remains active in every daylight layer.

```math
\tau_{{\rm A},g}=
\begin{cases}
C_{\rm w}\left[G\displaystyle\sum_{i=1}^{4}f_i k_{i,g}
+S\big((1-x)s_{0,g}+x s_{1,g}\big)
+B\big((1-y)b_{0,g}+y b_{1,g}\big)\right], & \ell\le T_{\rm p},\\
0, & \ell>T_{\rm p},
\end{cases}
\qquad
\tau_{{\rm R},g}=C_{\rm m}r_g,\qquad g=1,\ldots,10.
```

Here $`T_{\rm p}`$ is the one-based tropopause layer. The cosine $`\mu`$ of the solar zenith angle selects daylight when $`\mu>0`$. Night columns remain unchanged. A fixed solar spectrum $`F_g`$ is copied at a selected lower layer. It uses W m$`^{-2}`$ on a plane perpendicular to the Sun's rays and is not multiplied by the cosine.

The pressure and temperature factors sum to one within source rounding, but can be negative. The continuum fractions can also lie outside zero to one. Such extrapolation estimates beyond a table interval. Preserve these signed inputs, while independently checking that the complete active returned depths remain finite and nonnegative.

## Source Density and Wet Composition

The original gas preparation supplies the dry molecule count $`N_{\rm d}`$, water molecule count $`N_{\rm w}`$, pressure $`p`$ in hPa and temperature $`T`$ in K. The original SRTM_SETCOEF first forms the molecule ratio $`w=N_{\rm w}/N_{\rm d}`$. Its density relative to 1,013 hPa and 296 K is $`D_{\rho}=(p/1013)(296/T)`$. The continuum factors are the dry and water fractions of that relative density.

```math
B=\frac{D_{\rho}}{1+w},\qquad S=\frac{wD_{\rho}}{1+w}.
```

These formulas independently explain the factors, while their actual FP64 sequence remains frozen. The source separately rounds 296/1013, then its product with pressure, division by temperature, addition of one to the molecule ratio, and division by that sum. The self factor multiplies the rounded foreign factor by the rounded molecule ratio. All 972,800 captured layers preserve the prescribed factors and scaled columns exactly, and high-precision mixture-density checks pass.

Lower self interpolation uses $`z=(T-188)/h`$, index MIN(9,MAX(1,INT(z)-7)), and fraction $`x=z-({\tt INDSELF}+7)`$. Here INT truncates toward zero and the source default-real step becomes $`h=7.1999998092651367`$ K in FP64. The foreign interpolation uses $`z=(332-T)/36`$, index MIN(2,MAX(1,INT(z))), and fraction $`y=z-{\tt INDFOR}`$. Upper inputs retain self factor and fraction positive zero, self index zero, foreign index three and fraction $`(T-188)/36-1`$, although this band's upper absorption does not read them.

The original [gas preparation](rrtm_prepare_gases.md) approximates moist composition. With specific humidity $`q`$, meaning water mass divided by total moist-air mass, it uses $`w=qM_{\rm d}/M_{\rm w}`$. The molar masses are $`M_{\rm d}=28.970`$ and $`M_{\rm w}=18.0154`$ g mol$`^{-1}`$. A physical mixture would use $`w_{\rm physical}=qM_{\rm d}/[(1-q)M_{\rm w}]`$. The prescribed self and foreign density factors therefore have the following ideal-real ratios at fixed pressure and temperature.

```math
\frac{S_{\rm source}}{S_{\rm physical}}=1-\frac{q}{1+w}\quad(q>0),\qquad
\frac{B_{\rm source}}{B_{\rm physical}}=1+\frac{qw}{(1-q)(1+w)}.
```

For $`0\le q\le0.05`$, self density is at most 4.627901% low and foreign density at most 0.3916833% high. Across the actual captures, these maxima are 2.433391% low and 0.1016726% high. At zero humidity both self factors vanish and the foreign factors agree. The water and total column biases remain separately quantified in the gas and [scattering](srtm_taumol26.md) contracts. This preserves the original approximate science and does not claim exact moist-mass conservation.

The column scale is the default-real literal 1.E-20 converted from binary32 to $`A=9.999999682655225\times10^{-21}`$ in FP64. The source uses $`{\rm RN}(AN_{\rm w})`$ and the rounded sum of separately scaled dry and water counts for $`C_{\rm m}`$. Keep this conversion rather than silently replacing it with an exact decimal scale.

## Coefficient Provenance

The water line table comes from record eight of the original big-endian RADSRTM file. Its 8,320-byte payload contains five temperature rows, thirteen pressure rows and sixteen original spectral points. The captured KA_D matches the complete record, and its FP64 conversion to KA preserves every bit. The original source literal self, foreign, solar and Rayleigh arrays also match all captured bits.

SRTM_CMBGB23 forms ten reduced groups with the original weights starting at offset 112. The line, self, foreign and Rayleigh coefficients use ordered weighted sums, while solar flux uses an unweighted sum. An independent high-precision check covers 810 active coefficients and weight relations. A separate check confirms every ordered reduced bit. The primary reads these unchanged tables rather than reconstructing or fitting them.

The module gives ABSA(65,16) and KAC(5,13,16) the same memory, exported as yoesrta23.eq.0_. Temperature changes fastest, then pressure, then spectral point. The self table has ten rows and the foreign table three rows. LAYREFFR is six and NSPA(23) is one. Every declared coefficient and global is read-only.

## Complete Inputs and Storage

Let $`n={\tt KFDIA}-{\tt KIDIA}+1`$ be the selected columns, $`H={\tt KLEV}`$ the active layers and $`V={\tt YDDIMV\%NFLEVG}`$ the complete layer capacity. The first array dimension is compact width $`n`$, with the first element representing KIDIA. Columns change fastest. Supported shapes have $`{\tt KIDIA}\ge1`$, $`0\le n\le4096`$ and $`0\le H\le V\le512`$. Empty columns and zero layers write nothing.

| Input | Complete storage | Meaning |
| --- | --- | --- |
| YDDIMV | Eight 32-bit integers, 32 bytes | NFLEVG at byte zero and seven opaque unused fields |
| KIDIA, KFDIA, KLEV | Three 32-bit scalars | Selected columns and active layers |
| FAC00, FAC01, FAC10, FAC11 | $`nV`$ FP64 values each | Dimensionless pressure and temperature factors |
| JP, JT, JT1 | $`nV`$ integers each | Pressure and temperature table indices |
| COLH2O, COLMOL | $`nV`$ FP64 values each | Water and total molecular columns |
| LAYTROP | $`n`$ integers | One-based tropopause layer |
| SELFFAC, SELFFRAC, FORFAC, FORFRAC | $`nV`$ FP64 values each | Dimensionless continuum factors and fractions |
| INDSELF, INDFOR | $`nV`$ integers each | Continuum temperature rows |
| PRMU0 | $`n`$ FP64 values | Solar zenith cosine |
| ABSA, SELFREFC, FORREFC | 65 by 16, 10 by 16, 3 by 16 FP64 globals | Complete reduced absorption tables |
| SFLUXREFC, RAYLC | Sixteen FP64 globals each | Fixed solar flux and scattering |
| GIVFAC, LAYREFFR, NSPA | FP64 scalar, integer scalar, fourteen integers | Line adjustment, solar reference and species storage |

All reals align to eight bytes and integers to four bytes. Only ten of the sixteen spectral slots are active. Outputs must be disjoint from every other output, complete argument and numerical global. Preserve every complete input and global byte.

| Mutable output | Complete shape | Written cells |
| --- | --- | --- |
| SFLUXZEN | $`16n`$ FP64 values | Defined daylight solar reference, slots one through ten |
| TAUG, TAUR | $`16nV`$ FP64 values each | Daylight active layers, slots one through ten |

Night cells, extra layers and unused spectral slots keep every incoming byte. Inactive inputs have storage requirements only and can contain opaque NaN payloads. A NaN is a stored value that does not represent a real number. Such unused bytes remain in complete captures and are not interpreted as physics.

Each active lower layer reads JP(layer+1). Daylight with $`H>0`$ therefore requires $`1\le{\tt LAYTROP}\le H`$ and $`{\tt LAYTROP}<V`$. Lower indices satisfy $`1\le{\tt JP}\le12`$ and $`1\le{\tt JT},{\tt JT1}\le4`$, keeping all four line entries within rows one through 65. Self indices are one through nine, so the adjacent row stays within ten. Foreign indices are one or two, so the adjacent row stays within three. Upper continuum indices can differ because this band never consumes them. Check these capacities before original execution.

The physical domain uses finite $`-1\le\mu\le1`$, nonnegative finite active columns, density factors and coefficients, finite signed interpolation factors and fractions, and finite nonnegative returned optical depths. Four line factors sum to one within $`64\epsilon`$, where $`\epsilon=2^{-52}`$ is FP64 relative spacing near one. Keep signed zeros and gradual underflow, which preserves very small nonzero FP64 values. Stop if any consumed active physical value lacks a definition.

Unused caller storage can differ between runs. Freeze every complete incoming output and opaque object byte. Replay each complete frozen actual input through source and native clones and compare all returned bytes to the frozen original. Fresh forecasts compare complete paired source/native returns from identical inputs. Report unused cross-run differences separately, retaining every bit without masking, rounding or normalisation.

## Ordered Arithmetic and Solar Selection

RN means rounding one operation to FP64 using round-to-nearest with ties to even. The floating-point control register must equal zero at entry and return. Preserve signed zero and subnormal values. Forbid fused operations, expression contraction, reassociation, approximate arithmetic, reduced precision and fast-math.

For each column, initialise its selected solar layer to LAYTROP. Visit lower layers in increasing order. If JP(layer) is below LAYREFFR and JP(layer+1) is at or above it, select MIN(layer+1,LAYTROP). Copy solar coefficient bits when the current lower layer equals the selected layer. Preserve this state order within each column. Independent column enumeration and independent lower/upper cells can be reordered after retaining their complete dependencies and output disjointness.

With source rows counted from one, IND0=(JP-1)*5+JT and IND1=JP*5+JT1. The factor order is FAC00, FAC10, FAC01, FAC11, with table rows IND0, IND0+1, IND1, IND1+1. First compute the rounded Rayleigh product, then the complete lower absorption.

```math
p_i={\rm RN}(f_i k_{i,g}),\qquad
u_1={\rm RN}(p_1+p_2),\qquad u_2={\rm RN}(u_1+p_3),\qquad u_3={\rm RN}(u_2+p_4),\qquad L={\rm RN}(G u_3).
```

Use separately rounded subtraction, multiplication and addition for each continuum. The order and parentheses below also apply when a fraction lies outside zero to one.

```math
s_{\Delta}={\rm RN}(s_{1,g}-s_{0,g}),\qquad
s_x={\rm RN}(x s_{\Delta}),\qquad
s_*={\rm RN}(s_{0,g}+s_x),\qquad
s={\rm RN}(S s_*),
```

```math
b_{\Delta}={\rm RN}(b_{1,g}-b_{0,g}),\qquad
b_y={\rm RN}(y b_{\Delta}),\qquad
b_*={\rm RN}(b_{0,g}+b_y),\qquad
b={\rm RN}(B b_*),\qquad
v_1={\rm RN}(L+s),\qquad v_2={\rm RN}(v_1+b),\qquad
\tau_{{\rm A},g}={\rm RN}(C_{\rm w}v_2).
```

Every active Rayleigh depth is RN(COLMOL*RAYLC). Upper gas depth is positive zero. Store lower absorption, then any selected solar copy, then Rayleigh depth. The driver supplies no missing numerical stage. There are twenty scalar FP64 arithmetic operations per lower spectral cell, including scattering, and one multiplication per upper cell.

## Arm Calling Interface

The ABI, meaning the rules used to call separately built code, has twenty-four ordinary pointer arguments and no descriptors or hidden arguments. Their order is YDDIMV, KIDIA, KFDIA, KLEV, FAC00, FAC01, FAC10, FAC11, JP, JT, JT1, COLH2O, COLMOL, LAYTROP, SELFFAC, SELFFRAC, INDSELF, FORFAC, FORFRAC, INDFOR, SFLUXZEN, TAUG, TAUR, PRMU0. The first eight pointers use x0 through x7, and sixteen pointers use incoming stack bytes zero through 120.

The direct body uses the same complete interface under srtm_taumol23_assembly_. Its Armv8-A scalar body has a 320-byte aligned frame for saved x19 through x30, all argument pointers and the species count. It leaves x18, d8 through d15 and the floating-point control register unchanged. It calls no numerical helper and reads only the declared eight global inputs. Profiling is outside numerical state. Standalone source verification disables the profiling hook because MPI has not started, while full forecasts retain normal profiling.

## Frozen Records and Source Evidence

Each little-endian record begins with a 32-byte header containing a 64-bit call number, 32-bit phase and site, then KIDIA, KFDIA, KLEV and NFLEVG as integers. Inputs append the complete 32-byte object, the 10,308-byte global block in the input table order, complete arguments FAC00 through INDFOR in pointer order, complete PRMU0, and the three complete incoming outputs in solar, gas, Rayleigh order. Outputs retain that header and append the complete three returned buffers. Numerical metadata and timing stay separate.

```math
B_{\rm input}=10372+100nV+12n+128n(2V+1),\qquad
B_{\rm output}=32+128n(2V+1).
```

The source-only corpus has 61 complete records. Two protected placements give 122 calls and 1,171,264 returned bytes. Read-only input pages, inaccessible bounds and poisoned output neighbours protect full capacities. Its 224,520 independent relations cover line and continuum units, zero water, signed zeros, subnormals, constant and affine tables, continuum endpoints and extrapolation, self and foreign density scaling, mixed tropopause levels, pressure crossings, complete unused storage and the worst actual factors. Active outputs include 10,260 positive zeros, 80 negative zeros and 220 nonzero subnormal values.

The unchanged source forecast has 6,400 calls at original return offset 0x872d38, with 256 calls in each phase zero through 24. Every call has KIDIA=1, KFDIA=8 and $`H=V=19`$. The 419,865,600 complete input bytes and 255,795,200 complete return bytes include 95,846,400 preserved storage bytes. All 72,396,800 optical relations pass, and the complete original-input replay directly matches the frozen source. The density and column connection adds 9,523,200 independent relations across 972,800 layers. All ten saved files directly match the strict-vertical baseline across 618,140 bytes.

The actual pressure and temperature factors range from −1.5854138628 to 2.5593447427. Lower self fractions range from −7.6180123957 to 1.3501800303, and foreign fractions from −0.4700359141 to 1.9236024812. The largest actual absorption depth is 55.60758553. Each of the 768,000 next-pressure reads is within capacity, and every consumed daylight solar slot has a definition.

Acceptance requires zero differing bytes for protected complete returns, every frozen actual-input replay, each fresh paired complete return and all ten saved files. An immediate ABI observer checks saved registers and stack before C can restore them. Report the first mismatching call, phase, field, byte and bit pattern. Hashes identify preserved artifacts and never replace direct byte comparisons. No comparative timing is accepted.

## Verified Direct Body

The first complete direct body has 200 instructions and a 320-byte frame. It passes every one of the 122 protected physics and ABI calls, then all 6,400 complete original-input replays, with zero differing bytes. The isolated forecast accepts all 6,400 complete paired source/native returns and all ten saved files. The instruction review finds exactly eight declared global inputs and no numerical helper, fused operation, approximate arithmetic, FP32 calculation or use of reserved x18.

Fresh complete inputs differ in 52,218,078 unused storage bytes, including 12,802 opaque object bytes. Returned streams differ only in the corresponding 52,205,276 preserved unused spectral bytes. Every mathematical input and active physical returned value matches the original capture. All complete incoming and returned bits remain archived, while each same-input source/native state and complete frozen-input replay compares directly. No comparative timing is accepted.

## Reproduction

The immutable release lives under .runtime/openifs/srtm_taumol23_7207705/. Its pre-emission manifest freezes original source and tables, units, complete capacities, ordered arithmetic, ABI, corpus, actual captures and independent source-only science. The primary is emitted directly as assembly and built with an assembler and linker. Compiler numerical assembly and intermediate representations are not used to construct it.

Run this block through srun on CPU16 in the verified exclusive allocation, with local memory placement.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol23_7207705"
check="$release/reproduction"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -c src/openifs/physics/srtm_taumol23.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM23_ABI_OBSERVER .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol23.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/preparation/critical-corpus.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-final.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm23-source-7207705/t21/test_fc/srtm23-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm23-source-7207705/t21/test_fc/srtm23-fortran.bin "$check/replay-fortran.bin"
```

Documentation revision 1.2 records the selected forty-two-body combined forecast. Every complete same-input pair passes across forty streams and 5,016,076,808 returned bytes, and all ten saved files directly match across 618,140 bytes. All 159,744,000 active band-23 physical output bytes also match the separate original source capture. Complete same-input comparisons and every frozen-input replay retain all unused spectral bits. The frozen numerical revision remains unchanged.
