# Fourier Wind And Gradients

Revision 1.0.

A weather model can represent a field as waves around a latitude circle. Fourier coefficients give the real and imaginary parts of each wave. The integer wave number $`m`$ counts its cycles around the circle.

Let $`a`$ be the Earth’s radius in metres and $`\theta`$ the latitude. The circle’s radius is $`a\cos\theta`$. The geometry supplies $`g`$, the inverse of this radius, in $`\mathrm{m}^{-1}`$.

```math
g = \frac{1}{a\cos\theta}. \tag{P01}
```

The transform supplies weighted wind $`u^*=(a\cos\theta)u`$ in $`\mathrm{m}^2\,\mathrm{s}^{-1}`$. Multiplication by $`g`$ gives wind $`u`$ in $`\mathrm{m}\,\mathrm{s}^{-1}`$. The same metric converts the supplied northward derivative into a derivative per metre.

```math
u = g u^*. \tag{P02}
```

Write a scalar wave coefficient as $`z=z_{\mathrm{r}}+i z_{\mathrm{i}}`$, where $`i^2=-1`$. Its eastward derivative has the field’s units per metre. Multiplication by $`i m g`$ turns the wave’s change with angle into its change with distance.

```math
\left(\frac{\partial z}{\partial x}\right)_{\mathrm{r}}=-m g z_{\mathrm{i}},
\qquad
\left(\frac{\partial z}{\partial x}\right)_{\mathrm{i}}=m g z_{\mathrm{r}}. \tag{P03}
```

Wind derivatives use the wind after P02. A constant wave has $`m=0`$ and therefore has no eastward derivative. Inputs are the field coefficients, the largest retained wave number and the latitude metric. This formulation covers a Gaussian latitude grid with a positive finite metric. The transform supplies each latitude’s coefficients, so this stage has no time update or additional boundary condition.
