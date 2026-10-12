# Rounded Product And Sum

Inside an accepted mathematical function, this helper combines three finite, dimensionless inputs $`a`$, $`b`$ and $`c`$. It rounds their exact product and sum once to FP64, the 64-bit floating-point format.

```math
z=\operatorname{round}_{64}(ab+c).
```

Rounding chooses the nearest representable value. A halfway result chooses the value whose lowest stored bit is even. Keep the sign of a zero result and the original arithmetic status. This one-rounding operation belongs to the accepted mathematical function. The weather equations keep their separate multiplication and addition steps.
