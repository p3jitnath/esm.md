# Longwave Water And Methane Absorption

Revision 1.0 describes thermal radiation from 2,600 to 3,250 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water and methane provide the main lower-layer absorption. The upper layers retain methane absorption.

## Physical Inputs

Let $`W,M`$ be the water and methane columns in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. The supplied ratio $`r`$ places both gases on one scale. Supplied tables and atmospheric weights select absorption coefficients $`k_L,k_U`$. Let $`C_s,C_f`$ be dimensionless water self and foreign continuum depths. They describe water interactions with water molecules and with other gases. Let $`A`$ be the dimensionless aerosol depth.

## Basic Mathematics

Below the tropopause, the boundary above most weather, the two main gases form a combined absorbing column.

```math
Q=W+rM,\qquad \tau_L=Qk_L+C_s+C_f+A. \tag{P01}
```

Above this boundary, the parameterisation retains the supplied methane line coefficient and aerosol depth.

```math
\tau_U=Mk_U+A. \tag{P02}
```

Two representative spectral points describe the band. Supplied dimensionless Planck weights divide thermal emission across them. The frozen original upper-table selection is described in the numerical contract.

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol16.md) gives the numerical interpolation and complete assembly interface.
