# Canopy Water Stress

Formulation revision 1 groups COTWORESTRESS. A canopy is the layer formed by plant leaves. Dry soil and dry air can restrict gas exchange through those leaves. Canopy resistance measures that restriction in seconds per metre, while conductance measures the ease of exchange in metres per second.

For vegetated land, let $`g_c`$ be canopy conductance and $`g_{\min}`$ its supplied positive lower bound. Equation CWS-P01 relates the bounded conductance to resistance $`r_c`$.

```math
r_c=\frac{1}{\max(g_{\min},g_c)}\qquad\text{(CWS-P01)}
```

The existing [leaf carbon model](carbon_uptake_by_plant_leaves.md) defines photosynthesis and respiration. The forecast supplies vegetation, soil moisture, air and soil temperatures in kelvin, carbon dioxide, radiation in watts per square metre, evaporation and tile fractions. Water and ice retain their own boundary rules. The [md2fort contract](../../../skills/md2fort/references/openifs/surface/canopy_water_stress.md) preserves the complete C3 and selected C4 calculation.
