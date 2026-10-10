# Vertical Diffusion Increment Contract

Revision 1 implements `VDFINCR` from [the physics note](../../../../../formulations/openifs/physics/vertical_diffusion_increments.md), revision 1. The original is `ifs-source/arpifs/phys_ec/vdfincr.F90`, SHA-256 `aa5eee6852c260ac0618bdd1be550397d5b5662ea2f568a3ff6ff6645cb81d6f`. The [direct assembly](../../../../../src/openifs/physics/vdfincr.S) supplies every tendency update, six momentum fluxes, two column dissipation integrals and two bottom flux copies.

## Domain And Ordered Arithmetic

Let $`K`$ count columns and $`N`$ count layers. Support $`0\leq K\leq4096`$ and $`0\leq N\leq1024`$, selected indices `KIDIA` through `KFDIA` within `1..K`, and empty selections. The timestep $`t`$ and gravity $`g`$ are positive. Require finite inputs, nonnegative downward pressure differences and finite intermediate results. Require FPCR zero for nearest rounding with ties to even, gradual underflow and signed zeros. Each operation rounds separately to FP64. Forbid contraction, reassociation and approximate reciprocals.

First calculate `c1=1/t`, `c2=1/(g*t)` and `cg=1/g`, in that order. Initialise selected column dissipation, six upper fluxes and two bottom flux outputs to positive zero. Process layers from one to $`N`$. At each selected cell use `dp=p(k)-p(k-1)` and `mass=(-dp)*cg`. Wind before diffusion is `u1=u_old+u_tendency*t` and similarly for `v1`. Next use `u2=u1+u_vdf*t`, `v2=v1+v_vdf*t`, `u3=u2+u_so*t` and `v3=v2+v_so*t`, where `so` identifies smaller-hill drag.

```math
D_{\mathrm{vdf}}=\bigl(0.5(u_1-u_2)\bigr)(u_1+u_2)+\bigl(0.5(v_1-v_2)\bigr)(v_1+v_2),
```

```math
D_{\mathrm{so}}=\bigl(0.5(u_2-u_3)\bigr)(u_2+u_3)+\bigl(0.5(v_2-v_3)\bigr)(v_2+v_3).
```

Store `D_so` in `PDISGW3D`, in joules per kilogram. Each flux uses `next=tendency*mass+previous`, for U then V from diffusion, smaller hills and turbulent hill drag, in that order. Add diffusion and smaller-hill wind tendencies to the old tendency with two left-to-right additions. Accumulate `D_vdf*dp` and `D_so*dp` in separate column sums in increasing layer order. Add `PQTEVDF` to `PQTE`. Store `PSLGE+PSLGEVDF` in `PSLGEWODIS`, then add `(D_vdf+D_so)*c1` to that rounded sum for `PSLGE`. Finally copy the two bottom turbulent-hill fluxes to `PTOFDU,PTOFDV` and multiply each column dissipation sum by `c2`.

## ABI And Complete Owners

The application binary interface, or ABI, has 36 ordinary pointers. The first eight use `x0` through `x7`. Arguments nine through 36 use caller stack offsets 0 through 216 in eight-byte steps. Integers are four bytes. Reals are eight-byte-aligned little-endian FP64. Matrices use Fortran order, with columns contiguous. Layer matrices own $`8KN`$ bytes, interface matrices own $`8K(N+1)`$ bytes and column vectors own $`8K`$ bytes.

| Argument positions | Names and role |
| --- | --- |
| 1–5 | `KIDIA,KFDIA,KLON,KLEV,KTOP`, integer inputs |
| 6–8 | `PTMST` timestep, `PUM1,PVM1` old winds |
| 9–11 | `PSLGM1,PTM1,PQTM1`, unused old thermodynamic inputs |
| 12 | `PAPHM1`, pressure interfaces at levels `0..N` |
| 13–18 | `PDTUTOFD,PDTVTOFD,PDTUSO,PDTVSO,PDTUVDF,PDTVVDF`, drag tendencies |
| 19–22 | `PVOM,PVOL,PSLGE,PQTE`, existing and returned tendencies |
| 23–24 | `PSLGEVDF,PQTEVDF`, diffusion heat and water inputs |
| 25–27 | `PSLGEWODIS,PVDIS,PVDISG`, heat-before-dissipation matrix and two column dissipation outputs |
| 28–33 | `PSTRTU,PSTRTV,PSTRSOU,PSTRSOV,PSTRTOFDU,PSTRTOFDV`, six interface flux outputs |
| 34–36 | `PTOFDU,PTOFDV,PDISGW3D`, two bottom flux vectors and hill-energy-loss matrix |

`KTOP` is unused. Output owners are disjoint from one another, inputs and globals. Inputs stay read-only, and unselected output columns keep their incoming bytes. The unchanged global `__yomcst_MOD_rg` supplies gravity. No external numerical helper is called.

The leaf's 384-byte aligned frame stores 36 pointers and preserved registers. It preserves `x19` through `x30`, leaves `x18` and the preserved low halves of `v8` through `v15` untouched, and restores the stack. SIMD pairs of independent columns and the scalar tail preserve the same layer order and rounding points. No array scratch is used.

## Independent Physics And Bytes

The verifier compares factored energy losses with exact rational differences of squared rounded winds. It checks pressure-weighted momentum, wind changes, heat transfer, water tendency addition and complete column energy integrals against exact rounding-error budgets. Canonical bytes concatenate all 16 complete output owners in argument order. Acceptance requires zero differing bytes.

The original passed 18 cases, 834,672 bytes and 79,252 independent physical relations, including 72 subnormal values. Native passed 36 guarded calls, 1,669,344 bytes and 158,504 relations, including 144 subnormal values, with zero differences. Cases cover paired and odd columns, interior and empty selections, empty dimensions, timestep and gravity variants, drag, calm wind, zero pressure thickness, signed zeros, subnormals, halfway rounding, observable contraction and dimension limits. Read-only inputs, both protected buffer placements, preserved registers and FPCR zero passed. The paired relay passed 18 calls, 834,672 complete returned bytes and 648 unchanged scalar and gravity bytes, with zero differences. It runs the original on cloned complete output owners and returns native values. No comparative timing or speed claim is available.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 98,246,400 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
