# Implicit Momentum Diffusion Contract

Revision 1 implements `VDFDIFM` from [the physical momentum balance](../../../../../formulations/openifs/physics/implicit_momentum_diffusion.md), revision 1. Its original is `ifs-source/arpifs/phys_ec/vdfdifm.F90`, SHA-256 `c5cab410930d0ec08498ae54ad1f53f76ce5777f5bb7e9d886256b8d4dc3d82f`. The [direct assembly](../../../../../src/openifs/physics/vdfdifm.S) supplies coefficient formation, both complete wind solves, all six returned drag tendencies and the positive-zero diagnostic prefix.

## Domain And Method

Let $`K`$ count columns, $`N`$ count layers and $`T`$ be `KTOP`. Support $`0\leq K\leq4096`$, $`2\leq N\leq1024`$ and $`1\leq T<N`$. Selected columns run from `KIDIA` through `KFDIA`, with valid bounds and empty selections. Require positive timestep $`t`$, positive gravity $`g`$, strictly increasing pressure, nonnegative mixing and drag coefficients, finite inputs and finite intermediates. Both boundary equations must exist.

Use an implicit update, which evaluates mixing and drag at the new wind. Each wind gives a tridiagonal system, with the diagonal and its two neighbours nonzero. Solve it by downward elimination and upward substitution. Its independent physical matrix has nonpositive neighbouring coefficients and a strictly dominant positive diagonal. This gives a unique wind solution. Surface mixing uses the supplied ocean current. The source's saved convective multiplier is positive zero. Preserve every supplied mass-flux and plume-wind multiplication by that zero, including their signed zeros.

Require FPCR zero for nearest rounding with ties to even, gradual underflow and signed zeros. Every arithmetic operation below rounds separately to FP64. Forbid contraction, reassociation and approximate reciprocals. First use `s=g*t` and `it=1/t`. At interface `j` calculate `M(j)=PMFLX(j)*0` and `H_u(j)=M(j)*PUUH(j)`, with the corresponding V product.

## Ordered Column Equations

Let `c` denote `PCFM`, `o` denote `PTODC`, `d` denote `PSOC` and `e` denote explicit hill forcing. At row `k` use `r=s/(p(k)-p(k-1))`. For interior rows form `a=(-c(k-1)-M(k-1))*r`, `cdiag=(-c(k))*r` and `b=1+((c(k-1)+c(k))+M(k))*r+(o(k)+d(k))*t` with left-to-right additions. The upper row uses positive-zero `a` and `b=1+(c(k)+M(k))*r+(o(k)+d(k))*t`. The bottom row uses positive-zero `cdiag` and `b=1+(c(k-1)+c(k))*r+(o(k)+d(k))*t`.

The ordinary forcing is `y=(u_old+t*(u_tendency+e))+(H_u(k)-H_u(k-1))*r`. At the top replace the last term with `H_u(k)*r`. At the bottom subtract `H_u(k-1)*r`. Use the corresponding V inputs for the other wind.

At the top use `beta=1/b` and `u=y*beta`. Each later row uses `gamma=cdiag_previous*beta_previous`, `beta=1/(b-a*gamma)` and `u=(y-a*u_previous)*beta`. At the bottom add `(c(k)*r)*u_current` to the rounded numerator before multiplying by `beta`. Use the same `beta` and `gamma` for V. Substitute upward with `u=u-gamma_next*u_next` and similarly for V. Recomputing immutable coefficients when needed must keep each operand and rounding point.

Above row `T` set all six selected diagnostic tendencies to positive zero and preserve incoming solution bytes. At each solved row calculate `total=(u-u_old)*it`, `tofd=u*(-o)`, `so=u*(-d)+e` and `vdf=(total-u_tendency)-so`. The same stages apply to V. Preserve all unselected output bytes.

## ABI And Storage

The application binary interface, or ABI, has 29 ordinary pointers. The first eight use `x0` through `x7`. Remaining pointers use caller stack offsets 0 through 160 in eight-byte steps. Integers are four bytes. Reals are eight-byte-aligned little-endian FP64. Layer matrices have $`KN`$ elements in Fortran order. Pressure, convective mass flux and plume winds have $`K(N+1)`$ elements indexed from interface zero. Surface currents have $`K`$ elements.

| Positions | Arguments |
| --- | --- |
| 1–6 | `KIDIA,KFDIA,KLON,KLEV,KTOP,PTMST` |
| 7–11 | `PUM1,PVM1,PAPHM1,PCFM,PTODC` |
| 12–16 | `PSOTEU,PSOTEV,PSOC,PVOM,PVOL` |
| 17–21 | `PUCURR,PVCURR,PMFLX,PUUH,PVUH` |
| 22–29 | `PUDIF,PVDIF,PDTUTOFD,PDTVTOFD,PDTUSO,PDTVSO,PDTUVDF,PDTVVDF` |

All eight complete output owners are separate from each other and every input or global. Inputs and the gravity global `__yomcst_MOD_rg` remain unchanged. No external numerical helper is called. The assembly preserves `x19` through `x30`, leaves `x18` and the preserved low halves of `v8` through `v15` untouched, and restores the aligned stack. A 336-byte fixed frame stores pointers and saved registers. Gamma scratch needs only $`16N`$ bytes for a pair of columns, with the same space reused for the scalar tail.

## Independent Physics And Bytes

Before emission the genuine original passed 16 cases, 598,336 complete output bytes and 80,742 independent physical relations, including 36 subnormal values. The verifier forms the physical matrix separately, checks exact rational row and column momentum balances and drag diagnostics, and uses exact pivoted dense elimination for small systems. Constant winds with matching surface currents give an additional known solution.

Propagated rounding bounds use exact rational arithmetic. Each bound is enclosed upward on a $`2^{-2200}`$ lattice by integer ceiling, which preserves its guarantee while keeping its denominator bounded. This changes no FP64 result. The physical comparisons use the resulting rigorous bounds. Cases cover both boundaries, a changing upper row, paired and odd columns, interior and empty selections, zero columns, timestep and gravity variants, zero and strong mixing, constant winds, signed zeros, subnormals, halfway rounding, contraction and the column and layer limits. Canonical bytes concatenate all eight complete output owners in argument order. Acceptance requires zero differing bytes. The native body passed 32 guarded calls, 1,196,672 complete output bytes and 161,484 physical relations, including 72 subnormal values, with zero differences. Read-only inputs, both protected buffer placements, preserved registers and FPCR zero passed. The paired relay passed 16 calls, 598,336 complete returned bytes and 576 unchanged scalar and gravity bytes, with zero differences. It runs the original on cloned complete outputs and returns native values.  No comparative timing or speed claim is available.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 62,745,600 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.
