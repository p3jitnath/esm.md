# Longwave Layer Energy

Revision 1 describes thermal radiation through one atmospheric layer. Warm air, clouds and the ground emit this radiation. A two-stream model represents diffuse radiation with one upward flux and one downward flux. A flux is energy crossing unit area per second. Each spectral entry represents one group of wavelengths.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`x,\tau`$ | Downward optical-depth coordinate and total layer optical depth, both dimensionless |
| $`U,D`$ | Upward and downward radiation flux, in $`\mathrm{W\,m^{-2}}`$ |
| $`B_t,B_b,B(x)`$ | Thermal source at the top, bottom and within the layer, in $`\mathrm{W\,m^{-2}}`$ |
| $`a,b`$ | Removal and transfer coefficients, both dimensionless |
| $`R,T`$ | Reflected and transmitted fractions, both dimensionless |
| $`S_u,S_d`$ | Radiation emitted from the layer towards each boundary, in $`\mathrm{W\,m^{-2}}`$ |

Optical depth measures how strongly radiation interacts with matter. The coordinate $`x`$ increases from zero at the top to $`\tau`$ at the bottom. A derivative below describes how a flux changes per unit optical depth.

## Equations

**P01. Linear thermal source**

For a layer with $`\tau>0`$, the thermal source changes smoothly between its supplied boundary values.

```math
B(x)=B_t+(B_b-B_t)\frac{x}{\tau}.
```

**P02. Radiation balance**

```math
\frac{dU}{dx}=aU-bD-(a-b)B(x),\qquad
\frac{dD}{dx}=bU-aD+(a-b)B(x).
```

The coefficients describe removal from a stream and transfer into the other stream. The difference $`a-b`$ describes absorption and thermal emission. The signs differ because the upward stream travels against the downward coordinate.

**P03. Boundary response**

```math
U(0)=R D(0)+T U(\tau)+S_u,\qquad
D(\tau)=T D(0)+R U(\tau)+S_d.
```

Each outgoing flux contains reflected incoming radiation, transmitted radiation from the opposite boundary and emission from the layer.

## Parameters, state and boundaries

The caller supplies nonnegative optical depth and thermal sources, with $`a\ge b\ge0`$. These quantities can differ between layers and spectral entries. The calculation describes one instant, so it has no separate time initial state. Incoming downward flux enters at the top, and incoming upward flux enters at the bottom. A transparent layer has $`\tau=0`$, $`R=0`$, $`T=1`$ and zero emission.

The [md2fort skill](../../../skills/md2fort/SKILL.md) supplies the numerical method, supported input limits, ordered arithmetic, storage and verification in the [solver contract](../../../skills/md2fort/references/openifs/radiation/longwave_layer_transport.md).
