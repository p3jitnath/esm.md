# OpenIFS vertical mixing

Revision 1.0 describes the basic turbulent transport balance in OpenIFS 48.1.1.

## The idea

Small air motions mix moisture, energy and momentum between heights. A flux describes the amount transported through one square metre each second. OpenIFS combines transport along a local gradient with additional plume transport.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`z,t,\rho`$ | Height in metres, time in seconds and air density in kilograms per cubic metre |
| $`\chi`$ | Transported quantity, such as water fraction in kilograms per kilogram |
| $`K`$ | Mixing coefficient in square metres per second |
| $`F_\chi`$ | Upward transport flux, with the unit of $`\chi`$ multiplied by kilograms per square metre per second |
| $`F_{\rm plume},S_\chi`$ | Additional plume flux and local rate of change of $`\chi`$ |

## Equations

**P01. Mixing flux**

```math
F_\chi=-\rho K\frac{\partial\chi}{\partial z}+F_{\rm plume}.
```

The gradient term transports a quantity towards smaller values. The plume term represents transport that the local gradient alone does not describe.

**P02. Layer balance**

```math
\frac{\partial(\rho\chi)}{\partial t}
=-\frac{\partial F_\chi}{\partial z}+\rho S_\chi.
```

This equation describes the mixing contribution, with large-scale transport treated separately. A layer gains a quantity when more enters than leaves. The source has the unit of $`\chi`$ per second.

## Parameters, initial state, and boundaries

Mixing coefficients depend on atmospheric stability, wind and the configured scheme. The energy and moisture variables must match that scheme, including its treatment of liquid water and ice. Initial profiles come from the forecast. Surface exchange supplies the bottom flux, while the configured atmosphere supplies the upper boundary condition.

The local VDFMAIN and VDFDIFH sources define the coupled energy, water and surface updates, identified by the [source record](../../../bench/openifs/EVIDENCE.md#source). Their coefficients and complete numerical update belong in md2asm contracts.
