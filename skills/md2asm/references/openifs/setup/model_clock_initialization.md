# Owned Model Clock Initialisation

The model clock supplies the start date, seconds within the day and time-step controls used by the selected forecast loop. This assembly child follows the field assignments in SURIP0, SURIP, SU2YOM and SU3YOM. It receives explicit file metadata and controls. It uses no original module data, type table, callable or state packet. The selected MOD_INI calls do not change these values when NCONF is one.

## Interface And Input

The interface is `int md2asm_initialize_model_clock(inputs, state, capacity)`. Registers x0 and x1 carry separate, eight-byte-aligned input and output addresses, while x2 supplies the output capacity. The input has 40 bytes and the output needs 360 bytes. Both complete ranges must be mapped and must not wrap or overlap. Return value zero means success. Return value two rejects unsupported input before floating-point calculations or output mutation.

| Input offset | Type and meaning |
| --- | --- |
| 0 | int32 date as YYYYMMDD, from 1901 through 2099 |
| 4 | int32 seconds within the day, from 0 through 86399 |
| 8 | FP64 time step, exactly 3600 seconds |
| 16 | Eight characters, lower-case t followed by one or two digits selecting 1 through 25 steps, then spaces |
| 24 | int32 NFOST, zero in this selected route |
| 28 | Four retained reserved bytes |
| 32 | FP64 trajectory time step, either minus one for the source default or 3600 seconds |

A trajectory follows air movement between grid points. The actual configuration starts on 15 October 2004 at 43,200 seconds within the day, with the stop string t25. Its selected source controls are NCONF and NSUPERSEDE equal to one, with L4DVAR and LELAM false. The output namespace must already have false LASTRF. Other source-unwritten bytes retain their incoming values.

## Output And Calculation

Output offsets 0 and 4 hold NINDAT and NSSSSS as int32 date and seconds. Offset 8 holds FP64 RTIMST, the elapsed seconds from 1 January 2000 at 12:00. Offsets 16, 20, 24 and 28 hold int32 LASTRF, NSTAR2, NSTOP2 and NSTP. LASTRF is retained, while the remaining values become zero, the parsed stop count and one. Offset 32 retains the int32 NSTAR2CPL value. Offset 36 stores int32 NSTEP as minus 999, and offset 40 stores the selected FP64 trajectory time step in seconds.

The final 312 bytes, starting at offset 48, are the typed TRIP clock prefix. Its relative offsets 0 and 4 hold int32 NSTART and NSTOP, 8 holds the eight stop characters, and 16, 20 and 24 hold zero int32 NSTADD, NSTASS and NFOST. The four padding bytes at 28 remain unchanged. FP64 RSTATI at 32 becomes positive zero, and RTIMTR at 40 copies RTIMST. Source-listed FP64 words from 48 through 128, 168 through 192 and 216 through 304 become positive zero. They initialise the time coefficients and solar and lunar state for later producers. The four next-step solar words from 136 through 160 remain unchanged. FP64 TSTEP and TDT at 200 and 208 each become 3600 seconds. Members after this prefix belong to other model components and are outside this interface.

The calendar calculation preserves the original statement-function order. January and February use the preceding year and months 13 and 14. The routine separately multiplies the adjusted year by 365.25 and the adjusted month plus one by 30.601, truncates these results to integers and combines the source calendar terms. It adds 1720994.5, subtracts 2451545, multiplies by 86400 seconds per day and adds the input seconds. Each FP64 multiplication and addition rounds separately. This is the original calendar expression, with no fused or approximate arithmetic.

## ABI And Verification

The application binary interface defines argument registers and preserved processor state. This leaf uses no stack and calls no external function. It changes only caller-saved registers x0 through x17 and d0 through d1, preserving x18, x19 through x29, v8 through v15, the stack pointer, FPCR and errno. FPCR, the floating-point control register, must be zero. Source arithmetic can add flags to FPSR, the floating-point status register. The original source field control remains separate from complete parent namelist I/O, solar diagnostics, logging and other object construction. No complete original-producer body credit is claimed.

Six source-field cases compare 2,160 complete returned bytes and 240 complete read-only input bytes with zero differences. Twelve paired ABI/status calls, nine unchanged-output rejection cases and one protected-page-end case pass with every native register mask zero. Forty-two independent Gregorian-calendar and whole-hour relations pass. The actual header gives RTIMST equal to 151113600 seconds. Source and direct arithmetic each change fresh FPSR from zero to 16 while retaining errno 777. The production object has no undefined symbol or dynamic-library dependency, and independent source and ABI review passes. Complete owned-caller composition and an autonomous forecast remain unfinished.
