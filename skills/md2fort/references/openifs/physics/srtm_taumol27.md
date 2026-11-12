# SRTM_TAUMOL27 Solver Contract

Documentation revision 1.1 records the independently reviewed parent forecast. The physical equations, ordered update and direct numerical body remain unchanged.

Numerical revision 1.0 freezes the original OpenIFS shortwave band-27 calculation before direct assembly generation. This band covers wave numbers from 29,000 to 38,000 cm⁻¹. Wave number means the number of wavelengths in one centimetre. The calculation finds ozone absorption, scattering by air molecules and incoming solar energy in eight spectral groups. A spectral group collects nearby frequencies that use one coefficient. Coefficient setup and the rest of the forecast retain their original implementations.

## Physical Quantities

Optical depth is a dimensionless measure of how much radiation a layer removes from a beam. The ozone column $`C_o`$ and total molecular column $`C_m`$ count molecules through a layer, in units of $`10^{20}`$ molecules/cm². The absorption coefficient $`a`$ and Rayleigh coefficient $`r_g`$ use the inverse column unit, so their products with a column are dimensionless. Rayleigh scattering means scattering by molecules that are small compared with the wavelength. Solar energy $`S_g`$ uses W/m² perpendicular to the Sun’s rays.

Four factors interpolate an ozone coefficient between two pressure levels and two temperatures. Let $`f_{00},f_{10},f_{01},f_{11}`$ be those factors and $`a_0,a_{0+1},a_1,a_{1+1}`$ their four table values. The basic physics is

```math
\tau_{o,g}=C_o\left(f_{00}a_0+f_{10}a_{0+1}+f_{01}a_1+f_{11}a_{1+1}\right),\qquad
\tau_{r,g}=C_m r_g,\qquad S_g=sF_g .
```

Here $`s`$ is the original solar-spectrum correction and $`F_g`$ is reduced reference solar energy. Zero ozone gives zero absorption and zero molecular column gives zero scattering. Accepted table interpolation gives nonnegative optical depths. The factors sum to one within rounding error. Actual factors can be negative because the source sometimes extrapolates beyond its temperature grid, so checks use the resulting depth and do not assume a convex average.

Retain the source’s existing moist-air approximation. If $`q`$ is water mass divided by total moist-air mass, $`a_m=M_d/M_w-1`$ and $`A=\operatorname{FP64}(\operatorname{FP32}(10^{-20}))`$, its ideal-real total-molecule ratio to the physical mixture is $`(A/10^{-20})/(1-a_m^2q^2)`$. This is an algebraic bias, separately from rounding. Preserve the original rounded gas preparation and molecule scaling, without treating them as exact wet-mass conservation. The [gas contract](rrtm_prepare_gases.md) gives physical masses and measured bias. All molecular and ozone columns here exactly match the separately source-verified [band-25 inputs](srtm_taumol25.md).

## Dimensions and Complete Storage

Let $`n=N_F-N_I+1`$ be the compact column count, $`H`$ the active layer count and $`V`$ the complete layer capacity. Supported bounds are $`N_I\ge1`$, $`0\le n\le4096`$ and $`0\le H\le V\le512`$. Layers run from the surface upward. The tropopause separates the lower and upper coefficient tables.

| Storage | Type and complete capacity | Meaning and mutation |
| --- | --- | --- |
| Dimension object | Eight 32-bit integers, 32 bytes | Only its first integer gives $`V`$. Preserve all eight integers. |
| Bounds and active layers | Three 32-bit integer scalars | $`N_I,N_F,H`$ remain unchanged. |
| Four factors | Four FP64 arrays of $`nV`$ values | Dimensionless, unchanged. |
| Pressure and temperature indices | Three 32-bit integer arrays of $`nV`$ values | $`JP,JT,JT1`$ remain unchanged. |
| Molecular and ozone columns | Two FP64 arrays of $`nV`$ values | Scaled molecule columns, unchanged. |
| Tropopause | $`n`$ 32-bit integers | Lower-table layer count in each column, unchanged. |
| Solar cosine | $`n`$ FP64 values | $`\mu`$ lies in $`[-1,1]`$. Daylight means $`\mu>0`$. |
| Solar output | $`n\times16`$ FP64 values | Write only defined daylight groups 1–8. Preserve all other incoming bytes. |
| Absorption and scattering outputs | Each $`n\times V\times16`$ FP64 values | Write only daylight active layers and groups 1–8. Preserve all other incoming bytes. |

For zero-based compact column $`j`$, layer $`k`$ and group $`g`$, profile storage uses $`j+nk`$, optical storage uses $`j+n(k+Vg)`$ and solar storage uses $`j+ng`$. Outputs are mutually disjoint and disjoint from all inputs and coefficients. Inputs can share readonly storage when their full declared values agree. FP64 addresses need 8-byte alignment, while integers need 4-byte alignment. No 16-byte alignment is required.

For daylight with positive $`H`$, tropopause $`t_j`$ must satisfy $`1\le t_j\le H`$. Lower layers need $`1\le JP\le12`$ and upper layers need $`13\le JP\le58`$. Both need $`1\le JT,JT1\le4`$ and species count one. The upper pass reads the preceding pressure row, so positive $`t_j`$ protects that row before original execution. A forecast additionally requires the solar state below to define every consumed daylight slot. Empty-layer and night-only cases consume no solar value. Stop if a forecast would read an undefined active output.

## Coefficient Provenance

The lower table has 65 rows and 16 complete groups, using exported alias `yoesrta27.eq.1_` shared with the temperature-fast 5×13×16 reduced array. The upper table has 235 rows and 16 complete groups, using `yoesrta27.eq.0_` and the 5×47×16 reduced array. The complete readonly global input is 38,780 bytes.

| Global input in frozen order | Complete bytes | Source rule |
| --- | --- | --- |
| Lower ABSA, upper ABSB | 8,320 and 30,080 | Big-endian RADSRTM record 11 contains both original raw tables in one 38,400-byte payload. |
| Reduced solar and Rayleigh arrays | 128 each | Retain all 16 slots. Eight active groups collect the original 16 points. |
| Solar correction, reference pressure index | 8 and 4 | $`s=\operatorname{RN}(50.15/48.37)`$ and the reference index is 32. |
| NSPA and NSPB vectors | 56 each | Their band-27 entries both equal one. Preserve both complete vectors. |

Original `SRTM_KGB27` reads the raw FP64 tables and retains their conversion bits. It supplies the literal solar and Rayleigh values. Original `SRTM_CMBGB27` groups points with `NGC(12)`, `NGN(NGS(11)+g)` and `RWGT(176+p)`. Solar values are summed directly. Absorption and Rayleigh values use the original weights. Preserve each rounded multiplication and left-to-right sum. The source-only check independently verifies the raw file, both conversions, literal arrays, every active reduction and the separately rounded solar correction.

## Ordered Arithmetic and Solar State

$`\operatorname{RN}`$ means FP64 round-to-nearest with ties to even. Use gradual underflow, preserved signed zeros and FPCR zero. For each group, form

```math
p_0=\operatorname{RN}(f_{00}a_0),\quad p_1=\operatorname{RN}(f_{10}a_{0+1}),\quad
p_2=\operatorname{RN}(f_{01}a_1),\quad p_3=\operatorname{RN}(f_{11}a_{1+1}),
```

```math
u_1=\operatorname{RN}(p_0+p_1),\quad u_2=\operatorname{RN}(u_1+p_2),\quad
u_3=\operatorname{RN}(u_2+p_3),\quad
\tau_{o,g}=\operatorname{RN}(C_o u_3),\quad \tau_{r,g}=\operatorname{RN}(C_m r_g).
```

Compute molecular scattering first and ozone absorption next, as in the source. Lower zero-based table rows are $`i_0=(JP-1)5+JT-1`$ and $`i_1=JP5+JT1-1`$. Upper rows are $`i_0=(JP-13)5+JT-1`$ and $`i_1=(JP-12)5+JT1-1`$. Multiply these integer indices by the relevant species count, frozen to one, and also read each next row.

Complete the lower pass in increasing layer and then increasing compact column order. Before the upper pass, set one solar-layer scalar $`\ell_s=H`$. This scalar is shared across columns. In increasing upper-layer and column order, replace it by the current one-based layer when the previous pressure index is below 32 and the current index is at least 32. At that layer, write $`S_g=\operatorname{RN}(sF_g)`$. Write absorption before the conditional solar output, then scattering. Preserve this state order when columns have different tropopause or crossing layers. Actual captured columns all write solar values at layer 19.

Use separate FP64 multiply and add instructions. Fused multiply-add, contraction, reassociation, approximate arithmetic and FP32 numerical work are forbidden. Coefficient setup, profiling and I/O stay outside the complete optical body. Drivers check science and bounds but supply no missing optical stage.

## Native Interface

The 18 arguments are ordinary pointers. Registers x0–x7 hold the dimension object, three dimension scalars and four factors. Ten more pointers occupy entry-stack bytes 0–72, in order `JP,JT,JT1,molecular column,ozone column,tropopause,solar,absorption,scattering,cosine`. There are no array descriptors or hidden arguments. Preserve x19–x29, the return address, low 64 bits of v8–v15, FPCR and the 16-byte aligned stack. Do not use x18. Read original coefficient symbols through the global offset table, an address table supplied by the linker.

The original forecast caller is `SRTM_GAS_OPTICAL_DEPTH`, with source return offset `0x872b54` in the immutable strict library. It passes whole arrays and reads only daylight active groups. The observer accepts this exact source-scoped return and phases 0–24.

## Source Evidence and Acceptance

Before emission, the original body passes 43 complete input records at two protected placements, giving 86 calls, 906,944 returned bytes and 153,632 independent relations. Cases cover empty shapes, day/night thresholds, subnormal daylight cosine, extra capacity, signed zero, subnormal depths, exact unit and doubled depths, constant and affine tables, signed extrapolation, both pressure-table corners, mixed tropopauses and multi-column solar crossings. Inputs have readonly protected pages and outputs have checked neighbours. The source produces 560 positive zeros, 96 negative zeros and 304 nonzero subnormal optical values.

A fresh original forecast captures 6,400 calls, 563,174,400 complete input bytes and 255,795,200 returned bytes. Its 55,705,600 independent relations check every consumed solar value, every active depth and all untouched storage. Coefficients pass 2,425 additional high-precision provenance relations. All 972,800 layer compositions connect by exact original input bits to independently verified gas preparation, retaining its stated approximation. Ten saved files directly match the canonical forecast across 618,140 bytes.

Each input starts with an unsigned 64-bit call number, two signed 32-bit phase/site values and four signed 32-bit dimensions. It then stores the complete 32-byte dimension object, all globals in the table order, arguments 4–13 in pointer order, cosine and all three complete incoming outputs. Its size is $`38{,}844+60nV+12n+128n(2V+1)`$ bytes. Output stores the same 32-byte header and complete solar, absorption and scattering buffers, giving $`32+128n(2V+1)`$ bytes. Fields use little-endian order with no rounding, normalisation or masking.

Require zero differing returned bytes in protected source/native calls, every complete frozen-input replay, fresh paired forecast calls and all ten saved files. Hashes identify artifacts and do not replace direct comparison. Preserve unused incoming storage and unused dimension fields. Separate forecasts can receive different unused bytes, so disclose input differences before claiming cross-run output identity. Exact replay includes every original input byte. Independent science remains required because exact agreement can reproduce a source defect.

The independently reviewed parent forecast also accepts all 6,400 complete paired returns and 55,705,600 independent relations. Its 127,795,200 active solar, absorption and scattering bytes directly match the original source run. Every unused storage byte remains in complete same-input comparisons and the frozen-input replay. All ten saved files also match the canonical forecast directly.

## Reproduce the Critical Checks

Run this only through the own exclusive allocation, outside accepted timing. The strict library supplies the unchanged Fortran control and coefficient storage. The primary file is assembled directly. This recipe compares complete critical outputs and all complete original forecast records.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
cd /lus/lfs1aip2/projects/u6yq/users/p3jitnath/esm.md
check=.runtime/openifs/srtm27-public-critical-review-7207705
mkdir -p "$check"
gcc -c -fPIC -mcpu=neoverse-v2 src/openifs/physics/srtm_taumol27.S -o "$check/native.o"
gcc -c -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM27_ABI_OBSERVER .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol27.c -o "$check/critical.o"
gcc "$check/critical.o" "$check/native.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded .runtime/openifs/srtm_taumol27_7207705/preparation/critical-corpus.bin "$check/critical-source.bin" "$check/critical-native.bin"
cmp "$check/critical-source.bin" "$check/critical-native.bin"
cmp "$check/critical-source.bin" .runtime/openifs/srtm_taumol27_7207705/preparation/critical-fortran.bin
"$check/critical" replay .runtime/openifs/runs/strict-srtm27-source-7207705/t21/test_fc/srtm27-inputs.bin "$check/replay-source.bin" "$check/replay-native.bin"
cmp "$check/replay-source.bin" "$check/replay-native.bin"
cmp "$check/replay-source.bin" .runtime/openifs/runs/strict-srtm27-source-7207705/t21/test_fc/srtm27-fortran.bin
```

No comparative timing is accepted in revision 1.0. Whole-forecast scientific verification and other routine replacements remain separate work.
