# Greenhouse-Gas Time Series

Revision 1. This input describes gas concentrations used by the radiation calculation. Greenhouse gases absorb some of the infrared radiation emitted by Earth, so their amounts affect how quickly Earth loses heat.

For each gas g, the volume mixing ratio c_g is the number of its molecules divided by the number of dry-air molecules. It has no unit. Equation G1 defines this ratio.

```math
c_g = \frac{N_g}{N_{\mathrm{dry}}}. \tag{G1}
```

The input contains annual mean ratios for carbon dioxide, methane, nitrous oxide, CFC11, CFC12, HCFC22 and carbon tetrachloride. CFC means chlorofluorocarbon, and HCFC means hydrochlorofluorocarbon. An equivalent CFC11 ratio can include the radiation effect of other gases. For the supplied table, HCFC22 and carbon tetrachloride therefore have zero separate ratios.

Time is measured in decimal years. The value 2004.5 is the middle of 2004. Each gas amount varies between its two surrounding annual values. Equation G2 gives this basic time variation, where t_0 and t_1 are the surrounding dates.

```math
c_g(t) = c_g(t_0) + \frac{t-t_0}{t_1-t_0}\left[c_g(t_1)-c_g(t_0)\right]. \tag{G2}
```

The supplied table has 2 501 dates, from 0.5 to 2500.5 years. Its gas ratios are finite and nonnegative. The forecast starts near 2004.786 years. This lookup has no spatial boundary or evolving state, and each requested date must lie inside the table.
