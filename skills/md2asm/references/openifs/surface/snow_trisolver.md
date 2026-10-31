# Snow Temperature Column Solver

Revision 1.0 freezes the complete OpenIFS 48.1.1 `SRFSN_WEBAL_MOD::TRISOLVER` child from `surf/module/srfsn_webal_mod.F90`. The [physical input](../../../../../formulations/openifs/surface/snow_heat_column.md) defines its heat balance. [Direct assembly](../../../../../src/openifs/surface/snow_trisolver.S) supplies every numerical stage.

## Ordered Arithmetic

Use FP64, the 64-bit floating-point format, with separate rounding to nearest and ties to even. FPCR is zero, preserving gradual underflow and signed zeros. Fused operations, reassociation, approximate division and reduced precision are forbidden. Let $`\operatorname{RN}`$ mean one FP64 rounding. Set $`\beta=b_1`$ and $`u_1=\operatorname{RN}(f_1/\beta)`$. For $`j=2,\ldots,n`$, calculate these stages.

```math
\begin{aligned}
\gamma_j&=\operatorname{RN}(c_{j-1}/\beta),\\
q_j&=\operatorname{RN}(a_j\gamma_j),\\
\beta&=\operatorname{RN}(b_j-q_j),\\
r_j&=\operatorname{RN}(a_ju_{j-1}),\\
s_j&=\operatorname{RN}(f_j-r_j),\\
u_j&=\operatorname{RN}(s_j/\beta).
\end{aligned}
```

Visit $`j=n-1,\ldots,1`$, replacing $`u_j`$ with $`\operatorname{RN}(u_j-\operatorname{RN}(\gamma_{j+1}u_{j+1}))`$. These forward elimination and backward substitution stages remove one neighbour at a time, then recover the temperatures. Each pivot and used intermediate must be finite, and each pivot must be nonzero. Used coefficients and heat inputs are finite. The unused $`a_1`$ and $`c_n`$ words are not read and may contain any bit pattern.

## ABI and Bounds

The application binary interface, ABI, defines argument addresses and preserved registers. `md2asm_snow_trisolver` receives six addresses. The first points to a four-byte integer `KSNLAC` with $`1\leq n\leq4096`$. The next five point to GNU rank-one descriptors for `ZA`, `ZB`, `ZC`, `ZF` and `ZTSTAR`. The public interposed name is `__srfsn_webal_mod_MOD_trisolver`.

Each 64-byte descriptor has its base at byte 0, element size at byte 16, span at byte 32, stride at byte 40, lower bound at byte 48 and upper bound at byte 56. The base points to the first logical element. Elements occupy eight bytes. Each array has its own signed element stride. A stored stride of zero selects one, matching the original GNU interface. Negative and non-unit strides are supported. Counts and address offsets fit their integer widths.

The lower, central, heat-input and output arrays provide at least $`n`$ elements. The upper array provides at least $`n-1`$, and is unread for one layer. Descriptor and element addresses are aligned to eight bytes and the count to four bytes. All owners are disjoint. Inputs, count and descriptors remain unchanged. Only the first $`n`$ logical output elements change. Inactive elements and physical gaps retain every bit.

The body preserves `x19` through `x29`, the low 64 bits of `v8` through `v15`, the aligned stack pointer and FPCR, and does not use `x18`. A 112-byte fixed frame and an additional $`16\lceil n/2\rceil`$ bytes hold saved registers and elimination coefficients. No external numerical helper is called.

## Independent Checks and Acceptance

The original must pass independent matrix residual checks before native emission. Each row checks $`a_ju_{j-1}+b_ju_j+c_ju_{j+1}=f_j`$, omitting absent neighbours. The frozen residual bound is $`1024\epsilon`$ times the sum of absolute row contributions and heat input, plus $`1024`$ smallest positive FP64 subnormals, with $`\epsilon=2^{-52}`$. Positive heat matrices must also preserve the temperature bounds implied by row heat inputs.

Manufactured cases include one layer, coupled heat transfer, negative coefficients, signed zeros and subnormal values, with counts up to 4096. Independent signed strides, zero stride metadata, inactive tails and both guard-page placements cover storage boundaries. A register observer checks the native ABI and FPCR. Compare complete output owners with the strict original, including gaps and inactive tails. Canonical bytes are the first $`n`$ returned FP64 temperatures in increasing logical layer order, encoded little-endian. Accept zero differing bytes. A paired actual-call relay must pass before forecast acceptance. No speed gain or whole-forecast completion is claimed.

## Checked Checkpoint

On 2026-10-11, exclusive job 7240564 on nid010555, CPU 48 with local memory binding passed 660 protected native cases over 4,840,800 complete returned owner bytes, with zero differences. The original passed 539,256 independent matrix and temperature-bound relations before native emission. The corpus includes 51,276 subnormal outputs and 29,928 negative-zero outputs. A smaller paired smoke passed 48 intercepted calls over 4,128 bytes and 240 independent relations. The register observer and FPCR checks passed, and the body has no fused or approximate instructions or external numerical calls. Comparative timing remains open.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_webal_mod::trisolver | 6,060 | 52,425,600 | Complete parent owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
