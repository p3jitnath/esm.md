# Cloud Ice Particle Size

Revision 1.0

Ice particles reflect and absorb radiation. Their effective radius is the radius of a sphere with a comparable optical effect. This radius is measured in micrometres, written as $`{\rm \mu m}`$. The air temperature is $`T`$ in kelvin and the air pressure is $`p`$ in pascals.

For the temperature-only options, the model estimates the radius from a cubic polynomial in temperature and keeps it within a stated range. The fixed option uses a radius of 40 micrometres.

The cloud-ice option first finds the mass of ice in each cubic metre of cloudy air. The cloud fraction $`c`$ is the fraction of the air volume occupied by cloud. The ice and snow mass fractions are $`q_i`$ and $`q_s`$ in kilograms per kilogram. The gas constant for dry air is $`R_d`$ in joules per kilogram per kelvin.

<!-- Equation ICE-1 -->
```math
I = \frac{1000p(q_i+q_s)}{R_dTc}.

```

Here, $`I`$ is the ice mass in grams per cubic metre of cloudy air. The temperature in degrees Celsius is $`T_C=T-273.16`$. An empirical relation estimates the ice diameter $`D`$ in micrometres.

<!-- Equation ICE-2 -->
```math
D=(1.2351+0.0105T_C)
\left[45.8966 I^{0.2214}+0.7957I^{0.2535}(T-83.15)\right].

```

The model limits the diameter to at most 155 micrometres. Its minimum is either a constant or a latitude-dependent value. The latitude is $`\phi`$ in radians and the configured equatorial minimum is $`D_0`$.

<!-- Equation ICE-3 -->
```math
D_{\min}=20+(D_0-20)\cos\phi,
\qquad
r=k_r\min\left(155,\max(D_{\min},D)\right).

```

The dimensionless factor $`k_r`$ converts diameter to effective radius. When cloud fraction is at most 0.001 or total ice is zero, the model uses $`80k_r`$ micrometres. An optional configured random perturbation multiplies the diameter before these limits are applied. This calculation diagnoses particle size and does not change the ice mass or temperature.

The configured forecast has 32 Gaussian latitude rows, a latitude-dependent minimum and the cloud-ice option. The [numerical contract](../../../skills/md2fort/references/openifs/physics/ice_particle_radius.md) gives the exact arithmetic, interface and supported input limits.
