# Mathematical bindings for physics parameterisations

A physics parameterisation represents a process that is smaller than a model grid cell, such as cloud formation or turbulent mixing. A binding selects the function and storage that a call uses. This contract preserves the accepted mathematical bindings inside the runtime `CALLPAR` physics graph. It qualifies the helper component; the complete parent and forecast still need their own input-owner and numerical checks.

The selected graph uses 206 complete source objects. Each changed assembly body retains its accepted instructions, constants, interfaces and source call order. Source preprocessor definitions change the declared function or data names before assembly. Complete default objects remain available for comparison. The retained external C mathematical libraries remain mathematical-library boundaries and supply no OpenIFS calculation or setup stage.

| Caller family | Selected mathematical route | Product-sum counter owner |
| --- | --- | --- |
| Uncounted scalar EXP callers | `md2asm_r4_gnu_exp`, from the retained external mathematical library | No EXP counter |
| Turbulence EXP callers | `md2asm_r4_turb_exp_counted` | Separate turbulence EXP word |
| CLOUD scalar, paired and four-value EXP callers | `md2asm_r4_cloud_exp_counted` and its explicitly bound grouped entries | One CLOUD EXP word |
| Turbulence POWER, SIN, COS and ATAN callers | Their accepted canonical assembly names | Canonical `md2asm_product_sum_fast_calls` and `md2asm_product_sum_wide_calls` |
| CLOUD POWER callers | `md2asm_r4_cloud_pow_original_rounding_candidate` and the accepted deferred-status children | Two `md2asm_r4_cloud_*` words |
| Gravity-wave, snow-initialisation and cloud-radiation trig callers | `md2asm_r4_external_{sin,cos,atan}_original_rounding`, as required by each caller | Two standalone `md2asm_r4_external_*` words |
| Surface-radiation, methane and surface-time trig callers | `md2asm_r4_external_power_{sin,cos,atan,tan}_original_rounding`, as required by each caller | Two `md2asm_r4_external_power_*` words |
| Retained external POWER callers | `md2asm_r4_external_pow_original_rounding_candidate` | The same two external POWER words used by their trig calls |
| Radiation-flux POWER callers | `md2asm_r4_radiation_pow_original_rounding_candidate` | Two separate `md2asm_r4_radiation_*` words |
| Existing system EXP callers | `md2asm_r4_system_exp_glibc_2_29`, a single tail branch to `exp@GLIBC_2.29` | No EXP counter |

The braces in the table describe a family of explicit names, not a runtime choice. Each caller has one recorded target. The local source and object map gives every definition and relocation. A relocation is an assembler record that tells the linker which function or data address an instruction needs. The external POWER library and the standalone product-sum library retain separate status entries and counters even though they originate from the same mathematical source.

FP64 means the 64-bit floating-point format. The application binary interface, or ABI, puts unary arguments and results in `d0`. POWER takes its base in `d0` and exponent in `d1`; the product-sum primitive takes its three operands in `d0`, `d1` and `d2`. Every selected entry preserves its accepted register and stack obligations, including `x18`, saved integer registers, the low 64 bits of `v8` through `v15`, and sixteen-byte stack alignment. These scalar interfaces receive no numerical buffer. Their verification bridge uses an aligned three-word input buffer and one aligned eight-byte result word.

The floating-point control register, FPCR, is zero. This selects rounding to nearest with ties to even and gradual underflow. Each route preserves its original floating-point status register, FPSR, and error-number behaviour. SIN and COS retain the accepted finite-angle bound of $`2^{20}`$ radians; TAN retains the bound $`\pi`$ radians. ATAN retains its finite-input contract. POWER and product-sum retain the domains in their existing [POWER](power_original_rounding.md), [product-sum](rounded_product_sum.md), [SIN/COS](sin_cos_original_rounding.md), [ATAN](atan_original_rounding.md) contracts and the [bounded TAN source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/tan_original_rounding.S).

The product-sum primitive rounds an exact product plus an addend once inside the accepted elementary-function algorithms. It must not replace a solver multiplication followed by a separately rounded addition. No solver arithmetic, dimension, stride, loop bound or resolution choice changes in this binding checkpoint.

All twelve eight-byte counter owners have distinct addresses. Ten words count the fast and wide product-sum paths for five mathematical families, and two words count the turbulence and CLOUD EXP routes. Counts use unsigned 64-bit arithmetic and wrap modulo $`2^{64}`$. CLOUD grouped EXP entries retain their accepted counter increments and status interfaces.

Shared weather children also keep their per-consumer route. Turbulence receives explicitly named copies of SATUR, CUBASEN, CUADJTQ, CUININ and its environment child. CLOUD receives its own supersaturation-check child. The CUADJTQ conditional branch and the VDFHGHTN call branches preserve their instruction kinds and source order. Two explicit surface-time source edges preserve the accepted empty-range status work and replace the former linker wrapping.

The complete strict link has no competing strong definitions and uses only the declared profiling, system-mathematics and operating-system libraries. The loaded image passed 1,276 branch-target checks, 146 dynamic-slot checks, twelve distinct counter-owner checks and five canonical physical/clock/runtime alias checks. A separate frozen scalar batch passed 228 original/selected comparisons across twenty mathematical interfaces. It checked result words, ABI obligations, FPCR, FPSR, error numbers, both counter deltas, unsigned wrap and unchanged unrelated counters. Each original component ran in its own fresh process so that mathematical libraries with the same filename could not borrow another component's bindings.

The earlier 148 scalar EXP comparisons and the unchanged independent accuracy and physical checks were reused. No shared-weather-child, complete `CALLPAR`, forecast or comparative timing run was performed for this checkpoint. The 35 original parent addresses, appended 80-byte context, complete producer lifetimes and saved forecast output remain separate acceptance requirements. The same assembled solver and main Fortran reference executable remain the resolution-independent targets.
