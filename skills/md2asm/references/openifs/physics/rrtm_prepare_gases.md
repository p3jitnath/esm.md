# OpenIFS Gas Preparation

Numerical revision 1.0 freezes the complete `RRTM_PREPARE_GASES` numerical body before assembly generation. This routine prepares atmospheric pressure, temperature and gas amounts for the longwave radiation model. Longwave radiation is the heat that the Earth emits. Documentation revision 1.2 adds the measured bounded zero-store implementation and its combined acceptance record. The source and its one forecast caller remain unchanged, and the [OpenIFS rules](../../../../../bench/openifs/README.md) apply.

## Physical Meaning and Units

A layer has pressure difference $`\Delta p`$ in Pa and gravitational acceleration $`g`$ in m s$`^{-2}`$. The hydrostatic relation, which balances pressure and weight, gives its mass per unit area $`m`$ in kg m$`^{-2}`$. Specific humidity $`q`$ is water mass divided by total moist-air mass. Thus the exact dry and water masses are $`m_{\rm d}`$ and $`m_{\rm w}`$.

```math
m=\frac{\Delta p}{g},\qquad m_{\rm d}=(1-q)m,\qquad m_{\rm w}=qm.
```

The legacy source uses dry-air molar mass $`M_{\rm d}=28.970`$ and water molar mass $`M_{\rm w}=18.0154`$, both in g mol$`^{-1}`$. A molar mass is the mass of one mole of molecules. It retains Avogadro's constant $`N_{\rm A}=6.02214\times10^{23}`$ molecules mol$`^{-1}`$. These source constants are frozen, rather than updated to newer values.

The source first estimates the water volume ratio $`w`$ and a mixture molar mass $`M`$. It then obtains the dry molecular column $`N_{\rm d}`$, measured in molecules cm$`^{-2}`$. The factor 0.1 converts kg m$`^{-2}`$ to g cm$`^{-2}`$. Each source operation rounds separately, as specified below.

```math
w=q\frac{M_{\rm d}}{M_{\rm w}},\qquad M=(1-w)M_{\rm d}+wM_{\rm w},\qquad N_{\rm d}=\frac{0.1mN_{\rm A}}{M(1+w)}.
```

This is a legacy wet-air approximation. It is not exact conservation of moist mass. To quantify its mathematical error, define $`C`$ and $`D`$ below. Converting the returned dry and water molecule counts back to mass gives the stated ratios to the exact masses.

```math
C=\frac{(M_{\rm d}-M_{\rm w})M_{\rm d}}{M_{\rm w}^2},\qquad D=1+q-Cq^2,
\qquad
\frac{m_{\rm returned}}{m}=\frac{1+q}{D},\qquad
\frac{m_{{\rm d,returned}}}{m_{\rm d}}=\frac{1}{(1-q)D},\qquad
\frac{m_{{\rm w,returned}}}{m_{\rm w}}=\frac{1}{D}.
```

The table gives the largest relative errors. A plus sign means too much mass, and a minus sign means too little. The formula bounds cover $`0\le q\le0.05`$. The capture row was independently checked from every complete original return. Dry air, where $`q=0`$, has zero mathematical correction error.

| Evidence | Total moist mass | Dry mass | Water mass |
| --- | --- | --- | --- |
| Legacy formula through $`q=0.05`$ | +0.23335665% | +0.48456807% | −4.53966033% |
| All 972,800 captured forecast layers | +0.0612006974% | +0.1254161123% | −2.4102485208% |

The captured humidity ranges from $`9.999999999940612\times10^{-9}`$ to $`0.025324884844875363`$. Separate arithmetic edge cases retain the smallest FP64 humidity and gradual underflow, which means that very small values remain available instead of becoming zero automatically. The minimum-subnormal humidity case has +24.37279945% relative returned water error because its intermediate volume ratio rounds to a few representable values. This is a rounding edge, not a physically accurate tiny-water forecast. Its absolute water mass is negligible. The verifier reports it separately and never rounds or hides output bits. The assembly reproduces the existing approximation and does not silently correct its science.

## Inputs and Complete Outputs

The four integer inputs are `KIDIA`, `KFDIA`, `KLON` and `KLEV`, which give the first selected column, last selected column, full input width and layer count. Let $`L={\tt KLON}`$, $`H={\tt KLEV}`$ and $`n={\tt KFDIA}-{\tt KIDIA}+1`$. Input arrays have first dimension $`L`$, while every output has compact first dimension $`n`$. The first output element represents `KIDIA`. Column index changes fastest in memory.

| Input | Complete shape | Meaning and units |
| --- | --- | --- |
| `PAPH`, `PTH` | $`L(H+1)`$ | Interface pressure in Pa and temperature in K |
| `PAP`, `PT` | $`LH`$ | Layer pressure in Pa and temperature in K |
| `PQ` | $`LH`$ | Specific humidity in kg kg$`^{-1}`$ |
| `PCO2`, `PCH4`, `PN2O`, `POZN` | $`LH`$ each | Carbon dioxide, methane, nitrous oxide and ozone mass ratios in kg kg$`^{-1}`$ |
| `PC11`, `PC12`, `PC22`, `PCL4` | $`LH`$ each | Four trace-gas mass ratios in kg kg$`^{-1}`$ |
| `PNO2` | $`LH`$ | Unused source argument whose complete input bytes remain unchanged |
| `RG`, `RPLRG` | One FP64 scalar each | Read-only gravity in m s$`^{-2}`$ and dimensionless planetary scale |

The input level order is top to bottom. Outputs reverse that order to bottom to top. `PZ` and `PTZ` include the extra lower boundary, numbered zero in the source. Pressure divides by 100 to become hPa, which is the same pressure unit as a millibar. Temperatures are copied without arithmetic.

| Output | Complete shape | Meaning and units |
| --- | --- | --- |
| `PCOLDRY` | $`nH`$ | Dry molecular column in molecules cm$`^{-2}`$ |
| `PWBRODL` | $`nH`$ | Molecular column of the remaining broadening gases in molecules cm$`^{-2}`$ |
| `PWKL` | $`n\times35\times H`$ | All 35 gas molecular columns in molecules cm$`^{-2}`$ |
| `PWX` | $`n\times4\times H`$ | All four trace columns scaled by $`10^{-20}`$, representing units of $`10^{20}`$ molecules cm$`^{-2}`$ |
| `PAVEL`, `PTAVEL` | $`nH`$ each | Reversed layer pressure in hPa and temperature in K |
| `PZ`, `PTZ` | $`n(H+1)`$ each | Reversed interface pressure in hPa and temperature in K |
| `KREFLECT` | $`n`$ 32-bit integers | All reflection flags set to zero |

`PWKL` channels 1, 2, 3, 4, 6 and 7 contain water, carbon dioxide, ozone, nitrous oxide, methane and oxygen. Channel 5 and channels 8 through 35 return positive zero. Oxygen uses the fixed source volume ratio 0.209488. `PWX` channels 1 through 4 contain `PCL4`, `PC11`, `PC12` and `PC22`. The source comment calls broadening amounts “mol/cm2”, but its Avogadro factor and the independent mass check establish molecules cm$`^{-2}`$.

Supported capacities satisfy $`1\le L\le4096`$, $`0\le H\le512`$, $`1\le{\tt KIDIA}\le L+1`$, and $`{\tt KIDIA}-1\le{\tt KFDIA}\le L`$. Empty selected columns have $`n=0`$ and no output cells. Zero layers still copy the surface interface and set reflection flags. All live FP64 arrays and global addresses are aligned to eight bytes. Integer arguments and the reflection array are aligned to four bytes. Inputs and dimensions are read-only. Each output is disjoint from every other output, input, integer and global. Caller-owned outputs are fully overwritten, so incoming uninitialised output values are not part of the numerical input.

The checked physical domain uses finite nonnegative increasing interface pressure, layer pressure between its interfaces, positive temperature, nonnegative gas mass ratios, $`0\le q\le0.05`$, and a non-water gas volume sum below one. Source arithmetic edge cases also exercise signed zero, extremely small humidity and trace gases, and tiny positive layer pressure. The source-only critical gravity range is 4.903325 to 19.6133 m s$`^{-2}`$, with planetary scales 0.5 and 1. The forecast uses 9.80665 m s$`^{-2}`$ and scale 1 throughout.

## Ordered FP64 Arithmetic

Let `RN` mean rounding one operation to FP64, using round-to-nearest with ties to even. The floating-point control register must be exactly zero at entry and return. Retain signed zeros and gradual underflow. Do not fuse multiply-add operations, regroup expressions, replace division with multiplication by a reciprocal, use approximate arithmetic, or reduce precision.

1. Compute gravity as `Gcgs = RN(RN(RG / RPLRG) * 100)`. Set every reflection flag and every cell of all 35 `PWKL` channels to positive zero.
2. Copy the bottom interface into output boundary zero. Compute pressure with `RN(PAPH / 100)` and copy temperature bits.
3. For output layer `k = 1..H`, read source layer `H-k+1`. Divide its full and interface pressures by 100, and copy both temperatures.
4. Convert gas mass ratios using `RN(RN(ratio * 28.970) / molar_mass)`. Store water, carbon dioxide, ozone, nitrous oxide and methane into their stated channels, and store oxygen 0.209488. Keep all other gas channels at their required zero.
5. With the stored rounded water ratio `w`, compute `M = RN(RN(RN(1-w)*28.970) + RN(w*18.0154))`. Compute `dp = RN(previous_stored_PZ-current_stored_PZ)`, `num = RN(RN(dp*1000)*6.02214e23)`, `den = RN(RN(Gcgs*M)*RN(1+w))`, then `PCOLDRY = RN(num/den)`.
6. Set every `PWX` cell to positive zero. Convert all four trace mass ratios with the same multiply-then-divide order, then store each scaled column as `RN(RN(PCOLDRY*stored_trace_ratio)*1e-20)`.
7. Start the gas volume sum at positive zero and add stored `PWKL` channels 2 through 7 in increasing channel order, rounding every addition. Store `PWBRODL = RN(PCOLDRY*RN(1-sum))`. Finally store channels 1 through 7 as `RN(PCOLDRY*stored_volume_ratio)`.

| Gas | Frozen molar mass in g mol$`^{-1}`$ |
| --- | --- |
| Carbon dioxide | 44.011 |
| Ozone | 47.9982 |
| Methane | 16.043 |
| Nitrous oxide | 44.013 |
| `PC11` | 137.3686 |
| `PC12` | 120.9140 |
| `PC22` | 86.4690 |
| `PCL4` | 153.8230 |

The actual source returns contain 786 cases where regrouping the water conversion changes the final bits and 718 cases where pressure multiplication by 0.01 differs from division by 100. The private witness record preserves these values. No comparison driver supplies a missing numerical stage.

## Arm Interface and Storage

The primary entry is `rrtm_prepare_gases_`. Verification gives the same complete body the private symbol `rrtm_prepare_gases_assembly_`. There are 27 ordinary pointer arguments, without descriptors or hidden arguments. The first eight pointers arrive in `x0` through `x7`. The remaining 19 pointers occupy consecutive eight-byte slots on the incoming stack.

| Argument positions, counting from zero | Arguments | Incoming location |
| --- | --- | --- |
| 0 through 3 | `KIDIA`, `KFDIA`, `KLON`, `KLEV` | `x0` through `x3` |
| 4 through 7 | `PAPH`, `PAP`, `PTH`, `PT` | `x4` through `x7` |
| 8 through 17 | `PQ` through `POZN` in original source order | Stack bytes 0 through 72 |
| 18 through 26 | All nine outputs in the table order | Stack bytes 80 through 144 |

The target is AArch64 Armv8-A. The body uses a 384-byte stack frame, with the incoming pointers in a private table. It preserves `x19` through `x30`, the lower 64 bits of `d8` through `d15`, stack alignment and the floating-point control register. It leaves `x18` untouched and calls no numerical helper. The only extra numerical inputs are the two declared gravity globals. Profiling hooks are outside the returned numerical state. The standalone source checker disables profiling because it has no MPI setup, while the unchanged full forecast keeps its normal profiling.

## Acceptance and Evidence

The source-only corpus contains 62 different complete shape/global/input records. Both start and end placement against protected pages give 124 calls and 1,664,592 complete returned bytes. Read-only pages protect all inputs and integer dimensions, while poisoned neighbours and inaccessible pages protect every complete output. The 212,156 independent relations check hydrostatic dry limits, the prescribed wet correction and its quantified error, reverse levels, pressure units, temperature copies, all gas and trace columns, broadening, zero channels, zero levels and empty selections. Returned states include 3,780 negative zeros and 16 nonzero subnormal values.

The unchanged source forecast gives 6,400 calls, 256 in each phase 0 through 24. Every call has `KIDIA=1`, `KFDIA=KLON=8` and `KLEV=19`, at the one original caller return offset `0xb1e9a4` in the frozen science image. Complete input capture is 110,080,000 bytes, and complete returned capture is 351,539,200 bytes. All 44,902,400 independent relations pass. All ten saved files directly match the canonical strict-vertical forecast across 618,140 bytes.

Canonical input and output records start with a 48-byte header, consisting of the call index as a little-endian 64-bit integer, phase and source-site integers, the four dimension integers, then the two FP64 gravity globals. Inputs append all 14 full arrays in argument order. Outputs append `PCOLDRY`, `PWBRODL`, `PWKL`, `PWX`, `PAVEL`, `PTAVEL`, `PZ`, `PTZ` and `KREFLECT` in complete column-first storage order. A returned record has $`48+n(360H+20)`$ bytes. No inactive input, zero output, boundary, or deterministic header is omitted.

Acceptance requires zero differing bytes for each complete native return, each complete critical stream, the independent pre-emission source capture, the full isolated input capture, and all ten saved files. Report the first call, phase, field, cell or byte and its bit patterns before stopping. Hashes identify preserved artifacts but do not replace direct comparison. The immediate ABI observer forwards all 27 pointers and checks saved integer and floating-point registers before C can restore them. The initial checkpoint established numerical correctness before comparative timing.

The independently reviewed combined forecast also passes every gas call and all its complete input and returned bytes against the pre-emission source-only archive. All thirty-two paired routine streams match across 3,645,868,808 returned bytes, and all ten saved files match across 618,140 bytes. The original wet-air approximation and its stated mass errors remain unchanged.

## Measured Zero-Store Optimisation

The selected body uses paired vector stores to write four positive-zero FP64 values at once. Each pair is issued only when four complete cells remain. A scalar tail writes the remaining PWKL cells, while the PWX extent is already a multiple of four. The complete zero stages still finish before their numerical consumers. Their buffers are disjoint, the empty-shape returns remain valid and no stronger alignment is required. All floating-point instruction operands, constants and ordered dependencies are unchanged. The body has 291 instructions and the same 384-byte frame.

The complete gas call was measured on four frozen forecast states at phases 0, 8, 16 and 24. Each state has eight columns and nineteen levels. Own exclusive job 7207705 used nid011311, CPU 8, local memory binding and the same 64-byte-aligned physical arrays for all variants. Local binding and first touch were used, while physical page placement was not separately measured. Both quiet checks found zero activity on other CPUs and a one-minute load of 0.0615. The unchanged Fortran control uses GNU 12.3, O2, the actual CPU target and strict separate arithmetic.

A nanosecond, abbreviated ns, is one billionth of a second. Each measurement has thirty-two warm calls, then 256 complete calls per variant in each of twelve accepted rotations. The timer surrounds only a complete call. Initialisation, scientific checks and complete final-state comparisons remain outside it. Every accepted pair favours the selected body at all four states. Whole-call paired gains are 1.53 times the previous assembly and 1.30 to 1.31 times the Fortran control.

| Phase | Fortran Median, ns | Previous Assembly Median, ns | Selected Median, ns | Selected Range, ns |
| --- | ---: | ---: | ---: | ---: |
| 0 | 3316.812 | 3874.562 | 2530.250 | 2523.875–2608.125 |
| 8 | 3307.625 | 3871.875 | 2529.250 | 2527.500–2566.125 |
| 16 | 3317.500 | 3873.375 | 2527.750 | 2522.625–2571.750 |
| 24 | 3305.688 | 3873.875 | 2531.625 | 2525.250–2550.500 |

The compact record preserves variation for every variant and all raw rotations. Thirty-six whole-call rows and two component rows belong to rotations disturbed by context switches, so those complete rotations remain archived outside the accepted statistics. The matched zero-stage probes explain the reduced store-loop cost. They are component costs, with cache effects and timing overhead, and do not establish a hardware or DRAM bound. These warmed-call results support this workload and target. Whole-forecast comparative performance remains unmeasured.

All 124 protected critical calls and immediate ABI checks pass with unchanged complete bytes and independent relations. The selected parent forecast also matches all complete gas inputs and returns against the frozen source run. All thirty-four paired streams match across 4,081,782,408 returned bytes, and all ten saved files match across 618,140 bytes.

## Reproduction

The local immutable release lives under `.runtime/openifs/rrtm_prepare_gases_7207705/`. Its pre-emission manifest freezes the original source and caller hashes, strict library, arithmetic, scientific limits, corpus, complete source captures and source-only checks. Original failed standalone profiling evidence remains private. No numerical compiler assembly or intermediate representation is used to construct the direct body.

Run this block through srun inside your verified exclusive allocation, on a free CPU with local memory placement. It builds the emitted source with an assembler, checks complete numerical outputs and ABI obligations, then directly compares both complete critical streams.

```bash
set -euo pipefail
ulimit -c 0
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
release="$PWD/.runtime/openifs/rrtm_prepare_gases_7207705"
check="$release/reproduction"
mkdir -p "$check"
gcc -fPIC -march=armv8-a+simd -DORIGINAL_SYMBOL=rrtm_prepare_gases_assembly_ -c src/openifs/physics/rrtm_prepare_gases.S -o "$check/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -DGASES_ABI_OBSERVER bench/openifs/physics/rrtm_prepare_gases.c "$check/assembly.o" -L.runtime/openifs/strict-build/lib -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -larpifs.DP -lfiat -lm -ldl -o "$check/critical"
"$check/critical" "$release/frozen/corpus.bin" "$check/fortran.bin" "$check/assembly.bin"
cmp "$check/fortran.bin" "$check/assembly.bin"
cmp "$release/preparation/critical-fortran-frozen.bin" "$check/fortran.bin"
```

The original source SHA-256 is 5de1deb6ebb01671a2129134344a7d206f26b1eec565380b4305e8fb1920a725, and the original caller SHA-256 is 352e48ae31e27cd69e8e25706812507cbcc08dcd962c10d13536bfd26fa1861d. The strict science image SHA-256 is 8e4966877c735976f1e9356bc551294bbfc15c565ecdf1dc7db4cf814012b07b.

The [complete-call timing tool](../../../../../bench/openifs/physics/rrtm_prepare_gases_timing.c) uses the preserved earlier body and selected public source. Its build command is recorded under `zero-fill-tuning/publication/public-build-and-critical-command.sh` in the local release. The original and rebuilt timing executable have byte-identical instruction and constant sections. After rebuilding, pause other node work and execute `publication/reproduction/timing timing-corpus.bin` from the tuning directory through srun on CPU 8, with the same quiet checks and local memory binding. The frozen four-state timing corpus, full raw rows, quiet records, summaries and commands remain in that archive.
