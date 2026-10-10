# Fu longwave ice optical properties

Revision 1.1 adds combined acceptance and interface detail while preserving the numerical contract frozen at revision 1.0 for the complete original `radiation_ice_optics_fu::calc_ice_optics_fu_lw` body, at lines 70–112 of `radiation/module/radiation_ice_optics_fu.F90`. It describes how ice water and particle size determine the optical properties in each longwave band. A band is one interval of light wavelengths. The underlying model is [Fu, Yang and Sun (1998), *An Accurate Parameterization of the Infrared Radiative Properties of Cirrus Clouds for Climate Models*](https://journals.ametsoc.org/view/journals/clim/11/9/1520-0442_1998_011_2223_aapoti_2_0_co_2.xml). The model relates ice amount and effective particle size to extinction, absorption and scattering. This contract freezes the original OpenIFS fit and its unit conversions; it does not claim a new validation of the fitted coefficients against observations.

The input ice water path $`I`$ is the mass of ice per unit horizontal area, in kg m$`^{-2}`$. The effective radius $`r`$ is in metres. The outputs are total optical depth $`\tau`$, scattering optical depth $`\tau_s`$ and asymmetry factor $`g`$. Optical depths are dimensionless measures of interaction with light. The asymmetry factor is the mean cosine of the scattering angle; its physical range is $`[-1,1]`$.

## Frozen source and callers

The source coefficient table has eleven columns and at least `nb` rows. The configured caller in `radiation_cloud_optics.F90` lines 398–412 selects the Fu model and calls this longwave body at line 400 when in-cloud ice water is positive. Source setup lines 97–123 checks the band count and eleven-column capacity. The table is read, with matrix transposition, by `radiation_cloud_optics_data.F90` lines 80–87. The caller supplies three complete arrays of the configured longwave band count; the helper overwrites all their elements. The separate shortwave helper and the caller compatibility transform are outside this body.

The frozen current strict source-only forecast observes 223,175 calls, with 16 bands each, at original library return offset `0xb07668`. Every call captures the full 16 by 11 coefficient table, both input scalars and all three incoming and returned output arrays. All ten saved forecast files directly match `strict-vertical-fortran-7189435`, with zero differing bytes. The earlier complete compiler trace observes 223,313 calls to this body. That historical trace remains separate because the current ordered-vertical reference has a different call schedule.

The physical radius domain established by the current table capture is $`1.4911010295275469\times10^{-5}\leq r\leq1.006756\times10^{-4}`$ m. The observed ice water path is $`1.4362613663585699\times10^{-11}\leq I\leq4096.0398913412737`$ kg m$`^{-2}`$. Zero ice water and manufactured tables extend the critical checks to no-ice and known optical states. Numerical edge cases with signed zero, subnormal numbers and a radius of 0.1 m test arithmetic and storage only; they do not establish a physical ice-particle domain outside the captured range.

## Ordered FP64 arithmetic

Each input and each coefficient uses IEEE binary64, called FP64 here. Each operation rounds separately with round-to-nearest and ties to even. The Arm floating-point control register (FPCR) must be exactly zero on entry and remain zero. Gradual underflow and signed zeros are preserved. The primary body uses no fused operation, contraction, reassociation, approximate reciprocal or FP32 arithmetic. All accepted coefficients, scalars and intermediate results are finite, and radius is strictly positive. The original span and type metadata are required, and each logical row and column referenced by this body must lie within its declared bounds. Non-finite inputs and overflow are outside the declared domain.

Freeze the source constant division first: $`K=\operatorname{round}(1000000/0.64952)`$. Its binary64 encoding is `0x41377e0e79041148`. Compute the effective diameter in micrometres as $`D=\operatorname{round}(rK)`$, its inverse as $`V=\operatorname{round}(1/D)`$ and ice mass in g m$`^{-2}`$ as $`W=\operatorname{round}(1000I)`$. The first conversion multiplies by the already rounded ratio; it must not compute $`(r\,1000000)/0.64952`$.

For band $`b`$, coefficient $`c_j`$ means row $`b`$, column $`j`$. Its units follow the diameter $`D`$ in micrometres and water mass $`W`$ in g m$`^{-2}`$. The units of columns 1, 2 and 3 are m$`^2`$ g$`^{-1}`$, m$`^2`$ g$`^{-1}`$ μm and m$`^2`$ g$`^{-1}`$ μm$`^2`$. Columns 4, 5, 6 and 7 have units m$`^2`$ g$`^{-1}`$ μm, m$`^2`$ g$`^{-1}`$, m$`^2`$ g$`^{-1}`$ μm$`^{-1}`$ and m$`^2`$ g$`^{-1}`$ μm$`^{-2}`$. Column 8 is dimensionless, and columns 9, 10 and 11 have units μm$`^{-1}`$, μm$`^{-2}`$ and μm$`^{-3}`$.

Compute these complete array stages in the following order. Every multiplication, addition and subtraction below has its own FP64 rounding point.

```math
\begin{aligned}
\tau_b &= W\,[c_1+V(c_2+V c_3)],\\
P_b &= c_4+D[c_5+D(c_6+D c_7)],\\
B_b &= (W V)P_b,\\
(\tau_s)_b &= \tau_b-B_b,\\
G_b &= c_8+D[c_9+D(c_{10}+D c_{11})],\\
g_b &= \min(G_b,1).
\end{aligned}
```

The first stage fills all total depths. The second stage computes absorption depth $`B_b`$ and subtracts it from each stored total depth to fill the scattering depths. Form $`WV`$ before multiplying by $`P_b`$. The third stage fills all asymmetry factors. The rightmost multiplication is evaluated first in each nested polynomial. The minimum preserves the computed value below one, including negative zero; values above one produce exactly positive one. The cap does not assert that arbitrary coefficient tables have physically admissible optical properties.

The caller can separately replace the returned longwave scattering depth by `od_lw_ice-scat_od_lw_ice` when `do_fu_lw_ice_optics_bug` is enabled, at source lines 404–407. That compatibility transform stays in the original caller. This leaf never implements it or changes the returned scattering definition. Exact source/native comparison applies before the caller transform.

## ABI and buffers

An application binary interface (ABI) defines arguments and saved-register rules. This AArch64 interface passes seven ordinary argument addresses: `x0` points to a signed 32-bit `nb`, `x1` points to a GNU rank-two FP64 descriptor, `x2` points to `I`, `x3` points to `r`, and `x4`, `x5`, `x6` point to contiguous total-depth, scattering-depth and asymmetry arrays. There are no incoming stack arguments. The descriptor is 88 bytes. Its element length at byte 16 is eight, its GNU rank-two FP64 type word at byte 24 is `0x0000030200000000`, and its span at byte 32 is eight. Row lower and upper bounds are at bytes 48 and 56; column lower and upper bounds are at bytes 72 and 80. The configured table has 16 rows and 11 columns, while the critical cases also support surplus rows and shifted actual lower bounds. Its first word points to the first logical coefficient element. The row and column strides, at bytes 40 and 64, count FP64 elements. Logical row and column indices begin at one after dummy argument rebasing, so coefficient address `(b,j)` is `base+8*((b-1)*row_stride+(j-1)*column_stride)`. Descriptor offset and lower-bound metadata are preserved and do not change this rebased address rule. The storage-only GNU probe confirms the seven argument positions and first-element rule for contiguous, nonunit-row, reverse-row, nonunit-column and reverse-column tables.

Require a signed 32-bit band count between zero and INT32_MAX. All addressed offsets fit signed 64-bit integers and remain in the physical coefficient allocation. The first extent is at least nb and the second is at least eleven. Both input scalars remain valid with zero bands because the source converts them before the empty array stages. Support surplus coefficient rows, positive or negative row and column strides, and complete disjoint contiguous output arrays of `8*nb` bytes. The caller owns each complete physical table allocation. The scalar, descriptor and coefficient storage remain read-only. All FP64 addresses are eight-byte aligned. The helper preserves `x19`–`x29`, the low 64 bits of `v8`–`v15`, the incoming stack pointer and its 16-byte alignment; it does not use `x18`. The critical driver includes the direct saved-register observer as assembly in tracked C source. This observer checks immediately after the native call, before a C bridge could restore a damaged register.

## Independent acceptance

The frozen corpus has 366 cases. It covers widths 0, 1, 3, 14, 16, 17 and 24; five table layouts; surplus rows; constant and varying manufactured coefficients; zero and complete absorption; zero water; the configured full table; the cap below, at and above one; signed-zero outputs; nonzero subnormal outputs; and a conversion-order witness. Protected pages after each complete output and read-only input pages check declared capacities. The witness distinguishes `r*(1000000/0.64952)` from `(r*1000000)/0.64952` by both diameter and optical-depth bits.

A powers-based long-double calculation checks extinction as `c1+c2/D+c3/D²`, absorption as `W*(c4/D+c5+c6*D+c7*D²)`, and scattering as their difference. This uses a different algebraic evaluation from the nested source expression, independently checking the optical definitions. Manufactured coefficients give known total depth, exact no-absorption or complete-absorption limits and known capped asymmetry. Physical cases require finite outputs, nonnegative total and scattering depths, scattering no greater than total depth, and asymmetry within $`[-1,1]`$. The numerical tolerance is `8192*DBL_EPSILON*max(1,abs(expected))+8*DBL_TRUE_MIN` for the independent calculation; physical depth bounds use `256*DBL_EPSILON*max(1,abs(total)+abs(scattering))`. The exact comparison always requires zero differing bytes, including output guards, and has no tolerance or normalisation. The source-only corpus passes 4,006 independent band points and 2,881 physical band points before first assembly emission.

The complete-absorption manufactured input uses the next binary64 radius above `256/K`, so the source conversion gives diameter exactly 256 μm. The earlier rounded value `256/K` gives the next smaller diameter and produced scattering depth `-2^-47` instead of the asserted exact positive zero. That earlier source-only failure, corpus, ELF and diagnostic are preserved under `preparation/source-r1/`; the corrected input freezes the intended exact cancellation property without changing the original science source. This boundary example separates the physical tolerance from the zero-byte agreement requirement.

Final acceptance must compare all native critical output and guard bytes against the frozen source, then compare every isolated forecast return, the complete source-only return stream and all ten saved files directly. SHA256 hashes identify retained artifacts and do not replace byte comparisons. Combined forecast acceptance is recorded below. Comparative timing remains unfinished. This leaf does not include cloud preparation, gas optics, delta scaling, radiative transfer or shortwave optics.

## Generation and evidence

The direct solver was emitted from the frozen source equations and this contract, then assembled and linked. No numerical compiler assembly, intermediate representation or frontend statement dump is used before emission. Storage-only probes and symbol metadata establish the ABI and callers. After first emission, instruction inspection and source/native byte comparisons may check the result.

The immutable pre-emission contract, corpus, source hashes, command hashes, complete source-call capture and all ten direct file comparisons are indexed by `.runtime/openifs/calc_ice_optics_fu_lw/frozen/pre-emission-contract-corpus.json`. Raw inputs and outputs are kept under `.runtime/openifs/runs/strict-ice-fu-lw-source-7189435/t21/test_fc/`. Build, verification and profile collection use exclusive job 7189435 on `nid010825`, with one process and one thread, CPU 0 and local memory placement. They are verification work, not comparative timing.

## Combined forecast acceptance

The combined T21 historical forecast accepts all 223,175 original calls and 94,626,200 complete result-record bytes. The native stream also directly matches the source-only stream frozen before generation. Full coefficients, descriptors, scalar inputs and all three output capacities remain preserved, with unchanged inputs and FPCR zero at every entry. All 29 paired streams directly compare across 3,013,954,408 bytes, and all ten saved files match the strict Fortran baseline. Whole-forecast independent physics and comparative timing remain unfinished.

The [compact record](../../../../../src/openifs/README.md) identifies the frozen inputs, full capture, first emission and actual commands. The direct ABI observer is embedded in the [critical driver](../../../../../src/openifs/README.md). Run these commands through srun in a quiet exclusive allocation, with a fresh ignored output directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/calc_ice_optics_fu_lw/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -DORIGINAL_SYMBOL=calc_ice_optics_fu_lw_assembly_ \
  -c src/openifs/physics/calc_ice_optics_fu_lw.S -o "$check_dir/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/calc_ice_optics_fu_lw.c "$check_dir/assembly.o" \
  -L "$build_root/lib" -Wl,-rpath,"$build_root/lib" -larpifs.DP -lfiat -lm \
  -o "$check_dir/critical"
"$check_dir/critical" --verify \
  .runtime/openifs/calc_ice_optics_fu_lw/frozen/critical-corpus.bin "$check_dir/result"
cmp "$check_dir/result-fortran.bin" "$check_dir/result-assembly.bin"
cmp .runtime/openifs/calc_ice_optics_fu_lw/preparation/source-critical-fortran.bin \
  "$check_dir/result-fortran.bin"
gcc -O2 -mcpu=neoverse-v2 -fPIC -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  -c .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/calc_ice_optics_fu_lw_forecast.c \
  -o "$check_dir/forecast.o"
gcc -shared -Wl,-Bsymbolic "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -ldl -lm -o "$check_dir/libverify-ice-fu-lw.so"
```

Preload the complete source-scoped observer beside the accepted parent helpers in a fresh frozen forecast case. Compare every output stream and saved file directly. The observer performs no optical calculation.
