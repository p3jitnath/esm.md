# Prognostic Departure Update Contract

The [basic formulation](../../../../../formulations/openifs/dynamics/prognostic_departure_update.md) gives the physical idea.

This contract covers the hydrostatic, ordinary-coordinate LAPINEB route used by the coarse forecast. LAPINEB produces provisional wind, temperature, constituent fields and logarithmic surface pressure. It calls the complete accepted direct LARCINB child before it combines the returned transport terms with the caller's state. This is one forecast stage, and the surrounding forecast still controls its call order.

## Selected Controls

Use NVLAG, NWLAG and NTLAG equal to 3, finite differences or the captured finite-element vertical integral, ordinary spherical geometry and dry-air gas constant RD for the temporary temperature product. Disable the cheap predictor-corrector route, linear implicit additions, curved wind components, extra Coriolis backtracking, non-hydrostatic variables and trajectory-diagnostic pressure output. The split-physics switch remains an explicit caller input. Reuse the accepted LARCINB transport methods and their scientific and arithmetic limits.

## Ordered Update

Let $`B_u,B_v,B_T,B_r,B_s`$ be the caller's provisional fields before this stage. Let $`F_u,F_v,F_T,F_r,D_j,C_j`$ be the accepted child's contributions, with the required time factors already included. The wind terms have units of metres per second, the temperature term has units of kelvin, and the constituent terms are mass fractions. The vertical weight $`b_j`$ and the surface-pressure terms are dimensionless.

The caller supplies two coefficients $`p`$ and $`q`$ that express departure-point wind in the arrival-point basis. With geometry coefficients $`m,l`$ and supplied values $`r_x,r_y`$, form $`p=R(R(r_xm)-R(r_yl))`$ and $`q=R(R(r_ym)+R(r_xl))`$. Here $`R`$ means one FP64 rounding to nearest, with ties to even. Every multiplication and addition shown below has its own rounding.

```math
u^\star=R(R(B_u+R(pF_u))+R(qF_v)),\qquad
v^\star=R(R(B_v-R(qF_u))+R(pF_v)).
```

Add $`F_T`$ to temperature with one rounding. Add each advected constituent term to its corresponding provisional field, unless that field uses an external grid. The CVGQ diagnostic stores the transported moisture term minus the supplied old moisture. When the spectral moisture-copy switch is active, copy the completed moisture field into its declared diagnostic field.

Update $`s=\log(p_s/p_0)`$ in increasing level order. Each level first adds $`D_j+C_j`$, then multiplies that rounded sum by $`b_j`$, then adds the rounded product to the current surface value. This serial order fixes every rounding point.

```math
s^{(0)}=B_s,\qquad
s^{(j)}=R(s^{(j-1)}+R(b_jR(D_j+C_j))).
```

For split physics, rotate its interpolated wind terms with $`R(R(pF_u)+R(qF_v))`$ and $`R(R(-qF_u)+R(pF_v))`$. The accepted child owns its temperature and constituent output stages. Compute the selected temporary dry-air temperature product as $`R(RD\,T^\star)`$ without expression contraction.

## Finite-Element Pressure Branch

The genuine coarse forecast uses finite elements, which describe vertical variation with short polynomials. Its computational coordinate grid differs from the ordinary physical level coordinate. Use the exact captured VFE_RDETAH reciprocal layer widths and RINTBF11 matrix, with ITOP, boundary option 11 and default IBC equal to 3. Reuse the complete accepted VERDISINT, VERINT, VERDER and ordered matrix assembly closure. The original-defined endpoint inputs are positive zero.

For each level, first round the product of its supplied weight and reciprocal computational width, then round the sum of the two continuity terms, then multiply those two rounded values. The child integrates these values from the top and returns all levels through the ground. Add its ground integral to the old surface-pressure field with one rounding. Preserve the child's increasing-column, separately rounded matrix products and sums. The finite-difference branch above remains unchanged.

The exact same-run input record retains the matrix, reciprocal layer widths and matching TVFE and TCVER configuration. The grid tracer records LAPINEB as the ITOP/11 caller. Independent constant and homogeneous-quartic integrals and reciprocal-width relations qualify this actual coordinate grid with the accepted child limits. This preparation gives no new child routine credit.

## Interface and Owners

The original entry has 36 ordinary pointer arguments and no hidden character length. Use the Arm procedure-call rules, preserve x19 through x29 and the lower 64 bits of d8 through d15, keep the stack aligned to 16 bytes, and preserve x18, FPCR and observable status. The direct entry must calculate every selected numerical stage in assembly and must reject unsupported controls before mutation.

Full-level fields use the caller's NPROMA columns and NFLEVG levels. The three inactive half-level owners use NPROMNH columns, which is 1 in the hydrostatic forecast, and NFLEVG levels. Diagnostic owners use a 1 by 1 spatial allocation when LRDDHDYN is false, with their full declared field count. Derive the field counts and indices from the measured original records. Do not read a larger nominal callee shape. Preserve inactive columns, untouched fields, padding and declared input bytes.

## Acceptance

Qualify the original parent against independent high-precision checks of the surface-pressure column sum, changes of wind basis, scalar source additions and field admissibility before emitting the assembly. Reuse unchanged child proofs. Then require zero differing bytes over every complete caller-owned return buffer, matching FPCR, status and errno, preserved registers and protected boundaries. The normal saved-forecast gate supplies final routine credit. A source-only packet supplies inputs and gives no numerical credit.

The original source is arpifs/adiab/lapineb.F90. The accepted child is the private direct LARCINB closure recorded in departure_field_parent_7259755/parent-ready.json. The source-only captured owner graph is recorded in source_capture_ready_r2.json. Its controls and exact RD bytes must be read from the closed genuine packet before the selected route is admitted.

## Accepted Forecast Calls

The complete parent passes 2,150 genuine native calls and 236,465,600 returned bytes with zero differences. Each call owns one complete direct transport child and one direct vertical stage. Independent checks pass 12,697,600 physical relations. All ten saved files agree across 618,140 bytes. The complete forecast still has other Fortran stages.
