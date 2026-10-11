# Longwave Water, Carbon Dioxide And Nitrous Oxide Absorption

Revision 1 describes absorption of Earth's thermal radiation between 500 and 630 inverse centimetres. Water vapour and carbon dioxide absorb this radiation in the lower atmosphere. The water–carbon-dioxide mixture remains active above the tropopause, the boundary between the lower and upper atmosphere. Nitrous oxide and aerosols add absorption in both regions.

Let $`C_w`$, $`C_m`$ and $`C_n`$ be the water, carbon dioxide and nitrous oxide columns, measured in units of $`10^{20}`$ molecules per square centimetre. Optical depth $`\tau`$ is a dimensionless measure of absorption. Larger depth means less transmitted radiation. Each spectral point represents a small part of the frequency band.

```math
\tau_g=\tau_{w,m,g}+\tau_{s,g}+\tau_{f,g}+\widetilde C_n k_{n,g}+\tau_{a,g}. \tag{LW3-1}
```

The first term describes main water–carbon dioxide absorption. The next two terms describe water absorption due to nearby water molecules and other air molecules. The self-water term vanishes in the upper atmosphere. Absorption due to other air molecules remains active. The coefficient $`k_{n,g}`$ describes nitrous oxide absorption, and $`\tau_{a,g}`$ describes aerosol absorption.

The empirical tables correct the nitrous oxide column when its abundance greatly exceeds the reference atmosphere. Let $`C_d`$ be the dry-air column in molecules per square centimetre and $`\chi_n`$ the dimensionless reference nitrous oxide fraction.

```math
r=\frac{10^{20}C_n}{C_d\chi_n},\qquad
\widetilde C_n=
\begin{cases}
C_n,&r\leq1.5,\\
\left[0.5+(r-0.5)^{0.65}\right]\chi_n C_d\,10^{-20},&r>1.5.
\end{cases} \tag{LW3-2}
```

Use the original empirical tables, pressure, temperature and gas columns supplied by the forecast. The tables also provide the Planck fraction, which assigns thermal emission to each spectral point. This calculation has no time update or spatial boundary of its own. Its interpolation and assembly interface are defined in the [md2asm contract](../../../skills/md2asm/references/openifs/physics/rrtm_taumol3.md).
