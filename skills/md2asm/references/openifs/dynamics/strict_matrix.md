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

The critical verifier checks independently derived polynomial operators and the captured T21 integral matrix. It also checks a sum-of-squares matrix identity, empty dimensions, nonempty k=0, leading-dimension padding, signed zero, subnormal arithmetic, and witnesses that distinguish separate product rounding and increasing-column reduction from fused or reordered calculations. Exact comparison requires zero differing bytes. Independent analytical error limits are in [verdisint.md](verdisint.md). No timing or performance claim is part of this milestone.
