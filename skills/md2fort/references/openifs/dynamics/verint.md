# VERINT vertical integration

Revision 1 freezes the complete FP64 integral helper under the [vertical-operator contract](verdisint.md). Its source snapshot is upstream utility/verint.F90. The supplied M-by-N matrix contains integrals at its chosen result locations, and the P-by-N input contains the field at its input locations. P=KPROMA, N=KFLEV_IN and M=KFLEV_OUT. Eta is dimensionless, so the result keeps the input unit.

## Numerical stages

Require P,N,M at least one; 1 <= KSTART <= P; KSTART-1 <= KPROF <= P; KTYPE equal to zero or one; and KCHUNK at least one. Arrays are contiguous FP64 in Fortran column order, aligned to eight bytes, immutable except POUT, and separate from POUT. Input capacity is P*N values, matrix capacity M*N, and output capacity P*M. The matrix's output locations include eta=1 as its last row for bottom integration. All used values, products, sums and final differences are finite, and byte addresses fit signed 64-bit arithmetic.

Determine the actual parallel state with OML_IN_PARALLEL. Inside a parallel region, support KSTART=1 and use one matrix call for H=KPROF-KSTART+1 active points. The source passes unshifted bases in this branch; KSTART greater than one can leave undefined scratch rows and is rejected explicitly. Outside a parallel region, visit horizontal chunks starting at KSTART in increments of KCHUNK, with the final chunk shortened to the remaining points. Empty work changes no array bytes.

Each chunk obtains Q from the complete [ordered matrix calculation](strict_matrix.md), including every separately rounded product and accumulation in increasing input-column order. KTYPE=0 copies Q without changing its bits. KTYPE=1 performs one rounded subtraction per output:

```math
\mathrm{POUT}_{p,r}=
\operatorname{RN}_{64}(Q_{p,r}-Q_{p,M}).
```

Retain the last-row Q until every row uses it, and subtract it from itself in the last row to obtain positive zero. Do not subtract coefficients first, omit zero terms, combine reductions or fuse operations. The direct helper may retain Q in POUT before this last subtraction because inputs are separate and the last Q row is overwritten last. This changes no declared output or arithmetic dependency.

Preserve every inactive point in POUT and every input and coefficient byte. No driver supplies multiplication or bottom subtraction. Source profiling calls are outside the numerical body; its parallel-state query is part of the behavior.

## Interface

Export verint_ by default, with VERINT_ENTRY available at assembly time for an isolated comparison name. Registers x0 through x7 hold addresses of P, KSTART, KPROF, N, M, matrix, input and output. Incoming stack offsets zero and eight contain the KTYPE and KCHUNK addresses. All integers are four bytes and field values are eight bytes.

Preserve x19 through x29, the link register, and the low 64 bits of v8 through v15. Keep SP aligned to 16 bytes and leave x18 unused. FPCR must be zero on entry and remain zero. Invalid type, shape, interval, chunk or unsupported parallel start calls ABOR1. Use only the private direct ordered-matrix dependency, GNU/Fiat OML query and nonnumerical runtime support.

## Verification

Use the common critical verifier from [verdisint.md](verdisint.md). It checks top and bottom analytical integrals, the signed bottom direction, surface positive zero, active offsets outside parallel regions, actual parallel KSTART=1, empty work, chunks one and 24, shortened chunks, unchanged padding, protected array ends, and exact full-array bytes against the unchanged renamed Fortran source with the same private matrix dependency. Require zero differing bytes; scientific tolerances apply only to analytical targets.
