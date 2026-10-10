# OpenIFS ocean waves

Revision 1.0 describes the basic wave-action balance in the wave component of OpenIFS 48.1.1.

## The idea

Wind supplies energy to sea waves. Waves travel, change direction and lose energy through breaking and bottom friction. Wave action accounts for changes in wave frequency caused by currents and varying water depth.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`\sigma,\theta`$ | Wave angular frequency in radians per second and direction in radians |
| $`E,N`$ | Energy spectrum in joules per square metre per unit angular frequency and direction, and action spectrum $`E/\sigma`$ |
| $`\mathbf c_g,\mathbf U`$ | Wave group velocity and water current in metres per second |
| $`\dot\sigma,\dot\theta`$ | Rates of change of frequency in radians per second squared and direction in radians per second |
| $`S_E`$ | Rate of change of the energy spectrum per second |
| $`k,h,g`$ | Wavenumber in inverse metres, depth in metres and gravity in metres per second squared |

## Equations

**P01. Wave action**

```math
N=\frac{E}{\sigma}.
```

Dividing energy by the intrinsic frequency gives the action transported by the waves.

**P02. Transport and sources**

```math
\frac{\partial N}{\partial t}
+\nabla_h\cdot[(\mathbf c_g+\mathbf U)N]
+\frac{\partial(\dot\sigma N)}{\partial\sigma}
+\frac{\partial(\dot\theta N)}{\partial\theta}
=\frac{S_E}{\sigma}.
```

The terms describe travel over the sea and movement through frequency and direction. The horizontal divergence follows the Earth's surface. Sources include wind input, transfers between waves and energy losses.

**P03. Gravity-wave dispersion**

```math
\sigma^2=gk\tanh(kh).
```

This relation connects frequency, wavelength and water depth. A wavenumber is $`2\pi`$ divided by wavelength.

## Parameters, initial state, and boundaries

Wave spectra, frequency and direction ranges, water depth, wind and currents come from the configured wave inputs. Direction is periodic over a full turn. Land masks block propagation through the coast, and supplied boundary spectra define open boundaries. The solver contract must preserve the source spectrum's encoding, including any conversion between surface-height variance and physical energy.

The local WAVEMDL and PROPAGS sources and [IFS Wave Model, CY48R1](https://www.ecmwf.int/sites/default/files/elibrary/2023/81373-ifs-documentation-cy48r1-part-vii-ecmwf-wave-model.pdf) define the component. Source terms, coupling and ordered numerical updates require md2asm contracts, grounded in the [source record](../../../bench/openifs/EVIDENCE.md#source).
