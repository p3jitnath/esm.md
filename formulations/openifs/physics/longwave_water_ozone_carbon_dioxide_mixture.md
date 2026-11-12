# Longwave Water, Ozone And Carbon Dioxide Absorption

Revision 1 describes absorption of Earth's thermal radiation between 980 and 1080 inverse centimetres. Water vapour and ozone form the main absorbing mixture in the lower atmosphere. Ozone is the main absorber above the tropopause, the boundary between the lower and upper atmosphere. Carbon dioxide and aerosols add absorption.

Optical depth $`\tau_g`$ is a dimensionless measure of absorption at spectral point $`g`$. Each spectral point represents part of the frequency band. Let $`C_c`$ be the carbon-dioxide column in units of $`10^{20}`$ molecules per square centimetre and $`k_{c,g}`$ its absorption coefficient.

```math
\tau_g=s_g\left[\tau_{w,o,g}+\tau_{s,g}+\tau_{f,g}
+\widetilde C_c k_{c,g}+\tau_{a,g}\right]. \tag{LW7-1}
```

The main term describes water–ozone absorption. Self and foreign water terms describe absorption influenced by nearby water and other air molecules. These water terms vanish in the upper atmosphere. Aerosol depth is $`\tau_{a,g}`$. The dimensionless factor $`s_g`$ equals one except at six upper spectral points, where empirical factors improve ozone cooling.

The empirical carbon-dioxide law uses the dry-air column $`C_d`$ in molecules per square centimetre and its dimensionless reference fraction $`\chi_c`$.

```math
r=\frac{10^{20}C_c}{C_d\chi_c},\qquad
\widetilde C_c=
\begin{cases}
C_c,&r\leq3,\\
\left[a+(r-a)^{0.79}\right]\chi_c C_d\,10^{-20},&r>3.
\end{cases} \tag{LW7-2}
```

Here $`a=3`$ below the tropopause and $`a=2`$ above it. Use unchanged gas columns, aerosols and empirical tables supplied by the forecast. The tables also assign thermal emission through Planck fractions. This calculation has no separate time update or spatial boundary. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/rrtm_taumol7.md) defines the numerical interpolation and interface.
