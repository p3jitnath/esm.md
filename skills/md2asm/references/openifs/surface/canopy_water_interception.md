# Canopy Water Interception Contract

Revision 1 freezes complete SRFWL from [Canopy Water Interception](../../../../../formulations/openifs/surface/canopy_water_interception.md), CW-1 and CW-2. It includes the initial storage correction, wet-canopy evaporation, dew, both rain sources, the accumulated surface exchange and optional diagnostics.

## Interface

The AArch64 entry is $`md2asm_canopy_water_interception`$, with GNU alias $`__srfwl_mod_MOD_srfwl`$. All 22 arguments are addresses.

| Position | Meaning | Data |
|---|---|---|
| 1–4 | First and last column, surface type count, time | INT32, INT32, INT32 and FP64 scalars |
| 5–8 | Previous storage, low vegetation cover, high vegetation cover, capacity | Read-only FP64 column arrays |
| 9–10 | Surface type fractions and moisture fluxes | Read-only FP64 column-by-type arrays |
| 11–13 | Convective rain, large-scale rain, forest snow evaporation | Read-only FP64 column arrays |
| 14–17 | Canopy storage, accumulated surface exchange, convective and large-scale rain passed through | Returned FP64 column arrays |
| 18 | Canopy moisture flux per surface type | Returned FP64 column-by-type array |
| 19 | Land mask | Read-only INT32 logical column array |
| 20–21 | Soil and vegetation settings | Read-only GNU TSOIL and TVEG objects |
| 22 | Interception diagnostics | Returned FP64 column-by-channel array, optional through zero size |

The first eight arguments use x0 to x7, and the other fourteen use successive eight-byte stack slots. Preserve x19 to x29, the lower halves of v8 to v15, FPCR and 16-byte stack alignment. Do not use x18.

GNU assumed-shape descriptors have 40 common bytes and 24 bytes per dimension. Their data pointer is at byte 0, first stride at byte 40 and first bounds at bytes 48 and 56. A zero first stride means one element. Use each owner's independent signed strides and the first logical data cell without applying its offset twice. INT32 cells use four bytes and FP64 cells use eight. All scalar and FP64 addresses meet natural alignment.

Support 8 to 16 surface types, up to 4096 active columns and empty intervals. Every input and output contains the complete active extent, and owners do not overlap. A nonempty diagnostic has at least four channels. A zero-size diagnostic has no readable data owner requirement. Soil settings have 2416 bytes, with RPSFR at 200 and LEWBSOILFIX at 2392. Vegetation settings have 776 bytes, with RVINTER at 552. RPSFR is at least one, and RVINTER lies from zero to one. Input arrays contain finite values, positive canopy capacities, nonnegative rain and surface fractions from zero to one.

## Ordered Arithmetic

Use ordered FP64 operations, FPCR 0 and no contraction or approximation. Let $`\tau=10\,\mathrm{tiny}`$, where $`\mathrm{tiny}`$ is the smallest positive normal FP64 number. Form $`b=1/\Delta t`$ and $`s=1/\mathrm{RPSFR}`$ separately. Return positive zero in every active per-type canopy flux before applying its updates.

For land, first set storage to $`\max(0,\min(C-\tau,W_{\mathrm{old}}))`$ and add $`(W-W_{\mathrm{old}})b`$ to type 3 flux. When LEWBSOILFIX is false, restore $`W_{\mathrm{old}}`$ before evaporation, retaining the already recorded correction. For negative type 3 moisture flux, form $`(\Delta t f_3)E_3`$, add it to storage, limit the result from below by zero, and add the actual storage change times $`b`$ to type 3 flux.

Visit surface types in increasing order. Types 3, 4, 6, 7, 8 and 10 can collect dew. For type 7, subtract forest snow evaporation before multiplying by its surface fraction. For the other types, multiply the fraction by its moisture flux directly. If this liquid flux is positive, add $`\min((C-\tau)-W,\Delta t F)`$ to storage, then add its actual change times $`b`$ to that type's canopy flux.

Before rain, add $`(W-W_{\mathrm{old}})b`$ to the supplied accumulated exchange. For each rain source, use the strict threshold $`P>\tau`$. Large-scale rain forms $`((P(v_l+v_h))a)`$, then $`\Delta t`$ times this result. Limit the stored mass by $`(C-\tau)-W`$, add it to storage and subtract stored mass times $`b`$ from throughfall. Convective rain first forms $`P\,\mathrm{RPSFR}`$, follows the same products and minimum, then multiplies the stored mass by $`s`$ before applying its two outputs. Rain at or below the threshold produces zero throughfall in land columns and no stored rain mass.

Sea columns return positive-zero storage and exchange, unchanged convective and large-scale rain, and zero per-type canopy fluxes. Diagnostic channels 1 to 3 contain previous storage, large-scale interception and convective interception. Channel 4 sums canopy fluxes for types 3, 4, 6, 7 and 8 in that order. The original diagnostic excludes urban type 10, so its scope is the five listed types.

## Independent Acceptance

The extended-precision canopy balance checks total moisture stored across all types and both rain sources. The legacy initial restoration is a separate term, rather than hidden as water conservation. The exchange balance excludes the subsequent rain. Record rainfall discarded by the tiny-rate branch and verify both rain sources, sea transmission, fixed capacity bounds and the declared diagnostic scope.

Freeze a physical rounding budget of $`32768\epsilon`$ times the absolute storage and integrated flux scale plus $`4096`$ times the least positive FP64 value. Use this budget only to test physical balances. The exact output limit is zero differing bytes across all six complete returned owners, including unprocessed cells, storage gaps, unused surface types and diagnostic channels.

Protect immutable inputs and descriptors, use guard pages at both ends, and cover empty intervals, sea columns, 8, 10 and 16 types, both initial-repair settings, wet evaporation, dew, urban dew, both rain branches, threshold neighbours, signed zeros, subnormals and independent positive and negative strides. A paired actual-call adapter must execute the complete direct body before the routine enters the accepted weather count.

## Completed Checks

| Check | Calls | Complete output bytes | Independent relations | Differing bytes |
|---|---:|---:|---:|---:|
| Strict original physical balances | 964 | 24,372,704 | 1,121,680 | — |
| Protected direct assembly and ABI | 964 | 24,372,704 | 1,121,680 | 0 |
| Paired actual entry smoke | 108 | 173,568 | 8,420 | 0 |

The verifier includes 4096-column cases and preserves 12,939,488 bytes outside the declared output cells. The direct body uses a 448-byte fixed frame and no dynamic workspace. It keeps the separately rounded storage value in a register between ordered stages for each independent column. These checks establish output agreement and the declared water balances. No timing improvement has been measured for this routine.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwl_mod::srfwl | 2,150 | 7,017,600 | Complete parent owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
