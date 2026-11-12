# Longwave Transport Without Scattering

Revision 1 implements `radiation_adding_ica_lw::calc_fluxes_no_scattering_lw` from [the thermal layer equations](../../../../../formulations/openifs/physics/longwave_adding.md), revision 1, with zero layer reflectance. The original source is `ifs-source/radiation/module/radiation_adding_ica_lw.F90`, SHA-256 `3737f5c8d9d2a594b53e45f744c42d7ba174b226c7b9168de6785dbb4119bb5c`. The [direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/calc_fluxes_no_scattering_lw.S) follows these equations and the ordered update below.

Let $`G`$ count wavelength intervals and $`N`$ count layers. Supported dimensions are $`1\leq G\leq4096`$ and $`0\leq N\leq1024`$. FP64 is the 64-bit floating-point format. Fortran stores neighbouring intervals together, with zero-based byte offset $`8(g+Gj)`$.

| Position | Original argument | Complete storage |
| --- | --- | --- |
| 1–2 | `ncol`, `nlev` | Separate read-only 4-byte integers |
| 3 | `transmittance` | Read-only $`G\times N`$ FP64 fractions, dimensionless |
| 4–5 | `source_up`, `source_dn` | Read-only $`G\times N`$ FP64 fluxes each, W m$`^{-2}`$ |
| 6–7 | `emission_surf`, `albedo_surf` | Read-only $`G`$ FP64 values each, emitted W m$`^{-2}`$ and dimensionless albedo |
| 8–9 | `flux_up`, `flux_dn` | $`G\times(N+1)`$ FP64 outputs each, W m$`^{-2}`$ |

Every fraction lies between zero and one and each emitted flux is nonnegative. Outputs are written completely and are disjoint from every other argument. Read-only inputs can share storage. Integer addresses require 4-byte alignment and FP64 addresses require 8-byte alignment. With no layers, the three layer arrays are empty and are never read.

## Complete Ordered Update

Start at the top with positive zero downward radiation. Work downwards through all layers, reflect and emit at the ground, then work upwards through all layers.

```math
D_1=+0,\qquad D_{j+1}=(t_jD_j)+e_j^d
```

```math
U_{N+1}=E_s+(a_sD_{N+1})
```

```math
U_j=(t_jU_{j+1})+e_j^u
```

Each multiplication rounds before its addition. Preserve the stated operand order and every FP64 rounding point. With $`N=0`$, only the top and ground boundary calculation remains.

## ABI And Output Bytes

The application binary interface, or ABI, defines arguments, registers and stack use. The first eight pointers arrive in `x0` through `x7` and the ninth arrives at caller-stack byte offset zero. The default symbol is `__radiation_adding_ica_lw_MOD_calc_fluxes_no_scattering_lw`, with no return value. A build can change only its symbol through `ORIGINAL_SYMBOL`.

The leaf routine uses a 96-byte stack frame, preserves `x19` through `x30`, and leaves `x18` and the preserved low 64 bits of `v8` through `v15` untouched. Two independent FP64 lanes follow complete column updates, with one scalar remainder. Registers carry the current downward and upward fluxes, so no numerical scratch or allocation is needed. Every vector access remains within its declared owner.

Require FPCR zero, giving round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The routine leaves FPCR unchanged and uses separate multiplication and addition instructions, with no fused arithmetic, reduced precision or reassociation. It contains no external numerical call. The local integration relay retains original profiling.

Outputs are the unmodified little-endian FP64 bytes of arguments 8 and 9 in Fortran storage order. Incoming output bytes are irrelevant because every output is written completely. Acceptance requires zero differing bytes and unchanged inputs, without rounding or masking a mismatch.

## Independent Physics And Critical Cases

A strict local control uses the original Fortran source with profiling disabled, FP64 kinds and CPU-aware compilation. Sixteen critical input cases passed 196,080 output bytes and 24,510 independent physical relations. They cover no layers, scalar and vector widths, odd remainders, varying transmission, transparent and opaque layers, black and reflecting ground, signed zero, small radiation values and the supported dimension limits.

The verifier uses exact rational numbers for each layer's upward and downward energy equations, ground reflection, and whole-column energy. It carries each ordered operation's exact rounding error into the allowed bound. The independent whole-column identity is

```math
U_1+(1-a_s)D_{N+1}
+\sum_{j=1}^{N}(1-t_j)(D_j+U_{j+1})
=E_s+\sum_{j=1}^{N}(e_j^u+e_j^d).
```

The left side adds heat escaping upwards, heat absorbed by the ground, and heat absorbed by the air. The right side adds heat emitted by the ground and air. This energy equation is independent of the downward and upward calculation order. The local original-physics report is `.runtime/openifs/longwave_adding_source_7240564/no-scattering-original-physics-review.json`. Native assembly passed 34 protected calls with 394,080 returned output bytes and zero differences. These calls check read-only inputs, both guarded buffer placements, preserved registers and FPCR, including 234 nonzero subnormal values. An additional subnormal case passed 120 independent physical relations. The batched forecast passed complete same-input returned bytes.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed calc_fluxes_no_scattering_lw 51,200 calls over 2,293,760,000 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
