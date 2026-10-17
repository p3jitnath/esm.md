# LAITRIQM3D Transport Contract

Revision 2 implements the complete OpenIFS 48.1.1 LAITRIQM3D routine from the [physics note](../../../../../formulations/openifs/dynamics/bounded_three_dimensional_transport.md), revision 1.0. The [direct body](../../../../../src/openifs/dynamics/laitriqm3d.S) contains every interpolation and limiting stage. No numerical child or driver supplies a missing calculation.

## Method And Ordered Arithmetic

FP64 stores a real value in 64 bits. RN means one separate operation rounded to the nearest FP64 value, with an even result at an exact halfway point. Require FPCR, the Arm floating-point control register, to equal zero. Preserve gradual underflow and signed zeros, with no fused arithmetic, reassociation, approximate division or reduced precision.

Let S be KSLB1, P be KPROMA, H be KFLEV and F be KFLDX−KFLDN+1. The source vector PXSL has S×F elements. Each selected output point has four supplied western indices KL0 for the four latitude rows, and four source planes separated by S elements. Use the exact source indices KL0[row]+vS+j, in Fortran's one-based numbering. The complete stencil uses (v,j) = (0,1),(0,2),(3,1),(3,2) on the inner latitude rows, linear pairs at v=1,2 on the outer rows, and four longitude points j=0,1,2,3 at v=1,2 on the inner rows.

The interpolation weights and parcel-position fractions have no units. A linear estimate uses L(a,b,f) = RN(a+RN(f×RN(b−a))). A cubic estimate with three supplied weights uses C(a,b,c,d,w₁,w₂,w₃) = RN(RN(RN(a+RN(w₁×RN(b−a)))+RN(w₂×RN(c−a)))+RN(w₃×RN(d−a))). Preserve this left-to-right sum and each stored source value.

Compute the twelve original longitude estimates first. The outer vertical planes have two linear inner-row estimates. The inner vertical planes have two linear outer-row estimates and two cubic inner-row estimates. Use PCLA to combine their four latitude rows into two cubic inner-plane estimates, and PDLAT to combine the outer planes' two inner rows linearly. Use PVINTW to combine all four resulting vertical values cubically.

KQM zero returns this original estimate. KQM one replaces an estimate strictly outside the eight inner corners' minimum and maximum with longitude, latitude and vertical linear estimates using PDLO, PDLAT and PDVER. KQM two clamps the original estimate to these same bounds. Preserve the original numeric minimum and maximum semantics and equality rules.

When LDQM3DCONS is true and KQM is two, initialise one private surplus per column to positive zero. At each layer, add that surplus to the original estimate and clamp the sum. Form upper excess RN(MAX(sum,max)−max) and lower excess RN(MIN(sum,min)−min). Select upper excess when its absolute value is greater than or equal to the lower excess's absolute value, then multiply it by the current layer ratio. The first ratio is one, and later ratios are RN(RN(VETAH[j]−VETAH[j−1])/RN(VETAH[j−1]−VETAH[j−2])). This is the source's local vertical correction, with no independent claim of exact global conservation.

## Nineteen-Address ABI And Storage

The application binary interface, or ABI, defines argument addresses and preserved registers. x0 through x7 hold the first eight addresses in the following table. Incoming stack bytes zero through eighty hold the remaining eleven addresses. The default direct entry is md2asm_laitriqm3d, with no scalar return. The original entry is laitriqm3d_ at offset 0x3e60a0.

| Position | Argument | Owner |
| ---: | --- | --- |
| 1 | YDVETA | 320-byte TVETA input |
| 2 | LDQM3DCONS | One LOGICAL4 input |
| 3 | KSLB1 | One INTEGER4 input |
| 4 | KPROMA | One INTEGER4 input |
| 5 | KST | One INTEGER4 input |
| 6 | KPROF | One INTEGER4 input |
| 7 | KFLEV | One INTEGER4 input |
| 8 | KFLDN | One INTEGER4 input |
| 9 | KFLDX | One INTEGER4 input |
| 10 | KQM | One INTEGER4 input |
| 11 | PDLAT | P×H FP64 input |
| 12 | PCLA | P×H×3 FP64 input |
| 13 | PDLO | P×H×4 FP64 input |
| 14 | PCLO | P×H×3×2 FP64 input |
| 15 | KL0 | P×H×4 INTEGER4 input |
| 16 | PVINTW | P×H×3 FP64 input |
| 17 | PDVER | P×H FP64 input |
| 18 | PXSL | S×F FP64 input |
| 19 | PXF | P×H FP64 output |

Matrices store contiguous P columns followed by H layers. Weight planes follow complete P×H matrices. PCLO has three longitude weights followed by the two inner latitude rows. PDLO and KL0 have four latitude planes. FP64 addresses align to eight bytes and INTEGER4 addresses to four bytes. The complete output owner is P×H FP64 values, including unchanged inactive columns.

TVETA reuses its accepted 320-byte GNU layout with five 64-byte allocated-array descriptors. Its first descriptor is VETAH. In that descriptor, the data pointer is at zero, span at thirty-two, stride at forty, lower bound at forty-eight and upper bound at fifty-six. The vertical-correction path requires a contiguous FP64 VETAH array with lower bound zero and at least H+1 values. Other paths do not read that array.

Inputs are read-only and disjoint from output. Preserve x18, x19 through x30 and the low halves of v8 through v15. Keep the stack aligned to sixteen bytes. A private surplus buffer holds P FP64 values only when the vertical correction is selected. Allocation and release supply storage, with no numerical calculation.

For each active cell, keep the four signed KL0 row indices in x12 through x15 after their first original reads. A later stencil read reuses the saved integer index, then applies the same vertical and longitude offsets. This replaces twenty-eight repeated index reads without moving the first read, any floating-point operation or an input check. Each row's saved value is replaced on its first use in every active cell. The inputs stay read-only until these values are no longer needed, and there is no child call inside this interval. The nineteen-address interface, 640-byte stack frame and vertical surplus recurrence stay unchanged.

## Supported Inputs And Acceptance

Support 1 ≤ P ≤ 4096, 0 ≤ H ≤ 512, 1 ≤ KST ≤ P and KST−1 ≤ KPROF ≤ P. KQM is zero, one or two. The empty interval and zero layers write no output. Every active source stencil address must lie within S×F, with finite field values and weights. Position fractions lie in [0,1], layer coordinates increase strictly, and all intermediates stay finite. Unused input and output cells may hold arbitrary bits.

Before emission, check the original against constant and affine parcel fields, positivity and nearby bounds for both limiting rules. Check every selected source address and the vertical-correction branch with unequal layer widths. These physical checks use geometric expected values and high-precision bounds, rather than another ordered solver.

Compare complete original and assembly output owners with zero differing bytes. Include all limiter modes, vertical correction, changed starting columns, odd and capacity shapes, sharp fields, signed zeros, subnormal values, both protected placements and read-only inputs. Check the immediate nineteen-address ABI and FPCR, then actual forecast calls and the ten saved files.

The physical and numerical contract was frozen before emission. The original passed fifty protected placements and 220,864 independent relations before generation. The direct assembly then matched all 167,424 complete output bytes across the same placements, with zero differences and 441,728 checked relations. Both protected placements, all read-only inputs, inactive output cells, the nineteen-address ABI and FPCR passed. Cases cover all four mode paths, constant and affine fields, sharp fields, signed zeros, subnormal values, empty ranges, odd shapes and the declared capacity limits.

The paired adapter passed twenty calls across all four mode paths, with zero differences in 5,600 complete output-owner bytes and 875 independent relations. It preserves 1,600 inactive output bytes. The five vertical-correction calls use unequal layer widths. These adapter checks establish byte agreement.

The integer-index reuse passed sixty-two protected placements and 222 paired calls against the accepted direct body, with zero differences across 215,584 complete output-owner bytes. It also passed 223,964 independent physical relations, the nineteen-address ABI, nine inherited floating-point status patterns, immediate FPCR and errno, read-only owner checks and adjacent-byte guards. The added cases include valid negative row indices and a stencil at the last valid source-owner element. No floating-point instruction or mathematical rule changes.

The integer-index revision also passes the complete autonomous forecast comparison in a joint batch with reflection scheduling. All 685 numerical owners, 560 descriptor relations and 27,486,113 raw bytes match, as do ten saved files across 618,140 bytes and 59 controlled final views. The ABI mask is zero, and natural FPCR/FPSR/errno are 0/25/0. Known optional-argument and entry-status differences remain visible, so this does not claim whole-process byte identity. All six ordinary matched processes also reproduce the ten files and 59 observed final views. The [README](../../../../../README.md) reports the combined timing result; it does not assign the gain to this routine alone.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| laitriqm3d | 10,750 | 39,216,000 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Full water and heat budgets and whole-process byte identity remain outside these checks, as stated in the [coverage record](../../../../../src/openifs/README.md).
