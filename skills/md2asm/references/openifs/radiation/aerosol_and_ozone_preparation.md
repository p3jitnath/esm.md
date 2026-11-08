# Aerosol and Ozone Preparation Contract

This contract records the complete selected RADACT calculation for physics revision 1. It uses the actual coarse-forecast controls and complete input owners retained by the original-only observer. The observer forwards the original call and supplies no numerical stage. Native assembly must own every selected calculation.

## Selected Calculation

The selected controls are LNEWAER=1, NAERMACC=1, NMCLAT=61, NMCLON=120 and NMCVAR=12. LHVOLCA, LESO4HIS, LAERADJDU and LAER3D are zero, and NVOLCVERT is zero. The captured stochastic-control flag is zero. It would enable random changes to parameters, which are outside this selected unperturbed calculation. Reject an unsupported route before output writes. Keep all settings unchanged.

The source first sets the volcanic background. It then interpolates five Tegen fields on the 72 by 46 longitude and latitude grid. It clears every selected PAERO layer and species, then interpolates eleven MACC mass fields on the 120 by 61 grid. Latitude interpolation uses sine of latitude. Longitude inputs lie in the usual interval from zero up to, but excluding, two pi. Interpolation wraps the final interval to the first longitude. Rounded grid coordinates and the rounded final interval endpoint form the frozen interpolation geometry. Each interpolation performs two latitude differences, products and additions, then the longitude difference, product and addition in the original dependency order.

The source uses the accepted LEGTRI basis twice, with orders 6 and 11. A basis is a set of functions whose weighted sum describes a spatial field. Ordered coefficient sums and longitude recurrences produce the ozone column and shape, followed by four original aerosol harmonic fields. Tegen interpolation and these harmonic fields remain part of the selected source path even where MACC replaces their use.

A zero top pressure is valid. Each layer still has positive pressure depth. The initial boundary stores pressure, cumulative ozone, four legacy aerosol profiles, five MACC profiles and their cumulative masses. Each layer calculates the original temperature and humidity ratios, new cumulative quantities, tropopause weight and six legacy aerosol fields. It preserves the first land-aerosol expression before the selected MACC background assignment. It then calculates the ozone difference and all twelve PAERO fields, including the zero final field. It carries cumulative values to the next layer and applies the optical-depth floor.

The tropopause calculation sets its new weight to one when mean layer pressure is below 999 Pa. Otherwise it multiplies the old weight by the smaller of one and the boundary-temperature ratio raised to RCTRPT. The layer stratosphere weight is the square root of the product of old and new weights. The returned MACC weight is one minus this value. The accepted POWER route supplies exponentiation.

## Storage and Interface

The original entry has 27 pointer arguments. Arguments 0 to 4 are TEAERD4232B, TERAD2040B, TEAERSNK880B, TRIP175976B and TSPP_CONFIG3192B. Arguments 5 to 13 are four-byte integers KIDIA, KFDIA, KLON, KLEV, KRINT, KDLON, KDLONP2, KSHIFT and KCF. The observer forwards the optional final address. The unperturbed calculation does not consume it.

| Argument | Field | Complete FP64 shape | Role |
|---|---|---|---|
| 14 | PAPRS | KLON by KLEV+1 | Boundary pressure in Pa |
| 15 to 18 | PGELAM, PSIN, PCLON, PSLON | KLON | Longitude in radians and coordinate sine or cosine |
| 19 | PTH | KDLONP2 by KLEV+1 | Boundary temperature in K |
| 20 to 22 | PQ, PQS, PECPO3 | KDLONP2 by KLEV | Humidity, saturation humidity and prescribed ozone |
| 23 | PAER | KDLON by 6 by KLEV | Optical depth output |
| 24 | PAERO | KDLON by KLEV by 12 | Aerosol mass mixing ratio output |
| 25 | POZON | KDLON by KLEV | Pressure-weighted ozone amount output |

Selected input columns run from KIDIA to KFDIA in increments of KRINT. Selected output columns begin at KSHIFT+1 and advance by one. KCF=0 reads temperature and humidity at the input index. KCF=1 reads them at the output index. All indices must lie inside the complete owners. Selected columns share one latitude, as the original caller groups its columns by latitude.

An owner is the complete allocated byte range of a field. The complete input closure has 46 owners. It includes four legacy profile arrays from TEAERD, five current profile arrays from TERAD, and eleven MACC arrays from TRIP. GNU array descriptors retain their exact rank, lower bounds, strides and element size. Rebinding changes only descriptor addresses, then restores those address words for comparison. No numerical byte is normalised.

Integer addresses must have four-byte alignment. Other ordinary addresses, derived targets and arrays must have eight-byte alignment. The application binary interface (ABI) defines how the caller passes addresses and which registers the called function must preserve. Native code preserves Arm callee-saved registers, including x18, the stack pointer and floating-point control register. Internal calls use unique accepted assembly symbols. Original library data may supply captured constants, with no original Fortran numerical call.

## Arithmetic and Acceptance

FP64 stores each real number in 64 bits. Each real field uses FP64 with round-to-nearest, ties to even and gradual underflow. Preserve source dependencies and intermediate rounding points. Exclude fused multiply-add, reassociation, approximate division or square root, and reduced precision. Integer cubes use two ordinary multiplications, followed by square root where specified. Independent column work may share storage without changing any dependency.

Canonical output is every byte of PAER, PAERO and POZON in the original column-major layout. Prefixes, suffixes and inactive output columns retain their incoming bytes. All ordinary inputs, climate fields, profiles and consumed global constants remain unchanged. The FPCR register controls rounding and underflow. The FPSR register records arithmetic exception flags, and errno is the error code. Entry and returned errno, FPCR and FPSR must match the genuine original call and the focused source/native pair.

One focused verifier checks interpolation bounds, cumulative profiles, positive air-layer mass, aerosol mass per layer, optical-depth floors and the telescoping ozone column independently. It also checks complete output bytes, complete read-only owners, critical partial and seam or pole cases, and protected buffer bounds. Require zero differing output bytes and all physical relations before the normal forecast gate. Reuse unchanged accepted child proofs.

## Completed Focused Checks

The genuine eight-column, nineteen-layer original call passes 6,418 independent relations at 120 decimal digits. Nine protected source/native calls pass 53,842 relations with 207,936 returned bytes and 7,545,780 read-only bytes, all identical. These include partial column ranges, both temperature layouts, both poles, the cyclic longitude interval, the 999 Pa threshold and signed-zero floors. Eight unsupported-route and buffer checks reject before any of 6,892,192 owner bytes change.

The paired forecast adapter passes two protected calls with 46,208 returned bytes, 1,676,840 read-only bytes and no differences. Its independent live calculation uses a 113-bit significand. The interpolation oracle includes its own derived 16-epsilon rounding budget when checking a convex range. The physical FP64 relation budgets remain unchanged. The original GNU body changes only its qualified x18 register bit, while the native body and complete adapter preserve every declared register.

Each completed parent makes two private LEGTRI calls and 107 private sine calls. POWER calls depend on the pressure-threshold branch. Counts record completed direct child executions. Source shadows and verification-only basis evaluations supply no private child credit. Normal forecast admission and saved-file checks remain pending.

The [physics input](../../../../../formulations/openifs/radiation/aerosol_and_ozone_layer_amounts.md) defines the physical quantities. The shared scalar exp and log functions retain their previously qualified arithmetic boundary. Sine, POWER and the associated Legendre basis reuse their accepted assembly routes.

## Accepted Forecast Calls

The complete direct stage passes 6,400 genuine native calls and 147,865,600 complete returned bytes with zero differences. All ten saved forecast files agree across 618,140 bytes. The recorded independent physics and interface checks remain required within this contract. Other forecast stages remain in Fortran.

## Runtime Columns and Layers

The separate entry [`md2asm_runtime_radiation_aerosol_and_ozone_preparation`](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/radiation/runtime_aerosol_and_ozone_preparation.S) extends this calculation to live column and layer counts. It retains Tegen aerosol and ozone calculations and both MACC branches. The three-dimensional branch uses CAMS, the Copernicus Atmosphere Monitoring Service. Aerosols are small airborne particles. The earlier selected entry remains unchanged.

The first 27 argument addresses keep the interface above. Argument 28 is a borrowed 16-byte context at incoming stack offset 152. Its words contain the private memory budget in bytes and the address of the complete 520-byte assembly-owned physical-constant record. This record supplies pi and gravitational acceleration. The entry imports no original OpenIFS calculation or module global. Its mathematical services use the accepted direct provider graph.

The live column count $`P`$ is from 1 to 1,024 and the layer count $`L`$ is from 1 to 512. The three declared column pitches equal $`P`$. Active columns run from `KIDIA` to `KFDIA` with `KRINT` equal to one and `KSHIFT` equal to `KIDIA` minus one. Each call covers one source latitude group while retaining the full column pitch. The source `LAER3D` switch at typed `TERAD` offset 464 selects the three-dimensional route. The separate `LAERADJDU` switch remains false.

The complete `TRIP` record supplies thirteen contiguous FP64 work arrays of shape `(120, 61, 60)`. Eleven contain source aerosol layer masses. The other two contain pressure and pressure depth in Pa. Their genuine monthly-data producer and work arrays must remain live through the last reader. Each active profile and field keeps its complete declared bounds, alignment and units from the original interface. Optional stochastic input remains opaque under the selected disabled switch.

The three-dimensional route interpolates each of the thirteen fields in latitude and longitude at all sixty source levels. It then sums layer masses in source order, interpolates the cumulative mass to the model pressure boundaries, and subtracts neighbouring cumulative values to recover model-layer mass. Cumulative mass is the total above a pressure boundary. Air-layer mass per square metre is pressure depth divided by gravitational acceleration. Division by this air-layer mass gives the mass mixing ratio in kg/kg. The final source pressure interval supplies the original extrapolation case. The final species remains positive zero. All FP64 dependencies, separate operations and rounding points remain unchanged.

Boundary temperatures `PTH` must be finite and nonzero. The original twelve-point input interpolation can overshoot and produce negative temperatures. Keep the source temperature ratio and exponentiation without clipping these values. The observed case uses the even exponent `RCTRPT=30`, for which the unchanged POWER provider supports the finite negative ratio. A negative temperature in kelvin is outside the physical domain. This check preserves source behaviour and does not establish that such a temperature is physically valid.

One private allocation uses $`P(96L+12320)`$ bytes within a caller budget of at most 64 MiB. Set the child’s budget to the smaller of the parent’s remaining allocation budget and 64 MiB, which is 67,108,864 bytes. The maximum supported request is 62,947,328 bytes, so every supported shape fits this limit. Keep the parent’s full budget for its other children. The eight-column, 137-layer case needs 203,776 bytes. The 4,096-byte frame is aligned to 16 bytes and preserves x18 and all Arm saved registers. Success returns zero, allocation failure returns one, and an admission refusal returns two. Initial refusals and allocation failure preserve output bytes. Every successful call frees its private allocation. FPCR must be zero and remains unchanged. FPSR and errno retain the source-defined effects.

The focused check passes three source/native pairs at eight columns and 137 layers with first and final partial groups, and at three columns and five layers with pressure beyond the final source bracket. All 335,464 complete output bytes match. Independent mass, positivity and floor relations pass, along with three prewrite refusals, complete borrowed-input guards, immediate machine state and allocation cleanup. The retained source and mathematical checks cover the unchanged earlier branch. A separate caller-budget check covers seven capacity values, exact Fortran and assembly output agreement, and an insufficient-budget refusal. This is component acceptance. Genuine radiation-parent and complete forecast agreement remain pending.

One further original/assembly pair uses eight columns and 137 layers, with all eight scientific input arrays and active controls taken from the observed negative-temperature case. The thirteen complete CAMS arrays (45,676,800 bytes) and nine profile arrays (9,936 bytes) remain controlled verification inputs, rather than captured forecast data. All 166,592 output bytes match, all 45,917,860 read-only bytes remain unchanged in each call, and 20,912 independent mass and sign relations pass in each call. The zero top pressure keeps the existing mass check within its declared domain. Raw floating-point flags and `errno` agree. The original void return is ignored, and the native status and ABI pass. This source-compatible component result does not establish physical validity for negative temperatures or complete forecast acceptance.
