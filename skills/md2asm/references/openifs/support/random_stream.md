# OpenIFS random stream

Implementation revision 1.4 preserves the complete numerical bodies of `random_numbers_mix::uniform_distribution` and `random_numbers_mix::initialize_random_numbers` from OpenIFS 48.1.1, in `algor/module/random_numbers_mix.F90`. The [physical input](../../../../../formulations/openifs/support/random_stream.md) defines the lagged integer sequence and its conversion to a sample. These routines support cloud sampling and do not advance the atmospheric equations.

## State and ordered calculations

The stream retains 607 unsigned 30-bit integers, the number already consumed from the current batch and a marker that identifies initialized storage. Integer additions use the low 32 bits, then a bit mask retains the low 30 bits. The two operands sum to at most $`2^{31}-2`$, so valid states do not overflow a signed 32-bit sum. Each refill evaluates equation P01 for a complete batch of 607 samples. Values already present but not consumed are returned before another refill.

Conversion first converts each nonnegative integer exactly to FP64, the 64-bit floating-point format, then multiplies by the stored FP64 value $`2^{-30}`$. Both operations are exact on this domain. Use zero in FPCR, the floating-point control register. This selects rounding to nearest with ties to even, gradual underflow and preserved signed zeros. Do not use fused arithmetic, approximate operations or reduced precision.

An exclusive OR, written XOR, sets an output bit to one when the corresponding input bits differ.

For initialization, XOR the seed's 32-bit pattern with 123459876, interpret that result as a signed 32-bit integer and take its absolute value before replacing zero by 123459876. The target retains the bit pattern 0x80000000 when that result is the smallest signed integer, whose positive magnitude cannot fit signed 32-bit storage. The shift register then treats every stored pattern as 32 bits. Negative seeds occur in the actual weather caller and follow this same original route. A 32-bit shift register advances by shifting left one bit, discarding its old highest bit and, when that bit was one, XORing the result with 175. Advance it 64 times. Set the first 606 integers to zero, set integer 2 to twice the low 29 register bits and set integer 607 to the register's high three bits. For bit positions 1 through 29, advance the register for integers 3 through 606 and set that bit in the integer when the discarded register bit was one. Set bit zero of integer 502. Store used count 607, marker 12345678 and scale $`2^{-30}`$, then consume and discard 999 samples through the complete uniform body. The returned used count is 392. Initialization preserves the four padding bytes in the stream.

## Equivalent Grouped Initialisation

The direct initializer evaluates sixteen consecutive shift-register transitions together, preserving the same integer recurrence and sample sequence. Let `r` be the current unsigned 32-bit register. Shifting right by 24 selects its highest eight bits. Each value `T8[n]` comes from starting with `n << 24` and applying the original one-bit rule eight times. The unchanged table contains 256 four-byte words, each below two raised to 15.

```text
F8(r) = ((r << 8) & 0xffffffff) XOR T8[r >> 24]
F16(r) = ((r << 16) & 0xffffffff)
         XOR (T8[r >> 24] << 8)
         XOR T8[(r >> 16) & 255]
```

`F8` advances the register by eight original steps. Its feedback cannot reach the high byte, so that byte equals the old bits 23 through 16. Therefore `F16` is exactly two applications of `F8`, with both table indices obtained from the same old register. The mask retains 32-bit wrap. The discarded bits are the old bits 31 through 16, in order, because feedback cannot reach them within sixteen steps. Checking the zero word and all 32 single-bit basis words proves the complete linear transition and outgoing-bit order.

For each bit position from one through 29, process 37 groups of sixteen interior integers, then use the qualified eight-value and four-value tails. Each plane still advances exactly 604 times. Four vectors use lane shifts zero through three, four through seven, eight through eleven and twelve through fifteen. A right shift that repeats the sign bit turns each outgoing bit into a whole-lane mask. Masking by the current bit-position value and combining it with the destination by OR sets exactly the original output bits. The four-step table still supplies the 64 initial advances and four-value tail. The complete uniform child still discards all 999 warm-up samples.

## ABI and bounds

The application binary interface, ABI, defines how the caller passes arguments and which registers a function preserves. The native target is AArch64 Armv8-A. The uniform entry receives a GNU Fortran rank-one FP64 array descriptor in `x0` and the mutable stream address in `x1`. The descriptor is 64 readable bytes. Its base address is at byte 0, element stride at byte 40, lower bound at byte 48 and upper bound at byte 56. The number of samples is the nonnegative upper bound minus lower bound plus one. A zero descriptor stride means one, matching the original GNU interface. Other strides can be positive or negative.

The stream occupies 2448 writable bytes aligned to eight bytes. Its used count is a four-byte integer at byte 0, its marker is at byte 4, its 607 four-byte integers start at byte 8, four untouched padding bytes start at byte 2436 and its eight-byte scale starts at byte 2440. Valid input has used count from zero through 607, marker 12345678, 30-bit integers and scale $`2^{-30}`$. The output array and stream are disjoint. Every selected output element is eight writable bytes aligned to eight bytes. A zero-length array needs no accessible output element and leaves the stream unchanged. Descriptor bounds and their resulting byte offsets must fit signed 64-bit addressing, and the element count must fit a nonnegative signed 32-bit integer.

The initialization entry receives the address of a four-byte seed in `x0` and the stream address in `x1`. The seed is from $`-2^{31}`$ through $`2^{31}-1`$ and remains unchanged. The seed and stream are disjoint. The initialization frame is 8016 bytes, keeps the stack aligned to 16 bytes and owns all 999 discarded FP64 samples. The complete assembly retains its warm-up inside the direct solver, so no driver supplies a missing stage.

The grouped initializer clears exactly state bytes 8 through 2431 with 151 stores of 16 zero bytes and one final store of eight zero bytes. It sets integer 607 separately at bytes 2432 through 2435. The sixteen-value loop uses paired vector loads and stores over bytes 16 through 2383. Its eight-value tail covers bytes 2384 through 2415, and its four-value tail covers bytes 2416 through 2431. The eight-step table has exactly 256 readable four-byte entries, and the retained four-step table has 16. Ordinary AArch64 vector loads and stores support the declared eight-byte state alignment; no 16-byte state alignment or extra accessible state bytes are required. The four padding bytes remain untouched.

Both entries preserve `x19` through `x29`, the low 64 bits of `v8` through `v15`, the 16-byte-aligned incoming stack pointer and FPCR. They do not use `x18`. Profiling hooks and the original abort for an uninitialized stream are outside the valid numerical input domain. Initialization's original profiling hook is retained by the original side of the paired forecast observer.

The grouped seed expansion uses only integer arithmetic, vector integer shifts and bit operations. They use caller-saved registers, leave `x18` and `v8` through `v15` unused, and make no external call. The unchanged uniform child still runs inside initialization. Valid calls preserve FPSR, the floating-point status register, and `errno`, the library error indicator, as well as FPCR. The stream conversion remains exact, so it adds no floating-point exception flag.

## Independent checks and canonical bytes

An independent integer verifier uses a queue of 607 states and generates each next state by adding the oldest state to the state 334 places after it, taking the integer remainder modulo $`2^{30}`$, then shifting the queue by one position. This form checks the mathematical sequence independently of the source's three refill loops. It expands the seed with an integer polynomial shift rule and compares the complete returned stream, including unchanged padding.

Critical cases cover the smallest and largest signed seeds, the observed forecast seed -275, seed XOR cancellation and the minimum XOR word, initialization, empty arrays, retained samples, exact refill boundaries, multiple refills, positive and negative strides, 30-bit extrema and call partitioning. Guard pages and poisoned gaps check output bounds and untouched storage. Every sample must lie in $`[0,1)`$ and be an exact multiple of $`2^{-30}`$. The immediate assembly ABI observer checks saved integer and FP64 registers and FPCR on each native call.

The sixteen-step transition and outgoing-bit order pass the zero word and all 32 basis words before source emission. The current changed-path gate checks 540 sixteen-value initializer calls against the retained independent integer verifier. Its 15 seeds, two protected placements, eight-byte and 16-byte state alignment, and nine inherited FPSR patterns preserve all 2448 stream bytes, neighbouring bytes, the seed, saved registers, FPCR, FPSR and errno values zero, 33 and 34, with zero differences. The compared stream and neighbour span is 1,324,080 bytes. The unchanged uniform consumer retains its earlier empty-array, stride, refill, call-partition and original-result checks.

The grouped source was written directly in AArch64 assembly from this integer recurrence and assembled with GNU GCC's assembler driver for Armv8.2-A with Advanced SIMD. No compiler-generated numerical assembly or high-level numerical child supplies its state expansion, clear or warm-up. The shortwave and longwave private entries compile this same source with distinct entry and uniform-child names. Local source hashes, exact build commands, table proof and independent source review identify the checked artifacts.

Canonical critical bytes concatenate the complete 2448-byte stream and the complete bounded output span, including untouched stride gaps, in little-endian order. The seed and descriptor remain unchanged. Accept only zero differing bytes against the original and the independent integer verifier. Statistical independence of cloud realizations and whole-forecast scientific verification remain outside these two bodies.

## Accepted forecast calls

The earlier scalar initializer and unchanged uniform consumer passed the 2026-10-10 combined forecast with 57,242,556 uniform calls and 93,100 initializer calls, including the observed negative seeds. It compared 1,039,017,360 output bytes and 140,357,685,888 complete-stream bytes with zero differences, and all ten saved forecast files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 with local memory binding. Statistical independence, whole-forecast physics and comparative speed remain outside this result.

The earlier four-value grouped initializer also passes the selected [autonomous forecast](../input/standalone_weather_forecast.md). The final comparison matches all 27,486,113 bytes in 685 owned buffers and all ten saved files, containing 618,140 bytes. This is a final-state and file comparison, separate from the earlier per-call stream observations. The declared process-boundary and physical-validation limits remain unchanged.

## Current Sixteen-Value Selection

All 540 protected calls and twelve matched quiet component pairs pass, preserving the complete 999-sample warm-up. Each measured pair favours the sixteen-value initializer over the selected eight-value implementation. Detailed measurements remain local. The joint seed-expansion and constant-load batch passes all 685 numerical owners over 27,486,113 bytes, ten files over 618,140 bytes and 59 final views, with zero differences. Natural status and ABI remain unchanged. Three matched ordinary forecast pairs give medians of 24.05 and 24.02 seconds, with all pairs favouring the candidate and overlapping full wall-time ranges. User-time medians are 22.52 and 22.38 seconds. The [README](../../../../../README.md) reports this combined scope. Known process-boundary differences and whole-forecast physical limits remain unchanged.
