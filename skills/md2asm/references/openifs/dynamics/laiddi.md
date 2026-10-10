# Complete OpenIFS LAIDDI

Documentation revision 1.2 adds the independently reviewed parent forecast and retains the frozen numerical revision 1.0. The contract freezes the complete twelve-neighbour horizontal interpolation before direct assembly emission. Eight integer pointers and six array pointers define every input, source read, coefficient operation, clipping decision, returned cell and untouched byte.

## Physical Meaning

The [atmospheric-motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), especially P01, describes change following moving air. A weather model traces an air parcel to its earlier position, then estimates the field there from nearby samples. LAIDDI uses four latitude rows. The two outer rows contribute two longitude neighbours each, while each middle row contributes four, giving twelve samples.

The caller supplies the weights and neighbour indices. These weights have no unit. The field keeps its caller-defined unit, such as metres per second for wind, and interpolation retains that unit. A cubic estimate uses four samples to follow a curved local trend. Optional clipping limits the estimate to central neighbour values so that a local peak does not grow through interpolation alone. These weights are numerical inputs, rather than a new physical equation.

## Arguments and Complete Storage

All fourteen arguments are ordinary pointers, with no descriptor or hidden character length. The first eight point to signed 32-bit integers, in the order below. Real values use binary64, the 64-bit floating-point format. Define `A=KPROMA`, `B=KPROMB`, `L=KFLEV` and `F=KFLDX-KFLDN+1`.

| Argument | Complete Shape or Meaning |
| --- | --- |
| `KPROMA,KPROMB` | Source-plane size `A` and output-row size `B` |
| `KST,KPROF` | First and last selected output row, inclusive |
| `KFLEV` | Output-level count `L` |
| `KFLDN,KFLDX` | First and last source-plane labels |
| `KQM` | Zero disables clipping, while one enables all three clips |
| `PCLA` | `(B,L,3)` latitude coefficients |
| `PDLO` | `(B,L,0:3)` longitude fractions, of which outer planes zero and three are used |
| `PCLO` | `(B,L,3,2)` middle-row longitude coefficients |
| `KL0` | `(B,L,0:3)` signed source base indices |
| `PXSL` | `A*F` contiguous source values |
| `PXF` | `(B,L)` complete returned field |

Rows are stored fastest. For zero-based output row `r` and level `j`, use `p=r+B*j` and `C=B*L`. Latitude coefficients are at `p+t*C` for `t=0,1,2`. Longitude fractions and integer base indices use `p+s*C` for latitude row `s=0,1,2,3`. Middle-row coefficients use `p+((s-1)*3+t)*C` for `s=1,2` and `t=0,1,2`.

Let `k_s=KL0[p+s*C]`. The two outer latitude rows read zero-based source indices `k_s,k_s+1`. The middle rows read `k_s-1,k_s,k_s+1,k_s+2`. Thus the source's original one-based accesses are `k_s+1,k_s+2` for outer rows and `k_s:k_s+3` for middle rows. Source-plane labels affect the declared capacity only, while the caller's base indices already select the needed level.

Require nonnegative signed 32-bit sizes `A,B,L`, with `B,L < INT32_MAX`, `1 <= F <= INT32_MAX`, `6*B*L <= INT32_MAX` and `A*F <= INT32_MAX`. The source-plane label difference must also fit signed 32-bit arithmetic. Require `1 <= KST <= B+1`, `0 <= KPROF <= B` and `KQM` equal to zero or one. Empty selected intervals, zero rows and zero levels perform no field update.

For each selected point, require `0 <= k_s <= A*F-2` for outer rows and `1 <= k_s <= A*F-3` for middle rows. These bounds cover every source access and preserve the original integer calculations. Integer objects need four-byte alignment, and real arrays need eight-byte alignment. Each complete extent and byte address must fit its allocated object and the machine address range.

The complete output allocation is disjoint from every input. All eight integer arguments and all five input arrays remain unchanged. Used coefficients and source samples are finite, and every ordered arithmetic intermediate is finite. The accepted source corpus also satisfies `maximum_corner*gain < DBL_MAX/16`, which provides a conservative finite-intermediate bound. Unused fractions, indices, source cells and incoming inactive output may contain arbitrary bits, including NaNs. Every inactive output row retains its incoming bits.

## Frozen Ordered Arithmetic

`RN` means one binary64 operation rounded to nearest with ties to even. Require the Arm floating-point control register, or FPCR, to be zero before entry and unchanged at return. The caller establishes this setting before execution. This preserves gradual underflow and signed zeros. Use separate subtraction, multiplication and addition operations, with no fused operation, contraction, reassociation, reduced precision, approximate arithmetic or fast-math.

The outer-row function below uses two samples and one fraction. The middle-row and final latitude function use four samples and three nonbase coefficients. Every displayed `RN` is a separate rounding point.

```text
linear(a,b,x) = RN(a + RN(x * RN(b-a)))

cubic(a,b,c,d,w1,w2,w3)
    term1 = RN(w1 * RN(b-a))
    value1 = RN(a + term1)
    term2 = RN(w2 * RN(c-a))
    value2 = RN(value1 + term2)
    term3 = RN(w3 * RN(d-a))
    result = RN(value2 + term3)
```

For each output level and selected row, compute outer row `z0`, then middle row `z1` and its optional clip, then middle row `z2` and its optional clip, then outer row `z3`. Use `linear` for outer rows and `cubic` for middle rows, with their source samples and coefficients as defined above. The final latitude result is `cubic(z0,z1,z2,z3,PCLA[p],PCLA[p+C],PCLA[p+2*C])`, followed by the third optional clip.

For a middle row, define `lo=MIN(central_left,central_right)` and `hi=MAX(central_left,central_right)`, using its two central source values. When `KQM=1`, replace its cubic result `v` with `MAX(lo,MIN(hi,v))`. For the final latitude result, use `lo=MIN(z1,z2)` and `hi=MAX(z1,z2)` and the same ordered replacement. Finish each middle clip before computing the final latitude value.

Selected values are finite, so unequal values use ordinary numerical ordering. Equal nonzero values have the same bits. For zero ties, the typed original-toolchain probe establishes that `MIN(+0,-0)` and `MIN(-0,+0)` return negative zero, while both corresponding `MAX` calls return positive zero. When both operands have the same zero sign, retain it. All 3,596 negative-zero original-body values also return the exact negative-zero bits. Do not replace clips with a rule that changes these bits.

The update performs thirty-three separately rounded arithmetic operations per point. Enabled clipping adds twelve minimum/maximum selections across three clips. The original source performs separate row passes within each level. Since points have disjoint output cells and share only read-only inputs, a native body may complete one point at a time while preserving every point's arithmetic graph. Profiling, wall-clock records and floating-point exception-status flags are outside canonical field output. There is no numerical helper.

## Independent Physics Before Emission

The independent reference expands each row into explicit sample weights. For an outer fraction `x`, these weights are `(1-x,x)`. For nonbase cubic coefficients `(w1,w2,w3)`, they are `(1-w1-w2-w3,w1,w2,w3)`. It multiplies each weight by its sample and sums them at higher precision, rather than repeating the source's separately rounded difference-and-add tree. Apply independent central-neighbour clips to the two middle rows when enabled, then combine the four rows through expanded latitude weights and apply the independent final clip.

Without clipping, this is one expanded sum of twelve neighbours. With clipping, it is a piecewise polynomial estimate, meaning that it follows a polynomial inside the permitted interval and uses the interval endpoint outside it. Clipping is continuous and changes an error by no greater than that error's size.

Freeze the following absolute forward-error limit. Here `epsilon=2^-52` is binary64 spacing above one, `minimum_normal=2^-1022` is its smallest positive normal value and `minimum_positive=2^-1074` is its smallest positive value. `maximum_corner` is the largest absolute value of the twelve used samples. All gains are dimensionless, while the limit has the field's unit.

```text
row_gain = 1 + 2*sum(abs(nonbase_row_coefficients))
latitude_gain = 1 + 2*sum(abs(latitude_coefficients))
gain = latitude_gain * max(the four row gains)
limit = 256*epsilon*max(maximum_corner,minimum_normal)*gain
        + 128*minimum_positive*gain
```

For outer rows, the single fraction is the nonbase coefficient. The gain covers each rounded difference, weighted term and partial sum, with a conservative margin for thirty-three operations and gradual underflow. Independent acceptance does not replace exact source/native agreement.

Before emission, 288 complete original critical cases pass 52,836 independent values at 100 decimal digits, 79,254 independent clipping operations and 26,418 central-neighbour bounds. They also pass 3,596 exact constant values, 3,596 affine values, 1,798 exact unclipped endpoints and 3,596 exact negative-zero values. The corpus covers both clipping flags, partial and empty regions, signed plane labels, extrapolation, duplicate gathers, both source ends, subnormal and large values, unused NaN planes and complete guard/inactive storage. Its largest error is 0.000610 of the fixed limit. Inputs occupy 27,119,680 bytes, complete returned records 552,512 bytes and independent truth/limits 1,049,664 bytes.

## Complete Actual Original Capture

The fresh source-only T21 forecast captures all 2,150 original calls. Every call uses `A=3101,B=24,L=19,KST=1,KFLDN=0,KFLDX=20,KQM=1`. There are 2,125 full twenty-four-row calls and twenty-five eight-row calls. Original LARCINB supplies every call, with source-relative return address `0x15a910`. Its declared complete `PDP(NPROMA,NFLEVG)` storage is passed unsliced. The longitude/latitude coefficient planes, four `KLH0` planes and full declared source-field view come directly from its typed caller arrays.

Every one of 972,800 active values passes a separately expanded reference at 113-bit precision, about thirty-four decimal digits, with 2,918,400 independent clip operations and 972,800 central-neighbour bounds. The largest error is 0.000807 of the fixed limit. Every selected source sample and coefficient is finite, and the largest `maximum_corner*gain` is 131.382, far below the finite-intermediate limit.

The full incoming input archive has 1,245,985,200 bytes, including complete coefficient, fraction, index, source-field and incoming-output storage. Complete returned records have 8,256,000 bytes. All ten saved forecast files, totalling 618,140 bytes, directly match the canonical strict-vertical original run. These scientific checks cover this complete interpolation closure, while other model stages have separate scientific acceptance.

## Arm Interface and Output Bytes

The application binary interface, or ABI, defines how callers pass arguments and which registers a callee must preserve. Registers `x0:x7` receive the eight integer pointers. Incoming stack byte offsets 0, 8, 16, 24, 32 and 40 hold `PCLA,PDLO,PCLO,KL0,PXSL,PXF`. Preserve `x19:x29`, the stack pointer, return link, the low 64 bits of `v8:v15` and FPCR. Do not use reserved register `x18`. The target is Armv8-A with Advanced SIMD on the own Arm node.

The primary owns every gather, all thirty-three arithmetic operations, all enabled clips and every selected output write. A comparison driver supplies frozen arguments and allocated storage, then checks them. It supplies no omitted numerical stage. An ABI-only wrapper may forward the six stack pointers, while leaving callee-saved registers visible to the independent probe.

Critical files begin with a 64-byte `LAIDCR01` header. Each case has a 192-byte `LAIDCS01` header with case number, all eight integer arguments, profile and complete extents. Payload order is latitude coefficients, four longitude planes, six middle-row coefficient planes, four signed index planes, complete source field and incoming whole output with eight-cell prefix/suffix guards. Source returns retain the header and complete physical output allocation. Independent `LAIDIN01` records retain the header, complete higher-precision truth rounded once for checking and the frozen absolute limits.

Actual records use a deterministic 192-byte `LAIDFC01` header with call number, all eight integer arguments, caller kind, complete extents and source-relative return address. Their payload order is the same without added guards. Returned records retain the header and complete declared output field. Integer words and binary64 values use little-endian order.

Every same-input critical or actual replay, complete source/native field pair, checkpoint and final file requires zero differing bytes. Preserve all inactive incoming bits. Fresh runs may receive different opaque incoming storage, which must be disclosed through complete raw comparisons and a frozen-input replay. Do not round, mask or normalise any output bit. The complete native body now passes the accepted checks below. No comparative timing has been performed.

## Complete Native Acceptance

The unchanged first direct body has 121 instructions and 484 bytes. It owns all twelve source reads, thirty-three separately rounded arithmetic operations, twelve optional minimum/maximum selections and the selected output writes. It has no numerical helper, allocation or stack frame. It uses only caller-saved integer registers and the first eight floating-point registers, while preserving the required ABI state.

The protected critical run passes all 288 cases and 291 direct ABI calls, including three genuine concurrent thread calls, with zero differences across 552,512 complete returned bytes. All 52,836 independently checked values pass the frozen limit. Read-only inputs and protected output tails expose any access outside the declared storage, while complete guards and inactive cells remain unchanged.

Replay of all 2,150 frozen original forecast inputs passes zero differences across 8,256,000 complete returned bytes. The isolated native forecast then passes every whole same-input source/native pair, all 972,800 higher-precision interpolation checks, 2,918,400 independent clips and 972,800 central-neighbour bounds. All ten saved files directly match both the original source run and canonical forecast, with zero differences across 618,140 bytes.

The separate fresh source and native forecasts have different opaque incoming inactive storage. Their raw returned streams differ in 36,053 inactive bytes, covering 5,168 cells in seventeen calls. All 972,800 active values directly match. The first returned difference is call 258, level one, row nine, outside its selected rows one to eight. Its source word is `0x4026e4260c7a098f` and its native word is `0x4026f72e9447bb9f`. Each run preserves its own full incoming inactive storage, and all whole same-input comparisons and the frozen-input replay have zero differences. These raw differences remain in the archives, with no masked, normalised or discarded bit.

The parent combined forecast also accepts all 2,150 complete paired returns, 972,800 independently checked active values and 2,918,400 clipping operations. Its active values directly match the original source run. Complete same-input pairs and the unchanged frozen-input replay preserve every unused storage byte. Across the observed routines, thirty-six complete paired output streams match over 4,345,833,608 bytes, and ten saved files match over 618,140 bytes.

## Reproduction

Use the own exclusive allocation and CPU32 route recorded in the compact [acceptance record](../../../../../bench/openifs/dynamics/laiddi.json). Load `PrgEnv-gnu`, `gcc-native/12.3` and `libfabric/2.3.1`. The commands below run inside `srun --jobid=7207705 --overlap --exact -N1 -n1 -c33 --cpu-bind=map_cpu:32 --mem-bind=local bash -lc '<command>'`, from the repository root. A full forecast also uses `--mpi=cray_shasta` and one process and thread.

```sh
task_dir=.runtime/openifs/laiddi-7207705/public-reviewed
gcc -fPIC -march=armv8-a+simd -c src/openifs/dynamics/laiddi.S \
    -o "$task_dir/laiddi.o"
gcc -fPIC -march=armv8-a+simd -DLAIDDI_ABI_PROBE \
    -c src/openifs/dynamics/laiddi.S -o "$task_dir/laiddi-abi.o"
gcc -fPIC -march=armv8-a+simd -c bench/openifs/dynamics/vertical_abi.S \
    -o "$task_dir/vertical-abi.o"
gcc -O2 -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
    -Wall -Wextra -Werror bench/openifs/dynamics/laiddi.c \
    "$task_dir/laiddi-abi.o" "$task_dir/vertical-abi.o" -lm \
    -o "$task_dir/verify"
OMP_NUM_THREADS=1 OMP_DYNAMIC=FALSE "$task_dir/verify" \
    .runtime/openifs/laiddi-7207705/preparation/critical-inputs.bin \
    .runtime/openifs/laiddi-7207705/preparation/critical-fortran.bin \
    .runtime/openifs/laiddi-7207705/preparation/critical-independent.bin \
    "$task_dir/assembly.bin" "$task_dir/summary.json"
gcc -O2 -mcpu=neoverse-v2 -fPIC -shared -fopenmp -ffp-contract=off \
    -fno-fast-math -Wall -Wextra -Werror \
    bench/openifs/dynamics/laiddi_forecast.c "$task_dir/laiddi.o" \
    -ldl -lm -o "$task_dir/libverify-laiddi.so"
```

The verifier's `--actual INPUT SOURCE NATIVE SUMMARY` mode replays the complete actual source capture. Its `INPUT` and `SOURCE` files are `laiddi-inputs.bin` and `laiddi-fortran.bin` in `.runtime/openifs/runs/strict-laiddi-source-complete-7207705/t21/test_fc`. The full isolated launch is retained in `.runtime/openifs/laiddi-7207705/build/isolated-forecast-command.sh`, and exact preparation, emission, checks and publication commands are in `commands-release.json` beside the sealed `accepted.json`. The forecast comparator adds only `laiddi_` and `laiddi_assembly_`, with no SPCM scope relay or numerical dependency. A parent combined forecast can retain its existing sole SPCM relay and add this comparator.

Use `-DLAIDDI_SOURCE_ONLY` without the assembly object to build the original-source observer. The frozen source-only launch omits the old SIMPLICO observer and all newly emitted numerical bodies. Instrumented forecast wall-clock durations include capture and scientific checks, so they are not comparative performance measurements.
