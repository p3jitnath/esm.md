# Shortwave Cloud Solver Contract

Revision 1 preserves the complete forecast-configured `radiation_mcica_sw::solver_mcica_sw` body. Use [the physical input](../../../../../formulations/openifs/physics/shortwave_cloud_transport.md), P01 and P02. A spectral sample represents part of the radiation spectrum. Reuse the accepted [layer coefficients](calc_two_stream_gammas_sw.md), [layer reflection and transmission](calc_reflectance_transmittance_sw.md), [vertical adding](adding_ica_sw.md) and [complete cloud generator](cloud_sampling.md).

## Domain and Update

Support 1 to 512 layers, 1 to 4096 spectral samples and a complete selected column range. Contiguous input and mutable output owners retain their genuine GNU Fortran derived-type layout and start at label 1. Clear-sky calculations are enabled. The complete cloud generator supports exponential-random overlap, scheme 1, with its accepted cloud, PDF and power domains. The cloud-band map selects a valid band for every sample. Consumed optical depths and incoming sample fluxes are finite and lie between zero and 1,000,000, while scattering and surface reflection fractions lie between zero and one. Consumed direction factors lie between zero and 0.999999, which keeps the delta denominator positive after component mixing. The nonnegative PDF table has finite entries at most 1,000,000, at least two points per axis and finite signed-integer interpolation coordinates. Unused nighttime optical and solar inputs can retain arbitrary bits.

For each daylight column, calculate every clear layer and the complete clear vertical flux. The optional gas-inclusive delta correction uses `f=RN(g*g)`, `d=RN(1-RN(omega*f))`, `tau=RN(tau*d)`, `omega=RN(RN(omega*RN(1-f))/d)` and `g=RN(g/RN(1+g))`. Require a positive denominator and supported asymmetry above -1. Every RN marks separate FP64 rounding.

Sum spectral fluxes in increasing sample order from positive zero. Downward broadband flux is the separately rounded sum of diffuse and direct totals. Save the complete clear surface spectra. Copy each strided cloud row into parent-owned contiguous arrays, then call the complete generator with its unchanged seed, PDF, overlap and optional beta semantics.

When total cloud cover meets the threshold, calculate every cloudy layer. Multiply its sampled scale by cloud optical depth. Add gas depth, then apply P01 with original left-to-right products and separately rounded positive denominators. Clear layers copy all five clear transport properties. Apply the configured delta correction and complete accepted transport children. Sum the cloudy spectrum and apply P02 with two products and one addition, preserving `RN(1-c)`. Weight both surface spectra in the same way. For no cloud, copy clear results. For night, zero all ten shortwave owners while preserving incoming cloud-cover bits.

## Interface and Mutation

The Arm ABI has sixteen addresses. Registers x0 to x7 contain layers, first and last column, configuration, single-level object, cloud object, gas optical depth and gas scattering fraction. Eight stack addresses contain gas direction, cloud depth, cloud scattering fraction, cloud direction, direct albedo, diffuse albedo, incoming sunlight and the mutable flux object.

Optical arrays have sample or band first, layer second and selected column last. Broadband flux owners have full column first and boundary second, including H+1 boundaries. Surface spectra have sample first and full column second. Cloud cover has full column only. The all-sky direct owner can be absent. If it is present, its clear counterpart must also be present. All other used owners are allocated, disjoint and aligned to their element type. Unselected cells, output tails, metadata and every input owner remain unchanged.

Parent-owned scratch contains clear and cloudy layer properties, complete spectral fluxes, cloud scales, mixed properties, coefficients, cloud rows and repeated solar direction. No driver supplies a numerical stage. Preserve x18, x19 to x29, low halves of v8 to v15, stack alignment and FPCR zero. No fused operation, approximate instruction, contraction, reassociation or reduced precision is permitted.

## Acceptance

Before emission, independently check component optical and scattering balances, delta identities, broadband sums, area-weighted fluxes, cloud cover, surface spectra, night and no-cloud limits. Reuse accepted child science and scalar-math proofs. One protected verifier compares complete mutable owners with the unchanged source and checks readonly owners, selected ranges, optional outputs, bounds, the immediate sixteen-address ABI and FPCR. Require zero differing bytes before the paired forecast relay.

The original and direct bodies each pass 48 protected cases over 729,312 returned owner bytes with zero differences. Independent checks pass 846,208 parent relations, including 799,380 mixture relations. Night checks cover 15,248 exact positive zeros, and 211,968 inactive bytes remain unchanged. The focused immediate ABI check passes two calls over 5,088 bytes. One zero-depth case and one empty-column case each pass 2,544 bytes with the same register and bounds checks.

Four paired calls pass 9,792 allocated returned-owner bytes and 744 independent surface, inlet and cloud-area relations. They include clear and cloudy columns, both delta settings and absent direct outputs. One additional paired case preserves arbitrary unused nighttime optical bits while passing 2,544 bytes and 166 returned relations. Local readiness records remain under mcica_shortwave_7240564. Actual forecast acceptance and comparative timing remain pending.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| radiation_mcica_sw::solver_mcica_sw | 6,400 | 233,062,400 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
