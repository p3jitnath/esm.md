# Two-dimensional Rusanov–SSPRK2 solver contract

This reference records the numerical choices derived from the [basic model note](../../../formulations/sw/2d_periodic.md). A numerical method replaces continuous space and time with cells and steps; the contract fixes those choices, the order of arithmetic, and the required outputs so that implementations can be compared exactly. Read it when generating or changing this model. The verified equations and revision below are retained unchanged.

## 01. Document control

<details>
<summary>Document identity and frozen revision</summary>

| Field | Value |
| --- | --- |
| Template revision | 1.3 |
| Formulation ID | esm.shallow-water.periodic |
| Formulation revision | 1.0 |
| Status | Frozen after independent physical verification of the Fortran reference |
| Date | 2026-10-04 |
| Model name | Periodic nonlinear shallow-water equations |

</details>

## 02. Physical scope and assumptions

The model describes depth-averaged flow over a flat bed, using hydrostatic pressure and constant gravitational acceleration. The initial study keeps all depths positive and excludes rotation, external forcing, friction, wetting, drying, and topography.

| ID | Definition |
| --- | --- |
| S01 | Hydrostatic, depth-averaged flow; Pressure flux is $`gh^2/2`$; Horizontal scales must exceed the water depth for a physical application |
| S02 | Flat bed and no forcing; All source terms are zero; No bathymetry, rotation, or external stress |
| S03 | Positive finite depth; Velocities and wave speeds are well defined; $`10^{-6}\leq h\leq10^6`$ m; every stage remains finite |
| S04 | Periodic rectangular domain; Opposite boundaries identify the same state; Verification of an isolated discontinuity uses a region before boundary interaction |

| Term | Definition |
| --- | --- |
| State | Depth and the two depth-weighted velocities; Noun for $`\mathbf q`$ |
| Halo | One copied periodic cell layer surrounding the interior; Noun for the boundary storage |
| Stage | An intermediate state in the time update; Noun for $`\mathbf q^{(1)}`$ |
| Binary64 | IEEE 754 floating-point format with 64 storage bits; Noun for FP64 storage and arithmetic |
| Rusanov flux | A central flux with local wave-speed dissipation; Noun for D01 |
| SSPRK2 | The two-stage, second-order strong stability preserving Runge–Kutta method; Noun for T01 |

## 03. Symbols and units

The state contains depth $`h`$ and the two depth-weighted velocities $`m_x=hu`$ and $`m_y=hv`$. Depth is in metres, velocity is in metres per second, and momentum components are in square metres per second.

<details>
<summary>Complete symbol glossary, units, and supported ranges</summary>

| Symbol | Definition |
| --- | --- |
| $`x,y,t`$ | Coordinates and time; m, m, s; Scalars; Domain and run interval |
| $`L_x,L_y`$ | Domain lengths; m; Scalars; Positive; both 1 m in the study |
| $`h,u,v`$ | Depth and velocities; m, m/s, m/s; Scalars; S03 and finite velocities of magnitude at most $`10^3`$ m/s |
| $`m_x,m_y`$ | $`hu,hv`$; m²/s; Scalars; Finite |
| $`\mathbf q`$ | $`(h,m_x,m_y)^T`$; Component units; Vector; Three components |
| $`g,c`$ | Gravity and $`\sqrt{gh}`$; m/s², m/s; Scalars; $`10^{-6}\leq g\leq10^6`$; $`c>0`$ |
| $`\mathbf F,\mathbf G,\mathbf F_d`$ | Physical fluxes, with $`\mathbf F_x=\mathbf F,\mathbf F_y=\mathbf G`$; m²/s for depth; m³/s² for momentum; Vectors; P02 |
| $`\widehat{\mathbf F}_d,\alpha_d`$ | Interface flux and local speed bound; Flux units, m/s; Vector, scalar; D01 |
| $`n_x,n_y,i,j,a`$ | Mesh dimensions, cell indices, component index; 1; Integers; $`1\leq n_x,n_y\leq4096`$, $`a\in\{0,1,2\}`$ |
| $`\Delta x,\Delta y,\Delta t`$ | Cell dimensions and fixed time step; m, m, s; Scalars; Positive |
| $`\mathcal L`$ | Discrete flux-divergence operator; Component units per second; Vector operator; D02 |
| $`n,N`$ | Current step and run step count; 1; Integers; $`0\leq n\leq N\leq10^6`$ |
| $`H,U_0,A`$ | Reference depth, mean velocity, shear amplitude; m, m/s, m/s; Scalars; Section 06 |
| $`h_*,u_*,s,\xi`$ | Riemann middle state, shock speed, similarity coordinate; m, m/s, m/s, m/s; Scalars; P03 |
| $`p,A_x,C,A_y,s_x,s_y`$ | Ordered pressure, momentum fluxes, and point speed bounds; m³/s² for fluxes, m/s for speeds; Scalars; Section 10 |
| $`R`$ | One-operation binary64 rounding; Argument units; Operator; Finite supported operations |
| $`z`$ | Ordered product gh; m²/s²; Scalar; D03 |
| $`f,d_x,d_y,\ell,e`$ | Component face flux, directional divergences, signed divergence, and Euler output; Flux units, component units per second, component units; Scalars; D04 |
| $`H_b,V_b`$ | Depth and velocity bounds used to choose the time step; m, m/s; Scalars; $`H_b=17/16`$ m, $`V_b=3/16`$ m/s; IC04 uses $`H_b=2`$ m |
| $`b_0,b_1`$ | Endpoints of an exact-reference integration segment; m; Scalars; A cell split at wave boundaries |
| $`\Omega,\lvert\Omega\rvert`$ | Compared cells and their count; 1; Set, integer; Section 11 |
| $`P,S,o`$ | Row pitch, field size, and byte offset; Elements, elements, bytes; Integers; Section 10 |
| $`B_a,E_1,E_B,p_{\rm obs},s_a`$ | Budgets, errors, observed order, and component scales; Section 11; Scalars; Section 11 |

Left and right subscripts denote states adjacent to an interface; west, east, south, and north denote the four faces of a cell. A superscript $`n`$ denotes the current time level, while $`(1)`$ denotes the first Runge–Kutta stage.

</details>

## 04. Domain, geometry, state, and parameters

The domain is $`[0,L_x)\times[0,L_y)`$, with opposite faces identified. The x and y axes point east and north, so outward normal signs follow those directions and there are no coordinate singularities.

| Item | Definition |
| --- | --- |
| Spatial domain | $`0\leq x<L_x,\ 0\leq y<L_y`$, with $`L_x=L_y=1`$ m |
| Time interval | $`0\leq t\leq N\Delta t`$; each case fixes $`N,\Delta t`$ |
| Coordinate system | Cartesian, eastward x and northward y |
| Geometry | Flat bed; unit Cartesian metric |

**P01. State and governing system**

```math
\mathbf q=(h,m_x,m_y)^T,\quad m_x=hu,\quad m_y=hv,\qquad
\partial_t\mathbf q+\partial_x\mathbf F(\mathbf q)+
\partial_y\mathbf G(\mathbf q)=\mathbf0.
```

| Quantity | Definition |
| --- | --- |
| $`g`$ | Shared binary input; study value 9.81; m/s²; Constant; Positive and within Section 03 |
| $`n_x,n_y`$ | Shared integer dimensions; 1; Constant; Section 03 |
| $`\Delta x,\Delta y`$ | Shared binary values for $`L_x/n_x,L_y/n_y`$; m; Constant; Positive |
| $`\Delta t,N`$ | T01 and the case duration; s, 1; Constant; Stage stability condition |
| Initial state | Section 06, generated once and shared as bytes; Component units; Space; S03 |

Velocities are diagnostics $`u=m_x/h,\ v=m_y/h`$; there are no additional closures or prognostic variables.

## 05. Governing equations

**P02. Physical fluxes**

```math
\mathbf F=
\begin{bmatrix}m_x\\m_x^2/h+gh^2/2\\m_xm_y/h\end{bmatrix},
\qquad
\mathbf G=
\begin{bmatrix}m_y\\m_xm_y/h\\m_y^2/h+gh^2/2\end{bmatrix},
\qquad c=\sqrt{gh}.
```

The source vector is exactly zero. Depth flux has unit m²/s, momentum flux has unit m³/s², and each divergence therefore has the units of its state component per second. Section 10 specifies the ordered realisation of P02.

**P03. Independent central dam-break solution**

For a jump at $`x=L_x/2`$, take $`h_L=2,\ h_R=1,\ u_L=u_R=0`$. The positive middle depth is the unique root in $`(h_R,h_L)`$ of

```math
\begin{gathered}
2(\sqrt{gh_*}-\sqrt{gh_L})+
(h_*-h_R)\sqrt{\frac g2\left(\frac1{h_*}+\frac1{h_R}\right)}=0,\\
u_*=2(\sqrt{gh_L}-\sqrt{gh_*}),\quad s=\frac{h_*u_*}{h_*-h_R}.
\end{gathered}
```

Use 80 bisection iterations on $`[h_R,h_L]`$ for the physical reference. With $`\xi=(x-L_x/2)/t`$, its depth and velocity are

```math
(h,u)=
\begin{cases}
(h_L,0), & \xi\leq-\sqrt{gh_L},\\
((2\sqrt{gh_L}-\xi)^2/(9g),\ 2(\sqrt{gh_L}+\xi)/3),
 & -\sqrt{gh_L}<\xi<u_*-\sqrt{gh_*},\\
(h_*,u_*), & u_*-\sqrt{gh_*}\leq\xi<s,\\
(h_R,0), & \xi\geq s.
\end{cases}
```

The transverse momentum is zero. Split each comparison cell at the wave boundaries, then integrate each smooth segment with two-point Gauss quadrature: for segment endpoints $`b_0,b_1`$, evaluate their midpoint plus and minus $`(b_1-b_0)/(2\sqrt3)`$, multiply the sum by $`(b_1-b_0)/2`$, and divide the total integral by the cell width. This integrates the quadratic fan depth and cubic fan momentum exactly in real arithmetic. Exchange x and y for the second case.

## 06. Initial and boundary conditions

Cell centres are $`x_i=(i-1/2)\Delta x,\ y_j=(j-1/2)\Delta y`$, for interior indices $`1\leq i\leq n_x,\ 1\leq j\leq n_y`$. The evaluator generates each initial array once, and every solver reads the same resulting binary64 values.

| ID | Definition |
| --- | --- |
| IC01 | All; Entire domain; Rest: $`(h,m_x,m_y)=(1,0,0)`$; Component units |
| IC02 | All; Entire domain; Uniform flow: $`h=1,\ u=1/4,\ v=-1/8`$; Component units |
| IC03 | All; Entire domain; Steady shear: $`h=H=1,\ v=0,\ u=U_0+A\sin(2\pi y/L_y)`$, $`U_0=1/8,\ A=1/16`$; Component units |
| IC04 | All; Two halves; Dam break: depth 2 for $`x<1/2`$, depth 1 otherwise, both velocities zero; Component units |
| IC05 | All; Entire domain; Mixed profile: $`h=1+\sin(2\pi x/L_x)\cos(2\pi y/L_y)/16,\ u=1/8+\cos(2\pi x/L_x)/32,\ v=-1/16+\sin(2\pi y/L_y)/64`$; Component units |
| BC01 | All; Every face and corner; $`\mathbf q_{ij}=\mathbf q_{1+((i-1)\bmod n_x),\,1+((j-1)\bmod n_y)}`$; Component units |

For IC03, the initial cell-average sine equals $`\sin(2\pi y_j/L_y)\sin(\pi/n_y)/(\pi/n_y)`$. IC04 uses even dimensions in its varying direction, so the jump coincides with a cell face; its periodic outer jump is excluded from the central physical comparison before interaction. IC05 uses the stated values at cell centres as its discrete initial state, with momenta $`hu,hv`$; it supplies intercomparison and timing workloads.

## 07. Spatial discretisation

| Item | Definition |
| --- | --- |
| Mesh and variable location | Uniform rectangular mesh; cell-average state |
| Cell dimensions and measures | $`\Delta x,\Delta y`$; area $`\Delta x\Delta y`$ |
| Index ranges | Interior $`1..n_x,1..n_y`$; halos at 0 and $`n_x+1,n_y+1`$ |
| Reconstruction | None, because the method is first order in space |
| Numerical flux | D01 in both directions |
| Limiter or filter | None, because the declared cases remain positive under the stage bound |
| Boundary operator | BC01, copying interior values bit for bit |
| Spatial order | First order for smooth states; no smooth-order claim at shocks |

**D01. Interface flux**

```math
\begin{aligned}
\widehat{\mathbf F}_d(\mathbf q_L,\mathbf q_R)&=
\frac{\mathbf F_d(\mathbf q_L)+\mathbf F_d(\mathbf q_R)}2
-\frac{\alpha_d}2(\mathbf q_R-\mathbf q_L),\\
\alpha_d&=\max(|w_{d,L}|+c_L,\ |w_{d,R}|+c_R),\quad w_x=u,\ w_y=v.
\end{aligned}
```

**D02. Complete divergence**

```math
\mathcal L(\mathbf q)_{ij}=
-\left[
\frac{\widehat{\mathbf F}_{x,i+1/2,j}-\widehat{\mathbf F}_{x,i-1/2,j}}{\Delta x}
+\frac{\widehat{\mathbf F}_{y,i,j+1/2}-\widehat{\mathbf F}_{y,i,j-1/2}}{\Delta y}
\right].
```

Each face uses its two adjacent cell states, including copied periodic halos. All three components use the same face speed.

## 08. Time discretisation

**T01. Complete SSPRK2 update**

```math
\mathbf q^{(1)}=\mathbf q^n+\Delta t\,\mathcal L(\mathbf q^n),\qquad
\mathbf q^{n+1}=\frac{\mathbf q^n}{2}+
\frac{\mathbf q^{(1)}+\Delta t\,\mathcal L(\mathbf q^{(1)})}{2}.
```

| Item | Definition |
| --- | --- |
| Time method and order | SSPRK2, second order in time for smooth states |
| Stage dependencies | First divergence uses $`\mathbf q^n`$; second uses $`\mathbf q^{(1)}`$ |
| Source evaluation | None, because the source is zero |
| Time-step rule | For fixed-step runs, $`\Delta t=0.1\min(\Delta x,\Delta y)/(\sqrt{gH_b}+V_b)`$, generated once; for fixed duration $`T`$, $`N=\lceil T/\Delta t\rceil`$, then $`\Delta t=T/N`$ |
| Stability condition | $`\Delta t(\max s_x/\Delta x+\max s_y/\Delta y)\leq0.4`$ at both input stages |
| Final step and stop rule | Exactly N steps, with metadata time $`R(N\Delta t)`$ |

For IC04, use $`H_b=2`$ m in the provisional time-step rule. Update the input halo before its divergence, the stage halo before the second divergence, and the final halo before returning a complete step.

## 09. Invariants and admissible states

**I01. Periodic budgets**

```math
B_a=\Delta x\Delta y\sum_{j=1}^{n_y}\sum_{i=1}^{n_x}q_{aij},
\qquad a\in\{0,1,2\}.
```

| Quantity | Definition |
| --- | --- |
| Mass and momenta | Constant periodic budgets; Conservative flux differences, with floating-point drift; A02 limits |
| Depth | Positive physical state; Positive for the declared cases under the stage bound; $`h\geq10^{-6}`$ m at every stage |
| Total energy | Conserved by smooth inviscid flow; Numerical flux is dissipative; Exact discrete energy conservation is not required |
| State | Finite real values; Finite binary64 values; No NaN or infinity |

The evaluator computes budgets in a deterministic component, row, and column order using compensated or accurately rounded summation, outside timed work.

## 10. Numerical representation and operation contract

Each implementation follows the same ordered binary64 operations, including every intermediate rounding point. The complete contract below defines storage, signed zeros, tie rules, and the bytes that must agree.

<details>
<summary>Exact arithmetic, storage, and canonical output bytes</summary>

Let $`P=n_x+2,\ S=P(n_y+2)`$, with zero-based component $`a`$. The byte offset is $`o(a,j,i)=8(aS+jP+i)`$.

| Quantity | Definition |
| --- | --- |
| q | Three fields, each $`(n_y+2,n_x+2)`$; offset o; Binary64; Component units; Current state; Interior unchanged by one step; halos may be copied |
| stage | Same as q; Binary64; Component units; First-stage output; Fully written, including halos; no overlap with other buffers |
| out | Same as q; Binary64; Component units; Complete-step output; Fully written, including halos; no overlap |
| work | Five fields with the same pitch, storing $`A_x,C,A_y,s_x,s_y`$; Binary64; Flux or speed units; Scratch; Contents unspecified on return; no overlap |
| parameters | Four values $`g,\Delta x,\Delta y,\Delta t`$, offsets 0,8,16,24; Binary64; Parameter units; Input; Unchanged; no overlap |

**D03. Ordered point quantities**

Every R below rounds exactly one indicated operation to binary64.

```math
\begin{aligned}
u&=R(m_x/h),\quad v=R(m_y/h),\\
z&=R(gh),\quad c=R(\sqrt z),\quad p=R(R(z h)/2),
\end{aligned}
```
```math
\begin{aligned}
A_x&=R(R(m_xu)+p),\quad C=R(m_xv),\quad A_y=R(R(m_yv)+p),\\
s_x&=R(|u|+c),\quad s_y=R(|v|+c).
\end{aligned}
```

Thus the ordered flux vectors are $`(m_x,A_x,C)`$ and $`(m_y,C,A_y)`$. The expression $`m_xv`$ is the declared evaluation of the common cross flux, even when another algebraically equivalent expression is available.

**D04. Ordered face and cell arithmetic**

For each component and face, choose $`\alpha=s_L`$ when $`s_L\geq s_R`$, and $`s_R`$ otherwise. Evaluate

```math
f=R\left(R(R(f_L+f_R)/2)-
R(R(\alpha/2)\,R(q_R-q_L))\right),
```
```math
d_x=R(R(f_E-f_W)/\Delta x),\quad
d_y=R(R(f_N-f_S)/\Delta y),\quad
\ell=-R(d_x+d_y),\quad e=R(q+R(\Delta t\,\ell)).
```

The first stage stores e. The final stage stores $`R(R(q^n/2)+R(e/2))`$, where e now uses the first-stage input. Negation and absolute value operate on the sign bit without changing the remaining bits.

| Property | Required rule |
| --- | --- |
| Precision and rounding | Binary64, round to nearest with ties to even |
| Floating-point environment | Arm FPCR is zero before invocation; retain gradual underflow and signed zeros |
| Input and constant bytes | Shared binary files; parameters have identical bit patterns; 0, 1/2, and 1 are exact |
| Operation order | D03 and D04, preserving every dependency and rounding point |
| Intermediate rounding | R marks each arithmetic rounding; no extended-precision intermediate |
| Fused multiply-add | Forbidden, including compiler contraction |
| Division and square root | Correctly rounded binary64 operations; no approximations |
| Reductions | No reduction inside the step; evaluator order is fixed |
| Non-finite values and underflow | Non-finite states fail acceptance; gradual underflow is required |
| Signed zero and ties | Preserve all output bits; choose the left speed at a tie |
| Memory bounds and alignment | Buffers cover the stated shapes, are aligned to at least 8 bytes, and have disjoint storage |
| Inputs and outputs | Complete T01 step with BC01; return stage and out |
| Output byte encoding | The 80-byte header below, then interior fields in component, row, column order, x contiguous |
| Output checkpoints | Stage and final state at every verification step; selected files retained |
| Scratch storage | Exactly $`5S`$ values; may be reused after each stage |
| Invalid input | Outside the supported domain; the evaluator rejects it before invoking a solver |

The canonical header uses little-endian integers and floating-point values: 8 bytes `ESMSW001`, then unsigned 64-bit $`n_x,n_y,n,\mathrm{phase}`$, then binary64 $`g,\Delta x,\Delta y,\Delta t,t`$, with $`t=R(n\Delta t)`$. Phase 0 denotes an input, phase 1 the first stage, and phase 2 a complete step. The payload contains $`3n_xn_y`$ binary64 values without halos or padding. No implementation name, timestamp, or runtime measurement enters these bytes.

A repeated-step entry may alternate q and out without copying interior fields; after an odd step count the final state is in out, and after an even count it is in q. The one-step operation still preserves its input interior, while repeated steps may overwrite both buffers. CPU registers, assembly syntax, and calling conventions belong to the separate target interface record.

</details>

## 11. Numerical acceptance criteria

Acceptance requires independent physical checks, conserved periodic budgets within the declared limit, valid boundaries and buffers, and zero differing output bytes at every verification stage and step.

<details>
<summary>Verification cases and numerical limits</summary>

**A01. Independent physical error and observed order**

```math
E_1=\max_a\frac1{|\Omega|}\sum_{(i,j)\in\Omega}
\frac{|q_{aij}-q^{\rm exact}_{aij}|}{s_a},
\quad s_0=H,\quad s_1=s_2=H\sqrt{gH},
\quad p_{\rm obs}=\log_2(E_1(\Delta)/E_1(\Delta/2)),
```

where H is 1 m and $`\Omega`$ is the set of compared cells.

**A02. Budget drift**

```math
E_B=\max_a
\frac{|B_a^N-B_a^0|}
{\Delta x\Delta y\,(\sum_{ij}|q_{aij}^0|+n_xn_y s_a)}.
```

| ID | Definition |
| --- | --- |
| V01 | IC01 and IC02, 7×5 cells, 16 steps; IC01 also uses negative-zero momenta; Constant-state solution of P01; Maximum scaled absolute error; $`10^{-14}`$; Every stage and step |
| V02 | All shared cases and checkpoints; Reviewed Fortran discrete trajectory; Byte differences; 0 bytes; Every stage and step, checkpoint and final files |
| V03 | IC03 and its x/y exchange, 32²,64²,128² cells; Exact stationary shear, using initial cell averages; A01; $`0.75\leq p_{\rm obs}\leq1.25`$, decreasing error, $`E_1(128)\leq0.01`$; $`T=1/32`$ s |
| V04 | IC04 and its x/y exchange, 256×8 and 8×256 cells; P03 exact cell averages; A01; $`E_1\leq0.04`$ in $`1/4\leq x\leq3/4`$, or its y exchange; $`T=1/32`$ s |
| V05 | IC05, 31×23 cells, 1000 steps; I01 and admissible domain; A02, minimum depth, finite state, stage bound; $`E_B\leq10^{-10}`$, Section 09 depth, CFL at most 0.4; Every stage and step; final budget |
| V06 | IC05 on 1×1,2×3,7×5,31×23 cells, 8 steps; BC01 and storage rules; Guard, input, and halo byte changes; Zero guard changes and zero input-interior changes; exact periodic copies; Every step |
| V07 | IC05, 64²,256²,1024² cells; Reviewed Fortran at the same step count; V02 and V05; Zero differing bytes and the same admissibility limits; Outside each timed batch |

A direct byte comparison decides V02, including signed zeros and deterministic header metadata; hashes identify files but do not replace comparison. The verifier reports the first differing step, phase, component, cell, and two bit patterns, and a failure excludes that implementation from timing. Physical criteria remain separate because a shared defect can produce identical bytes.

</details>

## 12. References and limitations

| ID | Definition |
| --- | --- |
| R01 | [Clawpack Riemann book: shallow water](https://www.clawpack.org/riemann_book/html/Shallow_water.html); Governing flux, characteristic speeds, and rarefaction/shock relations; P02 and P03 |
| R02 | [Clawpack Riemann book: approximate solvers](https://www.clawpack.org/riemann_book/html/Approximate_solvers.html); Local dissipative approximate flux; D01 |

The first study concerns this positive-depth, periodic component and this binary64 operation contract. It does not establish dry-state behaviour, physical fidelity of an entire Earth system model, formal correctness, cross-architecture reproducibility, or global machine optimality. All equations needed by the implementations and independent verifier are included above, while the references establish their scientific origin.
