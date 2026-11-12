# Cloud Droplet Radius

Revision 1.

A cloud contains many small liquid drops. Their effective radius measures how strongly they scatter radiation. This formulation describes the Martin cloud-drop model with a rain adjustment, as used by OpenIFS LIQUID_EFFECTIVE_RADIUS.

Pressure $`p`$ is in pascals, temperature $`T`$ is in kelvin, and cloud fraction $`c`$ is between zero and one. Liquid and rain mixing ratios $`q_l`$ and $`q_r`$ give kilograms of water per kilogram of moist air. The gas constant $`R_d`$ is 287.06 J kg⁻¹ K⁻¹ in the physical check. The model converts these inputs to in-cloud water contents $`L`$ and $`W`$ in grams per cubic metre.

```math
\rho = \frac{1000p}{R_dT},\qquad L = \frac{\rho q_l}{c},\qquad W = \frac{\rho q_r}{c}. \tag{CDR-1}
```

Cloud condensation nuclei are small particles on which drops form. Their concentration $`C`$ is in particles per cubic centimetre. The activated drop concentration $`N`$ and the dimensionless spread $`d`$ depend on whether land covers at least half of the cell.

```math
(N,d) =
\begin{cases}
(-0.00115C^2+0.963C+5.30,\ 0.77), & \text{sea},\\
(-0.000210C^2+0.568C-27.9,\ 0.69), & \text{land}.
\end{cases} \tag{CDR-2}
```

The volume per drop gives the radius. Rain changes this estimate through the dimensionless factor $`f`$. The source uses the decimal powers shown below.

```math
z = (0.222/d)^{0.333},\qquad
f = \frac{(1+W/L)^{0.666}}{1+0.2zW/L},\qquad
r = 100f\left(\frac{3(L+W)}{4\pi Nd}\right)^{0.333}. \tag{CDR-3}
```

The returned radius is in micrometres and is limited to 4–30 µm. A clear cell or a cell with too little water returns 4 µm. The rain factor is one when liquid water is below the source threshold. This is a diagnostic calculation, so it needs no time step or physical boundary condition. Optional prescribed perturbations multiply the drop concentration by an exponential factor. The source also offers a simple 10 µm land and 13 µm sea option. Numerical order, source thresholds, the legacy pressure option and the supported inputs are defined in the [solver contract](../../../skills/md2fort/references/openifs/physics/cloud_droplet_radius.md).
