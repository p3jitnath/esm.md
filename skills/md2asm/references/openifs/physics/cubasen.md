# Complete CUBASEN Contract

Revision 1 implements [Convective Cloud Base](../../../../../formulations/openifs/physics/convective_cloud_base.md), equations C1–C4, as the complete original CUBASEN body. The original physical calculation passes independent checks before direct assembly generation.

## Ordered Parcel Calculation

Copy the incoming parcel temperature, humidity, liquid water and labels into local column storage. Clear surface-parcel squared speeds and each departure's CAPE. Build environmental dry static energy from the separately rounded heat-capacity product and geopotential addition.

Test departure levels from the lowest level upwards. The surface parcel uses density, heat and moisture fluxes, the square root of surface momentum flux, the original real power with exponent 3 and the original power with exponent 0.3333. Preserve the source's rounded constant 1.5 times RKAP, the 1.2 multiplier and the temperature and humidity excess floors. Stable surface columns do not lift at this stage.

Elevated parcels use their original bounded excesses. Within the lowest 6000 pascals, retain the descending three-level pressure-weighted mixture and its 5000 pascal stopping condition. The original temperature expression adds the excess after its static-energy conversion, including the separate excess already present in that energy. Preserve this complete heat input.

At each lifting level, preserve shallow reciprocal mixing or deep convex mixing, its humidity-ratio cube and the unit cap. Apply every configured positive SPP selection. SPP means a supplied random perturbation of a physical parameter. Its scalar EXP argument uses a rounded product before its addition.

Call the complete accepted [CUADJTQ mode 1](cuadjtq.md) with the same parcel temperature, humidity, pressure and active flag. Reuse its phase, two-correction saturation, latent-heat and missing-temperature proofs. No numerical stage is supplied by a driver or an unaccepted Fortran child.

Add condensation to cloud water, calculate the change in convective liquid fraction, remove half the liquid and add freezing heat. Form virtual temperatures, buoyancy, the two-level buoyancy average, kinetic energy and positive CAPE in their original order. Cloud-base detection retains both saturation exponentials, the original pressure and derivative calculations, the nearest-level tie rule and the configured liquid-water floor. Retain kinetic stopping, surface and shallow flags, deep-cloud selection, the complete field reset and maximum CAPE across departures.

Solver products and additions remain separately rounded. No fused floating-point instruction, reassociation, reduced precision or approximate division or square root is allowed. EXP reuses the accepted [elementary-function route](../pressure_math.md). The opaque [original-compatible POWER boundary](../power_math.md) retains its original internally single-rounded steps through exact integer arithmetic.

## GNU Arm Interface

The application binary interface, or ABI, receives 35 addresses. The first eight use x0 through x7 and the other 27 use consecutive eight-byte caller-stack slots. Integers and logical flags occupy four bytes. Real values are FP64 and require eight-byte alignment.

| Arguments | Meaning | Complete storage |
| --- | --- | --- |
| 1–4 | YDEPHLI, YDECLDP, YDECUMF, YDSPP_CONFIG | Plain configuration objects |
| 5–10 | KIDIA, KFDIA, KLON, KLEV, KINDEX, LDMIXS | Integer or logical scalars |
| 11–12 | PTENH, PQENH | KLON × KLEV matrices |
| 13–16 | PGEOH, PAPH, PQHFL, PAHFS | KLON × (KLEV + 1) matrices |
| 17 | PGP2DSPP | KLON × NRFTOTAL random-field matrix |
| 18 | PKMFL | Column vector |
| 19–22 | PTEN, PQEN, PQSEN, PGEO | KLON × KLEV matrices |
| 23–26 | PTU, PQU, PLU, PWU2H | Complete returned FP64 matrices |
| 27 | PWUBASE | Complete returned FP64 vector |
| 28 | KLAB | Complete returned integer matrix |
| 29–34 | LDCUM, LDSC, KCBOT, KBOTSC, KCTOP, KDPL | Complete returned four-byte vectors |
| 35 | PCAPE | Complete returned FP64 vector |

Columns change fastest. Half-level owners have lower bound one. The canonical bytes are the thirteen complete returned owners in argument order, with little-endian elements. Inactive columns and unchanged levels retain every incoming bit. Outputs do not overlap one another or consumed input owners.

TEPHLI is 120 bytes and LPHYLIN is at offset 4. TECLDP is 2776 bytes and RLMIN is at 120. TECUMF is 344 bytes, with ENTRORG at 0, ENTSTPC1 through ENTSTPC3 at 16, 24 and 32, RDEPTHS at 136 and NJKT2 at 312. Reuse the accepted TSPP_CONFIG size of 3192, LSPP at 0, NRFTOTAL at 216 and GNU PN descriptor at 352. The two PPTR offsets are 492 and 500. Each contiguous 184-byte perturbation supplies MU at 56, XMAG at 24 and MP at 136. Zero or negative selections are inactive, and valid positive selections can use a shifted lower bound.

The direct body preserves x18, x19 through x29 and the low 64 bits of d8 through d15. It keeps the stack aligned to 16 bytes and preserves FPCR. A 1536-byte fixed frame and 80 bytes per level hold one complete column. Calls add a 32-byte argument area. There is no heap allocation in the solver.

## Physical Domain

Support 1 through 4096 columns, 2 through 1024 levels, departure index 2 through KLEV, NJKT2 from 1 through KLEV minus one and a valid possibly empty selected interval. Normal physics requires LPHYLIN and LHOOK to be false. Consumed pressures, layer heights relative to the ground and physical constants are positive. Humidity and surface momentum flux are nonnegative. Absolute geopotential can be negative when relative layer heights remain valid. Every consumed state and perturbation must stay within the accepted finite arithmetic and thermodynamic domain.

The demonstrated missing-temperature interface also accepts the exact negative quiet-NaN word `fff8000000000000`. Humidity and pressure remain finite and physically admissible. Missing output bytes are compared exactly, but no heat, water or kinetic balance is claimed for a missing cell. All other missing encodings remain outside this contract.

## Required Evidence

The independent parent checks use exact rational balances for humidity and dry-static-energy mixing, condensate and removed-water exchange, freezing heat, kinetic energy and positive CAPE. The accepted CUADJTQ physical and storage proofs remain unchanged. Cloud-floor resets are retained as prescribed source inputs to the parcel-water calculation.

The main source/native gate passes 60 protected calls, 1,401,360 complete output bytes and 25,196 independent parent relations with zero differences. It covers shallow and deep mixing, stronger cloud mixing, stable and unstable surface fluxes, pressure-weighted elevated parcels, both cloud-base choices, kinetic stopping and the deep-cloud field reset. Six missing-temperature calls preserve 14,160 complete output bytes and 42 missing words. Six additional SPP cases preserve 6552 complete bytes across inactive selections and shifted contiguous records.

Two additional negative-datum cases preserve 2184 complete output bytes and 1188 independent parent balances. The paired smoke checks pass 32 complete calls and 50,160 returned bytes with zero differences, including missing temperatures, shifted perturbation records and a negative absolute geopotential datum.

Six immediate ABI cases preserve all required registers, FPCR and 47,436 returned bytes. Eight invalid shape or perturbation cases reject before 8736 shared output bytes change. The paired relay runs the original on cloned complete outputs and the native body on the real outputs, then checks every byte and every immutable owner.

## Positive Storage Optimisation

Each atmospheric column is independent during this calculation. Complete one column with reusable level storage and the accepted scalar adjustment child before moving to the next. This preserves every ordered dependency while keeping temporary storage proportional to the number of levels rather than the full packet size. No comparative performance claim is made before quiet-node timing.

The exterior top face can have zero pressure because it is the top boundary of the atmosphere. Interior pressure remains positive and increases towards the ground. The captured boundary-layer parent passed its unchanged half-level pressure owner to this routine after the original saturation and initialisation stages. With the accepted canonical thermodynamic constants, the focused child relay compared 17,376 complete returned bytes with zero differences and passed 232 physical relations. Negative exterior pressure and zero interior pressure still stop before changing outputs. The assembly and previous numerical and interface proofs remain unchanged.

The 6000 Pa departure test reads the exterior bottom pressure at half level N+1. A captured cold and moist caller state and twelve nearby protected cases verify this address, with 28,236 complete returned bytes and 5,237 independent physical relations. All bytes agree with the unchanged original. The hook-enabled paired replay returns another 2,172 identical bytes. Existing register, stack and child arithmetic proofs remain valid because the correction adds only the missing level stride.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cubasen | 51,200 | 51,600,000 | Native private cloud-base child, compared complete boundary-layer parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
