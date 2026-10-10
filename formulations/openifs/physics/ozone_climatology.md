# Ozone From Climatology

Revision 1.0.

Ozone absorbs radiation. A supplied climatology gives its average mixing ratio, which is ozone mass divided by air mass in kilograms per kilogram. This calculation places that profile on the model's latitude and pressure layers.

Let $`p`$ be pressure in pascals and $`s`$ the sine of latitude. Between neighbouring supplied latitudes, the weight $`w`$ and ozone mixing ratio $`q`$ are

```math
w=\frac{s-s_0}{s_1-s_0}, \qquad q=(1-w)q_0+wq_1. \tag{P01}
```

Interpolate the resulting profile linearly between its supplied pressure levels. Below the last supplied level, keep its final mixing ratio. The pressure-weighted ozone amount $`M`$ in a model layer is estimated from its two edge values.

```math
M_i=(p_{i+1}-p_i)\frac{q(p_i)+q(p_{i+1})}{2}. \tag{P02}
```

The output $`M_i`$ has units of pascals. Dividing it by gravity gives ozone mass per square metre. The trapezoid in P02 is exact for a profile that is linear across the layer.

## Supplied State And Boundaries

Supply finite, nonnegative ozone profiles and strictly increasing latitude and pressure coordinates. The usual climatology has 19 latitudes and 36 pressure points. Its first and last latitude intervals use profiles 1 and 18 respectively. The aquaplanet option has 64 latitudes and 61 pressure points, with nearest-profile values outside the latitude range. Pressure must be at or below the top climatology boundary. Process the requested columns, spacing and destination shift. Other output cells stay unchanged.
