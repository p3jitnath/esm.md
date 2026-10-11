# Tangent of a bounded angle

The tangent gives a slope from an angle. Let $`x`$ be the angle in radians. Its sine gives the vertical part of a unit direction, and its cosine gives the horizontal part.

``` math
t(x)=\frac{\sin(x)}{\cos(x)}.
```

This helper supports finite binary64 angles with $`\lvert x\rvert\leq 3.141592653589793`$. The result has no units. A direction close to a vertical line can have a large tangent because its horizontal part is small. The mathematical poles are irrational angles, so none of the supported binary64 inputs is exactly a pole. The helper preserves positive and negative zero.

The original GNU libc 2.38 calculation defines the result bits and floating-point status. The numerical contract records its ordered arithmetic and its bounded input range. Callers must prove that their angles are within this range.
