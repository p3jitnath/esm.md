# Original POWER Boundary

POWER is an elementary function that receives two FP64 numbers and returns their power. This local primitive preserves the original GLIBC 2.38 result boundary while the calling assembly keeps each ordinary product, sum and division separately rounded.

The original function contains 20 internal product-plus-addend steps with one rounding. The replacement computes those exact terms with integers and rounds once to FP64. This reproduces the original primitive's internal rounding and is distinct from a separately rounded solver product followed by a sum. Its machine code has no fused floating-point instruction. The original table-index rule uses nearest rounding with ties away from zero, while the final FP64 arithmetic uses FPCR zero and ties to even.

A 128-bit integer path handles small exponent gaps. A 67-word path covers every finite FP64 product and addend. Both preserve signed zeros, gradual underflow and the original cumulative status flags. Nonfinite internal product-plus-addend operands are outside the checked helper domain and cause exit 116. Ordinary POWER special cases retain their original source handling.

The immutable source is GLIBC tag 2.38, commit `36f2487f13e3540be9ee0fb51876b1da72176d3f`. Both installed lookup-table owners match its 6328 bytes exactly. The qualified local entry is `md2asm_pow_original_rounding_candidate` in `.runtime/openifs/weather24h-original-power-assessment/liboriginal_power_candidate.so`. Call this unique name and retain its exact source revision. Do not replace the process-wide POWER symbol.

Independent checks pass 6846 exact rational rounding cases and 8726 positive power cases across 16 weather exponents. The largest observed power error is 0.501344 units in the last place, where one unit is the spacing between adjacent FP64 values. Result bits, status flags and errno match the original on 8775 cases. These samples do not prove a global accuracy bound. Each solver must also check its newly consumed operand domain, independent physics and complete returned bytes.

The frozen source, 20-step map, table identity, builds and actual check records remain locally in `candidate-ready.json` and its referenced files. The accepted EXP and LOG functions and the separately rounded primary solver contract remain unchanged.
