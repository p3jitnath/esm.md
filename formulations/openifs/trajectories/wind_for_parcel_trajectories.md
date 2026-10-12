# Wind for Air Parcel Trajectories

A parcel is a small amount of air that moves with the wind. Its trajectory is the path it follows. This calculation prepares wind for that path calculation. Let $`u`$ be eastward wind and $`v`$ be northward wind, both in metres per second. Let $`\phi`$ be latitude and $`\lambda`$ be longitude, both in radians.

Cartesian components describe the same horizontal wind along three fixed axes through the Earth. They avoid choosing a special horizontal direction at a pole.

```math
u_x=-u\sin\lambda-v\cos\lambda\sin\phi, \qquad
u_y=u\cos\lambda-v\sin\lambda\sin\phi, \qquad
u_z=v\cos\phi. \tag{W01}
```

The vertical coordinate $`\eta`$ is dimensionless. Its rate $`w_\eta=D\eta/Dt`$ has units of inverse seconds, where $`D/Dt`$ follows the parcel. Supplied pressure fluxes and layer depths determine this rate through the existing pressure-coordinate relation.

Inputs are current and previous wind, pressure fluxes in pascals per second, layer pressure depths in pascals and the supplied latitude and longitude factors. The existing forecast has 2,048 horizontal points and 19 vertical levels. Use the supplied initial wind and boundaries.
