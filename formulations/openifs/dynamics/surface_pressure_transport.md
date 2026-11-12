# Surface-Pressure Transport

This part of the weather model uses the continuity equation, which states that air mass changes when air flows into or out of a region. It prepares the transported terms for the logarithm of surface pressure.

The surface pressure $`p_s`$ is in pascals. The wind components $`u`$ and $`v`$ are in metres per second. The horizontal gradient $`\nabla_h`$ measures change across the surface. The material derivative $`D/Dt`$ follows the moving air.

```math
\frac{D\ln p_s}{Dt}=-\frac{1}{p_s}\int \nabla_h\cdot(p\mathbf{v}_h)\,d\eta.
```

Here $`\eta`$ is a dimensionless vertical coordinate, $`p`$ is pressure, and $`\mathbf{v}_h=(u,v)`$ is the horizontal wind. The vertical integral combines the layers of the air column. The supplied pressure, wind, terrain and previous time state set the inputs. This routine prepares terms inside an existing forecast and introduces no new boundary condition.

The [LATTES contract](../../../skills/md2fort/references/openifs/dynamics/lattes.md) records the time scheme, arithmetic, field maps and accepted configurations. The physical input has revision 1 and equation ID LATTES-P1.
