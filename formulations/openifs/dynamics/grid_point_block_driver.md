# Grid-Point Block Driver

Formulation revision 1 groups the column calculations used by CPG_DRV. A block is a small group of neighbouring atmospheric columns. The driver visits every block and applies the same [complete grid-point update](complete_grid_point_update.md).

Let $`q_{i,k}`$ be an atmospheric field at global horizontal cell $`i`$ and level $`k`$. Let $`b`$ identify a block and $`j`$ identify a column within that block. These indices have no unit. Equation CPGDRV-P01 expresses the same field through its block position, preserving its physical unit.

```math
q^{\mathrm{block}}_{j,k,b}=q_{24(b-1)+j,k}\qquad\text{(CPGDRV-P01)}
```

Wind uses metres per second, temperature uses kelvin, pressure uses pascals and constituent mass fractions use kilograms per kilogram. The child formulation defines their physical equations and parameters.

The selected forecast has 2,048 horizontal cells, 19 levels and 86 blocks. Each allocated block has 24 columns, while the last block has eight active columns. The surrounding forecast supplies the initial state, time intervals and global boundaries. Processing a block changes no boundary condition and adds no physical model.

The LLM uses [md2asm](../../../skills/md2asm/SKILL.md) to record the [assembly contract](../../../skills/md2asm/references/openifs/dynamics/grid_point_block_driver.md).
