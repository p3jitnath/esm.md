# QSATMIXADJ Contract

Revision 1 covers the complete 70-line contained function in `arpifs/phys_ec/cloud_satadj.F90`. The source body and inherited thermodynamic statement functions are preserved locally. A separate source observer stores intermediate results without changing any numerical expression. It is checked against the unchanged scalar return before direct emission.

## Inputs And Meaning

The inputs are initial temperature $`T`$ in K, trial humidity $`q`$ in kg/kg and pressure $`p`$ in Pa. The initial bounds are $`160\le T\le340`$, $`-0.1\le q\le1`$ and $`1\le p\le2{,}000{,}000`$, with finite values. Every temperature before and after an iteration must stay in $`[140,360]`$ K. This is a conditional diagnostic domain. Signed trial humidity is not a claim that a physical air state has negative vapour.

The function returns final trial humidity after two iterations. It does not provide the actual cloud mass or final forecast temperature. `CLOUD_SATADJ` uses the returned difference, limits evaporation by available liquid and ice, chooses their actual phase, and computes its own heating. The complete parent must contain those stages.

## Complete Ordered Calculation

FP64 means 64-bit floating point. Let $`R(x)`$ mean one FP64 rounding to nearest with ties to even. Every product, sum, subtraction and division below has its shown rounding. Underflow remains gradual, signed zeros remain visible, and the floating-point control register, FPCR, is zero. No fused arithmetic, reassociation or approximate operation is permitted. The unchanged accepted scalar EXP route supplies both exponentials.

Freeze the 25 thermodynamic words from the accepted saturation source record. Let $`v=\mathrm{RETV}`$, $`E_0=\mathrm{R2ES}`$, $`T_0=\mathrm{RTT}`$, $`b_w=\mathrm{R3LES}`$, $`b_i=\mathrm{R3IES}`$, $`d_w=\mathrm{R4LES}`$ and $`d_i=\mathrm{R4IES}`$. Let $`T_i=\mathrm{RTICE}`$, $`T_w=\mathrm{RTWAT}`$ and $`r_T=\mathrm{RTWAT\_RTICE\_R}`$. The feedback coefficients $`D_w=\mathrm{R5ALVCP}`$ and $`D_i=\mathrm{R5ALSCP}`$ have units K$`^2`$. The heating coefficients $`H_w=\mathrm{RALVDCP}`$ and $`H_i=\mathrm{RALSDCP}`$ have units K.

Set $`t=T`$, $`u=q`$ and $`r_p=R(1/p)`$. Repeat the following complete update exactly twice.

```math
a_0=R\left(R(\max(T_i,\min(T_w,t))-T_i)r_T\right),\qquad \alpha=\min(1,R(a_0^2)),
e_w=\operatorname{EXP}\left(R\left(\frac{R(b_wR(t-T_0))}{R(t-d_w)}\right)\right),\qquad e_i=\operatorname{EXP}\left(R\left(\frac{R(b_iR(t-T_0))}{R(t-d_i)}\right)\right).
```

```math
f=\min\left(R\left(R\left(E_0R\left(R(\alpha e_w)+R(R(1-\alpha)e_i)\right)\right)r_p\right),0.5\right),
g=R\left(\frac{1}{R(1-R(vf))}\right),\qquad q_s=R(fg).
```

```math
D=R\left(R\left(R(\alpha D_w)R\left(\frac{1}{R(R(t-d_w)^2)}\right)\right)+R\left(R(R(1-\alpha)D_i)R\left(\frac{1}{R(R(t-d_i)^2)}\right)\right)\right),
h=R(1+R(R(q_sg)D)),\qquad c=R\left(\frac{R(u-q_s)}{h}\right),\qquad H=R\left(R(\alpha H_w)+R(R(1-\alpha)H_i)\right).
```

```math
t'=R(t+R(Hc)),\qquad u'=R(u-c).
```

Replace $`t,u`$ by $`t',u'`$ before the second iteration. Return the final $`u`$. The positive denominator accounts for the saturation change caused by latent heating. Two iterations give the source's prescribed approximation, and the remaining saturation residual is recorded separately. No exact nonlinear root or complete forecast accuracy is claimed.

## ABI And Output Bytes

The unique private entry is `md2asm_qsatmixadj`. Its application binary interface, ABI, uses `x0`, `x1` and `x2` for read-only eight-byte scalar owners $`T,q,p`$. `x3` is either zero or an eight-byte aligned 80-byte verification trace owner, disjoint from the inputs. The FP64 return is in `d0`. The optional trace stores $`t',u',c,q_s,h`$ for each iteration in that order and performs no extra numerical operation. The real parent passes a zero trace pointer.

The 320-byte stack frame is aligned to 16 bytes. It preserves `x19..x29`, the low 64 bits of `d8..d15`, the stack pointer and FPCR. Unsupported FPCR rejects before any trace write. The caller proves the physical and intermediate domain before execution. The compared observation is the eight-byte return followed by both 40-byte trace records, in little-endian FP64. Every declared bit is retained and zero differing bytes are required.

## Evidence

The original-first gate passes 104 scalar returns and 104 store-only trace calls, with 9,152 observed bytes and 1,040 independent relations at 120 digits. It checks water transfer, actual per-iteration latent heating, mixed saturation, heat feedback and transferred amount, including phase edges, signed diagnostic trials and the pressure cap. Plain and observed source returns, fresh floating-point status and errno agree. Local records are in `.runtime/openifs/qsatmixadj_7240564/`. No full forecast or timing is accepted here.

The complete direct body passes 208 protected placements and 18,304 observed bytes with zero differences, reusing the saved source corpus. Fresh status and errno match. Four immediate saved-register checks, four null-trace returns, inherited status and errno, one call from /tmp and two genuine shared-memory control-register rejections pass. The two rejected calls leave all 160 trace bytes unchanged. Instruction review confirms four dynamic EXP calls over the two iterations and no fused or approximate operation. Parent integration must record actual private child calls separately from original-shadow work.

## Actual Forecast Acceptance

The combined coarse forecast uses exclusive allocation 7259755 on nid010824. These actual assembly calls have zero differing bytes. A compared array contains the complete storage supplied by its caller. Private child counts exclude original comparison calls.

| Original routine | Actual calls | Compared bytes | Scope |
| --- | ---: | ---: | --- |
| cloud_satadj::qsatmixadj | 921,600 | 73,728,000 | Complete private iteration records and parent arrays |

All ten saved files match across 618,140 bytes. Accepted critical physics and interface checks are reused. Independent physics for the whole forecast, whole-process byte agreement, autonomous execution and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
