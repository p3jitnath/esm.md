# Spectral Pressure Mass Correction

Formulation revision 1 describes the small global pressure adjustment used by SPCMASCOR. A spectral coefficient gives the strength of one spatial wave. The coefficient with zero wave degree represents a constant contribution across Earth.

Let $`a_0`$ be that coefficient of logarithmic surface pressure, with no unit. Let $`M`$ be the current atmospheric mass and $`M_0`$ its reference value, both in kilograms. The dimensionless correction is $`\delta=\ln(M/M_0)`$. The model supplies this correction from its existing mass calculation.

```math
a_0^{\mathrm{corrected}}=a_0-\delta \qquad \text{(SPM-1)}
```

Equation SPM-1 changes the constant pressure contribution and leaves every other wave coefficient unchanged. The input is the current pressure field and its supplied mass correction. Longitude wraps around Earth, and the spherical waves represent both poles.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to derive the [assembly contract](../../../skills/md2asm/references/openifs/dynamics/spectral_pressure_mass_correction.md).
