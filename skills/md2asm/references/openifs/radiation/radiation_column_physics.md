# Radiation Column Physics Contract

The direct parent implements the complete selected `radiation_interface::radiation` route. Its eleven address arguments are column count, layer count, first column, last column, configuration, single-level state, thermodynamics, gas, cloud, aerosol and flux. Each of the eight stages calls a complete accepted assembly routine. These called routines are the numerical children. The outer `RADIATION_SCHEME` interface is a later checkpoint.

## Frozen Route

Use eight total columns, nineteen layers and an active interval from column one to a last column from one through eight. Pressure increases downward. Longwave and shortwave radiation, clear outputs, clouds and aerosols are enabled. The IFS RRTMG gas model groups spectral points to represent gas absorption. Both transport solvers use the Monte Carlo independent-column approximation, McICA, which samples cloud states and averages their radiation fluxes. Cloud optics use the accepted SOCRATES liquid and Fu ice models. Spectral diagnostic saving is disabled. Longwave aerosol scattering is disabled. Longwave cloud scattering and surface derivatives are enabled. Retain every accepted child's consumed numerical domain. A changed branch needs a new contract.

The genuine original caller selects the default shortwave water-vapour continuum with `NSWWVCONTINUUM=0`. The source replay uses the unchanged accepted RRTM parameter-table loader with that actual selector and the original big-endian table files. Table initialisation occurs before the parent call and supplies immutable parameter data. It supplies no omitted calculation in the direct parent. Keep the accepted exponential, logarithm and power dispatch unchanged.

## Complete Ordered Calculation

First extract the direct and diffuse shortwave albedos and longwave albedo with accepted `get_albedos`. Call complete accepted `gas_optics` for gaseous longwave depth, shortwave depth and scattering, boundary Planck emission, surface thermal emission and incoming solar radiation. Use the original spectral-first, layer-second and active-column-last temporary arrays.

Call accepted `crop_cloud_fraction`, then complete `cloud_optics` for all six liquid and ice optical arrays. Call complete `add_aerosol_optics` to add the selected aerosol mixture to gas optical properties. Preserve the unchanged accepted products, divisions, clipping and intermediate rounding points.

Call complete longwave McICA, then complete shortwave McICA. The cloudy and clear calculations, sample generator and all vertical transport belong to those accepted children. Finally call complete `calc_surface_spectral` to produce the required band and canopy fluxes. All eight stages must finish, with no original Fortran numerical fallback.

## Complete Owners And ABI

The genuine packet closes 95 complete owners and 1,030,880 bytes. Its 26 returned arrays own 66,368 bytes, including the cropped cloud fraction. Its 964,512 read-only bytes and every descriptor word remain unchanged. The fixed object sizes are 20,040 bytes for configuration, 624 for surface state, 264 for thermodynamics, 416 for gas, 792 for cloud, 800 for aerosol and 3,360 for flux. Retain recorded ordinary and pointed-array aliases. A descriptor stores an array address, type, bounds and spacing. Validate the consumed array shapes and keep inactive columns and unused values unchanged.

The Arm application binary interface, ABI, passes arguments zero through seven in `x0` through `x7`, then cloud, aerosol and flux in three eight-byte stack slots. Keep sixteen-byte stack alignment and preserve `x18`, saved general registers and saved vector-register portions. Class-method children receive their accepted sixteen-byte class carriers. Ordinary-type children receive the complete ordinary objects.

Use 1,247,360 bytes of numerical scratch and 66,368 bytes of private returned storage. Copy the cloud and flux object headers and rebind only their mutable arrays to private storage. Complete every child before copying returned bytes to the caller. Unsupported selectors, shapes and writable overlaps reject before caller writes.

## Arithmetic And Acceptance

Use 64-bit floating-point numbers, FP64, with round-to-nearest, ties to even, gradual underflow and signed zeros. Preserve every accepted arithmetic dependency and intermediate rounding point. No fused operation, reassociation, approximate instruction or reduced precision is permitted. FPCR controls rounding, FPSR records arithmetic events and `errno` records mathematical-library status.

The complete protected genuine source replay matches all returned and read-only bytes, actual aliases and descriptor words. Its source ABI has only the documented compiler use of `x18`. FPCR is zero, FPSR is 24 and `errno` is 34, matching the genuine original return. Independent exact-rational source checks pass 8,928 boundary, spectral, band, canopy, cloud-cover and derivative relations. They use $`\gamma_n=nu/(1-nu)`$, with $`u=2^{-53}`$, gradual-underflow terms and the unchanged accepted solar-spectrum bound. Unused nighttime cloud-cover bits remain unconstrained and are preserved.

The protected assembly genuine call passes all complete returned and read-only bytes, 8,928 independent relations and immediate status, with zero ABI errors. Four new supported source and assembly pairs cover partial intervals, night and clear sky. They match 265,472 returned bytes and 3,858,048 read-only bytes, with 28,224 independent relations for each implementation. Two rejecting cases preserve 2,061,760 caller bytes and execute no numerical child. A focused ordered check with all 141 normal preload libraries also passes the complete genuine return, all eight completed private stages and source-only forwarding. Reuse unchanged child physics. The normal forecast must have positive complete native parent calls, zero differing owner bytes and exact saved outputs. Original comparison calls receive no primary native credit.

The complete original aerosol route rejects an empty column interval in its gas reader. This parent therefore rejects an empty interval before allocation or caller writes. Partial non-empty intervals remain supported, and they preserve every inactive column byte.

For each normal comparison, the original source runs on separate returned storage. Its eight stages and qualified nested helpers are forwarded to the frozen original library, with no native credit. The primary parent directly calls the accepted assembly entries. The live check verifies original boundary energy before that primary call, then compares every returned and read-only owner byte and immediate arithmetic status. Its independent long-double sums use a stated 64-unit roundoff allowance for the separate 113-bit checking arithmetic, while retaining the source bounds. Standalone child reports can have zero visits because this parent owns their calls. Require positive completed private stage counts instead.

The three local assembly bindings for surface albedo, cloud cropping and surface spectral projection are made from the accepted public sources with unique entry names. They are static assembly objects. Gas optics, cloud optics, aerosol optics and both McICA stages use unique accepted assembly entries. The original Fortran library supplies frozen read-only coefficient data and the separate comparison only. It supplies no primary numerical stage.

The complete direct parent passes 6,400 forecast calls and 424,755,200 returned bytes with zero differences. All ten saved files match the separately reviewed unfused transform reference across 618,140 bytes.
