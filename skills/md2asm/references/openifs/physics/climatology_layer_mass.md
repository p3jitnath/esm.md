# Monthly Layer-Amount Contract

Revision 1 freezes the complete contained UPD_GHGCLIM::INTERP_GAS from [Monthly Gas Climatology](../../../../../formulations/openifs/physics/monthly_gas_climatology.md), MG-1 and MG-2. Native assembly performs every layer and latitude update.

## Ordered Calculation

FP64 stores a real number in sixty-four bits. RN means a separate operation rounded to nearest, with an even result at an exact halfway point. Require the Arm floating-point control register, FPCR, to equal zero. Preserve signed zeros and gradual underflow. Forbid fused, approximate, reassociated and reduced-precision arithmetic.

For each increasing layer, compute d=RN(p_bottom−p_top), then a=RN(d×s). For each increasing latitude, compute q=RN(v_month1−v_month2), q=RN(w×q), q=RN(v_month2+q) and G=RN(a×q). The separate rounded layer factor is shared across latitudes. Stored G is in pascals, and G/g is the physical mass per square metre.

## Interface And Bounds

The application binary interface, or ABI, defines argument addresses and preserved registers. Seven addresses enter x0 through x6, in the order month one, month two, weight, pressure descriptor, scaling, rank-three volume descriptor and rank-two returned-amount descriptor. Months are four-byte integers. Weight and scaling are eight-byte FP64 scalars. The original contained child reads its parent-owned IM1 and IM2, which equal the passed month values. A source-only bridge preserves those bindings for the independent child check, while the direct private interface passes their identical values explicitly.

A GNU descriptor records an array address and its shape. Its base address is at byte zero, and each dimension records stride, lower index and upper index at bytes forty, forty-eight and fifty-six, with twenty-four bytes between dimensions. Rank-one, rank-two and rank-three descriptors occupy sixty-four, eighty-eight and 112 bytes. The dummy pressure starts at zero, while dummy gas and output indices start at one. Address the first logical element from the descriptor base, using signed element strides. Actual lower bounds do not change the dummy index.

Let C be the output latitude count and L be the pressure upper index minus its lower index. Require 0≤C≤4096, 0≤L≤512, matching volume and output extents, twelve supplied months and 1≤month1,month2≤12. Support nonzero signed strides and gaps within complete supplied owners. Empty extents produce no writes. Consume only finite values, nondecreasing finite pressures, 0≤w≤1, finite nonnegative scaling and nonnegative volume fractions, with finite intermediates.

Inputs and outputs are disjoint and naturally aligned, and all address products fit their complete owner and signed sixty-four bits. Preserve x18, x19 through x30, the low halves of v8 through v15, FPCR and sixteen-byte stack alignment. Canonical bytes are the complete little-endian returned owner, including gaps. Require zero differences, protected bounds, unchanged inputs and descriptor bytes.

## Acceptance

Before assembly emission, the complete original child passed one hundred protected calls and 480,064 returned owner bytes against independent high-precision convex blends and pressure-integrated gas masses. The direct child passed the same cases with zero differing bytes. They cover both monthly endpoints, equal and wrapped month indices, empty extents, maximum shapes, positive and negative strides, gaps, zero pressure depth, signed zeros and subnormal concentrations. The complete parent binds this direct child and counts each execution.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| upd_ghgclim::interp_gas | 234 | 10,902,632 | Complete parent owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
