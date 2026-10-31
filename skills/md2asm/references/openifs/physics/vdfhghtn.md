# Complete VDFHGHTN Contract

Revision 1 implements [Boundary-Layer Height](../../../../../formulations/openifs/physics/boundary_layer_height.md) as the complete normal-physics VDFHGHTN body. The source is OpenIFS `arpifs/phys_ec/vdfhghtn.F90`. Original physics passes before direct assembly emission. The weak cloud-base call and alternative inversion-strength call have immutable false conditions in this source and contribute no numerical stage.

## Ordered Calculation

Initialize the selected columns, then form the Richardson number from the dry-static-energy difference, humidity difference, geopotential difference and squared horizontal wind differences. Preserve the 0.01 wind-shear floor and each source rounding point. SATUR calculates saturation humidity from level NJKT2 downwards. Complete CUININ and CUBASEN children initialize parcel states and perform the stronger, mixed cloud-base ascent. Each child is assembly and retains its accepted arithmetic and physical checks.

Convert surface heat and humidity fluxes using the ordered density denominator RD times temperature, then times the humidity correction. Return parcel energy as moist heat capacity times temperature, plus geopotential, minus phase-dependent latent heat times condensate. Return total water as vapour plus condensate. The final face copies the preceding energy and water and the environmental bottom wind, with zero mass flux.

The sign of virtual-temperature surface flux determines whether the column is convective. The source sign convention makes a negative value convective. Inversion strength uses the maximum of the two supplied energy differences divided by heat capacity. Scan parcel kinetic energy from the bottom towards the top, retaining the Richardson-number limit of 50. Return category 0 for stable air, 1 for dry convection, 2 for shallow cloud and 3 for air below deeper convection. Preserve the cloud-depth and inversion-strength tests, cloud-top adjustment, NJKT5 height cap and inversion-index floor.

For a dry convective column, preserve the two fractional POWER calls with exponents 0.33333 and 0.5. These use the [original-compatible opaque POWER boundary](../power_math.md). They retain the original external function result and its documented internal single rounding. This does not change the separately rounded solver arithmetic. The mass cap is three times the adjacent pressure difference divided by gravity times the timestep. The downward level scan uses the original quadratic height profile and entrainment-dependent implicit wind update. This update has a checked momentum residual and is not assumed to be a convex average.

All primary calculations use FP64, round to nearest with ties to even, preserve signed zeros and gradual underflow, and require FPCR zero. Each solver multiplication, addition and division rounds separately. No fused floating-point instruction, approximate arithmetic, reassociation or high-level numerical child supplies a missing stage. The accepted [strict EXP route](../pressure_math.md) remains unchanged.

## Interface and Storage

The GNU Arm application binary interface passes 40 argument addresses in this order. The first eight use x0 through x7 and the remaining 32 use consecutive eight-byte caller-stack slots.

| Addresses | Arguments |
|---|---|
| 0–4 | YDEPHLI, YDECLDP, YDECUMF, YDVDF, YDSPP_CONFIG |
| 5–10 | KIDIA, KFDIA, KLON, KLEV, PTMST, LDLAND |
| 11–16 | PTM1, PQM1, PSLGSM1, PUM1, PVM1, PCPTGZ |
| 17–25 | PAPHM1, PAPM1, PGEOM1, PGEOH, PBLH, PKMFL, PKHFL, PKQFL, PGP2DSPP |
| 26–31 | PKHVFL, PMFLX, PSLGUH, PQTUH, PUUH, PVUH |
| 32–39 | PZINV, KINV, KCLDBASE, KCLDTOP, PZCLDBASE, PRI, PEIS, KPBLTYPE |

Addresses 26 through 39 are the complete returned owners. KINV, KCLDBASE, KCLDTOP and KPBLTYPE contain four-byte integers. Every other numerical owner contains eight-byte FP64 values. Fortran storage places columns next to each other. Full-level matrices have KLON times KLEV elements. Half-level matrices have KLON times (KLEV + 1) elements and use the original level bounds 1 through KLEV plus one. Compare every returned byte, including unselected columns and untouched cells.

Reuse the accepted 120-byte TEPHLI, 2776-byte TECLDP, 344-byte TECUMF, 72-byte TVDF and 3192-byte TSPP_CONFIG layouts. The new parent fields are NJKT3 at byte 316, NJKT5 at 324, NJKT6 at 328 and REISTHSC at TVDF byte 56. Stochastic perturbation means a configured variation of a physical parameter. Its complete PN owner has 184-byte records, contiguous stride one and genuine lower and upper bounds. Preserve shifted lower bounds and the original zero or negative selections.

Real pointers require eight-byte alignment and integer pointers four-byte alignment. Consumed inputs and returned owners are disjoint, and returned owners do not overlap each other. LDLAND and the unused alternative PBLH value have no numerical consumer. PBLH can therefore share a returned height owner. PGP2DSPP is consumed only when stochastic perturbations are enabled.

The entry preserves x18, x19 through x29 and the lower 64 bits of d8 through d15, with a 16-byte stack boundary. It uses a fixed 2048-byte frame and a temporary arena of 256 + 200 × (KLEV + 1) + 8 × NRFTOTAL bytes, rounded up to a multiple of 16. It streams one column through complete accepted SATUR, CUININ and CUBASEN children. No heap allocation supplies a numerical stage. The public entry is `vdfhghtn_` and `VDFHGHTN_SYMBOL` can rename it when assembling a private closure.

## Supported Domain and Evidence

Support 1 to 4096 columns, 2 to 1024 levels, a valid possibly empty selected interval, positive finite timestep and normal physics with LPHYLIN false. All configured sample and height-cap indices must be in range, with NJKT2 below the last level. Pressures are positive and ordered towards the ground. Face geopotential is finite, nonnegative and decreases towards the ground. Humidity is finite between zero and one, wind is finite, and momentum surface flux is nonnegative. Required division denominators and fractional-power bases must satisfy the unchanged child contracts.

The accepted SATUR child consumes temperatures from NJKT2 through KLEV and requires 160 to 330 kelvin there. Before NJKT2, the exact canonical missing-temperature word `fff8000000000000` can represent an unused upper-level placeholder. Preserve its returned bits. Missing temperatures inside the SATUR-processed range are outside the supported physical domain and reject before output mutation. No heat or momentum balance is claimed for missing cells. Finite parent energy, total-water, Richardson-number, mass-cap, height-cap and implicit momentum checks remain independent of source-to-assembly byte comparison.

| Check | Cases | Complete returned bytes | Result |
|---|---:|---:|---|
| Original and native protected physics | 40 | 2,117,040 | 182,128 independent relations and zero byte differences |
| Missing-placeholder and perturbation edges | 5 | 15,640 | Eight canonical missing output words and zero byte differences |
| Immediate register and stack interface | 6 | 19,808 | Preserved registers, bounds and FPCR |
| Invalid shapes or metadata | 8 | 24,000 shared bytes | Rejected before output change |
| Paired relay smoke | 7 | 23,128 | Zero byte differences |
| Profiling and unused-input alias | 2 | 6,320 | Zero byte differences |
| Consumed missing-temperature rejection | 1 | 3,320 shared bytes | Rejected at the inherited SATUR domain before output change |

The corpus covers all four returned layer categories, cropped and empty selections, small and maximum shapes, dry mass transport, its profile and the timestep cap. Nine newly consumed POWER operand pairs match the original result bits and pass an independent 160-digit accuracy check. Accepted child proofs are reused. Public and private entry builds have identical numerical machine text, with no fused or approximate instruction.

Checks run on job 7240564, node nid010555, CPU 64 with local memory placement. The paired relay preserves original profiling hooks and its immutable input state, runs the original on cloned complete outputs and returns native output bytes to the caller. Its live report uses `MD2ASM_VDFHGHTN_REPORT`. The actual forecast gate and comparative performance remain pending.

The exterior top face can have zero pressure because it marks the top boundary of the atmosphere. Every interior face and every full-level pressure remains positive. The captured 24-column, 19-level forecast call had zero top pressure in all columns, and the unchanged original and assembly returned 24,000 identical bytes. The focused relay check retained the inversion-height and mass-flux bounds, and rejected negative top pressure and zero interior pressure before changing 48,000 output bytes across two rejected calls. All earlier complete numerical and interface proofs remain valid because the assembly body is unchanged.

The complete private CUBASEN child uses the verified exterior-bottom-face pressure address in its departure test. One replay of the captured 24-column and 19-layer parent call returns 24,000 identical bytes after this child correction. The parent instructions and the remaining child proofs are unchanged.

A separate integer counter records completed calls to the unique native CUBASEN child and the full sizes of its returned owners. These sizes describe storage. Exact byte agreement comes from the compared complete parent outputs and the independent complete child verifier.

The minimum wind difference is 0.1 m/s. The source squares its FP64 value to obtain the minimum squared shear, which is `0x3f847ae147ae147c`, or 0.010000000000000002 m²/s². A focused forecast-call replay checked this stored value against the independent Richardson-number balance and compared all returned owners. Both protected buffer placements passed with 48,000 compared bytes and zero differences, and the profiling-enabled paired call passed with 24,000 compared bytes. The source and native calls used the same qualified exponential function. The complete numerical children and their interface proofs are unchanged.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vdfhghtn | 2,150 | 51,600,000 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
