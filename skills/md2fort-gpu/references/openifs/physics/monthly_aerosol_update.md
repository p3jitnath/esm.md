# Complete Monthly Aerosol Update on the GPU

Aerosols are small solid or liquid particles in the air. UPDECAEC selects the calendar interval, interpolates aerosol tables and updates the five aerosol profiles and the model aerosol fields. The complete device path includes Gregorian calendar arithmetic, both table ranks, complete hydrostatic pressures and the original profile calculation.

The original ABI retains five addresses and a 64-byte common context. Its specific record has 4,096 bytes. Private scratch includes the calendar workspace, seasonal profiles and complete mutable owners. Typed storage records determine its exact size from the admitted grid. The Arm caller owns allocation and pointer setup, while one serial GPU thread performs the complete numerical call. Bounds, alignment, saved registers, x18, floating-point state and the error indicator follow the accepted child contracts.

Eighteen original calls and 36 selected-CPU/GPU calls match 6,928,448 complete output bytes. Independent checks cover 295,632 physical relations. Thirty-nine critical controls and a complete device-memory graph pass. New exponential, logarithm and power operands pass independent high-precision checks. Both complete source reviews and the current CPU bindings pass.

The pressure child retains its source-consumed and discarded arithmetic, including exponential calls in the inactive pressure mode. This component result adds one original routine and no full GPU forecast credit.
