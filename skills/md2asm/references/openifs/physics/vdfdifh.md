# VDFDIFH Solver Contract

Revision 1. The [heat and water formulation](../../../../../formulations/openifs/physics/boundary_layer_heat_water.md) maps the complete original `arpifs/phys_ec/vdfdifh.F90` routine to [direct AArch64 assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/vdfdifh.S).

## Method and Domain

The update uses the original implicit heat and water matrix. It eliminates layers from the selected top towards the ground, couples the remaining lowest-level equations to the complete [SURFSEB_CTL child](../surface/surfseb_ctl.md), then substitutes upwards. The matrix treatment preserves the turbulent and rising-air fluxes in the formulation.

Let `K` be the packet width, `N` be the level count and `T` be the surface-type count. The domain is `1 <= K <= 4096`, `2 <= N <= 1024`, `8 <= T <= 10` and `KN <= 65536`. The selected top lies between level 1 and level `N-1`. A column range may be empty. Pressure faces are nonnegative and strictly increasing, so an exterior top pressure of zero is valid.

The supplied Earth configuration has planet-area factor one, consistent atmospheric and surface thermodynamic constants, and finite physical fields with nonnegative water and transfer rates. Each surface solve must retain finite nonzero denominators and the layer elimination must retain positive finite pivots. The lake flag requires at least nine surface types. The prescribed-flux branch uses the first surface type as the only active fraction, matching its original boundary definition.

## Complete Update

| Stage | Direct calculation |
| --- | --- |
| Layer equations | Source-ordered pressure weights, matrix coefficients and transported rising-air terms |
| Initial right sides | Existing heat and water plus supplied change rates and face transport |
| Snow exchange | Explicit forest-snow evaporation and its static-energy contribution |
| Downward elimination | Ordered first, middle and lowest layer calculations |
| Surface response | Two complete SURFSEB_CTL calls for unstressed and actual evaporation |
| Warm snow | Optional third surface call with the original changed snow conductance and subsurface temperature |
| Boundary override | Complete prescribed heat and latent-heat flux calculations |
| Return air and skin state | Lowest-level values, upward substitution and complete change rates |

The two surface calls retain their different moisture-supply factors. Warm multilayer snow can trigger one further call for the complete selected packet. That call uses 100 W/(m² K) conductance and the water-phase reference temperature beneath the snow skin. Other surface types keep their source inputs. Snow evaporation is added to the returned moisture and latent-heat fluxes.

The returned air values are auxiliary values for the implicit solve. The caller can use a longer solve interval than the actual model step, then use the returned rates to update the physical state. Auxiliary total water must be finite but can be signed. Physical initial water remains nonnegative, and all layer fluxes, returned rates and column balances retain their original checks. The consumer must check its actual-step water state with its own timestep.

Only the selected mixed region receives the implicit air update. The heat and water change rates above it are zero, while the uncomputed air-output storage above it retains its complete source bytes. Inactive columns retain their original complete-owner bytes.

## Interface and Storage

The default entry is `vdfdifh_`, and `VDFDIFH_SYMBOL` can select a unique local entry. `VDFDIFH_SURFACE` selects the complete direct surface child. There are 66 ordinary GNU Fortran argument addresses. The first eight occupy `x0` through `x7` and the other 58 occupy the incoming stack.

| Argument indices | Role |
| --- | --- |
| 0–2 | Coupling, physics and time objects |
| 3–8 | First and last columns, packet width, levels, mixed-region top and surface count |
| 9–14 | Vegetation indices, timestep, prescribed heat and latent heat, and boundary flag |
| 15–22 | Surface fractions, radiation, emissivity, snow evaporation and lake states |
| 23–31 | Initial air, face pressure, transfer coefficients and rising-air fields |
| 32–33 | Auxiliary air thermal energy and total water |
| 34–53 | Surface heat and water response, initial temperature and soil, snow or ice states |
| 54–58 | Updated skin and supplied or returned atmospheric change rates |
| 59–65 | Skin change rate and complete surface flux outputs |

FP64 stores each real number in a 64-bit word. Real arrays contain little-endian FP64 elements, with the column index varying fastest. Integer and logical values use 32-bit words. Full fields need `8KN` bytes, face fields need `8K(N+1)` bytes and surface fields need `8KT` bytes. The 12 complete returned owners are arguments `32, 33, 54, 57, 58, 59, 60, 61, 62, 63, 64, 65`. They occupy `32KN+64KT` bytes.

The known object sizes are 7584, 448 and 175976 bytes for arguments 0–2. The physics object contains the registered surface pointer at byte 440. That pointer addresses the complete 11584-byte surface object, whose measured fields provide the six unchanged surface-child objects. The original registry lookup is a read-only metadata query and supplies no numerical stage.

Registers are the CPU’s working storage. The direct body preserves `x18`, `x19` through `x29` and the required low halves of `v8` through `v15`. The stack stays 16-byte aligned. Its parent storage needs `4864+align16(8(7KN+7K+4KT))` bytes, with 2304 more bytes while the complete surface child runs. Callers must provide valid separate mutable owners and enough stack.

## Arithmetic and Independent Checks

FPCR is the floating-point control register, which selects how real-number calculations round. It must be zero. Multiplication, addition, subtraction and division retain each source FP64 rounding point. There is no fused arithmetic, reassociation, approximate division or omitted numerical child. Parent face products are rounded before entering their original right-side dependencies.

Independent exact rational checks reconstruct turbulent and rising-air fluxes from the final state and check the layer and complete-column heat and water balances. They also check atmospheric and skin change rates, prescribed fluxes, zero tendencies above the mixed region and the changed warm-snow boundary. The unchanged surface-child physical, exact-byte and ABI proofs are reused. Unit roundoff is the FP64 relative rounding scale near one, with value 2⁻⁵³. The new balance budget is frozen at 4096 times that scale times each independent relation’s magnitude sum.

The original gate passed 20 cases, 3,248,736 complete output bytes and 8,488 independent relations. It covers multiple mixed-region tops, pressure-zero exterior faces, all admitted surface counts, moisture correction, snow evaporation, the actual warm-snow boundary change, prescribed surface fluxes, cropped and empty packets, and the individual packet and level limits. The largest residual uses less than 0.00053 of its frozen budget. The first complete direct body passed 40 protected placements, 6,497,472 complete returned bytes and 16,976 independent relations, with zero differing bytes. The final body reuses its descriptor metadata across the complete surface calls, reducing the source from 4514 to 2615 lines. Eight focused protected placements passed 20,160 bytes and 1,488 relations after that metadata change, while the unchanged matrix and surface proofs remain valid.

The final closure passed four immediate ABI cases, 34,944 complete bytes and 3,997 relations. Seven unsupported shape or boundary cases stopped before changing 12,096 bytes. Six profiling-enabled paired cases passed 65,760 complete bytes and 7,451 independent driver relations, including warm snow, prescribed fluxes, shared read-only input and an empty range. Three alias or pressure-domain cases stopped before changing 5,184 bytes. Machine-code inspection found no fused floating-point instruction.

The complete parent also counts actual private surface-child executions, separate from calls made by the source-verification shadow. That count records returned owner extents and does not claim an additional byte comparison. The final pair cases executed 11 genuine private surface calls. Local commands, exact controls, intermediate revisions and proof records are retained under `.runtime/openifs/heat_water_diffusion_7240564/`. Complete-forecast acceptance and comparative timing remain pending.

The captured forecast case uses a 5400 s auxiliary solve and a 3600 s actual step. Its complete 28,416 source and native output bytes match. Independent rational checks pass 3,912 unchanged balance relations, and all 456 reconstructed actual-step water values are positive. One new source case and two protected native placements qualify a signed auxiliary value with a positive actual-step value. The native placements match 4,032 bytes with zero differences and 300 relations. Its paired case matches 2,016 bytes and 150 relations. Numerical instructions, surface children, interface proofs and earlier bounds checks are unchanged.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vdfdifh | 2,150 | 61,094,400 | Complete returned parent owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
