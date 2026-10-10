# OpenIFS Shortwave Molecular Scattering

Numerical revision 1.0 freezes the complete `SRTM_TAUMOL26` numerical body before direct assembly generation. The routine describes molecular scattering in one shortwave band of the Sun's radiation. Scattering changes a light ray's direction. This band covers 22,650 to 29,000 cm$`^{-1}`$, or wavelengths of about 0.345 to 0.442 micrometres. The original source, coefficient setup and forecast caller remain unchanged. The [OpenIFS rules](../../../../../src/openifs/README.md) apply.

Documentation revision 1.2 adds the measured contiguous-cell implementation. Numerical revision 1.0, physical equations, ordered products and complete output bytes remain unchanged.

## Physics and Units

Let $`C`$ be a layer's total molecular column, measured in units of $`10^{20}`$ molecules cm$`^{-2}`$. Let $`r_g`$ be the reduced Rayleigh coefficient for spectral point $`g`$, with units cm$`^2`$ per $`10^{20}`$ molecules. A spectral point represents a part of the radiation band. Their product is the dimensionless Rayleigh optical depth $`\tau_{{\rm R},g}`$, which measures molecular scattering along the layer. Absorption optical depth $`\tau_{{\rm A},g}`$ is positive zero throughout this band.

```math
\tau_{{\rm A},g}=0,\qquad \tau_{{\rm R},g}=C\,r_g,\qquad g=1,\ldots,6.
```

The cosine $`\mu`$ of the solar zenith angle selects daylight when $`\mu>0`$. Zero and negative values select night. Only daylight columns are written. At each column's tropopause layer, the routine copies its fixed solar spectrum $`F_g`$, measured in W m$`^{-2}`$ on a plane perpendicular to the Sun's rays. The tropopause is the boundary between the lower and upper atmosphere. The routine does not multiply the spectrum by the cosine.

The original module stores 16 spectral slots, while this band uses six reduced points. Original tables in `srtm_kgb26.F90` provide 16 Rayleigh and solar values. `srtm_cmbgb26.F90` reduces them in ordered groups of 1, 1, 2, 2, 4 and 6 points. Each reduced Rayleigh coefficient is a weighted average. Each solar value is a sum. Independent high-precision checks cover the raw literal bits, all six normalised weight groups and both sets of reduced coefficients. The six solar values sum to 129.49501812 W m$`^{-2}`$.

The incoming column retains the existing [gas preparation approximation](rrtm_prepare_gases.md). `SRTM_SETCOEF` forms it by separately multiplying dry and water columns by the source literal `1.E-20` and adding the rounded results. That default-real literal first rounds to binary32, then converts to FP64, giving $`A=9.999999682655225\times10^{-21}`$. The scale differs from exact $`10^{-20}`$ by −3.1734477379$`\times10^{-8}`$ in relative terms.

For specific humidity $`q`$, define $`a=M_{\rm d}/M_{\rm w}-1`$, where the frozen dry and water molar masses are 28.970 and 18.0154 g mol$`^{-1}`$. The ideal-real ratio below compares the legacy scaled column with the full physical dry-plus-water molecule balance. It also applies to Rayleigh depth. It describes the algebraic approximation, while the verifier separately measures the source's ordered rounding.

```math
\frac{C_{\rm legacy}}{C_{\rm physical}}=
\frac{A/10^{-20}}{1-a^2q^2}.
```

The connected source check covers all 972,800 captured layer columns. Every supplied column exactly matches the original rounded dry-plus-water composition. Its signed relative physical error ranges from −3.1734497086$`\times10^{-8}`$ to +0.023716197891%. The largest difference from the ideal-real error formula is 2.7335$`\times10^{-14}`$. This inherited approximation remains unchanged. These checks establish its size without claiming exact wet-air conservation.

## Complete Storage and Inputs

Let $`n={\tt KFDIA}-{\tt KIDIA}+1`$ be the selected column count, $`H={\tt KLEV}`$ the active layer count, and $`V={\tt YDDIMV\%NFLEVG}`$ the complete layer capacity. Every array has compact first dimension $`n`$. Its first element represents `KIDIA`, and columns change fastest in memory. Supported shapes satisfy $`{\tt KIDIA}\ge1`$, $`0\le n\le4096`$ and $`0\le H\le V\le512`$. Empty columns and zero layers write no values.

| Argument | Complete storage | Meaning and mutation |
| --- | --- | --- |
| `YDDIMV` | Eight 32-bit integers, 32 bytes | Read-only object. `NFLEVG` is its first field, at byte zero. All other bytes are retained |
| `KIDIA`, `KFDIA`, `KLEV` | One 32-bit integer each | Read-only selected bounds and active layers |
| `P_COLMOL` | $`nV`$ FP64 values | Read-only scaled molecular column |
| `K_LAYTROP` | $`n`$ 32-bit integers | Read-only tropopause layer, counted from one |
| `PRMU0` | $`n`$ FP64 values | Read-only solar zenith cosine |
| `RAYLC`, `SFLUXREFC` | Two global arrays of 16 FP64 values | Read-only coefficients. Only slots 1 through 6 are used |
| `P_SFLUXZEN` | $`16n`$ FP64 values | Solar values. Writes slots 1 through 6 of daylight columns with a selected tropopause layer |
| `P_TAUG`, `P_TAUR` | $`16nV`$ FP64 values each | Absorption and scattering. Writes active layers and slots 1 through 6 of daylight columns |

All arrays store the column fastest. For zero-based column `j`, layer `k` and spectral point `g`, absorption and scattering use flat index `j+n*(k+V*g)`. The solar array uses `j+n*g`. Real addresses must align to eight bytes and integer addresses to four bytes. Each output must be disjoint from all other outputs, inputs, integer objects and coefficient globals. Inputs remain unchanged. The physical domain has finite $`-1\le\mu\le1`$, nonnegative finite active columns and coefficients, nonnegative finite solar values, and finite products. Negative zero and nonzero subnormal values, which are values smaller than the smallest normal FP64 number, remain supported. Inactive inputs are opaque storage and are not interpreted as physical numbers.

Night columns, slots 7 through 16, and layers above $`H`$ retain every incoming byte. Solar values also remain unchanged if the tropopause is outside layers 1 through $`H`$. The critical storage cases include those shapes. In a physical forecast, every consumed daylight solar value must first be defined, so its tropopause must lie in layers 1 through $`H`$. The original caller reads only daylight, active-layer, current-band values. All captured daylight columns have tropopause 15 within 19 active layers.

Unused caller storage and seven unused `YDDIMV` fields can contain unspecified incoming bytes. The complete incoming bytes are therefore part of each frozen input record. They are copied without interpretation, including NaN payloads and signed zeros. The complete output comparison covers them and never masks, normalises, rounds or omits any bits. A fresh run may start with different unused storage, so complete fresh streams are compared within each paired source/native call. Every original frozen complete input is also replayed through both bodies and compared directly with its frozen source return.

## Ordered Arithmetic and Arm Interface

`RN` means rounding one operation to FP64 with round-to-nearest and ties to even. The floating-point control register must be exactly zero at entry and return. Retain gradual underflow and signed zero. For each daylight column, active layer and spectral point, store absorption as positive zero and Rayleigh depth as `RN(P_COLMOL * RAYLC)`. Copy the solar coefficient bits when the active layer equals `K_LAYTROP`. There is no multiplication or reduction in the solar copy.

The original source has separate loops below and above the tropopause. Their returned cells are independent, so the direct body may enumerate all active layers in one loop without changing any arithmetic operation or observed state. It must retain the daylight condition and all untouched bytes. Do not use fused operations, approximate arithmetic, reduced precision, contraction or fast-math. No driver supplies a missing numerical stage.

For at least two selected columns, a short scan checks that every column is daylight and every tropopause lies in active layers 1 through H. This checked path then processes each spectral plane as a contiguous prefix of nH independent cells. It loads eight cells at a time, applies the original separate FP64 product to each lane and stores both positive absorption zeros and Rayleigh depths. Bounded groups of four, two and one handle the remainder. The next plane starts after the full nV capacity, so extra layers remain untouched. Solar coefficients are copied once per column and point because outputs are disjoint and every selected tropopause is valid. Other masks and tropopause ranges retain the complete scalar path.

The complete ABI, meaning the calling interface between separately built code, uses ten ordinary pointers with no descriptors or hidden arguments. The first eight arrive in `x0` through `x7`. `P_TAUR` arrives at incoming stack byte zero, and `PRMU0` at incoming stack byte eight. The pointer order is `YDDIMV, KIDIA, KFDIA, KLEV, P_COLMOL, K_LAYTROP, P_SFLUXZEN, P_TAUG, P_TAUR, PRMU0`. The two coefficient globals are the only extra numerical inputs. The primary name is `srtm_taumol26_`, and verification gives the same body the private name `srtm_taumol26_assembly_`.

The direct Armv8-A body preserves `x19` through `x30`, the lower 64 bits of `d8` through `d15`, stack alignment and the floating-point control register. It leaves `x18` untouched and calls no numerical helper. Its stack frame is 96 bytes. Profiling is outside the numerical return. Standalone source checks disable the profiling hook because MPI is not started, while the full forecast retains normal profiling.

## Frozen Records and Acceptance

Each record begins with a 32-byte header containing a little-endian 64-bit call index, 32-bit phase and site, then four 32-bit dimensions in the order `KIDIA, KFDIA, KLEV, NFLEVG`. Input records append the complete 32-byte `YDDIMV` object, all 16 Rayleigh and 16 solar coefficients, complete `P_COLMOL`, `K_LAYTROP` and `PRMU0`, then the complete incoming solar, absorption and Rayleigh buffers. Output records append the complete returned solar, absorption and Rayleigh buffers in that order. Metadata and timing remain separate.

```math
B_{\rm input}=320+8nV+12n+128n(2V+1),\qquad
B_{\rm output}=32+128n(2V+1).
```

The current source-only corpus retains all 62 original complete input records and adds four cases for changed vector groups and remainders. The added shapes use two, three and five columns, one through three active layers and extra layer capacity. Both placements against protected pages give 132 calls and 1,191,296 returned bytes. Read-only pages protect inputs, and poisoned neighbours and inaccessible pages protect complete outputs. The 162,456 independent relations check scattering dimensions, absorption zeros, solar copies, known unit depth, exact doubled-column response, zero column and coefficient limits, night masks, unused slots, extra layer capacity and complete preservation. Active Rayleigh results include 2,140 positive zeros, 3,000 negative zeros and 4,724 nonzero subnormal values.

The unchanged source forecast has 6,400 calls, with 256 calls in each phase 0 through 24 at original caller return offset `0x872b80`. Every call has $`n=8`$ and $`H=V=19`$. All 51,200 column entries are daylight. The complete input stream is 266,035,200 bytes and the complete output stream is 255,795,200 bytes, including 159,744,000 unchanged storage bytes. All 37,785,600 independent relations pass. The full frozen-input replay directly matches every returned byte. All ten saved forecast files match the strict-vertical baseline across 618,140 bytes.

Acceptance requires zero differing bytes for every paired complete return, every guarded stream, every original complete input replay and all ten saved files. An immediate ABI observer checks saved registers before C can restore them. Report the first call, phase, field and byte with its source/native bit patterns before stopping on a mismatch. Hashes identify immutable artifacts and do not replace direct byte comparison. Comparative timing starts only after these checks pass.

## Verified Direct Body

The selected complete body has 139 instructions and a 96-byte frame. All 132 guarded calls and all 6,400 original frozen-input calls pass complete output comparisons and immediate ABI checks. Its combined forecast passes all forty-three complete paired streams across 6,165,443,208 bytes and all ten saved files across 618,140 bytes. Every mathematical input and global matches the original source capture. All 95,846,400 active band 26 output bytes match it directly. Unused returned differences exactly equal their corresponding incoming bytes, with no masking.

Twelve quiet rotations compare complete calls on the same warmed buffers for four original eight-column, nineteen-layer states. Each sample repeats 200,000 calls, with compilation, loading, warm-up and byte checks outside the timer. The unchanged Fortran control uses CPU-aware GNU native 12.3 optimisation at -O3 with strict original arithmetic. It independently passes the same critical and frozen-input checks. Earlier assembly remains the matched scalar control. Times below are nanoseconds per complete call. The median is the mean of the two middle times after sorting these twelve measurements. MAD is the median absolute distance from that value.

| Original record | Fortran -O3 median | Earlier assembly median | Selected median | Selected range | Selected MAD | Gain over Fortran |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 817.91 | 720.45 | 170.50 | 152.15–174.58 | 2.41 | 4.80× |
| 256 | 818.43 | 721.26 | 169.87 | 155.69–173.82 | 3.95 | 4.82× |
| 3072 | 818.08 | 721.54 | 170.39 | 155.88–174.03 | 3.61 | 4.80× |
| 6144 | 817.95 | 720.29 | 170.85 | 152.12–174.02 | 0.94 | 4.79× |

The selected medians improve by 4.79–4.82 times over the stronger Fortran control. Full sample variation for every compared implementation remains in the retained local record and immutable local timing table. Measurements use own exclusive job 7207705 on nid011311, CPU 8 and local memory. All three agents confirm a pause, node occupancy and load are recorded, and before/after per-CPU observations pass.

The active data use 16 KiB within the observed 64 KiB first-level data cache. A complete call makes 912 separate FP64 products and an estimated 22,464 bytes of active-array traffic, plus dimension, global-address and stack traffic. A matching assembly reference keeps the complete bounds, copies, loads and stores, but replaces products with unchanged column copies. Its full return is checked independently. The selected rate is 93.9–99.6% of this empirical warmed memory/instruction rate, with calibration variation recorded. This rate describes these four workloads. It is not a global hardware limit. Division and square root are absent from this band.


## Reproduction

The immutable local release is under `.runtime/openifs/srtm_taumol26_7207705/`. Its pre-emission manifest freezes source and caller provenance, coefficients and units, ordered arithmetic, critical corpus, complete forecast captures, independent physical checks and the original strict science image. Numerical compiler assembly and intermediate representation are not used to construct the direct body.

Run this block through srun inside your verified exclusive allocation, on a free CPU with local memory placement. It builds the emitted body with an assembler, checks complete numerical and ABI behaviour, and replays all complete pre-emission forecast inputs. The strict science library SHA-256 is `8e4966877c735976f1e9356bc551294bbfc15c565ecdf1dc7db4cf814012b07b`.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol26_7207705"
check="$release/contiguous-cell-tuning-20261010/public-reproduction"
tuning="$release/contiguous-cell-tuning-20261010"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -DORIGINAL_SYMBOL=srtm_taumol26_assembly_ -c src/openifs/physics/srtm_taumol26.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM26_ABI_OBSERVER .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol26.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$tuning/extended-corpus.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$tuning/extended-fortran.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm26-source-7207705/t21/test_fc/srtm26-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm26-source-7207705/t21/test_fc/srtm26-fortran.bin "$check/replay-fortran.bin"
```
