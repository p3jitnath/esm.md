# Solar Averaging With Original OpenIFS Behaviour

A solar averaging window covers part of a model day. The original OpenIFS calculation clips this window to one daylight interval. When the window also intersects daylight from a neighbouring day, that clipping can omit an illuminated segment. This separate assembly entry preserves the original calculation and records its physical limitation.

The entry is `md2asm_cos_sza_openifs_source_compatibility` in [source_matching_solar_zenith_angle.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/source_matching_solar_zenith_angle.S). It shares one source body with the [strict solar entry](cos_sza.md). The default strict binary remains exactly unchanged. The separate entry omits the 14-instruction scientific-domain test, while retaining the original ordered arithmetic, elementary functions, other guards and output writes. Removing the complete test also removes its extra floating-point operations.

## Interface And Bounds

The application binary interface (ABI) has ten address arguments. Its owner sizes, alignment, register obligations and scalar bounds are defined in the strict contract. They apply here except for its additional single-period condition. The block has 1–4,096 columns. The fixed stack frame remains 384 bytes, with a private result buffer that precedes writes to active output cells. The caller keeps every owner alive through the call. The procedure returns no value, so register `w0` carries no error status. Other invalid inputs retain the declared abort path.

The operational integration explicitly selects this entry at one radiation call and two complete-physics calls. Both providers retain the strict entry. Assembly implements the calculation directly.

## Checked Agreement And Physical Limit

One supported-grid witness uses latitude 66.537783 degrees and longitude 6.157707 radians from the actual 9 km input grid, called TCo1279. The source-produced solar state uses a 450-second model step and a radiation interval of eight steps. This fixture represents a supported grid cell, rather than the uncaptured numerical payload of the earlier failed forecast.

The separately compiled original routine and the assembly entry each ran once. Their complete 136-byte output owners agree with zero differing bytes. All 178,352 read-only bytes and 128 inactive output bytes remain unchanged. ABI checks pass, and both calls produce the same floating-point control, exception flags that record conditions such as rounding, and the library error number `errno` from a fresh floating-point status. Independent source review confirms that the remaining instructions, numerical calls and buffer rules are retained.

The original result is 0.0011753973039942411, while an independent integral over both daylight segments gives 0.0011475754958735556. Both values are dimensionless solar cosines. The difference is a known physical-model limitation, which remains visible alongside exact source-output agreement. These component results provide no whole-forecast physical acceptance or comparative runtime. Complete operational raw-state and saved-output agreement remain open.
