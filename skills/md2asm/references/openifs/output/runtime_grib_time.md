# Runtime GRIB Time Labels

GRIB is a binary format for weather fields. The direct assembly entry `md2asm_set_runtime_grib_time` implements the selected `GRIB_SET_TIME` source route through the public ecCodes C interface. It receives a borrowed ecCodes handle in x0, a128-byte field specification in x1, an int32 valid-field result in x2 and the actual logical `LPPSTEPS` value0 or1 in w3. The caller retains every input and owns the handle. A successful return is0 and publishes valid0 or1. The outer writer skips fields whose valid result is0.

The specification stores a signed-int32-representable parameter number at8, a nonnegative int32 step at40, a positive finite FP64 time step in seconds at64, a borrowed40-byte `NSTEPLPP` table at72 and the common128-byte Fullpos context at80. Bytes96through127 are zero. Other specification members belong to the field encoder. `NSTEPLPP` is the source INTEGER4 array5by2, with five parameter numbers followed by their five previous steps. The first matching parameter wins. No match or a negative previous step selects the parameter-specific interval rules.

Common context72 borrows the genuine112-byte output metadata. Its local definition at0 is1, leg at80 is1 and type at90 is `fc`. Context64 borrows the canonical552-byte loop record. `RESTART` at44 is the single character `0`, while `LVAREPS` at60 is a false four-byte logical value. Bytes45through47 are padding and remain unread. Context80 points to the actual false profiling control. The fresh source route assigns `NSTEPINI=0` in original `arpifs/setup/suarg.F90` line183. Restart, analysis and multiple-leg forecasts are outside this component's supported route. Context88 remains the distinct input classification/date record and does not supply an initial step.

Each pointer is aligned for its declared type, addresses a complete nonwrapping span and remains live through the call. The four-byte result is disjoint from every consumed input and from the borrowed handle. Handles and records require eight-byte alignment, while the valid result, logical control and previous-step table require four-byte alignment. The entry checks its explicit metadata and selected controls before its first handle setter.

The current step is converted from a signed integer to FP64, multiplied by the time step and truncated toward zero to whole seconds. When `LPPSTEPS` is true, only the current-step multiplication uses3600seconds instead. A nonnegative previous step still uses the actual time step, followed by the source addition of zero initial-leg seconds and integer truncation. Products must round to nonnegative values below2147483648. Integer-only admission keeps the previous-step floating-point operations after the first public setter, where the original routine performs them. No fused operation or reassociation is used.

The interval categories retain their source parameter numbers and whole-hour requirements.

| Source behavior | Parameter numbers |
| --- | --- |
| Three-hour maximum window, clamped at initial time | 228026,228027,228028,228222,228223 |
| Six-hour maximum window, clamped at initial time | 121,122,123,228224,228225 |
| One-hour average | 228051,228053 |
| Three-hour average | 228057,228059 |
| Six-hour average | 228058,228060 |
| Six-hour maximum, invalid before its full window | 228035,228036 |
| One-,three-,six-hour mode | 260320,260321,260339 |
| One-,three-,six-hour severity | 260318,260319,260338 |
| Accumulation retained at zero time | 222001through222256 and223001through223256 |

Other parameters are instantaneous unless the previous-step table selects a maximum interval. Average, mode, severity and the two unclamped maximum parameters become invalid when their requested window begins before initial time. The source zero-time instantaneous override and its accumulation exception remain unchanged.

The first public setter is `timeRangeIndicator=0`. The source `stepType`, second units, conditional `startStep`, `endStep`, zero-time override and final positive whole-hour unit change keep their original order. A failed public service returns its natural error and leaves the valid result unchanged. The borrowed handle can be partly changed, so the caller deletes its private clone after a failure. Invalid metadata returns2 before changing the handle. The entry preserves x18, all callee-saved registers, the floating-point control register and16-byte stack alignment. Floating-point status and public-service errno keep their natural effects. The fixed private frame is384bytes and the routine allocates no memory. Public ecCodes memory belongs to the caller's process memory bound.

The focused original/native component comparison passed57 pairs with10214 identical complete message bytes,228 identical valid-result bytes and302 identical setter records, including floating-point status at every setter. It also passed657 time-window, unit and preservation relations, nine atomic admission refusals and one genuine ecCodes service-error observation. Fixtures covered both GRIB editions, all24 named interval cases, composition-range endpoints, zero and fractional times, previous-step selection, `LPPSTEPS` and maximum admitted second counts. Every native ABI mask was zero. Three separate GNU reference calls had the retained x18 exception, while final and setter-boundary floating-point state matched. Earlier fixture failures and their raw records remain archived locally. Complete operational writer files and the full forecast require separate acceptance.
