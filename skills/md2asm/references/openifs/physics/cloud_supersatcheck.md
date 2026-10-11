# Cloud Supersaturation Contract

Revision 1 implements the complete original `CLOUD_SUPERSATCHECK` from `arpifs/phys_ec/cloud_supersatcheck.F90`. The [physical input](../../../../../formulations/openifs/physics/cloud_supersaturation.md) defines water and heat changes. The [direct assembly](../../../../../src/openifs/physics/cloud_supersatcheck.S) returns all five adjustment arrays in both original modes. It calls the previously qualified scalar EXP route, while the numerical driver supplies no stage.

## Inputs And Activity

The shape is a contiguous vector of at most 4,096 FP64 cells. FP64 is the 64-bit floating-point format. The selected range runs from `KIDIA` through `KFDIA`, with an empty range permitted. `KLEV` is an unused level count. Every input and output owner contains `KLON` words. The 2,776-byte `TECLDP` object holds the cloud relaxation fraction at byte 136 and the homogeneous-freezing temperature at byte 224. The original `RAMID` and surface-pressure calculation has no output consumer and is removed in the strict original numerical body.

Temperature is finite from 160 to 340 K, pressure and surface pressure are finite from 1 to 2,000,000 Pa, and temporary humidity is finite from −0.1 to 1 kg/kg. The finite supplied cloud fraction can lie from −1 to 2 and is clipped to $`[0,1]`$ for this calculation. The relaxation fraction lies in $`[0,1]`$, and the freezing threshold lies from 160 K to 273.16 K. Constants retain the source-defined binary words in the local frozen thermodynamic record. No input owner is changed.

Scientific admission depends on activity. Negative temporary humidity is admitted only with zero condensation and zero adjustment, so this routine cannot lower it further. A warm state is admitted when passive, or when the cloud update leaves nonnegative condensation. The original 329 and 330 K trigger-gap examples that produce negative condensation remain excluded. A caller must establish this activity condition before invoking the native body. Shape, mode and the floating-point control register are checked directly before output writes.

## Complete Rounded Calculation

Write $`R(v)`$ for nearest-even FP64 rounding. Every ordinary sum, subtraction, product and division has its own $`R`$, with gradual underflow and preserved signed zeros. Fused operations, reassociation, approximate arithmetic and fast-math are forbidden. EXP uses the unchanged qualified [pressure math](../pressure_math.md). Let $`t=\max(T,160)`$, $`A=\max(0,\min(a,1))`$ and $`r_p=R(1/p)`$. The original temperature and cloud clipping stages remain in the body.

Let $`T_0=273.16`$ K. The frozen coefficients are $`b_w=17.502`$, $`b_i=22.587`$, $`d_w=32.19`$ K, $`d_i=-0.7`$ K and $`E_0=380.1608703442847`$ Pa. Define the two separately rounded exponential values

```math
e_w=\operatorname{EXP}\left(R\left(\frac{R(b_wR(t-T_0))}{R(t-d_w)}\right)\right),\qquad
e_i=\operatorname{EXP}\left(R\left(\frac{R(b_iR(t-T_0))}{R(t-d_i)}\right)\right).
```

Form $`f_w=\min(R(R(E_0e_w)r_p),0.5)`$. Form $`f_s`$ in the same way using $`e_w`$ when $`t\ge T_0`$ and $`e_i`$ otherwise. The original phase-coefficient selection has the same rounded coefficients. Let $`v=0.6077667316114637`$, $`K_1=2.583`$ and $`K_2=0.0048116`$ K$`^{-1}`$. Then

```math
f_k=\min(R(f_sR(K_1-R(K_2t))),f_w),\qquad
q_k=R\left(\frac{f_k}{R(1-R(vf_k))}\right).
```

The liquid fraction uses $`T_i=250.16000000000003`$ K, $`T_w=273.16`$ K and $`r_T=0.043478260869565216`$ K$`^{-1}`$. Form $`u=R(R(\max(T_i,\min(T_w,t))-T_i)r_T)`$ and $`\alpha=\min(1,R(u^2))`$. The mixed vapour factor and its humidity are

```math
f_m=\min\left(R\left(R\left(E_0R(R(\alpha e_w)+R(R(1-\alpha)e_i))\right)r_p\right),0.5\right),
g=R\left(\frac{1}{R(1-R(vf_m))}\right),\qquad q_m=R(f_mg).
```

The heat-feedback coefficients are $`D_w=10497584.68169531`$ K$`^2`$ and $`D_i=17451123.253362577`$ K$`^2`$. They contain the saturation slopes and latent heating. Form

```math
d=R\left(R\left(R(\alpha D_w)R\left(\frac{1}{R(R(t-d_w)^2)}\right)\right)+R\left(R(R(1-\alpha)D_i)R\left(\frac{1}{R(R(t-d_i)^2)}\right)\right)\right),
h=R(1+R(R(q_mg)d)),\qquad q_c=R(0.5R(q_k+q_m)).
```

The initial grid-cell limit is $`q_\ell=R(R(Aq_m)+R(R(1-A)q_c))`$. Set $`c=\max(R(q-q_\ell),0)`$ and $`\Delta a=0`$. When $`c>10^{-14}`$ kg/kg, let $`s`$ be the cloud relaxation fraction and compute

```math
F=R(\alpha+R(R(1-\alpha)s)),\qquad \Delta a=R(R(1-A)F),\qquad A'=R(A+\Delta a),
q_\ell'=R(R(A'q_m)+R(R(1-A')q_c)),\qquad c=R\left(\frac{R(q-q_\ell')}{h}\right).
```

The source branch and its threshold are preserved exactly. Scientific admission requires $`c\ge0`$ after this update. The returned mixed temperature uses $`H_w=2489.0792795374246`$ K and $`H_i=2821.2152982440934`$ K.

```math
\Delta T=R(R(R(\alpha H_w)+R(R(1-\alpha)H_i))c),\qquad \Delta q=-c.
```

Mode one returns $`\Delta q_w=R(c\alpha)`$ and $`\Delta q_i=R(cR(1-\alpha))`$. Mode two returns all $`c`$ in the liquid field when $`R(T+\Delta T)\ge T_h`$ and in the ice field otherwise, with positive zero in the other field. Both modes return $`\Delta a`$. No other mode is supported.

## Consumer Meaning And Scientific Limits

`CLOUDSC` lines 3731–3743 and `SLTEND` lines 390–401 choose mode one and add all five adjustments to their state tendencies. Their heat relation uses the actual liquid and ice amounts. Negative temporary humidity produces an exact zero adjustment because every saturation limit in the admitted thermal domain is positive. These callers can later reach `CALLPAR`'s conditional `QNEGAT`, but this contract does not assume that the separate correction runs or repairs the forecast.

`CLOUD_SATADJ` lines 757–815 chooses mode two, does not use the returned temperature or humidity adjustment, and consumes only the sum of liquid and ice plus the cloud increment. It selects the actual phase using the input temperature, then computes liquid or ice heating in its own numerical body. The native child preserves the complete original diagnostic partition even if its temperature-based threshold differs from the caller's input-temperature threshold. The independent caller relation is $`c_p\Delta T_{\rm caller}=L_{\rm phase}(\Delta q_w+\Delta q_i)`$. The verifier checks this relation, while the original caller still performs every actual simulation stage.

A standalone mixed-temperature mode-two output does not generally conserve the heat of its returned single phase. The retained 260 K example has a 216.871 J/kg residual under that interpretation. It is a diagnostic-output limit and is not erased. Mode two is admitted only for the documented condensate consumer or for a separately qualified caller. No full-forecast scientific acceptance follows from this leaf.

## ABI And Output Bytes

The AArch64 application binary interface, ABI, takes 16 ordinary addresses. `x0..x7` hold `YDECLDP`, `KIDIA`, `KFDIA`, `KLON`, `KLEV`, `KFTLIQICE`, `PT` and `PQ`. Eight caller stack slots hold `PA`, `PP`, `PSURF`, `PT_ADJ`, `PQ_ADJ`, `PA_ADJ`, `PL_ADJ` and `PI_ADJ`. Integer owners contain four bytes, FP64 arrays use eight-byte alignment and unit cell stride, and all output owners are disjoint from inputs and one another. Every selected cell receives all five outputs. Unselected words retain their initial bytes.

The native body preserves `x19..x29`, the low 64 bits of `d8..d15`, the stack pointer and FPCR, using a 512-byte private frame aligned to 16 bytes. It uses no caller-owned scratch. The complete compared output is five `KLON`-word owners in argument order, including untouched words, as little-endian FP64. A mismatch is rejected at the first field, cell and bit pattern, with zero differing bytes required.

## Evidence

The archived review supplies 28 accepted mode-one source calls and one retained mode-two diagnostic record, with 1,160 complete returned bytes. Its 145 reviewed relations and the warm trigger-gap counterexamples remain unchanged. The extended original-first review passes 36 new protected calls, 1,440 bytes and 222 independent relations at 120 digits before direct emission. It covers warm passive and accepted active states, signed temporary humidity, clipped cloud fractions, both modes and phase boundaries. A later independent review of condensed amount and cloud growth adds 195 relations over these 65 saved source cases without calling the source again.

Direct acceptance compares 72 protected placements and 663,680 complete returned bytes with zero differences, including the actual original-only r40 input packet, cropped intervals, empty intervals and 4,096-cell owners. It checks 99,156 physical relations, read-only inputs, untouched cells and saved registers. The new source corpus separately establishes exact fresh numerical floating-point status and errno. The instruction review finds the two accepted EXP calls and no fused or approximate numerical instructions.

The live pair passes six complete calls and 1,120 bytes with zero differences, plus two calls and 40 bytes with the original profiler enabled and initialized. It preserves every inherited status bit and every original diagnostic output. A profiler-only inexact difference is recorded separately from fresh numerical status. Genuine shared-memory checks reject seven direct shape or control-register errors before 280 output bytes change, and reject a warm physical defect or output alias before 80 output bytes change.

Original-only r40 evidence contains both modes and signed cumulative temporary states. It shows no negative condensation or water-balance failure in the observed cloud calls, while isolated mode-two diagnostic heat and passive negative-humidity observations remain recorded. The complete caller still supplies its actual phase and heating stages. Local evidence is under `.runtime/openifs/cloud_supersaturation_7240564/`. Full-forecast scientific acceptance, comparative timing and weather counts remain separate gates.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cloud_supersatcheck | 116,100 | 111,456,000 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
