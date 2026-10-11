# Yearly Ozone Cycle

Revision 1.

Ozone changes during the year. This model represents the total ozone column and the pressure where ozone concentration is greatest. Both quantities have units Pa. Their smooth spatial patterns use a short list of sine and cosine coefficients.

Let $`\theta`$ be the time of year in radians, with one year represented by $`2\pi`$. Each spatial coefficient uses a mean value and two seasonal waves.

```math
f(\theta)=A_0+2\left[A_1\cos\theta+A_2\sin\theta+A_3\cos(2\theta)+A_4\sin(2\theta)\right].
```

Equation O3-SEAS gives one coefficient at the supplied time. The constants $`A_0,\ldots,A_4`$ come from the frozen original ozone climatology. Its mean total-column constant is 0.06012 Pa, and its mean peak-pressure constant is 3,166 Pa.

Each quantity has 21 spatial cosine coefficients and 15 spatial sine coefficients. These coefficients represent broad geographical patterns rather than individual grid cells. No previous state or boundary data are needed. The model receives the current time of year and returns its four coefficient arrays.
