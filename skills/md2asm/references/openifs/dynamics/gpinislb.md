# GPINISLB Solver Contract

[Physics input](../../../../../formulations/openifs/dynamics/work_buffer_initialisation.md), revision 1. This contract covers the complete `arpifs/adiab/gpinislb.F90` body. Reuse accepted [GPRCP](gprcp.md) field metadata and GNU storage, adding only newly consumed members.

## Complete Update

Use FP64, round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Multiplication rounds once. A copy preserves every bit. Explicit zero writes positive zero. Keep contraction, fusion, reassociation and fast-math disabled. No language helper supplies a numerical stage.

Write the U, V and T work fields as zero in the semi-Lagrangian branch. In the Eulerian branch, multiply their previous values by `PTE` at iteration zero and clear them at later iterations. Apply the same rule to pressure/divergence fields when nonhydrostatic dynamics is enabled, and to the extra NHX field when its flag is also enabled. Other NH outputs remain untouched.

For each active water species, copy its `MP` field when semi-Lagrangian two-time-level transport is enabled and its `MP9` field otherwise. An inactive species receives positive zero. Preserve the liquid, ice, rain and snow selections separately.

Visit each component in increasing original order. In the semi-Lagrangian branch, clear an advected component's `MP1` work field. Otherwise multiply its selected `MP` or `MP9` input by `PTE` only when `LT1` is true. In the Eulerian branch, only `LT1` components are written, using `MP9 * PTE` at iteration zero and zero later. Preserve untouched tracer fields.

Apply the U/V/T branch rule to the surface-pressure work field. When `LDTL` is false, write `PVVEL0 * PZPRE0F` into the selected PB2 vertical-velocity slots. When it is true, leave those slots unchanged.

Copy wave fields only when `NOT LDTL AND LNHDYN AND LGWADV AND LVERTFE AND LVFE_GW AND LSLAG`. Choose the three time-zero optional inputs when `LTWOTL` is true and the three earlier-time inputs otherwise. Copy full-level wave and wave-divergence fields to their selected PB2 slots, followed by the surface wave field. Required selected optional inputs must be present. Unused optionals may be absent. No setup stage is omitted.

## Interface and Bounds

There are thirty-eight ordinary addresses. In order they are `YDGEOMETRY, YGFL, YDDYN, YDDYNA, YDPTRSLB2, KST, KEN, PTE, LDTL, PGFL, PUT9, PVT9, PTT9, PSPDT9, PSVDT9, PNHX9, PSPT9, PVVEL0, PZPRE0F, PB2U1, PB2V1, PB2T1, PGFLT1, PB2PD1, PB2VD1, PGMVNHX1, PB2SP1, PB2, PQICE, PQLI, PQRAIN, PQSNOW, PGWFT0, PGDW0, PGWS0, PGWFT9, PGDW9, PGWS9`. The first eight use `x0` to `x7`, and the remaining thirty use eight-byte entry-stack slots. The default entry is `gpinislb_`.

Let `K` be the column pitch, `N` the level count, `D` the main tracer capacity, `D1` the new tracer capacity, `F` the component count and `B` the PB2 field capacity. Use `0 <= K <= 4096`, `1 <= N <= 1024`, `0 <= F <= 2163`, and positive capacities that cover every used field. The inclusive work range obeys `1 <= KST <= K+1` and `0 <= KEN <= K`, including empty work. Level arrays own `8*K*N` bytes. Surface arrays own `8*K` bytes. PGFL owns `8*K*N*D`, PGFLT1 owns `8*K*N*D1`, and PB2 owns `8*K*B`. Column one comes first, then increasing level, then field. Integers and logical values use four aligned bytes. Reals and addresses use eight aligned bytes. Output bytes are little-endian.

All output numerical views must be separate from complete inputs and metadata. An output may be a view entirely inside the complete PB2 owner, or may be a disjoint returned field view in another caller buffer. Compare each complete declared returned view and all PB2 bytes. GPINISLB does not receive the capacity of an enclosing PGMVT1 buffer, so fields outside all returned views are outside its capture boundary. Preserve that topology in the original comparison clones. Written PB2 slots and standalone work views must obey their declared disjoint field layout. Preserve every complete capture owner, including padding, inactive columns and untouched fields. Do not clone aliased views as unrelated arrays.

Reuse the accepted 17,096-byte GEOMETRY, 4,720-byte TDYN and 1,359,136-byte TYPE_GFLD. Geometry stores `NPROMA` at 5,144, `NPROMNH` at 5,156 and `NFLEVG` at 5,224. Its TCVER pointer is at 3,264, and the complete 216-byte TCVER remains read-only. TCVER `LVERTFE` is at 52 and `LVFE_GW` at 96. TDYN `NCURRENT_ITER` is at 2,580.

TDYNA is 456 bytes, with `LNHDYN, LTWOTL, LSLAG, LNHX, LGWADV` at 8, 20, 24, 40 and 48. TPTRSLB2 is 160 bytes, with `NFLDSLB2, MSLB2VVEL, MSLB2GWF, MSLB2GDW, MSLB2GWS` at 0, 40, 124, 128 and 132. Every used slot range must fit PB2.

The accepted GFL component array begins at 3,848 with 368 bytes per component. `NUMFLDS, NDIM, NDIM1` are at 0, 48 and 64. Each component has `LADV, LACTIVE, LT1, MP, MP9, MP1` at 20, 64, 92, 168, 180 and 188. The ice, liquid, rain and snow pointer slots are 799,848, 799,856, 799,920 and 799,912. They point to complete components in the fixed component array. Used MP/MP9 indices fit D, and used MP1 indices fit D1. Preserve every complete metadata owner and all unused bits.

Keep `x19` to `x29`, the link register and the required low 64 bits of `v8` to `v15` unchanged. Use a sixteen-byte aligned stack. The numerical body may use its own direct assembly loop for copy, zero and ordered multiplication, with no external numerical call.

## Critical Acceptance

Use `PTE` zero or one, nonnegative iteration indices and valid logical values zero or one. Consumed arithmetic inputs and outputs are finite. The nonlinear pressure input is positive. Selected water mass fractions are nonnegative, and their sum is no greater than one. A copied general tracer retains its units. Fields cleared without reading may contain arbitrary unused bits.

Before assembly generation, verify the genuine original using independent field-selection relations, exact rational scaled-field and pressure-velocity relations with the accepted actual rounding-error enclosure, phase-mass admissibility and complete parent bytes. Include all transport, time-level, iteration, nonhydrostatic and tangent-linear branches, both optional-wave epochs, each water-species activation, all component write modes, zero and 4,096 columns, one and 1,024 levels, partial/empty ranges, signed zeros, subnormals, unused NaN payloads, absent unused optionals and shared PB2 views.

Then reuse that same corpus with protected owner bounds and preserved-register probes. Require zero differing complete owner bytes and unchanged complete inputs and metadata, with FPCR zero. The paired actual-call relay preserves complete PB2 aliases, runs the genuine original on clones and returns direct assembly bytes after comparing every complete output owner. Add it to a combined forecast gate before claiming accepted forecast coverage. No comparative timing is claimed.

The CPG_GP caller supplies full-level optional wave arrays with actual NPROMNH capacity. Its hydrostatic branch has NPROMNH zero, although the GPINISLB dummy declares NPROMA. Capture the actual `8*NPROMNH*N` bytes for those optional full-level views, preserving presence separately from extent. A consumed wave branch requires NPROMNH equal to K. The surface wave views have K values. Unused null SC2PRG views have zero extent, while each present ordinary array retains its complete declared owner. No source numerical operation is changed by this capacity correction.

Original physics passed 50 cases, 1,317,272 complete owner bytes and 159,315 independent physical relations. Native verification passed 100 protected calls, 2,634,544 bytes and 318,630 relations, including 126 nonzero subnormal results. The paired smoke passed 50 calls and 1,317,272 bytes. All required bytes agreed, complete inputs and metadata stayed unchanged, the ABI was preserved and FPCR was zero. The focused caller-capacity case reused the accepted base proof and changed no assembly instruction. Actual combined-

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| gpinislb | 2,150 | 165,532,800 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
