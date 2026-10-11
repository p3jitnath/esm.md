# Plant Temperature Response

Revision 2.

A leaf reaction changes speed when its temperature changes. This model gives the reaction rate as a fraction of its rate at a reference temperature. Both rates are positive.

Let $`T`$ and $`T_r`$ be the leaf and reference temperatures in kelvin. Let $`R`$ be the gas constant in joules per mole per kelvin, and let $`E_a`$ be the effective temperature-response energy in joules per mole. A positive value makes the basic response increase with warming. A negative value makes it decrease. Equation AR1 describes the basic temperature response $`A`$.

```math
A = \exp\!\left[\frac{E_a}{R}\left(\frac{1}{T_r}-\frac{1}{T}\right)\right].
\tag{AR1}
```

A second model allows the reaction to slow at high temperature. Let $`E_d`$ be the deactivation energy in joules per mole, and let $`S`$ be entropy in joules per mole per kelvin. Equation AR2 gives the adjusted response $`B`$.

```math
B = A\,\frac{1+\exp[(T_r S-E_d)/(R T_r)]}{1+\exp[(T S-E_d)/(R T)]}.
\tag{AR2}
```

Both responses equal one when $`T=T_r`$. Equation AR1 increases with temperature when $`E_a>0`$. Equation AR2 also includes the loss of reaction activity at high temperature.

Use positive finite temperatures and gas constant. The effective energy can have either sign. The deactivation energy and entropy are nonnegative. The model caller supplies these values. Each call returns one dimensionless response and does not change its inputs. There is no time step, spatial grid or boundary condition.
