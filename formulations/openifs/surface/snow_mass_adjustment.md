# Snow Mass At Warm Start

Revision 1 gives the physics for complete OpenIFS `SURFWS_MASSADJ_MOD::SURFWS_MASSADJ`.

A warm start builds a layered snow state from supplied initial data. Let $`m_k`$ be snow mass per area in kilograms per square metre, $`\rho_k`$ its density in kilograms per cubic metre and $`h_k`$ the provisional layer depth in metres. The total supplied snow mass $`M`$ must be preserved.

```math
\sum_k m_k=M.
\tag{SM-1}
```

An exponential profile provides an initial density shape. The adjustment changes its trial top and bottom densities, then changes individual layer densities to reduce the mass error. A final residual changes the accumulation layer mass. That layer can therefore have a new implied depth $`m_k/\rho_k`$.

Liquid water is diagnosed from snow mass, density and temperature. The model uses a melting temperature of 273.16 kelvin, a four-kelvin transition and a density-dependent storage fraction between 0.03 and 0.1. Glacier columns start with zero liquid water.

Inputs supply layer depths, active layer counts, profile coefficients, initial densities and temperatures. Columns below the supplied snow-depth threshold keep their current state. This routine builds an initial state and has no time step or external mass flux.
