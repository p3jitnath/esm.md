# Greenhouse-Gas Parent Contract

The physical input is revision 1.0 of [greenhouse_gas_profiles.md](../../../../../formulations/openifs/physics/greenhouse_gas_profiles.md). The complete native parent chooses latitude weights and the configured gas species, then calls the direct [pressure interpolation child](greenhouse_gas_interpolation.md). No driver supplies a numerical stage.

## Latitude And Gas Selection

Read the supplied sine of latitude. Above the last table latitude, choose its last pair and weight one. Below the first, choose its first pair and positive-zero weight. Otherwise search pairs from north to south, accepting both endpoints. At an interior latitude tie, this selects the pair starting at that latitude. Compute weight as a separately rounded subtraction divided by the separately rounded latitude difference.

The INTEGER4 configuration code chooses species using the original rules. Each row is active when its code matches the single-species code or reaches the multiple-species threshold.

| Gas | Single code | Threshold |
| --- | ---: | ---: |
| Carbon dioxide | 1 | 10 |
| Methane | 2 | 11 |
| Nitrous oxide | 3 | 12 |
| Nitrogen dioxide | 4 | 20 |
| CFC-11 | 5 | 15 |
| CFC-12 | 6 | 16 |
| Ozone | 7 | 21 |
| HCFC-22 | 8 | 18 |
| Carbon tetrachloride | 9 | 19 |

Ozone is also active at code17. Visit the rows in this order, writing only active species and selected columns. Reuse the child's ordered accumulation and division. Require FPCR zero and the frozen nonfused FP64 contract.

## Arm Interface

`md2asm_openifs_radghg` receives eighteen address arguments. x0 is the 2040-byte radiation configuration, whose gas code is at byte156. x1 is the unused model configuration object. x2 and x3 address first and last INTEGER4 columns, x4 the full column count, x5 model layers, x6 the unused radiation-column count and x7 model pressure faces. The incoming stack contains the latitude-sine pointer followed by nine output pointers, in the table's species order, at eight-byte intervals. Unused x1 and x6 are not dereferenced.

The original global `__yoeradghg_MOD_yradghg` points to a928-byte climatology object. Its contiguous one-based latitude descriptor starts at byte0 and zero-based pressure descriptor at byte64. Rank-two amounts start at bytes128 for methane,216 for carbon dioxide,304 for nitrous oxide,392 for nitrogen dioxide,480 for CFC-11,568 for CFC-12,656 for carbon tetrachloride,744 for HCFC-22 and832 for ozone. Latitude and pressure counts are INTEGER4 at bytes920 and924. Descriptors, supplied tables and configuration remain unchanged.

Require at least two strictly increasing latitude points and a valid pressure profile under the child contract. Full column count is at most4096. Outputs are disjoint contiguous `KLON*KLEV` FP64 arrays with capacity for all columns, and pressure has `KLON*(KLEV+1)` cells. Latitude has KLON cells. Every reached pointer is naturally aligned and address products fit signed64 bits.

A fixed256-byte aligned frame preserves x19 through x30. Private latitude indices need `4*KLON` bytes and weights need `8*KLON` bytes, each rounded up to16, plus32 bytes for child stack arguments. The child supplies its own bounded accumulation buffer. The native parent leaves x18, preserved FP registers and FPCR unchanged. Empty selected columns or zero layers produce no output writes.

## Acceptance

Compare complete owners for all nine gases against the strict genuine parent, preserving untouched species, inactive columns, gaps, guards, inputs and global tables. Require zero differing bytes. Independent exact-rational latitude blends and column-integrated gas amounts check the physical equations with the child's declared forward rounding bound, including the separately rounded latitude weight.

The focused corpus covers all configured gas codes, exact and adjacent latitude ties, both polar caps, pressure boundaries, final-interval extrapolation, partial and empty columns, zero layers and sparse or very small amounts. Critical acceptance precedes a same-input paired forecast. No whole-forecast speed or independent whole-forecast physics is implied.

## Critical Results

The small strict original/native verifier passed 69 calls over 130,536 complete owner bytes, with zero differences and 9,966 independent profile relations. Inputs, descriptor bytes, inactive outputs and guards stayed unchanged. Immediate preserved-register and stack checks passed, and FPCR was zero. The emitted instructions contain no fused or approximate operations, no FPCR writes and no x18 use.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 6,400 genuine calls. The same-input comparison covers 70,041,600 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
