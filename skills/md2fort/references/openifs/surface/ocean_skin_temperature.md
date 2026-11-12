# Ocean Skin Temperature Contract

The [physical note](../../../../../formulations/openifs/surface/ocean_skin_temperature.md) describes heat exchange in the upper ocean. This complete `VOSKIN_MOD::VOSKIN` replacement computes the cool-skin change and advances the warm-layer state, then returns their sum with sea-surface temperature. The source selects formulation C unconditionally. Its legacy formulation A is unreachable. Every active cool, warm and Langmuir branch is included.

## Inputs And Arithmetic

The declared column count is 1 to 512. A selected inclusive interval can be empty. Twelve immutable FP64 input arrays and one returned array are contiguous and use the GNU rank-one assumed-shape descriptor. Read-only input owners may share storage because the solver does not change them. The returned output owner is separate from every input owner and both metadata objects. Sea-surface and previous skin temperatures, gravity, heat capacity, latent heat and the von Kármán constant are positive, while time interval is nonnegative and planet scale is positive. All consumed values and intermediate results remain finite. Three source switches are independent. Langmuir mixing acts only inside an enabled stable warm-layer calculation.

Use round-to-nearest, ties to even, gradual underflow and signed zeros with FPCR zero. Each source addition, subtraction, multiplication, division, integer power and square root retains its FP64 rounding point. Real powers use the uniquely named accepted original-rounding POWER primitive. Exponential calls use the accepted strict scalar route. Neither is globally redefined for the original control. There is no fused instruction, approximation, contraction, reassociation or reduced-precision solver stage.

Some source constants have no kind suffix. The source reads those literals as default FP32, then promotes their exact values to FP64. Preserve that promotion for the melting point `273.16`, Rayleigh coefficient `0.23` and the three temperature-dependent water viscosity coefficients. Their precise values and units are retained in the local frozen record. The numerical body still computes entirely in FP64.

## Complete Update

First compute the scaled warm depth `3/planet_scale`, boundary-layer depth `1000/planet_scale`, air-to-water density ratio, three exponential solar-absorption terms, and the three warm-layer coefficients. Their operation order follows the original left-to-right expressions. The density-ratio power has exponent `1.5`. Air density is `1.2 kg m^-3`, water density is `1025 kg m^-3`, heat capacity is `4190 J kg^-1 K^-1`, and conductivity is `0.6 W m^-1 K^-1`.

When cooling or warming is enabled, calculate atmospheric buoyancy from sensible and latent heat fluxes. Nonnegative buoyancy supplies a convective wind-square correction through exponent `RN(2/3)`. Negative buoyancy supplies positive zero. Apply the squared wind floor `0.01`, calculate stress magnitude divided by air density, then multiply by the ratio of corrected to original squared wind. Its square root has floor `0.0001 m s^-1`. The water expansion coefficient is the larger of `1e-5` and `1e-5*(SST-273)`.

The cool branch computes the quadratic temperature-dependent viscosity, the complete Saunders and Rayleigh coefficient, and water friction-velocity squared. Net upward heat flux has a floor of `1 W m^-2`. Its buoyancy term has power `3/4`, while the wall-thickness factor uses `RN(-1/3)`. Multiply that factor by viscosity and divide by the water friction velocity. The solar absorption relation uses its complete exponential term and has floor `0.01`. Corrected cooling flux again has floor `1 W m^-2`. Cooling is negative thickness times that flux divided by conductivity.

The warm branch starts from previous skin temperature minus sea-surface temperature minus the computed cool change. Its forcing combines the absorbed solar flux and all other surface heat fluxes, divided by water heat capacity per unit volume. A positive initial warm state with negative forcing uses the original square-root cooling limit before forming dimensionless stability. Other states use the forcing directly.

Positive stability uses the complete rational profile correction `1+(5*z+4*z*z)/(1+3*z+0.25*z*z)`. With Langmuir mixing, form the wave number from the stress and clipped squared wave-drift magnitude, take power `1/4`, then take `RN(-2/3)` and clip the result to one through ten. Nonpositive stability uses `1/sqrt(1-16*z)` and mixing factor one. The complete warm update is the larger of zero and its old excess plus forcing times the original depth coefficient and time interval, divided by one plus the complete mixing coefficient times that interval. Finally add sea-surface temperature, warm change and cool change in that order.

## Interface And Output

The [assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/ocean_skin_temperature.S) exports `md2asm_ocean_skin_temperature` and `__voskin_mod_MOD_voskin`. Its twenty arguments are addresses. The first eight use `x0` through `x7`, and the remaining twelve use the incoming stack. Metadata uses the unchanged GNU `TCST` and `TEXC` layouts. Assumed-shape entry indices start at one and ignore the caller's actual lower-bound bias. Validate shape, switches and FPCR before writes.

The fixed aligned frame is 768 bytes. It preserves general registers `x19` through `x29` and the low halves of `v8` through `v15`, and leaves `x18` untouched. Scalar columns need no dynamic workspace. The canonical output is the complete native-endian FP64 skin-temperature owner, including untouched inactive columns. All input arrays, descriptors and metadata remain byte-identical.

## Physical Evidence

Before direct emission, the unchanged original passed 72 protected calls over 4,224 complete output bytes and 3,199 independent physical relations. Cases cover every switch combination, stable and unstable forcing, zero and finite wind, stress and wave drift, three positive planet scales, three time increments, partial intervals and changed actual descriptor lower bounds. Independent high-precision physics uses a cubic wall-thickness balance and the warm-layer heat balance. It expresses Langmuir mixing through an equivalent sixth-root ratio, rather than repeating the source's two real-power stages. The qualified scalar arithmetic proofs and unchanged surface metadata are reused.

The native gate passed the same 72 calls, 4,224 output bytes and 3,199 independent relations with zero differences. Two maximum-shape and empty-interval cases added 8,192 output bytes and 5,993 relations. Six immediate twenty-address ABI cases passed 336 bytes, and six paired cases passed the same complete bytes and 124 physical relations. No forbidden fused or approximate instruction occurs in the direct object. Count the routine only after positive genuine calls and zero differing saved forecast bytes. Controls, detailed values, protection tools and provenance remain under `.runtime/openifs/weather24h-ocean-skin-temperature/`. No measured speed increase or whole-forecast assembly claim is made here.

The focused input-sharing correction passed two source, native and paired placements, each with 112 complete returned bytes, 115 independent energy relations and zero differences. Wind components, previous and sea-surface temperatures, and wave components share input storage in these cases. A returned output alias rejects before changing any of 4096 shared bytes. The numerical body, earlier physical evidence and ABI checks are unchanged and reused. The corrected local adapter awaits the next actual forecast gate.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| voskin_mod::voskin | 2,150 | 73,065,600 | genuine_private_ocean_skin_execution_with_compared_complete_surface_postprocessing_parent_owners_and_unchanged_complete_child_exact_proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
