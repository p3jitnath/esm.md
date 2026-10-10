# Supported OpenIFS LAITRI Interpolation

Documentation revision 1.2 adds the independently reviewed parent forecast and retains the frozen numerical revision 1.0. The contract freezes the complete 32-neighbour interpolation for clipping flags zero, one, two and three before direct emission. The separate original flag minus one conservation correction is excluded and is not replaced by this release. All eighteen ordinary pointer arguments, complete arrays, optional presence, ordered arithmetic and returned bytes are declared below.

## Physical Meaning

The [atmospheric-motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), especially P01, describes change following air motion. A weather model traces each moving air parcel to its earlier position and estimates the field there from nearby grid samples. LAITRI combines samples in longitude, latitude and height, using four local levels and four latitude rows. The two middle levels use twelve samples each, and the two outer levels use four samples each, giving thirty-two samples.

The caller supplies indices and dimensionless interpolation coefficients. Fields retain their caller's unit, such as metres per second for wind. A two-sample estimate follows a straight local trend. A four-sample estimate follows a curved trend, while an optional clip limits an estimate to its central neighbours. This numerical reconstruction adds no new physical equation.

## Arguments and Storage

All eighteen arguments are ordinary pointers, with no array descriptor or hidden length. The first eight point to signed 32-bit integers. Real values use binary64, the 64-bit floating-point format. Define `A=KSLB1`, `B=KPROMA`, `L=KFLEV`, `F=KFLDX-KFLDN+1` and `C=B*L`.

| Argument | Complete Shape or Meaning |
| --- | --- |
| `KSLB1,KPROMA` | Source-plane size `A` and output-row size `B` |
| `KST,KPROF` | First and last selected output row, inclusive |
| `KFLEV` | Output-level count `L` |
| `KFLDN,KFLDX` | First and last source-plane labels |
| `KQM` | Supported clipping flag from zero through three |
| `PDLAT` | `(B,L)` latitude fraction for the two outer levels |
| `PCLA` | `(B,L,3)` latitude coefficients for the middle levels |
| `PDLO` | `(B,L,0:3)` longitude fractions |
| `PCLO` | `(B,L,3,2)` middle-row longitude coefficients |
| `KL0` | `(B,L,0:3)` signed source base indices |
| `PVINTW` | `(B,L,3)` vertical coefficients |
| `PXSL` | `A*F` complete source values |
| `PXF` | `(B,L)` complete output field |
| `PRDETAR` | Optional `L`-value input, unused by the supported flags |
| `LDQM3DCONS` | Optional 32-bit logical input, unused by the supported flags |

An absent optional argument has a null pointer. Present optional arrays and logical values remain unchanged, including arbitrary real bits. No supported calculation reads them. The original `LOPT_RS6K` global is a 32-bit logical that selects scalar or row-pass source organization. Both settings produce identical complete critical returns. The direct body needs no numerical global because these organizations have the same per-point arithmetic.

Rows are stored fastest. For zero-based row `r` and output level `j`, use `p=r+B*j`. The coefficients occupy complete row-fast planes with plane stride `C`. Latitude and vertical coefficients use `p+t*C` for `t=0,1,2`. Longitude fractions and base indices use `p+s*C` for latitude side `s=0,1,2,3`. Cubic longitude coefficients use `p+((s-1)*3+t)*C` for `s=1,2`.

Let `k_s=KL0[p+s*C]` and let `v=0,1,2,3` identify the local vertical level. Each index below is zero based and corresponds to one original source access.

| Latitude Side and Local Level | Source Indices |
| --- | --- |
| Outer sides `s=0,3` at `v=1,2` | `k_s+v*A` and `k_s+v*A+1` |
| Middle sides `s=1,2` at `v=0,3` | `k_s+v*A` and `k_s+v*A+1` |
| Middle sides `s=1,2` at `v=1,2` | `k_s+v*A-1` through `k_s+v*A+2` |

There is no source access for an outer side at an outer local level. Negative base indices on outer sides are valid when all used indices remain inside the complete source field. The caller's base indices already select the source level, while plane labels define capacity only.

Require nonnegative signed 32-bit `A,B,L`, with `B,L < INT32_MAX`, `3*A+3 <= INT32_MAX`, `6*B*L <= INT32_MAX` and `A*F <= INT32_MAX`. Require `1 <= F <= INT32_MAX` and a source-plane label difference that fits signed 32-bit arithmetic. The typed original probe confirms that its index kind `JPIA` is also 32 bits, so these bounds protect all original offset calculations.

Require `1 <= KST <= B+1`, `0 <= KPROF <= B` and flag zero through three. Empty selected intervals, zero rows and zero levels perform no update. Each selected thirty-two-neighbour index must lie from zero through `A*F-1`. Each complete extent and address must fit its allocated object and the machine address range. Integer objects need four-byte alignment, and real arrays need eight-byte alignment.

The complete output is disjoint from all inputs, including present optional arguments. All input scalars and arrays remain unchanged. Used coefficients and samples are finite, and every ordered intermediate is finite. Require `maximum_corner*gain < DBL_MAX/32`, using the gain below, as a conservative finite-intermediate bound. Unused input and incoming inactive output may contain arbitrary bits, including NaNs. Every inactive output cell retains those bits.

Source and native comparison guards reject unsupported flags before either numerical body executes. A private caller-compatible execution trap proves this for minus one, four and both signed 32-bit extremes. The assembly also returns before numerical array reads for an unsupported flag, with no field update. This early return is an interface guard, rather than an implementation of an excluded original flag.

## Frozen Arithmetic

`RN` means one binary64 operation rounded to nearest with ties to even. The caller establishes a zero Arm floating-point control register, or FPCR, before entry, and the callee leaves it unchanged. Preserve gradual underflow and signed zeros. Use separate subtraction, multiplication and addition, with no fused operation, contraction, reassociation, reduced precision, approximate arithmetic or fast-math.

```text
linear(a,b,x) = RN(a + RN(x * RN(b-a)))

cubic(a,b,c,d,w1,w2,w3)
    term1 = RN(w1 * RN(b-a))
    value1 = RN(a + term1)
    term2 = RN(w2 * RN(c-a))
    value2 = RN(value1 + term2)
    term3 = RN(w3 * RN(d-a))
    result = RN(value2 + term3)

clip(value,a,b)
    lo = MIN(a,b)
    hi = MAX(a,b)
    result = MAX(lo,MIN(hi,value))
```

For each point, first compute the twelve longitude estimates. At each middle local level, use `linear` on the two outer latitude sides and `cubic` on the two middle sides. At each outer local level, use `linear` on the two middle latitude sides only. When the horizontal clip is enabled, finish each middle-side cubic clip against its two central samples before using that value in latitude.

Next compute four latitude estimates `z0,z1,z2,z3`. Use `linear` with `PDLAT[p]` on the middle latitude sides at the two outer levels. Use `cubic` with the three `PCLA` coefficients on all four latitude sides at the two middle levels. When the horizontal clip is enabled, clip each middle latitude estimate against its two middle-side longitude estimates.

Finally compute `cubic(z0,z1,z2,z3,PVINTW[p],PVINTW[p+C],PVINTW[p+2*C])`. When the vertical clip is enabled, clip this result against `z1,z2`, then write the selected output cell. Each cubic keeps its original left-to-right partial sums.

| Flag | Horizontal Clips | Final Vertical Clip |
| --- | --- | --- |
| Zero | None | None |
| One | Four longitude and two latitude clips | None |
| Two | Four longitude and two latitude clips | One |
| Three | None | One |

The point update has ninety-three separately rounded operations, comprising thirty-one subtractions, multiplications and additions each. Each enabled clip has four minimum/maximum selections. Flag two uses seven clips, while flag one uses six and flag three uses one. Source row-pass and scalar organizations may order independent point work differently, while retaining each point's dependencies. No numerical helper is needed for the supported flags.

All selected operands are finite. Unequal values use numerical ordering, and equal nonzero values have the same bits. The typed original-toolchain probe gives negative zero for `MIN(+0,-0)` and `MIN(-0,+0)` and positive zero for both corresponding `MAX` calls. A same-sign zero pair retains its sign. The complete original critical body also passes 14,384 exact negative-zero values. Preserve each zero bit through the ordered arithmetic and clips. Profiling, wall-clock records and floating-point exception-status flags are outside canonical field output.

## Independent Source Physics

The independent reference expands each linear estimate into weights `(1-x,x)` and each cubic estimate into `(1-w1-w2-w3,w1,w2,w3)`. It multiplies weights by their samples and sums at higher precision, rather than repeating the source's rounded difference-and-add tree. It separately applies each supported horizontal and vertical clip. Without clips this is a thirty-two-sample polynomial, and clipping makes it a continuous piecewise polynomial. A clip increases an input error by no greater than that error's size.

Freeze the absolute error limit below. `epsilon=2^-52` is binary64 spacing above one, `minimum_normal=2^-1022` is its smallest positive normal number and `minimum_positive=2^-1074` is its smallest positive number. `maximum_corner` is the largest absolute used sample. Gains have no unit, while the limit has the field's unit.

```text
each_gain = 1 + 2*sum(abs(nonbase coefficients))
gain = max(longitude gains) * max(latitude gains) * vertical gain
limit = 1024*epsilon*max(maximum_corner,minimum_normal)*gain
        + 512*minimum_positive*gain
```

A linear fraction is its one nonbase coefficient. The gain covers each rounded difference, product and partial sum, with a conservative margin for ninety-three operations and gradual underflow. Independent acceptance complements exact bytes.

Before emission, 1,152 complete original cases pass 211,344 independently expanded values at 100 decimal digits, 739,704 independent clip operations and 52,836 eight-central-neighbour bounds. They also pass 14,384 exact constants, 14,384 closed-form affine coordinates, 14,384 exact endpoints and 14,384 exact negative-zero values. All 576 whole-return pairs directly agree across the two original layout settings. The corpus covers all four flags, absent and present optional inputs, partial and empty work, zero levels, signed plane labels, signed outer bases, both source ends, repeated gathers, extrapolation, subnormals, large values, unused NaNs and full guard/inactive storage. Its largest error is 0.000048 of the fixed limit.

## Complete Actual Original Capture

The fresh original-only T21 forecast captures all 4,300 calls. Every call comes from original LAITRE_GMV, with source-relative return address `0x14814c`. The actual shape is `A=3101,B=24,L=19,KST=1,KFLDN=0,KFLDX=20`, clipping flag one, original layout false and both optional arguments absent. There are 4,250 full twenty-four-row calls and fifty eight-row calls. The caller passes its complete declared `POUT(B,L)` unsliced, with the full declared source view, index planes and contiguous coefficient planes.

Every one of 1,945,600 active values passes an independently expanded reference at 113-bit precision, about thirty-four decimal digits, with 11,673,600 independent horizontal clips. The largest error is 0.000111 of the fixed limit. All selected data are finite, and the largest `maximum_corner*gain` is 2,379.186, far below the finite-intermediate bound.

The complete incoming archive has 2,554,853,600 bytes, and complete returned records have 16,649,600 bytes. All ten saved files directly match the canonical strict original run across 618,140 bytes. These scientific checks cover the supported interpolation body. Other forecast stages have separate acceptance.

## Arm Interface and Canonical Bytes

The application binary interface, or ABI, defines argument passing and preserved machine state. Registers `x0:x7` receive the eight integer pointers. Incoming stack byte offsets zero through seventy-two, in steps of eight, hold `PDLAT,PCLA,PDLO,PCLO,KL0,PVINTW,PXSL,PXF,PRDETAR,LDQM3DCONS`. Preserve `x19:x29`, the stack pointer, return link, the low 64 bits of `v8:v15` and FPCR. Do not use reserved `x18`. The target is Armv8-A with Advanced SIMD.

The primary owns all thirty-two sample reads, ninety-three arithmetic operations, supported clips and selected writes. A driver loads inputs and allocates storage, with no omitted numerical stage. An ABI-only wrapper may forward all ten stack pointers while leaving required preserved registers visible to an independent probe.

Critical files start with a 64-byte `LAIRCR01` header. Each 224-byte `LAIRCS01` record header retains case number, eight integers, profile, two optional-presence flags, original layout setting and complete extents. Input payload order is latitude fractions, latitude coefficients, four longitude fractions, six longitude coefficient planes, four signed index planes, vertical coefficients, complete source field, whole incoming output with eight-cell prefix/suffix guards and any present optional array and logical. Returned records retain the header and full physical output allocation. Independent `LAIRIN01` records retain the header, complete higher-precision truth rounded once for checking and complete frozen limits.

Actual records use 224-byte `LAITRF01` headers, replacing profile with caller kind and retaining the source-relative return address. Their payload has the same order without added guards. All integers and binary64 values use little-endian order. Preserve headers, inactive cells and every declared output bit.

All same-input critical and captured replays, complete source/native pairs, checkpoints and final files require zero differing bytes. Fresh forecasts may have different opaque incoming inactive storage, which must be disclosed through complete raw comparisons and a frozen-input replay. Do not round, mask or normalise any bit. The supported native body now passes the checks below. No comparative timing has been performed.

## Complete Supported Native Acceptance

The unchanged first direct body has 304 instructions and 1,216 bytes. It owns all thirty-two source reads, ninety-three separately rounded operations, up to seven clips and every selected write. It has no numerical helper, allocation or stack frame, and it touches no callee-saved register or reserved `x18`.

All 1,152 protected critical cases pass zero differences across 2,246,720 complete returned bytes and all 211,344 independent values. The 1,159 direct ABI calls include the numerical cases, three genuine concurrent calls and four unsupported-flag early-return checks. Complete optional inputs, inactive cells and guards retain their bits. Both original layout settings were checked before emission.

Replay of all 4,300 complete frozen original inputs passes zero differences across 16,649,600 returned bytes. The isolated native forecast also passes every complete same-input original/native pair and all 1,945,600 independent values, with 11,673,600 independent clips. All ten saved files match both the original run and canonical forecast across 618,140 bytes.

The separate fresh source/native returned streams also directly agree across all 16,649,600 bytes in this run. Their complete incoming archives differ in 11,928,200 unused source bytes and 133,000 inactive index bytes. A full audit directly checks all 62,259,200 declared sample reads and every selected coefficient, fraction and index, with zero differences. The first changed source sample is index 55,129 in call one, which that call does not read. Whole incoming-input identity is not claimed. Every raw bit remains in the complete captures, and no output or input is masked or normalised.

Source and native observer guards reject four unsupported flags through independent execution traps before either numerical body. Both record-verifier modes also reject each malformed flag header before loading its numerical payload. The primary's four direct ABI checks return before numerical array reads when every other pointer is null. These interface checks do not extend numerical acceptance to the excluded conservation branch.

The parent combined forecast also accepts all 4,300 complete paired returns, 1,945,600 independently checked active values and 11,673,600 clipping operations. Its active values directly match the original source run. Complete same-input pairs and the unchanged frozen-input replay preserve every unused storage byte. Across the observed routines, thirty-eight complete paired output streams match over 4,618,278,408 bytes, and ten saved files match over 618,140 bytes.

## Reproduction

Use own exclusive job `7207705` on `nid011311` through `srun --jobid=7207705 --overlap --exact -N1 -n1 -c33 --cpu-bind=map_cpu:32 --mem-bind=local bash -lc '<command>'`. Load `PrgEnv-gnu`, `gcc-native/12.3` and `libfabric/2.3.1`, and run from the repository root. Full forecasts add `--mpi=cray_shasta` and use one process and thread.

```sh
task_dir=.runtime/openifs/laitri-7207705/public-reviewed
gcc -fPIC -march=armv8-a+simd -c src/openifs/dynamics/laitri.S \
    -o "$task_dir/laitri.o"
gcc -fPIC -march=armv8-a+simd -DLAITRI_ABI_PROBE \
    -c src/openifs/dynamics/laitri.S -o "$task_dir/laitri-abi.o"
gcc -fPIC -march=armv8-a+simd -c bench/openifs/dynamics/vertical_abi.S \
    -o "$task_dir/vertical-abi.o"
gcc -O2 -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
    -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laitri.c \
    "$task_dir/laitri-abi.o" "$task_dir/vertical-abi.o" -lm \
    -o "$task_dir/verify"
OMP_NUM_THREADS=1 OMP_DYNAMIC=FALSE "$task_dir/verify" \
    .runtime/openifs/laitri-7207705/preparation/critical-inputs.bin \
    .runtime/openifs/laitri-7207705/preparation/critical-fortran.bin \
    .runtime/openifs/laitri-7207705/preparation/critical-independent.bin \
    "$task_dir/assembly.bin" "$task_dir/summary.json"
gcc -O2 -mcpu=neoverse-v2 -fPIC -shared -fopenmp -ffp-contract=off \
    -fno-fast-math -Wall -Wextra -Werror \
    .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laitri_forecast.c "$task_dir/laitri.o" \
    -ldl -lm -o "$task_dir/libverify-laitri.so"
```

The verifier's `--actual INPUT SOURCE NATIVE SUMMARY` mode replays `laitri-inputs.bin` and `laitri-fortran.bin` from `.runtime/openifs/runs/strict-laitri-source-complete-7207705/t21/test_fc`. The isolated forecast launch is retained in `.runtime/openifs/laitri-7207705/build/isolated-forecast-command.sh`, with all exact source, emission, verification and publication commands in `commands-release.json` beside sealed `accepted.json`. The comparator defines only `laitri_` and `laitri_assembly_`, with no SPCM scope relay or numerical dependency. A parent forecast can add it while retaining the existing sole SPCM relay.

Use `-DLAITRI_SOURCE_ONLY` without an assembly object to build the source-only observer. Its frozen launch uses only this observer, the immutable original vertical reference and strict pressure math. Instrumented forecast durations include capture and independent science, so they are not accepted performance measurements.
