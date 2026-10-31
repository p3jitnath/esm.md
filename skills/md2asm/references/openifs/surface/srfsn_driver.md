# Complete Multilayer Snow Driver

Revision 1 freezes the complete coupled-forecast body of `SRFSN_DRIVER_MOD::SRFSN_DRIVER` from `surf/module/srfsn_driver_mod.F90`. The [physical input](../../../../../formulations/openifs/surface/snow_surface_update.md) gives the water and heat balances. The direct body is [multilayer_snow_driver.S](../../../../../src/openifs/surface/multilayer_snow_driver.S).

## Complete Update

Use FP64, the 64-bit floating-point format, with one nearest-even rounding after each operation and FPCR zero. Keep every product and sum in the original order. Preserve signed zeros and gradual underflow, and use no fused operation, reassociation or approximate division.

First clip old mass to `MAX(0,mass)` and old liquid water to `MIN(clipped_mass,MAX(0,water))`. Snow cover is `MAX(f5+f7,RFRTINY)`. A column is snow-free when this value is less than `RFRSMALL`. Snowfall is the sum of both snowfall inputs on land and positive zero elsewhere. Signed snow evaporation is `f5*evap5+f7*forest_snow_evap`.

A resolved snow column receives rain `f*(rain_convective+rain_large_scale)` and returns each ground rain input multiplied by `1-f`. Its heat input is the ordered sum of `f5*(sensible5+Ls*evap5)`, `f7*(sensible7+Lv*(evap7-forest_snow_evap)+Ls*forest_snow_evap)`, both weighted shortwave inputs and both weighted longwave inputs. Here `Ls=2834500` and `Lv=2500800` are latent heats in J kg$`^{-1}`$. Snow-free columns use positive-zero rain, heat and soil conductivity.

The frozen soil fraction is one at or below 270.16 K and zero at or above 274.16 K. Between them it is `0.5*(1-SIN((pi/4)*(T-272.16)))`. Soil conductivity uses the complete ordered `FSOILTCOND` graph already verified for [soil heating](srft.md), with the selected soil-type tables. Clamp the resulting value between 0.19 and 2 W m$`^{-1}`$ K$`^{-1}`$. Reuse the qualified unique SIN, LOG10 and POWER routes.

Call all six complete private assembly children in this order. [VGRID](snow_grid.md) selects layer depths. [REGRID](snow_regrid.md) conserves mass and heat while remapping layers. [SSRABS](srfsn_ssrabs.md) partitions radiation, with its first entry representing transmission through the top layer. [WEBAL](snow_water_energy.md) updates every layer's water and heat. [RSN](snow_density.md) updates density. [ASN](snow_albedo.md) updates albedo using top-layer melt minus freezing. Clear emitted snow energy to positive zero. Preserve the complete original diagnostic update, including precipitation, sensible and latent heat and old density channels.

## Supported Forecast Scope

The actual retained soil object selects multilayer snow and `LESNCHECK=false`. This is the coupled forecast domain. The original optional testing-only text output and abort budgets are outside the declared domain and are rejected before caller writes. The driver still performs independent acceptance checks for water, heat and valid snow states. No active forecast calculation is omitted.

Support 1 to 4096 columns, 1 to 64 snow layers, a complete or partial inclusive column interval and an empty interval. Snow fields have exactly the declared layer extent. Tile fields contain at least seven tiles. Soil fields contain their first layer. Logical land masks and soil-type indices use four-byte words. Density is positive, temperatures are between 100 K and 273.16 K, and clipped water cannot exceed clipped mass. Resolved snow has a positive active prefix after remapping. All consumed physical inputs and intermediates are finite. The six child domains, buffer rules and physical limits remain in force.

The top-soil temperature is between 100 and 500 K and soil water between zero and one. The original zero-index porosity word may be positive zero when unused by the snow-free branch. Each resolved snow column must select an index inside all three soil tables. Its selected soil porosity is between 1/32 and one, so the LOG10 operand is between 2$`^{-40}`$ and 32. The ice and water conductivity bases are between 0.1 and 10, and their POWER exponents are between zero and one. The phase SIN argument is strictly between $`-\pi/2`$ and $`\pi/2`$. Qualified arithmetic proofs are reused. The material constants and layer-bound tables are supplied by the checked soil and thermodynamic objects.

Diagnostics are enabled only when both complete rank-three owners have positive size. Heat diagnostics contain at least 15 channels and mass diagnostics at least 5. Empty owners have no accessed data. All caller inputs, descriptors and configuration objects remain unchanged, except the two throughfall vectors and ten declared output owners.

## Arm Interface and Storage

The application binary interface, ABI, defines addresses and preserved registers. `md2asm_multilayer_snow_driver` takes the original 41 argument addresses. Arguments 1–5 are the start column, final column, column count, snow-layer count and time step. They are followed by land mask, terrain, old mass, old temperature, old density, old liquid water, old albedo, tile fractions, soil temperature, two wind components, air temperature, two snowfall inputs, two throughfall vectors, longwave, shortwave, sensible heat, tile evaporation, forest-snow evaporation, soil water, soil type, pressure, soil object and thermodynamic object. The final ten are new mass, temperature, density, liquid water, albedo, ground heat, runoff, emitted-snow energy and both diagnostic owners.

GNU descriptors occupy 64, 88 and 112 bytes for ranks one, two and three. Each base pointer identifies its first logical element. Independent signed strides support gaps and reversed fields. Output owners must be disjoint from inputs, interfaces, material arrays and each other. All addresses and spans fit their integer widths.

The first eight addresses use x0–x7 and the remaining 33 use the stack. Preserve x18, x19–x29, low 64-bit v8–v15, FPCR and the aligned stack. A fixed 16 KiB frame contains interfaces and descriptors. One zeroed local workspace contains `columns*(80*layers+184)` bytes. Complete output owners are copied to temporary storage before calculation, and committed only after every numerical child returns. This retains inactive words and gaps and keeps rejected calls from changing caller outputs. Allocation and copying provide storage only, with no omitted numerical stage.

Canonical bytes contain both complete throughfall owners followed by the ten complete returned owners in argument order, including unused words, gaps and diagnostic channels. All bytes are little-endian. Native and paired acceptance requires zero differing bytes.

## Independent Verification

Check the full-column water change against snowfall, rain, signed evaporation and runoff at 110 decimal digits. Independently check throughfall partition, nonnegative mass, liquid-water limits, temperature, density and albedo bounds. With enabled diagnostics, check total thermal storage plus latent heat and ground exchange against the independently combined surface heat input. Check precipitation and heat channels separately.

Reuse the accepted children's unchanged physical and arithmetic proofs. The frozen physical residual bound is `1000000*2^-52` times the sum of absolute physical terms, with a unit floor, plus `128*2^-52`. This is the existing water and heat budget scale. Raw output comparison retains every bit and does not alter values to satisfy a physical check.

The native corpus passes 24 protected calls over 632,000 complete bytes with zero differences and 10,156 independent relations. Each native trial follows the complete original source and its independent 110-digit physical check. Cases include empty and partial intervals, snow-free columns, clipped analysis increments, snowfall, rain, melting, freezing, terrain and glacier grids, 64 layers, signed and gapped strides and both diagnostic states. The immediate 41-address ABI and paired smoke each pass two calls over 143,104 complete bytes with zero differences. Separate one-layer and one-empty-diagnostic comparisons pass, and four invalid domain or control settings reject before all output bytes remain unchanged. The five-channel mass diagnostic also passes four protected placements for each native, immediate ABI and paired route over 67,680 complete bytes with zero differences and 3,568 independent relations. These cases use the captured 24-column, five-layer contiguous layout and a partial reversed, gapped layout. A four-channel owner rejects before any returned byte changes. The captured first forecast call also passes the original source, native body, immediate ABI and paired routes at both protected placements. Each route compares 48,384 complete bytes with zero differences and checks 2,592 independent relations. Its 24 snow-free columns use no soil conductivity, so the original unused index-zero porosity sentinel remains positive zero. A resolved-snow call that selects that zero word rejects while all 24,192 shared output bytes remain unchanged. Actual complete forecast acceptance and performance measurements remain separate.

The shortwave child supports one to 64 snow layers, so the complete parent uses this same bound. The coarse forecast has five layers. The parent copies only the tile fractions and shortwave inputs to private contiguous buffers before the shortwave child, which lets the public interface keep signed or gapped input strides without changing any arithmetic.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_driver_mod::srfsn_driver | 2,150 | 52,012,800 | Complete returned multilayer-snow owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
