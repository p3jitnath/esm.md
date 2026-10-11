# Heat Flow In Soil

Revision 1 supplies the physics for complete OpenIFS `SRFT_MOD::SRFT`.

Soil stores heat and passes it between neighbouring layers. Let $`T`$ be temperature in kelvin, $`z`$ depth in metres, $`C`$ heat capacity in joules per cubic metre per kelvin and $`\lambda`$ thermal conductivity in watts per metre per kelvin. The heat equation is

```math
C\frac{\partial T}{\partial t}
=\frac{\partial}{\partial z}
 \left(\lambda\frac{\partial T}{\partial z}\right).
\tag{ST-1}
```

At the upper boundary, sunlight, infrared radiation, sensible heat, evaporation and heat from snow supply a net heat flux $`Q`$ in watts per square metre. Sensible heat means energy transferred by a temperature difference. The lower boundary has no heat flux. Surface fractions weight the supplied tile fluxes, with the original land-area adjustment beside lakes.

Water and ice change conductivity. A smooth frozen-water fraction connects 270.16 and 274.16 kelvin. The source model uses water conductivity 0.57 and ice conductivity 2.2 watts per metre per kelvin, with supplied soil-dependent dry and saturated coefficients. Urban cover adds its supplied conductivity.

Inputs provide layer thickness, soil temperature, water fraction, heat capacity and surface fluxes. Land columns evolve. Other columns retain their supplied temperatures and have zero soil heat flux. The initial state and surface masks come from the frozen forecast inputs.
