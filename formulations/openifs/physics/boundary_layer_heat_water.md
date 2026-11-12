# Boundary-Layer Heat and Water

Revision 1.

Turbulent motion mixes heat and water near the ground. Rising air also carries these quantities between levels. The surface supplies or removes heat and water, and the atmosphere changes to keep the layer balances.

## Basic Mathematics

The weather model supplies liquid-water static energy, which combines thermal and gravitational energy with a latent-heat correction for condensed water. Let $`X`$ be this carried energy in J/kg or total water in kg/kg. Let $`m`$ be the layer mass per unit area in kg/m². The layer balance is

```math
m\frac{dX}{dt}=F_b-F_t+mR. \tag{DIFH-1}
```

Here $`F_b`$ enters through the bottom face, $`F_t`$ leaves through the top face, and $`R`$ is the change rate supplied by other model processes. Heat flux is in W/m² and water flux is in kg/(m² s).

Let $`C`$ be a turbulent transfer rate and $`M`$ be upward mass transport, both in kg/(m² s). If $`X_l`$ and $`X_u`$ are the lower and upper air values and $`X_c`$ is the rising-air value, then the upward face flux is

```math
F=C(X_l-X_u)+M(X_c-X_u). \tag{DIFH-2}
```

For upper and lower pressure $`p_t`$ and $`p_b`$ in Pa, gravitational acceleration $`g`$ gives

```math
m=\frac{p_b-p_t}{g}. \tag{DIFH-3}
```

## Inputs and Parameters

The caller supplies thermal energy, total water, pressure, transfer rates, rising-air transport, surface fractions and initial surface temperatures. It also supplies radiation, soil and snow states, the other atmospheric change rates, and the timestep. Levels run from the atmosphere’s top to the ground.

| Parameter | Example value | Unit |
| --- | ---: | --- |
| Gravitational acceleration | 9.80665 | m/s² |
| Dry-air specific heat | 1004.7088578330674 | J/(kg K) |
| Latent heat of vaporisation | 2500800 | J/kg |
| Latent heat of sublimation | 2834500 | J/kg |
| Timestep | 600 | s |

## Initial State and Boundaries

The initial air and surface state comes from the weather model. Pressure increases towards the ground, total water is nonnegative, and surface fractions sum to one. There is no flux through the top of the mixed region. The bottom flux follows the [surface skin balance](../surface/surface_skin_energy.md), with the source snow-evaporation term. A prescribed surface-flux mode uses the first surface type alone. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/vdfdifh.md) records the complete implicit update.
