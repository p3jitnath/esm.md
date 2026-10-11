# CUMASTRN Solver Contract

Revision 1. This contract maps the [convective column formulation](../../../../../formulations/openifs/physics/convective_column_update.md) to [direct AArch64 assembly](../../../../../src/openifs/physics/cumastrn.S). The complete original weather caller is `arpifs/phys_ec/cumastrn.F90`.

## Method and Supported Domain

The calculation keeps the original cloud ascent, cloud exchange, precipitation, moisture and momentum updates. It processes a complete horizontal packet because some cloud decisions depend on the packet as a whole. Levels retain their top-to-bottom source order.

The accepted domain has normal nonlinear physics, `LSPP=false` and `LMFDD=true`. Chemical tracer transport is inactive, which means `LMFTRAC=false` or `KTRAC=0`. The actual coarse-forecast capture has `KTRAC=0`, `LMFTRAC=true` and `LSPP=false`. Active stochastic cloud perturbations, active tracer transport and the original undefined no-downdraft branch are rejected before any output changes.

Let $`K`$ be the packet width and $`N`$ be its number of levels. The supported limits are $`1\le K\le4096`$, $`4\le N\le1024`$ and $`KN\le65536`$. Selected columns start at `KIDIA` and end at `KFDIA`, both using Fortran’s numbering from 1. A selected range may be empty. Cloud search indices retain the bounds required by their complete numerical children.

## Complete Numerical Update

| Stage | Direct numerical route |
| --- | --- |
| Prepare environmental and parcel states | `CUININ` |
| Find cloud bases and parcel buoyancy | `CUBASEN` |
| Complete cloud ascent and exchange | `CUASCN` with `CUBASMCN` and `CUENTR` |
| Start and descend downdrafts | `CUDLFSN` and `CUDDRAFN` |
| Return precipitation and cloud mass fluxes | `CUFLXN` |
| Update heat and water | `CUDTDQN` with its complete tridiagonal solve |
| Update wind | `CUDUDV` with its complete tridiagonal solve |
| Adjust saturated parcels where required | Complete `CUADJTQ` and its environment child |
| Return parent diagnostics | Direct parent arithmetic for cloud speed, wind work and precipitation density |

Every numerical child is a complete accepted assembly body. The local comparison wrapper supplies pointer storage, snapshots and checks. It supplies no numerical stage.

The parent preserves the cloud-base selection, deep and shallow cloud rules, daily-cycle choices, explicit or implicit tendency updates, lightning diagnostics and source precipitation phases. It keeps the original separately rounded multiply, add, divide and reduction order. Its cube-root-like diagnostic preserves the source’s widened single-precision `0.3333` literal. Its rain and snow density diagnostics retain the FP64 exponents `1/1.15` and `1/1.10`.

The parent starts the first full-level dissipation plane at zero for the complete packet, including an empty selected range. Other inactive columns retain their original complete-owner bytes.

## Interface and Storage

The application binary interface, or ABI, is the GNU Fortran ordinary-pointer interface. The default entry is `cumastrn_`. The `CUMASTRN_SYMBOL` macro can select a unique entry for local comparisons. There are 68 addresses, numbered from 0 below. The first eight use `x0` through `x7`, and the remaining 60 occupy the incoming stack in that order.

| Argument addresses | Storage and role |
| --- | --- |
| 0–4 | Simplified-physics, model-physics, field metadata, chemistry and stochastic configuration objects |
| 5–8 | Four 32-bit integers for first column, last column, packet width and level count |
| 9–10 | $`K`$ land flags and one FP64 timestep in s |
| 11–17 | Seven $`K\times N`$ environmental fields |
| 18–23 | Surface-flux and geometry fields, with $`N+1`$ faces where required |
| 24–26 | Two column fields and the declared stochastic-field owner |
| 27–32 | Existing temperature, water and wind rates, plus the parent’s input tendency fields |
| 33–42 | Ten $`K`$-element 32-bit cloud or boundary-layer flags and indices |
| 43–47 | Five $`K\times N`$ cloud and aerosol-limit fields |
| 48–50 | Four condensed-water output planes, two snow planes and one exchange plane |
| 51–55 | Two face precipitation fields, surface rain, level rain and two precipitation-density planes |
| 56–59 | Four $`K\times N`$ mass-flux or exchange-rate fields |
| 60–63 | Three column diagnostics and one $`K\times N`$ dissipation field |
| 64–67 | Tracer count and the complete declared, inactive tracer owners |

Real arrays use little-endian FP64 values, with the column index varying fastest. Integer arrays use 32-bit words. Full-level fields occupy $`8KN`$ bytes and face fields occupy $`8K(N+1)`$ bytes. The four condensed-water planes occupy $`32KN`$ bytes. Two-plane outputs occupy $`16KN`$ bytes. Each caller must provide complete aligned owners for the declared shapes.

The 36 mutable owners are arguments `11, 12, 17, 27, 28, 29, 30, 33, 34, 35, 36, 37, 38, 39, 40, 41, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63`. The comparison checks each complete owner in this order, including padding columns, untouched cells and diagnostic bits. Shared read-only views remain shared when the source control is cloned.

The verified object sizes are 864, 10408, 1359136, 11936 and 3192 bytes for arguments 0–4. The model-physics object contains its convection settings at byte 3504 and cloud settings at byte 712. The local frozen layout record supplies each consumed field offset. Unused embedded pointers are retained as metadata and do not provide an omitted calculation.

The body preserves `x18`, `x19` through `x29` and the required low 64 bits of `v8` through `v15`. The stack stays 16-byte aligned. Its parent workspace needs `4608+align16(268KN+248K)` bytes, with additional stack for the complete children. A caller must provide enough stack for this declared workspace and the selected child calls.

## Arithmetic and Verification

Execution requires FPCR zero, which selects round-to-nearest with ties to even and gradual underflow. Solver operations retain signed zeros and round separately in FP64. The accepted scalar exponential function and the uniquely named original-rounding [POWER primitive](../power_math.md) provide the frozen external math boundaries. The production comparison route verifies both bindings before execution.

Independent checks cover positive water and upward mass fluxes, nonpositive downward mass fluxes, valid cloud levels, inactive-cloud boundaries and the pressure-integrated wind work. If $`u`$ and $`v`$ are wind in m/s and $`\delta a_u`$ and $`\delta a_v`$ are their added accelerations in m/s², the column wind-work diagnostic $`W`$ in W/m² obeys

```math
W=-\sum_j\left(u_j\delta a_{u,j}+v_j\delta a_{v,j}\right)\frac{\Delta p_j}{g}. \tag{CUM-4}
```

Active parcel condensate must be nonnegative. The original ascent can retain a finite trial value one level above the accepted cloud top, where `JK=KCTOP-1`, `LDCUM=true`, and both `PMFU` and `PLRAIN` are zero. This stopped trial carries no upward water. The parent’s CAPE calculation reads condensate below the cloud top, and the following `CUCCDIA` calculation reads it at the cloud base. The comparison preserves every trial diagnostic bit, including a negative value, while keeping the active condensate, detrainment, precipitation and mass-flux bounds.

Exact rational arithmetic checks this balance in the small verifier. High-precision real calculations independently check the parent’s dissipation and precipitation-density powers. The admissibility and balance budgets remain the frozen local values. Exact output acceptance requires zero differing bytes and preserves every declared output bit.

The original physical corpus covers 28 cases, including deep, shallow, mid-level, cold, stable, cropped and empty packets, daily-cycle choices, explicit and implicit momentum, and the declared dimension limits. The native check passed 56 protected buffer placements, 8,762,432 complete returned bytes and 1,187,184 independent parent relations. Six immediate ABI cases passed 86,800 compared bytes and 5,480 independent relations. Six unsupported-input cases stopped before changing 78,120 shared output bytes.

The retained actual forecast packet has 24 columns and 19 levels. Its complete source outputs passed 14,808 independent parent relations, and the direct body matched all 104,160 returned bytes. Three profiling-enabled live paired cases passed 130,200 compared bytes and 15,840 independent driver relations. These include the actual packet, shared read-only wind views and an empty selected range. The source runs on cloned complete owner unions, the assembly runs on the real owners, and the assembly’s exact output returns to the caller.

These focused results establish readiness for the combined forecast gate. They do not yet claim that the complete forecast passed this new parent replacement. Local source versions, binary captures, commands, revisions and proof records are retained under `.runtime/openifs/cumastrn_source_7240564/`.

The complete native parent counts its private CUASCN and CUFLXN executions separately from calls made by the source-verification shadow. These counters record completed function calls and complete output-owner extents. An extent is the storage size and does not claim an additional byte comparison. The complete parent comparison and each child’s unchanged physical, exact-byte and ABI proofs establish the declared scope.

The final closure also passed one captured, profiling-enabled parent comparison and one immediate ABI call after these counters were added. Both calls matched their complete outputs, covering 208,320 bytes and 29,616 independent parent relations. These counters add no numerical operation.

A second actual forecast packet exposed this stopped-trial state. Its independently checked original outputs passed 10,565 parent relations. Two protected native placements matched 208,320 complete returned bytes, and one profiling-enabled paired replay matched 104,160 bytes. Four focused guard cases rejected negative active condensate, a negative trial with upward mass or rain, and a nonfinite trial. The assembly and every numerical child remained unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cumastrn | 2,150 | 223,944,000 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
