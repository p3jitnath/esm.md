# Complete Spectral Semi-Implicit Atmospheric Update

Arithmetic revision 2 freezes the separately rounded matrix route for original SPCSI. The [physical input](../../../../../formulations/openifs/dynamics/spectral_semi_implicit_update.md) defines pressure and rotation. This parent owns the complete selected spectral calculation and calls verified assembly children. Its two matrix products use a new, independently checked FP64 reference. The earlier fused vendor reference remains preserved and is not claimed to have identical bytes.

## Physical And Numerical Meaning

A vertical mode is a weighted combination of atmospheric levels. Matrix $`A`$ is original SIMI and maps level coefficients to modes. Matrix $`B`$ is original SIMO and maps modes back to levels. Both have nineteen rows and nineteen columns. The caller supplies their complete coefficient arrays.

Use nineteen levels and the full degree-21 sphere, stored as 506 real and imaginary spectral columns. First column is one and last column is 506. This route uses the coupled implicit pressure-wave solve, with no stretching, no single-wave selection and no diagnostic updates. The vertical method uses finite elements and integral boundary three. Both parallel copy selectors are one, so each copy covers the complete field on one process.

The finite-element method represents vertical fields through local polynomials and integrates them using the supplied coefficient matrix. Its source approximation and physical checks remain those of [vertical integration](verdisint.md), [SIGAM](sigam.md) and [SITNU](sitnu.md). The complete pressure-wave system remains [SPCIMPFSOLVE](spcimpfsolve.md), including its independent dense-matrix check and complete [SIMPLICO](simplico.md) assembly child.

## Complete Ordered Update

RN means one FP64 operation rounded to nearest with ties to even. Each multiplication, addition and subtraction has its own rounding point. Use FPCR zero, gradual underflow and preserved signed zero. Fused products, contraction, reassociation, reduced precision and approximate arithmetic are forbidden.

Let $`b=\operatorname{RN}(\mathrm{RBTS2}\,\mathrm{TDT})`$ be the source time weight in seconds. In the current source input, RBTS2 is one half and TDT is 3600 seconds. Let $`s=\mathrm{RSTRET}=1`$ be the stretching factor. The caller's auxiliary field $`r`$ contains the prepared rotation contribution in inverse seconds. The degree table selects $`\lambda`$ for each column.

Perform these stages in order. The source row and column order is preserved.

```text
gamma = complete SIGAM(T, q)
rhs = RN(RN(D - RN(RN(b * lambda) * gamma)) + r)
modes = ordered_matrix(A, rhs)
solved_modes = complete SPCIMPFSOLVE(modes)
D_new = ordered_matrix(B, solved_modes)
velocity = RN(RN(D_new * s) * s)
tau, nu = complete SITNU(velocity)
T_new = RN(T - RN(b * tau))
q_new = RN(q - RN(b * nu))
```

For each matrix output, start at positive zero. Visit contraction index one through nineteen in increasing order. At every index, first round the product and then round its addition to the sum. The contraction index is the vertical level or mode over which the matrix product sums. Independent outputs can share a coefficient, but each output retains these nineteen ordered product and addition steps.

Complete SIGAM forms hydrostatic geopotential. Complete SPCIMPFSOLVE builds the pressure and rotation coefficients, makes both full single-process copies and solves every wave. Complete SITNU obtains the temperature and ground-pressure rates. The parent performs both dense matrix products and every final temperature and pressure assignment. The driver supplies no numerical stage.

The two source matrices are located at dynamics descriptor offsets 3224 for SIMI and 3136 for SIMO. The original capture's labels mode_to_levels and levels_to_modes are reversed in meaning. Original routine names and descriptor offsets define the mapping.

## Interface And Storage

The application binary interface, or ABI, defines arguments, registers and stack use. The eighteen original ordinary pointer arguments are geometry, diagnostic configuration, integration, dynamics, nonhydrostatic configuration, wave number, local wave number, first column, last column, single-wave flag, vorticity descriptor, divergence descriptor, temperature descriptor, surface-pressure descriptor, three tendency descriptors and auxiliary descriptor. The first eight pointers arrive in x0 through x7. The other ten occupy eighty incoming stack bytes.

Use the measured GNU Fortran 12.3 layout. Geometry has 17,096 bytes, dynamics 4,720, nonhydrostatic configuration 456, diagnostic configuration 120 and integration 175,976. The last-column argument can point inside geometry. The three vertical records can also be embedded in that owner. Preserve these aliases when rebuilding or comparing a call.

| Consumed Record | Layout |
| --- | --- |
| Divergence, temperature and auxiliary descriptors | Rank two, nineteen by 506 FP64 values |
| Surface-pressure descriptor | Rank one, 506 FP64 values |
| SIMI and SIMO descriptors | Rank two, nineteen by nineteen FP64 values |
| Vertical records and coefficients | The complete accepted SIGAM, SITNU and vertical ABI |
| Wave tables and pressure coefficients | The complete accepted SPCIMPFSOLVE ABI |

Consumed field and matrix descriptors have eight-byte elements and span, lower bounds one and contiguous Fortran storage. Rank-two row stride is one and column stride is nineteen. Their offset is minus twenty. The surface descriptor has stride one and offset minus one. Preserve every descriptor and all inactive arrays. Vorticity, tendency values and the two wave-number sentinel values are unconsumed on this route.

Mutable divergence, temperature and surface-pressure owners are disjoint from each other and every read-only owner. Configuration aliases within one read-only owner are supported. Consumed numerical inputs and intermediate values must be finite and satisfy the accepted child domains. Other selections and incompatible consumed descriptor bounds reject before any native child or caller output changes.

The parent owns 388,608 scratch bytes for five nineteen-by-506 fields and one 506-value surface field. Allocation supplies storage only. A 576-byte aligned frame holds preserved registers, all ordinary pointers, scalar child arguments and two complete GNU descriptors for the implicit solve. Preserve x19 through x29, the link register, the required low halves of v8 through v15, reserved register x18 and FPCR. The saved x18 value occupies byte 568, beyond both complete descriptors and all outgoing arguments.

The default direct entry is md2asm_spcsi. Its five private stage counters cover SIGAM, the first matrix, SPCIMPFSOLVE, the second matrix and SITNU. Private numerical children resolve within the assembly bundle. A previously accepted nonnumerical thread-state query remains an explicit vertical-helper dependency. Module constants, allocation and terminal failure handling are separate from the numerical calculation. There is no OpenIFS numerical procedure call or fallback in the direct route.

## Source Physics And Exact Agreement

The original source replay and a private vendor control each reproduce all 523,496 genuine owner bytes. The separately unfused source intentionally differs from that old result in 10,447 bytes. This change is isolated to the two matrix rounding routes.

Before direct emission, the complete genuine unfused source passes 100-digit independent hydrostatic and thermal integrals, both matrix products, dense original pressure-wave solutions and residuals, positive-zero imaginary modes and ground pressure-weighted mass. The check covers 77,924 exact ordered values and 52,965 independent relations. The largest observed fraction of a frozen rounding limit is below 0.079. Existing child approximation and solution limits are reused unchanged.

The direct parent matches all 523,496 whole-owner bytes, including 157,872 mutable bytes, with ABI zero and exact captured FPCR zero, FPSR 25 and errno 34. Its observation build also matches 542,432 complete intermediate bytes across eight stages. Each of the five private parent stages executes once. The independent source physics therefore applies to those identical native stages.

Three unsupported native cases preserve 1,570,488 shared caller bytes. They cover first column two, stretched geometry and an incompatible consumed divergence bound. Two unsupported relay overlap cases preserve 1,046,992 bytes. Counter snapshots taken inside each rejecting process prove that no native stage runs before rejection. Complete source and native pointer words, read-only bytes and unused padding are preserved.

The private native bundle exports only its parent and counter getter. Instruction inspection finds no fused or approximate arithmetic. The numerical body is written directly as assembly from the frozen equations, order, storage and ABI, without compiler numerical instructions or intermediate representations used for construction.

## Fresh Forecast Reference

The qualified original-only revision-2 Fortran forecast passes with twenty-five positive complete SPCSI calls and all ten saved files, totalling 618,140 bytes. Of those saved bytes, 131,398 differ from the retained old vendor forecast. This difference is explicit. The complete direct parent passes 25 genuine calls and 3,946,800 returned bytes with zero differences. All ten saved files match the revised Fortran reference across 618,140 bytes.

The live relay resolves the qualified revised source explicitly. It rebuilds the real complete owner graph for the source shadow, preserving ordinary, descriptor and embedded-record aliases. It then returns the direct native result only after whole-owner and numerical-status agreement. Its positive source and native counts are separate. Detailed controls, builds, inputs, failures and results stay in ignored .runtime, with compact public results in [the assembly overview](../../../../../src/openifs/README.md). Whole-forecast independent physics and comparative timing remain separate.
