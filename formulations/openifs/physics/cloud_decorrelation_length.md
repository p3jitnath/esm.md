# Vertical Cloud Similarity

Revision 1.0

Cloud shapes at nearby heights are often similar. A decorrelation length is the vertical distance over which that similarity decreases. The radiation model uses one length for cloud boundaries and another for the amount of cloud water. Both lengths are in kilometres.

The constant option uses the configured lengths $`L_f`$ and $`L_w`$. Their ratio is $`L_w/L_f`$. A second option makes the cloud-boundary length decrease with the absolute latitude $`\phi_d`$ in degrees.

<!-- Equation CDEC-1 -->
```math
L_f=2.899-0.02759\lvert\phi_d\rvert.
```

The smooth option uses latitude $`\phi`$ in radians and has no sharp change at the equator.

<!-- Equation CDEC-2 -->
```math
L_f=0.75+2.149\cos^2\phi,
\qquad L_w=\tfrac12 L_f.
```

Both latitude-dependent options use $`L_w=L_f/2`$, so their water-to-boundary ratio is 0.5. The calculation changes only these diagnostic lengths. It does not change cloud mass or the weather state.

The configured forecast uses 32 Gaussian latitude rows. The [numerical contract](../../../skills/md2asm/references/openifs/physics/cloud_decorrelation_length.md) gives the complete input set, arithmetic and interface.
