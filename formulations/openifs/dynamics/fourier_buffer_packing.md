# Fourier Coefficient Transfer

Revision 1 describes the transfer of wave coefficients in the selected OpenIFS forecast. A wave coefficient states the size and phase of one wave in a field, such as temperature or wind. Moving these coefficients between work buffers must preserve their values.

A complex coefficient has a real part $`a`$ and an imaginary part $`b`$. The imaginary unit $`i`$ satisfies $`i^2=-1`$.

```math
c = a + ib.
```

Each transfer preserves the same coefficient at the same field, latitude and wave number.

```math
c_{\mathrm{destination}} = c_{\mathrm{source}}.
```

The coefficient units follow the field. Temperature uses kelvin and wind uses metres per second. This transfer has no time update, new physical parameter or boundary condition. It uses the coefficients and occupied wave slots supplied by the surrounding transform. The selected forecast has 32 latitude rows and retains wave numbers zero through 21.

The LLM uses [md2fort](../../../skills/md2fort/SKILL.md) to derive the [buffer layout and assembly contract](../../../skills/md2fort/references/openifs/dynamics/fourier_buffer_packing.md).
