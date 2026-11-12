# Soil Water Transfer

Revision 1.

Soil stores liquid water and ice. Rain enters at the surface, roots remove liquid water, and gravity carries water between layers. Each soil layer has thickness $`h_k`$ in metres and water fraction $`w_k`$ in cubic metres per cubic metre.

```math
\rho_w h_k \Delta w_k = \Delta t \left(F_{k-1}-F_k+S_k\right). \tag{WT-1}
```

Here $`\rho_w=1000`$ kilograms per cubic metre is water density. The time interval $`\Delta t`$ is in seconds. The downward water flux $`F_k`$ and the source $`S_k`$ are in kilograms per square metre per second. A source is positive when it adds water. The equation states that water gained by a layer equals water entering it minus water leaving it.

The relative wetness $`s`$ is zero at the residual water fraction and one at saturation. The Van Genuchten relation gives the downward conductivity $`K`$ in metres per second.

```math
s = \frac{w-w_r}{w_s-w_r}, \qquad K = K_s s^\ell \left[1-\left(1-s^{1/m}\right)^m\right]^2. \tag{WT-2}
```

Here $`w_r`$ is residual wetness, $`w_s`$ is saturated wetness, and $`K_s`$ is saturated conductivity. The dimensionless constants $`\ell`$ and $`m`$ describe the soil. Ice reduces the liquid conductivity. The caller supplies soil and vegetation tables, layer depths, temperatures, rain, snowmelt, evaporation and tile fractions. Tile fractions describe the parts of one grid cell covered by water, vegetation, bare soil and urban surfaces. The bottom boundary permits gravity drainage. The verified numerical contract is [SRFWEXC_VG](../../../skills/md2fort/references/openifs/surface/srfwexc_vg.md).
