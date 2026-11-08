# SURFSEB_CTL Solver Contract

Revision 1. The [surface formulation](../../../../../formulations/openifs/surface/surface_skin_energy.md) maps to the complete original `surf/module/surfseb_ctl_mod.F90` caller and [direct AArch64 assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/surfseb_ctl.S).

## Method and Domain

The solver eliminates surface skin energy from the heat and water flux equations, averages their coefficients over surface types, solves the resulting two coupled air equations, and returns each surface temperature and flux. The source’s surface conductance input overwrites its preliminary conductance calculations, so the final numerical balance uses the supplied conductance.

The supported packet width is 1–4096 and the number of surface types is 1–10. The selected column range may be empty. The solver keeps all ten surface types, both supplied longwave flags, water or ice on lakes, the moisture correction to sensible heat, and each source radiation-transmission fraction. Inputs must supply valid allocated vegetation metadata and finite physical fields. Transfer rates and conductances are nonnegative, static energy and temperatures are positive, and surface fractions lie between zero and one and sum to one within FP64 rounding. The coupled equations must have nonzero finite denominators.

The surface arrays use GNU Fortran descriptors. A descriptor states the array address, shape and element strides. Both contiguous arrays and positive strided views are supported. The physical checks use only selected cells, while byte comparisons retain every complete output owner, including untouched cells and padding.

## Complete Stages

| Stage | Calculation |
| --- | --- |
| Prepare surface response | Longwave derivative and skin energy-to-temperature conversion |
| Eliminate skin energy | Heat, water and conductance coefficients for each surface type |
| Couple the lowest air layer | Ordered surface-fraction averages and a two-by-two solve |
| Return surface quantities | Static energy, temperature, water, sensible heat, latent heat and ground heat |
| Centre tiled longwave | Optional radiation values about the new mean skin temperature |

Heat and water fluxes are positive from air into the skin, and ground heat is positive from skin into the subsurface. The latent heat is for ice on sea ice, snow and frozen lakes, and for liquid water on the other types. The supplied longwave flag either uses the Stefan–Boltzmann derivative or the source’s radiation-to-temperature derivative.

The energy solve uses thermal radiation linearised about the radiation-step reference temperature. The optional final tiled-longwave stage instead centres the returned values about the new weighted skin temperature. These are distinct stages. The verifier checks the balance used by the solve, the final centring equation and the change between their two radiation references. It does not claim an unchanged energy balance for each returned, recentered tile.

## Interface and Storage

The default entry is `__surfseb_ctl_mod_MOD_surfseb_ctl`. `SURFSEB_CTL_SYMBOL` selects a unique comparison entry. There are 48 ordinary argument addresses. The first eight occupy `x0` through `x7`, and the remaining 40 occupy the incoming stack.

| Argument indices | Storage |
| --- | --- |
| 0–3 | Four 32-bit column and surface-count integers |
| 4–5 | Two 32-bit vegetation-index arrays |
| 6 | FP64 timestep in s |
| 7–18 | Twelve rank-two input descriptors |
| 19–30 | Twelve rank-one input descriptors |
| 31–36 | Constants, exchange, vegetation, lake, soil and urban objects |
| 37–44 | Eight rank-two complete output owners |
| 45–46 | Static-energy and water output descriptors for the lowest air layer |
| 47 | One 32-bit ice-thickness flag |

An FP64 element uses eight little-endian bytes. Matrix indices follow Fortran column order. The frozen local metadata record specifies the six configuration-object sizes and every consumed field and allocated-array descriptor. The caller must provide complete valid owners and must keep mutable outputs separate from other arguments. Read-only views may share storage.

The direct body preserves `x18`, `x19` through `x29`, and the low 64 bits of `v8` through `v15`. Its stack stays 16-byte aligned and needs 2304 bytes. It requires FPCR zero for round-to-nearest with ties to even, gradual underflow and preserved signed zeros.

## Arithmetic and Physical Checks

Every solver multiply, add, subtraction and division rounds separately in FP64. Integer cubes use exact source-ordered FP64 multiplications. There is no fused arithmetic, reassociation, approximation, compiler-generated solver assembly or missing numerical helper.

Independent exact rational checks cover the static-energy conversion, heat and water exchange, sensible and latent heat split, ground conduction, the linearised surface energy balance, the air-layer response and final tiled longwave centring. The rounding budget is 4096 times FP64 unit roundoff times the sum of magnitudes in each independent relation. It accounts for cancellation in very stiff sea-surface conductance and is frozen before assembly emission.

The original gate passed 29 cases, 2,760,272 complete output bytes and 7,788 independent relations. It covers all ten tile counts, both longwave flags, lake ice and liquid water, moisture correction, strided views, cropped and empty packets, and the declared packet limit. The largest observed residual uses less than 0.00049 of its frozen budget. The direct body passed 58 protected placements, 5,520,544 complete returned bytes and 15,576 independent relations, with zero differing bytes. Two immediate ABI cases passed 35,376 bytes and 2,375 relations. Five shape or stride rejection cases stopped before changing 9,840 output bytes. The machine-code check found no fused floating-point instruction or numerical child call.

The forecast comparison wrapper accepts positive-strided inputs and complete contiguous output owners. It calls the unchanged source on complete output snapshots, runs the native body on the real outputs and compares every returned byte. Four profiling-enabled paired cases passed 6,144 bytes and 609 independent driver relations. They include a shared read-only view, an empty range and one- and ten-type surfaces. Output overlap and unsupported output layout stopped before changing 35,376 bytes. The native body also has separate accepted strided-output checks.

Full-forecast acceptance and comparative timing remain pending. Exact local source, commands, metadata, original controls and focused proofs are retained under `.runtime/openifs/surface_energy_balance_7240564/`.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfseb_ctl_mod::surfseb_ctl | 4,737 | 61,094,400 | Native private surface child, complete heat/water-parent owners and child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
