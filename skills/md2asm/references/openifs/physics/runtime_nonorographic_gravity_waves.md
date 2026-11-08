# Runtime Non-Orographic Gravity Waves

Gravity waves move air vertically and transfer horizontal momentum between atmospheric layers. This runtime extension retains the accepted [wave calculation](gwdrag_wms.md) and [launch combination](gwdragwms_layer.md), while restoring the original grid-spacing factor for fine grids. The [physical formulation](../../../../../formulations/openifs/physics/nonorographic_gravity_wave_drag.md) and all later wave calculations remain unchanged.

## Grid-Spacing Factor

Let $`w`$ be the positive, dimensionless area weight of a column, $`R`$ the planet radius in metres, and $`\pi`$ the accepted circular constant. The source estimates the grid spacing $`d`$ in metres and reduces the launch strength by the dimensionless factor $`f`$.

```math
d=\max\left(100,\,2R\sqrt{\pi w}\right),\qquad a=\frac{1}{29000},\qquad b=\frac{1}{3500}
```

```math
f=1-\min\left(1,\,\arctan\frac{\max(1/d,a)-a}{b-a}\right)
```

The denominators 29,000 and 3,500 are lengths in metres. The source launch flux is multiplied by $`f`$ before the existing launch-spectrum normalisation. Coarse columns have $`f=1`$. Fine columns use the original gradual reduction, including the 100-metre lower spacing bound. This implements original `GWDRAG_WMS` lines 409 through 416 with separately rounded FP64 operations. The constants $`a`$ and $`b-a`$ use the source-rounded words `3f021432907d6c1f` and `3f3076f7314da70a`. No fused arithmetic or reassociation is used.

## Entries and Supported Inputs

[`runtime_nonorographic_gravity_wave.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/runtime_nonorographic_gravity_wave.S) exports `md2asm_runtime_nonorographic_gravity_wave`. Its 22-address application binary interface (ABI), complete arrays, disjoint output owners, 1,024-byte stack frame and private allocation follow the original [child contract](gwdrag_wms.md). The ABI defines argument locations and saved registers. Columns range from 1 through 2,048 and atmospheric levels from 2 through 512. Launch indices range from 1 through 3, with each selected launch level from 2 through the live level count. The selected column interval is empty or lies within the column count.

[`runtime_nonorographic_wave_launches.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/runtime_nonorographic_wave_launches.S) exports `md2asm_runtime_nonorographic_wave_launches`. Its nine-address ABI, complete derived records, 768-byte stack frame, work allocation and zero through three ordered launches follow the [parent contract](gwdragwms_layer.md). It calls the complete runtime child directly. Weather fields, pressure, temperature, precipitation, launch levels, column weights and array bounds remain runtime inputs. No driver supplies a numerical stage.

These new entries currently support the default source parameter selection `LOZPR=1`, the other three flags equal to zero, `NSLOPE=1`, `NGAUSS=2` and `GPTWO=2`. These select the latitude-dependent launch profile, spectral slope and square saturation law. Other values are refused before output mutation. Launch fluxes, wavelengths, Gaussian parameters and time step remain live inputs within the accepted physical limits. The earlier coarse-grid entries and their broader accepted options retain complete object identity.

Callers provide complete live records and buffers, with no address wrap, the original typed descriptor bounds, four-byte integer alignment and eight-byte FP64 alignment. Mutable owners must be mutually disjoint and disjoint from consumed inputs and records. Pressure, temperature, wavelength and time step retain the positive and finite limits in the child contract. Area weights must be positive and finite. The five physical constants come from the accepted owned physical record. The circular constant must have word `400921fb54442d18`. Floating-point control FPCR must be zero. Raw pointer capacities and all alias relations remain caller obligations.

[`wave_launch_grid_factor.S`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/wave_launch_grid_factor.S) exports `md2asm_wave_launch_grid_factor`. Registers `d0`, `d1` and `d2` receive $`w`$, $`\pi`$ and $`R`$, respectively. It returns $`f`$ in `d0`. Its raw caller supplies positive finite values and FPCR zero. Its 32-byte stack frame preserves `x18`, `x29`, `x30`, stack alignment and all required saved registers. It calls the public scalar `atan` function. The complete wave route also retains its existing public `exp` and `log` calls. Floating-point status and `errno` remain observable and are compared with the original.

The selected build uses the shared numerical bodies behind `GW_RUNTIME_GRID_SPACING`. It restores the full spacing expression and narrows admission to the checked parameter selection. The default builds remain byte-identical complete objects. The private wave arrays, launch accumulation order, canonical complete output owners and independent momentum and energy checks are unchanged.

## Checks and Remaining Connection

Ten genuine original and ten native child calls compare all 156,064 returned bytes exactly, while preserving every read-only owner and matching raw floating-point status and `errno`. Ten parent pairs compare all 305,024 returned bytes exactly. Protected placements cover both buffer ends, partial intervals, shifted descriptor bounds, zero launches and three launches, including a 137-level case. Separate passive observations compare all consumed intermediate values. Source-unwritten private cells are outside that intermediate comparison, while every returned output byte remains included.

An independent 100-digit calculation checks the spacing factor and its range and trend. Independent wave-action, momentum and phase-weighted energy relations cover the joined child, while pressure-weighted momentum relations check accumulated parent tendencies. Twenty-four new shared-buffer refusals preserve complete owners for unsupported parameter choices, zero area and a changed circular constant. Native ABI masks are zero. The original reference's known `x18` scratch use is disclosed separately from numerical and status agreement.

Actual linked slots reach all five owned physical constants and the public mathematical functions. The parent-to-child and child-to-factor branch targets are checked in memory. The native check links no original OpenIFS numerical library. Its local physical-storage scaffold is only verification storage. Production must use the one accepted assembly-owned physical record and aliases.

## Actual Parameter Connection

The [mountain-wave setup](../setup/runtime_orographic_gravity_wave_parameters.md) and [wave-launch setup](../setup/runtime_nonorographic_gravity_wave_parameters.md) now feed this unchanged parent from actual assembly-owned Geometry and MODEL records. Geometry is the grid description, and MODEL stores the forecast settings and fields. The accepted configuration reads the actual input files and supplies the physical controls, a 450-second time step and an eight-step stop. Its own `LEPHYS` word selects the active physical schemes. The accepted standard-atmosphere calculation supplies all six live profile arrays before either wave setup runs.

The original nine-address interface is unchanged. Its first three addresses are Geometry + 3,272 for the standard atmosphere, MODEL + 1,588,032 for mountain-wave settings and MODEL + 1,588,128 for wave-launch settings. The fourth address is the actual field namespace at MODEL + 192. The remaining five records supply the live dimensions, weather state, auxiliary fields, fluxes and two tendency fields. The emitted runtime `CALLPAR` already forms these same member addresses. No additional binding wrapper or numerical implementation is needed. Its complete enclosing execution remains a separate check.

Eight new original and eight native calls use the same actual parameter owners with 137 levels and column counts 1, 8 and 17. Full and partial intervals are placed at both protected buffer ends. All 378,400 output bytes and 160 raw status bytes agree exactly. Both routes pass 94,600 independent accumulated-momentum relations in total. Every Geometry, MODEL, configuration and six profile-owner byte remains unchanged, along with consumed weather inputs and inactive output cells. All actual owners are released. Native ABI masks are zero, and the original retains its disclosed mask of two. Existing child science, unsupported-input refusals, pointer slots and branch checks are reused for unchanged code.

This accepts the bounded component connection and its exact provider revision. The weather carriers in this check are prepared valid states. Complete loaded-weather `CALLPAR` forwarding and the operational forecast remain unfinished. The actual guarded setup limits this joined route to 2 through 256 levels, within the broader raw numerical bounds above. This fresh owner connection checks 137 levels. Physical constants in the comparison use the already qualified assembly-owned verification storage. Production must retain the one accepted physical namespace and its exact linked addresses.
