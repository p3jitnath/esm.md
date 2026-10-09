# Ordered FP64 vertical matrix multiplication

Revision 1 freezes the small matrix dependency used by the [vertical-operator contract](verdisint.md). FP64 is the 64-bit floating-point format. This dependency implements the one DGEMM operation required by these routines; DGEMM is a library interface for matrix multiplication. It does not replace other OpenIFS matrix calls.

## Shapes and complete source calls

Let P be KPROMA, H be KPROF-KSTART+1, N be KFLEV_IN, and M be KFLEV_OUT. The matrix A contains horizontal points by input columns. Matrix B contains output rows by input columns. All six source calls use the flags N,T, which mean A unchanged and B transposed. Alpha is exactly positive one, with bits 3ff0000000000000, and beta is exactly positive zero, with bits 0000000000000000.

| Source and line | Branch | m, n, k | A base | B base | C base | lda, ldb, ldc |
| --- | --- | --- | --- | --- | --- | --- |
| VERINT 144 | Inside a parallel region, nonempty | H, M, N | PIN | PINTE | ZOUT | P, M, P |
| VERINT 156 | Outside, ICHUNK=0; dormant | H, M, N | PIN | PINTE | ZOUT | P, M, P |
| VERINT 164 | Outside, ICHUNK=1; actual | JLEN, M, N | PIN(JROF,1) | PINTE | ZOUT(JROF,1) | P, M, P |
| VERINT 174 | Outside, ICHUNK=2; dormant | H, JLEN, N | PIN | PINTE(JLEV,1) | ZOUT(1,JLEV) | P, M, P |
| VERDER 120 | JPRB=JPRD; actual FP64 build | H, M, N | PIN | PDERI | POUT | P, M, P |
| VERDER 129 | Different precision; inactive | H, M, N | Converted ZIN | PDERI | ZOUT | P, M, P |

The active horizontal chunk has JROF=KSTART,KSTART+KCHUNK,..., and JLEN=min(KCHUNK,KPROF-JROF+1). The dormant output chunk uses JLEV=1,1+KCHUNK,..., and JLEN=min(KCHUNK,M-JLEV+1). Source ICHUNK is assigned one, so the dormant alternatives are documented and do not become new runtime options. The GNU module probe establishes JPRB=JPRD=8 bytes, so the precision-conversion branch is also inactive.

## Ordered arithmetic

Support only those exact flags and alpha/beta bits. Require nonnegative m,n,k, lda and ldc at least max(1,m), and ldb at least max(1,n). Values have eight-byte alignment. Used operands, products and sums must be finite. Arrays have separate storage, and all address calculations must fit signed 64-bit arithmetic. With zero-based indices, A(i,c) is at A+8*(i+lda*c), B(r,c) at B+8*(r+ldb*c), and C(i,r) at C+8*(i+ldc*r).

RN64 means rounding to FP64 with round-to-nearest and ties to an even last bit. Each output starts with positive zero and visits every input column in increasing order.

```math
s_0=+0,\qquad
t_c=\operatorname{RN}_{64}(A_{i,c}B_{r,c}),\qquad
s_c=\operatorname{RN}_{64}(s_{c-1}+t_c),\qquad
C_{i,r}=s_k.
```

Include zero terms. Keep the product and addition as separate rounded operations. For k=0, write positive zero. For m=0 or n=0, read and write no array bytes. Beta selects an operation which does not read incoming C; alpha adds no further multiplication. Independent points and output rows can be visited in any order. Leave all inactive C bytes unchanged.

Require FPCR=0, which selects the required rounding, gradual underflow and disabled traps on this target. Preserve FPCR and signed zeros. Forbid fused multiply-add, reassociation, tree reductions, approximate arithmetic, reduced precision and fast-math.

## AArch64 and GNU interface

Export the private hidden symbol verdisint_strict_nt_fp64_. Registers x0 through x7 hold addresses of transA, transB, m, n, k, alpha, A and lda. Incoming stack offsets 0,8,16,24,32 hold B, ldb, beta, C and ldc addresses; offsets 40 and 48 hold the two hidden character lengths by value as eight-byte size_t values, both one. Integers occupy four bytes. Preserve x19 through x29 and the required low 64 bits of v8 through v15; preserve the link register around calls, keep SP aligned to 16 bytes, and leave x18 unused.

The direct dependency must be emitted from this contract as AArch64 source and assembled. No compiler-generated solver instructions or intermediate representation may supply its body. Unsupported flags, signed alpha/beta alternatives, negative sizes or inadequate leading dimensions call ABOR1. Buffer capacities remain caller obligations.

## Shared reference and evidence

The unchanged Fortran VERINT and VERDER sources are compiled with only DGEMM renamed to this private dependency. The same direct object is linked with the complete direct routines and with the Fortran comparisons. A standalone libstrict-vertical-reference.so exports the original Fortran VERDISINT, VERINT and VERDER entries and binds its internal helper calls locally. Renamed comparison objects expose verdisint_reference_, verint_reference_ and verder_reference_ separately.

This defines a new arithmetic baseline. Existing CrayBLAS forecasts remain archived. The new route can change setup-derived coefficients because SUVFE_ADJUST_AB uses vertical integration. The new Fortran forecast and mixed assembly forecast must use the same new dependency and compare complete call and saved file bytes. No old BLAS bit agreement is assumed.

The critical verifier checks independently derived polynomial operators and the captured T21 integral matrix. It also checks a sum-of-squares matrix identity, empty dimensions, nonempty k=0, leading-dimension padding, signed zero, subnormal arithmetic, and witnesses that distinguish separate product rounding and increasing-column reduction from fused or reordered calculations. Exact comparison requires zero differing bytes. Independent analytical error limits are in [verdisint.md](verdisint.md). The numerical revision and every earlier critical output byte are preserved by the measured implementation below.


## Measured eight-point implementation

The selected implementation processes eight independent horizontal points with four two-value Arm NEON registers. Each point keeps its original increasing-column product and sum, so vector lanes never combine partial sums. One rounded matrix coefficient is shared across the eight points. Separate FMUL and FADD instructions preserve both rounding points. This argument applies to every finite operand in the frozen domain, including signed zero and subnormal values.

The ABI and numerical revision remain unchanged. Only caller-saved registers are used during normal work. Eight-byte array alignment is sufficient on this target. A group is loaded only when eight points remain, followed by bounded pairs and a final scalar point. Fewer than eight points use the original scalar loop. Zero dimensions, leading-dimension padding and the invalid-argument path retain their declared behaviour.

The following measurements time complete native VERINT calls with type zero and chunk size 24, including their private matrix operation. Both controls use the same public VERINT body, 20 output rows and 21 input columns. Values are medians with observed minimum–maximum ranges from twelve accepted paired repetitions. A microsecond, written µs, is one millionth of a second.

| Active points | Earlier scalar helper, µs | Eight-point helper, µs | Complete VERINT gain |
| --- | --- | --- | --- |
| 1 | 0.171 (0.169–0.185) | 0.172 (0.170–0.194) | 0.996× |
| 8 | 1.307 (1.299–1.336) | 0.418 (0.418–0.422) | 3.123× |
| 24 | 3.683 (3.666–3.692) | 1.218 (1.213–1.228) | 3.023× |
| 506 | 77.376 (77.129–89.600) | 25.891 (25.873–25.967) | 2.989× |

Measurements used Neoverse V2 on nid010825 in exclusive job 7189435, CPU 8 and local first-touch memory placement. The Slurm step reserved nine CPUs so that CPU 8 could be selected, while the operation used one execution thread. Both controls reused the same 64-byte-aligned arrays, with 32 warm-up calls and an approximately two-millisecond timing block. Compilation, initialisation and full input/output byte checks were outside the timer. An interrupted block discarded the complete paired rotation. The compact [vertical record](../../../../../bench/openifs/dynamics/verdisint.json) retains the median, range and median absolute deviation, which measures typical distance from the median.

For the 24-point private matrix call, the median falls from 3.685 to 1.212 µs. Its 20,160 separate arithmetic operations attain 16.63 billion operations per second. A compatible non-fused FP64 calibration gives a median of 25.31 billion operations per second, with a range of 24.23–25.53. A calibration retaining the same loads, stores, strides and branches gives an equivalent 27.34 billion operations per second, with a range of 26.00–27.39. The smaller measured limit is therefore 25.31, and the implementation reaches 65.7% of it. The same calculation gives 82.4%, 64.3% and 78.8% for the one-, eight- and 506-point matrix workloads.

These bounds describe warmed cache work on this processor. The 24-point arrays occupy 11,232 distinct bytes, while repeated instructions transfer 94,560 bytes per call at a read/write ratio of 23.625 to one. The 506-point arrays occupy 169,328 bytes. Instruction traffic is counted from the schedule and is not a measurement of main-memory transfers. The helper has no division or square root. Dependency latency, addressing and instruction issue can reduce the achieved rate, so the calibrated fraction does not establish global optimality or a complete-forecast speedup.

The [timing driver](../../../../../bench/openifs/dynamics/vertical_timing.c), [throughput probes](../../../../../bench/openifs/dynamics/vertical_throughput.S) and [VERINT ABI adapter](../../../../../bench/openifs/dynamics/vertical_timing_abi.S) preserve editable reproduction sources. The adapter only arranges arguments, leaving every numerical stage inside VERINT. Build commands, frozen input bytes, all tuning candidates and raw measurements remain in the ignored .runtime/openifs/matrix-tuning/ archive. Recover the scalar control from commit 7cb8bfbb004117dfcaaa30736e84c1d9e1b1e2b1 when reproducing this comparison.

The selected helper passes the original 163 critical calls and 1,454,464 raw bytes, with 174,451 independent values. Its instruction audit finds 168 instructions and zero forbidden arithmetic or writes to preserved registers. A fresh 24-hour T21 forecast preserves all eighteen paired streams across 1,618,789,200 bytes and all ten saved files against the earlier scalar-helper Fortran baseline. Captured matrices, grid coordinates and reciprocal layer widths retain their exact bits, with the original independent polynomial limits satisfied.
