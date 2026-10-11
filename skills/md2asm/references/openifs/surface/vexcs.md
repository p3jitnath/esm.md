# Surface exchange coefficients

Revision 1. The [physical input](../../../../../formulations/openifs/surface/surface_exchange.md) describes transfer between the surface and the lowest atmosphere layer. The [direct AArch64 source](../../../../../src/openifs/surface/surface_exchange.S) implements every calculation in the scalar standard-math branch of `VEXCS_MOD::VEXCS`.

## Physical inputs and profiles

Let $`\Phi`$ be geopotential in square metres per square second, $`g`$ gravity in metres per square second and $`z=\Phi/g+z_{0m}`$ the reference height in metres. The three positive roughness lengths $`z_{0m}`$, $`z_{0h}`$ and $`z_{0q}`$ describe momentum, temperature and moisture. The dimensionless stability parameter is $`\eta=z/L`$, where $`L`$ is the Obukhov length.

The speed squared combines the two wind components relative to the surface and the convective contribution $`(Bh_{\mathrm{PBL}})^{2/3}`$ when buoyancy flux $`B`$ is positive. Buoyancy flux has units of square metres per cubic second. The height $`h_{\mathrm{PBL}}`$ is in metres. A positive squared-speed floor prevents a zero denominator.

Dry static energy $`s_a`$ in the air and $`s_s`$ at the surface has units of joules per kilogram. The bulk Richardson number compares their density contrast with the wind mixing. Humidities $`q`$ and $`q_s`$ have units of kilograms per kilogram. The source constants $`r_v`$ and $`r_t`$ define its moisture correction.

```math
\delta=\frac{2(s_a-s_s)}{s_a+s_s-\Phi}-(r_v-r_t)\left[q-\min(q_s,0.1)\right],\qquad
\mathrm{Ri}=\frac{\Phi\delta}{U^2}.
```

The profile functions are empirical expressions from the retained OpenIFS model. For unstable air, set $`t=\sqrt{\sqrt{1-16\eta}}`$.

```math
\psi_{hu}=2\ln\!\left(\frac{1+t^2}{2}\right),\qquad
\psi_{mu}=\ln\!\left(\frac{(1+t)^2(1+t^2)}8\right)-2\operatorname{atan}(t)+\frac\pi2.
```

For stable air, define $`A=-b(\eta-c/d)e^{-d\eta}`$. The constants are $`a=1`$, $`b=2/3`$, $`c=5`$ and $`d=0.35`$, with their original FP64 values.

```math
\psi_{hs}=A-\left(1+\frac{2a\eta}{3}\right)\sqrt{1+\frac{2a\eta}{3}}-\frac{bc}{d}+1,\qquad
\psi_{ms}=A-a\eta-\frac{bc}{d}.
```

Use the stable family only when the current main stability parameter is positive. Each near-surface argument multiplies that parameter by an already rounded reciprocal height ratio. Retain the original sequence of standalone products, additions, square roots and function calls.

## Complete numerical method

For each column, first prepare the wind square, Richardson number, three height ratios, logarithms and reciprocal ratios. Set $`D=(z/z_{0m})/(z/z_{0m}-1)`$.

When `LDINIT` is true, obtain the first stable guess from the original 101-cell Richardson table, using linear interpolation and its last entry above the table range. For nonpositive Richardson number, use the source's direct logarithmic guess. Multiply that guess by the momentum logarithm and $`D`$. Otherwise, use the supplied `PZDL` value.

Always perform the first substitution. With momentum and heat profiles $`M`$ and $`H`$, compute $`V=M^2D/H`$, $`\eta_3=\mathrm{Ri}V`$ and $`F_2=\mathrm{Ri}-\eta_2/V`$. Then perform every requested secant iteration. A secant uses the last two values to estimate the next root.

```math
F_3=\mathrm{Ri}-\frac{\eta_3H}{DM^2},\qquad
\eta_{\mathrm{new}}=\eta_2-\frac{F_2(\eta_3-\eta_2)}{F_3-F_2}.
```

Use the secant update only when $`\lvert F_3-F_2\rvert>10^{-25}`$. Otherwise, retain $`\eta_3`$. If the proposed value changes sign relative to $`\eta_3`$, use half of $`\eta_3`$. Move the two iterate states forward in the original order.

Copy the resulting parameter to `PZDL` before the final height adjustment. When it exceeds the source's stable-height constant 5, retain $`L=z/\eta`$, replace $`z`$ with $`5L+\max(z_{0m},z_{0q})`$ and recompute the ratios and logarithms. This adjustment affects the final transfer calculation while preserving the already returned `PZDL` value.

Evaluate all momentum, heat, moisture and tracer profiles, including the separate moisture and tracer near-surface terms. Compute density from pressure, temperature and the source humidity correction, then calculate all five transfer outputs in the physical input. `PI10FGCV` is unused in this source branch, so its payload supplies no term.

The initial stable table uses the separate gradient relation $`\mathrm{Ri}=\eta(1+4\eta)^2/(1+5\eta)^2`$. As the original source states, these stable gradient functions differ from the stable profile functions used for the final flux. Keep those two empirical roles distinct.

## Arithmetic and interface

Each ordinary FP64 operation has its original rounding point. Use nearest rounding, even ties, gradual underflow and exact signed zeros, with FPCR equal to zero. The function uses hardware division and square root, the accepted scalar EXP and LOG routes, unique `md2asm_pow_original_rounding_candidate` and unique `md2asm_atan_original_rounding`. The two unique math primitives retain their own accepted internal rounding contracts. No fused instruction, approximate reciprocal, reduced precision or reassociation supplies a weather calculation.

`md2asm_surface_exchange` has the original 30-address GNU Fortran interface. Arguments 1–6 are four-byte first column, last column, column count, iteration count, standard/vector-math choice and initial-guess flag. Arguments 7–23 are rank-one GNU FP64 descriptors, ordered as `PUMLEV, PVMLEV, PTMLEV, PQMLEV, PAPHMS, PGEOMLEV, PCPTGZLEV, PCPTS, PQSAM, PZ0MM, PZ0HM, PZ0QM, PZDL, PBUOM, PUCURR, PVCURR, PI10FGCV`. Arguments 24–25 are the 128-byte `TCST` and 144-byte `TEXC` objects. Arguments 26–30 are the five output descriptors. `PZDL` is argument 19 and is also an output.

The supported domain has `K_VMASS≤0`, `KITT` from 0 through 32 and a logical flag of zero or one. Positive `K_VMASS` selects the excluded IBM vector-math branch and rejects before writes. Initialized original stability constants and all 101 table words must match the independently checked setup. The caller keeps these globals immutable. The paired route checks that setup before its first write and records the actual scalar branch.

The active columns form an inclusive interval within the declared positive column count. An empty interval returns without array mutation. Every consumed descriptor has eight-byte elements, rank one, a nonzero signed stride and enough cells. Negative and gapped strides are supported, and dummy-array indexing begins at one regardless of the actual lower bound. Inputs, object bytes and descriptors remain unchanged. Output element addresses are distinct from other outputs and read-only inputs. The paired adapter admits shared read-only input storage and checks actual element addresses when bounding ranges overlap.

Pressure, temperature, geopotential and roughness lengths are positive. The dry-energy and virtual-temperature denominators are positive, and every consumed value is finite. An initial-guess call does not consume the entering `PZDL` payload. The unused gust payload is also excluded from the value checks.

The Arm application binary interface specifies which registers a function must preserve. This body preserves `x19` through `x29`, the low 64 bits of `d8` through `d15`, the stack pointer and FPCR. Its private cell frame is 960 bytes, and each private profile frame is 64 bytes. Stack alignment is 16 bytes. No caller-owned scratch is needed. The unique math helpers retain their already qualified stack and register obligations.

Canonical output consists of the complete `PZDL`, `PCFM`, `PCFH`, `PCFQ`, `PKH` and `PKC` owner bytes, including inactive cells and signed-stride gaps. Values remain raw little-endian FP64 words. Acceptance requires zero differing bytes.

## Executed checks and remaining gate

The independent original gate passed before emission. Forty-eight protected source and native placements each cover 25,344 complete output-owner bytes, with zero differences. The two routes pass 4,116 independent 110-digit profile and trajectory relations. They cover initial and continued guesses, 0, 1, 3 and 6 iterations, neutral, stable and unstable air, wind-floor and convection branches, full, partial and empty intervals, and strides 1, 2 and −2. All 11,232 inactive and gap bytes remain unchanged.

The 101 initial-guess cells satisfy their separate physical relation within the frozen absolute Richardson limit $`10^{-6}`$, with maximum residual $`5.595004\times10^{-7}`$. Four new convective POWER operands match the original bits and an independent 110-digit calculation, with maximum observed error 0.455470 units in the last place. The accepted full ATAN, EXP, LOG, POWER and metadata proofs are reused.

The independent trajectory limit is $`10^{-8}\max(1,\lvert\eta\rvert)`$. Each final transfer uses its frozen $`4096\epsilon`$ relative budget multiplied by the measured profile condition, where $`\epsilon=2^{-52}`$ and that condition accounts for cancellation in the profile differences. Heat transfer also passes the independent density-removal identity.

Two focused immediate ABI and paired placements each pass 960 bytes with zero differences. Two additional source-first, native and paired cases pass 96 bytes and 42 relations, covering the upper table entry with final height adjustment and an opposite-sign continuing guess. Four native or paired preflight cases reject the vector-math branch or a short descriptor before any of 240 shared output bytes change. Instruction inspection finds no fused or approximate operation. The complete numerical gate is reused after adapter-only changes.

The actual combined forecast still needs to confirm genuine calls, the supported configuration, complete compared owners and unchanged saved files. No comparative speed claim is made here. The direct emitter, original source, setup, protected verifier, build identities and immutable ready route are retained under `.runtime/openifs/surface_exchange_7240564/`.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vexcs_mod::vexcs | 19,350 | 22,291,200 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
