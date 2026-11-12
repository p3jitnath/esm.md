# Sun's Irradiance

Formulation revision 1. This input describes the solar energy supplied to the atmosphere. The numerical contract is [solar_irradiance.md](../../../skills/md2fort/references/openifs/physics/solar_irradiance.md).

Irradiance is power received per unit area, in watts per square metre. The table gives total solar irradiance at the mean Earth–Sun distance, called one astronomical unit. A decimal year gives the forecast date. For example, 2004.5 is near the middle of 2004.

Let $`y_j`$ be a table date and $`I_j`$ its irradiance in W m⁻². Between neighbouring dates, assume that irradiance changes along a straight line.

**SI1 — Irradiance between records**

```math
I(y)=I_j+\frac{y-y_j}{y_{j+1}-y_j}(I_{j+1}-I_j),
\qquad y_j\le y<y_{j+1}.
```

The forecast uses the supplied 450-record climate table, covering 1850.5 to 2299.5. Its current dates, 2004.786 to 2004.789, lie within that range. The lookup has no evolving state. Use positive table irradiance and strictly increasing dates. This supported calculation uses dates strictly between the first and final records.
