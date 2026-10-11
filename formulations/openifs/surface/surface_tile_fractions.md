# Surface Tile Fractions

Revision 1.

One weather grid cell can contain water, ice, vegetation, bare ground, snow and buildings. Divide the cell into surface tiles so that each surface can exchange heat and water with the air. A tile fraction is its area divided by the grid-cell area, so every fraction has no units.

Let $`a`$ and $`b`$ be the corrected low- and high-vegetation fractions, $`l`$ the lake fraction and $`u`$ the urban fraction. The remaining land area is

```math
A=1-l-u,\qquad
A_{\rm low}=aA,\qquad
A_{\rm high}=bA,\qquad
A_{\rm bare}=(1-a-b)A.
\tag{TF1}
```

Let $`s`$ be snow cover and $`w`$ be the wet canopy fraction. A canopy is the leaves and branches above the ground. The dry and snow-free fraction of an area $`B`$ is $`B(1-s)(1-w)`$. Its snow fraction is $`Bs`$. Wet canopy contributes $`(1-l)(1-s)w`$.

The maximum canopy water mass depends on vegetation area and leaf area

```math
W_{\max}=r\,[1-a-b+aL_{\rm low}+bL_{\rm high}],
\qquad
w=\min\!\left(1,\max\!\left(0,\frac{W}{W_{\max}}\right)\right).
\tag{TF2}
```

Here $`W`$ and $`W_{\max}`$ are water masses in kg per square metre, $`r`$ is the caller's positive water-capacity parameter in the same units, and $`L_{\rm low}`$ and $`L_{\rm high}`$ are leaf area divided by ground area. The caller supplies vegetation properties, surface masks, lake-ice thickness, snow mass and snow density. Thickness is in metres, snow mass is in kg per square metre, and density is in kg per cubic metre.

Choose the caller's snow-cover rule, lake setting and leaf-area data. Sea ice divides ocean area between water and ice. Lake ice divides lake area between open water and the lake tile. The final surface fractions sum to one. This calculation supplies an initial surface partition and has no time update or spatial boundary cells.
