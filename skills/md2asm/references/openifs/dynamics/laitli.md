# Complete OpenIFS LAITLI

Numerical revision 1.0 freezes the complete original trilinear-interpolation body before direct AArch64 emission. Documentation revision 1.2 adds the independently reviewed combined forecast without changing that update. The method combines eight samples through seven linear blends. Every arithmetic operation, gather address, loop, returned cell and untouched byte belongs to this contract.

## Physical Meaning

The [atmospheric-motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), especially P01, describes change following moving air. A weather model traces each air parcel back to its earlier position. Interpolation estimates the field at that position from nearby grid values. LAITLI uses two east–west neighbours on each of two latitude rows, at each of two source heights.

The caller supplies the chosen neighbour indices and four fractional distances. These distances have no unit. The scalar field `q` keeps its caller's unit, such as metres per second for wind. Its interpolated value has the same unit. Each latitude row can have a different longitude fraction, because grid spacing can change with latitude.

A linear blend is `mix(a,b,w)=a+w*(b-a)`. When `0 <= w <= 1`, it gives a value between its two samples. Values outside this range extend the same local linear trend. The critical corpus checks both cases.

## Arguments and Complete Storage

All thirteen arguments are ordinary pointers. The first seven point to signed 32-bit integers. The six arrays follow them in their original order. Define `A=KPROMA` as the source-plane size, `B=KPROMB` as the output-row size, `L=KFLEV` as the level count and `F=KFLDX-KFLDN+1` as the number of stored source planes.

| Argument | Shape or Meaning |
| --- | --- |
| `KPROMA,KPROMB` | `A,B`, the source-plane and output-row sizes |
| `KSTART,KPROF` | First and last selected output row, both inclusive |
| `KFLEV` | `L`, the output-level count |
| `KFLDN,KFLDX` | First and last source-plane labels |
| `PDLAT` | `(B,L)` latitude fractions |
| `PDLO` | `(B,L,2)` longitude fractions, one plane for each latitude row |
| `KL0` | `(B,L,2)` signed 32-bit source base indices |
| `PDVER` | `(B,L)` height fractions |
| `PXSL` | `A*F` contiguous 64-bit source values |
| `PXF` | `(B,L)` complete returned field |

Arrays store the output row fastest. For zero-based row `r` and level `j`, the output index is `p=r+B*j`. The second longitude/index plane starts `B*L` elements after the first. A descriptor or hidden character length is not passed.

For each selected output point, let `k_s=KL0[p+s*B*L]` for latitude row `s=0,1`. Define the eight zero-based source indices below, with height `h=0,1` and east–west side `e=0,1`.

```text
index(h,s,e) = k_s + (h+1)*A + e
corner[h,s,e] = PXSL[index(h,s,e)]
```

The original one-based Fortran index is one greater. These offsets preserve the original selection of the middle eight neighbours from its larger interpolation neighbourhood.

Require `0 <= A <= (INT32_MAX-2)/2`, `0 <= B,L < INT32_MAX` and `1 <= F <= INT32_MAX`. Require `2*B*L <= INT32_MAX` and `A*F <= INT32_MAX`, with the plane-label difference also representable in signed 32-bit arithmetic. Require `1 <= KSTART <= B+1` and `0 <= KPROF <= B`. A reversed selected interval, zero rows or zero levels performs no field update.

Every selected source base index must satisfy `1 <= k_s+A+1` and `k_s+2*A+2 <= A*F`. These inequalities cover all eight reads and keep the original 32-bit address calculations valid. Original typed probes confirm 32-bit `JPIM` and `JPIA` and 64-bit `JPRB`. Integer objects need four-byte alignment, while real buffers need eight-byte alignment. Every extent and byte address must fit the allocated object and the machine address range. Empty arrays permit no reads or writes.

All input arrays and integer arguments remain unchanged. The output allocation must be disjoint from every input. Used weights and source samples are finite, with every separately rounded intermediate finite. Unselected weights, indices and unused source samples can hold arbitrary bits, including NaNs. Each returned field includes its full declared capacity, so inactive rows preserve their incoming bits.

## Frozen Ordered Update

`RN` means one binary64 operation rounded to nearest with ties to even. Binary64 is the 64-bit floating-point format. Each subtraction, multiplication and addition is separate. Keep the Arm floating-point control register, or FPCR, zero at entry and return. This preserves gradual underflow and signed zeros. Fused arithmetic, contraction, reassociation, reduced precision, approximate arithmetic and fast-math are forbidden.

Visit output levels `1:L` in increasing order, and rows `KSTART:KPROF` in increasing order. For each point, load `t=PDLAT[p]`, `x1=PDLO[p]`, `x2=PDLO[p+B*L]` and `z=PDVER[p]`. Finish the complete upper-height interpolation before the lower-height interpolation, then combine heights.

```text
upper_latitude1 = RN(corner[0,0,0] + RN(x1 * RN(corner[0,0,1]-corner[0,0,0])))
upper_latitude2 = RN(corner[0,1,0] + RN(x2 * RN(corner[0,1,1]-corner[0,1,0])))
upper = RN(upper_latitude1 + RN(t * RN(upper_latitude2-upper_latitude1)))
lower_latitude1 = RN(corner[1,0,0] + RN(x1 * RN(corner[1,0,1]-corner[1,0,0])))
lower_latitude2 = RN(corner[1,1,0] + RN(x2 * RN(corner[1,1,1]-corner[1,1,0])))
lower = RN(lower_latitude1 + RN(t * RN(lower_latitude2-lower_latitude1)))
PXF[p] = RN(upper + RN(z * RN(lower-upper)))
```

These seven blends require twenty-one floating-point operations per point. There is no reduction across points and no numerical helper. Intel-only prefetch branches are inactive in the frozen GNU target. Profiling calls, wall-clock records and floating-point exception-status flags are outside the field-output contract.

## Arm Interface

Registers `x0:x7` receive the first eight pointers, ending with `PDLAT`. Incoming stack byte offsets 0, 8, 16, 24 and 32 hold `PDLO,KL0,PDVER,PXSL,PXF`. Preserve `x19:x29`, the stack pointer, the return link, the low 64 bits of `v8:v15` and FPCR. Do not use reserved register `x18`. The target is Armv8-A with Advanced SIMD on the own Arm node. The primary needs no allocation or external numerical call.

A comparison driver only supplies frozen arguments, allocated storage and verification. It performs none of the seven blends for the primary. A register-check wrapper may load the ordinary arguments and reserve their five stack slots, while leaving callee-saved registers visible to the independent ABI probe.

## Independent Source Physics

An independent reference expands the result into eight weighted corners, using `z_0=1-z,z_1=z`, `t_0=1-t,t_1=t` and longitude weights `x_{s,0}=1-x_s,x_{s,1}=x_s`.

```math
q^*=\sum_{h=0}^{1}\sum_{s=0}^{1}\sum_{e=0}^{1}
z_h\,t_s\,x_{s,e}\,q_{hse}.
```

The critical reference uses 100 decimal digits and does not repeat the source's seven-blend operation tree. It separately checks constant and affine source values, exact cell endpoints, convex bounds, both buffer ends, empty regions, partial rows, unequal longitude fractions, signed zeros, subnormal values and inactive NaN storage.

For every point, freeze the absolute error limit below. `epsilon=2^-52` is the spacing above one in binary64, `minimum_normal=2^-1022` is its smallest positive normal value and `minimum_positive=2^-1074` is its smallest positive value. `maximum_corner` is the largest absolute value among the eight samples. The factor `gain` bounds amplification by the interpolation weights.

```text
gain = (1+2*abs(t))*(1+2*abs(z))*(1+2*max(abs(x1),abs(x2)))
limit = 128*epsilon*max(maximum_corner,minimum_normal)*gain
        + 64*minimum_positive*gain
```

The limit has the field's unit and is set before native generation. Constant and exact endpoint cases also require exact value bits where defined. When all four weights lie between zero and one, the returned value must remain between the minimum and maximum corners, allowing only this frozen rounding limit. Complete source/native byte agreement still requires zero differing bytes.

Before emission, 126 complete original calls pass 22,822 independent hundred-digit values, 21,024 convex bounds and 1,798 values each in constant, affine and endpoint checks. The source corpus includes the actual 3,101 by 24 by 19 geometry. Source inputs occupy 9,846,880 bytes and complete returned/guard records occupy 237,728 bytes. The original accepted ninety-one-case preparation remains separately archived.

## Actual Complete Source Capture

The fresh source-only historical T21 forecast records 47,300 complete original calls. Every call uses `A=3101,B=24,L=19,KFLDN=0,KFLDX=20,KSTART=1`. The last selected row is twenty-four in 46,750 calls and eight in 550 partial calls. LARCINA supplies 17,200 calls, LARCINB 19,350 and QMFIXER's original local OpenMP worker 10,750. That hidden worker resolves to `qmfixer.F90:321` at source-image offset `0x275450`. The observer proves its frozen source image and caller identity.

All 21,401,600 active actual values pass a separately expanded reference with 113-bit precision, approximately thirty-four decimal digits, and all pass convex bounds. The largest error is 0.009553 of the frozen limit. The critical reference remains at 100 decimal digits. Actual weight ranges are between zero and one.

Capture every declared latitude, longitude, index, height and source-field byte, followed by the incoming whole output. Check complete input and scalar immutability after the original call, and preserve every inactive output bit. The input archive has 25,684,656,800 bytes. Whole returned records have 180,118,400 bytes. All ten saved forecast files, totalling 618,140 bytes, directly match the canonical strict-vertical Fortran run.

Critical files begin with a 64-byte `LAITCR01` header. Every critical record has a 160-byte `LAITCS01` header containing the case, all seven integer arguments, profile and exact extents. Input payload order is latitude, both longitude planes, both integer-index planes, height, complete source field and incoming output with eight-cell prefix/suffix guards. Source results retain the same case header and complete output/guard allocation. Frozen independent records use `LAITIN01` and retain each case header, complete physical truth and limits.

Each actual record has a deterministic 160-byte `LAITFC01` header, with call number, every integer argument, caller kind, complete extents and source-relative return address. Input payload order is the same without added guards. Result records retain the header and entire returned field. Integers and binary64 words use original little-endian order. Every stage, record, checkpoint and final-file comparison requires zero differing bytes, with no rounding, masking or normalisation of output bits.

These source-only scientific checks cover the complete interpolation closure. Independent scientific acceptance of other forecast stages remains separate. Native acceptance is complete, and no comparative timing has been performed.

## Native Acceptance

The unchanged first direct body has 68 instructions and a 272-byte function. It performs all seven blends with twenty-one separate binary64 operations, using seven subtractions, seven multiplications and seven additions. It uses no allocation, external call, reserved register or stack frame. The optional ABI wrapper supplies ordinary arguments only. The assembly was emitted directly from the frozen contract and typed original interface, then assembled and linked. Compiler-generated numerical assembly and intermediate representations were not used to construct it.

All 126 critical cases return the complete 237,728-byte frozen source record without a differing byte. They pass 22,822 independent hundred-digit values, protected buffer ends, input pages that cannot be written and three simultaneous calls on a genuine three-thread team. The register probe accepts 129 direct calls with FPCR zero. A separate replay passes all 47,300 frozen actual input records and all 180,118,400 returned bytes with protected complete storage.

The isolated native forecast independently checks all 21,401,600 active values at 113-bit precision and compares each complete returned field against the original body supplied with the same incoming bytes. Every source/native pair is identical. All ten saved files directly match both the original source-only forecast and the canonical strict-vertical run, including their full 618,140 bytes. These scientific checks cover this complete interpolation body, while other model stages retain separate scientific acceptance.

Fresh forecasts can receive different opaque bits in inactive incoming output cells. The source-only and isolated native runs differ in 124,124 such bytes across 15,708 inactive cells in 65 calls. Their first returned difference is visit 683, level 10, row 14, outside its selected rows 1–8. All 21,401,600 active values remain directly identical. No captured byte is removed, masked or normalised. Complete same-input comparisons and the frozen-input replay each require zero differing bytes.

The parent combined forecast also accepts all 47,300 complete paired returns and all 21,401,600 independently checked active values. Its full incoming records remain captured. Active values directly match the original source run, while complete fresh pairs and the unchanged frozen-input replay preserve all unused storage bytes. Across all observed routines, thirty-four complete paired streams match over 4,081,782,408 returned bytes, and all ten saved files match over 618,140 bytes.

## Reproduction

Run all commands through the own exclusive allocation on the compute node. The accepted route is `srun --jobid=7207705 --overlap --exact -N1 -n1 -c33 --cpu-bind=map_cpu:32 --mem-bind=local bash -lc '…'`. Full forecasts add `--mpi=cray_shasta` and use one process and one thread. Load `PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1` and disable core-file creation with `ulimit -c 0`. The commands below run inside that compute step. Set `build` to a new directory under the ignored runtime folder.

```bash
build=.runtime/openifs/laitli-reproduction
mkdir -p "$build"
gcc -fPIC -march=armv8-a+simd -c src/openifs/dynamics/laitli.S -o "$build/laitli.o"
gcc -fPIC -march=armv8-a+simd -DLAITLI_ABI_PROBE -c src/openifs/dynamics/laitli.S -o "$build/laitli-abi.o"
gcc -c bench/openifs/dynamics/vertical_abi.S -o "$build/vertical-abi.o"
gcc -O2 -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laitli.c "$build/laitli-abi.o" "$build/vertical-abi.o" -lm -o "$build/verify"
d=.runtime/openifs/laitli-7207705
OMP_NUM_THREADS=1 OMP_DYNAMIC=FALSE "$build/verify" "$d/preparation/critical-inputs.bin" "$d/preparation/critical-fortran.bin" "$d/preparation/critical-independent.bin" "$build/assembly.bin" "$build/summary.json"
cmp "$d/preparation/critical-fortran.bin" "$build/assembly.bin"
gcc -O2 -mcpu=neoverse-v2 -fPIC -shared -fopenmp -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laitli_forecast.c "$build/laitli.o" -ldl -lm -o "$build/libverify-laitli.so"
```

For full frozen-input replay, use `verify --actual INPUT SOURCE NATIVE SUMMARY` with the complete files in `.runtime/openifs/runs/strict-laitli-source-complete-7207705/t21/test_fc/`. For a fresh source-only capture, compile the forecast observer with `-DLAITLI_SOURCE_ONLY` and omit the assembly object. For native capture, put `libverify-laitli.so` first in the preload list, before the immutable strict-vertical reference and pressure-math library. This observer defines no SPCM scope relay and introduces no numerical helper.

The ignored local release `.runtime/openifs/laitli-7207705/accepted.json` identifies the frozen source, critical corpus, original and effective pre-emission contracts, unchanged first objects, complete captures, raw differing inactive storage, exact commands and acceptance reports. Preparation failures remain archived there. Wall-clock logs include observation and disk work, so they support no performance claim.

## Runtime Operational Shapes

The unchanged numerical bodies now also pass a component check at 17 columns and 137 levels with source-plane lengths 1,744,925 and 1,783,837. The same objects cover smaller shapes, shifted and final-two work, zero levels, empty work and an absent maximum output. Across both children, all 479,280 complete output bytes and 768 raw-status bytes match the unchanged original objects. Each route passes 68,646 independent affine-field, extrema and unchanged-cell relations. Native ABI checks, read-only source storage and output guards pass. These checks establish runtime shape and address support for the two leaves, while the enclosing operational mass-correction caller and forecast remain unverified. Detailed records remain in the ignored local research folder.
