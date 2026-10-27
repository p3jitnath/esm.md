# Runtime Radiation Interpolation

Radiation uses its own grid. These two assembly entries prepare interpolation weights and use them to transfer a field between grid locations. Interpolation estimates a value from nearby known values. The entries preserve the original `RDSCAW` twelve-point branch and `LAIDDI_RAD` calculations from `arpifs/interpol/`.

## Coordinate Weights

[`md2asm_runtime_radiation_coordinate_weights`](../../../../../src/openifs/radiation/runtime_radiation_coordinate_weights.S) retains the original 19 by-address arguments. Registers x0 to x7 carry `YDSL`, `KPROMB`, `KSTART`, `KPROF`, `KSTABUF`, `KWIS`, `KFRSTLOFF` and `P4JP`. Successive incoming stack slots carry `PIS2`, `PLSDEPI`, `PLATI`, `PIPI`, `PLON`, `PLAT`, `PDLAT`, `PCLA`, `PDLO`, `PCLO` and `KL0`.

The grid record `YDSL` supplies the source interpolation rows and index tables. `KPROMB` is the complete output pitch, from 1 to 32,769 points. The selected points run from `KSTART` to `KPROF`, with both endpoints included. The interpolation selector `KWIS` must be 203. `KFRSTLOFF` is the source latitude offset. `P4JP` estimates inverse latitude spacing and `PIS2` is half of pi. Coordinates are in radians.

| Buffer | Meaning and extent |
| --- | --- |
| `KSTABUF` | Source row offsets across the declared halo latitude range |
| `PLSDEPI`, `PLATI`, `PIPI` | Longitude scale, latitude and three latitude-coefficient planes |
| `PLON`, `PLAT` | Coordinates through the consumed point `KPROF` |
| `PDLAT` | One distance per point |
| `PCLA`, `PDLO`, `PCLO`, `KL0` | Three latitude weights, four longitude distances, six longitude weights and four western indices per complete output pitch |

The typed halo bounds are `NDGSAH` and `NDGENH` at record offsets 1,672 and 1,676. They are distinct from the global grid bounds. Their row count is from 1 to 131,072. The owning parent supplies a mapped record of at least 1,800 bytes, its genuine `NSLEXT` index descriptor and every consumed table element. Integer arrays need four-byte alignment and FP64 arrays need eight-byte alignment. Buffers are disjoint and their complete declared spans must not wrap around the address space.

The calculation retains the source coordinate-to-row conversion, ties-away integer rounding and separate FP64 products and additions. Selected coordinate values must be finite, select valid table entries and give nonzero source denominators. The source on-demand branch writes the same sixteen mask cells for each point. Its genuine mask covers the source local buffer and up to six extra stencil cells. Other points and all unused output padding remain unchanged.

Metadata refusals return two before output writes. Invalid coordinate-derived indices can leave an earlier completed point prefix, so the caller must satisfy the coordinate prerequisites. Successful calls return zero. The 896-byte private frame is aligned to 16 bytes. The entry allocates no memory, calls no service, preserves x18 and all Arm saved registers, and requires unchanged FPCR zero. FPSR follows the source arithmetic and errno is unchanged.

## Twelve-Point Field Interpolation

[`md2asm_runtime_radiation_twelve_point_interpolation`](../../../../../src/openifs/radiation/runtime_radiation_twelve_point_interpolation.S) takes eight addresses in x0 to x7, in the order `KPROMA`, `KFIELDS`, `PCLA`, `PDLO`, `PCLO`, `KL0`, `PRE` and `POST`. `KPROMA` is the source point count from 1 to 268,435,456. `KFIELDS` is the field count from 0 to 16,384. `PRE` has shape `(KPROMA, KFIELDS)` and `POST` has one value per field. Counts and indices are signed 32-bit integers. Values and weights are FP64.

The sixteen-word `KL0` table describes a four-by-four neighbourhood. Only twelve entries are consumed because the four outer corners are unused. Each consumed index is from 1 to `KPROMA`. The unused corners remain opaque and may be zero. The caller provides complete nonoverlapping mapped arrays within its memory budget.

For each field, the calculation first obtains four longitude estimates $`Z_0`$ to $`Z_3`$. It uses linear interpolation on the two outer rows and cubic interpolation on the two inner rows. With latitude weights $`a_1`$, $`a_2`$ and $`a_3`$ from `PCLA`, the final value is

```math
u = Z_0 + a_1(Z_1-Z_0) + a_2(Z_2-Z_0) + a_3(Z_3-Z_0).
```

Each subtraction, multiplication and addition remains a separate FP64 operation in source order. The complete output contains exactly `KFIELDS` values. A zero field count returns zero before payload reads. Bounds or overlap refusals return two before output writes. The entry uses a 256-byte frame aligned to 16 bytes, no heap or service call, preserves x18 and all Arm saved registers, and retains source FPSR and errno with unchanged FPCR zero.

## Accepted Checks and Limits

The joint check passes 40 calls across four shapes with zero differences in 11,096 complete output bytes. Checks include partial point ranges and full-pitch padding, source mask writes, four constant-field preservation cases, empty fields, eight prewrite refusals, buffer guards and immediate machine state. The original Fortran control uses the same typed halo bounds and an explicitly matched profiling setting. Local records retain the exact source revisions, build commands and checks.

These entries are accepted components. The live radiation communication, aerosol calculation, owning radiation parent, complete weather step and operational forecast remain separate integration requirements.
