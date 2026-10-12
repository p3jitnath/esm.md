# Spherical Trajectory And Interpolation

Air moves across a spherical Earth and carries physical fields such as heat and water. This calculation traces air backwards to its earlier position, then finds nearby stored field values. Longitude and latitude are angles in radians. The vertical coordinate is dimensionless.

Let $`\boldsymbol r`$ be position in the model's coordinates, $`\boldsymbol v`$ be velocity in the corresponding coordinate units per second and $`t`$ be time in seconds.

```math
\frac{d\boldsymbol r}{dt}=\boldsymbol v.
```

Use the supplied time interval, arrival positions, earlier winds, full and half levels and model boundaries. Keep the earlier vertical position between the supplied lower and upper limits. The md2asm contract chooses the numerical update and interpolation weights, retaining the original source order and output bytes.

Physical source is OpenIFS LAPINEA, with its Cartesian LARMES_XYZ trajectory and full-level LARCINA interpolation calculation.
