# Longwave Transport With Scattering In Cloudy Layers

Revision 1 implements `radiation_adding_ica_lw::fast_adding_ica_lw` from [the thermal layer equations](../../../../../formulations/openifs/physics/longwave_adding.md), revision 1. The source is `ifs-source/radiation/module/radiation_adding_ica_lw.F90`, SHA-256 `3737f5c8d9d2a594b53e45f744c42d7ba174b226c7b9168de6785dbb4119bb5c`. The [direct assembly](../../../../../src/openifs/physics/fast_adding_ica_lw.S) follows the complete ordered calculation below.

Let $`G`$ count wavelength intervals, $`N`$ count layers and $`H`$ denote the first boundary where scattering must be considered. Supported dimensions are $`1\leq G\leq4096`$, $`0\leq N\leq1024`$ and $`1\leq H\leq N+1`$. Fortran stores neighbouring intervals together, giving zero-based FP64 byte offset $`8(g+Gj)`$. FP64 is the 64-bit floating-point format.

| Position | Original argument | Complete storage |
| --- | --- | --- |
| 1–2 | `ncol`, `nlev` | Separate read-only 4-byte integers |
| 3–4 | `reflectance`, `transmittance` | Read-only $`G\times N`$ FP64 dimensionless fractions |
| 5–6 | `source_up`, `source_dn` | Read-only $`G\times N`$ FP64 emitted fluxes each, W m$`^{-2}`$ |
| 7–8 | `emission_surf`, `albedo_surf` | Read-only $`G`$ FP64 values each, W m$`^{-2}`$ and dimensionless |
| 9 | `is_clear_sky_layer` | Read-only $`N`$ 4-byte logical values, zero or one |
| 10 | `i_cloud_top` | Read-only 4-byte integer $`H`$ |
| 11 | `flux_dn_clear` | Read-only $`G\times(N+1)`$ FP64 downward flux, W m$`^{-2}`$ |
| 12–13 | `flux_up`, `flux_dn` | Complete $`G\times(N+1)`$ FP64 outputs each, W m$`^{-2}`$ |

Require nonnegative finite radiation and fractions with $`r_j+t_j\leq1`$ and $`0\leq a_s\leq1`$. Each clear layer has zero reflectance and each layer above $`H`$ is clear. The supplied clear downward prefix is already the accepted no-scattering calculation, starting with positive zero at the top. The routine copies that prefix without recomputing it. Values below the prefix are unused. With $`H=N+1`$, all layers are clear.

All integer and logical addresses need 4-byte alignment and FP64 addresses need 8-byte alignment. Outputs are disjoint from all other owners and are written completely. Read-only owners may share storage. With no layers, layer and logical arrays are empty and are not read. Every multiple-reflection denominator must be positive and every intermediate must remain finite.

## Complete Ordered Calculation

$`A_j`$ is the effective reflectance of everything below boundary $`j`$, and $`S_j`$ is its upward emission. Start with $`A_{N+1}=a_s`$ and $`S_{N+1}=E_s`$. Work upwards from layer $`N`$ through layer $`H`$. For a clear layer use

```math
A_j=(t_jt_j)A_{j+1},\qquad
S_j=e_j^u+t_j\bigl(S_{j+1}+A_{j+1}e_j^d\bigr).
```

For a cloudy layer use

```math
I_j=\frac{1}{1-A_{j+1}r_j},\qquad
A_j=r_j+\bigl((t_jt_j)A_{j+1}\bigr)I_j,
```

```math
S_j=e_j^u+
\bigl(t_j(S_{j+1}+A_{j+1}e_j^d)\bigr)I_j.
```

Copy $`D_1`$ through $`D_H`$ from the clear downward input. At boundary $`H`$ use $`U_H=S_H+(A_HD_H)`$, preserving the source as the left addition operand. Work upwards above it using $`U_j=(t_jU_{j+1})+e_j^u`$.

Work downwards from layer $`H`$. A clear layer uses $`D_{j+1}=(t_jD_j)+e_j^d`$. A cloudy layer uses

```math
D_{j+1}=\bigl((t_jD_j)+(r_jS_{j+1})+e_j^d\bigr)I_j.
```

Both branches use $`U_{j+1}=(A_{j+1}D_{j+1})+S_{j+1}`$. Every product, subtraction, division and addition rounds separately in the stated order. Three-term additions associate from the left. Preserve signed zeros and every output bit.

## ABI And Output Bytes

The application binary interface, or ABI, defines arguments, preserved registers and stack use. The first eight pointers arrive in `x0` through `x7`. Caller-stack offsets 0, 8, 16, 24 and 32 hold the remaining five pointers. The default symbol is `__radiation_adding_ica_lw_MOD_fast_adding_ica_lw`, with no return value. A build can change only the symbol through `ORIGINAL_SYMBOL`.

The leaf routine uses a 96-byte fixed frame and $`48(N+1)`$ bytes of private scratch, aligned to 16 bytes. It preserves `x19` through `x30` and leaves `x18` and the preserved low 64 bits of `v8` through `v15` untouched. Two independent FP64 lanes reuse the same scratch across interval groups, followed by one scalar remainder. Registers carry effective reflectance, source and the current flux. Every access stays within its owner and the routine supplies all declared numerical stages.

Require FPCR zero for round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The assembly leaves it unchanged and uses full division and separate arithmetic instructions, with no fused arithmetic, approximation, reduced precision or external numerical call. A local integration relay keeps original profiling.

Canonical outputs are the unmodified little-endian FP64 bytes of arguments 12 and 13 in Fortran order. Acceptance requires zero differing bytes and unchanged inputs. Do not mask, round or normalise a difference.

## Independent Physics And Acceptance

A strict local original Fortran control passed 19 cases, 196,560 output bytes and 24,570 independent physical relations. Cases cover no layers, no cloud, cloud-top boundaries, both layer branches, scalar and vector widths, odd remainders, black and reflecting ground, transparent layers, signed zeros, subnormal radiation, a positive denominator close to zero and supported dimension limits.

Exact rational arithmetic checks the independent upward and downward layer balances and ground balance from the physical formulation. Each ordered operation contributes its exact rounding error to a carried bound, including division. Whole-column energy also obeys

```math
U_1+(1-a_s)D_{N+1}
+\sum_{j=1}^{N}(1-r_j-t_j)(D_j+U_{j+1})
=E_s+\sum_{j=1}^{N}(e_j^u+e_j^d).
```

This states that escaping and absorbed heat equals emitted heat. The local original report is `.runtime/openifs/longwave_adding_source_7240564/fast-adding-original-physics-review.json`. Native assembly passed 38 protected calls with 393,120 returned output bytes and zero differences, including 234 nonzero subnormal values. These calls check both guarded placements, unchanged inputs, FPCR and preserved registers. The batched forecast passed complete same-input returned bytes.


## Accepted Forecast Calls

The 2026-10-10 combined forecast passed fast_adding_ica_lw 46,550 calls over 2,085,440,000 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
