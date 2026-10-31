# Snow Water and Energy Contract

Revision 1 freezes the complete numerical body of `SRFSN_WEBAL_MOD::SRFSN_WEBAL` for the [snow water and heat formulation](../../../../../formulations/openifs/surface/snow_water_energy.md). The original route is `surf/module/srfsn_webal_mod.F90`, with the two used material formulas in `surf/function/fcsurf.h`. The assembly is [snow_water_energy.S](../../../../../src/openifs/surface/snow_water_energy.S). A column contains $`N`$ snow layers, numbered from the surface downwards.

## Inputs and Material Properties

All real inputs use FP64, the 64-bit floating-point format. Mass and water are in kg m$`^{-2}`$, density is in kg m$`^{-3}`$, temperature is in K, time is in s, conductivity is in W m$`^{-1}`$ K$`^{-1}`$, heat flux is in W m$`^{-2}`$, pressure is in Pa and precipitation is in kg m$`^{-2}`$ s$`^{-1}`$. The time step and densities are positive. Water lies between zero and total mass. Supported input temperatures and returned temperatures lie between 100 K and the melting temperature $`T_f`$. Inputs and intermediate results are finite, mass removal cannot exhaust the available ice, and the linear solve has nonzero finite pivots.

The configuration supplies ice heat capacity $`c_i=H_i/\rho_i`$, maximum thermal depth $`D_{\max}`$, liquid retention coefficients $`a,b,c`$, vapour conductivity coefficients $`A,B,C,p_0`$, first soil depth $`D_s`$, $`T_f`$ and latent heat $`L`$. The checked defaults are $`H_i=2.05\times10^6`$, $`\rho_i=920`$, $`D_{\max}=1`$, $`a=200`$, $`b=0.03`$, $`c=0.1`$, $`A=-0.06023`$, $`B=2.5425`$, $`C=289.99`$, $`p_0=100000`$, $`D_s=0.07`$, $`T_f=273.16`$ and $`L=333700`$, with the units stated above or implied by the material equations. Water heat capacity is 4180 J kg$`^{-1}`$ K$`^{-1}`$. The temperature must differ from $`C`$ and pressure must be positive.

```math
I_j=M_j-W_j,\qquad
d_j=\min(D_{\max},M_j/\rho_j),
\qquad
h_j=\frac{c_i\rho_j\min(D_{\max},I_j/\rho_j)+4180W_j}{\Delta t}.
```

Here $`h_j`$ is heat capacity divided by the time step, in W m$`^{-2}`$ K$`^{-1}`$. The conductivity and liquid capacity are

```math
k_j=2.5\times10^{-6}\rho_j^2-1.23\times10^{-4}\rho_j+0.024+
\frac{p_0}{p}\max\left(0,A-\frac{B}{T_j-C}\right),
\qquad
W_{\mathrm{cap}}(I,\rho)=I\left[b+\frac{(c-b)\max(0,a-\rho)}{a}\right].
```

The original type field offsets in bytes are `TSOIL` size 2416, `RHOCI 312`, `RHOICE 296`, `RDSNMAX 416`, `RDAW 1648`, `RLWCSWEA 1776`, `RLWCSWEB 1784`, `RLWCSWEC 1792`, `SNHCONDAV 2088`, `SNHCONDBV 2096`, `SNHCONDCV 2104` and `SNHCONDPOV 2112`. `TCST` has size 128, `RTT 0` and `RLMLT 64`. `RDAW` is a contiguous allocated rank-one descriptor with unit stride and bounds that contain element 1. Read element 1 at its data pointer plus eight times the sum of its stored offset and one, preserving the actual lower bound.

## Complete Time Update

Set $`r=1/\Delta t`$ and $`\epsilon=10\,2^{-52}`$. A snow column has at least one layer with $`M_j>\epsilon`$. Its active count $`n`$ is the last such layer. Valid physical inputs form a positive active prefix with zero mass and water after it. Calculate all $`N`$ material values above, and replace $`h_1`$ by $`\max(\epsilon,h_1)`$ when $`n=1`$.

Let $`f`$ be snow cover, between zero and one. Calculate the unused upper coefficient $`K_1=fk_1/\max(\epsilon,(d_1/2)^2)`$, all internal coefficients $`K_j=2f(d_{j-1}k_{j-1}+d_jk_j)/\max(\epsilon,(d_{j-1}+d_j)^2)`$ for $`2\le j\le n`$, and the bottom coefficient $`K_{n+1}=f(d_nk_n+D_sk_s)/\max(\epsilon,(d_n+D_s)^2)`$. The supplied radiation values $`S_j`$ are signed heat terms. $`S_1`$ is subtracted from the top heat input $`F`$, internal $`S_j`$ are added to their layers and $`S_{n+1}`$ is added to the ground flux.

For several active layers, the first matrix row is $`(0,h_1+K_2,-K_2)`$ with right side $`F-S_1+h_1T_1`$. An internal row is $`(-K_j,h_j+K_j+K_{j+1},-K_{j+1})`$ with right side $`h_jT_j+S_j`$. The last row is $`(-K_n,h_n+K_n+K_{n+1},0)`$ with right side $`h_nT_n+K_{n+1}T_s+S_n`$. Copy all old temperatures before calling the accepted [snow tridiagonal solver](snow_trisolver.md), which solves the active rows. For one active layer, use $`T_1^*=(F-S_1+h_1T_1+K_2T_s)/(h_1+K_2)`$. Set $`G=K_{n+1}(T_n^*-T_s)`$.

If $`T_1^*>T_f`$, repeat the several-layer solve with first-row diagonal 1, upper coefficient zero and right side $`T_f`$, again copying old temperatures first. Recompute $`G`$ and replace the top temperature by $`(F-S_1+h_1T_1-K_2(T_1^*-T_2^*))/\max(\epsilon,h_1)`$. The one-layer melting branch instead uses $`G=K_2(T_f-T_s)`$ and $`T_1^*=(F-S_1+h_1T_1-G)/\max(\epsilon,h_1)`$.

Copy ice and liquid mass to their working vectors, set all liquid fluxes to positive zero, add $`\Delta t(P_{\mathrm{snow}}+E)`$ to the top ice and set the incoming top liquid mass to $`\Delta tP_{\mathrm{rain}}`$. Initialise every melt and freeze output to positive zero. Walk the active layers from top to bottom. Add the preceding liquid flux to old water, set $`q_0=h_j(T_j^*-T_f)`$, melt rate $`q_m=\max(0,\min(q_0,LrI_j^*))`$ and freeze rate $`q_f=\min(0,\max(q_0,-LrW_j^*))`$. These returned rates have units W m$`^{-2}`$. Set $`q=q_m+q_f`$.

The incoming residual heat is initially zero. Update $`T_j^*\leftarrow T_j^*-(q+G_{\mathrm{res}})/\max(\epsilon,h_j)`$. If it exceeds $`T_f`$, set $`G_{\mathrm{res}}=h_j(T_f-T_j^*)`$ and clamp the temperature to $`T_f`$, otherwise set the residual to positive zero. Add $`(q/L)\Delta t`$ to water and subtract the same rounded mass from ice. Set liquid flux to $`\max(0,W_j^*-W_{\mathrm{cap}}(I_j^*,\rho_j))`$ and subtract it from retained water.

Copy the last active temperature into inactive layers. Return $`T_j'=\min(T_f,T_j^*)`$, $`M_j'=\max(0,W_j^*+I_j^*)`$ and $`W_j'=\min(M_j',\max(0,W_j^*))`$ for all layers. Return runoff $`r\,\text{liquid flux}_n`$ and ground heat $`G-G_{\mathrm{res}}+S_{n+1}`$.

A no-snow mask returns $`M_1'=\max(0,M_1+\Delta t(P_{\mathrm{snow}}+E))`$, positive-zero deeper mass and water, all temperatures $`T_f`$, and positive-zero melt, freeze, ground and runoff outputs. Rain does not enter this branch. This is a state initialisation. Any retained thin-snow mass is treated as solid snow, including its incoming liquid water. Check its total mass update and prescribed solid phase at the freezing temperature. Apply the ice and latent-energy evolution budgets to resolved snow columns.

## Ordered Arithmetic and Diagnostics

Every displayed product, division, sum and difference is rounded separately in FP64. Evaluate products and sums from left to right as written in the original equations. In particular, thermal capacity multiplies $`c_i\rho_j`$ before capped ice depth, conductivity multiplies $`2.5\times10^{-6}\rho_j`$ before the second density, an internal coefficient multiplies $`f\times2`$ before the weighted conductivity, each squared thickness multiplies its already rounded sum by itself, matrix diagonals add heat capacity and lower conductivity before upper conductivity, and liquid capacity multiplies $`(c-b)\max(0,a-\rho)`$ before dividing by $`a`$. Compute $`-L`$ before multiplying by $`r`$ in the freeze limit. Preserve signed zeros, subnormal values and comparison ties. Use nearest-even rounding and FPCR zero, with no fused multiply-add, reassociation, approximate arithmetic or reduced precision.

Diagnostics are enabled only when both complete rank-three owners have positive size. Disabled owners may have null data pointers and must not be read or written. In enabled snow columns, heat channels 1, 2, 3, 4, 14 and 15 contain $`h_j\Delta t`$, old temperature, $`(h_j\Delta t)T_j`$, $`M_j/\rho_j`$, melt plus freeze, and $`(h_j\Delta t)(T_j'-T_j)`$. Heat channel 13 receives ground flux in layer 1 only. Mass channels 1, 4 and 5 receive old mass, signed ice flux and phase rate divided by $`L`$. Preserve all other channels and extra layers. For no-snow columns, write positive zero to all those heat and mass channels at every declared layer, except heat channel 2 which receives $`T_f`$.

## Interface and Storage

The original entry `__srfsn_webal_mod_MOD_srfsn_webal` aliases unique entry `md2asm_snow_water_energy`. Thirty arguments are addresses in this order. `KIDIA,KFDIA,KLON,KLEVSN,PTMST,LLNOSNOW,PFRSN,PSSNM1M,PWSNM1M,PRSNM1M,PTSNM1M,PTSURF,PHFLUX,ZSNOTRS,PSNOWF,PRAINF,PEVAPSN,PSURFCOND,PAPRS,TSOIL,TCST,PSSN,PWSN,PTSN,PGSN,PRUSN,PMELTSN,PFREZSN,PDHTSS,PDHSSS`. Integers and logical values use 32 bits. Input owners and both configurations remain unchanged.

Use independent signed GNU descriptor strides and a logical data pointer at the first supplied element. The first stride defaults to one when its metadata is zero. Descriptor sizes are 64, 88 and 112 bytes for ranks one, two and three. Descriptor fields are data pointer 0, offset 8, element size 16, rank 28, span 32, then stride, lower and upper at 40, 48 and 56 with 24 bytes per further dimension. Real element size and span are 8 bytes and logical element size and span are 4 bytes. The routine accepts $`1\le N\le4096`$, at most 4096 columns and an inclusive processed column range, including an empty range. Every owner contains all declared columns. Complete real snow layer owners have exactly $`N`$ layers, radiation has at least $`N+1`$, and enabled diagnostics have at least $`N`$ layers and 15 heat or 5 mass channels. Their complete element count fits a signed 32-bit size. Every accessed owner is disjoint, naturally aligned and within its buffer.

Preserve x18, x19–x29, the low 64 bits of v8–v15, aligned stack and FPCR under AAPCS64, the Arm calling convention. The fixed stack frame uses 1360 bytes for saved registers, owner addressing, live scalars, vector pointers and five child descriptors. Thirteen workspace vectors use $`104N+16`$ bytes, rounded up to a multiple of 16. The accepted child uses its own declared stack. Numerical stages are wholly inside the parent and that assembly child. A private relay may count child calls before dispatching to the unchanged child, and supplies no numerical stage.

## Frozen Acceptance

Before assembly generation, the original passed 770 protected calls covering 1, 2, 3, 7, 16, 65 and 4096 layers, no-snow states, several active layers, a one-layer solve, melting with a second top-boundary solve, freezing, rain, runoff, snowfall, evaporation, capped depth, inactive tails, empty column ranges, independent signed strides and all four states of the two optional diagnostic owners. Independent checks established water mass, ice mass with latent heat, thermal energy and diagnostic relations.

Evaluate physical sums independently in extended precision. Mass and ice residual bounds are $`10^6\epsilon_{\mathrm{FP64}}`$ times the sum of one kg m$`^{-2}`$, absolute input/output masses and boundary mass changes, plus $`128\epsilon_{\mathrm{FP64}}`$ kg m$`^{-2}`$. The thermal residual bound is the same relative factor times the sum of one W m$`^{-2}`$, absolute old and new capacity-temperature products, phase rates and boundary heat rates, plus $`128\epsilon_{\mathrm{FP64}}`$ W m$`^{-2}`$. These bounds were frozen before testing and cover accumulated rounding without changing any returned bits. For a snow column, the independent thermal equation is $`\sum_{j=1}^n h_j(T_j'-T_j)+\sum_j(q_{m,j}+q_{f,j})+G'=F-S_1+\sum_{j=2}^nS_j+S_{n+1}`$.

Compare all nine complete returned owners as raw bytes, including untouched cells, gaps, extra layers and channels. The native and paired acceptance limit is zero differing bytes. Protect inputs and descriptors against writes and place owners against guards at both ends. Reuse the accepted child's matrix and arithmetic evidence. Retain source identities, controls, actual results and quiet-node conditions locally in `.runtime/openifs/weather24h-snow-water-energy/`. No comparative speed is claimed before repeated timing.

## Checked Results

The unchanged complete arithmetic passed protected native and paired checks on node nid010555 in exclusive allocation 7240564, using CPU 48 and local memory placement. A separate four-call check established the contiguous soil owner's actual lower-bound offsets.

| Check | Calls | Returned owner bytes | Independent relations | Different bytes |
| --- | ---: | ---: | ---: | ---: |
| Original physical budgets before generation | 770 | 21,346,880 | 162,870 | — |
| Complete native body | 770 | 21,346,880 | 162,870 | 0 |
| Soil allocation lower-bound edge | 4 | 11,520 | 252 | 0 |
| Paired original and native calls | 112 | 281,792 | 5,738 | 0 |

The paired parent executed the accepted assembly tridiagonal child 160 times across 640 solved layers. This includes 48 columns that required the second solve at the melting boundary. The count-only wrapper forwards every numerical argument to the unchanged child, so these are genuine complete child executions. Four focused protected cases reproduce a captured wet thin-snow initialisation, with both diagnostic states and both guard placements. Source/native and paired comparisons each passed 6,880 complete owner bytes, zero differences and 236 independent relations. The resolved-snow budgets and all numerical bodies are unchanged. Forecast acceptance remains a separate integration gate.

The parent prepares owner addressing and its thirteen workspace vectors once per call, then reuses them across columns. Its five child descriptors refer directly to those vectors, preserving rounded state without a separate packing pass. The protected comparisons establish the storage and numerical correspondence. Repeated whole-forecast timing is still needed before a speed claim.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_webal_mod::srfsn_webal | 2,150 | 52,425,600 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
