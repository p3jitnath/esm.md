# Semi-Lagrangian Time and Map Factors

Revision 1. LASURE prepares factors for a semi-Lagrangian weather update, which follows air back to its earlier position.

Let $`\Delta t`$ be the timestep in seconds, $`\beta`$ the dimensionless implicit weight, and $`e`$ the dimensionless off-centering factor. Off-centering changes the weights of the two time levels.

```math
d=\frac{\Delta t}{2},\qquad b=d\beta,\qquad w_+=1+e,\qquad w_-=1-e.
```

The positive dimensionless map factor $`G`$ accounts for grid geometry. Let $`s>0`$ be the dimensionless stretch and $`A>0`$ the supplied map numerator. Choose the declared geometry branch.

```math
r=
\begin{cases}
1 & \text{implicit grid branch},\\
A/G^2 & \text{extended implicit branch},\\
s^2/G^2 & \text{stretch branch}.
\end{cases}
\qquad b_{\mathrm{map}}=br.
```

The time factor $`b_{\mathrm{map}}`$ has units of seconds. The map ratio $`r`$ is dimensionless. The implementation retains the original multiplication order, so these equations describe the physical relation.

Use a finite nonnegative timestep and implicit weight, $`-1\le e\le1`$, and positive finite consumed map inputs. The caller supplies the initial arrays and active column range. Leave columns outside that range unchanged.

The refined Coriolis flag is true when two-time-level refinement is enabled, physics is enabled, and lagged physics is disabled. Coriolis acceleration describes the effect of the Earth's rotation. The [md2fort contract](../../../skills/md2fort/references/openifs/dynamics/lasure.md) records the exact update and interface.
