# Monthly Gas Parent Contract

Revision 1 freezes complete UPD_GHGCLIM from [Monthly Gas Climatology](../../../../../formulations/openifs/physics/monthly_gas_climatology.md), MG-1 and MG-2. The parent selects the two months and every configured gas, then binds the complete direct [layer-amount child](climatology_layer_mass.md). No verification driver supplies a numerical stage.

## Time And Gas Selection

Read day and month from the supplied positive YYYYMMDD integer. Set day to day−1. January uses RN(RN(day×1440)+minutes). February first maps day twenty-eight to twenty-seven, then uses RN(RN(44640+RN(day×1452.8571))+minutes). Other months use RN(RN(RN(previous_cumulative_day+day)×1440)+minutes), with cumulative days 31, 59.25, 90.25, 120.25, 151.25, 181.25, 212.25, 243.25, 273.25, 304.25, 334.25 and 365.25.

Take the nonnegative remainder modulo 525960 minutes. The monthly midpoint array is 22320, 64980, 107640, 151560, 195480, 239400, 283320, 327960, 371880, 415800, 459720 and 503640. At or before the first midpoint, select months twelve and one and RN(RN(22320−time)/44640). Beyond the last, use the same months and RN(RN(548280−time)/44640). Otherwise choose the unique interval with time>left and time≤right, and compute RN(RN(time−right)/RN(left−right)). Every operation rounds separately under the child FP64 contract.

The remainder uses a separately rounded division followed by integer truncation. Its integer quotient times 525960 is exact because the product is below 2^53. Subtract that product from the supplied FP64 time. For a positive quotient, the two values differ by less than a factor of two, so the subtraction is exact in FP64. A division rounded up at a period boundary can give a small negative remainder, which is corrected by adding one period. This corrected remainder is also representable exactly in the declared time range. A zero quotient leaves the original time unchanged. Protected comparisons include period ties, year wrapping and the largest supported minute count.

Use the [accepted radiation gas rules](radghg.md) in their original nine-species order. Divide each prescribed mass fraction by its supplied positive surface-mean volume fraction. Nitrogen dioxide instead uses RMNO2/RMD, and ozone uses RMO3/RMD. Perform each division once before its complete child call. KSTEP is unused, and KUPGHG stays unchanged.

## ABI And Storage

Six argument addresses enter x0 through x5, in the order TERAD, TERDI, date, minutes, unused KSTEP and unchanged KUPGHG. TERAD has 2040 bytes and gas code at byte 156. TERDI has 176 bytes and prescribed gas fractions at bytes sixteen, twenty-four, thirty-two, sixty-four, seventy-two, eighty and fifty-six for carbon dioxide, methane, nitrous oxide, CFC-11, CFC-12, HCFC-22 and carbon tetrachloride.

The global __yomclim_MOD_yghgclim points to the 1208-byte source object. Its nine rank-three descriptors start at bytes 128, 240, 352, 464, 576, 688, 800, 912 and 1024, in species order. Eight surface means start at 1136 with eight-byte spacing, with unused nitrogen dioxide at 1160. Pressure and latitude counts are at 1200 and 1204. The accepted global __yoeradghg_MOD_yradghg layout contains the pressure and nine returned descriptors, as recorded in radghg.md. Reuse those unchanged measured offsets.

Use valid Gregorian dates, 0≤minutes≤2147483647, finite nonnegative prescribed fractions, positive finite used means and molar masses, and the complete child domain. Every unselected owner stays unchanged. Source tables and all input objects stay unchanged. Canonical bytes contain the nine complete returned owners in species order followed by the unchanged four-byte KUPGHG. Preserve the Arm ABI and require zero differences before timing.

The complete original parent passed eighty protected calls and 723,632 returned owner bytes, with independent layer and column balances. The direct parent passed the same calls with zero differing bytes, including all species codes, monthly midpoint ties, year wrapping, February twenty-nine, the largest minute count, empty and maximum shapes, signed zeros and subnormal values. Four paired calls also pass. Its private complete child is counted at each actual execution. No speed improvement is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| upd_ghgclim | 26 | 10,902,632 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
