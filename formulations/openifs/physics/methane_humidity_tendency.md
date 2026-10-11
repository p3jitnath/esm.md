# Methane humidity tendency

Revision 1 describes the local water source from methane oxidation and the water sink from sunlight that breaks water molecules apart. Pressure selects the reaction rate at each atmospheric cell.

The specific humidity $`q`$ is water mass per air mass in kg/kg, pressure $`p`$ is in Pa, and $`t`$ is time in seconds. The relaxation humidity $`q_*`$ is 4.81e-6 kg/kg. The inverse reaction times $`a(p)`$ and $`b(p)`$ are in 1/s. One model day has length $`D=86400`$ s.

**P01. Local water source and sink**

```math
\frac{dq}{dt}=a(p)\max(q_*-q,0)-b(p)q.
```

The maximum selects zero when humidity is already at or above the relaxation limit. Thus oxidation adds water to dry air, while photolysis removes water.

**P02. Oxidation rate**

```math
a(p)=
\begin{cases}
1/(100D), & 0\le p\le 50,\\
1/\{100D[1+A\ln^4(p/50)/\ln(10000/p)]\}, & 50<p<10000,\\
0, & p\ge10000,
\end{cases}
\qquad A=\frac{19\ln(10)}{\ln^4(20)}.
```

All pressure numbers are in Pa. The oxidation time is 100 days at low pressure, then grows towards the lower atmosphere. The natural logarithm $`\ln`$ makes its pressure ratios dimensionless.

**P03. Photolysis rate**

```math
b(p)=
\begin{cases}
1/(3D), & 0\le p\le0.1,\\
[\exp(B-C[1+\cos(\theta)])-0.01]/D, & 0.1<p<20,\\
0, & p\ge20,
\end{cases}
\qquad
\theta=\frac{\pi\ln(p/20)}{\ln(0.1/20)}.
```

The angle $`\theta`$ is in radians. The dimensionless coefficients are $`B=\ln(1/3+0.01)`$ and $`C=[\ln(100)+B]/2`$. The cosine joins a 3-day removal time at low pressure to a zero removal rate at 20 Pa.

Each cell starts from its supplied humidity and pressure. This calculation returns a rate; the caller advances time. It exchanges no water with neighbouring cells and has no spatial boundary flux. The model can supply other coefficients within the consumed physical bounds in the [md2asm contract](../../../skills/md2asm/references/openifs/physics/methox.md), which records ordered arithmetic and checks.
