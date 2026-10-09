# OpenIFS pressure math

Revision 1.0 freezes the scalar exp and log library used for pressure comparisons. The exponential exp(x) gives $`e^x`$, while the natural logarithm log(x) is its inverse for positive x. Their inputs are numerical ratios with no unit. A pressure logarithm uses a reference pressure of 1 Pa.

## Frozen library

Use the unmodified scalar exp.c, exp_data.c, log.c, log_data.c and math_err.c from [Arm Optimized Routines v26.01](https://github.com/ARM-software/optimized-routines/tree/649ccc8411e7c4862965710f25c570d854a1483f/math), commit 649ccc8411e7c4862965710f25c570d854a1483f. Preserve its headers and coefficient tables, with their hashes in the [math record](../../../../bench/openifs/pressure_math.json). The source is an external elementary-function library, not generated solver assembly.

Build with GNU 12.3.0, -O2, -mcpu=neoverse-v2, -ffp-contract=off and -fno-fast-math. Define HAVE_FAST_FMA=0, HAVE_FAST_ROUND=0 and WANT_ERRNO=1. These choices select separately rounded polynomial arithmetic and the shift-based integer reduction. FPCR must select round-to-nearest with ties to even, gradual underflow and preserved signed zeros. Inspect the complete library's instructions, since flags alone do not establish these conditions.

The five C files, math_config.h and test headers are frozen without source edits. Export exp, log and their finite-input aliases, linking with -Wl,-z,defs and -Wl,-Bsymbolic-functions. Both unchanged Fortran and direct solver assembly must call this same library. No comparison driver calculates an omitted pressure stage.

## Accuracy and verification

The pressure contracts require positive finite pressure and finite used intermediates. The math verifier separately covers finite inputs near overflow, underflow, zero, one and every reduction-table interval, including positive subnormal inputs to log. An ulp is the spacing beside the rounded reference value. Compare each result with independent decimal exp or log values at 110 and 220 significant digits, requiring the two precisions to select the same nearest FP64 reference and an absolute error no larger than one ulp. Verify exp(0)=exp(-0)=1 and positive-zero log(1).

The accepted sampled check contains 10,428 exponential and 10,421 logarithm inputs. Its largest observed errors are about 0.5022 and 0.5012 ulp, and the 407-instruction library has no forbidden arithmetic. These sampled checks establish the recorded accuracy cases, rather than a proof over every binary64 input. Independent pressure checks remain required.

## Reference boundary

The former system library used fused arithmetic, so its forecast archive remains a separate record. Create a fresh Fortran baseline with this library and unchanged strict-source scientific code. Record the runtime libraries and new output bytes, then compare the mixed assembly forecast directly with that baseline. This change does not alter the ten previously frozen routine contracts or erase their earlier evidence.

Acceptance here covers scalar pressure exp and log. Other external functions, including private math calls inside external libraries, need their own audit before accepting the whole forecast's arithmetic or comparative timing.
