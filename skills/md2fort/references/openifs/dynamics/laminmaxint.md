# Eight-Neighbour Field Bounds

Documentation revision 1.2 preserves frozen numerical contract 1.0 and the complete finite-input LAMINMAXINT calculation in the original OpenIFS source. Before the assembly is emitted, the original source, complete captured arrays, independent mathematical checks and ordered selections are frozen together. The leaf finds local lower and upper bounds for the later field correction. It does not perform that correction or establish conservation for the complete forecast.

## Physical Meaning And Mathematics

A departure point is the earlier location from which moving air reaches a grid point. Its surrounding grid cells give eight neighbouring field values. The smallest and largest values define the local range used by the original correction caller. Each returned bound has the same units as the supplied field. A mass mixing ratio, for example, is measured in kilograms of substance per kilogram of air.

Let $`A`$ be the source plane length, $`B`$ the destination row length, $`L`$ the number of destination levels and $`C=BL`$ the complete destination capacity. The inclusive one-based destination row limits are $`S`$ and $`E`$. The source field labels run from $`N_0`$ to $`N_1`$, giving $`F=N_1-N_0+1`$ source planes and $`AF`$ field values. Labels identify the outer source dimension. They may be zero or negative and do not change the following flattened addresses.

Use zero-based array positions in this explanation. At row $`j`$ and level $`l`$, the destination position is $`i=j+Bl`$. Two values from the second and third of the four complete integer index planes are $`k_1=K_{i+C}`$ and $`k_2=K_{i+2C}`$. The source field is $`f`$. The original operand order is

```math
\begin{aligned}
v_0&=f_{k_1+A}, &v_1&=f_{k_1+A+1},\\
v_2&=f_{k_2+A}, &v_3&=f_{k_2+A+1},\\
v_4&=f_{k_1+2A}, &v_5&=f_{k_1+2A+1},\\
v_6&=f_{k_2+2A}, &v_7&=f_{k_2+2A+1}.
\end{aligned}
```

The minimum $`m_i`$ and optional maximum $`M_i`$ are

```math
m_i=\min(v_0,v_1,v_2,v_3,v_4,v_5,v_6,v_7),\qquad
M_i=\max(v_0,v_1,v_2,v_3,v_4,v_5,v_6,v_7).
```

The leaf writes only rows $`S-1\le j<E`$ at all $`L`$ levels. Every other output byte stays unchanged. If $`S>E`$ or $`L=0`$, it writes nothing. An absent maximum pointer requests the complete minimum-only calculation.

## Ordered Selection And Floating-Point Rules

For each bound, select the first two operands, then include operands two through seven in the stated order. Seven scalar `fmin` operations produce the minimum. If the maximum is present, seven scalar `fmax` operations produce the maximum. Both passes read the same eight original values. No driver supplies a selection or another numerical stage.

Selected values must be finite FP64 numbers, which use the 64-bit floating-point format. Preserve each selected bit pattern, including small subnormal values and signed zeros. A source-only probe tests all 256 assignments of positive and negative zero to the eight corners, with and without the optional maximum. The original minimum chooses negative zero if any tied zero has that sign. The original maximum chooses positive zero if any tied zero has that sign. Seven ordered Arm `fmin` and `fmax` selections obey these rules for the accepted finite domain.

The floating-point control register, FPCR, must be zero at entry and return. This establishes round-to-nearest with ties to even and gradual underflow. The leaf contains no floating-point addition, multiplication, division or square root. Fused multiply-add, approximate arithmetic, reassociation, reduced precision and fast-math remain forbidden. Unused field values and incoming outputs are opaque bytes, so they may contain non-finite representations without entering a selection.

## Complete Interface And Storage

The application binary interface, or ABI, defines how a caller passes arguments and which registers a function preserves. The original routine takes eleven ordinary pointers in the order below. Its `JPIM` and `JPIA` integers are both signed 32-bit values. Its `JPRB` reals are FP64. A typed original-module probe verifies these widths. The optional argument is absent exactly when its pointer is null. It has no extra source Boolean argument.

| Position | Original argument | Complete storage and use |
| --- | --- | --- |
| 0 | `KPROMA` | One 32-bit input $`A`$ |
| 1 | `KPROMB` | One 32-bit input $`B`$ |
| 2 | `KST` | One 32-bit input $`S`$ |
| 3 | `KPROF` | One 32-bit input $`E`$ |
| 4 | `KFLEV` | One 32-bit input $`L`$ |
| 5 | `KFLDN` | One 32-bit input $`N_0`$ |
| 6 | `KFLDX` | One 32-bit input $`N_1`$ |
| 7 | `KL0` | All $`4C`$ 32-bit index values, including unused planes zero and three |
| 8 | `PXSL` | All $`AF`$ FP64 field values |
| 9 | `PMINVFLD` | All $`C`$ FP64 values, preserving inactive incoming bytes |
| 10 | `PMAXVFLD` | All $`C`$ FP64 values when present, otherwise a null pointer |

Arguments zero through seven use registers `x0` through `x7`. The remaining three pointers use caller stack offsets zero, eight and sixteen bytes. Integer storage requires four-byte alignment and real storage requires eight-byte alignment. Both complete output buffers are disjoint from every input and from each other. Read-only inputs may overlap. The leaf preserves the stack pointer, reserved register `x18`, all required saved general and floating-point registers, FPCR and every input byte. The accepted complete body has no private stack frame and no helper call.

For a present maximum with zero extent, the verifier supplies a nonnull aligned protected eight-byte placeholder and checks its complete sentinel. This establishes pointer presence without inventing formal output elements. The recorded maximum-presence value is exactly zero or one. The original typed probe also verifies four-byte logical false zero and true one, although this leaf passes no logical argument.

## Supported Bounds

Require $`0\le A\le 1\,048\,576`$, $`0\le B\le4096`$, $`0\le L\le512`$, $`0\le F\le1024`$ and $`AF\le2^{31}-1`$. Require $`1\le S\le B+1`$ and $`0\le E\le B`$. The field labels are signed 32-bit integers. Their difference is formed in a wider integer for validation, before the original routine runs.

For every selected destination, each source address $`o=k_p+hA+e`$ with $`p\in\{1,2\}`$, $`h\in\{1,2\}`$ and $`e\in\{0,1\}`$ must satisfy $`0\le o<AF`$ and $`o<2^{31}-1`$. Thus every original one-based address $`o+1`$ also fits its declared signed 32-bit domain. Validate all eight values as finite before either numerical body runs. Preserve complete buffer sizes even when only part of a row is selected. Empty shapes retain complete incoming outputs and do not dereference absent or zero-extent arrays.

## Independent Mathematical Acceptance

The independent checker enumerates the eight surrounding values using the two planes, two levels and two east positions. For each returned minimum, it checks all eight inequalities $`m_i\le v_r`$ and membership in the neighbour set. For a returned maximum, it checks all eight inequalities $`v_r\le M_i`$ and the same membership rule. These conditions prove the real extrema without generating an output stage. Source-probed signed-zero checks then establish the representation of tied zero extrema. No numerical tolerance is used.

The original-only corpus contains 792 complete records, covering partial rows, empty shapes, absent and present maxima, signed field labels, repeated addresses, finite extremes, subnormal values and all 256 zero-sign patterns. Replaying every record at both protected buffer placements gives 1,584 calls, 483,264 returned bytes and 410,100 independent relations. All complete returned bytes agree. Guard pages, protected input pages and unchanged padding check complete buffer bounds and read-only obligations. Nine malformed-input cases reject noncanonical presence, invalid shapes, overflowing label differences, invalid gathers, non-finite selected values and a truncated next header before executing the invalid record.

## Actual Forecast Call And Complete Capture

The standalone source observer accepts only the original local OpenMP function `qmfixer_._omp_fn.6` at return offset `0x275dcc` in the frozen strict source library, with original phases zero through twenty-four. The original full symbol table and source line lookup establish this site independently. QMFIXER declares separate complete `ZMINVFLD` and `ZMAXVFLD` arrays of shape $`B\times L`$ at source lines 149–150 and passes both whole allocations at lines 394–396. The observer therefore retains complete capacities, including untouched row cells. It does not use a guessed dynamically exported caller name.

The fresh original-only forecast contains 10,750 calls. Of these, 10,625 have $`A=3101`$, $`B=24`$, $`S=1`$, $`E=24`$, $`L=19`$, $`N_0=0`$ and $`N_1=20`$. The remaining 125 use $`E=8`$ with every other shape value unchanged. All actual calls request the maximum. The selected index values span 68 to 55,059. Every selected source address fits the complete 65,121-value field and the original integer domain.

The archive retains 5,757,958,000 complete incoming bytes and 79,120,000 complete returned bytes, including headers. All 10 saved forecast files directly match the canonical strict forecast across 618,140 bytes. Original replay at both protected placements gives 21,500 calls, 158,240,000 complete returned bytes and 187,949,164 independent relations, with zero differing bytes. The original standalone control disables only profiling and uses no replacement numerical helper.

NEGFIXER, JMGFIXER and other QMFIXER sites are outside this observer domain. QMFIXER2 passes slices of larger local families, whose enclosing capacities need a separate source proof before forecast replacement. These observer exclusions do not change the independently supplied complete-buffer leaf domain above.

## Raw Record Format And Generation Route

Every record has a 64-byte little-endian header with two unsigned 64-bit identifiers followed by twelve signed 32-bit values. The identifiers are the call number and original return-site offset. The first metadata values hold phase, site or critical profile, and canonical maximum presence. The next seven preserve the complete shape arguments. The final two are zero. Payload order is all four index planes, the complete source field, the incoming minimum and the incoming maximum when present.

If $`P\in\{0,1\}`$ denotes maximum presence, a complete input record occupies $`64+16C+8AF+8C(1+P)`$ bytes. A complete returned record occupies $`64+8C(1+P)`$ bytes. Preserve every header and payload bit. Compare whole source and native returns directly, retaining the first call, phase, field, cell and differing bit patterns on failure. Hashes identify immutable files and do not replace byte comparison.

The LLM emits the complete AArch64 primary directly from these equations, storage bounds and original operand order. Only an assembler and linker build its numerical body. Compiler-generated numerical assembly, intermediate representations and high-level solver emission are excluded from construction. Compiled original Fortran remains the separate comparison control. Build and verification commands run on CPU 32 in exclusive allocation 7207705 on nid011311. Any later comparative timing requires a separately coordinated quiet-node window and complete exact final-state acceptance.


## Accepted First Body

The unchanged first assembly body contains 62 instructions and occupies 248 function bytes. It performs every selected minimum and optional maximum, with no helper or driver-supplied calculation. Independent original-science, exact pre-emission identity and first-body ABI reviews all pass. The source and native bodies are checked separately against the physical inequalities and membership rules before their complete returned bytes are compared.

| Verification | Native calls | Complete returned bytes | Differing bytes |
| --- | ---: | ---: | ---: |
| 792 frozen critical records at both protected placements | 1,584 | 483,264 | 0 |
| Four groups of three genuine threads | 12 | 1,128 | 0 |
| 10,750 original forecast records at both placements | 21,500 | 158,240,000 | 0 |
| 10,750 fresh forecast records at both placements | 21,500 | 158,240,000 | 0 |
| Fresh same-input source and native forecast | 10,750 | 79,120,000 | 0 |

Every protected replay and worker call has an explicit saved-register ABI check. The forecast forwards the complete original arguments and checks FPCR, full storage and returned bytes. Each three-thread group uses a barrier to start three distinct real worker threads with separate protected buffers. All workers stay on the one allocated CPU 32. This checks independent call storage and register obligations. It is not a multicore performance measurement. All nine invalid-input guards pass, and an intentional one-bit change to a frozen expected minimum confirms that the diagnostic reports the first stage, call, phase, field, cell and bit patterns.

The complete fresh returned stream also directly equals the original pre-emission source stream, including inactive cells. The complete incoming streams retain 233,611 differing bytes across independent runs. These comprise 191,375 unused index bytes and 42,236 incoming bound bytes that the leaf overwrites. Complete physical fields, selected integer indices, all eight gathered values and active outputs agree exactly. Whole original and fresh incoming buffers remain archived. Both complete frozen-input replays pass without masking or normalisation.

All ten fresh saved files directly equal the canonical strict forecast across 618,140 bytes. The numerical comparison covers this complete leaf and its declared caller scope. Other forecast routines remain separate stages. No comparative timing or whole-forecast speed claim is accepted.

## Reproduce The Accepted Objects And Checks

Run this recipe from the repository root inside the assigned exclusive compute-node step, with the documented CPU affinity and local memory placement. The original strict OpenIFS library and frozen source captures must be present. Choose a fresh output folder for each run. The recipe stops if that folder already exists. It compiles only the comparison driver and assembles the complete direct body. The ABI checker seeds the required saved registers around each native call.

```bash
set -euo pipefail
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
ulimit -c 0
task_build=.runtime/openifs/laminmaxint-7207705/new-public-reproduction
task_source=.runtime/openifs/laminmaxint-7207705/preparation
task_original=.runtime/openifs/runs/strict-laminmaxint-source-complete2-7207705/t21/test_fc
task_fresh=.runtime/openifs/runs/strict-laminmaxint-native-isolated-7207705/t21/test_fc
mkdir "$task_build"
gcc -mcpu=neoverse-v2 -c src/openifs/dynamics/laminmaxint.S -o "$task_build/solver.o"
gcc -mcpu=neoverse-v2 -c bench/openifs/dynamics/vertical_abi.S -o "$task_build/abi.o"
gcc -O2 -mcpu=neoverse-v2 -fno-fast-math -fno-associative-math -ffp-contract=off .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laminmaxint.c "$task_build/solver.o" "$task_build/abi.o" -ldl -lm -pthread -o "$task_build/laminmaxint-verify"
gcc -O2 -mcpu=neoverse-v2 -fno-fast-math -fno-associative-math -ffp-contract=off -fPIC -shared .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/laminmaxint_forecast.c "$task_build/solver.o" -ldl -lm -o "$task_build/libverify-laminmaxint.so"
"$task_build/laminmaxint-verify" --replay "$task_source/critical-corpus-v1.bin" "$task_source/critical-fortran-v1.bin"
"$task_build/laminmaxint-verify" --replay "$task_original/laminmaxint-inputs.bin" "$task_original/laminmaxint-fortran.bin"
"$task_build/laminmaxint-verify" --replay "$task_fresh/laminmaxint-inputs.bin" "$task_fresh/laminmaxint-fortran.bin"
```

The forecast comparator defines only the LAMINMAXINT relay and the complete primary. It needs no parent scope relay and no optional setup hook. In an isolated forecast, preload it before the immutable ordered-vertical reference and pressure-math library. In a combined forecast, preserve the existing accepted preload chain and add this comparator once. Use one process and one thread with the complete original QMFIXER call-site guard. Each forecast case must be new because capture files are created exclusively. Preserve both complete `laminmaxint-fortran.bin` and `laminmaxint-assembly.bin` streams, the full `laminmaxint-inputs.bin` file and metadata.

The combined forecast keeps all 37 previous libraries unchanged and adds this reproduced comparator. All 47 complete paired streams pass across 6,828,118,408 bytes, and all ten saved files pass across 618,140 bytes, with zero differences. All 10,750 complete minimum and maximum returns also directly equal the original source capture, including inactive cells. Its fresh incoming arrays retain 280,188 different bytes, comprising 237,375 unused index bytes and 42,813 overwritten output bytes. The complete physical field, used indices and gathered corner values agree, and no incoming value is repaired. This result does not claim whole fresh input equality or complete assembly forecast coverage.

## Runtime Operational Shapes

The unchanged numerical bodies now also pass a component check at 17 columns and 137 levels with source-plane lengths 1,744,925 and 1,783,837. The same objects cover smaller shapes, shifted and final-two work, zero levels, empty work and an absent maximum output. Across both children, all 479,280 complete output bytes and 768 raw-status bytes match the unchanged original objects. Each route passes 68,646 independent affine-field, extrema and unchanged-cell relations. Native ABI checks, read-only source storage and output guards pass. These checks establish runtime shape and address support for the two leaves, while the enclosing operational mass-correction caller and forecast remain unverified. Detailed records remain in the ignored local research folder.
