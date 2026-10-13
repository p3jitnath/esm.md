# Carbon Uptake By Plant Leaves

Revision 2. Leaves take carbon dioxide, or CO₂, from the air to make sugars, and they release some CO₂ through respiration. C3 plants fix carbon directly. C4 plants first pump carbon into a second group of cells, called the bundle sheath, before fixing it. This model gives carbon uptake and the conductance of leaf pores. Conductance measures how easily a gas passes through a surface.

Let $`A`$ be net uptake, $`W`$ gross fixation and $`R_d`$ leaf respiration. These rates use µmol of CO₂ per square metre of leaf per second.

```math
A=W-R_d. \tag{C1}
```

For C3 leaves, fixation is limited by the enzyme capacity $`V_c`$ or electron supply $`J`$. Let $`C_c`$ be CO₂ at the fixing cells, $`\Gamma`$ the compensation concentration and $`K`$ the effective enzyme response constant. A compensation concentration gives zero gross uptake. CO₂ uses ppm under the model's near-one-bar approximation.

```math
W=\min\left(V_c\frac{C_c-\Gamma}{C_c+K},\frac{J}{4}\frac{C_c-\Gamma}{C_c+2\Gamma}\right). \tag{C2}
```

Carbon crosses the leaf boundary, its pores and internal tissue. Their conductances are $`g_b`$, $`g_s`$ and $`g_m`$. Let $`C_a`$ and $`C_i`$ be air and internal CO₂. Conductance uses mol/(m²·s·bar); ppm is numerically equal to µbar at the assumed one-bar pressure.

```math
C_a-C_i=A\left(\frac{1}{g_b}+\frac{1}{g_s}\right), \qquad C_i-C_c=\frac{A}{g_m}\quad\text{for C3}. \tag{C3}
```

The canopy totals are gross production $`G`$, net uptake $`N`$ and respiration $`R`$, in kg of CO₂ per square metre of ground per second.

```math
G=N+R. \tag{C4}
```

For C4 leaves, $`C_c`$ is bundle-sheath CO₂ and $`O`$ is oxygen. The enzyme constants $`K_{mc}`$ and $`K_{mo}`$ describe responses to CO₂ and oxygen. Let $`\gamma=1/(2S_{co})`$, where $`S_{co}`$ is the enzyme's relative preference for CO₂ over oxygen. Let $`X_J`$ be the carbon-rate capacity supplied by light. Concentrations and enzyme constants use the same pressure-equivalent units.

```math
W=\min\left(V_c\frac{C_c-\gamma O}{C_c+K_{mc}(1+O/K_{mo})},X_J\frac{C_c-\gamma O}{C_c+(7\gamma/3)O}\right). \tag{C5}
```

The carbon pump has an enzyme response $`k_p C_i`$ and light capacity $`V_{pJ}`$. Carbon leaks from the bundle sheath with conductance $`g_{bs}`$, and the first cell group respires at rate $`R_m=R_d/2`$. Both $`k_p`$ and $`g_{bs}`$ use mol/(m²·s·bar).

```math
A=\min(k_p C_i,V_{pJ})-g_{bs}(C_c-C_i)-R_m. \tag{C6}
```

Let $`C_s`$ be leaf-surface CO₂, $`g_0`$ residual pore conductance and $`f`$ the dimensionless humidity-and-water response. The compensation value $`C_*`$ is surface CO₂ where net uptake is zero.

```math
C_s=C_a-\frac{A}{g_b},\qquad
g_s=g_0+\frac{Wf}{C_s-C_*},\qquad
C_*=\frac{g_{bs}\gamma O_i-(1+\gamma\alpha/0.047)R_d+R_m}{g_{bs}+k_p}. \tag{C7}
```

The air oxygen concentration is $`O_i`$. The dimensionless $`\alpha`$ gives the fraction of oxygen production affecting the bundle sheath. The value 0.047 is the oxygen-to-CO₂ diffusion ratio used by the model.

```math
O=O_i+\frac{\alpha A}{0.047g_{bs}}. \tag{C8}
```

Inputs are radiation in W/m², pressure in Pa, temperatures in K, humidity in kg/kg, CO₂ in kgCO₂/kgAir, leaf area per ground area, soil-water availability and vegetation type. Retained tables give plant responses. Temperature responses use 298 K. The C4 parameters are $`g_{bs}=0.003`$, $`k_p=0.7`$, $`O_i=210000`$ pressure-equivalent ppm and $`\alpha=0.1`$. The supplied light response gives $`X_J`$ and $`V_{pJ}`$.

Each call solves a steady leaf state and sums rates through the canopy. Positive internal and bundle-sheath concentrations, positive pore conductance and both minimum equations select the physical solution. The derived contract records the canopy grid, pathway order, light response and fixed positive-capacity scope.
