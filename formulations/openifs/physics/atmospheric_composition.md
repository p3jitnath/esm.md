# OpenIFS atmospheric composition

Revision 1.0 describes the basic tracer balance in OpenIFS 48.1.1.

## The idea

A tracer is a gas or particle carried by air. Emissions add it, chemical reactions change it, and deposition removes it at the ground or through precipitation.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`q_j,\rho`$ | Tracer mass fraction in kilograms per kilogram and air density in kilograms per cubic metre |
| $`\mathbf v,\mathbf F_j`$ | Air velocity in metres per second and additional tracer flux in kilograms per square metre per second |
| $`P_j,L_j,E_j`$ | Chemical production, chemical loss and emission rates, in kilograms per kilogram per second |

## Equations

**P01. Tracer mass balance**

```math
\frac{\partial(\rho q_j)}{\partial t}
+\nabla\cdot(\rho q_j\mathbf v+\mathbf F_j)
=\rho(P_j-L_j+E_j).
```

The divergence measures net outflow from a small region. Chemical reactions transfer material between species, while emissions supply material from outside the tracked mixture. Deposition enters the flux or loss terms according to the configured process.

## Parameters, initial state, and boundaries

Species, reaction coefficients, emissions and deposition choices come from the upstream configuration and input data. Starting concentrations come from the forecast state. Surface emission and deposition provide lower-boundary fluxes. The current T21 evidence case has chemistry disabled and does not verify these processes.

The local CHEM_MAIN and chem_scav sources define chemistry and removal interfaces, identified by the [source record](../../../src/openifs/README.md). Reaction networks, units conversions and their complete ordered updates require md2asm contracts.
