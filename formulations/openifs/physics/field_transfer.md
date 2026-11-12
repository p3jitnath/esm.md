# Weather Field Transfer And Update

Revision 1 describes `UPDATE_FIELDS`. A weather model passes fields between physical calculations and updates them with rates of change. Each field retains its own units, such as kelvin for temperature or metres per second for wind.

Let $`X`$ be the incoming field, $`A`$ and $`S`$ rates that add to and subtract from the field, and $`\Delta t`$ the physics time interval in seconds. Let $`I_A`$ and $`I_S`$ be supplied increments in field units. Equation F1 gives the time update.

```math
X_{\mathrm{new}}=X+\Delta t(A-S)+I_A-I_S.
\tag{F1}
```

A transfer without a time update uses Equation F2.

```math
X_{\mathrm{new}}=X+I_A-I_S.
\tag{F2}
```

Supply up to thirteen fields. Each supplied output can have an activation flag. An absent output or a false flag disables that field. The incoming field can be supplied separately or kept in the output buffer. Omit an increment or subtraction rate when it is zero. The time update always needs its addition rate for each active field.

Apply the chosen equation at selected horizontal columns and all supplied levels. Other cells and disabled fields retain their incoming output values. Choose rates and increments that keep each physical field admissible, such as positive temperature and nonnegative water. No neighbour boundary condition is needed. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/update_fields.md) fixes storage, arithmetic and optional arguments.
