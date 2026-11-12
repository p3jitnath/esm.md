# Aerosol And Gas Optical Mixtures

Revision 1.0. Aerosols are small solid or liquid particles in air. They absorb or scatter radiation. A particle can change its optical properties when water attaches to it, so the model uses a table for each humidity range.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`p_-,p_+`$ | Air pressure at the top and bottom of a layer, Pa |
| $`g_0`$ | Acceleration due to gravity, m s$`^{-2}`$ |
| $`q_t`$ | Mass fraction of aerosol type $`t`$, kg kg$`^{-1}`$ |
| $`k_t`$ | Extinction area per unit aerosol mass, m$`^2`$ kg$`^{-1}`$ |
| $`\omega_t`$ | Fraction of extinction caused by scattering, dimensionless |
| $`a_t`$ | Mean forward direction of scattered radiation, dimensionless |
| $`D,S,M`$ | Extinction depth, scattering depth and its direction-weighted moment, dimensionless |
| $`r`$ | Water mass fraction divided by its value at saturation, dimensionless |

## Equations

**P01. Aerosol Optical Depth**

```math
D=\sum_t\frac{p_+-p_-}{g_0}q_t k_t,\qquad S=\sum_t\frac{p_+-p_-}{g_0}q_t k_t\omega_t,\qquad M=\sum_t\frac{p_+-p_-}{g_0}q_t k_t\omega_t a_t.
```

The pressure difference gives the air mass per unit area. Multiplication by the particle mass fraction and extinction area gives the radiation removed from a beam. The other sums keep the scattering fraction and mean scattering direction.

**P02. Humidity Selection**

```math
r=\frac{q_{\mathrm{water}}}{q_{\mathrm{sat}}}.
```

A supplied ordered table selects the aerosol properties for this humidity. Hydrophobic particles use one fixed table. Hydrophilic particles use the humidity table. Ignored particle types contribute zero.

**P03. Mixture With Gas**

```math
D_{\mathrm{mix}}=D_{\mathrm{gas}}+D,\qquad S_{\mathrm{mix}}=\omega_{\mathrm{gas}}D_{\mathrm{gas}}+S,\qquad \omega_{\mathrm{mix}}=\frac{S_{\mathrm{mix}}}{D_{\mathrm{mix}}},\qquad a_{\mathrm{mix}}=\frac{M}{S_{\mathrm{mix}}}.
```

Gas scattering has zero mean forward direction. Longwave gas radiation has zero scattering depth. The model can omit aerosol longwave scattering and keep only its absorption depth, $`D-S`$.

## Parameters And Boundaries

The gravitational constant and spectral tables are frozen model inputs. Particle optical depths and mass fractions are nonnegative, scattering fractions lie between zero and one, and direction factors lie between zero and one. Each layer is independent and its output is mapped from spectral bands to the model's radiation points. A direct-input option supplies optical properties without the mass conversion. The existing [forward-scattering formulation](aerosol_forward_scattering.md) removes the strongly forward part before mixture formation when the chosen radiation mode requires it.

The [md2fort contract](../../../skills/md2fort/references/openifs/physics/add_aerosol_optics.md) records the table selection, ordered arithmetic and complete assembly interface.
