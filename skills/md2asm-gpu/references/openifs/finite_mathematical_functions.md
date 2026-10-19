# Finite GPU Mathematical Functions

Revision 1 fixes two reusable device functions for finite FP64 inputs. FP64 stores each floating-point number in 64 bits. The [mathematical support contract](mathematical_support.md) defines the target, ordinary arithmetic helpers and status flags. Neither function changes a physical equation.

## Exact Product Sum

The [exact product-sum source](../../../../src/openifs/support/gpu/exact_product_sum.ptx) exports `md2asm_gpu_exact_product_sum(first, second, addend)`. Its three parameters are raw 64-bit words for finite values. It forms the exact mathematical product plus addend with integer arithmetic, then rounds once to the nearest FP64 value, choosing an even final digit at a tie.

```math
S(a,b,c)=\operatorname{round}_{64}(a b+c).
```

Use this function only where the frozen mathematical-library algorithm requires $`S`$. Model expressions that specify a rounded multiplication followed by a rounded addition must retain both rounding steps. The function preserves signed zeros and gradual underflow, which allows values smaller than the smallest normal FP64 number.

Its application binary interface, or ABI, returns an eight-byte-aligned 24-byte object. Bytes 0–7 hold the result, bytes 8–11 hold newly raised Arm-equivalent status flags, bytes 12–15 hold a zero error-write event, bytes 16–19 hold the original helper’s fast or wide classification, and bytes 20–23 are zero. Classification zero means the retained exact alignment fits within 127 bits, while classification one requires the wider route. For nonzero terms in classification zero, two 64-bit registers hold each complete aligned magnitude and their exact sum or difference. This path and the general path use the same final rounding and return rules. Other inputs retain the full calculation in a private 1,072-byte local work area. Neither path reads or writes a caller buffer or global numerical state.

## Finite Arctangent

The [arctangent source](../../../../src/openifs/support/gpu/finite_arctangent.ptx) exports `md2asm_gpu_atan_finite(input_word)`. The input is one raw finite FP64 word. Its result is $`\arctan(x)`$, the angle in radians whose tangent is the dimensionless input $`x`$. Preserve the complete ordered algorithm, threshold words and table values in the accepted [CPU arctangent contract](../../../md2asm/references/openifs/support/atan_original_rounding.md).

The function uses six input ranges. Very small inputs retain their input word, small inputs use an odd polynomial, intermediate inputs use a table, larger inputs use the reciprocal with that table or polynomial, and very large inputs return the retained signed approximation to half of pi. Every rounded operation and exact product-sum call retains its source order. Finite inputs include signed zeros and subnormal values. Callers must reject infinities and NaNs before calling this function.

The ABI returns an eight-byte-aligned 32-byte object. Bytes 0–7 hold the result, bytes 8–11 hold newly raised status flags, bytes 12–15 hold a zero error-write event, bytes 16–23 hold the actual fast-call count, and bytes 24–31 hold the actual wide-call count. Counts start at zero, count executed product-sum helpers and wrap at $`2^{64}`$. The four polynomial or table ranges execute 6, 6, 8 and 8 such calls. Tiny and very large inputs execute none.

Each thread has private parameters, results and registers. The function reads a private, eight-byte-aligned table of 1,687 words arranged as 241 rows of seven coefficients. The table uses global storage so that it does not exhaust the linked module's constant-memory allowance. Callers must keep these coefficients unchanged. The function changes no caller buffer, global diagnostic counter or shared work area.

## Linking And Accepted Scope

Assemble both sources with `ptxas -c -arch=sm_90 --fmad=false`, then link them with the existing exponential and full operator modules using `nvlink`. Each caller stores every parameter immediately before its call and combines the returned flags, error event and counters through its declared parent interface. The pure functions impose no launch shape or array-length contract because they take scalar words and return private objects.

The product sum passes 9,938 input triples against exact rational arithmetic, including 7,860 retained triples and 2,078 further alignment, cancellation, rounding and range cases. Every result, status and classification byte agrees, as do 4,998 dependent POWER return records. Arctangent passes 13,188 retained finite inputs with exact result, status, error-event and actual-counter agreement. Independent high-precision angle checks are retained, together with seeded-status, refusal and ordinary device-memory checks of its local verification entry. These results qualify the components for the declared hardware and toolchain. They do not establish a complete GPU forecast or a proof over every input word. Tools and detailed evidence remain local under `.runtime/`.
