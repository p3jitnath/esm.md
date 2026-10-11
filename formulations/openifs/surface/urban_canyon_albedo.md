# Sunlight reflected by an urban canyon

A road between two walls can reflect sunlight more than once. The canyon albedo is the fraction of incoming sunlight that escapes back to the sky. This fraction is dimensionless and lies between zero and one.

Let $`R`$ be wall height divided by road width, $`a_r`$ and $`a_w`$ be road and wall albedos, and $`\mu`$ be the cosine of the solar zenith angle. The zenith angle is measured from the upward vertical direction. The supported physical inputs are $`0.05\leq R\leq1.5`$, $`0\leq a_r,a_w\leq1`$, and $`0\leq\mu\leq1`$. The standard setup uses $`R=0.5`$, $`a_r=0.05`$, and $`a_w=0.6`$.

The sky-scattered fraction is 0.3. The original illumination equations split the remaining sunlight between the road and walls. Shape factors describe how much reflected light reaches each surface or the sky. A three-surface linear balance accounts for repeated reflection.

``` math
(I-AS)O=b.
```

Here $`S`$ contains the shape factors, $`A`$ contains the surface albedos, $`O`$ contains outgoing fractions of the incoming radiation, and $`b`$ contains the initially reflected fractions. The road and both walls absorb part of the light. The rest gives the canyon albedo. The output is clipped to the interval from zero to one, as in the original calculation.

The written illumination rule can give a negative road fraction for some aspect ratios above $`\pi/2`$. The supported range retains nonnegative incident fractions and includes the model's standard setup. There is no evolving initial state or spatial boundary in this local calculation.
