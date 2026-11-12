# Longwave Water And Trace-Gas Absorption

Revision 1.0 describes thermal radiation from 820 to 980 cm$`^{-1}`$. A wavenumber counts wave cycles per centimetre. Water vapour, carbon dioxide, CFC-11 and CFC-12 absorb radiation in this band. The two CFC gases are chlorofluorocarbons. Aerosols add their supplied absorption.

## Physical Inputs

Let $`W,C,X_{11},X_{12}`$ be the four gas columns, in units of $`10^{20}`$ molecules cm$`^{-2}`$. Their supplied coefficients $`k_W,k_C,k_{11},k_{12}`$ convert each column to a dimensionless absorption depth. Let $`d`$ be the unscaled dry-air column in molecules cm$`^{-2}`$, and let $`q_r`$ be the dimensionless reference carbon-dioxide fraction. The tropopause is the boundary above most weather.

## Basic Mathematics

A high carbon-dioxide amount needs an empirical adjustment, which comes from fitted radiation data. The dimensionless ratio $`r`$ compares the gas fraction with its reference value.

```math
r=\frac{10^{20}C}{d q_r},\qquad
\widehat C=
\begin{cases}
C,&r\leq 3,\\
\left[2+(r-2)^{0.77}\right]q_r d\,10^{-20},&r>3.
\end{cases}\tag{P01}
```

Let $`S,F`$ be the dimensionless water self and foreign continuum depths. A continuum is a broad background of absorption. Let $`A`$ be the supplied dimensionless aerosol depth. The lower atmosphere includes the water and carbon-dioxide terms, while the upper atmosphere includes the two CFC terms and aerosols.

```math
\tau_L=W k_W+S+F+X_{11}k_{11}+X_{12}k_{12}
+\widehat C k_C+A,\qquad
\tau_U=X_{11}k_{11}+X_{12}k_{12}+A.\tag{P02}
```

Eight representative spectral points describe this band. Their supplied dimensionless Planck weights $`w_g`$ divide its thermal emission.

```math
f_g=w_g.\tag{P03}
```

## State And Boundaries

The calculation reads an existing atmospheric state. It does not advance time or transport radiation through the whole atmosphere. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/rrtm_taumol6.md) defines interpolation, ordered arithmetic and the complete assembly interface.
