# Transport Equation Terms

Wind, temperature and material fields change as air moves. The forecast stage LATTEX prepares their source terms before transport and converts temperature between physical and terrain-corrected coordinates.

Let u and v be horizontal wind in metres per second, f be the Coriolis parameter in inverse seconds, and a_u and a_v be supplied wind tendencies in metres per second squared. The wind source combines a_u+fv and a_v-fu. Coriolis acceleration does no instantaneous work because u(fv)+v(-fu) equals zero.

The temperature source combines the supplied temperature tendency with the horizontal and vertical change of a supplied terrain correction. Temperature has units of kelvin. The dry-air gas constant, reference temperature, surface geopotential and vertical correction arrays determine that correction. The caller also adds the current value of each transported material field to its transport buffer.

The local verified contract covers the genuine hydrostatic two-time-level, finite-element route with three-point transport and inactive diagnostics. The forecast supplies initial state, boundaries and forcing. Complete forecast physics remains a separate requirement.
