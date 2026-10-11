# Monthly Gas Climatology

Revision 1.0 uses the OpenIFS 48.1.1 UPD_GHGCLIM source. A climatology is an average over many years. This model stores an average gas concentration for each month and estimates the concentration between two neighbouring months.

Let $`v_1`$ and $`v_2`$ be gas volume fractions, which have no units. Let $`w`$ be the fraction assigned to the first month, with $`0\leq w\leq1`$. Let $`s`$ convert the volume fraction to a mass fraction, allowing a prescribed change in gas concentration.

```math
r=s\bigl[w v_1+(1-w)v_2\bigr]. \tag{MG-1}
```

Here $`r`$ is kilograms of gas per kilogram of air. For pressure faces $`p_t`$ and $`p_b`$ in pascals and gravitational acceleration $`g`$ in metres per square second, the gas mass per square metre is

```math
m=\frac{p_b-p_t}{g}\,r. \tag{MG-2}
```

The upstream field called MASS stores the pressure-weighted amount $`G=g m`$ in pascals. Its later radiation calculation uses this same convention. All pressure depths and concentrations are nonnegative.

Use the supplied twelve monthly tables, their surface means and their pressure faces. The configuration selects carbon dioxide, methane, nitrous oxide, nitrogen dioxide, CFC-11, CFC-12, ozone, HCFC-22 and carbon tetrachloride. The date determines the two neighbouring monthly midpoints, including the December-to-January boundary. The existing state supplies the prescribed concentrations. Unselected gases keep their previous values.
