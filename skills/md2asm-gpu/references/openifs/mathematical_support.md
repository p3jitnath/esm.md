# OpenIFS GPU Mathematical Support

Revision 1 fixes the numerical interface of the direct PTX support functions. These functions retain the accepted [scalar exponential contract](../../../md2asm/references/openifs/support/scalar_exponential.md) and the original Arm processor’s rounded FP64 operations. FP64 means a floating-point number stored in 64 bits. No physical equation changes.

The target is NVIDIA compute capability 9.0 with PTX 8.5 and CUDA 12.6. Assemble the [exponential module](../../../../src/openifs/support/gpu/scalar_exponential.ptx) and [operator module](../../../../src/openifs/support/gpu/ieee_operator_status.ptx) separately with `ptxas -c -arch=sm_90 --fmad=false`, then link their objects with `nvlink`. Every model multiplication and addition remains separate and rounds to nearest, with ties to even. Inputs, stored state and returned values remain FP64, with signed zeros and gradual underflow preserved.

## Device Function Interface

Each function receives raw unsigned 64-bit number words through PTX parameters. Binary functions receive the left operand before the right operand. The application binary interface (ABI), which defines argument and result duties, returns one eight-byte-aligned 16-byte object. Bytes zero to seven hold the result word, bytes eight to eleven hold newly raised status flags, and bytes twelve to fifteen hold a mathematical error-write event. Store every argument immediately before each call. Each thread has its own arguments, return storage and temporary registers.

| Function | Inputs | Meaning |
| --- | --- | --- |
| `md2asm_gpu_exp_original_rounding` | One word | Frozen scalar exponential |
| `md2asm_gpu_add_rn` | Two finite words | Addition and new status flags |
| `md2asm_gpu_mul_rn` | Two finite words | Multiplication and new status flags |
| `md2asm_gpu_add_status` | Two words | Addition including infinities and NaNs |
| `md2asm_gpu_sub_status` | Two words | Subtraction including infinities and NaNs |
| `md2asm_gpu_mul_status` | Two words | Multiplication including infinities and NaNs |
| `md2asm_gpu_div_status` | Two words | Correctly rounded division and status |
| `md2asm_gpu_div_rn` | Two words | Same complete division interface |
| `md2asm_gpu_sqrt_status` | One word | Correctly rounded processor square root |

These functions change no global numerical buffer and use no shared storage, barriers or cross-thread operations. The exponential reads an immutable 2,048-byte table. The operator module imports the finite addition and multiplication functions from the exponential module. Callers provide valid parameter and return storage, and combine the results through the [GPU call context](gpu_call_context.md).

## Further Finite Functions

The [finite mathematical functions contract](finite_mathematical_functions.md) adds an exact integer product sum and a complete finite arctangent. Their private return objects also carry the original helper classification or actual helper-call counts. Use their stated 24-byte and 32-byte interfaces when composing a parent. The [raw product-and-sum binding](support/raw_product_sum.md) preserves the original uncounted Arm interface while executing its complete numerical calculation on the GPU. The bounded [sine and cosine](small_angle_projections.md) and [base-ten logarithm](base_ten_logarithm.md) contracts add the same complete result, status and actual-counter interface for their stated input intervals. The [inverse cosine](finite_inverse_cosine.md) and [inverse sine](support/finite_inverse_sine.md) add their finite unit-interval interfaces. The [Cartesian direction angle](support/finite_direction_angle.md) accepts two finite vector components. The [complete bounded sine and cosine](support/bounded_angle_projections.md) support the full declared interval through $`2^{20}`$ radians, including trajectory longitude differences. Use the separate [system exponential](support/system_scalar_exponential.md) when its declared CPU library provider is required.

## Numerical Status

The Arm floating-point status register records invalid operation at bit zero, division by zero at bit one, overflow at bit two, underflow at bit three and inexact rounding at bit four. These functions return only newly raised flags. The caller combines them with its incoming status by integer OR, preserving all other incoming bits. The frozen processor mode has FPCR zero, so subnormal inputs remain numerical values and do not add a denormal-input flag.

A NaN is a bit pattern for an undefined numerical result. The full operators select signalling NaNs before quiet NaNs, then preserve source operand order within each group. They retain the selected sign and payload while making the result quiet. An invalid operation without a NaN input returns the Arm default NaN. Subtraction selects from its original operands before changing the second operand’s numerical sign.

The complete add, subtract and multiply entries check the original operand bits for finite values. When both values are finite, they call the corresponding finite helper directly. Other values retain the complete original shared handler. Subtraction changes the second sign only after both inputs pass the finite check, so the original NaN selection stays in its original order. Each private call loads both returned words before its parameter storage ends.

Finite addition checks an exact residual after its rounded addition. Finite multiplication forms the exact product of the integer significands, which are the stored significant digits, and tests discarded bits. Division tests whether the rounded result times the divisor equals the dividend through exact integer products. Square root tests whether the rounded result squared equals the input. These checks identify inexact rounding without changing any returned numerical bit. Underflow follows the Arm rule that tests whether an inexact exact result is tiny before rounding, including when rounding reaches the smallest normal value.

Primitive arithmetic returns an error-write event of zero, which preserves the incoming C error slot called `errno`. Square root follows the processor instruction and does not claim C library error behaviour. The exponential returns event 34 when its finite input overflows to infinity or underflows to zero. The event records a write even if errno already contains 34. Its caller adds the operation’s original position before joining parallel events.

## Exponential and Machine Instructions

The exponential preserves the accepted range reduction, 128 table pairs, polynomial dependencies, threshold choices and adjusted-scale paths. Small inputs retain the rounded expression one plus input. The negative-scale path retains its high and low correction, subnormal rounding and positive-zero choice. NaN handling preserves source sign and payload before any ordinary device arithmetic can choose a different payload.

Correctly rounded division and square-root instructions can expand into internal fused arithmetic, reciprocal or square-root estimates, including an internal single-precision estimator. Those assembler refinements implement one required FP64 operation. They do not replace a model expression with approximate division or combine a model multiplication and addition. Inspect the native instructions and their containing functions to keep this distinction visible.

## Accepted Scope

The exponential has zero result, status and error-event differences across 23,200 calls. Its 2,900 distinct inputs also have an independent high-precision accuracy check with sampled error below one unit of the last place. The finite helpers pass 144,381 operand pairs against single Arm instructions. The complete five-operator comparison passes 536,135 operations, including special values, cancellation, rounding boundaries, subnormal values and a separate relocatable-call interface. Inputs and surrounding bytes remain unchanged.

The direct finite paths match 321,681 retained add, subtract and multiply cases, with zero differing result, flag or event bytes. The joined module also matches the retained 23,200 exponential cases. Saved reference records supply the expected bytes, and no reference calculation is repeated. The original finite helpers, special-value paths, division, square root and independent accuracy evidence are retained.

These results qualify mathematical components for the declared target and toolchain. They do not establish a complete GPU forecast, its performance, or an empirical proof over every possible input. Keep the CPU forecast and its physical checks as a separate verification reference until all GPU stages and saved outputs pass together. Detailed inputs, tools, independent checks and instruction records remain local under `.runtime/`.
