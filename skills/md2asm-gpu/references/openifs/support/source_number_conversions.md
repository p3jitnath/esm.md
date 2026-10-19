# Source-number conversions on the GPU

A number conversion changes the stored format or rounds a real value to an integer. FP64 and FP32 mean the 64-bit and 32-bit floating-point formats. These private scalar entries preserve the original Arm instruction's result word, signed width, rounding and status. They do not introduce a new physical approximation. The [startup host](../../../../../src/openifs/support/gpu/startup_integer_cell_calls.S) with [startup PTX](../../../../../src/openifs/support/gpu/startup_integer_cell.ptx) supplies the startup conversions. The [physical host](../../../../../src/openifs/support/gpu/physical_setup_numeric_calls.S) with [physical PTX](../../../../../src/openifs/support/gpu/physical_setup_numeric.ptx) supplies the physical-setup extension.

| Entry and mode | Original operation and result |
| --- | --- |
| Startup 17, 18 | Convert a signed 64-bit or signed 32-bit integer to FP64, with nearest-even rounding. |
| Startup 19, 20 | Convert FP64 to signed 64-bit or signed 32-bit integer, with halfway cases away from zero. |
| Startup 21, 22 | Convert FP64 to signed 32-bit integer, toward positive or negative infinity. |
| Startup 23 | Call the unchanged EXP child without a public EXP counter increment. |
| Physical 24 | Convert FP64 to signed 32-bit integer toward zero. |
| Physical 25 | Round FP64 to an integral FP64 value, with halfway cases away from zero. |
| Physical 26 | Convert signed 32-bit integer to FP32 with nearest-even rounding. |
| Physical 27 | Perform the original FP32 division for the 101 cloud-table pairs: integer indices 0 through 100 divided by FP32 100. |
| Physical 28 | Widen the source cloud-table FP32 value in the interval zero through one to FP64 exactly. |

Integer-to-real modes cover the complete signed input width. Real-to-integer modes cover every FP64 bit pattern: NaN, which means not a number, returns zero with invalid-operation status; an out-of-range value saturates at the appropriate signed bound with invalid-operation status. A valid fractional conversion raises inexact. FP64 integral rounding preserves signed zero and the original NaN rules and does not raise inexact. The cloud path keeps conversion, division and widening as three distinct source rounding points. Its private 101-pair division domain comes from the complete fixed source table and does not restrict physical caller inputs. An exact bounded integer quotient and remainder produce the original nearest-even FP32 result without an approximate division sequence.

The application binary interface (ABI) takes `x0` as the address of a 72-byte input containing nine 8-byte words and `w1` as the mode. Integer operands use the original signed width; FP32 operands and results occupy the low 32 bits of a word. The returned 64-bit word is in `d0`, including raw integer-result bits; comparison modes also return condition bits in `w0`. The 32-byte result stores the value at byte 0, condition at byte 8, errno event at byte 12 and internal FAST/WIDE work totals at bytes 16 and 24. Conversion modes add no mathematical counter event and preserve errno.

The unchanged seven-owner boundary contains the 72-byte input, 32-byte result, 16-byte pointer vector, 64-byte context, 64-byte capacity record and two separate 8-byte counter owners. Alignment, complete spans, nonwrapping addresses and required separation are checked before output writes. Each host uses a 768-byte frame and requires serial use with FPCR zero. Failure refuses the operation before numerical output or counter mutation; the host stops on refusal. Incoming FPSR flags remain set. Callers must preserve any additional live registers; setup parents use the [complete-state header](../../../../../src/openifs/support/gpu/preserved_scalar_calls.inc.S).

Qualification includes 7,528 native Arm/GPU startup conversion comparisons with independent exact integer relations, including full signed boundaries, NaNs, infinities, subnormals and status. The physical extension passes 3,784 native/GPU pairs; 202 pairs cover the final cloud-division revision and 3,582 unchanged pairs are reused. Its six refusal controls, five ordinary-device graphs and native audit pass. The final kernel contains no fused, approximate or flush-to-zero arithmetic. Complete parent checks are reported separately in [physical setup](../setup/physical_setup.md). These helper checks give no whole-forecast or timing result.
