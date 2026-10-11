# Longwave Water, Ozone And Minor Gas Absorption

Revision 1 describes absorption of Earth's thermal radiation between 1080 and 1180 inverse centimetres. Water vapour is the main absorber in the lower atmosphere. Ozone is the main absorber above the tropopause, the boundary between the lower and upper atmosphere. Carbon dioxide, nitrous oxide, two trace gases and aerosols add absorption.

Optical depth $`\tau_g`$ is dimensionless and measures absorption at spectral point $`g`$. Each point represents part of this frequency band. Let $`C_o`$, $`C_n`$ and $`C_c`$ be ozone, nitrous oxide and carbon-dioxide columns in units of $`10^{20}`$ molecules per square centimetre. The coefficients $`k_{o,g}`$, $`k_{n,g}`$ and $`k_{c,g}`$ convert these columns to optical depth.

```math
\tau_g=\tau_{\mathrm{main},g}+\tau_{\mathrm{water},g}
+\widetilde C_c k_{c,g}+C_n k_{n,g}
+\tau_{\mathrm{trace},g}+\tau_{\mathrm{aerosol},g}. \tag{LW8-1}
```

In the lower atmosphere, add $`C_o k_{o,g}`$ for minor ozone absorption. The main upper term already describes ozone. Additional water absorption occurs only below the tropopause. The trace terms describe CFC-12 and CFC-22, chemicals that absorb infrared radiation.

The empirical tables reduce carbon-dioxide growth when its amount greatly exceeds the reference atmosphere. Let $`C_d`$ be the dry-air column in molecules per square centimetre and $`\chi_c`$ the dimensionless reference carbon-dioxide fraction.

```math
r=\frac{10^{20}C_c}{C_d\chi_c},\qquad
\widetilde C_c=
\begin{cases}
C_c,&r\leq3,\\
\left[2+(r-2)^{0.65}\right]\chi_c C_d\,10^{-20},&r>3.
\end{cases} \tag{LW8-2}
```

Use the original gas, aerosol and empirical table inputs supplied by the forecast. The tables also assign a Planck fraction to each spectral point for thermal emission. This calculation has no separate time update or spatial boundary. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol8.md) defines its interpolation and assembly interface.
