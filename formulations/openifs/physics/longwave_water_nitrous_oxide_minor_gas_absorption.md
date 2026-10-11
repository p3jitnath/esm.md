# Longwave Water, Nitrous Oxide And Minor-Gas Absorption

Revision 1 describes absorption of Earth's thermal radiation between 2080 and 2250 inverse centimetres. Water vapour and nitrous oxide form the main absorbing mixture in the lower atmosphere. Carbon dioxide and nearby air molecules add absorption. Above the tropopause, the boundary between the lower and upper atmosphere, this band uses ozone absorption.

Let $`C_w`$, $`C_n`$, $`C_c`$ and $`C_o`$ be the water, nitrous oxide, carbon dioxide and ozone columns in units of $`10^{20}`$ molecules per square centimetre. Optical depth $`\tau`$ measures absorption without units. Each spectral point $`g`$ represents part of the frequency band.

```math
\tau_g=
\begin{cases}
\tau_{w,n,g}+\tau_{s,g}+\tau_{f,g}+\widetilde C_c k_{c,g}+\tau_{a,g},&\text{lower atmosphere},\\
C_o k_{o,g}+\tau_{a,g},&\text{upper atmosphere}.
\end{cases} \tag{LW13-1}
```

The first lower-atmosphere term describes water and nitrous oxide absorption. The next two terms describe absorption caused by nearby water molecules and other air molecules. The coefficients $`k_{c,g}`$ and $`k_{o,g}`$ describe carbon dioxide and ozone absorption. The term $`\tau_{a,g}`$ is aerosol optical depth. The original band also evaluates a carbon monoxide coefficient with a zero column.

The tables use an empirical correction for abundant carbon dioxide. Let $`C_d`$ be dry-air column in molecules per square centimetre and let $`\chi_c=3.55\times10^{-4}`$ be its reference fraction.

```math
r=\frac{10^{20}C_c}{C_d\chi_c},\qquad
\widetilde C_c=
\begin{cases}
C_c,&r\leq3,\\
\left[2+(r-2)^{0.68}\right]\chi_c C_d\,10^{-20},&r>3.
\end{cases} \tag{LW13-2}
```

Use the unchanged empirical tables, pressure, temperature, gas columns and aerosol depth supplied by the forecast. The tables also supply a Planck fraction, which assigns thermal emission to each spectral point. This calculation has no time update or spatial boundary of its own. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol13.md) defines interpolation and the exact representations of constants.
