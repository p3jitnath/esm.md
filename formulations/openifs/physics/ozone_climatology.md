# Monthly Ozone Climatology

Revision 1. Ozone absorbs some of the Sun's radiation. This input describes how a monthly ozone distribution changes smoothly through the year, rather than calculating chemical reactions.

The supplied table gives an ozone volume fraction at 19 latitudes from minus 90 to 90 degrees, 34 vertical levels and 12 months. A fraction has no unit. The supplied positive conversion factor $`k`$ changes the volume fraction into a mass fraction in kilograms of ozone per kilogram of air. Let $`q_1`$ and $`q_2`$ be neighbouring monthly values and let $`w`$ be the fraction of time from the first month to the next.

```math
q(t)=k\bigl[(1-w)q_1+wq_2\bigr].
```

Time repeats over a mean year of 365.25 days. Use the supplied date and minute of the day, with the existing monthly calendar convention. The first boundary level has zero ozone and the last repeats the neighbouring interior value.

An optional amplitude $`A`$ from minus one to one changes ozone over nine middle latitudes and seven vertical levels. Two supplied integer modes select the vertical interval, while other modes leave the distribution unchanged. The smooth sine shapes are zero at the interval ends and largest near its centre.

```math
q_{\mathrm{perturbed}}=q(t)\bigl[1+A\sin(\alpha)\sin(\beta)\bigr].
```

The angles $`\alpha`$ and $`\beta`$ run from zero to $`\pi`$ across the chosen latitude and height intervals. The grid and the physical constant $`\pi`$ are fixed, so all required sine values are constants.
