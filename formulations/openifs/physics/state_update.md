# Weather State Time Update

Revision 1 describes `STATE_UPDATE`. A tendency is a rate of change supplied by the physical processes. Multiplying this rate by a time interval gives the change in a state field.

Let $`X`$ be a state field, $`\dot X`$ its tendency in field units per second, and $`\Delta t`$ the physics time interval in seconds. Equation U1 gives the state at the end of the interval.

```math
X_{\mathrm{new}}=X_{\mathrm{initial}}+\Delta t\,\dot X.
\tag{U1}
```

The [state field table](state_increments.md) defines wind, temperature, ozone, vapour, cloud fraction, cloud water and turbulent kinetic energy. Supply the initial fields, their tendencies and a finite nonnegative time interval. Tendencies must leave the physical state admissible, with positive temperature, nonnegative water and energy, and fractions from zero to one.

Apply Equation U1 to wind and temperature at all selected cells. Other fields also need their output state's field mask, which is a flag that enables each field. Disabled fields and cells outside the selected columns or levels keep the output owner's incoming values. Liquid water, ice, rain and snow update their components in the combined cloud array. No neighbour boundary condition is required. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/state_update.md) fixes rounding, storage and the interface.
