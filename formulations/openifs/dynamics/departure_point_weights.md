# Departure Point Interpolation Weights

Formulation revision 1.0. A semi-Lagrangian forecast follows moving air back to its earlier position. Interpolation estimates the earlier field from nearby grid values. Latitude and longitude have units of radians. The supplied vertical coordinate eta and all interpolation weights are dimensionless.

Let x be the earlier position, and let n_j be four distinct nearby nodes. Cubic interpolation uses the following weights to reproduce a polynomial through degree three. Recover the first weight from the other three.

```math
h_j(x)=\prod_{m\ne j}\frac{x-n_m}{n_j-n_m},
\qquad h_0=1-h_1-h_2-h_3.
```

A position between two nodes has fractional distance d. Linear interpolation uses weights 1-d and d. A correction may move the position towards the pair centre, using supplied scale s.

```math
d=\frac{x-n_1}{n_2-n_1},
\qquad d_m=s\,d+\frac{1-s}{2}.
```

The caller supplies departure positions, grids, increasing vertical nodes, lookup tables, diffusion coefficients and earlier field indices. It chooses linear, cubic, Hermite, spline or WENO interpolation. Hermite uses values and slopes. A spline uses supplied cubic polynomial coefficients. WENO combines three cubic stencils to reduce oscillations.

The initial state contains the complete supplied buffers. Only selected rows change. Vertical boundary pairs use the original linear weights. The original physical limits and the one-process communication limit are recorded in the md2fort contract.
