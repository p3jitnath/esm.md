# Radiation Forcing Update Contract

[UPDRGAS](../../../../../src/openifs/physics/updrgas.S) implements [Radiation Gas and Solar Forcing](../../../../../formulations/openifs/physics/radiation_gas_forcing.md), revision 1, equation U1. It includes the complete numerical GET_YEAR stage and privately binds the complete direct [greenhouse lookup](greenhouse_timeseries.md) and [solar lookup](solar_irradiance.md). GET_YEAR is contained in the original source and appears separately in the audited queue. Its direct two-address stage remains identifiable in this assembly file, with a separate actual-execution counter in the paired build.

## Domain and Numerical Stages

Support a positive fixed year, or the current forecast date. Dates must lie strictly inside each required input table. Both lookup domains and unchanged proofs are reused. A missing required table is rejected. All molar masses and used solar values are finite and positive. Integers and logical values use their original GNU kinds, with logical values zero and one.

For current dates, NINDAT is a valid positive YYYYMMDD calendar date. NSTADD is the integer number of elapsed days. Normally use it directly. If LNF is false and NSTADD is zero, compute restart days from TSTEP and NSTAR2. TSTEP and RDAY are finite and positive. Their NINT results and the selected integer product fit the original signed 32-bit type, and the rounded RDAY is nonzero. NINT rounds a halfway value away from zero.

Let IYEAR, IMONTH and IDAY be the integer date parts. The monthly cumulative mean-day table is [0, 31, 59.25, 90.25, 120.25, 151.25, 181.25, 212.25, 243.25, 273.25, 304.25, 334.25]. Form ZDAY as rounded REAL(IDAY) minus 1, then add the selected monthly value, then rounded REAL(ISTADD). Form year as REAL(IYEAR) plus ZDAY divided by 365.25. This is the original average-year convention. A positive NCMIPFIXYR instead gives REAL(NCMIPFIXYR) plus 0.5.

For restart, first form ITIMESTEP=NINT(TSTEP). If LTWOTL is true, form REAL(NSTAR2)+0.5, multiply by TSTEP and use NINT for IZT. Otherwise use the signed integer product ITIMESTEP*NSTAR2. Set ISTADD to integer IZT divided by NINT(RDAY), truncating toward zero. No calendar stage is supplied by a driver.

Before gas lookup, compute eight separately rounded divisions M_g/RMD, in the source gas order. The complete lookup returns seven volume ratios. The original nitrogen-dioxide placeholder is the FP64 literal 500.E-13. Multiply each volume ratio by its rounded mass ratio and write all eight mass outputs in source order. Preserve the explicit separate division and multiplication.

If PSOLINC is present, copy its raw FP64 value into RSOLINC. Otherwise, NHINCSOL zero copies RI0. Any other NHINCSOL value invokes the full direct solar lookup at the same date. The parent executes all numerical stages itself. Formatted diagnostics and DR_HOOK instrumentation are outside canonical output and are omitted by the numerical replacement.

## Five-Address ABI and Bounds

The GNU AArch64 application binary interface, or ABI, receives YDDYNA, YDERAD, YDERDI, YDRIP and optional PSOLINC in x0–x4. A null fifth address means absent. All objects have eight-byte alignment and disjoint owners.

| Object | Bytes | Consumed fields |
| --- | --- | --- |
| TDYNA | 456 | LTWOTL at 20 |
| TERAD | 2040 | NHINCSOL at 148 |
| TERDI | 176 | RCARDI 16, RCH4 24, RN2O 32, RNO2 40, RCCL4 56, RCFC11 64, RCFC12 72, RCFC22 80, RSOLINC 168 |
| TRIP | 175976 | NSTADD 16, TSTEP 200, NCMIPFIXYR 33332 |
| PSOLINC | 8, if present | Scalar solar override |

YDERDI alone is mutable. Both global table owners, all input objects, optional solar scalar, scalar setup constants and date globals remain read-only. Preserve complete TERDI bytes, including unused fields. The parent uses a fixed 256-byte frame and preserves x19–x29, the low 64 bits of v8–v15, stack alignment and FPCR, and does not use x18. The separately queued GET_YEAR stage has the direct two-address interface TDYNA in x0 and TRIP in x1, returning the decimal year in d0. It uses caller-saved registers and no frame. The paired build enables UPDRGAS_COUNT_YEAR, which counts its actual executions and records the year used by the parent. These two metadata words lie outside canonical simulation output.

## Arithmetic and Acceptance

Use separate ordered FP64 additions, subtractions, divisions and multiplications with round-to-nearest, ties to even, gradual underflow and signed zeros. Only the source NINT operation uses a local explicit halfway-away conversion. FPCR remains unchanged. Fused arithmetic, reassociation, approximate division and fast-math are forbidden.

Canonical output is the complete 176-byte TERDI owner in little-endian storage order. Acceptance requires zero differing bytes, complete read-only input owners and table owners, independent gas mass and solar relations, current/fixed dates and restart branches, optional scalar selection, protected buffer bounds, immediate ABI checks and FPCR zero. Reuse the complete accepted gas and solar interpolation proofs. New checks concern date conversion, parent conversions and selection only.

## Positive Optimisation

Retain the once-rounded mass ratios in one fixed frame across the child lookup. Reuse the same date for both lookups, and call each complete direct child without an intermediate array allocation. Use the source's exact quarter-day month values and local integer date extraction.

## Verification State

The complete native parent passes 44 protected calls, 7 744 complete TERDI output bytes and 836 independent date, mass-ratio and solar-selection relations with zero differences. The contained GET_YEAR stage executes 42 times, while two fixed-year calls bypass it. Current days, signed restart counts, both restart schemes, halfway-away cases that alter whole days, month offsets and all three solar choices pass. An unused NaN timestep is preserved when the source reads elapsed days directly. Complete objects, table owners, optional scalars, setup constants and pointer globals remain unchanged, and immediate saved-register and FPCR checks pass.

The paired smoke passes sixteen genuine parent calls and fourteen actual native GET_YEAR executions, 2 816 complete output bytes and 304 independent live relations with zero differences. Unchanged complete child proofs are reused.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| updrgas | 28 | 4,928 | Complete routine owners |
| updrgas::get_year | 28 | 4,928 | Complete parent owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
