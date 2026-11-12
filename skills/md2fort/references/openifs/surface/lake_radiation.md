# Lake Radiation Contract

Revision 1 freezes `FLAKERAD_MOD::FLAKERAD` from `surf/module/flakerad_mod.F90` for [Sunlight in a lake](../../../../../formulations/openifs/surface/lake_radiation.md). Its complete direct source is [lake_radiation.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/lake_radiation.S). All numerical stages use ordinary FP64 arithmetic and the already qualified scalar EXP route.

## Physical Inputs and Complete Calculation

Process the inclusive column range only where the lake mask is true. Preserve all six output owners at other columns. Depths are in m, radiation fluxes are in W m$`^{-2}`$ and extinction coefficients are in m$`^{-1}`$. For each material, use 1–6 bands, nonnegative fractions that sum to one within binary-input rounding, and positive extinction coefficients. Accessed inputs, intermediate arithmetic and outputs are finite. The mixed layer does not exceed the clipped water column. Either thickness may be slightly below zero after a rounded update. Admit only h_i,H≥−8ε×max(D,H_min)−8u_min, where ε is the FP64 rounding scale and u_min is its smallest positive value. Preserve this supplied value in the original threshold branches and every calculation.

Let $`D=\min(50,\max(2,D_{\mathrm{input}}))`$, $`H`$ be mixed-layer depth, $`h_i`$ ice thickness and $`I_0`$ incoming radiation. The sign of every flux follows $`I_0`$. Let $`h_{i,\min}>0`$ and $`H_{\min}>0`$ be the configuration thresholds. Define transmission through a material as $`T(z)=\sum_b f_b\exp(-k_bz)`$. The interface outputs are

```math
I_i=I_0,\qquad
I_w=
\begin{cases}
I_0T_i(h_i),&h_i\ge h_{i,\min},\\
I_0,&h_i<h_{i,\min},
\end{cases}
\qquad
I_H=
\begin{cases}
I_wT_w(H),&H\ge H_{\min},\\
I_w,&H<H_{\min},
\end{cases}
\qquad
I_D=I_wT_w(D).
```

The mean mixed-layer output is $`(I_w\sum_b(f_b/k_b)(1-\exp(-k_bH)))/H`$ when $`H\ge H_{\min}`$, otherwise copy $`I_H`$. The mean deeper-layer output is $`(I_w\sum_b(f_b/k_b)(\exp(-k_bH)-\exp(-k_bD)))/(D-H)`$ when $`H\le\operatorname{RN}(D-H_{\min})`$, otherwise copy $`I_H`$. Here RN means one rounding to the nearest FP64 number, with ties to even. This explicit rounded boundary controls the threshold tie.

Initialise each required sum to positive zero and accumulate bands in increasing order. Form each exponential argument by negating the coefficient before multiplying by thickness. Round multiplication by a band fraction before adding it to a transmission sum. For means, divide fraction by coefficient, form the rounded exponential difference, multiply the two rounded values and then add to the ordered sum. Multiply the completed sum by $`I_w`$ before dividing by layer thickness. Preserve signed zeros, gradual underflow and every rounded intermediate. FPCR must be zero. Forbid fused multiply-add, reassociation, approximate operations, reduced precision and fast-math.

The qualified EXP implementation is `.runtime/openifs/strict-math/libpressure-math.so`, loaded before the original and direct routines. Reuse its accepted source, instruction and sampled accuracy evidence. No global external-library accuracy proof is claimed. Its repeated calls with the same rounded argument return the same rounded result, so the direct body shares each water-band exponential between interface and mean calculations while retaining each original ordered sum.

## Interface and Storage

Unique entry `md2asm_lake_radiation` aliases `__flakerad_mod_MOD_flakerad`. The sixteen arguments are addresses in this order. `KIDIA,KFDIA,LDLAKEPOINT,PDEPTH_W,POPTICPAR_WATER,POPTICPAR_ICE,TFLAKE,PI_ATM_FLK,PH_ICE_P_FLK,PH_ML_P_FLK,PI_ICE_FLK,PI_BOT_FLK,PI_W_FLK,PI_H_FLK,PI_INTM_0_H_FLK,PI_INTM_H_D_FLK`. Input and configuration owners remain unchanged, and every accessed owner is disjoint and naturally aligned. The mask owner contains at most 4096 columns. An empty processed range is valid.

Each rank-one GNU descriptor occupies 64 bytes. Its data pointer is at byte 0, element size at 16, rank at 28, span at 32, stride at 40 and bounds at 48 and 56. Data points to the first supplied element. Each descriptor has its own signed stride, with zero stride metadata meaning unit stride. Logical elements occupy 4 bytes and real elements 8 bytes. Every real owner contains the complete mask extent.

The optical configuration occupies 104 bytes, with 32-bit band count at byte 0, six FP64 fractions at byte 8 and six FP64 extinction coefficients at byte 56. `TFLAKE` occupies 856 bytes, with ice threshold at byte 192 and mixed-layer threshold at byte 200. The genuine defaults are $`10^{-9}`$ m and 0.01 m. Optical properties come from the configuration rather than substituted constants. Unused bands and other configuration fields are preserved.

Use a fixed 416-byte frame for saved registers, eleven owner address/stride records and rounded exponential temporaries. Preserve x18, x19–x29, the low 64 bits of v8–v15, aligned stack and FPCR under AAPCS64, the Arm calling convention. The qualified EXP call is the only numerical dependency, and no control or adapter supplies a numerical stage.

## Frozen Verification

Before assembly emission, check the original against the exponential profile and its independently integrated means in extended precision. Use `expm1` for the independent integral, which evaluates $`e^x-1`$ accurately for small $`x`$, while the primary contract retains its original ordered difference. Check total water absorption as $`I_w-I_D`$, complete band fractions, threshold limits and unmodified non-lake outputs.

For each ordinary flux, use residual bound $`8192\epsilon_{\mathrm{FP64}}(|I_0|+|I_{\mathrm{expected}}|)+512u_{\min}`$, where $`u_{\min}`$ is the smallest positive FP64 value. For an active layer mean, add $`8192\epsilon_{\mathrm{FP64}}|I_w|\sum_b f_b/(k_b\Delta z)`$. This term accounts for cancellation when nearby exponentials are subtracted. It is an absolute rounding bound and does not promise a fixed relative error for arbitrarily weak absorption. Freeze these budgets before testing and preserve all returned bits.

The protected corpus includes 1, 2, 3 and 6 bands, the genuine water and ice settings, opaque ice, very weak absorption, subnormal and signed-zero outputs, both depth clipping limits, thin layers, adjacent floating-point values at both threshold boundaries, no-lake columns, empty ranges, independent signed strides, descriptor metadata with zero first stride and owners against guards at both ends. Protect all input data, optical properties, configurations and descriptors against writes.

Compare the six complete returned owners as raw bytes, including unprocessed columns and physical gaps. Require zero differing bytes from the strict original, a preserved ABI and FPCR, and the independent physical relations before composing a paired forecast relay. Retain actual controls, results, source identities and build commands locally under `.runtime/openifs/weather24h-lake-radiation/`. Repeated quiet-node timing is required before a performance claim.

## Checked Results

The original physical check, direct native comparison and paired adapter passed on node nid010555 in exclusive allocation 7240564, with CPU 48 and local memory placement.

| Check | Calls | Returned owner bytes | Independent relations | Different bytes |
| --- | ---: | ---: | ---: | ---: |
| Original profile and layer integrals before generation | 642 | 4,214,016 | 265,606 | — |
| Complete native body | 642 | 4,214,016 | 265,606 | 0 |
| Paired original and native calls | 63 | 27,216 | 1,923 | 0 |

The complete corpus included 1560 subnormal outputs and 11,280 negative-zero outputs. The paired sample included 15 and 151 respectively. Full-owner comparison also established preservation of 2,512,032 inactive or gap bytes in the complete corpus and 14,976 bytes in the paired sample. A captured forecast call had mixed-layer depth −8.8817841970012523×10⁻¹⁶ m. Source, native and paired protected replays each matched all 1,152 returned owner bytes, with zero differences and 522 independent relations in total. Input values were preserved, including the small rounding deficit. A later captured call had ice thickness −1.3552527156068805×10⁻²⁰ m. The same three protected routes each matched 1,152 bytes with zero differences and 87 independent relations in total, preserving the original thin-ice branch. Actual forecast acceptance remains a separate integration gate.

Sharing two rounded water-band exponentials across four independent ordered sums reduces EXP calls from five to two per band when both layer means are active. Each sum retains its own original addition order, and one rounded fraction-to-extinction ratio serves both means. The exact comparisons establish this reuse across the declared cases. A helper-call count does not establish a measured speed gain.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| flakerad_mod::flakerad | 2,150 | 2,476,800 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
