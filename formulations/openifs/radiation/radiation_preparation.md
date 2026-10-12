# Radiation Preparation

Revision 1 preserves the selected OpenIFS coarse-forecast physics. Radiation depends on the surface and clouds. This routine prepares the surface reflectivity, which is the fraction of incoming radiation that is reflected, and the emissivity, which describes the surface emission of heat radiation. Both fractions are dimensionless.

The wind speed near the surface combines the eastward speed $`u`$ and the northward speed $`v`$, each in metres per second.

```math
w=\sqrt{u^2+v^2}.
```

The physical energy bounds use reflectivity $`a`$ and emissivity $`e`$.

```math
0\leq a\leq1,
\qquad
0\leq e\leq1.
```

Temperature is in kelvin and pressure is in pascals. The saturation calculation gives the equilibrium water-vapour mass fraction. The cloud calculation prepares cloud probabilities and copies the selected liquid-water and ice fields into the radiation input. Those copies are diagnostic fields and do not form a new water-mass update.

The initial state, surface categories, cloud settings, date and physical constants come from the retained coarse-forecast inputs. The selected cloud route uses the prognostic cloud fields. The parent calls the existing surface, calendar, saturation and cloud calculations. Its numerical contract records their complete ordered work and output storage.
