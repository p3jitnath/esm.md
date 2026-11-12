# Vertical Mixing Rates

Formulation revision 1 groups VDFMAIN and VDFOUTER. Turbulent air motion mixes wind, heat and water between atmospheric layers. The lowest layer also exchanges momentum, heat and water with the surface. A tendency is the rate of change of a state per second.

Wind uses metres per second, temperature uses kelvin and water mass fractions use kilograms per kilogram. Their tendencies use metres per second squared, kelvin per second and inverse seconds. Heat flux uses watts per square metre and water flux uses kilograms per square metre per second. The unchanged [momentum-diffusion equations](implicit_momentum_diffusion.md) and [increment equations](vertical_diffusion_increments.md) define the existing child physics.

The forecast supplies pressure, height, state, incoming rates, surface tiles and mixing coefficients. The selected case has 19 atmospheric levels, four soil layers and nine surface tiles. Child models retain the supplied top and surface flux conditions. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/vertical_diffusion_rates.md) records the ordered complete updates and interfaces.
