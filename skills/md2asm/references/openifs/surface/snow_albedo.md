# Snow Albedo Update

Revision 1.0 freezes the complete OpenIFS 48.1.1 `SRFSN_ASN_MOD::SRFSN_ASN` child from `surf/module/srfsn_asn_mod.F90`. The [physical input](../../../../../formulations/openifs/surface/snow_albedo.md) defines ageing and fresh snow. [Direct assembly](../../../../../src/openifs/surface/snow_albedo.S) implements every numerical stage.

## Ordered Arithmetic

Use FP64, the 64-bit floating-point format, with separate rounding to nearest and ties to even. FPCR is zero. Preserve signed zeros and gradual underflow. Fused operations, reassociation, approximate division and reduced precision are forbidden. Let `RN` mean one FP64 rounding.

A true no-snow mask copies the upper albedo limit exactly. Otherwise a positive melting indicator selects melting. Compute `RN(A-Amin)` and multiply it by the accepted scalar `EXP` of `RN(RN((-rf)*dt)/D)`, then add `Amin`. Ordinary ageing subtracts `RN(RN(ra*dt)/D)` from `A` and takes the maximum with `Amin`.

For either snow branch, multiply snowfall by the time step, take the maximum with zero, divide by ten and take the minimum with one. Subtract the aged value from `Amax`, multiply that difference by the snowfall weight and add it to the aged value. Take the maximum with `Amin`, then the minimum with `Amax`. Preserve these intermediate rounding points. Scalar `EXP` reuses the qualified non-fused pressure-math route and its accepted accuracy record. No new helper audit is needed.

The time step and rates are finite and nonnegative, the day length is finite and positive, and all used intermediate products and quotients are finite. Used albedo inputs and snowfall rates are finite. The previous albedo lies between zero and one. Configuration limits satisfy `0<=Amin<=Amax<=1`. The melting indicator is finite and can have either sign. Unused temperature inputs are not read. In no-snow columns the other column inputs are not read.

## ABI and Storage

The application binary interface, ABI, defines argument addresses and preserved registers. `md2asm_snow_albedo` receives twelve addresses in original order. Arguments 1–4 are four-byte `KIDIA`, `KFDIA`, `KLON` and an eight-byte time step. Arguments 5–9 are descriptors for the no-snow mask, previous albedo, melting indicator, temperature and snowfall. Arguments 10–11 point to `TSOIL` and `TCST` configuration objects. Argument 12 is the albedo output descriptor. The public alias is `__srfsn_asn_mod_MOD_srfsn_asn`.

`KLON` is between zero and 4096. The processed range is inclusive and lies within its columns, or is empty with `KFDIA=KIDIA-1`. Rank-one GNU descriptors occupy 64 bytes, with base at byte 0, element size at byte 16, span at byte 32, stride at byte 40 and lower and upper bounds at bytes 48 and 56. The mask uses four-byte logical elements and other used arrays use eight-byte real elements. Each array has its own signed element stride. Zero stride metadata selects one, matching the original interface. Every used descriptor has at least `KLON` logical elements. The first logical element is at the base address. Descriptor, real and configuration addresses are aligned to eight bytes and integer and logical addresses to four bytes. Owners are disjoint and address offsets fit their integer widths.

The frozen GNU `TSOIL` object occupies 2416 bytes. Its upper albedo limit, lower limit, ordinary ageing rate and melting rate are at byte offsets 336, 320, 376 and 368. The `TCST` object occupies 128 bytes and its day length is at byte 16. The temperature argument is unused. Count, descriptors, configuration and input owners remain unchanged. Only output elements within the processed range change, preserving inactive tails and physical gaps.

The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and does not use `x18`. The fixed stack frame occupies 192 bytes. Each constant ageing decrement and melting factor is computed when its branch is first used and is then reused. This retains the same ordered rounded values while avoiding reads of unused branch data.

## Independent Checks and Acceptance

Before native emission, compare the original with an independent high-precision ageing law and the convex mixture `(1-w)*B+w*Amax`. A convex mixture is a weighted average with weights that add to one. The frozen physical bound is `2048*epsilon` times the input and ageing condition size, plus 2048 smallest positive FP64 subnormals, where `epsilon=2^-52`. Check albedo bounds, no-snow copies, empty ranges, melting, ordinary ageing, snowfall thresholds, signed strides and protected input and output owners. Poison the unused temperature address and unused no-snow values.

Compare every complete output owner byte with the original, including inactive elements and gaps. A register observer checks the native ABI and FPCR. Canonical output is the processed FP64 albedo sequence in increasing column order and little-endian encoding. Zero differing bytes is the exact acceptance limit. A paired actual-call relay must pass before forecast acceptance. Whole-forecast completion and speed remain unproved.

## Checked Checkpoint

On 2026-10-11, exclusive job 7240564 on nid010555, CPU 48 with local memory binding passed 1,152 protected native cases over 619,008 complete owner bytes with zero differences. The original passed 64,032 independent physical relations before native emission. The corpus includes 5,088 no-snow columns, 9,696 melting columns and 19,776 ordinary-ageing columns. The native register observer and FPCR checks passed. Its sole external numerical call uses the accepted non-fused EXP route. A smaller paired smoke passed 80 intercepted calls over 6,976 owner bytes and 176 independent relations with zero differences. Comparative timing remains open.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_asn_mod::srfsn_asn | 2,150 | 412,800 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
