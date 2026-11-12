# Operational Time Coefficients

This UPDTIM child converts the time interval into six coefficients used by later calculations. It preserves the existing physical model. Time is in seconds and the Earth radius is in metres.

`md2asm_update_operational_time_coefficients(MODEL,capacity,interval,constants)` takes four arguments in x0 through x3. MODEL has 4,275,088 bytes, interval points to one FP64 value, and constants has 520 bytes with the Earth radius at byte 104. All ranges are mapped, eight-byte aligned and nonwrapping. Constants are separate from MODEL. Interval may point to the existing TDT member inside MODEL and is loaded before any store.

Multiply interval by 0.5, round, then divide by radius and round. Square that result, then divide the square separately by 6 and by 2. Store the interval itself as RTDT and the larger of interval and one second as TSPHY. These six FP64 assignments change only MODEL bytes 1359544, 1359552, 1359560, 1359568, 1359576 and 4150016. Each listed address starts an eight-byte result. No other MODEL byte changes. Fusion, reassociation and approximate operations remain disabled.

The interval must be finite, positive and at most 86,400 seconds. Radius must be finite and between one million and ten million metres. Floating-point control FPCR must be zero. This leaf has no frame or imports and preserves x18, saved registers, FPCR and the system error value. It returns 0 on success or 2 before writes on refusal. Natural arithmetic flags remain visible.

Complete MODEL and raw-status comparisons pass for 450, 900, 1 and 0.5 seconds, including an interval that aliases the live MODEL value. Independent high-precision relations and atomic refusal checks pass. The complete clock, solar calculations, monthly forcing and full forecast remain separate.
