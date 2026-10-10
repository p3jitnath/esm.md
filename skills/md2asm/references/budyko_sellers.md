# Energy-balance solver contract

This reference records the numerical choices derived from the [basic model note](../../../formulations/ebm/budyko_sellers.md). A numerical method replaces continuous space and time with cells and steps; the contract fixes those choices, the order of arithmetic, and the required outputs so that implementations can be compared exactly. Read it when generating or changing this model. The verified equations and revision below are retained unchanged.

## 01. Document control

<details>
<summary>Document identity and frozen revision</summary>

| Field | Value |
| --- | --- |
| Template revision | 1.3 |
| Formulation ID | esm.budyko-sellers.diffusive |
| Formulation revision | 1.1 |
| Status | Frozen after independent physical verification of the Fortran reference |
| Date | 2026-10-04 |
| Model name | Diffusive Budyko–Sellers energy balance model |

</details>

## 02. Physical scope and assumptions

The state is surface temperature averaged around each latitude band, with constant heat capacity, linear outgoing longwave radiation (OLR), idealised annual insolation, diffusive meridional heat transport, and a temperature threshold for ice albedo. Seasonal forcing, moisture, explicit ice dynamics, and longitude dependence are absent because this operation isolates the annual-mean energy balance.

| ID | Definition |
| --- | --- |
| S01 | Zonal symmetry on a sphere; The area coordinate is µ=sin(φ); Latitude φ lies between the poles |
| S02 | Constant heat capacity and diffusion; C and D are spatially constant; Positive C; nonnegative D |
| S03 | Linear outgoing radiation; OLR=A+BT; Temperature is in degrees Celsius |
| S04 | Prescribed annual insolation; Forcing is independent of time; No seasonal cycle |

| Term | Definition |
| --- | --- |
| Cell average | Mean temperature over one equal-area latitude band; Noun for T_i |
| Face flux | The signed diffusive quantity J at a band interface; Noun for D02 |
| Stage | The intermediate SSPRK2 temperature; Noun for T¹ |
| Ice branch | The albedo choice when T is at or below T_f; Noun for P02 |

## 03. Symbols and units

The state is the mean surface temperature $`T_i`$ of latitude band $`i`$, in degrees Celsius. The equal-area coordinate $`\mu=\sin\varphi`$ runs from the South Pole at −1 to the North Pole at 1.

<details>
<summary>Complete symbol glossary, units, and supported ranges</summary>

| Symbol | Definition |
| --- | --- |
| φ,µ,t | Latitude, sin(latitude), and time; rad, 1, s; Scalars; µ∈[−1,1], t≥0 |
| T,T_i | Surface temperature and cell average; °C relative to 273.15 K; Scalar and indexed state; −100≤T≤100 at every stage |
| C,A,B,D | Heat capacity, OLR intercept, OLR slope, and diffusion parameter; J m⁻² K⁻¹, W m⁻², W m⁻² K⁻¹, W m⁻² K⁻¹; Scalars; C>0, 0≤A≤1000, 0≤B≤100, 0≤D≤100 |
| S_0,Q,s_2 | Solar constant, S_0/4, and insolation coefficient; W m⁻², W m⁻², 1; Scalars; S_0>0, −1≤s_2≤1 |
| α,a_0,a_2,a_i,T_f | Albedo, warm coefficients, ice value, and threshold; 1, 1, 1, 1, °C; Scalars; 0≤α≤1, −100≤T_f≤100 |
| P_2,µ_i,µ_f,δ | Legendre polynomial, cell centre, face coordinate, and spacing; 1; Scalars; P_2(µ)=(3µ²−1)/2, δ=2/N |
| N,i,f,n,M,P | Cell count, cell/face indices, step, run count, and storage length; 1; Integers; 1≤N≤65536, 1≤i≤N, 0≤f≤N, 0≤n≤M≤10⁶, P=N+2 |
| K_f,W_i,I_i,J_f,r_i,ℓ_i,β,e_i | Face coefficient, warm/ice absorbed shortwave radiation (ASR), flux, net radiation, tendency, time coefficient, and Euler state; Defined by D01–D03; Indexed scalars; Finite; W_i,I_i∈[0,1000], K_f≥0 |
| p_i,P̄₂,i | Centre value and cell average of P₂; 1; Indexed scalars; D01 and IC01 |
| S_i,a_w,i,F_i | Local insolation, warm albedo, and selected ASR; W m⁻², 1, W m⁻²; Indexed scalars; S_i≥0; 0≤a_w,i≤1; F_i∈[0,1000] |
| L | Largest linear radiation and diffusion decay coefficient; W m⁻² K⁻¹; Scalar; L≥0 |
| R,Δt,H,E_∞,E_H,p_obs | One-operation rounding, time step, mean heat, error metrics, and observed order; Argument units, s, J m⁻², K, 1, 1; Operators and scalars; Sections 08–11 |

</details>

## 04. Domain, geometry, state, and parameters

| Item | Definition |
| --- | --- |
| Spatial domain | −1≤µ≤1, south to north |
| Time interval | 0≤t≤MΔt |
| Coordinate system | Equal-area coordinate µ=sin(φ) |
| Geometry | Spherical, zonally symmetric bands; the µ metric removes the latitude-coordinate singularity |

The prognostic state is T_i, while albedo, radiation, and face fluxes are diagnostic quantities evaluated from the current stage.

| Quantity | Definition |
| --- | --- |
| Standard climate parameters | C=41813000, A=210, B=2, D=0.555, S_0=1365.2, s_2=−0.48, a_0=0.3, a_2=0.078, a_i=0.62, T_f=−10; Symbol units; Constant; Shared binary64 values |
| Evaluation parameters | C,Δt,δ,A,B,T_f; Symbol units; Constant per run; Stability rule below |
| Static coefficients | K,W,I from D01, or the explicitly defined analytic verification inputs; D01 units; Face or cell; Identical bytes across implementations |

The standard C represents a 10 m water layer with density 1000 kg m⁻³ and specific heat 4181.3 J kg⁻¹ K⁻¹. This is a physical parameter choice, while δ and Δt belong to the numerical method.

## 05. Governing equations

**P01. Annual-mean energy balance**

```math
\begin{aligned}
C\,\partial_tT&=(1-\alpha)Q[1+s_2P_2(\mu)]-(A+BT)\\
&\quad+D\,\partial_\mu[(1-\mu^2)\partial_\mu T],\qquad Q=S_0/4.
\end{aligned}
```

**P02. Ice-albedo closure**

```math
\alpha(T,\mu)=\begin{cases}a_i,&T\leq T_f,\\a_0+a_2P_2(\mu),&T>T_f.\end{cases}
```

Every term in P01 has units W m⁻²; its diffusion term redistributes heat without supplying a global source.

## 06. Initial and boundary conditions

| ID | Definition |
| --- | --- |
| IC01 | T; All cells; Standard climate T_i=12−40 P̄₂,i, where P̄₂,i=P₂(µ_i)+δ²/8; °C |
| IC02 | T; Analytic cases; Uniform temperature or the cell-averaged mode defined in Section 11; °C |
| BC01 | T; Poles; J_0=J_N=+0, with copied ghosts T_0=T_1 and T_{N+1}=T_N; W m⁻² for J |

The ghost copies include their exact sign bits, and a one-cell grid copies its sole interior value to both ghosts.

## 07. Spatial discretisation

| Item | Definition |
| --- | --- |
| Mesh and variable location | Equal-area finite volumes with cell-average T_i |
| Cell dimensions and measures | δ=2/N; each band has global area fraction 1/N |
| Index ranges | Interior i=1…N; ghosts 0,N+1; faces f=0…N |
| Reconstruction | Centred differences; no separate reconstruction |
| Numerical flux | J_i=K_i(T_{i+1}−T_i) for 1≤i<N; pole flux is +0 |
| Limiter or filter | None, because the declared method uses centred diffusion |
| Boundary operator | BC01 before each stage and on both returned states |
| Spatial order | Second order for smooth forcing and temperature away from an ice-threshold crossing |

**D01. Ordered static coefficients**

Generate the inputs once, with every R indicating one binary64 operation; for cell i and interior face f, evaluate the following expressions in their stated order.

```math
\begin{aligned}
\delta&=R(2/N),\quad \mu_i=R(-1+R(R(i-1/2)\delta)),\\
\mu_f&=R(-1+R(f\delta)),\quad p_i=R(R(R(3R(\mu_i\mu_i))-1)/2),
\end{aligned}
```
```math
\begin{aligned}
S_i&=R(R(S_0/4)R(1+R(s_2p_i))),\quad a_{w,i}=R(a_0+R(a_2p_i)),\\
W_i&=R(R(1-a_{w,i})S_i),\quad I_i=R(R(1-a_i)S_i),
\end{aligned}
```
```math
K_f=R(R(DR(1-R(\mu_f\mu_f)))/\delta),\quad K_0=K_N=+0.
```

W and I use centre sampling, whose smooth spatial error is second order; they are immutable static forcing rather than a numerical time stage. Analytic cases can supply their stated W=I directly, so their exact references isolate the diffusion and time operators.

**D02. Ordered face flux**

```math
J_i=R(K_iR(T_{i+1}-T_i)),\quad 1\leq i<N;\qquad J_0=J_N=+0.
```

Face i is between cells i and i+1, so T_i denotes a cell value and T_f remains the ice threshold.

**D03. Ordered cell tendency and Euler update**

```math
\begin{aligned}
F_i&=\begin{cases}I_i,&T_i\leq T_f,\\W_i,&T_i>T_f,\end{cases}\\
r_i&=R(F_i-R(A+R(BT_i))),\quad \ell_i=R(r_i+R(R(J_i-J_{i-1})/\delta)),\\
\beta&=R(\Delta t/C),\quad e_i=R(T_i+R(\beta\ell_i)).
\end{aligned}
```

## 08. Time discretisation

**T01. Complete SSPRK2 update**

```math
T_i^1=e_i(T^n),\qquad T_i^{n+1}=R(R(T_i^n/2)+R(e_i(T^1)/2)).
```

| Item | Definition |
| --- | --- |
| Time method and order | Two-stage SSPRK2; second order for smooth trajectories |
| Stage dependencies | First stage reads Tⁿ; final stage reads T¹ and averages with Tⁿ |
| Source evaluation | Radiation and the ice branch are evaluated from the current stage temperature |
| Time-step rule | Fixed positive Δt; default Δt=R(R(0.2 C)/L), with L=max_i[B+(K_i+K_{i−1})/δ] |
| Stability condition | (Δt/C) max_i[B+(K_i+K_{i−1})/δ]≤0.4; every stage also satisfies the admissible range |
| Final step and stop rule | Exactly M complete steps, without an implicit partial step |

BC01 belongs to the solver and is applied to the input, first stage, and final state. The stability condition controls the linear diffusion and radiation terms; it does not establish smoothness across the discontinuous ice threshold.

## 09. Invariants and admissible states

**I01. Global heat budget**

```math
H=\frac C N\sum_iT_i,\qquad H^{n+1}-H^n=\frac{\Delta t}{2N}\sum_i[r_i(T^n)+r_i(T^1)]
```

The identity holds in real arithmetic because the shared face fluxes telescope, while acceptance allows the floating-point error specified in A02.

| Quantity | Definition |
| --- | --- |
| Global heat | Changes through net radiation; I01, with rounding drift; A02 |
| Pole transport | Zero; Exact +0 pole flux; BC01 |
| Temperature | Finite within the model's validity range; Finite at every stage; −100≤T≤100 °C |
| State and coefficients | Reflection symmetry for symmetric inputs; Symmetry up to rounding; A03 |

## 10. Numerical representation and operation contract

Each implementation follows the same ordered binary64 operations and returns both complete time stages. The contract below specifies all buffers, threshold ties, signed zeros, and output bytes.

<details>
<summary>Exact arithmetic, storage, and canonical output bytes</summary>

All arrays use contiguous binary64 storage, with P=N+2 and zero-based byte offset 8i for a state or work value; coefficient field a∈{0,1,2} uses offset 8(aP+i), in K,W,I order.

| Quantity | Definition |
| --- | --- |
| q | P values; Binary64; °C; Current state; Interior unchanged by one step; ghosts may change |
| stage,out | P values each; Binary64; °C; First stage and complete step; Fully written; disjoint from other buffers |
| work | P values; Binary64; W m⁻²; Scratch face fluxes; Contents unspecified on return; disjoint |
| coefficients | Three fields of P values; Binary64; W m⁻² K⁻¹ for K; W m⁻² for W,I; Input; Unchanged; K_N and both pole coefficients are +0; unused padding is +0 |
| parameters | C,Δt,δ,A,B,T_f at offsets 0,8,16,24,32,40; Binary64; Symbol units; Input; Unchanged; disjoint |

| Property | Required rule |
| --- | --- |
| Precision and rounding | Binary64, nearest with ties to even |
| Floating-point environment | Arm FPCR=0; gradual underflow and preserved signed zeros |
| Input and constant bytes | One shared input file; +0, 1/2, and 1 are exact |
| Operation order | D01–D03 and T01; independent cells may be scheduled freely |
| Intermediate rounding | Each R is a separate binary64 rounding point |
| Fused multiply-add | Forbidden, including contraction and reassociation |
| Division and square root | Correctly rounded division; no square root in the operation |
| Reductions | Outside the solver, with deterministic accurate summation |
| Non-finite values and underflow | Non-finite inputs are excluded; outputs must remain finite |
| Signed zero and ties | Preserve computed bits; T=T_f takes the ice branch |
| Memory bounds and alignment | Every buffer covers its declared length, is at least 8-byte aligned, and has disjoint storage |
| Inputs and outputs | Complete T01 plus BC01; stage and out returned |
| Output byte encoding | Header below, followed by N interior temperatures south to north |
| Output checkpoints | Every verification stage and step; last stage and final state of each timed batch |
| Scratch storage | Exactly P binary64 values, with no extra numerical buffer |
| Invalid input | Excluded from the solver domain and rejected by the evaluator |

The canonical little-endian 88-byte header contains `ESMEB001`, then unsigned 64-bit N,n,phase, then binary64 C,Δt,δ,A,B,T_f,t with t=R(nΔt). Input phase 0 has the same header followed by N temperature values and all 3P coefficient values; output phases 1 and 2 contain only the N temperatures, with timing metadata stored separately.

Independent work across cells and stages may be interleaved once each cell's stated dependencies and required pole values are available, while both complete returned states remain observable.

The repeated-step entry alternates q and out, placing the final state in out for an odd count and q for an even count, with zero steps leaving all buffers unchanged. A positive normal power-of-two δ permits multiplication by its exact reciprocal in place of division because both instructions round the same real value once; all other δ retain division.

</details>

## 11. Numerical acceptance criteria

Acceptance checks equilibrium, analytic relaxation and thermal-mode convergence, heat balance, symmetry, boundaries, buffer bounds, and exact agreement with the physically verified Fortran reference.

<details>
<summary>Verification cases and numerical limits</summary>

**A01. Temperature error and observed order**

```math
E_\infty=\max_i|T_i-T_i^{\rm exact}|,\qquad p_{\rm obs}=\log_2(E_\infty(\Delta t)/E_\infty(\Delta t/2)).
```

**A02. Normalised heat-budget residual**

```math
E_H=\frac{|(C/N)\sum_i(T_i^{n+1}-T_i^n)-(\Delta t/2N)\sum_i[r_i(T_i^n)+r_i(T_i^1)]|}{C(1+N^{-1}\sum_i|T_i^n|)}\leq10^{-10}.
```

**A03. Symmetry error**

For symmetric inputs, the maximum absolute temperature difference between mirrored cells must be at most 10⁻¹⁰ K after every complete verification step.

| ID | Definition |
| --- | --- |
| V01 | N=7, C=1, A=200, B=2, D=0, W=I=224, T=12, T_f=−10, Δt=0.1; Exact uniform equilibrium T=12; State bytes and A02; Exact state and E_H≤10⁻¹⁰; 16 steps and both stages |
| V02 | N=7, C=1, A=0, B=1, D=0, W=I=0, T=1, T_f=−10; Δt=1/8,1/16,1/32; T(t)=exp(−t); A01; 1.8≤p_obs≤2.2; E_∞(1/32)≤10⁻⁴ K; t=1 |
| V03 | N=16, C=1, A=0, B=1, D=1/16, W=I=0, T_i=1+(1/4)P̄₂,i; Δt=1/256,1/512,1/1024; T_i(t)=exp(−t)+(1/4)P̄₂,i exp[−(1+6D)t]; D02 has exact eigenvalue −6D for P̄₂; A01; 1.8≤p_obs≤2.2; E_∞(1/1024)≤10⁻⁶ K; t=1/2 |
| V04 | Standard climate IC01 on N=1,2,7,31,128,8193 with default Δt; I01, A03, and admissibility; A02, A03, buffer bits; Stated limits; zero guard or input changes; 8 steps; N=31 also 1000 steps |
| V05 | N=7, C=1, A=B=D=0, W=1, I=0, T=T_f=−10, Δt=0.1; and a negative-zero case T=T_f=−0; Exact threshold branch; D03 signed-zero arithmetic; State bytes; Tie remains −10; negative-zero outputs follow ordered arithmetic; 8 steps |
| V06 | Every case, stage, complete state, and canonical file; Physically verified unchanged vanilla Fortran; Byte differences; Zero differing bytes; Each verification step and timed final outputs |

The thermal mode in V03 follows from taking the centred differences of P̄₂,i=P₂(µ_i)+δ²/8: D02 gives −6D P̄₂,i even at the poles, providing an independent physical identity rather than another implementation of the solver.

</details>

## 12. References and limitations

| ID | Definition |
| --- | --- |
| R01 | [climlab EBM documentation](https://climlab.readthedocs.io/en/stable/api/climlab.model.ebm.html); Continuous diffusive EBM and standard parameter choices; P01–P02 and Section 04 |
| R02 | [Brian Rose: one-dimensional EBM](https://brian-rose.github.io/ClimateLaboratoryBook/courseware/one-dim-ebm/); Meridional energy transport and linear radiation; P01 and I01 |
| R03 | [climlab heat-capacity source](https://climlab.readthedocs.io/en/stable/_modules/climlab/utils/heat_capacity.html); Water-layer heat capacity; Section 04 |

The equal-area mesh and explicit SSPRK2 scheme are choices of this experiment, so byte agreement concerns this formulation's implementations and does not assert identical outputs or time integration to climlab. The standard climate workload checks nonlinear albedo and heat budgets, while the smooth analytic cases establish time convergence; the ice discontinuity does not have a claimed smooth temporal order.
