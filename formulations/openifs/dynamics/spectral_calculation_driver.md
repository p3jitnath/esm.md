# Spectral Forecast Update

Formulation revision 1 groups the physical updates used by SPCM. A spectral field describes a global atmospheric field through wave coefficients. Each coefficient gives the strength of a spatial wave. This update treats fast atmospheric waves, Earth's rotation and the smoothing of small waves through horizontal diffusion.

The physical equations are the frozen [semi-implicit wave equations](spectral_semi_implicit_update.md), [rotating atmospheric motion](atmospheric_motion.md) and [horizontal diffusion](spectral_horizontal_diffusion.md). Their parameters and initial states remain unchanged.

The work buffers hold the same physical coefficients. Let $`q_{k,n}`$ be a coefficient at atmospheric level $`k`$ and wave position $`n`$. Equation SCD-1 states that moving a coefficient preserves its value and physical unit.

```math
q_{k,n}^{\mathrm{destination}}=q_{k,n}^{\mathrm{source}} \qquad \text{(SCD-1)}
```

Vorticity describes spinning motion and divergence describes spreading motion. Both coefficients use inverse seconds. Temperature uses kelvin, and logarithmic surface pressure is dimensionless. The rotation correction uses the units defined in its own formulation.

The coarse forecast supplies 19 vertical levels and retains spatial wave degrees through 21. Its initial state and fixed coefficient tables come from the surrounding forecast. Longitude wraps around Earth, and the spherical waves represent both poles. This grouping adds no new physical parameter or boundary condition.

The LLM uses [md2fort](../../../skills/md2fort/SKILL.md) to derive the [complete assembly contract](../../../skills/md2fort/references/openifs/dynamics/spectral_calculation_driver.md).
