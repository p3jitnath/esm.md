# Boundary-Layer Height

Revision 1 describes the complete OpenIFS VDFHGHTN calculation. The boundary layer is the lowest part of the atmosphere, where surface heating and friction strongly affect the air. The calculation follows a rising parcel of air to estimate the layer height and its upward transport.

The parcel has temperature $`T`$ in kelvin, height $`z`$ in metres, water-vapour fraction $`q`$ and condensed-water fraction $`q_\ell`$, both in kilograms per kilogram. Its total water is $`q_t`$. Its energy per unit mass $`s_\ell`$, in joules per kilogram, includes heat, height and the energy needed to form condensed water.

```math
q_t=q+q_\ell,
\qquad
s_\ell=c_pT+gz-L(T)q_\ell
\tag{BL-1}
```

The heat capacity $`c_p`$ is in joules per kilogram per kelvin. Gravity $`g`$ is in metres per second squared. The latent heat $`L(T)`$ is in joules per kilogram and uses the supplied liquid or ice value.

A rising parcel can reach an inversion, where stable air limits further ascent. Surface buoyancy, parcel speed and the Richardson number determine the height. The Richardson number compares stable density layering with wind shear. Cloud-base and cloud-top levels distinguish a dry layer, a shallow cloud layer and a layer below deeper convection.

The upward mass flux $`M`$ is the transported mass per unit area per second. It depends on air density $`\rho`$, the rising area fraction $`a`$ and parcel speed $`w`$.

```math
M=\rho a w
\tag{BL-2}
```

The input supplies atmospheric temperature, humidity, wind, pressure, height, energy and surface fluxes. Pressure increases towards the ground, while height decreases. Gravity, heat capacity, latent heats and cloud parameters come from the fixed model configuration. The initial state is the supplied atmospheric column. The ground mass flux is zero, and columns outside the selected interval retain their output bytes. The [solver contract](../../../skills/md2asm/references/openifs/physics/vdfhghtn.md) specifies the ordered calculations and supported input range.
