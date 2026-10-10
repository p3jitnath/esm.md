# Shortwave Band 29 Water and Carbon Dioxide Absorption

This contract covers the complete original SRTM_TAUMOL29 routine, which has 147 source lines. The band spans 820 to 2600 inverse centimetres, corresponding to wavelengths of about 3.85 to 12.2 micrometres. Lower layers use water absorption tables and water continuum terms, then add carbon dioxide absorption. Upper layers use carbon dioxide tables, then add water absorption. All active layers also produce molecular Rayleigh scattering, which redirects sunlight without absorbing it.

The original caller is SRTM_GAS_OPTICAL_DEPTH. Its one captured return address is 0x87289c in the unchanged strict library. The complete caller arrays have sixteen spectral channels, while the original NG29 value selects twelve. A spectral channel is one part of this wavelength band. The routine writes only daylight columns, where the cosine of the Sun's zenith angle is positive. Every incoming night, unused-channel and extra-layer bit stays unchanged.

## Physical Quantities

Let $`C_w`$ denote the water column, $`C_c`$ the carbon dioxide column and $`C_m`$ the total molecular column. Each column uses units of $`10^{20}`$ molecules per square centimetre. The coefficients have the inverse corresponding column unit, so each optical depth is dimensionless. An optical depth measures how strongly a layer attenuates radiation. Solar flux uses watts per square metre. The continuum density factors and interpolation fractions are dimensionless.

Let $`a_{00},a_{10},a_{01},a_{11}`$ be the four absorption coefficients selected from a pressure and temperature table, and let $`f_{00},f_{10},f_{01},f_{11}`$ be their interpolation factors. The factors sum to one. They may be negative when the original temperature rule extrapolates beyond a reference interval, so the contract does not assume a convex average.

```math
L = f_{00}a_{00}+f_{10}a_{10}+f_{01}a_{01}+f_{11}a_{11}.
```

Let $`s_0,s_1`$ be adjacent self-continuum coefficients and $`b_0,b_1`$ adjacent foreign-continuum coefficients. Self continuum describes water interacting with water, while foreign continuum describes water interacting with other molecules. Their fractions are $`x_s,x_f`$, and their density factors are $`F_s,F_f`$.

```math
S = F_s\left[(1-x_s)s_0+x_s s_1\right],\qquad
B = F_f\left[(1-x_f)b_0+x_f b_1\right].
```

The lower-layer carbon dioxide coefficient is $`k_c`$, the upper-layer water coefficient is $`k_w`$, and the Rayleigh coefficient is $`r=9.30\times10^{-11}`$ in the inverse scaled molecular-column unit.

```math
\tau_{g,\mathrm{lower}}=C_w(L+S+B)+C_c k_c,\qquad
\tau_{g,\mathrm{upper}}=C_c L+C_w k_w,\qquad
\tau_r=C_m r.
```

Zero water and carbon dioxide columns give zero absorption. A zero molecular column gives zero scattering. With fixed coefficients and density factors, scaling both absorber columns scales absorption by the same amount. The critical corpus checks these limits, known unit depths and doubled columns independently of the ordered source expressions.

## Existing Gas Preparation

The inputs retain the reviewed RRTM gas-preparation approximation. Let $`q`$ be water mass divided by total moist-air mass, and let $`M_d=28.970`$ and $`M_w=18.0154`$ be the dry-air and water molar masses in grams per mole. The source uses $`w=qM_d/M_w`$ in its prescribed gas correction. It does not equal the physical moist-to-dry molecular ratio $`w/(1-q)`$ when $`q>0`$.

The continuum factors use the source water-to-dry molecular ratio, pressure $`p`$ in hectopascals and temperature $`T`$ in kelvin. The foreign factor is a dry-fraction relative density, while the self factor is the corresponding water-fraction relative density.

```math
F_f=\frac{p\,296}{1013\,T(1+w)},\qquad F_s=wF_f.
```

At matched pressure and temperature, the source self factor divided by the physical-mixture factor is $`1-q/(1+w)`$ for $`q>0`$. The foreign-factor ratio is $`1+qw/[(1-q)(1+w)]`$. At $`q=0`$, both self factors are zero, and the self-ratio continuous limit is one. The foreign ratio is one. These are ideal-real composition-factor biases, before the retained gas-column and literal-rounding effects. At $`q\le0.05`$, their maximum departures are a 4.62791% self-factor reduction and a 0.391684% foreign-factor increase. Across the actual forecast inputs, the corresponding maxima are 2.43340% and 0.101673%.

For the complete upstream mass correction, set $`D=1+q-Cq^2`$ with $`C=(M_d-M_w)M_d/M_w^2`$. The original inferred total mass divided by the prescribed layer mass is $`(1+q)/D`$. The accepted upstream domain reaches a 0.233357% total mass excess, while the actual inputs reach 0.061201%. The source sequence and its approximation stay unchanged. Exact source/native bytes therefore establish implementation agreement, without claiming exact wet mass conservation.

The original unsuffixed 1.E-20 literal becomes the FP64 value 9.9999996826552254e-21 after its default-real conversion. SETCOEF multiplies the water and carbon dioxide molecule columns by this value and forms the total column by adding separately rounded scaled dry and water columns. Its prescribed zero-carbon-dioxide fallback uses the separately converted unsuffixed 1.E-32 literal times the dry column. The connected source verifier checks all three rounded columns, this fallback and all density inputs against the complete original gas outputs.

The original source-only SRTM_INIT call receives the optional continuum argument with value zero. CAVIAR continuum modification is therefore inactive. This is captured directly, rather than inferred from a default. All raw, converted and reduced coefficient arrays also match the unchanged literals and data records.

## Complete Storage and ABI

The application binary interface, or ABI, is the rule that a caller and assembly routine use to pass arguments and preserve registers. The first eight pointers arrive in x0 through x7, and the remaining seventeen pointers arrive at consecutive eight-byte positions on the incoming stack. Integer and logical values use four bytes, and real values use eight-byte FP64 storage. The first thirty-two TDIMV bytes are captured, including the used NFLEVG field and all unused object bits.

Let $`n=KFDIA-KIDIA+1`$, $`H=KLEV`$, $`V=NFLEVG`$ and $`C=nV`$. The first array index varies fastest. A layer cell with zero-based column $`j`$ and layer $`k`$ has index $`j+nk`$. A spectral output cell in channel $`g`$ has index $`j+n(k+Vg)`$. The solar index is $`j+ng`$.

| Argument | Meaning | Complete capacity |
| --- | --- | --- |
| 0 | TDIMV object | 32 captured bytes |
| 1, 2, 3 | KIDIA, KFDIA, KLEV | One int32 each |
| 4, 5, 6, 7 | FAC00, FAC01, FAC10, FAC11 | C FP64 each |
| 8, 9, 10 | JP, JT, JT1 table indices | C int32 each |
| 11, 12, 13 | Water, carbon dioxide, molecular columns | C FP64 each |
| 14 | Lower-layer count LAYTROP | n int32 |
| 15, 16, 17 | Self density, fraction, index | C FP64, C FP64, C int32 |
| 18, 19, 20 | Foreign density, fraction, index | C FP64, C FP64, C int32 |
| 21 | Solar flux | 16n FP64 |
| 22, 23 | Gas and Rayleigh depths | 16C FP64 each |
| 24 | Sun's zenith-angle cosine | n FP64 |

The eleven complete numerical global objects are ABSA(65,16), ABSB(235,16), SELFREFC(10,16), FORREFC(4,16), SFLUXREFC(16), ABSCO2C(16), ABSH2OC(16), scalar RAYL, scalar LAYREFFR and the fourteen-element NSPA and NSPB arrays. Their total size is 40,700 bytes. The original ELF symbols yoesrta29.eq.1_ and yoesrta29.eq.0_ identify ABSA and ABSB respectively. The source reads NSPA(29)=NSPB(29)=1 and LAYREFFR=49.

All outputs are disjoint from all inputs, other outputs and numerical globals. Inputs may alias each other. Normal eight-byte real and pointer alignment and four-byte integer alignment are sufficient. Every readonly argument and complete global is preserved. The planned direct body uses a 320-byte aligned stack frame and preserves x19 through x29, the link register, stack pointer and the required lower bits of d8 through d15. Reserved x18 is not used.

The supported bounds are $`0\le n\le4096`$ and $`0\le H\le V\le512`$, with KIDIA positive. A zero column or layer count writes no output. Daylight columns with $`H>0`$ have $`1\le LAYTROP\le H`$. This ensures each active upper layer has a previous pressure row within the complete input capacity.

Each active temperature index is from one to four. Lower pressure indices are from one to twelve, and upper indices from thirteen to fifty-eight. Thus both pressure-temperature row pairs lie within the complete 65-row or 235-row table. Lower self indices are from one to nine and foreign indices from one to three, so the second interpolated row remains within the ten-row or four-row continuum table.

Each selected column is finite, nonnegative and at most $`2^{300}`$. Interpolation factors and continuum fractions have magnitude at most $`2^{20}`$, and density factors are also nonnegative. Each active absorption or scattering coefficient is finite, nonnegative and at most $`2^{100}`$. These bounds keep every intermediate far below FP64 overflow. The returned active absorption must remain finite and nonnegative under the original extrapolation. Unused incoming array and object bits can contain any bit pattern and remain captured unchanged.

## Frozen Ordered Arithmetic

RN means one correctly rounded FP64 operation, using round-to-nearest with ties to even, gradual underflow and preserved signed zeros. FPCR, the Arm floating-point control register, is zero at entry and return. Contraction, fused multiply-add, reassociation, approximate arithmetic, reduced precision and fast math are excluded.

For either pressure-temperature table, the source forms four separately rounded factor products and adds them from left to right. The lower self and foreign terms retain subtraction-based interpolation before their density-factor multiplication. The independent physical verifier uses expanded barycentric weights instead.

```math
L=\operatorname{RN}\left(\operatorname{RN}\left(\operatorname{RN}(\operatorname{RN}(f_{00}a_{00})+\operatorname{RN}(f_{10}a_{10}))+\operatorname{RN}(f_{01}a_{01})\right)+\operatorname{RN}(f_{11}a_{11})\right).
```

```math
S=\operatorname{RN}\left(F_s\operatorname{RN}\left(s_0+\operatorname{RN}\left(x_s\operatorname{RN}(s_1-s_0)\right)\right)\right),\qquad
B=\operatorname{RN}\left(F_f\operatorname{RN}\left(b_0+\operatorname{RN}\left(x_f\operatorname{RN}(b_1-b_0)\right)\right)\right).
```

```math
\tau_{g,\mathrm{lower}}=\operatorname{RN}\left(\operatorname{RN}\left(C_w\operatorname{RN}(\operatorname{RN}(L+S)+B)\right)+\operatorname{RN}(C_c k_c)\right),\qquad
\tau_{g,\mathrm{upper}}=\operatorname{RN}\left(\operatorname{RN}(C_cL)+\operatorname{RN}(C_w k_w)\right),\qquad
\tau_r=\operatorname{RN}(C_mr).
```

Lower interpolation uses zero-based rows $`i_0=(JP-1)5+(JT-1)`$ and $`i_1=JP5+(JT1-1)`$. Upper interpolation uses $`i_0=(JP-13)5+(JT-1)`$ and $`i_1=(JP-12)5+(JT1-1)`$. The four table entries are $`i_0,i_0+1,i_1,i_1+1`$, in that source arithmetic order.

The original lower pass visits increasing layers, then increasing columns, and writes gas depth before Rayleigh depth. The upper pass starts one shared solar-layer scalar at H. At each daylight upper layer it tests whether the previous JP is below 49 and the current JP is at least 49. If so, the shared scalar becomes the current one-based layer. When that layer equals the scalar, the source copies SFLUXREFC to the column's solar spectrum between the gas and Rayleigh writes. This scalar is shared across columns, so the complete upper pass keeps the original layer-major and increasing-column order. A separate source-only proof checks that every solar slot later consumed by the caller is defined.

## Coefficient Provenance and Source Evidence

Original KGB29 reads the final RADSRTM record, number thirteen, then closes the data file. Its 38,400-byte payload contains KA_D(5,13,16) followed by KB_D(5,47,16), with big-endian Fortran record markers. The converted tables match every raw coefficient bit. The remaining continuum, solar, extra-absorber and Rayleigh values are frozen from their original literal setup and captured actual option.

The original CMBGB29 reduction uses twelve groups, with raw weight offset 208. It sums the line tables, continuum tables and extra-absorber coefficients using the original separately rounded products and ordered additions. Solar values use unweighted sums. The independent 70-digit verifier checks 3,817 relations and also requires the original ordered reduction bits.

The source-only critical corpus has forty input records and eighty protected placements. It checks zero shapes, table and continuum corners, night columns, complete incoming tails, signed zeros, nonzero subnormals, known unit and doubled columns, extra layers and shared solar crossings. Before primary emission, the original source passes 232,552 independent optical and complete-storage relations over 912,384 returned bytes.

The fresh selected-option original forecast captures all 6,400 actual entries, 622,156,800 complete input bytes and 255,795,200 complete returned bytes. It passes 85,401,600 independent relations, and a complete original-input replay directly matches the immutable returned stream. All ten saved forecast files directly match the canonical source across 618,140 bytes. A connected source check covers every one of the 972,800 layer-column inputs and the complete prescribed water, carbon dioxide, molecular and continuum inputs. No comparative timing is accepted.

## Output Bytes and Acceptance

Every record starts with a thirty-two-byte little-endian chronology header, followed by complete solar, gas and Rayleigh arrays in that order. No field, channel, signed zero or inactive value is rounded, masked or normalized. Acceptance requires zero differing bytes for each same-input original and direct call, each complete frozen-input replay and all ten saved forecast files.

The input archive also retains the entire incoming outputs and every declared global. A fresh run may have different unused incoming bytes. Its own complete source/native states must still match, and replay of every complete frozen source input must reproduce the original returned bytes. Cross-run input and output differences are classified and retained, with no claim that unrelated unused storage is identical.

The generator emits the complete primary directly as AArch64 assembly from this frozen science, ABI and ordered arithmetic. An assembler and linker build it. Compiler numerical assembly and compiler intermediate representations are not used for construction. The C observer supplies no omitted numerical stage. An immediate ABI observer checks saved registers and stack before C can restore them.

## Verified Direct Body

The unchanged first direct body has 314 instructions and a 320-byte frame. It passes all eighty protected independent-physics and immediate ABI calls, then all 6,400 complete actual-input replays, with zero differing bytes. The isolated forecast also directly compares all complete paired returned states across 255,795,200 bytes and all ten saved files across 618,140 bytes. The object review confirms the eleven declared global inputs and finds no numerical helper, FP32, fused or approximate arithmetic, reserved x18 or use of d8 through d15.

Every mathematical input, complete global and active incoming output bit is identical between the source and fresh native captures. Complete incoming archives retain 54,516,914 differing unused bytes, including 12,802 opaque object bytes. The 54,504,112 differing cross-run returned bytes exactly equal the corresponding preserved incoming gas and Rayleigh storage. The full incoming arrays and complete returned states remain archived. Same-input whole source/native states and the complete frozen-input replay compare directly, with no bit normalization or omission.

The comparator also forwards the unchanged original SRTM_INIT setup to record the selected optional continuum argument. It requires the original SUECRAD caller, preserves the flag and FPCR, and records the present value zero. This relay supplies no numerical stage. No comparative timing is accepted.

## Reproduction

Run this block through srun on an assigned CPU in your own verified quiet exclusive allocation, using local memory placement. Preserve the local immutable release and all source inputs.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol29_7207705"
check="$release/reproduction"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -c src/openifs/physics/srtm_taumol29.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM29_ABI_OBSERVER bench/openifs/physics/srtm_taumol29.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/preparation/critical-corpus.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-final.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm29-source-options-7207705/t21/test_fc/srtm29-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm29-source-options-7207705/t21/test_fc/srtm29-fortran.bin "$check/replay-fortran.bin"
```

Documentation revision 1.2 records the unchanged numerical revision 1.0 and first direct body. Root reproduction passes all eighty protected cases and every original-input replay, with an identical fresh primary object. The selected forty-four-body combined forecast passes forty-two complete paired streams across 5,909,648,008 bytes and all ten saved files across 618,140 bytes. All 191,692,800 active band-29 physical output bytes also match the separate original source capture. Unused storage can differ between fresh runs and remains fully archived. This release keeps the sole original SRTM_INIT setup relay and accepts no comparative timing.
