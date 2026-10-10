# OpenIFS Shortwave Water and Ozone Absorption

Documentation revision 1.1 records the independently reviewed parent forecast. The physical equations, ordered update and direct numerical body remain unchanged.

Numerical revision 1.0 freezes the complete `SRTM_TAUMOL25` body before direct assembly generation. It describes absorption by water and ozone, and scattering by molecules, in a visible band of the Sun's radiation. Absorption removes energy from a light ray. Scattering changes the ray's direction. This band covers 16,000 to 22,650 cm$`^{-1}`$, or wavelengths of about 0.442 to 0.625 micrometres. The unchanged source and its complete forecast caller remain the reference. The [OpenIFS rules](../../../../../src/openifs/README.md) apply.

## Physics and Units

Let $`C_{\rm w}`$, $`C_{\rm o}`$ and $`C_{\rm m}`$ be water, ozone and total molecular columns. Each column uses units of $`10^{20}`$ corresponding molecules cm$`^{-2}`$. At spectral point $`g`$, the table coefficients $`k_{i,g}`$ describe water absorption, $`o_{{\rm low},g}`$ and $`o_{{\rm high},g}`$ describe ozone absorption, and $`r_g`$ describes molecular scattering. Their units are cm$`^2`$ per $`10^{20}`$ corresponding molecules. A spectral point represents a part of the radiation band.

Four dimensionless factors $`f_i`$ estimate the water coefficient from four pressure and temperature table points. They sum to one within the source rounding. The factors can be negative when temperature lies beyond a table interval. This is extrapolation, which estimates beyond the table grid. All captured absorption depths remain finite and nonnegative, and the signed factors remain unchanged.

For a layer below or at the tropopause, the dimensionless absorption depth $`\tau_{{\rm A},g}`$ combines water and ozone. Above that layer, the source retains the second ozone coefficient and omits water absorption. The tropopause is the boundary between the lower and upper atmosphere.

```math
\tau_{{\rm A},g}=
\begin{cases}
C_{\rm w}\displaystyle\sum_{i=1}^{4}f_i k_{i,g}
+C_{\rm o}o_{{\rm low},g}, & \ell\le {\tt K\_LAYTROP},\\
C_{\rm o}o_{{\rm high},g}, & \ell>{\tt K\_LAYTROP},
\end{cases}
\qquad
\tau_{{\rm R},g}=C_{\rm m}r_g,\qquad g=1,\ldots,6.
```

The cosine $`\mu`$ of the solar zenith angle selects daylight when $`\mu>0`$. Night columns remain unchanged. A fixed solar spectrum $`F_g`$ is copied at the selected lower-atmosphere reference layer. It uses W m$`^{-2}`$ on a plane perpendicular to the Sun's rays and is not multiplied by the cosine.

The incoming columns retain the existing [gas preparation approximation](rrtm_prepare_gases.md) and the scale described in the [molecular scattering contract](srtm_taumol26.md). `SRTM_SETCOEF` uses the default-real literal `1.E-20`, which converts from binary32 to $`A=9.999999682655225\times10^{-21}`$ in FP64. The routine uses $`{\rm RN}(A N_{\rm w})`$ and $`{\rm RN}(A N_{\rm o})`$ for water and ozone. Its total column is the rounded sum of separately scaled dry and water amounts. The connected audit verifies all three compositions exactly for every one of the 972,800 captured layer columns. This retains the quantified legacy wet-air approximation and does not claim exact wet-mass conservation.

## Coefficient Provenance

The water table comes from record 10 of the original big-endian `RADSRTM` file. Its 8,320-byte payload has 5 temperatures, 13 pressure points and 16 original spectral points. The captured `KA_D` table matches that complete record exactly, and its FP64 conversion into `KA` preserves every bit. Original literal solar, Rayleigh and two ozone arrays match their 16 source constants exactly.

`SRTM_CMBGB25` forms six reduced spectral groups. It multiplies each water, Rayleigh and ozone coefficient by the original normalised spectral weight, then sums in source order. Solar values use an unweighted sum. The independent high-precision check covers all 390 active water entries, all 24 reduced solar/scattering/ozone values and six weight sums, giving 420 relations. A separate check confirms every original ordered reduced value's bits. The primary reads these unchanged tables rather than regenerating or fitting them.

The original module makes `ABSA(65,16)` and `KAC(5,13,16)` share memory. This is an equivalence, meaning that both names describe the same storage. Its exported symbol is `yoesrta25.eq.0_`. Temperature changes fastest, then pressure, then spectral point. The reference pressure index `LAYREFFR` is 2, and the species count `NSPA(25)` is frozen at 1. All numerical globals are read-only inputs.

## Complete Inputs and Storage

Let $`n={\tt KFDIA}-{\tt KIDIA}+1`$ be the selected column count, $`H={\tt KLEV}`$ the active layers, and $`V={\tt YDDIMV\%NFLEVG}`$ the complete layer capacity. Arrays have compact first dimension $`n`$, with their first element representing `KIDIA`. Columns change fastest in memory. Supported shapes satisfy $`{\tt KIDIA}\ge1`$, $`0\le n\le4096`$ and $`0\le H\le V\le512`$. Empty columns and zero layers write no values.

| Input | Complete storage | Meaning |
| --- | --- | --- |
| `YDDIMV` | Eight 32-bit integers, 32 bytes | `NFLEVG` at byte zero, with seven opaque unused fields |
| `KIDIA`, `KFDIA`, `KLEV` | Three 32-bit scalars | Selected columns and active layers |
| `P_FAC00`, `P_FAC01`, `P_FAC10`, `P_FAC11` | $`nV`$ FP64 values each | Dimensionless pressure and temperature factors |
| `K_JP`, `K_JT`, `K_JT1` | $`nV`$ 32-bit integers each | Pressure and two temperature table indices |
| `P_COLH2O`, `P_COLMOL`, `P_COLO3` | $`nV`$ FP64 values each | Scaled water, total and ozone columns |
| `K_LAYTROP` | $`n`$ 32-bit integers | Tropopause layer, counted from one |
| `PRMU0` | $`n`$ FP64 values | Solar zenith cosine |
| `ABSA` | 65 by 16 FP64 global table | Complete reduced water coefficients |
| `SFLUXREFC`, `RAYLC`, `ABSO3AC`, `ABSO3BC` | Four global arrays of 16 FP64 values | Solar, scattering and lower/upper ozone coefficients |
| `LAYREFFR`, `NSPA` | One 32-bit scalar and 14 integers | Solar reference and full species-count storage |

Only six spectral slots are active. All coefficient capacities remain 16. All real addresses align to eight bytes and integer addresses to four bytes. Every output must be disjoint from all other outputs, arguments and numerical globals. The routine preserves every complete input and global byte.

| Mutable output | Complete shape | Written cells |
| --- | --- | --- |
| `P_SFLUXZEN` | $`16n`$ FP64 values | Defined solar reference in daylight, slots 1 through 6 |
| `P_TAUG`, `P_TAUR` | $`16nV`$ FP64 values each | Daylight, active layers, slots 1 through 6 |

Night, extra layers and unused spectral slots retain every incoming byte. Inactive inputs can contain opaque NaN payloads or other arbitrary storage, which is never interpreted as physics. Solar storage remains unchanged if no lower layer selects it. Each physical forecast must define every solar value that its caller consumes. All actual captures meet this condition.

Each active lower layer reads `K_JP(layer+1)` for the solar crossing test. Thus every daylight tropopause must satisfy $`0\le{\tt K\_LAYTROP}\le H`$ and, when positive, $`{\tt K\_LAYTROP}<V`$. This ensures that the next row lies within complete defined storage. Lower-layer indices satisfy $`1\le{\tt JP}\le12`$ and $`1\le{\tt JT},{\tt JT1}\le4`$, so all four table entries lie in rows 1 through 65. The source-only observer proves these bounds before calling the original routine. Its 768,000 actual look-ahead reads are all safe.

The physical domain uses finite $`-1\le\mu\le1`$, finite nonnegative active columns and coefficients, finite factors whose sum agrees with one within $`64\epsilon`$, and finite nonnegative returned depths. Here $`\epsilon=2^{-52}`$ is FP64 relative spacing near one. Signed factors and signed zeros remain supported. Very small nonzero FP64 values remain available through gradual underflow. Inactive cells have storage requirements only.

Unused caller bytes can differ between fresh runs. Freeze the entire incoming output storage and the complete object, including all opaque bytes. Replay every complete original input through source and native clones and compare every returned byte with the frozen source. A fresh forecast compares each complete paired source/native return. Cross-run complete streams are directly comparable only when their complete incoming storage is identical. Never mask, normalise, round or omit any bits.

## Ordered Arithmetic and Solar Selection

`RN` means rounding one operation to FP64 with round-to-nearest and ties to even. The floating-point control register must be exactly zero at entry and return. Retain signed zero and gradual underflow. Forbid fused operations, contraction, reassociation, approximate arithmetic, reduced precision and fast-math.

For each daylight column, initialise the selected solar layer to `K_LAYTROP`. Visit lower layers in increasing order. If `JP(layer) < LAYREFFR` and `JP(layer+1) >= LAYREFFR`, set the selected layer to `MIN(layer+1,K_LAYTROP)`. Copy the complete solar coefficient bits whenever the current lower layer equals that selected layer. The selection is column-local state and must preserve its increasing-layer order.

With source indices counted from one, the four water rows start at `IND0 = (JP-1)*5 + JT` and `IND1 = JP*5 + JT1`. The factors correspond to `FAC00, FAC10, FAC01, FAC11` in that order, with rows `IND0, IND0+1, IND1, IND1+1`. For each active point, use the following separately rounded operations.

```math
p_i={\rm RN}(f_i k_{i,g}),\qquad
s_1={\rm RN}(p_1+p_2),\qquad
s_2={\rm RN}(s_1+p_3),\qquad
s_3={\rm RN}(s_2+p_4),
\qquad
\tau_{{\rm A},g}={\rm RN}\!\left({\rm RN}(C_{\rm w}s_3)+{\rm RN}(C_{\rm o}o_{{\rm low},g})\right).
```

Upper-layer absorption uses exactly `RN(P_COLO3 * ABSO3BC)`. Every active layer uses `RN(P_COLMOL * RAYLC)` for scattering. Solar output is a bit copy. Independent columns and the lower/upper cell enumeration may be reordered after preserving each column's lower-layer solar selection. A driver must supply no omitted numerical stage.

## Arm Calling Interface

The complete ABI, meaning the interface between separately built code, uses 19 ordinary pointers with no descriptors or hidden arguments. The order is `YDDIMV, KIDIA, KFDIA, KLEV, FAC00, FAC01, FAC10, FAC11, JP, JT, JT1, COLH2O, COLMOL, COLO3, LAYTROP, SFLUXZEN, TAUG, TAUR, PRMU0`. The first eight pointers arrive in `x0` through `x7`. The remaining 11 occupy incoming stack bytes 0 through 80.

The primary symbol is `srtm_taumol25_`. Verification names the same body `srtm_taumol25_assembly_`. The Armv8-A body uses a 256-byte stack frame, preserves `x19` through `x30` and the lower 64 bits of `d8` through `d15`, keeps stack alignment and leaves `x18` and the floating-point control register unchanged. It calls no numerical helper. The declared coefficient and table globals are its only additional numerical inputs. Profiling is outside the numerical state. Standalone source verification disables the profiling hook because MPI has not started, while full forecasts retain normal profiling.

## Frozen Records and Evidence

Each record starts with a 32-byte header containing a little-endian 64-bit call index, 32-bit phase and site, then `KIDIA, KFDIA, KLEV, NFLEVG` as 32-bit integers. Inputs append the complete 32-byte object, numerical globals in the table order, complete arguments `FAC00` through `LAYTROP` in pointer order, complete `PRMU0`, then complete incoming solar, absorption and scattering buffers. The global block is 8,892 bytes. Outputs append all three complete returned buffers in the same order. Metadata and timing remain separate.

```math
B_{\rm input}=8956+68nV+12n+128n(2V+1),\qquad
B_{\rm output}=32+128n(2V+1).
```

The source-only corpus has 46 complete input records. Both start and end placement at protected pages give 92 calls and 893,056 returned bytes. Read-only pages protect every argument input, and poisoned neighbours and inaccessible pages protect complete outputs. The 136,356 independent relations check dimensional scattering and absorption, exact unit and doubled water responses, upper ozone depth, affine and constant tables, zero species, signed extrapolation, solar crossings, next-row bounds, night, unused slots and extra capacity. Active depths include 276 positive zeros, 72 negative zeros and 228 nonzero subnormal values.

The unchanged source forecast has 6,400 calls, 256 in each phase 0 through 24, at original return offset `0x872bf0`. Every call has `KIDIA=1`, `KFDIA=8` and $`H=V=19`$, with 51,200 daylight column entries. It captures 379,673,600 full input bytes and 255,795,200 full return bytes, including 159,744,000 unchanged bytes. All 47,001,600 independent relations pass. The signed factor range is −1.5854138628 to 2.5593447427, and the largest absorption depth is 0.07151580661. The full original-input replay directly matches every frozen source return. All ten saved files match the strict-vertical baseline across 618,140 bytes.

Acceptance requires zero differing bytes for all complete paired returns, protected streams, frozen original-input replays and saved files. The immediate ABI observer checks saved integer and floating-point registers before C can restore them. Stop on the first mismatch and report its call, phase, field, byte and bit patterns. Hashes identify immutable artifacts and do not replace direct comparisons. No comparative timing is accepted in this milestone.

## Verified Direct Body

The complete direct body has 165 instructions and a 256-byte stack frame, with no numerical helper. It passes all 92 protected calls and all 6,400 complete original-input replays, including immediate ABI checks and exact returned bytes. The isolated forecast passes all 6,400 paired complete returns and all ten saved files. No comparative timing is accepted.

The fresh run differs in 52,772,923 incoming bytes, all in unused object fields or spectral slots. Its returned source stream differs in the corresponding 52,760,121 preserved storage bytes. Every original complete frozen input still returns the exact frozen source bytes, and every fresh paired complete source/native state compares exactly. All incoming and returned bytes remain present in the archives.

The independently reviewed parent forecast also accepts all 6,400 complete paired returns and 47,001,600 independent relations. Its 95,846,400 active solar, absorption and scattering bytes directly match the original source run. Every unused storage byte remains in complete same-input comparisons and the frozen-input replay. All ten saved files also match the canonical forecast directly.

## Reproduction

The immutable release is under `.runtime/openifs/srtm_taumol25_7207705/`. Its pre-emission manifest freezes the original source and caller, complete empirical data and coefficients, ordered arithmetic, units, physical limits, corpus, complete captures and source-only replay. Numerical compiler assembly and intermediate representation are not used to construct the primary body.

Run the following block inside the verified exclusive allocation on CPU 16 with local memory placement. It assembles the direct body, verifies all complete protected returns and ABI obligations, then replays the complete pre-emission forecast inputs.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/srtm_taumol25_7207705"
check="$release/reproduction"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -DORIGINAL_SYMBOL=srtm_taumol25_assembly_ -c src/openifs/physics/srtm_taumol25.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DSRTM25_ABI_OBSERVER .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/srtm_taumol25.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" guarded "$release/frozen/corpus.bin" "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$check/critical-fortran.bin" "$check/critical-assembly.bin"
cmp "$release/preparation/critical-fortran-final.bin" "$check/critical-fortran.bin"
"$check/critical" replay .runtime/openifs/runs/strict-srtm25-source-7207705/t21/test_fc/srtm25-inputs.bin "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp "$check/replay-fortran.bin" "$check/replay-assembly.bin"
cmp .runtime/openifs/runs/strict-srtm25-source-7207705/t21/test_fc/srtm25-fortran.bin "$check/replay-fortran.bin"
```
