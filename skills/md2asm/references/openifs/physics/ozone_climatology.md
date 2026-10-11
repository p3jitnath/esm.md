# Monthly Ozone Update

Revision 2 records the complete UPDECOZC body from the [physical input](../../../../../formulations/openifs/physics/ozone_climatology.md). Monthly interpolation, all perturbation modes, boundary rows and the latitude coordinate vector are part of this direct entry.

## Frozen Time And Arithmetic

The date is a valid Gregorian YYYYMMDD value with a year from 1 through 9999. The minute argument is a nonnegative signed 32-bit elapsed offset from that initial date, including offsets beyond one day. The UPDTIM caller rounds elapsed seconds plus the initial clock offset to minutes. Extract the initial month and day with the original integer remainder. January uses day index times 1440 plus the offset. February starts at 44640 and uses the original rounded FP64 day length 1452.8571, mapping February 29 to February 28. Later months use the preceding supplied cumulative day count plus the day index, then multiply by 1440 and add the offset. Keep each original rounding point, then take the nonnegative remainder after division by 525960 minutes, which is the mean 365.25-day year.

The rounded total is less than 2^32 minutes. For a total below one year, retain its bits. Otherwise split that FP64 value into its exact integer part and binary fraction. Divide the integer part by 525960 with unsigned integer division and subtract the quotient times 525960. Add the untouched binary fraction to this integer remainder. Each conversion and subtraction is exact in this domain, and the final fraction fits the smaller remainder exactly. This produces the source MOD result without an approximate floating-point division or a numerical helper.

The independent calendar check forms time in extended precision and uses a separate cyclic remainder. In February, three rounded operations can contribute time error. Freeze its bound as four FP64 epsilons times the unwrapped calendar-time magnitude. Propagate that bound through the largest adjacent monthly ozone slope, using the shortest month interval of 42660 minutes, the conversion factor and the perturbation bound. Keep the existing interpolation-rounding allowance and zero differing bytes. Calendar times in other months are exact integer values in this domain.

The twelve mid-month times are 22320, 64980, 107640, 151560, 195480, 239400, 283320, 327960, 371880, 415800, 459720 and 503640 minutes. Keep the original closed-right interval choice and both December–January branches. Preserve the original subtraction and division when forming the first-month weight, then the original difference, weight multiplication, addition and conversion-factor multiplication for every ozone value.

Write interior levels 1 through 34 at latitudes 1 through 19. Set level zero to positive zero and copy level 34 into level 35 before applying any perturbation. Mode zero perturbs heights 23 through 29 and mode one heights 27 through 33. Other integer modes make no perturbation. An amplitude equal to positive or negative zero skips this stage. Each factor is the ordered result of amplitude times the latitude sine, times the height sine, plus one. Multiply the existing value by that factor.

Return the 19 fixed latitude sines after the perturbation. Preserve every other byte of the complete ozone object and all supplied climatology data.

## Complete Fixed Grid

The protected global RPI constant has bits 400921fb54442d18. Native code checks those bits before any output write. Every latitude sine operand is the separately rounded result of minus 90 plus ten times the zero-based latitude index, times RPI, divided by 180. Every perturbation-latitude operand is the zero-based index converted through default REAL, divided by four, times RPI, divided by two. Every perturbation-height operand is similarly divided by three, times RPI, divided by two. The small integer conversions are exact.

These loops admit exactly 19, 9 and 7 operands. The complete 35-value table preserves the original SIN results at those exact FP64 arguments. An independent 120-digit sine series qualifies every fixed value, with a maximum observed error of 0.486295 ulp and a one-ulp acceptance limit. An ulp is the spacing between neighbouring floating-point values. This is a finite constant grid, rather than a continuous trigonometric approximation. There is no runtime sine helper and no replacement of a general SIN route.

## Interface And Storage

The five-address Arm application binary interface receives TERAD, TERDI, TEOZOC, date and minute in x0 through x4. Integer arguments contain four bytes. The frozen GNU objects contain 2040, 176 and 33008 bytes respectively. TERAD stores NPERTOZ at byte 140 and RPERTOZ at byte 576. TERDI stores RO3 at byte 48. TEOZOC stores the genuine contiguous rank-three ZOZCL allocatable descriptor at byte zero, the 64-value RSINC vector at byte 776 and the 64-by-61 ROZT matrix at byte 1288.

Read climatology indices 1 through 19, 1 through 34 and 1 through 12 through the descriptor's actual offset, strides and lower bounds. The owner can include additional latitudes, levels or months. Its dimensions include all those indices. The conversion factor is finite and positive, climatology values are finite and nonnegative, and the finite perturbation amplitude has magnitude at most one. Inputs and writable ozone storage are disjoint. All FP64 owners have eight-byte alignment.

Use FP64 nearest-even arithmetic, gradual underflow and preserved signed zeros. Forbid fused operations, reassociation, approximate operations and changes to the floating-point control register. The body has a 96-byte fixed frame, restores x19 through x29 and the return address, keeps the stack aligned to 16 bytes and leaves the low 64 bits of v8 through v15 unchanged. It needs no numerical helper or dynamic workspace. Preserve Arm saved registers and the stack. Canonical returned bytes are the complete 33008-byte ozone object in its original little-endian storage order, including unchanged descriptors, unused latitude entries and unused levels.

## Acceptance

Qualify the complete fixed sine grid and verify the original before assembly emission. Check independent cyclic interpolation and perturbation relations, nonnegative ozone, positive-zero top values, exact boundary copying and untouched object bytes. Include all months, leap-day mapping, interval endpoints, zero and nonzero amplitudes, both selected height ranges, other integer modes, subnormal values, allocation lower bounds and padded dimensions.

Then compare complete original and native object bytes with zero differences, protected inputs, bounds and the immediate five-address ABI and FPCR. A paired adapter compares genuine calls on the same immutable inputs. Saved-file forecast acceptance and timing are later gates.

The original passed the independent check before assembly emission. The complete native gate passed 1800 protected calls, 59,414,400 returned object bytes and 1,265,400 independent relations with zero differences, preserving 329,520,000 input bytes. This includes 27,216 perturbed values and 60 leap-day calls. Immediate ABI and FPCR checks passed, and a changed-RPI case with a read-only result owner confirmed rejection before writes. The paired adapter smoke passed 36 calls, 1,188,288 returned bytes and 25,308 independent relations with zero differences. These results qualify this finite-grid update. Comparative timing remains open.

The elapsed-time extension separately passes 56 protected day and year rollover cases, including the largest nonnegative signed 32-bit offset. Each source/native and paired route matches 1,848,448 complete returned bytes with zero differences and passes 39,368 independent relations. Immediate saved registers, FPCR and 10,014,080 read-only input bytes pass. The original physical gate passed before the new year-remainder instructions were emitted. The previous 1800-case arithmetic, bounds and fixed-grid evidence is reused for unchanged stages.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| updecozc | 26 | 858,208 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
