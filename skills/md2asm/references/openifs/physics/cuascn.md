# Complete CUASCN Contract

Revision 1 implements [Moist Cloud Ascent](../../../../../formulations/openifs/physics/moist_cloud_ascent.md), equations CA-1 and CA-2, from the complete original `arpifs/phys_ec/cuascn.F90` body. The accepted domain uses normal physics with LPHYLIN false. Its linearized TANH branch is outside this domain. Original physical checks pass before direct assembly emission.

## Ordered Update

Initialize all selected columns and levels, preserving condensate at cloud base. Keep the original deep, shallow and midlevel flags. Visit levels KLEV minus one down to 3. Call complete accepted [CUBASMCN](cubasmcn.md), [CUENTR](cuentr.md) and [CUADJTQ](cuadjtq.md) assembly children with the full original owners. Preserve the shared work flag across all columns and levels. Mode 1 performs mixed-phase parcel condensation, while mode 6 permits the configured liquid-only shallow cloud.

Apply the original entrainment and detrainment limits, pressure and timestep mass cap, transported-energy and water update, 100 to 400 kelvin pre-adjustment temperature bounds, and reset below the departure level. Preserve the stochastic ENTRORG, ENTSHALP and RPRCON selections. Each selected factor uses the separately rounded XMAG times random value, addition of MU, strict EXP and multiplication by the source coefficient.

Phase changes warm the parcel through the original glaciation term. Update buoyancy, provisional environmental face fields, parcel kinetic energy, organized entrainment and the cloud-top stopping test in source order. Preserve the midlevel activation threshold, cloud-top overshoot condition, shallow-cloud stopping branch and all returned detrainment diagnostics.

Rain formation uses the original condensate threshold, parcel-speed limit, mixed-phase enhancement and aerosol threshold. Preserve both analytic exponential updates and the 0.005 condensate cap. Rain removal uses the original POWER exponent 0.2 and its phase-dependent fall speed. Rebuild dry-energy, vapour and condensate fluxes, then split detrained condensate into liquid and ice. Finish the pressure-weighted mean parcel speed and cloud-level flags.

Each primary multiplication, addition, subtraction and division rounds separately in FP64, with round to nearest and ties to even, gradual underflow, signed zeros and FPCR zero. No fused floating-point instruction or reassociation is allowed. EXP uses the unchanged [strict elementary-function route](../pressure_math.md). Fractional POWER uses the [original-compatible opaque primitive](../power_math.md), whose documented internal single rounding does not change the primary solver arithmetic. No high-level child supplies a numerical stage.

## Interface and Bounds

The GNU Arm application binary interface passes 52 addresses. The first eight arrive in x0 through x7 and the remaining 44 use consecutive eight-byte caller-stack slots. Four-byte integers represent indices and logical flags. Real elements are FP64 and require eight-byte alignment.

| Addresses | Arguments |
|---|---|
| 0–4 | YDEPHLI, YDECLDP, YDECUMF, YDSPP_CONFIG, YGFL |
| 5–9 | KIDIA, KFDIA, KLON, KLEV, PTSPHY |
| 10–17 | PTENH, PQENH, PUEN, PVEN, PTEN, PQEN, PQSEN, PLITOT |
| 18–24 | PGEO, PGEOH, PAP, PAPH, PVERVEL, PWUBASE, PGP2DSPP |
| 25–29 | LDLAND, LDCUM, KTYPE, KLAB, LSCVFLAG |
| 30–36 | PTU, PQU, PLU, PLRAIN, PMFU, PMFUB, PLGLAC |
| 37–44 | PMFUS, PMFUQ, PMFUL, PLUDE, PLUDELI, PDMFUP, PLCRIT_AER, PDMFEN |
| 45–51 | KCBOT, KCTOP, KCTOP0, KDPL, PMFUDE_RATE, PKINEU, PWMEAN |

The complete returned owners are addresses 10, 11, 26 through 42, 44 through 47 and 49 through 51. PUEN, PVEN and LDLAND retain their original interface positions but have no numerical consumer. YGFL supplies only NACTAERO at byte 112 and is not passed to a child. Existing metadata proofs cover its 1,359,136-byte type and the unchanged 120-byte TEPHLI, 2776-byte TECLDP, 344-byte TECUMF and 3192-byte TSPP_CONFIG objects.

Support 1 to 4096 columns, 4 to 1024 levels and a valid possibly empty selected interval. Arrays have columns next to each other. Full-level matrices contain KLON × KLEV elements and face matrices KLON × (KLEV + 1). PLUDELI has two complete species planes. Column vectors have KLON elements. Complete returned owners are disjoint from each other and consumed immutable inputs. Compare untouched cells and columns as well as changed values.

The newly read TECUMF fields are ENTSHALP at byte 8, RMFCMIN at 120, RPRCON at 144 and LSCVLIQ at 280. Reuse RMFCFL at 56 and LMFGLAC at 276. The TECLDP aerosol flags are at 1112 and 1116. Parent stochastic selections are at SPP bytes 492, 496 and 508, with the unchanged CUENTR selection at 504. PN uses contiguous 184-byte records, genuine lower bounds, at most 128 records and at most 512 random fields. Every positive selected record and random-field index must be in bounds.

Consumed pressure, temperature, water and parcel data must satisfy the reused child and math limits. Pressure and layer height are ordered, the timestep and required division denominators are positive, transported water and mass are nonnegative, and fractional POWER bases are positive. The exact negative quiet-NaN word `fff8000000000000` is accepted for the demonstrated unused top-level placeholders. Preserve those bits and claim no physical balance for missing cells.

The entry preserves x18, x19 through x29 and the lower 64 bits of d8 through d15, with 16-byte stack alignment. A 2048-byte fixed frame and a 256-byte outgoing-call area accompany scratch storage of 8 × KLON × KLEV + 76 × KLON bytes, rounded up to a multiple of 16. Scratch contains one buoyancy matrix, eight FP64 column vectors and three four-byte logical column vectors. There is no heap allocation in the numerical body. The public entry `cuascn_` can be renamed with `CUASCN_SYMBOL` when assembling its private closure.

## Actual Checks

Independent checks cover nonnegative transported mass, water and rain, dry-energy and water flux relationships, liquid-plus-ice detrainment, source-limited pressure and timestep caps, and positive mean speed for active parcels. Exact rational residuals carry the declared FP64 rounding budget. Accepted child proofs remain unchanged.

| Check | Cases | Complete returned bytes | Result |
|---|---:|---:|---|
| Original independent physics | 30 | 3,595,152 | 370,520 independent relations |
| Protected native calculation | 60 | 7,190,304 | 741,040 relations and zero byte differences |
| Immediate register and stack interface | 6 | 52,908 | Preserved registers, bounds and FPCR |
| Invalid input admission | 8 | 68,448 shared bytes | Rejected before output change |
| Paired complete-owner relay | 10 | 76,624 | Zero byte differences |
| Profiling and unused top placeholders | 2 | 17,636 | Four canonical missing output words and zero byte differences |

The protected corpus covers deep, shallow, midlevel and inactive columns, glaciation, liquid-only adjustment, all aerosol threshold branches, stochastic parameters, rain formation and removal, small and maximum shapes, cropped ranges and empty ranges. Thirty-nine consumed POWER operand pairs match the original bits and pass an independent 160-digit accuracy check. Public and private builds have identical numerical machine text and contain no fused or approximate instruction.

Checks run on job 7240564, nid010555, CPU 64 with local memory. The composable relay runs the original on cloned complete outputs, compares every returned byte and returns assembly bytes to the caller. Original profiling hooks remain active. The report uses `MD2ASM_CUASCN_REPORT`. Actual forecast acceptance and comparative performance remain pending.

The exterior top pressure face can be zero. All interior face pressures remain positive and ordered. The source uses this exterior face only in a positive pressure thickness and does not divide by it. The retained 24-column and 19-layer pressure and geometry owners, combined with accepted remaining inputs and constants, pass 68,448 complete original/native/paired output bytes and 21,096 physical relations. Negative exterior pressure and zero interior pressure are rejected before changing 136,896 shared output bytes. The numerical body and its complete children are unchanged.

A trial parcel is a small volume of air used to test whether a cloud can rise to the next level. Above the accepted cloud top, an unaccepted trial has parcel label KLAB equal to zero and can retain finite negative condensate PLU with a consistent signed preliminary condensate flux PMFUL. The original downdraft and closure calculations exclude that level. CUFLXN clears its mass and transport fluxes before the atmosphere is updated, while the raw PLU at cloud top minus one remains observable. The verifier admits finite negative PLU only when KLAB is zero and the level lies strictly above KCTOP, the accepted cloud top. Active condensate, rain, mass and detrainment remain nonnegative, and all mass times parcel-property relations retain their independent checks. The complete returned storage, including the signed trial value and flux, is compared without changes.

Actual source call 219 retained PLU equal to -0.00012069309216993807 at column 5, level 14, above cloud top 15. Its mass and condensate flux were nonzero and passed the independent carrier relation. The unchanged native body reproduced 136,896 complete bytes across two protected placements with zero differences. Focused paired replays of calls 32 and 219 passed 136,896 complete bytes and 12,310 independent driver relations with zero differences. A negative value in an accepted cloud cell was still rejected before changing 68,448 output bytes. This correction changes the source-output admission check; the numerical body, its complete children and the physical error budgets remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cuascn | 4,300 | 223,944,000 | Native private convection child, compared complete convection-parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
