# Seasonal Ozone Coefficients

Revision 2 freezes the complete SUECOZO calculation from [yearly ozone physics](../../../../../formulations/openifs/physics/yearly_ozone_cycle.md). The direct entry calculates all four coefficient arrays and leaves every other record byte unchanged.

## Ordered Calculation

Let $`c=\cos\theta`$ and $`s=\sin\theta`$, with $`\theta`$ in radians. Use the unchanged qualified [sine and cosine helpers](../support/sin_cos_original_rounding.md). The admitted finite phase has magnitude at most $`2^{20}`$ radians, matching the unchanged helpers. A calendar can supply an accumulated phase over several years. Pass its exact bits to both helpers without wrapping or replacing it.

Form $`c_2=(c c)-(s s)`$ with two separate multiplications and one subtraction. Form $`s_2=(2s)c`$ with two separate multiplications. For every coefficient, multiply $`A_1c`$, $`A_2s`$, $`A_3c_2`$ and $`A_4s_2`$ separately. Add the four terms from left to right, multiply the sum by two, then add $`A_0`$. Every operation rounds separately in FP64. Keep signed zeros, gradual underflow and round-to-nearest with ties to even. Do not contract operations or change their dependencies.

The 360 original coefficient constants retain their exact FP64 bits. The four output arrays have 21, 15, 21 and 15 coefficients in COZQC, COZQS, COZHC and COZHS order. All coefficients use Pa. Individual spatial coefficients can be negative, while the mean ozone quantity and mean peak pressure remain positive throughout the seasonal model.

## Interface And Bytes

The original and direct entries each take two address arguments. x0 points to one immutable FP64 phase value, and x1 points to the complete TEOZOC record. The measured record occupies 33,008 bytes. Its mutable arrays start at byte offsets 200, 368, 488 and 656 and occupy 576 consecutive bytes in total. Preserve the two unconsumed allocation descriptors and all later arrays.

Both addresses must be nonnull and eight-byte aligned, their complete bounds must fit the address space, and the immutable phase owner must be disjoint from the mutable output region. The direct entry rejects an invalid phase or machine state before any record write. The application binary interface, or ABI, requires saved registers and a 16-byte aligned stack. Preserve x19 to x29, x18, the low 64 bits of d8 to d15, SP, FPCR, incoming numerical status flags and errno. The parent saves x18 across both private mathematical calls, and the immediate ABI check supplies a fixed nonzero x18 value.

Canonical output is the complete record in original byte order, using little-endian FP64 for the four arrays. Compare every byte, including unused storage. The mathematical helpers supply complete direct unary calculations. A driver only supplies the phase and record addresses and performs no numerical stage.

## Source Gate

Before direct emission, 32 protected original calls pass 1,056,256 complete record bytes and 2,432 independent 180-digit relations. These relations check the seasonal equation, harmonic identities, positive mean quantities, immutable phase and untouched record storage. The phase corpus includes both signed zeros, subnormal values, ordinary yearly phases, the quarter and half cycle, both range edges and a neighbour of the upper edge.

The native numerical corpus also passes 32 protected calls, 1,056,256 complete record bytes and 2,432 independent relations with zero differing bytes. The final parent adds x18 preservation without changing any numerical instruction, reusing that unchanged arithmetic proof. Six focused live pairs then pass 198,048 complete record bytes and 456 independent 180-digit relations, with a fixed nonzero x18 check, matching fresh numerical flags, preserved errno and profiling enabled. Ten invalid machine-state or buffer cases reject before changing any of 330,080 shared record bytes. Machine inspection confirms separate arithmetic and the declared direct sine and cosine dependency.

Performance measurements remain pending. The seasonal forcing check does not establish independent physical correctness of a complete weather forecast.

The accumulated-angle extension passes 20 protected source calls followed by 20 native calls. Each route covers 660,160 complete record bytes and 1,520 independent 180-digit relations with zero differing bytes. It includes both signs, several full turns, the declared range edges and their inner neighbours. Seven focused live pairs pass 231,056 complete record bytes and 532 independent relations, including the fixed nonzero x18 check and enabled profiling. Both direct and paired routes reject the first value beyond the new upper bound before changing 66,016 shared record bytes. The independent verifier reduces its decimal angle before evaluating a series. The direct solver retains the supplied FP64 phase, every original numerical instruction and the unchanged sine and cosine proofs.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| suecozo | 26 | 858,208 | Complete ozone coefficients and unchanged record bytes |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
