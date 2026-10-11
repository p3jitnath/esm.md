# Complete VDFEXCU Contract

Revision 1 implements [Turbulent Exchange Coefficients](../../../../../formulations/openifs/physics/turbulent_exchange_coefficients.md) as the complete original VDFEXCU body. Independent scientific checks accept the original before assembly emission. Source equations, shared constants and output bytes are frozen.

## Ordered Calculation

Each column computes its configured SPP factors with the accepted EXP boundary. SPP means stochastic perturbation of a physical parameter. The five source selections use VDEXC and the four boundary-layer categories. Each selected factor is EXP(MU + XMAG times the supplied random value), with a separately rounded multiplication and addition.

The surface friction speed is the maximum of the square root of momentum flux and the registered surface minimum. Negative buoyancy flux sets the signed Obukhov length through the original friction-speed cube. Cloud type 2 uses the nonnegative radiative cooling jump across its inversion. Positive buoyancy flux scans from the bottom upwards and places the stable boundary height between the first two layers that bracket Richardson number 0.25.

The remaining levels run from the second-last level towards the top. Preserve the wind-difference squares, shear floor, square root, division and gravity multiplication. Stable mixing uses the limited 30 to 300 metre length and the two Louis stability factors. Unstable mixing uses the original nested square roots and reciprocals from PHIMU and PHIHU. Unused PSI statement functions supply no numerical stage.

Below the inversion, preserve the two negative-one-third POWER calls, surface mixing shape, moist-cloud fourth-power correction and cloud-top cooling terms. At the inversion, preserve the buoyancy and radiative entrainment velocity, its zero floor and the 0.001 kelvin temperature-jump threshold. Cap each coefficient at one million square metres per second. Preserve stratospheric modes 1, 2, 5 and the unchanged branch for every other integer mode.

Store heat and momentum diagnostics after the planetary-area factor. Then multiply each coefficient by the separately calculated pressure scaling and area factor. Integer powers use the original square, square or cube order. Fractional POWER uses the [original-compatible primitive contract](../power_math.md). EXP uses the accepted strict [elementary-function route](../pressure_math.md). All solver multiplication and addition remain separately rounded and no fused floating-point instruction is allowed.

## Interface and Storage

The Arm GNU interface passes 36 argument addresses. In order they are YDEGWD, YDEPHY, YDSPP_CONFIG, KIDIA, KFDIA, KLON, KLEV, KINV, KCBASE, KCTOP, PLAM, PZ0MM, PHRLW, PHRSW, PUM1, PVM1, PTM1, PQM1, PAPHM1, PGEOM1, PGEOH, PGELAT, PCPTGZ, PKMFL, PKHFL, PKQFL, PKHVFL, PGP2DSPP, PCFM, PCFH, PZINV, PKH, PKM, PRI, PZCLDBASE and KPBLTYPE. The outputs are complete PCFM, PCFH, PKH and PKM matrices in Fortran column order. Bottom-level and unselected bytes remain unchanged. PZINV and PZCLDBASE are not consumed.

TEGWD is 96 bytes and the consumed stratospheric fields are at offsets 88 and 12. TEPHY is 448 bytes and its registered surface handle is at offset 440. YOS_SURF proves that this handle is already the address of the read-only 11,584-byte surface context. GET_SURF only searches the registry and returns the same context. The assembly directly loads consumed REPUST at offset 4056 without supplying a missing numerical stage or changing the registry.

TSPP_CONFIG is 3192 bytes. LSPP is at 0, NRFTOTAL at 216 and the accepted GNU rank-one PN descriptor at 352. The five PPTR offsets are 488, 464, 468, 472 and 476. Each 184-byte perturbation supplies MU at 56, XMAG at 24 and MP at 136. PN is an allocatable Fortran array and must have its genuine contiguous stride of one. Lower bounds can differ from one, and all positive selections must lie within the descriptor bounds.

## Physical Domain and Acceptance

Support 1 to 4096 columns and 1 to 1024 levels, a valid possibly empty selected interval, contiguous complete matrix owners and disjoint consumed input/output storage. Half-level matrices cover levels 0 through KLEV. Temperatures, pressures, height differences and limiting length are positive. Momentum flux is nonnegative. Consumed fractional POWER bases must be nonnegative and negative-one-third bases must be strictly positive. Cloud and entrainment branches require valid inversion, cloud-base and neighbour indices. Registered surface metadata, all globals and every input owner remain unchanged.

The physical verifier checks mixing-length bounds, stable boundary interpolation, positive heat and momentum diffusion, dissipative tendencies, independent high-precision stability factors, entrainment heat balance and conversion between diagnostic and pressure-scaled coefficients. Its original protected corpus passes 68 calls, 674,304 full output bytes and 95,736 independent relations. All source branch groups pass and all 86 newly consumed POWER operand pairs have zero original-bit differences. Native exact bytes, immediate ABI and bounds checks and the actual forecast gate must pass before acceptance.

The first eight addresses use registers x0 through x7 and the remaining 28 use consecutive eight-byte caller-stack slots. Scalars and matrix elements use FP64, while indices and logical values use four-byte integers. Real owners require eight-byte alignment. The entry preserves x18, x19 through x29 and the lower 64 bits of d8 through d15, maintains a 16-byte stack boundary and uses a fixed 1024-byte frame. No scratch matrix or heap allocation supplies a numerical stage.

Source and native checks pass 74 protected calls, 682,944 complete output bytes and 96,792 independent physical relations with zero differences. The extra cases cover zero and negative perturbation pointers and a contiguous PN array with lower bound minus two. The paired checks pass the same complete owners. Six immediate ABI cases pass 300,672 output bytes, and eight invalid shape or perturbation cases reject before 11,520 shared output bytes change. The public and private symbol builds have identical numerical machine text. The actual forecast gate remains pending.

The exterior top face, at index 0, can have zero pressure. Interior face pressures remain positive because the diffusion scaling uses them. The original vertical-diffusion caller passes the same half-level pressure owner to the boundary-layer-height and exchange routines. The focused check reused that captured 24-column, 19-level pressure owner with the accepted atmospheric fixture and constants. It compared 14,592 complete returned bytes with zero differences and passed 3,048 physical relations. Negative exterior pressure and zero interior pressure still stop before changing 29,184 output bytes across two rejected calls. The assembly and earlier numerical and interface proofs remain unchanged.

The captured forecast case revealed an integer register reuse defect in the cloud-shape condition. The cloud-base index now remains in w11 while x9 loads the cloud-top array address, so the comparison uses two indices. The equation and all floating-point instructions remain unchanged. Eight protected captured and threshold cases pass 37,824 complete bytes, 7,964 independent relations and the immediate assembly ABI check with zero differences. Four paired cases pass another 18,912 complete bytes and 3,982 independent relations. The old input guards and qualified arithmetic proofs are reused.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vdfexcu | 2,150 | 31,372,800 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
