# Weather State Increments

Revision 1 describes `STATE_INCREMENT`. Each physical process supplies a change to the weather state. Adding that change gives the state after the process.

Let $`X`$ be one state field and $`\Delta X`$ be its supplied change, in the same units. Equation I1 applies independently to each selected grid cell.

```math
X_{\mathrm{new}}=X_{\mathrm{old}}+\Delta X.
\tag{I1}
```

| Field | Meaning | Units |
| --- | --- | --- |
| $`U,V`$ | Two horizontal wind components | m s⁻¹ |
| $`T`$ | Temperature | K |
| $`O_3,Q`$ | Ozone and water-vapour mass fractions | kg kg⁻¹ |
| $`A`$ | Cloud fraction | Dimensionless |
| $`Q_l,Q_i,Q_r,Q_s`$ | Liquid cloud water, cloud ice, rain and snow mass fractions | kg kg⁻¹ |
| TKE | Turbulent kinetic energy, the energy of small unresolved motions per unit mass | m² s⁻² |

Supply the initial state and any requested field changes. The increments already include the physical process's time interval. A missing increment leaves its field unchanged. Wind and temperature use each supplied increment. The other fields also require their model field mask, which is a flag that enables that field. Changes must leave the physical state admissible, with positive temperature, nonnegative water and energy, and fractions between zero and one.

Apply Equation I1 over every level in the selected columns. Other columns and disabled fields keep their incoming bytes. There is no neighbour boundary condition. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/state_increment.md) fixes storage, field masks, rounding and the interface.
