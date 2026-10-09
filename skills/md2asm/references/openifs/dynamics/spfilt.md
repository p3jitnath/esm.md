# OpenIFS spectral vorticity filter

Revision 1.1 records forecast acceptance for the complete filter frozen at numerical revision 1.0 from [atmospheric motion](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), equation P03. Vorticity measures local rotation and has units s⁻¹. A spectral coefficient gives the strength of one spatial pattern. Its integer degree counts spatial variation, while its atmospheric level selects height. This filter multiplies selected vorticity coefficients by a positive factor no greater than one.

## Physical and numerical contract

Let $`N`$ be the largest degree, $`n`$ a coefficient's degree, and $`\omega`$ its vorticity. The filter uses the following dimensionless values. Here NINT rounds to the nearest integer, with ties away from zero.

```math
g=\operatorname{NINT}(2N/3)-1,\qquad s=\operatorname{NINT}(0.83N)-g,\qquad i=n+s.
```

```math
f=
\begin{cases}
32\exp\left[-\dfrac{(i-N)^2}{2(i-g)^2}\right],&i>g,\\
0,&i\leq g,
\end{cases}
\qquad c=\frac{1}{1+f^2},\qquad \omega_{\rm out}=c\omega_{\rm in}.
```

The piecewise condition keeps the denominator positive. The factor stays between 1/1025 and one. For the T21 forecast, $`N=21`$, $`g=13`$, and $`s=4`$. Degree-one rigid rotation is preserved, and degree 17 has the strongest damping. This filter does not damp every higher degree more strongly. Divergence and all other fields remain unchanged.

Use the unchanged OpenIFS 48.1.1 SPFILT source as the discrete reference. Its SHA-256 is 7bd9d9cec8cba831bce0e72f51949d308a7003e7d4a752a1b90ec15e86de8295. Freeze source, input bytes, independent factors and reference outputs before emitting direct assembly. The observable route uses the formulation, these equations, original source and storage-only ABI probes. Compiler numerical assembly and intermediate representations must not construct the direct solver.

FP64 arithmetic uses round-to-nearest with ties to even, gradual underflow and preserved signed zeros, with FPCR zero. NINT is a separate integer conversion with ties away from zero. First form integer 2N, convert it exactly, divide by three, convert with NINT and subtract one. Form 0.83N with binary constant 0x3fea8f5c28f5c28f, convert with NINT and subtract g. For each degree, form integer i and the two integer differences. Convert both differences exactly, square each separately, multiply the numerator by −0.5, divide by the squared denominator, call the frozen scalar exp, then multiply by 32. Square f, add one, divide one by that sum and multiply each selected vorticity. Each operation rounds separately. There is no contraction, reassociation, approximate arithmetic or reduced precision.

The frozen exp dependency is [pressure math](../pressure_math.md), with matched source and assembly calls. The direct solver performs every filter operation. Drivers supply buffers and compare results, while compilation and verification remain outside measured work.

## Storage and application binary interface

The AArch64 entry has five pointers in x0–x4, in order GEOMETRY, KSTA, KEND, PSPVOR and PSPDIV. KSTA and KEND point to 32-bit integers. GEOMETRY is the probed 17,096-byte GNU Fortran object, with NSMAX at byte 5172, NFLEVL at 5228 and the NVALUE descriptor at 3848. NVALUE is a contiguous rank-one 32-bit integer array. Its data pointer is at descriptor byte zero and actual lower bound at byte 48, so degree j is data[j−lower]. The configuration and degree storage are read-only.

PSPVOR and PSPDIV use 88-byte GNU Fortran rank-two FP64 descriptors. Data is at byte zero, row stride at 40, row bounds at 48/56, column stride at 64 and column bounds at 72/80. Strides count elements and can be positive or negative. Assumed-shape arguments rebase indices to one, so vorticity at level l and column j is data + 8[(l−1)row_stride + (j−1)column_stride]. Descriptor offset and actual lower bounds do not alter that address. Shape lengths still come from the actual bounds.

The supported domain is 0 ≤ NSMAX ≤ 4096, 0 ≤ NFLEVL ≤ 4096, and degrees between zero and NSMAX. Selected columns satisfy 1 ≤ KSTA ≤ KEND within the vorticity descriptor and degree allocation. An empty interval has KEND = KSTA−1. Selected levels fit the row extent. Integer setup and byte addresses must fit their declared integer widths. Every selected cell has distinct storage, and vorticity does not alias divergence, descriptors, geometry or degrees. FP64 data has eight-byte alignment and integer degrees have four-byte alignment. Inputs are finite, including signed zero and subnormal values. Zero levels and empty intervals do not access a field cell.

Only selected vorticity cells can change. Retain every other allocated byte, including padding, unused levels and columns, and all divergence storage. The solver preserves x19–x29, the low 64 bits of v8–v15, FPCR and a 16-byte-aligned stack, and does not use x18. The frozen study uses one execution thread. Independent concurrent calls with separate writable arrays must remain safe.

## Verification and evidence

Freeze a binary corpus covering threshold degrees, NINT ties, the 506 packed T21 coefficients, zero and odd level counts, both stride signs, unused storage, signed zero, subnormals and protected allocation ends. Compare every returned storage byte against unchanged source and its pre-emission outputs, requiring zero differences. Seed preserved registers at the direct assembly entry and check FPCR before and after every call.

Independently calculate each factor with 110-digit decimal arithmetic from the exact binary 0.83 constant and integer degrees. Each active output must be within 64 FP64 machine epsilons times the expected magnitude plus eight smallest subnormal units. This limit allows the separately rounded operations and the frozen exp error without fitting to sampled results. Check the factor bounds, no amplitude increase, exact preservation of the T21 degree-one pattern, unchanged divergence and inactive storage. Exact agreement and these physical checks are separate requirements.

Full-forecast acceptance must capture the complete caller allocations and every selected field, compare the paired source and native streams directly, and compare the ten saved forecast files with the frozen Fortran baseline. Record actual degree order, calls, hashes and failures in the compact benchmark record, with full artifacts in ignored .runtime/. Timing and performance claims require a later matched quiet-node measurement.

## Accepted checks and reproduction

The complete body passes 146 frozen cases and 484,240 canonical record bytes, including each 128-byte case header and every field allocation byte. Both implementations pass 36,014 independent active-value checks each. Two additional cases check actual zero-row and zero-column descriptors with field data at the protected allocation end. Their 544 record bytes match separately frozen source outputs. The original 146 cases and numerical body remain unchanged. The direct entry passes 148 preserved-register checks, while read-only inputs and protected allocation ends cover every case. Post-emission audits decode 104 native instructions and 176 source instructions, with no forbidden arithmetic.

The full T21 forecast accepts all 25 calls, with 3,845,600 returned allocation bytes and 3,902,600 canonical stream bytes. It checks 240,350 active values and preserves 1,900 degree-one values exactly. The actual full module arrays have 19 levels and 506 columns each. The observer verifies their complete descriptors against the module allocations and records the full NVALUE allocation. All 21 paired streams and ten saved files compare directly with zero differing bytes. Whole-forecast physical validation and comparative timing remain unfinished.

Run these commands through srun in a quiet exclusive allocation. The frozen corpus, independent factors, build commands and failed initial assembler invocation are preserved under ignored .runtime/openifs/spfilt/. The [critical verifier](../../../../../bench/openifs/dynamics/spfilt.c) uses the shared register checker and a small [direct-entry bridge](../../../../../bench/openifs/dynamics/spfilt_abi.S). The [forecast observer](../../../../../bench/openifs/dynamics/spfilt_forecast.c) performs no numerical solver stage.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
r="$PWD/.runtime/openifs/spfilt"
strict_build="$PWD/.runtime/openifs/strict-build"
gcc -fPIC -DSPFILT_ENTRY=spfilt_assembly_ -c src/openifs/dynamics/spfilt.S -o "$r/assembly.o"
gcc -c bench/openifs/dynamics/spfilt_abi.S -o "$r/abi-bridge.o"
gcc -c bench/openifs/dynamics/vertical_abi.S -o "$r/vertical-abi.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  bench/openifs/dynamics/spfilt.c "$r/assembly.o" "$r/abi-bridge.o" "$r/vertical-abi.o" \
  -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl \
  -Wl,-rpath,"$strict_build/lib" -o "$r/verify"
OMP_NUM_THREADS=1 OMP_DYNAMIC=FALSE \
  LD_PRELOAD="$PWD/.runtime/openifs/strict-math/libpressure-math.so" \
  "$r/verify" "$r/preparation/input-corpus.bin" "$r/new-assembly.bin" "$r/new-fortran.bin"
cmp "$r/new-assembly.bin" "$r/new-fortran.bin"
cmp "$r/new-fortran.bin" "$r/preparation/reference.bin"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC -Wall -Wextra -Werror \
  "-DSPFILT_FACTOR_FILE=\"$r/preparation/factors-by-degree.bin\"" \
  -c bench/openifs/dynamics/spfilt_forecast.c -o "$r/forecast.o"
gcc -shared -Wl,-Bsymbolic "$r/forecast.o" "$r/assembly.o" -ldl -lpthread -lm \
  -o "$r/forecast/libverify-spfilt.so"
```

The [compact record](../../../../../bench/openifs/dynamics/spfilt.json) identifies the accepted source, frozen input and output hashes, actual node, comparison streams and original Fortran baseline. The separately rounded scalar exp library remains a required preload for both implementations.
