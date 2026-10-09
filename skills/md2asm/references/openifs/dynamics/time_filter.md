# OpenIFS two-part time filter

Revision 1.2 retains the frozen arithmetic and interfaces and records the complete two-stage scientific check for GPTF1 and GPTF2 from OpenIFS 48.1.1. These numerical stages belong to the [atmospheric-motion model](../../../../../formulations/openifs/dynamics/atmospheric_motion.md), whose physical equations P02 to P04 and revision 1.0 stay unchanged. A time filter combines stored values from neighbouring times to reduce an unwanted oscillation between time levels.

## Fields and mathematics

Let $`a`$ be an earlier stored value, $`b`$ its current value before the forecast update, and $`c`$ its value after that update. All three represent the same field and have the same unit. Wind uses metres per second and temperature uses kelvin. Stored log-pressure values and tracer mass fractions have no unit. A derivative field keeps the units of its coordinate derivative.

The coefficients $`e_1,e_2`$ have no unit. GPTF1 first forms a partial result $`h`$, then GPTF2 adds the new-time contribution to form $`f`$.

```math
r=1-(e_1+e_2),\qquad
h=e_1a+rb,\qquad
f=h+e_2c.
```

Tracer fields use their separate coefficients REPSM1 and REPSM2. Other selected fields use REPS1 and REPS2. This filter operates on the stored variable, including a logarithm when that is the model's variable.

In exact mathematics, the combined weights sum to one. A constant history therefore stays constant. If $`a=b-d`$ and $`c=b+d`$, then $`f=b+(e_2-e_1)d`$. Equal coefficients preserve a linear history. For alternating values $`a=c=-b`$, the result is $`[1-2(e_1+e_2)]b`$. These identities check the numerical purpose independently of the comparison implementation. GPTF1 alone supplies only the partial result and does not preserve a constant by itself.

The implementation uses FP64, the 64-bit floating-point format. RN means one round to nearest with ties to even. Each addition, subtraction and multiplication has its own rounding point.

```math
r=\operatorname{RN}\!\left(1-\operatorname{RN}(e_1+e_2)\right),
\quad
h=\operatorname{RN}\!\left(\operatorname{RN}(e_1a)+\operatorname{RN}(rb)\right),
\quad
f=\operatorname{RN}\!\left(h+\operatorname{RN}(e_2c)\right).
```

Copies preserve every input bit. A clear operation writes positive zero. Preserve signed zeros and gradual underflow, with floating-point control register FPCR equal to zero. Fused multiply-add, contraction, reassociation, approximate arithmetic and reduced precision are forbidden.

## Complete stage decisions

A logical switch is a four-byte integer with value zero or one. LDTF1 enables the first part of filtering, LTWOTL selects two time levels, LGRADSP selects two gradient fields, LPC_FULL selects the full predictor/corrector update, and LNHDYN selects the non-hydrostatic fields. NFTHER counts thermodynamic variables. LDLSTEP means the last step in GPTF1, while LDFSTEP means the first step in GPTF2.

| GPTF1 condition | Complete work |
| --- | --- |
| LDTF1 false | Copy MSGRTL and MSGRTM from YT0 to YT9 only when LGRADSP is true. |
| LDTF1 true and LTWOTL true | Copy MU and MV. Copy MSGRTL and MSGRTM when LGRADSP is true. When LPC_FULL is true, also copy MT, MTL, MTM, enabled tracer fields and the three surface fields. Under that same full update, LNHDYN also copies six non-hydrostatic fields. LDLSTEP has no effect here. |
| LDTF1 true, LTWOTL false and LDLSTEP false | Apply the partial weighted result to MU, MV and MDIV, the three thermal fields when NFTHER is at least one, the six non-hydrostatic fields when LNHDYN is true, enabled tracer fields and the three surface fields. LGRADSP and LPC_FULL have no effect here. |
| LDTF1 true, LTWOTL false and LDLSTEP true | Clear every column and level of all PGMV fields after YT0%NDIM and every column of all PGMVS fields after YT0%NDIMS. Clear only active columns and all levels of enabled previous tracer fields. The full air and surface clears still occur when the active column interval is empty. |

| GPTF2 condition | Complete work |
| --- | --- |
| LTWOTL true and LDFSTEP false | Leave all arrays unchanged. |
| LTWOTL true and LDFSTEP true | Copy MU and MV from YT0 to YT9. |
| LTWOTL false | Copy selected values when LDFSTEP is true, otherwise add their rounded new-time contribution. Select MU, MV, MDIV, thermal fields when NFTHER is at least one, enabled tracers, the three surface fields and six non-hydrostatic fields when LNHDYN is true. Only the first-step copy also selects MNHX when LNHDYN is true and NVDVAR equals four. |

The six non-hydrostatic fields are MSPD, MSVD, MSPDL, MSVDL, MSPDM and MSVDM. The three surface fields are MSP, MSPL and MSPM. An enabled tracer has LT9 true and maps its current MP field to its previous MP9 field. No other stage, field or numerical update is supplied by a driver.

## Storage and supported inputs

NPROMA, written $`P`$, is the column capacity and NFLEVG, written $`L`$, is the number of vertical levels. PGMV has shape $`(P,L,N_{\rm air})`$, PGMVS has shape $`(P,N_{\rm surface})`$, and PGFL has shape $`(P,L,N_{\rm tracer})`$. Fortran column-major order places the first column next to the second column. Each value occupies eight bytes and needs eight-byte alignment.

KST and KEN select the inclusive active column interval. Require $`P\geq1`$, $`L\geq0`$, $`1\leq{\rm KST}\leq P`$ and $`{\rm KST}-1\leq{\rm KEN}\leq P`$. KEN equal to KST minus one is an empty interval. Surface work can still occur when there are no vertical levels. Every size and byte offset must fit a signed 64-bit address calculation.

The three array regions do not overlap. Every field index that a selected operation uses must fit its array. Current fields and previous fields occupy distinct storage, and selected field pairs and enabled tracer pairs are disjoint from other pairs. These conditions allow independent fields to run in a different loop order while preserving all rounded results. Unused field indices may be invalid, since they are not accessed. The field maps do not change during a call.

Require $`0\leq{\rm YT0\%NDIM}\leq N_{\rm air}`$ and $`0\leq{\rm YT0\%NDIMS}\leq N_{\rm surface}`$ for the full last-step clear. NUMFLDS is between zero and the probed YCOMP capacity of 2,163 descriptors. Only descriptors with LT9 true need valid MP and MP9 indices.

Weighted operations use finite inputs and coefficients whose rounded intermediate results remain finite. The scientific smoothing cases use nonnegative coefficients with $`e_1+e_2\leq1`$. Copies, clear operations and untouched storage can contain arbitrary bit patterns, including NaN payloads. A NaN is a floating-point value that does not represent a real number.

The storage-only GNU Fortran 12.3 probe records the following object sizes and offsets in bytes. Descriptors for allocated arrays inside these objects are not used by either routine.

| Object or field | Size or offset |
| --- | --- |
| GEOMETRY | 17,096 bytes, NPROMA at 5,144 and NFLEVG at 5,224 |
| TGMV | 1,560 bytes, NDIMGMV at 992, NDIMGMVS at 996, YT0 at 1,000 and YT9 at 1,108 |
| YT0 and YT9 | 108 and 252 bytes, respectively |
| MODEL_GENERAL_CONF_TYPE | 1,556,112 bytes, NFTHER at 8 and inline YGFL at 184 |
| YGFL | 1,359,136 bytes, NUMFLDS at 0, NDIM at 48 and YCOMP at 3,848 |
| One YCOMP descriptor | 368 bytes, LT9 at 88, MP at 168 and MP9 at 180 |
| TDYN | 4,720 bytes, REPS1 at 0, REPS2 at 8, REPSM1 at 16 and REPSM2 at 24 |
| TDYNA | 456 bytes, LNHDYN at 8, LTWOTL at 20, NVDVAR at 32, LGRADSP at 200 and LPC_FULL at 336 |

| Field | Offset within YT0 | Offset within YT9 |
| --- | ---: | ---: |
| MU, MV, MDIV | 12, 16, 32 | 8, 12, 80 |
| MT, MTL, MTM | 20, 24, 28 | 16, 20, 24 |
| MSPD, MSVD | 48, 60 | 96, 108 |
| MSPDL, MSVDL | 52, 64 | 100, 112 |
| MSPDM, MSVDM | 56, 68 | 104, 116 |
| MSGRTL, MSGRTM | 88, 92 | 208, 212 |
| MNHX | 72 | 120 |
| MSP, MSPL, MSPM | 96, 100, 104 | 216, 220, 224 |
| NDIM, NDIMS | 0, 4 | 0, 4 |

## Assembly interface

The application binary interface, or ABI, defines how a caller supplies arguments and which registers a routine must preserve. Both functions use the GNU Fortran address-based interface on AArch64, with no hidden string lengths or optional arguments.

GPTF1 has twelve address arguments. Registers x0 to x7 hold GEOMETRY, TGMV, model configuration, TDYN, TDYNA, LDTF1, KST and KEN. The incoming stack holds LDLSTEP at byte zero, PGMV at eight, PGMVS at sixteen and PGFL at twenty-four.

GPTF2 has eleven address arguments. Registers x0 to x7 hold GEOMETRY, TGMV, model configuration, TDYN, TDYNA, KST, KEN and LDFSTEP. The incoming stack holds PGMV at byte zero, PGMVS at eight and PGFL at sixteen.

Each direct body owns its complete selection, weighting, copying and clearing. Private assembly helpers handle field loops and never supply a missing forecast stage. Each public frame is 288 bytes, aligned to sixteen bytes. Its private tracer helper adds sixteen bytes, so the largest simultaneous stack use is 304 bytes. Preserve x19 to x29 and x30, keep x18 untouched, and use only caller-owned FP registers d0 to d7. Neither routine changes its configuration objects or the caller's FPCR. Only the declared arrays and the private stack frame are writable.

## Verification and provenance

The critical corpus freezes 202 GPTF1 calls and 106 GPTF2 calls before direct emission. It covers the full relevant logical selections, separate thermodynamic and non-hydrostatic choices, alternative field maps, disabled invalid tracer indices, unused invalid air-field indices, partial and empty intervals, zero and single levels, odd widths, protected array ends, signed zeros, gradual underflow, NaN-preserving copies and witnesses that distinguish separate rounding from a fused operation.

Use one [critical verifier](../../../../../bench/openifs/dynamics/time_filter.c) for both stages. Compare every output byte with unchanged strict Fortran, protect configuration objects as read-only pages, check writable buffer guards and confirm FPCR before and after each call. Independent long-double equations check each weighted result, while exact mathematical copying and positive-zero checks cover the other changed values. Combined constant, linear and alternating histories also check the complete two-part filtering when both direct bodies are available.

For critical inputs, write 32 little-endian 32-bit integers for routine number, case, shape, interval, capacities, component count, thermodynamic count, switches, non-hydrostatic mode, value pattern, map variant and guard selection, followed by reserved zeros. Next write the contiguous 108-byte YT0 and 252-byte YT9 maps, four FP64 coefficients, each configured tracer's LT9, MP and MP9 integers, then full incoming PGMV, PGMVS and PGFL arrays. Critical outputs use the same 128-byte integer header followed by the three full returned arrays in that order. No addresses, padding, timestamps, rounding or normalisation are added.

The source bodies, storage probe, frozen contract, input streams, toolchain and emission order remain identified in ignored .runtime/openifs/timefilter/. Consult compiler-produced reference instructions only after direct assembly has been emitted. Accept the complete bodies only after critical physics and exact-byte checks, instruction audits and all captured forecast calls pass. A timing or optimisation claim requires subsequent matched measurements.

The two-stage check uses six complete histories, covering constant, linear and alternating values with symmetric and asymmetric coefficients. It compares all three complete arrays after each of the twelve stages, giving 29,184 identical bytes, 204 independent final identities and 204 cases that require the final new-time term. The original 202 and 106 cases retain all input and output bytes. A source-only correction sets GPTF2's default export name to gptf2_; the earlier verification builds already selected its correct private name, and the rebuilt object is identical.
