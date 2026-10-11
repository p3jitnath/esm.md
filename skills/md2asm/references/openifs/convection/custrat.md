# CUSTRAT solver contract

Revision 1 accompanies [low-cloud mixing](../../../../../formulations/openifs/convection/stratocumulus_mixing.md) and [the direct assembly](../../../../../src/openifs/convection/custrat.S).

## Interface and scope

The unique AArch64 entry is `md2asm_custrat_7240564`. Its 17 pointer arguments retain the original order: `YDEPHLI, KIDIA, KFDIA, KLON, KLEV, LDCUM, PTSPHY, PVDIFTS, PAP, PAPH, PGEO, PTEN, PQEN, PQSAT, PENTH, PTENT, PTENQ`. Integers and logicals occupy four bytes. Reals occupy eight bytes. The first eight pointers use registers x0 through x7; the remaining pointers use the caller's aligned stack.

Let `K=KLON` and `N=KLEV`. Profiles contain `K*N` values with the column index changing first; `PAPH` contains `K*(N+1)` values. `LDCUM` contains K logicals. The configuration object has 120 bytes. `PENTH, PTENT, PTENQ` are the only output owners. Distinct input and output owners have eight-byte alignment and sufficient complete declared storage. The routine preserves the caller's nonvolatile registers and stack alignment. Its 768-byte frame and private scratch are released before return.

The domain has 1 to 4,096 columns, 4 to 137 layers, an interval of selected columns including the empty interval, normal nonlinear physics, a positive time interval through 86,400 s, and a positive diffusion weight through 1. Selected temperatures lie from 140 to 360 K, geopotential from 0 to 2,000,000 J kg$`^{-1}`$, and consumed lower-layer humidity from 0 to 0.1 kg kg$`^{-1}`$. Consumed pressures are positive, half-level pressure increases downward, and geopotential decreases downward. Supplied saturation humidity must be positive only where the cloud-top branch consumes it. The complete CUADJTQ mode-one child's accepted thermodynamic domain also applies.

## Complete ordered update

The routine forms dry static energy and starts the surface parcel at temperature plus 0.25 K. It raises the parcel through the lower model region, performs the accepted complete CUADJTQ mode-one condensation adjustment, and sets the original dry, cloud or inactive parcel label from virtual-temperature buoyancy. The 90% surface-pressure cutoff stops the original boundary-layer branch. It then computes both original cloud coefficients, 10 and 2.5, and the humidity-dependent cloud-top exchange. All pressure and height conversion factors retain their original operation order.

The lower mixing region starts at the original integer `N/2` layer. Its complete implicit three-diagonal system is solved by forward elimination and backward substitution, including the top row, bottom row and zero-exchange boundaries. The solved dry energy and humidity produce all three original output updates. Existing temperature and humidity tendencies are incremented; dry-energy tendency is assigned. All upper-region and unselected output words retain their original bytes.

Every primary operation is separate FP64 addition, subtraction, multiplication or division, with round-to-nearest, ties to even, gradual underflow and preserved signed zeros. FPCR must be zero. The complete private child retains its already accepted exponential and saturation routes. There is no omitted numerical stage in a driver, contraction, approximate instruction or global math override.

## Acceptance

The original-first science gate checks the diffusion equation at 120 decimal digits, pressure-weighted water and dry-energy conservation, nonnegative exchange, bounded mixing and agreement between heat and temperature tendencies. It uses stored source intermediates to check the equation directly rather than repeating the solve. Its error bound includes every consumed term, output recovery rounding and gradual underflow.

Ten original protected placements pass 424,200 complete output bytes and 97,690 independent relations before emission. Twenty native placements pass 848,400 bytes with zero differences, 195,380 relations and the immediate Arm register check. A separate warm-inversion case proves the 2.5 coefficient and cloud-top branch: one original and two native placements pass another 288 and 576 bytes, with 69 and 138 relations. Fresh numerical status, complete read-only owners and FPCR agree. The CUCALLN paired cases exercise this complete support body inside its actual parent interface.

Local provenance, unchanged child identities, source controls, build commands and failures are retained in `.runtime/openifs/stratocumulus_diffusion_7240564/`. Root owns forecast acceptance. This support helper adds no queued weather-routine count or timing claim.
