# Convection tendencies and column fluxes

Revision 1 describes the complete normal-physics CUCALLN controller.

## The idea

Convection moves warm, moist air upward and cooler air downward. The controller prepares the air state, calls the complete convection and low-cloud calculations, and expresses their heating, drying and wind changes as fluxes between model layers. Rain, snow and cloud water carry water and latent energy, which is the energy released or absorbed when water changes phase.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`q,T,u,v`$ | Water vapour, temperature and horizontal wind components, kg kg$`^{-1}`$; K; m s$`^{-1}`$ |
| $`\dot q,\dot T,\dot u,\dot v`$ | Their rates of change per second |
| $`\Delta p/g`$ | Air mass per unit area in one layer, kg m$`^{-2}`$ |
| $`c_p(q)`$ | Air heat capacity, J kg$`^{-1}`$ K$`^{-1}`$ |
| $`L_v,L_s`$ | Latent energy for liquid water and ice, J kg$`^{-1}`$ |
| $`R,S,C_l,C_i`$ | Rain, snow and cumulative liquid and ice transfers, kg m$`^{-2}`$ s$`^{-1}`$ |

## Equations

**P01. Layer tendency converted to flux**

```math
F_{q,j+1}=F_{q,j}-\frac{\Delta p_j}{g}\dot q_j,
\qquad
F_{T,j+1}=F_{T,j}-\frac{\Delta p_j}{g}c_p(q_j)\dot T_j.
```

The wind fluxes use the same pressure weighting as water. Starting with zero flux at the upper boundary makes each lower flux include the changes in all layers above it.

**P02. Water and latent-energy transfer**

```math
F_q^{\,\mathrm{total}}=F_q-R-S-C_l-C_i,
\qquad
F_T^{\,\mathrm{total}}=F_T+L_v(R+C_l)+L_s(S+C_i).
```

Water transferred into rain, snow or condensate is removed from the vapour flux. Its latent energy is included in the heat flux.

## Parameters, initial state, and boundaries

The caller supplies the previous air state, cumulative and dynamical tendencies, pressure geometry, model settings and time interval. The provisional humidity has the original model's lower bound. The model supplies gravity, dry-air heat capacity and latent energies. Its normal setup uses dry-air heat capacity without a humidity correction. The complete convection calculation supplies the rain, snow and condensate transfers. The original precipitation child sets both precipitation boundary rows to positive zero for every column.

The [solver contract](../../../skills/md2asm/references/openifs/convection/cucalln.md) records the full selected calculation, storage and acceptance limits.
