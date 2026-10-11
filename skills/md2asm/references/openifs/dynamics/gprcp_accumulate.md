# OpenIFS GPRCP Accumulate Contract

This contract identifies the complete ACCUMULATE child already written inside the accepted [GPRCP assembly](../../../../../src/openifs/dynamics/gprcp.S). It uses the same [moist-air formulation](../../../../../formulations/openifs/dynamics/thermodynamics.md) and [parent contract](gprcp.md). No arithmetic or assembly binary changes are required.

## Update And Host Arguments

The original contained routine has three explicit arguments. PX is one gas-constant or heat-capacity difference in joules per kilogram per kelvin. PGFL is the selected water mass fraction in kilograms per kilogram. POUT is the corresponding running mixture property. The parent supplies the matrix dimensions KPROMA and KFLEV and the active columns KSTART through KPROF. Each product and sum rounds separately to the nearest FP64 value, with ties to even.

```math
\mathrm{POUT}_{g,j}\leftarrow\operatorname{RN}_{64}
\left(\mathrm{POUT}_{g,j}+\operatorname{RN}_{64}
\left(\mathrm{PX}\,\mathrm{PGFL}_{g,j}\right)\right).
```

The parent visits the phases in the following order. ZR stores the running gas constant and ZCP stores the running heat capacity. A stage executes only when its input is present, its thermal flag is true, and its corresponding property is requested.

| Phase | PGFL argument | PX for ZR | PX for ZCP |
| --- | --- | --- | --- |
| Vapour | PQ | RV-RD | RCPV-RCPD |
| Liquid | PQL | -RD | RCW-RCPD |
| Ice | PQI | -RD | RCS-RCPD |
| Rain | PQR | -RD | RCW-RCPD |
| Snow | PQS | -RD | RCS-RCPD |
| Graupel | PQG | -RD | RCS-RCPD |

The assembly's water macro contains every listed multiply and add. It interleaves the independent gas and heat calculations while preserving each property's phase order. The full-column and partial-column source branches use the same active-cell update. Inactive cells remain unchanged. All pointers, bounds, alignment and register obligations follow the complete GPRCP interface. This child is included inside its parent and has no separate exported entry.

## Reused Acceptance

The unchanged parent passed 3,976 critical calls and 899,712 returned bytes per implementation with zero differences. Its independent mixture checks cover all six phases, thermal flags, absent outputs, complete and partial intervals, empty intervals, zero levels and subnormal fractions.

The accepted forecast capture contains 860 genuine separate-water parent calls, including 850 complete intervals and 10 partial intervals. These execute 8,600 child stages and 3,891,200 active-cell updates. Vapour, liquid, ice, rain and snow each execute both property stages 860 times. Graupel is thermally inactive in this forecast, while its selected calculation remains covered by the critical parent checks. The complete parent capture passes 81,643,584 bytes, including record headers, with zero differences and FPCR zero. Counting these saved stages changes no numerical code and requires no additional forecast.
