# Private Power Integer Calculations on the GPU

Revision 3 preserves the seven private numerical services used by the [original-rounding power function](../../../../md2fort/references/openifs/support/power_original_rounding.md). FP64 is the 64-bit floating-point format. These services round an exact product and sum once; their callers define the physical units. The original coefficients, rounding points, supported power inputs, signed zeros and gradual underflow remain unchanged.

## Interfaces and Ordered Work

The application binary interface (ABI) defines the argument registers and preserved state. The [raw Arm wrappers](../../../../../src/openifs/support/gpu/power_private_integer_raw_calls.S) retain these entry names and select the corresponding [device entry](../../../../../src/openifs/support/gpu/power_private_integer_cell.ptx) modes.

| Mode | Export | Result registers | Ordered exact product-and-sum calls |
| ---: | --- | --- | ---: |
| 0 | `md2asm_private_power_product_sum_deferred` | `d0` | 1 |
| 1 | `md2asm_private_power_coefficient_product_sum` | `d0` | 1 |
| 2 | `md2asm_private_power_log_seed_triplet` | `d0`, `d1`, `d2` | 3 |
| 3 | `md2asm_private_power_square_residual` | `d0` | 1 |
| 4 | `md2asm_private_power_product_rounding_residual` | `d0` | 1 |
| 5 | `md2asm_private_power_exponential_seed_pair` | `d0`, `d1` | 2 |
| 6 | `md2asm_private_power_log_polynomial_merge` | `d0` | 1 |

Single-result entries receive their original operands in `d0` through `d2` and preserve `d1` and `d2`. Seed entries use `d10` and immutable coefficient records addressed by `x16`; mode 1 also retains its original coefficient record. A logarithm seed has zero input or an absolute input from $`2^{-60}`$ up to, but excluding, $`1/128`$. The original caller supplies the remaining private bounds and matching records. Each 32-byte record contains two integer significands at offsets 0 and 8, exponent words at 16 and 20, and sign words at 24 and 28. Three records serve mode 2; two serve mode 5. Integer shifts reconstruct the exact coefficient words on the GPU. The original seed classification thresholds remain 74 for the logarithm and 72 and 73 for the exponential pair.

Each calculation calls the unchanged [exact integer device function](../../../../../src/openifs/support/gpu/exact_product_sum.ptx). It forms the complete finite product and sum before one nearest-even rounding, then returns the result word, required exception flags and original FAST or WIDE class. FAST and WIDE identify the original aligned integer width, with class values zero and one. Removing trailing zero bits must not change that class.

## Status, Domain and Registers

The floating-point control register, FPCR, must be zero. This selects nearest-even rounding and gradual underflow. The floating-point status register, FPSR, records sticky exception flags: once raised, a flag stays set until explicitly cleared. The return `w0` preserves source success or refusal, and `w1` contains flags deferred until a later source commit. The caller's pending flag mask in `w27` survives each call. `errno`, the C library error indicator, retains its original value.

On ordinary compact and wide paths, immediate FPSR remains unchanged and `w1` returns the new flag mask. The unchanged parent commits these flags at its original boundaries. A zero product or exact cancellation retains the original compact path. Otherwise, a nonzero subnormal result or underflow before rounding selects the original general path. That path immediately joins incoming FPSR, pending `w27` and the required flags with integer OR, returns `w1=0`, and records the original aligned FAST or WIDE event. Counter addition preserves unsigned 64-bit wrap.

Both seed entries refuse nonzero FPCR with `w0=1`, `w1=0` and unchanged vector outputs before launch. Mode 5 also preserves its original refusal unless the input is zero or its stored exponent field lies from 963 through 1015 inclusive; refusal preserves `d0` and `d1` and adds no counter event. Nonfinite internal product-and-sum operands retain the original terminal error. These private conditions preserve the complete public power domain.

Each wrapper uses a 1024-byte temporary aligned to 16 bytes. It saves all 31 general registers, all 32 complete vector registers and NZCV, the integer branch flags. It copies only the required coefficient owner and retains results privately until restoration, then installs the original result registers and `w0` and `w1`. The required callee registers, `x18`, stack alignment and FPCR remain preserved.

## Complete Storage and Binding

The [host transport](../../../../../src/openifs/support/gpu/power_private_integer_cell_calls.S) uses a 768-byte frame and the [common call context](../gpu_call_context.md). The [CUDA contract](../cuda_runtime.md) requires one serial, nonrecursive host caller. The numerical work runs on the declared GPU target.

| Complete buffer | Bytes | Stored information |
| --- | ---: | --- |
| Input | 128 | `d0`, `d1`, `d2`, `d10`, followed by up to three coefficient records |
| Output | 48 | Three result words, deferred flags, source status and two counts |
| Argument vector | 16 | Input and output addresses |
| Context | 64 | Status, launch state and call-record bounds |
| Call record | 64 | Input, output, mode and counter descriptions |
| FAST owner | 8 | Original FAST counter |
| WIDE owner | 8 | Original WIDE counter |

All seven complete buffers are aligned to eight bytes and disjoint. The device checks their bounds, address wrap, reserved fields and mode before numerical effects. Output offsets 0, 8 and 16 hold the result words; 24 holds deferred flags; 28 holds source status; 32 and 40 hold FAST and WIDE totals. Input byte 120 carries pending `w27` only in single-result modes, where it cannot overlap coefficient metadata.

Link exactly one [counter owner](../../../../../src/openifs/support/gpu/power_counter_owners.S). It defines `md2asm_product_sum_fast_calls`, `md2asm_product_sum_wide_calls`, `md2asm_diagnostic_status_clear` and `md2asm_diagnostic_status_read`. Counted private events retain their own source policy. The [uncounted public direct interface](raw_product_sum.md) and [counted public interface](counted_public_product_sum.md) retain their separate status and counter rules.

## Component Evidence

The complete retained power parent passes 11,041 selected-CPU and 11,041 GPU calls, with 481 GPU register checks and 529,968 compared record bytes. The private interfaces pass 720 CPU and 720 GPU calls across 63,360 bytes, including pending flags, refusal, counter wrap and preserved registers. Every compared output, status and counter byte agrees. Fifteen prewrite refusals, four valid raw boundary cases and four ordinary device graphs pass. Exact rational evidence for the unchanged child, independent numerical and interface source reviews, selected-provider checks and final machine-instruction checks are retained. These results qualify the listed mathematical components; detailed inputs and records remain local.
