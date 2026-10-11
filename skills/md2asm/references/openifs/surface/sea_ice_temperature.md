# Sea Ice Temperature Contract

Revision 1 freezes complete SRFI from [Sea Ice Temperature](../../../../../formulations/openifs/surface/sea_ice_temperature.md), IT-1 and IT-2. A weighted implicit update uses the new temperature in the heat-transfer equations. The accepted [soil column diffusion body](soil_column_diffusion.md) supplies the complete tridiagonal solve, and this parent supplies every coefficient, boundary, diagnostic and final temperature.

## Interface

The AArch64 entry is $`md2asm_sea_ice_temperature`$, with GNU alias $`__srfi_mod_MOD_srfi`$. Eighteen addresses follow the original order.

| Position | Meaning | Data |
|---|---|---|
| 1–6 | First and last column, column count, ice layer count, diagnostic layer count, time | Five INT32 scalars and one FP64 scalar |
| 7–10 | Previous ice temperatures, surface fractions, sensible heat and moisture flux | Read-only FP64 column-by-layer or column-by-type arrays |
| 11–12 | Net longwave and per-type shortwave radiation | Read-only FP64 column array and column-by-type array |
| 13–14 | Ice mask and northern hemisphere mask | Read-only INT32 logical column arrays |
| 15–16 | Physical constants and soil settings | Read-only GNU TCST and TSOIL objects |
| 17–18 | New ice temperatures and optional diagnostics | Returned FP64 column-by-layer and column-by-layer-by-channel arrays |

The first eight addresses use x0 to x7. The last ten use successive eight-byte stack slots. Preserve x19 to x29, the lower halves of v8 to v15, FPCR and 16-byte stack alignment. Do not use x18.

GNU descriptors have 40 common bytes and 24 bytes for each dimension. Their data pointer is at byte 0, first stride at byte 40 and first bounds at 48 and 56. A zero first stride means one element. Use independent signed strides from each first logical cell, and do not apply assumed-shape offsets twice. Input and output owners are disjoint and naturally aligned.

Support 1 to 4096 columns, 4 to 512 ice layers, 1 to N diagnostic layers and an empty active interval. Every supplied owner contains the complete declared extent. Per-type inputs contain at least type 2. A positive-size diagnostic contains every ice layer and at least 13 channels. A zero-size diagnostic needs no readable data owner. Require finite consumed values, positive time and heat capacity, nonnegative conductivity, positive thicknesses and $`0<\sigma\le1`$, where $`\sigma=\mathrm{RSIMP}`$ is the implicit weight.

TSOIL has 2416 bytes. RSIMP is at 144, freezing and melting temperatures at 240 and 248, northern and southern ice depths at 256 and 264, conductivity at 272, heat capacity at 424 and the contiguous RDAI allocation descriptor at 1712. TCST has 128 bytes, with sublimation latent heat RLSTT at 56. RDAI covers indices 1 to N−1, with its allocation offset and lower bounds. The bottom thickness is the hemisphere's ice depth minus the separately rounded sum of RDAI(1), RDAI(2) and RDAI(3), as in the original. For four layers this gives the configured total depth. Preserve this declared bottom rule for larger supported layer counts.

## Complete Update

Round each operation separately in FP64 with FPCR 0. Form $`b=1/\Delta t`$, $`A=(\Delta t\,\sigma)\,2`$ and $`B=1-1/\sigma`$. Ice columns form surface input in the order $`(Q_{\mathrm{SW}}+Q_{\mathrm{LW}})+(H+\mathrm{RLSTT}\,E)`$, using surface type 2.

For each layer, form $`C_j=c h_j`$. For a layer above the bottom, form $`G_j=(A k)/(h_j+h_{j+1})`$. The bottom uses $`G_N=(A k)/(2h_N)`$. The right-hand side is $`(\Delta t Q)/C_1`$ at the top, zero in the interior and $`((T_f/\sigma)G_N)/C_N`$ at the bottom.

Call the complete accepted $`md2asm_soil_column_diffusion`$ with previous temperatures, G, the right-hand side, C and the ice mask. Its returned stage $`U`$ solves the frozen layer system. Recover $`T'_j=\min((T_j B)+U_j,T_m)`$. Nonice columns return $`\min(T_f,T_m)`$. The direct parent can use one-column views because the equations have no cross-column dependency, while retaining every original stage and operation inside the direct closure.

Diagnostics retain their source write order and scope. Channels 1 to 4 record heat capacity per ground area, previous temperature, previous heat and thickness. Channels 9 and 10 record sensible and latent surface flux in diagnostic layer 1 and zero in higher diagnostic layers. Channels 12 and 13 are zero. Channel 11 uses $`((\sigma(U_j-U_{j+1}))G_j)b`$ above the last diagnostic layer. At physical layer N it uses $`((\sigma(U_N-T_f))G_D)b`$, where D is the diagnostic layer count. This is the original bottom diagnostic expression, which differs from the heat-balance boundary flux and also selects G_D when D<N. Do not use it as evidence of column conservation.

## Independent Acceptance

Derive the heat matrix independently in extended precision from IT-1 and IT-2, and solve it through Cholesky factorisation, which writes the positive symmetric matrix as a product of two triangular matrices. Reuse the accepted child's ordered calculation proof, and check only this parent's new coefficients, surface input, ocean boundary, cap and diagnostic scope.

Compare returned temperatures with the independent implicit heat solution and check the complete column heat balance. Account explicitly for heat removed by the temperature cap. Use a solution rounding budget of $`65536\epsilon(N+1)`$ times the absolute temperature and stage scale, plus $`256`$ times the least positive FP64 value. Use the corresponding absolute energy scale for the column budget. These budgets test the physical equations and never alter returned bits.

The exact output limit is zero differing bytes over both complete owners, including unprocessed cells, gaps and unused diagnostic channels. Protect immutable inputs and descriptors, check both guard-page ends and preserved ABI registers, and cover both hemispheres, ice and nonice, empty intervals, surface heating and cooling, the melting cap, zero conductivity, signed zeros, subnormal flux, maximum dimensions, partial diagnostics and independent signed strides. A paired actual-call adapter must execute the complete direct parent and accepted child before forecast acceptance.

## Completed Checks

| Check | Calls | Complete output bytes | Independent relations | Differing bytes |
|---|---:|---:|---:|---:|
| Strict original heat solution and budgets | 262 | 32,573,936 | 749,018 | — |
| Protected direct assembly and ABI | 262 | 32,573,936 | 749,018 | 0 |
| Focused logical descriptor correction | 42 | 401,856 | 8,170 | 0 |
| Paired actual entry smoke | 42 | 401,856 | 8,170 | 0 |

The corpus includes 4096 columns and 512 layers, both hemispheres, the temperature cap and partial diagnostic layers. It preserves 24,611,536 bytes outside the declared output cells. The paired smoke records 160 actual calls to the complete unchanged diffusion child for 160 active ice columns. Its count-only wrapper supplies no numerical stage.

The direct parent uses a 1024-byte fixed frame and five FP64 layer vectors, with a further 32 bytes for child arguments and 16-byte workspace alignment. It reuses the vectors across independent columns. The child's accepted elimination scratch is separate and bounded by its unchanged contract. These checks establish agreement and the stated heat balances. No speed improvement has been measured.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfi_mod::srfi | 2,150 | 23,116,800 | Complete parent owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
