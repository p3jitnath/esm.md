# Departure-Field Transport

LARCINB moves wind, temperature and other transported fields to their departure points. A departure point is the earlier position of air that reaches a grid cell during the next time step. The physics input is [Departure-Field Transport](../../../../../formulations/openifs/dynamics/departure_field_transport.md). This contract covers the frozen hydrostatic forecast route, where vertical pressure balance replaces a separate vertical acceleration equation. The original interfaces and selected child equations are retained.

## Ordered Calculation

Let $`H`$ be the high-order interpolated wind or temperature contribution, and let $`L`$ be its linear contribution. Both terms have the units of their supplied field. Wind has units of metres per second, temperature has units of kelvin, and water mixing ratios have units of kilograms per kilogram. Each selected return cell receives one separately rounded addition.

```math
F = \operatorname{FP64}(H + L).
```

The two wind fields also save H in PUFZ and PVFZ. If LD2TLFF1 is true, separate refined wind inputs supply these saved fields. With LRSLDDH enabled, the high-order result is added to the incoming transport diagnostic before the low-order result is added to the main field. With LRSIDDH enabled, a separate linear interpolation is added to the incoming linear diagnostic. Each diagnostic contribution uses one FP64 addition, with its own rounding point.

A transported constituent is a field such as humidity, cloud water or rain. Its LADV flag selects transport and its LMGRID flag identifies a separate grid that this caller leaves unchanged. MP_SL1 selects the source field. The selected LAITRE_GFL method calculates its return without an additional parent sum. The split-physics route uses MPSLP to select its linear source and return plane. It applies to every LADV and LPHY field, including a field marked LMGRID.

Finally, LAITLI calculates PCF and LAIDDI calculates PDP. Every interpolation equation, clipping rule and rounding point comes from the unchanged accepted child contract. The parent performs raw-word copies for saved fields and one FP64 addition for each contribution. It uses no fused multiply-add, reordered sum or numerical Fortran fallback.

## Original Interface

The application binary interface, or ABI, defines where a caller places each argument and which registers the routine must preserve. LARCINB has 39 ordinary pointer arguments and no hidden character length. AArch64 places arguments 0 to 7 in x0 to x7 and arguments 8 to 38 in 31 consecutive eight-byte stack slots. The parent uses a 2,048-byte stack frame, preserves x19 to x29 and the return address, and leaves platform register x18 unchanged. Its stack remains aligned to 16 bytes. FPCR must be zero, which selects the frozen floating-point mode. FPSR and errno must match the original return from the same entry state.

Let K be the column count, N the level count, and C = KN the number of cells in one physical field plane. Let D be the cell count in one diagnostic plane. The caller allocates D = C when LRDDHDYN is true and D = 1 when it is false. Columns vary fastest. Source storage has KASLB1 rows in each source plane, and NFLDSLB1 planes. Source blocks retain the original field and level order. Integer and logical values occupy four bytes. FP64 values and ordinary pointers occupy eight bytes.

| Argument | Original Name | Supplied Storage |
| --- | --- | --- |
| 0 | YDGEOMETRY | 17,096-byte geometry record |
| 1 | YDGMV | 1,560-byte field map |
| 2 | YDLDDH | 120-byte diagnostic switches |
| 3 | YDMDDH | 35,016-byte diagnostic map |
| 4 | YDML_GCONF | 1,556,112-byte configuration record, containing TYPE_GFLD |
| 5 | YDML_DYN | 13,232-byte dynamics record |
| 6 to 11 | KST, KPROF, KASLB1, KHVI, LDSLPHY, LD2TLFF1 | Six four-byte scalar owners |
| 12 and 13 | KL0, KLH0 | Four integer planes each, or 16C bytes |
| 14 and 15 | PLSCAW, PRSCAW | Complete declared FP64 coefficient planes |
| 16 | PB1 | 8 KASLB1 NFLDSLB1 bytes |
| 17 | KIBL | One four-byte scalar |
| 18 | KNOWENO | 4C bytes |

The return interface contains all 20 original array owners. Their complete allocated bytes are compared, including unused planes, inactive columns, signed zeros and NaN payloads. A physical plane is a complete K by N field. An inactive diagnostic plane can contain only one value. Both diagnostic write switches must be false for this compact allocation.

| Argument | Original Name | Complete Return Owner |
| --- | --- | --- |
| 19 | PGMVTNDSL | 8D (2 + NFTHER) bytes |
| 20 | PGFLTNDSL | 8D NUMFLDS bytes |
| 21 | PGMVTNDSI | 8D NDIMSIGMV bytes |
| 22 to 24 | PGMVF, PGMVF_SI, PGMVF_NL | 8C GMV.NDIM bytes each |
| 25 | PDP | 8C bytes |
| 26 | PGFLF | 8C NUMFLDS bytes |
| 27 to 29 | PCF, PCF_SI, PCF_NL | 8C bytes each |
| 30 and 31 | PUFZ, PVFZ | 8C bytes each |
| 32 to 34 | PUPF, PVPF, PTPF | 8C bytes each |
| 35 | PGFLPF | 8C NDIMSLP bytes |
| 36 to 38 | PDBBCF, PDPHIF, PGWSF | 8K bytes each |

Every selected coefficient window and source block must fit its complete declared owner. FP64 owners require eight-byte alignment and integer owners require four-byte alignment. A zero-sized unused owner may be absent. Every nonzero declared owner must be present. Selected return cells must be finite and every unused return bit must remain unchanged.

The geometry record supplies a 320-byte vertical-coordinate record when a selected GFL method needs it. Its coordinate array is read only for a conservative mode-2 calculation. That route requires a contiguous array with lower bound zero and at least N + 1 levels. The original forecast has an embedded KASLB1 scalar inside its dynamics owner. Verification preserves that address relationship. SUALDYN_DDH allocates one row and one level for each diagnostic plane when LRDDHDYN is false. CALL_SL supplies one block section through LAPINEB to LARCINB. The genuine first call therefore has separate 24-byte, 64-byte and 72-byte diagnostic owners, with both write switches disabled. The observer uses these actual extents and rejects contradictory write flags before either numerical call.

## Frozen Route

The supported parent route is hydrostatic and uses ordinary coordinates, NWLAG = NTLAG = NVLAG = 3 and RRINTOPT = 1. Nonhydrostatic, curved-coordinate, extra high-order, extra turbulence and predictor-corrector routes stop before return-owner writes. The consumed wind limiter is horizontal, the consumed temperature limiter is horizontal with WENO selected, and the pressure interpolation uses the original clipping route. Modified advection, horizontal diffusion, the heat vertical selector, split physics, refined saved winds and both diagnostic switches retain their supplied supported choices.

For active local constituent transport, the parent supports LIN, LIN(MAD) and the 16 already-qualified LAITRE_GFL selectors. An additional LTDIABLIN numerical stage and unqualified selectors stop before writes. Inactive or external-grid fields retain all original output bytes. Their unused selector strings and unused source-plane indices are not interpreted. The direct GMV and GFL interfaces remain complete, including the GFL child's exact hidden character length of 12 bytes.

New metadata offsets and owner extents were obtained from the frozen original modules. Existing geometry, coefficient and child-layout evidence was reused. The original TYPE_GFLD component stride is 368 bytes with 2,163 components. Its source map, split map, flags, name, selector and WENO exponent are taken from the supplied component rather than inferred from field order. The selected parent route uses interpolation weight set 1. KIBL identifies the geometry block and does not select an interpolation weight set.

## Verification And Limits

Original parent returns were collected before assembly emission. Independent child science is reused for every unchanged numerical route. A new higher-precision check verifies each parent addition with the budget $`4\epsilon(\lvert H\rvert+\lvert L\rvert)+4m`$, where epsilon is the FP64 machine epsilon and m is its smallest positive value. Diagnostic sums use their incoming value and complete added contribution in the same budget.

The live comparison checks consumed-input bounds and finite source values, all complete input and return owners, inactive bytes, FPCR, FPSR and errno on every call. Expanded independent child and parent science runs once for each new consumed branch and supported shape. A byte comparison accepts only zero differing bytes. Original controls run on alias-preserving shadows and supply no stage to the native calculation.

The primary numerical call targets are direct LAITRE_GMV, LAITRE_GFL, LAITLI and LAIDDI assembly. A single reusable FP64 plane holds the linear contribution. Its malloc and free calls manage storage and supply no calculation. The local parent library hides normal child aliases so the original comparison calls cannot enter its native children. Native parent and private-child getter changes are recorded around the primary call only.

Critical parent checks and genuine forecast-packet replay passed with zero differing return bytes. The forecast-packet checks cover 24 columns, 19 levels, eight constituent slots, six active local fields and the actual input address relationship. The corrected caller-buffer check covers compact diagnostics beside protected pages, full diagnostics with both write switches active and rejection of unsafe compact write flags. Earlier complete numerical proofs use an explicitly supplied full diagnostic corpus and remain valid for that corpus. Thirty focused rejection cases verify the new unsupported routes and invalid consumed maps before caller-owner writes. The complete routine also passes the normal combined forecast and saved-output gate recorded below. No whole-forecast independent physical proof or speed claim follows from this local checkpoint.

## Actual Forecast Acceptance

The combined coarse forecast uses exclusive allocation 7259755 on nid010824. These actual assembly calls have zero differing bytes. A compared array contains the complete storage supplied by its caller. Private child counts exclude original comparison calls.

| Original routine | Actual calls | Compared bytes | Scope |
| --- | ---: | ---: | --- |
| larcinb | 2,150 | 221,192,000 | Complete returned parent arrays |

All ten saved files match across 618,140 bytes. Accepted critical physics and interface checks are reused. Independent physics for the whole forecast, whole-process byte agreement, autonomous execution and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

## Complete Source Owner Capacity

Capacity revision 2 retains every floating-point instruction, interpolation index bound, field-selection check and child call. The complete PB1 owner can contain more than 2147483647 elements because its field bases and byte addresses use 64-bit integer products and sums. The positive signed 32-bit NAS and NFLDSLB1 inputs are multiplied in 64 bits. Their product must be at most 1152921504606846975 elements, so its eight-byte size is below the signed 64-bit limit. PB1 must be non-null and aligned to eight bytes, and adding its complete byte size to its base must produce no unsigned carry. These checks run before temporary allocation and every child call. Each individual interpolation index retains its signed 32-bit domain; each child retains its existing source-view checks and narrower supported range. The caller still supplies the complete mapped owner and disjoint returned storage.

The added qualification passes six LAPINEB source/native calls at 17 columns and 137 levels, using source leading dimensions 1744925 and 1783837 and 3892 source planes. The complete read-only sparse PB1 owners contain 54329984800 and 55541548832 bytes. Each plane has 4096 populated constructed columns. All 3257376 complete output and raw-status bytes agree, and 54020 independent physical relations pass per route. Null, misaligned and wrapping PB1 pointers refuse before a public write, leaving all 56727876 shared owner bytes unchanged. The previous provider and its accepted small-owner evidence remain retained; unchanged banks were not replayed. This extends the passed component scope and does not establish a loaded weather-state or forecast result.
