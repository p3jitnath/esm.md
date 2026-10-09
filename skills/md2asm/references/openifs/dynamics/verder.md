# VERDER vertical differentiation

Revision 1 freezes the complete FP64 derivative helper under the [vertical-operator contract](verdisint.md). Its source snapshot is upstream utility/verder.F90. Let P=KPROMA, N=KFLEV_IN and M=KFLEV_OUT. The supplied M-by-N matrix encodes a first derivative, second derivative, or caller-defined inverse vertical operation. Because eta has no unit, the result keeps the input field's unit.

## Numerical stages and source row restriction

Require P,N,M at least one, KSTART=1 and 0 <= KPROF <= P. All arrays are contiguous FP64 in Fortran column order, aligned to eight bytes. Input, matrix and output storage are separate. Their capacities are P*N, M*N and P*M values. Used values, products and sums are finite; byte addresses fit signed 64-bit arithmetic.

The source passes unshifted input and output bases to DGEMM for H=KPROF-KSTART+1. If KSTART exceeds one, it writes rows 1:H instead of the documented interval KSTART:KPROF. This contract rejects that case rather than silently shifting its pointers. Empty work uses H=0 and changes no array bytes.

GNU JPRB and JPRD are both eight-byte FP64. The source's precision-conversion branch is therefore inactive. Apply the complete [ordered matrix calculation](strict_matrix.md) to every active point and output row, including every zero coefficient and both rounding stages in increasing input-column order. There is no further arithmetic or boundary stage. Preserve every inactive output point, input and matrix byte. A driver cannot provide any part of the reduction.

## Interface

Export verder_ by default, with VERDER_ENTRY available at assembly time for an isolated comparison name. Registers x0 through x7 hold addresses of P, KSTART, KPROF, N, M, matrix, input and output. There are no stack arguments. Integers are four bytes and values eight bytes.

Preserve x19 through x29, the link register, and the low 64 bits of v8 through v15. Keep SP aligned to 16 bytes and leave x18 unused. FPCR must be zero and remain zero. Invalid shapes or row intervals call ABOR1. The numerical dependency is the directly emitted private ordered matrix function; source profiling calls add no numerical stage.

## Verification

The common critical verifier checks constant and polynomial first and second derivatives, distinct rectangular input/output shapes, zero active points, inactive rows, the actual L-column FDER/DDER allocation, protected array ends, signed-zero and subnormal behavior, and complete output bytes against the unchanged renamed Fortran helper with the same matrix dependency. Exact acceptance is zero differing bytes. Direct VERDER calls in CPEULDYN remain part of the public full-forecast dependency set.
