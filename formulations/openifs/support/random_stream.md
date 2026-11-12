# Reproducible random samples

Revision 1.1 describes the random samples used to choose cloud states in a weather model. A random sample is a number that selects one of several possible states. This model calculates the samples from an integer seed, so the same seed always gives the same sequence.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`x_n`$ | Integer state at position $`n`$, without units |
| $`u_n`$ | Sample between zero and one, without units |
| $`s`$ | Signed 32-bit integer seed, without units |

## Equations

**P01. State sequence**

```math
x_n=(x_{n-607}+x_{n-273})\bmod 2^{30}.
```

The remainder after division by $`2^{30}`$ keeps each state between zero and $`2^{30}-1`$.

**P02. Uniform sample**

```math
u_n=\frac{x_n}{2^{30}}.
```

Each sample lies in $`0\leq u_n<1`$. A cloud with cover fraction $`c`$ can be selected when $`u_n<c`$. This note specifies the sample sequence and does not claim that a finite sequence is perfectly random.

## Parameters, initial state and boundaries

Use the fixed lags 607 and 273 and a seed $`-2^{31}\leq s\leq2^{31}-1`$. The [md2fort contract](../../../skills/md2fort/references/openifs/support/random_stream.md) defines the exact seed expansion and the state retained between calls. There is no spatial boundary in this sequence.
