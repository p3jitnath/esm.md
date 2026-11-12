# Atmospheric Planck Function Contract

The [physics input](../../../../../formulations/openifs/physics/atmospheric_thermal_emission.md) describes emitted longwave flux at layer boundaries. The original entry is radiation_ifs_rrtm::planck_function_atmos. Reuse the independently checked Planck tables and fixed ASIN(1) value shared with the surface emission routine. Keep every ordinary and reordered spectral calculation.

## Inputs And Table Meaning

Support 0 to 4096 selected columns, positive first-column labels and 1 to 512 model layers. The configuration supplies 1 to 140 spectral samples and 1 to 16 bands. Consumed map values select existing bands and gas-fraction samples. The ordinary mode uses its band map and sample number. Spartacus, whose solver code is three, uses its reordered band and sample maps. Other solver codes retain the original ordinary mode.

The temperature owner stores all columns and half levels, which are the boundaries between layers. Each consumed temperature is finite and between zero and 4096 K. Its descriptor has unit column stride, a positive full-column pitch and sufficient bounds for every selected column and the last layer count plus one half levels. Unused thermodynamic owners and unused spectral maps can be absent. Consumed gas fractions are finite and from zero to one. Their unconsumed cells need not be finite. Outputs and inputs have disjoint complete capacities.

The table has 181 temperatures from 160 to 340 K at one-kelvin intervals and sixteen bands. DELWAVE supplies the original nominal band widths in inverse centimetres. TOTPLNK is the original mean spectral radiance in watts per square centimetre per steradian per inverse centimetre. Its band sixteen represents the integral from 2600 inverse centimetres to infinity, divided by the nominal width. It is not truncated at 3250. Preserve all empirical values without normalisation.

## Ordered Emission

Let RN mean one separately rounded FP64 result. Compute the fixed scale as $`Z=\operatorname{RN}\{\operatorname{RN}[2\,\operatorname{ASIN}(1)]\,10^4\}`$. The ASIN operand is exactly one, and its independently qualified result is the original FP64 word. No continuous inverse-sine approximation is introduced.

For $`160\leq T<339`$, the one-based table index is INT(RN(T−159)), and the fraction is RN(T−INT(T)). For $`T\geq339`$, use index 180 and RN(T−339), retaining the original linear extension beyond the last interval. For $`T<160`$, use index one and positive-zero fraction, retaining the original lower-temperature cap.

For each band, compute factor RN(Z×DELWAVE). Subtract the two adjacent table entries, multiply the difference by the fraction, add the lower entry and multiply by the factor. Multiply that rounded band flux by the selected gas fraction for the output. Keep each operation and its intermediate rounding. The direct body can repeat identical band arithmetic for different samples because its operands and rounded results are identical.

Select the last supplied model-layer count plus one temperature boundaries from the descriptor's upper level label. Output boundary one uses gas layer H. Each later boundary j uses gas layer H+2−j. Thus the top two boundaries use the top gas layer. Ordinary mode retains sample order, and Spartacus applies both original maps. Outputs store samples, then boundaries, then selected columns.

Use FP64 with round-to-nearest, ties to even, gradual underflow and preserved signed zeros. FPCR is zero. Forbid fused operations, contraction, reassociation, reduced precision and approximate arithmetic.

## Seven-Address Interface

The [assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/planck_function_atmos.S) exports md2asm_planck_function_atmos and the original GNU module entry. Arguments x0 through x6 address model layers, first column, last column, configuration, thermodynamics, gas fractions and emitted flux. Integers use four-byte words. The two explicit-shape arrays use raw eight-byte aligned FP64 pointers.

The genuine GNU configuration is 20040 bytes. Its solver code is at byte 624, spectral count at 20000 and band count at 20008. Its rank-one integer descriptors are at 10608 for ordinary bands, 10864 for reordered bands and 10736 for reordered samples. Consumed descriptors have lower label one, unit stride, sufficient upper labels and offset minus one. Their elements use four bytes.

The thermodynamics object is 264 bytes, with its 88-byte temperature descriptor at byte 88. The descriptor stores data pointer, element offset, element size, span and two dimension triples. Each triple gives stride, lower label and upper label. Preserve shifted lower labels and derive each consumed address from the complete descriptor. The fixture independently checks this construction with nonunit lower labels.

Use a fixed 224-byte, sixteen-byte aligned frame. Preserve x19 through x29, return address, x18 and low halves of v8 through v15. No numerical helper, allocation or driver supplies a calculation. Inputs remain unchanged, and only the complete output owner is written.

## Focused Acceptance

Before emission, 24 protected original calls pass 36,933,664 complete returned bytes, 4,616,708 independent spectral emission relations and 529,492 band-energy partition relations. Cases cover zero columns, one and odd column counts, shifted labels, partial spectral ranges, both solver modes, absent unused maps, 512 layers, 4096 columns, interval edges, capped temperatures, upper extrapolation and both guarded placements. Inputs are read-only.

The unchanged shared table proof matches all 2896 literal words and sixteen widths. Independent all-band blackbody integrals meet the frozen relative limit of 0.0005, including the independently checked high-frequency tail in band sixteen. The fixed ASIN(1) word is checked at 150 decimal digits. Reuse these proofs without another table audit.

Require zero different complete output bytes, independent emission and partition relations, protected bounds, unchanged input owners, immediate seven-address ABI checks and a paired original/native adapter. Local records are under .runtime/openifs/planck_atmosphere_7240564/. This helper is outside the weather-routine queue. The complete gas_optics caller supplies its actual forecast acceptance. No timing or forecast acceptance is claimed here.

The direct body passes the same 24 protected calls, all 36,933,664 complete bytes and all original emission and partition relations with zero differences. Two focused calls pass the immediate ABI and paired adapter checks over 3,264 bytes, 408 emission relations and 72 band partitions. The object has no numerical helper calls, fused operations or approximate instructions. These checks establish readiness for its complete gas_optics caller.
