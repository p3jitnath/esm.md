# Selected Longwave Cloud Solver Contract

This contract defines complete direct assembly for the selected coarse-forecast longwave calculation. All eight numerical children are accepted. The parent passes a genuine protected replay, five critical branch cases and three before-write rejection cases.

## Selected Inputs And Branches

The original entry is `__radiation_mcica_lw_MOD_solver_mcica_lw`. Its 16 pointer arguments are layer count, first column, last column, configuration, single-level state, cloud state, gas optical depth, aerosol scattering fraction, aerosol asymmetry, cloud optical depth, cloud scattering fraction, cloud asymmetry, boundary emission, surface emission, surface reflectivity and flux state, in that order.

The supported route starts at column 1 and ends at a column from 0 through 8, with 0 defining empty work. The genuine route processes all eight columns, 19 layers, 140 spectral points and 16 bands. Clear radiation, cloud scattering and surface derivatives are enabled. Aerosol scattering is disabled. Overlap uses scheme 1, the beta option is false, the cloud threshold is $`10^{-6}`$ and the decorrelation scale is 0.5. Guard the declared branch before parent writes. An additional branch needs its complete numerical children and new source evidence.

Use qualified original-type member positions and array descriptors from `layout.json`, the accepted shortwave layout and genuine capture. A descriptor stores the address, element type, bounds and spacing of an array. Retain its rank, lower bounds, element size and strides. Never use stale captured pointer addresses.

The complete genuine packet has 30 owners and 1,467,596 bytes. Its eight mutable flux arrays own 24,384 bytes. The remaining 1,443,212 bytes are read-only. Configuration, single-level, cloud and flux structures contain 20,040, 624, 792 and 3,360 bytes. Their descriptor words remain unchanged.

## Complete Source Order

For each column, calculate clear transmission and emission for every layer, then use accepted clear vertical transport. Set clear reflection to positive zero. Sum each spectral profile in increasing spectral-point order and store the clear downward surface spectrum. Interleave four independent boundary sums to keep their additions in progress together. Each sum still starts at positive zero and performs the same 140 additions in the same order. The 20 boundary sums retain their original private output locations.

Copy the strided cloud fraction, spread and overlap rows for the accepted complete cloud generator. Supply the original seed plus 997 and retain its qualified random numbers, probability table, overlap and power calculations. Store total cloud cover.

For each cloudy layer, multiply sampled scaling by band cloud depth, then add gas depth. Initialise scattering and asymmetry to positive zero. Where total depth is positive, divide cloud scattering depth by total depth. Where scattering depth is positive, divide the left-to-right cloud asymmetry product by that scattering depth. Preserve both divisions and all intermediate rounding. Call the accepted coefficients and complete conditional layer. Copy all four clear arrays for each clear layer.

Call accepted fast cloudy transport. Sum cloudy spectra in increasing order, then apply cloud cover and the separately rounded one-minus-cover value to form all-sky profiles and surface spectra. Calculate the cloudy derivative, adding the accepted clear contribution only below one minus the cloud threshold. The genuine packet has six such modifications and two near-one skips. If the column is unclouded, copy all clear outputs and calculate its clear derivative.

The selected children are `calc_no_scattering_transmittance_lw`, `calc_fluxes_no_scattering_lw`, `cloud_generator`, `calc_two_stream_gammas_lw`, `calc_reflectance_transmittance_lw`, `fast_adding_ica_lw`, `calc_lw_derivatives_ica` and `modify_lw_derivatives_ica`. Bind accepted native entries directly. No driver supplies an omitted stage. General `adding_ica_lw` is outside the selected branch.

## Storage And ABI

For $`G`$ spectral points and $`L`$ layers, numerical scratch needs $`8(13GL+10G)`$ bytes. The genuine shape needs 287,840 bytes of numerical scratch and 24,384 bytes of private outputs in one 312,224-byte allocation. Cloud rows and flags use the 2,048-byte aligned stack frame. Copy outputs to the caller only after every selected column completes.

The Arm application binary interface, ABI, passes arguments 0 through 7 in `x0` through `x7` and arguments 8 through 15 in eight-byte slots at the entry stack pointer. Keep 16-byte stack alignment. Preserve `x18`, required saved general registers and saved vector-register portions. Supply every raw or descriptor child argument according to its accepted interface.

Data use FP64 elements except four-byte selectors, band indices and seeds. Spectral arrays store spectral point first, then layer and column. Flux profiles store column first and boundary second. Respect each complete owner, preserve inactive columns and descriptor words, and reject unsupported overlap between writable and read-only storage.

Retain the layer's finite capped domain, strictly positive absorption, rounded root product above its floor and thin nonnegative-energy condition. The original conservative thin-layer defect remains excluded. No arithmetic or tolerance changes are made. The accepted complete child forecast closes the actual call domain. The parent retains that unchanged child domain and its independent energy proof.

## Arithmetic And Checks

Use ordered FP64 arithmetic, round-to-nearest with ties to even, gradual underflow and preserved signed zeros. Disable fused multiply-add, reassociation, approximate operations and contraction. Preserve each product, division, sum and area-weight rounding point.

FPCR controls rounding, FPSR records arithmetic events and the mathematical library uses `errno` to record error status. Canonical outputs are every byte of the eight complete flux arrays. All read-only owners and descriptor words remain unchanged. The genuine original call enters with FPCR 0, FPSR 16 and `errno` 2, then returns with FPSR 24 and `errno` 34. Compare canonical bytes and fresh original/native status. Original comparison visits receive no primary native child credit.

The genuine boundary check uses exact rational arithmetic and the source-operation bound $`\gamma_n=nu/(1-nu)`$, with $`u=2^{-53}`$, plus gradual-underflow terms. It checks clear and all-sky ground energy, surface spectral sums, positive-zero top downward radiation and bounded derivatives. Accepted child energy proofs establish internal layer physics. Broadband accounting alone does not provide that independent proof.

Six protected original/native calls preserve 146,304 returned bytes with zero differences and pass 17,200 independent boundary and response relations. They cover the genuine cloudy packet, seven columns, one column, clear columns with unused optical NaN payloads, a cloud threshold tie and empty work. Both buffer edges, all read-only and inactive bytes, descriptors, ABI and immediate status pass. Three unsupported cases reject before writes, preserving 4,402,788 caller bytes and every private child counter. They cover the first-column selector, aerosol-scattering branch and a consumed descriptor bound.


## Direct Child Binding

The parent entry is `md2asm_solver_mcica_lw`, with the original module entry retained as a configurable alias. Assemble each accepted child source and rename its numerical entries to the private names below with `objcopy --redefine-sym`. Rename references as well as definitions, then link those objects directly with the parent using `-Bsymbolic-functions`. This changes symbol binding without changing accepted numerical instructions. The complete cloud generator uses its accepted cover, random-number, probability-table and column assembly units. Its probability sampler is the ordinary object at configuration byte 17,840, rather than a class descriptor.

| Accepted child entry | Private parent entry |
| --- | --- |
| `md2asm_calc_no_scattering_transmittance_lw` | `md2asm_mcica_lw_clear_layer` |
| `md2asm_no_scattering_lw_7240564` | `md2asm_mcica_lw_clear_fluxes` |
| `md2asm_cloud_generator` | `md2asm_mcica_lw_cloud_generator` |
| `md2asm_calc_two_stream_gammas_lw` | `md2asm_mcica_lw_gammas` |
| `md2asm_longwave_layer` | `md2asm_mcica_lw_layer` |
| `md2asm_fast_adding_lw_7240564` | `md2asm_mcica_lw_fast_fluxes` |
| `md2asm_calc_lw_derivatives_ica` | `md2asm_mcica_lw_calc_derivatives` |
| `md2asm_modify_lw_derivatives_ica` | `md2asm_mcica_lw_modify_derivatives` |

Keep the accepted elementary exponential, logarithm and power assembly boundaries in the link and preload context. These are mathematical helpers, with no OpenIFS numerical fallback. Source comparison uses the same elementary-helper dispatch. The normal verifier sends original parent child calls to the qualified original library and counts only completed private assembly children as native work.

## Accepted Forecast Calls

The earlier complete-parent qualification passed 6,400 genuine native calls and 156,057,600 complete returned bytes with zero differences. All ten saved forecast files agree across 618,140 bytes. Completed private child calls retain their accepted physics, exact-output and interface checks. The separate original parent remains a verification reference. The current [autonomous forecast](../input/standalone_weather_forecast.md) also owns the other selected stages in assembly.

## Ordered-Sum Update

The updated parent passes the retained genuine packet and five branch cases with zero differing bytes across 146,304 returned bytes. All read-only owners, inactive cells, descriptors, child counts, ABI and immediate status remain unchanged, and 17,200 independent boundary relations pass. Separate raw-profile checks cover signed values, cancellation, subnormal values and special floating-point words. The local helper changes only caller-saved registers whose old values are unused by all four callers. Its reads stay within each 22,400-byte spectral profile, and its stores stay within the original 1,280-byte profile owner. The joint forecast passes the complete state, saved-file and repeated timing checks reported in the [README](../../../../../README.md).
