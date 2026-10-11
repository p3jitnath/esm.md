# Spherical Boundary Values

Revision 1. Weather fields on a latitude and longitude grid need neighbouring values at a pole or where longitude wraps around the Earth. A halo is a small row of extra values outside the local grid. Each field keeps its supplied units, such as kelvin for temperature or metres per second for wind.

Longitude $`\lambda`$ is measured in radians and repeats after one full turn. The latitude beyond a pole represents a point on the other side of that pole. At the north pole the corresponding latitude and longitude are $`\pi-\phi`$ and $`\lambda+\pi`$, where $`\phi`$ is latitude in radians.

```math
f(\phi,\lambda+2\pi)=f(\phi,\lambda), \qquad f(\pi-\phi,\lambda+\pi)=p f(\phi,\lambda).
```

The parity $`p`$ is one for a field whose value keeps its sign across the pole and minus one for a component whose direction reverses. Supplied grid maps identify the matching points. Copy the appropriate longitude and pole values into the halo, then record which source points an on-demand communication needs.
