# Surface Skin Energy

Revision 1.

The thin surface layer exchanges heat and water with the air. Sun’s radiation and thermal radiation also heat or cool it. Heat can then pass into the soil, sea, lake water or ice below. Different surface types share one weather-model cell.

## Basic Mathematics

Let $`T_s`$ be the surface-layer temperature in K. Let $`S_a`$ and $`S_s`$ be the air and surface static energy in J/kg, and let $`C_h`$ be a heat-transfer rate in kg/(m² s). The downward static-energy flux $`J_s`$ is in W/m².

```math
J_s=C_h(S_a-S_s). \tag{SEB-1}
```

Let $`q_a`$ and $`q_s`$ be specific humidity in kg/kg. With a water-transfer rate $`C_q`$ in kg/(m² s), the downward water flux $`J_q`$ is

```math
J_q=C_q(\alpha_a q_a-\alpha_s q_s). \tag{SEB-2}
```

The dimensionless factors $`\alpha_a`$ and $`\alpha_s`$ describe the water supply. The surface humidity changes with temperature. Its supplied value and temperature derivative define a local linear approximation.

Let $`H`$ be sensible heat, $`LE`$ be latent heat, $`R_s`$ be absorbed Sun’s radiation and $`R_l`$ be net thermal radiation, all in W/m². Let $`G`$ be heat into the material below. The surface balance is

```math
G=H+LE+R_s+R_l. \tag{SEB-3}
```

If $`\lambda`$ is surface conductance in W/(m² K) and $`T_b`$ is the temperature below the surface in K, then

```math
G=\lambda(T_s-T_b). \tag{SEB-4}
```

## Inputs and Parameters

The weather model supplies the air state, initial surface temperature, surface humidity and its temperature derivative, transfer rates, surface fractions, radiation, conductance and subsurface temperature. It also supplies snow and ice states and the heat and water response of the lowest air layer.

| Parameter | Example value | Unit |
| --- | ---: | --- |
| Dry-air specific heat | 1004.7088578330674 | J/(kg K) |
| Latent heat of vaporisation | 2500800 | J/kg |
| Latent heat of sublimation | 2834500 | J/kg |
| Stefan–Boltzmann constant | 5.670374419 × 10⁻⁸ | W/(m² K⁴) |
| Timestep | 600 | s |

## Initial State and Boundaries

The caller supplies the initial surface state and the current air-layer response. Each surface fraction is between zero and one, and the fractions sum to one. The surface receives the radiation and exchanges heat and water with the atmosphere and material below. The [md2asm contract](../../../skills/md2asm/references/openifs/surface/surfseb_ctl.md) records the coupled numerical solve and its longwave-radiation approximation.
