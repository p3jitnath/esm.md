# Longwave Layer Transport Contract

Revision 3 covers the complete native entry `md2asm_longwave_layer` and the original interface `calc_reflectance_transmittance_lw`, from the frozen OpenIFS two-stream radiation source. The [physical input](../../../../../formulations/openifs/radiation/longwave_layer_energy.md) defines $`\tau,a,b,B_t,B_b,R,T,S_u,S_d`$. The layer calculates all four outputs itself and performs no forecast time update.

## Supported inputs and interface

An application binary interface (ABI) specifies arguments, registers, and stack use. This AArch64 entry receives ten ordinary pointers; each positive-length array contains consecutive FP64 values, which are 64-bit floating-point numbers.

| Position | Address location | Pointee and meaning | Access |
| --- | --- | --- | --- |
| 1 | `x0` | `ng`, one signed 32-bit entry count | Read |
| 2 | `x1` | `od[ng]`, optical depth $`\tau`$ | Read |
| 3 | `x2` | `gamma1[ng]`, coefficient $`a`$ | Read |
| 4 | `x3` | `gamma2[ng]`, coefficient $`b`$ | Read |
| 5 | `x4` | `planck_top[ng]`, source $`B_t`$ | Read |
| 6 | `x5` | `planck_bot[ng]`, source $`B_b`$ | Read |
| 7 | `x6` | `reflectance[ng]`, output $`R`$ | Replace |
| 8 | `x7` | `transmittance[ng]`, output $`T`$ | Replace |
| 9 | Incoming `[sp]` | `source_up[ng]`, output $`S_u`$ | Replace |
| 10 | Incoming `[sp+8]` | `source_dn[ng]`, output $`S_d`$ | Replace |

For $`1\le\mathtt{ng}\le4096`$, each array must have at least $`8\mathtt{ng}`$ accessible bytes and 8-byte alignment. All four output arrays must be disjoint from each other, the input arrays, and `ng`. The count pointer must be readable and 4-byte aligned. A nonpositive count returns without array access or writes; a count above 4096 rejects.

Every active input must be finite and lie from zero through $`10^6`$, with $`a>b\ge0`$ and the rounded product $`(a-b)(a+b)>10^{-12}`$. The assembly checks all entries before its first output write. For $`\tau\le0.001`$, it also requires $`k\tau\le1`$ and $`a-b-b(a-k)\tau\ge0`$, evaluated with the stated FP64 multiplication and subtraction order. For the latter guard, calculate $`w=a-k`$, $`v=bw`$, $`v=v\tau`$, and $`h=(a-b)-v`$, preserving the already rounded difference $`a-b`$. In exact arithmetic, these conditions make thin transmission and absorption nonnegative. The source case $`a=b=0.83,\ \tau=0.001`$ gives negative approximate emission and remains excluded; no model setting is changed to admit it.

The entry retains its 192-byte frame, 16-byte stack alignment, `x18`, `x19` through `x29`, return address and ABI-required low 64 bits of `v8` through `v15`. Scalar work calls the build-selected `EXP_SYMBOL`. Two-cell work calls the qualified private `md2asm_try_exp_pair_counted`, and four-cell work calls `md2asm_try_exp_four_counted`. Both children preserve all 128 bits of `q8` through `q15` and `q24` through `q31`, so each lane, which holds one independent cell, retains its rounded state across the call. Rejected inputs still call `abort` before output writes. The selected parent binds the entry to `md2asm_mcica_lw_layer` and its local count getter to `md2asm_mcica_lw_exp_count_get`.

## Complete ordered calculation

The scalar route processes spectral entries in increasing index order. The grouped routes interleave two or four independent entries as defined below. Each operation below rounds separately to FP64. First calculate $`p=a-b`$, then $`m=a+b`$, then $`q=p\,m`$, then $`k=\sqrt{\max(q,10^{-12})}`$. The retained floor matches the original routine. The branch threshold is the FP64 value with bits `0x3f50624dd2f1a9fc`; equality selects the thin branch.

For a thin layer, calculate $`R=b\tau`$. Calculate $`v=k\tau`$, $`n=1-v`$, $`w=a-k`$, $`z=\tau w`$, $`d=1+z`$, and $`T=n/d`$, in that order. Then calculate $`h=1-R`$, $`A=h-T`$, $`f=A(0.5)`$, $`s=B_t+B_b`$, and $`S_u=f s`$; copy its bits to $`S_d`$. This uses the mean thermal source and does not claim to solve the continuous equations exactly.

For a thick layer, calculate $`v=k\tau`$, negate it, call the qualified exponential helper to obtain $`E=\exp(-v)`$, and calculate $`E_2=E E`$. Calculate $`u=k+a`$, $`w=k-a`$, $`z=w E_2`$, $`d=u+z`$, and $`F=1/d`$. Calculate $`h=1-E_2`$, $`j=b h`$, and $`R=j F`$; then calculate $`j=2k`$, $`j=j E`$, and $`T=j F`$.

For thick-layer emission, calculate $`\Delta=B_b-B_t`$, $`m=a+b`$, $`d=\tau m`$, and $`C=\Delta/d`$. Calculate $`U_t=C+B_t`$, $`U_b=C+B_b`$, $`D_t=(-C)+B_t`$, and $`D_b=(-C)+B_b`$. Calculate $`j=R D_t`$, $`h=U_t-j`$, $`j=T U_b`$, and $`S_u=h-j`$. Then calculate $`j=R U_b`$, $`h=D_b-j`$, $`j=T D_t`$, and $`S_d=h-j`$. Store $`R,T,S_u,S_d`$ into their separate arrays for that entry.

The floating-point control register, FPCR, must equal zero: round to nearest with ties to even, gradual underflow, and no enabled floating-point traps. Multiplication and addition remain separate; fused operations, contraction, reassociation, approximate division or square root, reduced precision, and fast-math are forbidden. Input and output signed zeros are preserved according to the original operations. The prewrite guard restores the incoming floating-point status register, FPSR, before numerical work, so accepted calculations retain the source's sticky flags and the mathematical helper's error indicator, `errno`.

## Grouped Thick Cells

After the unchanged whole-array guard and its restore of incoming FPSR, the numerical loop first checks whether two adjacent cells both select the original thick branch. Integer comparisons of their validated FP64 words select this path. If at least four complete cells remain, the same integer checks examine the next two depths before a four-cell prefix starts. Four thick cells use two independent vector groups and one counted four-value EXP call. Other complete thick pairs use the accepted pair body. Thin, mixed and odd work keeps the accepted scalar point. No thick expression executes for a thin cell.

Each lane calculates the same difference, sum, product, maximum, root and separately rounded root-times-depth value as the scalar method. The helper admits every grouped argument before EXP arithmetic or a counter change. Admission requires exact signed zero or a magnitude from $`2^{-54}`$ inclusive to $`512`$ exclusive. Both helpers require FPCR zero and retain the scalar EXP table words and rounding points. The four-cell path carries its two input-and-root groups in `q8` through `q13` and `q24` through `q29`, within the private preserved registers, without enlarging the frame or adding spills.

A successful group performs the listed thick reflection, transmission and thermal-emission tree separately in each lane and writes its values to each output array. A four-value refusal enters the existing pair body, and a pair refusal enters the existing scalar point. Neither fallback repeats the whole-array guard or restores FPSR again. The already executed prefix contains only accepted scalar operations, so its sticky flags form a subset of the final scalar union. No status logger or flag clear intervenes. The scalar EXP range-error route preserves its incoming FPSR snapshot, including these prefix bits.

The shared counted EXP route adds four or two scalar-equivalent evaluations after grouped admission. The layer's existing local counter adds the same amount atomically after successful grouped EXP and one after each scalar thick EXP. Both use unsigned wrapping arithmetic and retain their original storage owners and getters. Refusal changes neither count before fallback work. Thin cells do not call EXP or change its counts. Final outputs, FPSR, FPCR, `errno` and counts preserve the scalar contract. Displaced intermediate status and count snapshots have no equality claim.

## Focused Evidence And Limits

The retained independent reference uses 120-digit thermal boundary integrals for 36 cases and 396 relations. It covers zero and subnormal depth, both sides and equality at the thin threshold, equal and unequal thermal sources, large depth and supported near-conservative inputs. For thin layers, define $`M=a+b`$ and $`Q=(M\tau)^2\exp(2M\tau)`$. The absolute approximation bounds are $`2Q`$ for reflection, $`3Q`$ for transmission and $`2B_{\max}Q`$ for each emission, with independently propagated rounding bounds added. Thick cases use the integral identity and the same rounding method. Pairing retains this numerical method and its exclusions.

| Requirement | Current check | Result |
| --- | --- | --- |
| Complete outputs, read-only owners, bounds, physical reference bytes, status and ABI | Eight protected calls, 138,432 output bytes, 173,064 read-only bytes | Zero differences |
| Physical and interface rejection before writes | Nine accepted cases, 1,980 complete owner bytes, reused after exact guard-source comparison | No changes before rejection |
| Grouped routes, immediate seeded status, counters and public ABI | 67 cases under eight status seeds, 536 comparisons, 60,160 output bytes | Zero differences |

The focused cases retain the earlier 48 cases and add 19 cases for four through eight cells, four-value refusal in each lane, thin cells in each quartet position, pair and odd remainders, the admitted upper neighbour, actual scalar underflow and signed-zero source values. They reach 128 four-value attempts with 80 admissions and 368 pair attempts with 240 admissions. The public ABI mask is zero, and immediate FPSR, FPCR and `errno` agree. Both counters wrap correctly in 412 comparisons. The private vector ABI reuses the qualified four-value and pair EXP checks. The original physical solutions are reused without another oracle execution. All output bytes remain unmasked, and all read-only bytes retain their original values.

The accepted layer domain and independent energy proof remain unchanged. The conservative thin-layer defect remains excluded. The selected [autonomous forecast](../input/standalone_weather_forecast.md) passes the complete returned-state gate over all 685 numerical owners, 560 descriptor relations and 27,486,113 raw bytes with zero differences. All ten saved files match over 618,140 bytes, and all 59 controlled final views match the accepted R26 run. The solver exits with zero, the native ABI mask is zero, and natural final FPCR, FPSR and `errno` are zero, 25 and zero.

Three matched ordinary forecast pairs retain all ten files and 59 R25 final views exactly, with checks outside timing. The joint private product-sum input handoff and four-cell layer batch has lower median wall and user times. Wall ranges overlap, two of three wall-time pairs favour the batch, and all three user-time pairs favour it. This whole-process result belongs to the combined batch and does not assign its gain to the longwave layer alone. The [README](../../../../../README.md) gives the matched ranges and timing limits.

The known optional-argument and incoming-status differences retain a false aggregate process-boundary identity. Existing child and saved-trajectory physical checks remain in force; global heat and water budgets and whole-process identity remain unproved. Detailed records stay locally under `.runtime/openifs/four_value_longwave_layer_7484780/` and `.runtime/openifs/prepared_longwave_batch_7484780/`.
