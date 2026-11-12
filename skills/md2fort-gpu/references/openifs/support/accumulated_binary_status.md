# Accumulated Binary Status

Revision 1 adds four private arithmetic helpers to the [GPU mathematical interface](../mathematical_support.md). A status flag records an event such as rounding an exact result. A flag stays set until its declared boundary. These helpers keep the original rounded number and avoid reconstructing a rounding flag that the caller already holds. The physical equations, units and supported input values stay unchanged.

## Interface

The [assembly source](../../../../../src/openifs/support/gpu/accumulated_binary_status.ptx) defines `md2asm_gpu_accumulated_add_status`, `md2asm_gpu_accumulated_sub_status`, `md2asm_gpu_accumulated_mul_status` and `md2asm_gpu_accumulated_div_status`. Each takes two unsigned 64-bit operand words followed by an unsigned 32-bit accumulated flag word. The operands encode FP64, the 64-bit floating-point format. The application binary interface (ABI) returns one eight-byte-aligned 16-byte object. Bytes 0 through 7 hold the result, bytes 8 through 11 hold additional flags, and bytes 12 through 15 hold the original error event.

The caller combines the additional flags with its supplied flag word using integer OR. This operation keeps each bit set in either word. Every consumer of the returned flag word must use that same rule. Each thread owns its parameters, return object and temporary registers. The helpers read no model buffer and write no global buffer, counter or shared storage. They use the same NVIDIA target and assembly commands as the common mathematical interface.

## Safe Arithmetic Range

The short route requires the incoming inexact flag, whose mask value is 16, to be set already. Each operand must be zero or a normal FP64 value with a binary exponent from −200 through 200. A normal value lies outside the very small subnormal range. Division also requires a nonzero denominator. Every other input uses the unchanged complete operator, including its result bits, flags and error event.

A nonzero admitted operand has magnitude at least $`2^{-200}`$ and below $`2^{201}`$. The spacing between stored operands gives the following conservative bounds on a nonzero exact result.

| Operation | Lower Bound on Magnitude | Strict Upper Bound on Magnitude |
| --- | --- | --- |
| Addition or subtraction | $`2^{-252}`$ | $`2^{202}`$ |
| Multiplication | $`2^{-400}`$ | $`2^{402}`$ |
| Division | Greater than $`2^{-401}`$ | $`2^{401}`$ |

These results remain normal and finite after rounding. The admitted operations can therefore add only the inexact flag, which is already present. The helper executes the same `add.rn.f64`, `sub.rn.f64`, `mul.rn.f64` or `div.rn.f64` instruction and returns zero additional flags and a zero event. The caller's complete accumulated status remains exact. Signed zero follows the original rounded instruction. Complete operators handle every input outside this proved range.

## Cloud Binding and Evidence

The [cloud column contract](../physics/cloud_microphysics_columns.md) selects these helpers at 993 sites in eight numerical children. Each original returned flag word has one consumer, which combines it with the same local accumulated state. The original operands, result loads, arithmetic order, numerical child interfaces, counters, storage and launch sequence are retained.

A 4,320-case GPU bank checks result bits, error events, complete accumulated flags, unchanged complete fallback returns and buffer guards. It covers signed zeros, closest cancellation, every range boundary, subnormal values, overflow, zero denominators, infinities and NaN payloads. NaN means a stored value that represents an undefined numerical result. Raw additional flags are retained locally and can differ when the caller already holds the inexact flag. No stored model value or declared output byte is changed to obtain agreement.

The unchanged complete-cloud verifier then passes 192 cases with exact owners, numerical status, actual counters and ABI. Existing independent water and phase-enthalpy checks remain applicable through exact canonical output agreement. Matched complete-call measurements select this route for the retained component. Detailed records stay local. This result does not establish complete GPU forecast acceptance or runtime.
