# UPDCAL Contract

The [physical note](../../../../../formulations/openifs/physics/calendar_days.md) describes Gregorian dates. The direct [assembly](../../../../../src/openifs/physics/updcal.S) contains the complete date calculation from arpifs/climate/updcal.F90, including both signs of the day update.

## Inputs and outputs

The entry md2asm_updcal takes nine ordinary addresses in the original order KD0, KM0, KY0, KINC, KD1, KM1, KY1, KLMO and KULOUT. The first four inputs and KULOUT contain one signed 32-bit integer each. The three date outputs contain four bytes each, and KLMO contains twelve adjacent signed 32-bit month lengths, or 48 bytes. Integers use little-endian encoding and four-byte alignment. Every output is a distinct owner and does not overlap an input. Input owners are read only. KULOUT is negative, so the source does not write a console date.

The initial Gregorian date has year 1600 through 3000. KINC is at most 36,600, and a negative increment cannot cross the first day of the initial year. This scope permits the forecast's forward date updates and preserves the original arithmetic. The original backward year boundary calculates February before decreasing the year, so that boundary has no admission claim.

## Ordered calculation

First fill KLMO with the original 31-day, 30-day and February branches. February has 29 days when the year remainder modulo four is zero and the remainder modulo 400 differs from 100, 200 and 300. Copy the initial date to the three outputs. For each forward day, increase the day, carry it into the next month if it exceeds the month length, then carry December into January and update February for the new year. For each backward day, decrease the day, move into the previous month when it reaches zero, recompute February for the current year, copy that month's length to the day and finally decrease the year if the new month is December. Preserve this last source order even though the admitted backward range stays within one year.

The complete returned record is KD1, KM1, KY1 and the twelve KLMO values in that order, 60 bytes. Integer arithmetic has no overflow in the admitted scope. The driver supplies no date calculation.

## Arm interface

The first eight addresses use x0 through x7. The ninth address is at the caller's stack pointer. The function preserves x19 through x29, the return address, the sixteen-byte stack alignment and the floating-point control and status registers. A 256-byte frame holds a private month table before any public write. The entry requires FPCR zero, as for the other study entries. It rejects unsupported dates, increments, console output, null or misaligned addresses and overlapping owners before a public write. It uses integer arithmetic and copies, with no numerical Fortran call or floating-point instruction.

## Original-first evidence

Before assembly emission, 82 protected original calls pass 4,920 complete output bytes and 1,230 independent Gregorian relations using Python's date library and a separate month-length rule. These cases include the 1900 and 2000 century rules, December carry, large forward updates, zero updates and backward updates within one year. The original floating-point status remains zero and errno remains 47. Local source inputs and complete output bytes are frozen for the focused native and interface checks. The 164 protected native placements pass 9,840 complete output bytes with zero differences and 2,460 independent relations. Six full nine-address ABI calls preserve the stack, all saved registers, seeded status and errno. Thirteen shared-owner entry rejections leave every output byte unchanged. Four paired parents and two profiled pairs match 360 complete bytes and 90 independent relations, with exact status and errno. Actual forecast acceptance remains pending.
