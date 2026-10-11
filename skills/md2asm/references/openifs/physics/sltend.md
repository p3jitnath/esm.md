# Slow-Physics Averaging

Revision 1 freezes the complete SLTEND calculation. A tendency is a change per second. Wind tendencies have units m/s², temperature tendencies have units K/s, and water or cloud-fraction tendencies have units s⁻¹. The physical inputs are [state increments](../../../../../formulations/openifs/physics/physics_increment.md) and [cloud supersaturation](../../../../../formulations/openifs/physics/cloud_supersaturation.md). The [direct assembly](../../../../../src/openifs/physics/sltend.S) calculates every stage and uses the complete accepted [supersaturation child](cloud_supersatcheck.md).

## Save And Average Rates

Let $`C`$ be the cumulative rate, $`D`$ the dynamics rate, $`F`$ the fast diffusion rate, $`A`$ the saturation rate already applied, and $`S`$ the rate saved for the next step. Each operation rounds separately in FP64.

| Field | Saved rate |
| --- | --- |
| Wind | $`S=(C-F)-D`$ |
| Temperature, humidity and cloud fraction | $`S=((C-F)-D)-A`$ |
| Liquid water and ice | $`S=(C-D)-A`$ |
| Rain, snow and ozone | $`S=C-D`$ |

The time interval $`\Delta t`$ is TSPHY in seconds, and the reciprocal $`r=1/\Delta t`$ rounds once. Each level has a weight $`w`$ between zero and one. The flag $`a`$ is zero on the starting step and one on later steps. If $`H`$ is the supplied previous-step change, the returned extra rate is

```math
E=(1-w)\bigl((-a)S+rH\bigr).
```

Compute the multiplication by negative $`a`$, the multiplication by $`r`$, the addition, and the final multiplication in that order, with separate rounding. Preserve negative zero on the starting step. A constituent whose LPHY flag is false receives positive zero. Store active constituent slots in the original field order before any returned rate reads them. This preserves the result when two constituents share a slot.

## Remove Supersaturation And Record Budgets

Starting at NCLDTOP, form the trial temperature, humidity and cloud fraction. For any one of these fields, let $`X`$ be its supplied state and $`C_X`$ its cumulative rate. Form

```math
X'=X+\Delta t(C_X+E_X).
```

Round the inner addition, multiplication and final addition separately. The complete private CLOUD_SUPERSATCHECK executes mode one on the trial states and the supplied full-level and surface pressures. Each returned extra rate then adds its adjustment multiplied by $`r`$. The multiplication and addition remain separate.

The rounded cloud-fraction, liquid and ice adjustments multiplied by $`r`$ also form diagnostic rates. A diagnostic records part of the calculation without changing the forecast state. For the vertical budgets, let $`p_h`$ and $`p_{h+1}`$ be successive interface pressures in Pa, $`p_f`$ the full-level pressure in Pa, $`R_d`$ the gas constant in J/(kg K), $`T`$ temperature in K, and $`g`$ gravity in m/s². Calculate

```math
\Delta p=p_{h+1}-p_h,\qquad
\rho=\frac{p_f}{R_dT},\qquad
\Delta z=\frac{\Delta p}{\rho g}.
```

The layer depth $`\Delta z`$ has units m. Form each multiplication, division and subtraction in the displayed order. Add each diagnostic rate multiplied by this depth into rows 5, 20 and 45 of the first extra-field plane. Preserve the original level order for each sum. Ordinary budgets use the original cloud-fraction, liquid and ice offsets, including the 26-field LBUD23 shift and the one-field vertical-budget shift.

Only the vertical sums depend on an earlier level. The direct parent consumes one level's rounded diagnostics before advancing and uses eight rows of temporary storage. This storage schedule passes the exact local checks. Its speed has not been measured.

## Interface And Storage

The original entry has 50 address arguments in its original declaration order. The direct entry md2asm_sltend adds one read-only context address. This context contains six little-endian 32-bit integers followed by two FP64 values. The integers are the current step, 5, 1, 2, 3 and 4. They identify the five cloud planes and the liquid, ice, rain and snow planes. The two values are $`R_d`$ and $`g`$. The context supplies inputs and performs no numerical stage.

The Arm application binary interface, or ABI, defines arguments and saved registers. The first eight addresses enter through x0 to x7, and the remaining 43 occupy eight-byte caller stack slots. Preserve x19 to x29, x18, the low 64 bits of d8 to d15, SP and FPCR. Keep the stack aligned to 16 bytes. FPCR must be zero, which selects the frozen rounding and gradual-underflow rules. Preserve incoming status flags and compare the fresh numerical flags and errno, the library error indicator.

| Storage | Complete declared extent |
| --- | --- |
| Ordinary fields | $`N L`$ FP64 words |
| Interface pressure | $`N(L+1)`$ FP64 words |
| Cloud fields | Five planes of $`N L`$ words |
| Previous and saved constituent rates | NDIMSLP planes |
| Saved wind and temperature rates | KTEND planes |
| Extra diagnostic fields | KFLDX planes |

Here $`N`$ is the column count and $`L`$ is the level count. Columns vary fastest. Every complete buffer starts at an eight-byte aligned address. Mutable owners are disjoint from each other and from immutable inputs. Preserve every unselected cell, unused plane, model byte and immutable input.

The selected interval starts at column one and ends between zero and $`N`$. Support zero to 4096 columns and zero to 512 levels, 3 to 64 saved-rate planes, zero to 64 slow-constituent planes and zero to 128 extra-field planes. Active constituent slots must fit their declared planes. Vertical cloud diagnostics need at least 45 levels, and every enabled budget must fit its extra-field extent. The time interval, gas constant and gravity must be finite and positive.

The measured model occupies 4,275,088 bytes. Its constituent records store LPHY at byte 100 and the one-based MPSLP slot at byte 204. The RSLWX weights use the measured GNU Fortran FP64 descriptor with contiguous stride one, lower bound one and enough levels. Read only active constituent slots. The caller supplies valid nested metadata and weights. The paired verifier checks consumed physical inputs and disjoint complete owners before either calculation. Unsupported controls reject before output writes.

The numerical parent links only its unchanged complete private supersaturation assembly and qualified exact exponential helper. Its cloud constants have the frozen accepted bits. It imports no OpenIFS Fortran symbol, makes no OpenIFS Fortran numerical call and uses no compiler-generated assembly or compiler intermediate representation.

## Evidence And Limits

The original scientific check passed before direct emission. Twenty-two protected original placements and twenty-two native placements each cover 13,023,024 complete mutable-owner bytes and 271,164 independent 100-digit relations. All native bytes and fresh numerical flags agree with the archived original outputs. The checks cover rate weighting, phase-water balance, phase-change heat, available vapour, all diagnostic sums, read-only inputs and both buffer edges.

The corpus includes first and later steps, all and mixed constituent flags, repeated slots, partial final columns, empty intervals, zero levels, active and passive saturation, all cloud budgets, 4096 columns and 512 levels. Seven paired calls also preserve 241,536 complete bytes with zero differences and 4,971 independent relations. Eleven required prewrite cases preserve 251,328 shared output bytes.

Two additional starting-step cases check signed-zero rates and subnormal previous changes. Their original, native and paired outputs agree, and the profiling-enabled caller also passes. These seven comparisons cover 57,120 bytes with zero differences and 1,007 independent relations. Performance measurements remain pending. Whole-forecast autonomy remains a separate requirement because the current forecast gate uses an original Fortran driver.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete arrays and records compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| sltend | 2,150 | 125,491,200 | Native private slow-physics child, complete record-layer owners and unchanged child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
