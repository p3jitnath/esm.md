# Counted Public Exact Product and Sum on the GPU

Revision 1 preserves `md2asm_round_product_sum_candidate` for finite FP64 operands, where FP64 is the 64-bit floating-point format. It receives $`a`$, $`b`$ and $`c`$ in `d0`, `d1` and `d2`, and returns $`\operatorname{RN}(ab+c)`$ in `d0`. Here $`\operatorname{RN}`$ means one rounding to nearest with ties to even. The product and addend must have compatible physical units. Signed zero, gradual underflow, overflow and the original underflow-before-rounding rule remain unchanged.

## Public Interface and Counters

The floating-point control register, FPCR, must be zero under the inherited caller contract. The [Arm wrapper](../../../../../src/openifs/support/gpu/counted_public_product_sum.S) checks this precondition before launch. The historical CPU body did not independently check FPCR. Nonfinite operands retain the original terminal refusal, `_exit(116)`, followed by `brk #116` if that service returns.

Every admitted finite call adds exactly one event to the original FAST or WIDE counter, including the general path for very small results. The class uses the complete aligned integer widths without removing trailing zeros. A zero product or zero addend is FAST. Otherwise, align the exact integer product and addend to their smaller exponent; the call is FAST when both aligned widths are at most 127 bits, and WIDE otherwise. Counter addition preserves unsigned 64-bit wrap. This counted policy remains separate from the [uncounted public direct interface](raw_product_sum.md).

## GPU Binding and Immediate Status

Reuse mode 0 of the [private power transport](private_power_integer_closure.md) and its unchanged exact integer device function. The 128-byte input places the operands at offsets 0, 8 and 16 and sets every other word to zero, including pending status at byte 120. The seven complete input, output, context and counter owners retain their checked bounds, eight-byte alignment and disjointness. Link one counter owner, one private device entry and one exact product-and-sum device function.

The floating-point status register, FPSR, records sticky exception flags. Ordinary private paths return new flags in `w1`; their general path already joins the required flags into FPSR and returns `w1=0`. The public wrapper joins `w1` into FPSR with integer OR immediately after the call. Thus every public path exposes its original immediate flags, preserves incoming flags and leaves `errno`, the C library error indicator, unchanged.

The wrapper uses a 1024-byte temporary aligned to 16 bytes. Transport saves all 31 general registers and all 32 complete vector registers, retains the result privately at byte 896, and restores saved state before installing `d0`. NZCV, the integer branch flags, uses byte 944. The original ABI permits `x9` and NZCV as scratch; required callee registers, `x18`, the stack pointer and FPCR remain preserved. Calls are serial and nonrecursive under the [CUDA contract](../cuda_runtime.md).

## Component Evidence

The selected historical source rebuilds byte for byte to the complete actual counted CPU provider, including its relocation records and counter owners. The GPU binding passes 7,861 finite triples with independent exact rational checks and zero differing bytes in 282,996 bytes of value, status, error and counter records. Additional seeded-status calls, register checks, counter wrap and twelve paired CPU/GPU nonfinite-refusal controls pass. Both independent source reviews pass. The unchanged child supplies the accepted complete-buffer, device-graph, native-instruction and exact arithmetic checks. These results qualify this mathematical component; detailed inputs and records remain local.
