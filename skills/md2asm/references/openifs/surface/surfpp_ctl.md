# SURFPP_CTL Solver Contract

Revision 2. This contract maps the [surface weather formulation](../../../../../formulations/openifs/surface/surface_weather_elements.md) to [direct AArch64 assembly](../../../../../src/openifs/surface/surfpp_ctl.S). The original complete routine is `surfpp_ctl_mod::surfpp_ctl` in `surf/module/surfpp_ctl_mod.F90`.

## Method and Domain

The parent preserves the original tile order and complete surface update. It first averages the existing sensible and water fluxes, replaces values on zero-fraction tiles where the source does so, and writes the optional tile diagnostics. It then separates snow and snow-free latent heat, derives friction velocity from surface stress, calls the complete near-surface profile and gust stages, applies configured ocean skin effects, and returns the final mean skin-temperature rate.

Let $`K`$ be the packet width and $`T`$ the tile count. The supported domain is $`1\le K\le4096`$ and $`8\le T\le10`$. Ocean skin effects require $`K\le512`$ and contiguous rows because the unchanged accepted ocean child has that interface. Lake mode requires at least nine tiles. All normal cool-skin, warm-layer and Langmuir ocean settings are present. Selected columns use Fortran numbering, and their range may be empty.

The caller supplies finite physical inputs, positive pressure, skin temperatures and roughness lengths, nonnegative humidity, positive time and planet scales, and nonnegative tile fractions that sum to one. The ordinary scalar interpolation settings and the supported numerical domains of the complete children apply. Mutable array owners must be separate from other consumed arguments. Read-only views may share storage.

## Complete Stages

| Stage | Direct route and source meaning |
| --- | --- |
| Flux means and zero-fraction tiles | Ordered parent sums preserve the old tile fluxes before any replacement |
| Optional tile diagnostics | The complete contained `COMPUTE_DDH` stage writes sensible, latent, ground and water fields 8–11 |
| Snow heat and evaporation | The parent retains forest-snow splitting and the optional lake contribution |
| Wind, temperature and dewpoint | Complete private [SPPCFL](../../../../../src/openifs/surface/sppcfl.S) retains stable, unstable and neutral profile branches |
| Gust speed | Complete private [SPPGUST](../../../../../src/openifs/surface/sppgust.S) uses stress-derived friction velocity |
| Ocean skin | The unchanged complete [VOSKIN](ocean_skin_temperature.md) body retains every configured mode |
| Final skin state and rate | Ordered tile means update the returned temperature and existing rate |

No wrapper supplies a numerical stage. The private profile and gust bodies use their complete original address interfaces. Unused source arguments remain part of those interfaces.

The stress-derived friction velocity used for gusts is distinct from the profile-derived friction velocity returned in `PUST`. If $`\rho`$ is air density in kg/m³ and $`\tau_u,\tau_v`$ are surface stresses in N/m², the former is

```math
\rho=\frac{p}{R_dT_\mathrm{old}(1+\chi q)},\qquad
u_\tau=\max\left(u_\mathrm{min},\sqrt{\frac{\sqrt{\tau_u^2+\tau_v^2}}{\rho}}\right). \tag{SWX-4}
```

Here $`R_d`$ is the dry-air gas constant in J/(kg K), $`\chi`$ is the supplied dimensionless humidity correction and $`u_\mathrm{min}`$ is the supplied positive friction-velocity floor.

## Interface and Bounds

The application binary interface, or ABI, is GNU Fortran’s ordinary address interface. The default parent symbol is `__surfpp_ctl_mod_MOD_surfpp_ctl`. `SURFPP_SYMBOL` selects a unique local entry. There are 63 addresses, with arguments 0–7 in `x0`–`x7` and arguments 8–62 on the incoming stack.

| Argument indices | Meaning and storage |
| --- | --- |
| 0–5 | Six 32-bit dimensions for selected columns, packet width, tiles and diagnostic counts |
| 6 | FP64 time interval in s |
| 7–9 | Rank-two tile fractions, latent heat and ground heat |
| 10–29 | Rank-one atmospheric, surface, roughness and snow inputs |
| 30 | Rank-two solar radiation by tile |
| 31–36 | Rank-one thermal radiation, sea temperature, currents and Stokes drift |
| 37–39 | Complete TCST, TEXC and TFLAKE objects of 128, 144 and 856 bytes |
| 40–43 | Existing sensible heat, water flux, skin rate and next skin temperature |
| 44–60 | Returned mean fluxes, tile stresses and temperatures, weather elements and friction velocity |
| 61 | Rank-three optional tile diagnostics |
| 62 | Positive FP64 planet scale |

Real arrays use GNU descriptors with little-endian FP64 values. The first logical column starts at the descriptor’s base address. Rows and higher dimensions have positive element strides. Rank-one, rank-two and rank-three metadata occupy 64, 88 and 112 bytes. Each descriptor must cover the declared packet and tiles. Nonempty diagnostics need fields 1–11, while an empty diagnostic array is supported.

The 22 complete mutable owners are arguments 40–61. The native body supports positive strides within its declared child limits. The live comparison requires contiguous complete output owners, preserves read-only sharing through cloned owner unions, and compares all returned bytes, including inactive columns and untouched diagnostic fields.

The body preserves `x18`, `x19`–`x29` and the required low 64 bits of `v8`–`v15`. The stack remains aligned to 16 bytes. The parent needs `2432+32K` stack bytes, plus the complete child workspace. Local temporary vectors hold the two old flux means, the new skin mean and stress-derived friction velocity.

## Arithmetic and Physical Checks

FPCR must be zero, which selects round-to-nearest with ties to even and gradual underflow. Every primary multiply, add, divide and square root remains separately rounded FP64 in source order. The forest-snow term retains the ordered product `fraction * sublimation_heat * snow_evaporation`. Signed zeros are preserved.

For the dewpoint calculation, $`T_2`$ is temperature at 2 m in K, $`q_a`$ is the lowest-level specific humidity in kg/kg and $`\chi`$ is the supplied humidity correction. First round $`R_d T_2`$ to FP64. Then multiply that rounded value by the rounded factor $`1+\chi\max(q_\mathrm{min},q_a)`$ before the pressure division. Here $`q_\mathrm{min}`$ is the fixed numerical humidity floor $`100\,2^{-52}`$ in kg/kg. This keeps the complete water-pressure and dewpoint calculation in the original order.

Scalar EXP and LOG use the accepted strict math route. The original-compatible [ATAN primitive](../support/atan_original_rounding.md) and [POWER primitive](../power_math.md) retain the original external function results without fused floating-point instructions. Their accepted numerical and ABI proofs are reused.

Independent checks use the tile heat and water sums, snow splitting, tile diagnostics, skin-rate balance, stress-derived gust relation, and high-precision surface profile and dewpoint relations. The unstable profile correction has an independent integral and derivative check. Stable profile corrections retain their own original empirical relation and do not claim the different stable flux-gradient identity. The rounding budget remains $`4096\,2^{-53}`$ times the independent relation magnitudes.

Original parent physics passed 13 cases, 2,813,624 complete returned bytes and 389,022 parent, profile and boundary relations. The main native corpus passed 26 protected placements with 5,627,248 compared bytes. Four focused forest-snow ordering cases then passed 139,968 compared bytes and 36,324 relations. Three immediate ABI cases passed 76,248 bytes, and five unsupported shape cases rejected before changing outputs.

Four profiling-enabled paired calls passed 14,304 complete compared bytes and 1,857 driver relations. These include ocean skin, optional diagnostics, an empty selected range and shared read-only wind views. A mutable input/output alias was rejected before writes. The live report counts complete parent returns and genuine private VOSKIN calls; a focused counter check recorded two VOSKIN calls and excluded original shadow calls and the empty selected range. SPPCFL and SPPGUST are private children outside the queued weather count. Full forecast acceptance is recorded below.

A later genuine cold-column packet qualifies this pressure order across all 33,984 returned bytes and 13,072 immutable bytes with zero differences. The protected native and live paired replays retain every alias and descriptor, pass 120 independent dewpoint relations at the same rounding budget, and preserve FPCR 0, FPSR 16 and errno 34. The native register and stack check also passes. Earlier unchanged parent and child proofs remain valid. The complete revised forecast gate is recorded below.

Local source versions, binary controls, input corpus, commands and compact acceptance records are retained under `.runtime/openifs/surface_postprocessing_7240564/`. No comparative timing or measured speedup is claimed here.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| surfpp_ctl_mod::surfpp_ctl | 2,150 | 73,065,600 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

The revised wind forecast in exclusive allocation 7259755 also passes 2,150 complete surface calls and 73,065,600 returned bytes with zero differences. All ten saved files match its separately reviewed source forecast across 618,140 bytes.
