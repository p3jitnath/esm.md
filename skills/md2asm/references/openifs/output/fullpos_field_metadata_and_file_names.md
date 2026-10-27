# Fullpos Field Metadata And File Names

These direct AArch64 entries replace the selected SUVFPOSL, SUFPOFNAME and GET_CLINC work. Fullpos prepares forecast fields for output. This contract covers the field descriptions and names that its later writer consumes. It does not cover the enclosing output calculation, file encoding or a complete forecast.

## Field descriptions

`md2asm_create_runtime_output_field_metadata` keeps the original eleven address arguments. The first eight use `x0` through `x7`. The level array, configuration integer and configuration character use incoming stack offsets 0, 8 and 16. The input name length 16 and configuration length 1 use offsets 24 and 32. An added context pointer uses offset 40. Its first word points to the actual false profiling flag and its second word gives the allocation budget in bytes.

The request record has 1160 bytes. The separate spectral and gridpoint output records each have 744 bytes. Their addresses and the context use eight-byte alignment. The input code, surface flag and name arrays use complete contiguous GNU Fortran array descriptions with lower bound 1 and at least 686 elements. Integer and logical elements have four bytes. Input names have sixteen bytes. An array description stores its buffer address, bounds and strides, which give the spacing between elements. The caller supplies mapped nonoverlapping records and payloads and keeps every input alive through the call.

The supported source domain count is 1 through 8. The level count is 0 through 512, the request field count is 0 through 686 and the expanded row count is at most 351232. Source configuration values are 0 through 2. Selected coordinate characters are S, P, B, T and V. P is the actual pressure output character. A zero level count is permitted for surface-only requests and the empty level payload remains unread.

The entry retains the source sixteen-allocation order and the source field, level and domain order. It copies declared codes, names and levels, writes positive zero for surface levels and preserves source domain padding. The requested allocation total must fit the context budget, which is at most 128 MiB. Each empty allocation retains a distinct minimum one-byte token. Its undefined payload is never read. The private aligned frame has 768 bytes. No original OpenIFS routine supplies a production value.

A successful call returns 0. Allocation failure returns 1 after releasing the reached owner prefix. Admission refusal returns 2 before output writes. A source consistency failure returns 3 and requires caller teardown. `md2asm_release_runtime_output_field_metadata(spectral744,gridpoint744)` frees the sixteen associated payloads and clears their base words. Other record bytes retain the source values. The caller releases a valid matching result exactly once.

## File names

`md2asm_runtime_fullpos_output_file_names` keeps the six original address arguments for input names, output names, optional step, optional extension, optional digit count and optional timestep. The two name element lengths are 256 in `x6` and `x7`. The extension length uses incoming stack offset 0 and the common 128-byte Fullpos context uses offset 8. Its word 72 points to the unique produced output metadata record. The source time format is its four-byte word at offset 104. Context word 80 points to the actual false profiling flag.

Both name arrays use GNU rank-one CHARACTER descriptions with lower bound 1, equal count 1 through 8 and positive source strides. Their complete backing spans must be mapped and separate. The time format is 0, 1 or 2. A present positive digit count is 1 through 6 and a negative count has magnitude 1 through 16. A present step is a nonnegative four-byte integer. A present timestep is finite and positive in seconds. The source converted hours and rounded integers must fit the original four-byte integer range.

The entry retains the ordered conversion from step times timestep to hours. It uses source truncation or nearest-integer rounding with halfway values away from zero, then the original ordered hour and minute subtractions. It preserves the source result when a rounded minute or second is 60. A missing step gives INIT. Negative digit counts use the integer step directly. The entry trims only trailing spaces, preserves embedded zero bytes, appends the exact extension and fills every remaining output byte with spaces. It checks all final lengths before writing a destination.

This entry has a 768-byte aligned private frame and makes no allocation or file call. It returns 0 for success or 2 for admission refusal. Both families preserve the Arm application binary interface, including `x18` and saved registers. They require floating-point control register 0 and retain the natural sticky floating-point status of the source operations. The arithmetic uses separate operations without contraction.

## Accepted component check

The bounded check made 36 calls. Three source and native field-description profiles compared complete 1488-byte records, all defined payloads, untouched input spans and matched release records. The profiles included mixed spectral and gridpoint fields, source configuration 1 and a surface-only zero-level request whose level address was inaccessible. Ten source and native name pairs covered INIT, formats 0 through 2, 450-second steps including 96 and 576, rounding, raw integer labels, extensions, strided arrays and embedded zero bytes. Four native refusals checked the allocation budget, reached-prefix allocation cleanup and name admission.

All 455672 compared bytes agreed. The 7693 independent field and name checks passed, including field identities, positive-zero surface levels, source time labels and untouched padding. All 36 immediate status records passed. The allocation guards, pointer slots, page protections, original verification flags and owner release checks passed. These results establish the stated component boundary only.
