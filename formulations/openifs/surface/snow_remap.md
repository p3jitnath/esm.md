# Mass and Heat in Changing Snow Layers

Revision 1.0 describes the physical input for OpenIFS 48.1.1 `SRFSN_REGRID_MOD::SRFSN_REGRID`. When layer boundaries change, the snowpack must keep its total mass and heat. A layer contains snow mass $`m`$ and liquid-water mass $`w`$ in kilograms per square metre. Its density $`\rho`$ is in kilograms per cubic metre and its temperature $`T`$ is in kelvin.

P01 gives layer depth $`h`$ in metres.

```math
h=\frac{m}{\rho}.
```

P02 gives heat per square metre, $`E`$, relative to liquid water at the freezing temperature $`T_f`$. Cooling lowers this heat, and freezing also lowers it.

```math
E=c_i m(T-T_f)-L_f(m-w).
```

Use $`T_f=273.16\,\mathrm{K}`$, $`c_i=2050000/920\,\mathrm{J\,kg^{-1}\,K^{-1}}`$ and $`L_f=333700\,\mathrm{J\,kg^{-1}}`$. The input supplies each old layer's mass, density, liquid water and temperature, plus the requested new depths. Both sets of layers cover the same total depth. Masses and depths are nonnegative, density is positive, liquid water is no greater than total mass, and temperature is between 100 kelvin and freezing.

P03 requires the new layers to keep the total mass and heat.

```math
\sum_j m_j^{\mathrm{new}}=\sum_j m_j^{\mathrm{old}},
\qquad
\sum_j E_j^{\mathrm{new}}=\sum_j E_j^{\mathrm{old}}.
```

Each column is a closed snowpack, with no mass or heat entering through its surface or base during this change. The no-snow mask and an all-liquid state keep their supplied fields. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/snow_regrid.md) defines the layer overlap, ordered arithmetic and verification.
