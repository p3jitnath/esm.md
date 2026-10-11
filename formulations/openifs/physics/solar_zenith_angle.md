# Sunlight On An Atmospheric Column

Revision 1.

The Sun supplies more energy to a horizontal surface when it is higher in the sky. The cosine of the solar zenith angle gives this geometric factor. The zenith is the direction straight above a location.

Let $`\phi`$ be latitude, $`\delta`$ the Sun's declination, and $`h`$ the local hour angle. All three angles use radians. Declination is the Sun's angle north or south of the equator, and the hour angle is zero at local solar noon. The sunlight factor is dimensionless.

```math
\mu(t)=\max\left(0,\sin\phi\sin\delta+\cos\phi\cos\delta\cos h(t)\right).
```

The value is zero at night and at the horizon. A value of one means that the Sun is directly overhead. For the Earth's daily rotation, the hour angle increases by $`2\pi`$ during 86,400 seconds.

The model can use the value at the centre of a time interval or its average. The model-step average includes the complete interval. The radiation calculation can instead average only over the part when the Sun is above the horizon, because it uses this value to calculate the solar beam's path through the atmosphere.

Latitude, longitude, the Sun's declination, the interval's centre and its duration are inputs. Declination is held fixed during each interval. There is no evolving state in this calculation. The [md2asm contract](../../../skills/md2asm/references/openifs/physics/cos_sza.md) gives the supported time windows, numerical method and output checks.
