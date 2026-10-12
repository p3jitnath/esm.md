# Real Fourier representation

Revision 1 records the longitude representation used by FFT992 in OpenIFS 48.1.1.

## The idea

A latitude row forms a circle around the Earth. A real field, such as temperature, has a value at each longitude position. A Fourier representation describes the same row as a mean value plus smooth cosine and sine waves. This operation changes the representation at a fixed time; it does not advance the forecast in time.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`N`$ | Number of equally spaced positions around the row; a fixed dimensionless integer. |
| $`j`$ | Position number from $`0`$ to $`N-1`$; dimensionless. |
| $`k`$ | Wave number, which counts complete waves around the row; dimensionless. |
| $`x_j`$ | Real field value at position $`j`$, in the supplied field unit, such as kelvin for temperature or metres per second for wind. |
| $`a_k,b_k`$ | Cosine and sine coefficients at wave number $`k`$; they have the same unit as $`x_j`$. |

The wave angle $`2\pi jk/N`$ is measured in radians. A complete circle has $`2\pi`$ radians.

## Equations

**P01. Analysis of a row**

```math
a_k=\frac{1}{N}\sum_{j=0}^{N-1}x_j\cos\left(\frac{2\pi jk}{N}\right),\qquad b_k=-\frac{1}{N}\sum_{j=0}^{N-1}x_j\sin\left(\frac{2\pi jk}{N}\right).
```

Analysis finds the wave coefficients from the row values. In particular, $`a_0`$ is the row's mean. The negative sine sign is the original routine's choice of coefficient sign.

**P02. Synthesis of a row**

```math
x_j=a_0+2\sum_{k=1}^{\lfloor(N-1)/2\rfloor}\left[a_k\cos\left(\frac{2\pi jk}{N}\right)-b_k\sin\left(\frac{2\pi jk}{N}\right)\right]+\begin{cases}a_{N/2}(-1)^j,&N\text{ even},\\0,&N\text{ odd}.\end{cases}
```

Synthesis combines the coefficients to recover the row. Each interior wave represents a positive and negative pair, so its contribution appears twice. For an even row length, the final wave is its own pair and appears once. The floor marks the greatest integer that is not greater than the value inside it.

## Parameters, initial state, and boundaries

The audited coarse forecast has $`N=64`$. The supplied field values or coefficients form the initial state of each call. The row is periodic: after position $`N-1`$, the next position is position $`0`$.

The [md2asm skill](../../../skills/md2asm/SKILL.md) records the numerical method, ordered arithmetic, storage and verification in the supporting [solver contract](../../../skills/md2asm/references/openifs/dynamics/real_fourier_transform.md).
