# Complete Single-Rank OpenIFS SPCIMPFSOLVE

Revision 1.2 records direct-body acceptance and preserves the numerical contract frozen at revision 1.0. That contract freezes the complete numerical body of the original SPCIMPFSOLVE, including both single-rank copies, coefficient construction, every wave solve and the returned field. The verified complete SIMPLICO assembly is its only numerical helper. Distributed geometries require separate transpose contracts and are outside this accepted domain.

## Physical Meaning

The [atmospheric-motion formulation](../../../../../formulations/openifs/dynamics/atmospheric_motion.md) describes pressure forces and Earth's rotation. A spectral coefficient gives the size of a smooth wave on the sphere. Wave number $`m`$ counts variation around longitude, while degree $`n`$ also includes variation with latitude. SPCIMPFSOLVE prepares the rotation coefficients and solves the implicit pressure-wave update for every wave. An implicit update includes the new state in the equation, so the solver must solve a coupled linear system.

The input field $`y`$ and returned field $`x`$ contain real and imaginary divergence coefficients, in inverse seconds for a dimensionless vertical-mode basis. An imaginary coefficient records the second part of a longitude wave. The zero longitude wave has no imaginary part, and its returned imaginary coefficients are positive zero.

The time interval $`\Delta t=\mathrm{TDT}`$ is in seconds. The source weight $`\beta=\mathrm{RBT}`$ and stretching factor $`s=\mathrm{RSTRET}`$ have no unit. Earth's angular speed $`\Omega=\mathrm{ROMEGA}`$ is in inverse seconds. The vertical pressure-wave coefficients $`v_\ell=\mathrm{SIVP}`$ are in square metres per square second. The spherical Laplacian coefficients $`\lambda_n=\mathrm{RLAPDI}(n)`$ are in inverse square metres.

## Complete Ordered Update

`RN` means one operation in the 64-bit floating-point format, rounded to nearest with ties to even. Each multiplication, addition, subtraction, division and square root has its own rounding point. The Arm floating-point control register, or FPCR, must be zero at entry and return. This preserves gradual underflow and signed zeros. Exception-status flags and profiling records are outside the canonical output.

First compute the weights below, without combining operations. The rounded rotation factor is identical for every wave, so its stored bits can be reused.

```text
b = RN(RN(0.5 * TDT) * RBT)
t = RN(b * RSTRET)
b2 = RN(t * t)
f = RN(RN(2 * b) * ROMEGA)
v_local[level] = SIVP[MYLEVS[level]]
```

Copy every selected input cell into a private dense field, with levels stored fastest. In a single-rank geometry, this is the complete original TRSTOM numerical operation. The assembly performs the copy itself, preserving every bit. The driver supplies no transposition or field value.

Visit `MYMS[1:NUMP]` in increasing local index order. This array is a permutation of all wave numbers from zero through `NSMAX`. For each wave `m`, set `a = RN(f * real(m))`. For `n = max(m,1):NSMAX`, prepare the coefficients below, using exact integer-to-floating-point conversion.

```text
r = real(n)
rp1 = RN(r + 1)
alpha[n] = RN(a / RN(r * rp1))
denim[n] = RN(1 / RN(1 + RN(alpha[n] * alpha[n])))
numerator = RN(RN(r * r) - RN(real(m) * real(m)))
denominator = RN(RN(RN(4 * r) * r) - 1)
epsilon[n] = RN(sqrt(RN(numerator / denominator)))
```

For a zero wave, `alpha[0]`, `denim[0]` and `epsilon[0]` are positive zero. Both `alpha[NSMAX+1]` and `denim[NSMAX+1]` are positive zero for every wave.

For `n = max(m,1):NSMAX-1`, compute the neighbouring-wave weights below.

```text
plus[n] = RN(RN(RN(f * real(n)) * epsilon[n+1]) / RN(real(n) + 1))
minus[n] = RN(RN(RN(f * RN(real(n) + 1)) * epsilon[n]) / real(n))
```

For a zero wave, `plus[0]` and `minus[0]` are positive zero. At the final degree, set `plus[NSMAX]` to positive zero and compute `minus[NSMAX]` with the same ordered formula. Set both weights at `NSMAX+1` to positive zero.

Call the verified [complete SIMPLICO assembly](simplico.md) with the original thirteen ordinary pointers. Pass the selected vertical coefficients, the Laplacian beginning at degree zero, `b2`, and the real/imaginary columns beginning at `NASM0[m]`. Its contract defines the original independent matrix and every ordered parity sweep. Its zero-wave mutation of the private input field remains part of this update.

After every wave finishes, copy all local levels and spectral columns from the private returned field into the output descriptor. This is the complete original single-rank TRMTOS numerical operation. Preserve inactive rows, unrelated fields in a shared parent, both descriptors and every input byte.

## Supported Geometry and Storage

The target is AArch64 with base Armv8-A instructions and Advanced SIMD, using the frozen GNU Fortran 12.3 storage layout for OpenIFS 48r1. Require `NPRTRN=NPRTRV=1`. This covers the current coarse forecast on one process and one node, with distributed MPI exchanges excluded.

Require `1 <= NSMAX <= 255`, `NUMP=NSMAX+1` and `NSPEC2=(NSMAX+1)*(NSMAX+2)`. Global, local and storage level counts must be equal, with `0 <= NFLEVG=NFLEVL=NFLSUR <= INT32_MAX`. Each wave owns a disjoint real/imaginary block, with `NASM0[m]=1+m*(2*NSMAX+3-m)`. `MYMS[1:NUMP]` contains every wave once. These rules ensure that every active returned cell is defined.

Geometry occupies 17,096 bytes, the integration object occupies 175,976 bytes and the dynamics object occupies 4,720 bytes. The typed source probe freezes these offsets. A descriptor is an array description containing its data pointer, type, strides and bounds.

| Object | Member | Byte Offset |
| --- | --- | --- |
| Geometry | `NSMAX` | 5172 |
| Geometry | `NSPEC2` | 5200 |
| Geometry | `NUMP` | 5212 |
| Geometry | `NFLEVG` | 5224 |
| Geometry | `NFLEVL` | 5228 |
| Geometry | `NFLSUR` | 5236 |
| Geometry | `RSTRET` | 7512 |
| Geometry | `MYMS` descriptor | 3912 |
| Geometry | `NASM0` descriptor | 3720 |
| Geometry | `MYLEVS` descriptor | 5960 |
| Geometry | `RLAPDI` descriptor | 4104 |
| Integration | `TDT` | 208 |
| Dynamics | `RBT` | 2488 |
| Dynamics | `SIVP` descriptor | 3312 |

The rank-one descriptor occupies 64 bytes. It stores its base pointer at byte zero, offset at byte eight, element size at byte sixteen, type at byte twenty-four, span at byte thirty-two, element stride at byte forty, lower bound at byte forty-eight and upper bound at byte fifty-six. Require unit element stride. Integer arrays use four-byte elements and type `0x0000010100000000`. Real arrays use eight-byte elements and type `0x0000030100000000`.

`MYMS` starts at zero or one and includes `NUMP`. `NASM0` starts at zero and includes `NSMAX`. `MYLEVS` starts at one and includes every local level. `RLAPDI` starts at minus one and includes `NSMAX+2`. `SIVP` starts at one, and every selected `MYLEVS` index lies in its complete allocation. Larger upper bounds are allowed. Every allocation remains unchanged.

The rank-two input and output descriptors occupy 88 bytes each. They add the second dimension's stride and bounds at bytes sixty-four, seventy-two and eighty. Eight-byte element size/span and type `0x0000030200000000` are fixed. Each base points to the first selected cell. Each descriptor has exactly `NSPEC2` columns and at least `NFLEVL` rows. Either stride can be positive or negative. Selected cells must be distinct and valid, with all byte offsets fitting signed 64-bit integers. Zero rows permit an empty descriptor. Descriptors, objects and real buffers require eight-byte alignment. Integer arrays require four-byte alignment.

Complete input/output parents must be disjoint, and disjoint from every read-only object and reachable allocation. Used scalars and coefficients are finite. Pressure-wave matrices are nonsingular, with finite separately rounded intermediates and returned values. Inactive input rows can hold arbitrary bits, including NaNs, because the solver does not read them. Preserve every incoming output byte except active field cells.

The logical pointers `LDNHDYN`, `LDNHX` and `LDONEM` hold canonical four-byte zero or one. They do not change these single-rank divergence-only copies. All eight combinations are supported and remain unchanged.

## Assembly Interface and Bounds

The application binary interface, or ABI, specifies arguments and register obligations. Eight ordinary pointers arrive in `x0:x7`, in the order geometry, integration, dynamics, three logical flags, input descriptor and output descriptor. There are no hidden character lengths or returned scalar values.

The body owns one allocation for complete dense input/output fields, five coefficient arrays and local vertical coefficients. Its size is `16*NFLEVL*NSPEC2 + 8*(5*(NSMAX+2)+NFLEVL)` bytes. This size and every address must fit the target address range. Allocation failure aborts before any numerical result is accepted. SIMPLICO owns its own bounded work array under its existing verified contract.

Preserve `x19:x29`, the stack pointer and the low 64 bits of `v8:v15`. Do not use reserved platform register `x18`. The frame is a multiple of sixteen bytes, and SIMPLICO's five stack arguments start at the current stack pointer. Allocation, deallocation and failure handling are nonnumerical dependencies. The primary uses no unported numerical Fortran helper.

## Source-Only Scientific Acceptance

Before primary emission, sixty-six complete original calls pass the frozen corpus. They cover degrees 1, 2, 3, 7 and 21, the upper supported degree 255 with empty levels, both source MYMS lower bounds, zero/one/three/nineteen levels, zero and reversed time, zero implicit weight, zero gravity, reordered wave and vertical indices, signed descriptor strides, inactive NaN rows and subnormal fields.

Independent hundred-digit dense systems pass 28,850 solution values and 15,400 original-matrix residuals. There are 1,950 exact positive-zero imaginary cells and 3,462 zero-time or zero-weight identity values. The dense matrix does not use the source parity recurrence. All tolerances are frozen from strict diagonal dominance before emission.

All 763 source SIMPLICO calls pass 150,652 exact ordered coefficient checks, 30,800 copy values and 61,600 returned-stage values. Their 2,739,640 stage bytes and 339,392 returned/guard bytes are frozen. Actual forecast science also passes every complete source closure before emission. The first direct assembly body passes the same complete records without a numerical change.

## Actual Source Forecast and Canonical Bytes

The historical T21 source forecast has twenty-five complete visits. Each uses degree twenty-one, nineteen levels, 506 real/imaginary spectral columns and twenty-two waves. Both processor partition counts are one. The actual MYMS allocation begins at one and ends at twenty-two. These facts are frozen from full argument captures, rather than assumed from a synthetic layout.

SPCSI allocates the complete input and output temporaries at source lines 182–183, with nineteen rows and MAX(NSPEC2V,NSPEC2VF)=506 columns. Its sole SPCIMPFSOLVE call passes both allocations without slicing. The observer proves the source-library caller symbol/image, both original geometry capacities and complete descriptor bounds. Its 1,929,200 result bytes include every cell of all twenty-five output temporaries and deterministic 256-byte headers. The separate shared SPCM SP3D parent is checked unchanged. It is not the returned temporary.

Every one of the 550 source SIMPLICO stages passes exact ordered coefficients, copied input and returned field checks, together with 229,900 hundred-digit independent solution values, 120,175 original-matrix residuals and 10,450 positive-zero imaginary cells. Both complete single-rank copies are checked bit for bit. The 6,309,600 full stage bytes and 8,824,300 whole input-record bytes are frozen. All ten saved model files, totalling 618,140 bytes, directly match the canonical strict-vertical Fortran forecast.

Each critical result record has a 160-byte deterministic header, followed by the complete physical output allocation with its eight-cell prefix/suffix guards. Fields use original physical cell order, including inactive cells. Each forecast result has a 256-byte deterministic header followed by the complete original returned temporary. Output words use little-endian FP64 encoding. Source/private stage records retain every defined coefficient, copied wave input and complete returned wave field, with separately identified before/after stages. Undefined private array prefixes are not output fields. No output bit is rounded, masked, normalised or omitted to conceal a difference. Require zero differing bytes in every complete raw stage, checkpoint and final record before timing.


## Direct-Body Acceptance

The first body contains 253 AArch64 instructions. Its only numerical call is the previously verified complete SIMPLICO assembly. Its two copies, rotation arrays, selected vertical coefficients and all wave visits are present in the body. Object inspection finds no reduced-precision, fused or approximate arithmetic, and no use of reserved register `x18`.

All sixty-six critical cases match 339,392 complete returned bytes and 2,739,640 before/after stage bytes. Guard cells and inactive rows remain unchanged. Every declared input allocation is read-only during execution, and each declared allocation ends at an inaccessible page. Sixty-nine direct ABI calls pass, including three calls in one genuine three-thread team with separate returned fields. The uninstrumented body is checked directly, while an observation-only build records the complete SIMPLICO argument and result buffers. Both builds have identical primary instruction bytes and differ only in the numerical call's observer relocation.

The isolated native forecast passes all twenty-five complete calls and 550 source/native wave pairs. Every returned byte and every stage byte matches the independent pre-emission source capture. All ten saved forecast files directly match the canonical source forecast. A separate hundred-digit check of the native capture passes 229,900 solution values, 120,175 original-matrix residuals and 10,450 positive-zero imaginary cells. The largest solution error is 0.015 of its frozen limit. This checks the complete implicit-solve closure. Independent scientific acceptance of other model stages remains separate.

The forecast observer supports the recorded positive dense descriptors with nineteen rows and 506 columns. The body supports the larger declared geometry and signed-stride domain checked by the critical corpus. The actual forecast flags are all zero, while the critical corpus covers every canonical flag combination. There is no comparative timing or optimisation claim for this new complete body.

The fresh combined forecast also passes all twenty-five complete closures and 550 wave pairs. All 1,929,200 returned bytes and 6,309,600 before/after stage bytes directly match the independently checked pre-emission source. Its thirty-one paired stream records and all ten saved files compare directly with zero differing bytes. Remaining model stages and whole-forecast independent physics remain separate.

## Reproduction and Evidence

Run these commands through srun in your own quiet exclusive allocation. Select a fresh ignored output directory. The accepted SIMPLICO and ABI-observer objects are identified by hashes in the compact record.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
ulimit -c 0
review_dir="$PWD/.runtime/openifs/spcimpfsolve-7207705/reproduce"
mkdir -p "$review_dir"
gcc -fPIC -march=armv8-a+simd -DSPCIMPFSOLVE_ABI_PROBE \
 -c src/openifs/dynamics/spcimpfsolve.S -o "$review_dir/abi.o"
gcc -fPIC -march=armv8-a+simd \
 -DSPCIMPFSOLVE_ENTRY=spcimpfsolve_observed_assembly_ -DSPCIMPFSOLVE_STAGE_OBSERVER \
 -c src/openifs/dynamics/spcimpfsolve.S -o "$review_dir/observed.o"
cmp "$review_dir/abi.o" .runtime/openifs/spcimpfsolve-7207705/build/spcimpfsolve-abi.o
cmp "$review_dir/observed.o" .runtime/openifs/spcimpfsolve-7207705/build/spcimpfsolve-observed.o
gcc -O2 -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
 -Wall -Wextra -Werror bench/openifs/dynamics/spcimpfsolve.c \
 "$review_dir/abi.o" "$review_dir/observed.o" \
 .runtime/openifs/simplico/build/simplico.o .runtime/openifs/verdisint/build/vertical_abi.o \
 -L .runtime/openifs/strict-build/lib -larpifs.DP -lalgor.DP -lfiat -lm -ldl \
 -Wl,-rpath,"$PWD/.runtime/openifs/strict-build/lib" -o "$review_dir/verify"
OMP_NUM_THREADS=1 OMP_DYNAMIC=FALSE "$review_dir/verify" \
 "$review_dir/inputs.bin" "$review_dir/fortran.bin" "$review_dir/fortran-stages.bin" \
 "$review_dir/assembly.bin" "$review_dir/assembly-stages.bin" "$review_dir/summary.json" \
 .runtime/openifs/spcimpfsolve-7207705/preparation/critical-independent.bin > "$review_dir/verify.log" 2>&1
cmp "$review_dir/inputs.bin" .runtime/openifs/spcimpfsolve-7207705/preparation/critical-inputs.bin
cmp "$review_dir/fortran.bin" .runtime/openifs/spcimpfsolve-7207705/preparation/critical-fortran.bin
cmp "$review_dir/fortran.bin" "$review_dir/assembly.bin"
cmp "$review_dir/fortran-stages.bin" .runtime/openifs/spcimpfsolve-7207705/preparation/critical-fortran-stages.bin
cmp "$review_dir/fortran-stages.bin" "$review_dir/assembly-stages.bin"
cat "$review_dir/summary.json"```

The direct-register build adds only an argument-loading tail veneer. The stage-observation build forwards complete arguments to the accepted numerical helper. The primary instruction bytes remain identical apart from that call's observer relocation. Every cmp command must return zero.

Build the forecast observer without SPCIMPFSOLVE_MINIMAL_SCOPE when the accepted SPCIMPFPOST observer already supplies the read-only SPCM scope. Keep that accepted observer and load one complete SPCIMPFSOLVE comparator. The compact record identifies the exact library and combined launch command. Isolated checks use SPCIMPFSOLVE_MINIMAL_SCOPE to supply that scope themselves.

The accepted isolated run is `.runtime/openifs/runs/strict-spcimpfsolve-assembly-7207705/t21/test_fc`. It ran on the exclusive own job 7207705, node `nid011311`, with `map_cpu:32`, local memory placement, one process, one thread and `--mpi=cray_shasta`. Builds, source checks and simulations used that same own allocation. Instrumented forecast wall time is verification evidence and is not an accepted timing.

The [compact benchmark record](../../../../../bench/openifs/dynamics/spcimpfsolve.json) identifies every public file, frozen corpus, accepted object, source/native stream and saved model file. The ignored `accepted.json` manifest seals the release and exact command archive for parent review.
