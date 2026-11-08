# Ozone Climatology Contract

Revision 1.0. The input is [ozone_climatology.md](../../../../../formulations/openifs/physics/ozone_climatology.md). The original exported routine is `RADOZC` in `arpifs/phys_radi/radozc.F90`. Its preparation routines define the supplied mixing ratios in kilograms per kilogram.

## Interface And Bounds

Eleven argument addresses enter the Arm ABI. Registers x0 through x7 point to the ozone object, first column, last column, full column count, level count, column spacing, output column count and destination shift. The last seven of those are INTEGER4 values. Stack offsets 0, 8 and 16 hold the pressure, latitude-sine and output FP64 buffers. The metadata-only GNU layout probe measures a 33,008-byte TEOZOC object. Latitude coordinates begin at byte 776. The 64 by 61 profile begins at byte 1288, with latitude first and pressure second. Pressure coordinates begin at byte 32520.

Pressure has full-column count times level-count-plus-one cells. Latitude sine has full-column count cells. Output has output-column count times level-count cells. All arrays are contiguous and one-based, with columns fastest. Inputs and outputs are separate and naturally aligned. Source rows run from first to last in positive column-spacing steps. Destination rows start at shift plus one and advance by one. Bounds and address products must fit their owners and signed 64 bits. Empty column ranges or zero levels write nothing.

The global `__yomdyncore_MOD_lape` selects normal or aquaplanet climatology. The normal source uses the first 19 latitude points and pressure indices 0 through 35. The aquaplanet source uses all 64 latitude points and indices 0 through 60. Latitude and pressure coordinates are strictly increasing. Every model pressure is at least the first climatology pressure, and successive model edge pressures increase. Inputs are finite, mixing ratios are nonnegative, and the grid has no rotation or stretching. No allocated component of the object is accessed or changed.

## Complete Ordered Calculation

Read the latitude sine from the first requested source column. In the normal mode, scan latitude intervals in decreasing index order. Inclusive equality at both ends selects the lowest matching interval. Intervals 1 and 18 copy their outer profile, even though the source computes a weight. Other intervals use `low+weight*(high-low)`, with separate subtraction, multiplication and addition. In aquaplanet mode, values at or outside either endpoint copy that endpoint. Interior interval ties and blends use the same source order.

For every pressure interval compute `(1/(left_pressure-right_pressure))*(left_ozone-right_ozone)`. Round the reciprocal before the product. For each model face, find its interval with `p>=left` and `p<right`, then compute `right_ozone+(p-right_pressure)*slope`. At or below the final climatology level, copy its final value. For each layer, subtract edge pressures, add edge ozone values, multiply those two rounded values, then multiply by 0.5.

The native body may retain two successive rounded face values and pressures in registers. This replaces the source's complete intermediate face matrix without changing any output dependency. This accepted buffer-reuse method is also recorded in [greenhouse-gas interpolation](greenhouse_gas_interpolation.md).

Each FP64 operation rounds separately to nearest with ties to even. Keep signed zero, gradual underflow and FPCR zero. Forbid fused instructions, reassociation, approximate division and reduced precision. The complete caller contains all numerical stages and needs no mathematical library.

## Output And Acceptance

Canonical output is the full output owner's little-endian FP64 bytes, including untouched columns. Objects, input scalars, latitude and pressure arrays, guards and saved registers stay unchanged. Require zero differing bytes against the genuine strict original exported body.

Independently evaluate P01 and the pressure-linear profile at 100-digit precision, then P02. Check nonnegative ozone, manufactured constant and linear profiles, latitude ties, pressure ties, final-profile continuation, both global modes, cropped and spaced columns, destination shifts, zero levels and empty ranges. Compare values with the conservative bound `1024*2^-52*max(2^-1022,abs(expected))` plus 16 minimum subnormal units. Critical and live forecast acceptance are recorded separately.

The direct source is [radozc.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/radozc.S). Its fixed frame is 1120 bytes and contains the latitude-interpolated profile and its slopes. It restores x19 through x29 and the link register, uses only caller-saved FP registers, leaves x18 and FPCR unchanged, and writes only selected destination cells.

## Critical Results

The native check passed 1,248 protected placements, 148,070 independent profile relations and 5,670,912 complete source/native output bytes with zero differences. Inputs, inactive output cells, saved registers and FPCR passed. The instruction review found no fused or approximate operations, no FPCR writes and no x18 use.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 7,782,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
