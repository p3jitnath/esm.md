# Longwave Nitrous Oxide, Carbon Dioxide And Nitrogen

Revision 1.0 describes thermal radiation from 2,380 to 2,600 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Nitrous oxide and carbon dioxide provide the main lower-layer absorption. Nitrogen adds a smaller broad absorption contribution.

## Physical Inputs

Let $`N,C`$ be the nitrous-oxide and carbon-dioxide columns in the model's approximately $`10^{20}`$ molecules cm$`^{-2}`$ scaling. Nitrous oxide is N$`_2`$O. Nitrogen is N$`_2`$, a different gas. The supplied ratio $`r`$ places the main gases on one scale. Pressure, temperature and gas mixture select line coefficient $`k`$ and nitrogen coefficient $`k_N`$. Let $`B`$ be the supplied broadening-gas column and $`s_N`$ its density scale. Let $`C_s,C_f,A`$ be dimensionless water self-continuum, foreign-continuum and aerosol depths. The continua describe broad water absorption from molecular interactions.

## Basic Mathematics

Below the tropopause, the boundary above most weather, the two main gases form a combined absorbing column.

```math
Q=N+rC,\qquad
\tau_L=Qk+C_s+C_f+B s_N k_N+A. \tag{P01}
```

This band parameterisation assigns no gas absorption or thermal emission weight above that boundary.

```math
\tau_U=A,\qquad f_U=0. \tag{P02}
```

Two representative spectral points describe the band. Supplied dimensionless Planck weights divide lower-layer thermal emission across them.

## State And Boundaries

The leaf reads an existing atmospheric state. It does not advance time or calculate radiation transport through the complete atmosphere. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol15.md) gives the numerical interpolation and complete assembly interface.
