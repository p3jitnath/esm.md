# Shortwave Adding Solver Contract

Revision 1 implements `radiation_adding_ica_sw::adding_ica_sw` from [the layer equations](../../../../../formulations/openifs/physics/shortwave_adding.md), revision 1. The original source is `ifs-source/radiation/module/radiation_adding_ica_sw.F90`, SHA-256 `80b74f71594c42bd41cfe15505e2bc732bb46a3e9fa984c52130e90d3e88559a`. The direct source is [adding_ica_sw.S](../../../../../src/openifs/physics/adding_ica_sw.S). Its arithmetic is written directly in AArch64 assembly, without compiler-generated numerical assembly or intermediate code.

## Inputs And Storage

Let $`G`$ be the number of wavelength intervals and $`N`$ the number of layers. Supported dimensions are $`1\leq G\leq4096`$ and $`0\leq N\leq1024`$. A boundary is the surface between two layers. There are $`N+1`$ boundaries, including the top and ground. FP64 means the 64-bit floating-point format.

| Position | Original argument | Storage and units |
| --- | --- | --- |
| 1–2 | `ncol`, `nlev` | Separate read-only 4-byte integers |
| 3 | `incoming_toa` | $`G`$ read-only FP64 beam values, W m$`^{-2}`$ perpendicular to the beam |
| 4–6 | `albedo_surf_diffuse`, `albedo_surf_direct`, `cos_sza` | $`G`$ read-only FP64 values each, dimensionless |
| 7–11 | `reflectance`, `transmittance`, `ref_dir`, `trans_dir_diff`, `trans_dir_dir` | $`G\times N`$ read-only FP64 values each, dimensionless |
| 12–14 | `flux_up`, `flux_dn_diffuse`, `flux_dn_direct` | $`G\times(N+1)`$ FP64 outputs each, W m$`^{-2}`$ through a horizontal surface |

Fortran stores neighbouring wavelength intervals together. With zero-based indices $`g,j`$, the byte offset is $`8(g+Gj)`$. Each output is written completely and is disjoint from all other arguments. Read-only inputs can share storage. Integer addresses require 4-byte alignment and FP64 addresses require 8-byte alignment. Empty layer arrays have zero capacity when $`N=0`$ and are never read.

## Ordered Update

The numerical method adds multiple reflections between layers. It first passes the direct beam downwards, then combines reflected radiation from the ground upwards, and finally obtains all fluxes downwards. A calculation in parentheses is rounded before its consumer. Every multiplication, addition, subtraction and division has a separate FP64 rounding point.

Use $`A_j`$ for the effective albedo below boundary $`j`$, $`S_j`$ for its reflected-beam source, and $`I_j`$ for the reciprocal reflection denominator. These three temporary arrays belong to the call and are not public outputs.

```math
Q_1=Q_{\mathrm{in}},\qquad Q_{j+1}=Q_jd_j
```

```math
A_{N+1}=a_d,\qquad S_{N+1}=(a_bQ_{N+1})\mu
```

For $`j=N,\ldots,1`$, use the following ordered expressions. All reflection denominators must be positive.

```math
I_j=1/(1-A_{j+1}r_j)
```

```math
A_j=r_j+(((t_jt_j)A_{j+1})I_j)
```

```math
S_j=(b_jQ_j)+\left(t_j\left(S_{j+1}+((A_{j+1}c_j)Q_j)\right)\right)I_j
```

Set $`D_1=+0`$ and $`U_1=S_1`$. For $`j=1,\ldots,N`$, calculate the next diffuse and upward values before converting the current direct beam to a horizontal flux.

```math
D_{j+1}=(((t_jD_j)+(r_jS_{j+1}))+(c_jQ_j))I_j
```

```math
U_{j+1}=(A_{j+1}D_{j+1})+S_{j+1}
```

The complete direct output is $`B_j=Q_j\mu`$. The coefficients $`b_j,c_j`$ already include the conversion to a horizontal diffuse flux and receive no extra cosine factor. With no layers, only the boundary calculations remain.

## Assembly Interface And Arithmetic

The application binary interface, or ABI, defines arguments, registers and stack use. The first eight pointers arrive in `x0` through `x7`. The last six arrive at caller-stack byte offsets 0, 8, 16, 24, 32 and 40. The default exported symbol is `__radiation_adding_ica_sw_MOD_adding_ica_sw`, with no return value. A build can change only its symbol through `ORIGINAL_SYMBOL`.

The source preserves `x19` through `x30`, leaves `x18` and the preserved low 64 bits of `v8` through `v15` untouched, and restores the original 16-byte-aligned stack. A 96-byte fixed frame and $`48(N+1)`$ bytes of private scratch support two independent intervals at once, with one scalar remainder. Each lane follows the same ordered expressions. Registers carry the next albedo and source in the upward pass and the current diffuse flux in the downward pass, while scratch retains values needed later. No vector load extends beyond a declared owner.

Require FPCR zero, giving round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The routine leaves FPCR unchanged. It uses ordinary FP64 division and no fused multiply-add, approximate arithmetic, reduced precision or reassociation. Profiling is outside the numerical core and must be retained by the local integration relay. No external routine supplies a numerical stage.

Outputs are the unmodified little-endian FP64 bytes of arguments 12, 13 and 14 in their declared Fortran order. Incoming output bytes are irrelevant because each output is written completely. Acceptance requires zero differing output bytes and unchanged input bytes, without masking, rounding or normalising a mismatch.

## Independent Checks And Evidence

The complete original capture contains 97,750 calls at $`G=112,N=19`$. Its independent check passed 5,255,040,000 returned output bytes and 645,932,000 physical relations, with zero differing bytes. It checks each layer's upward, downward and direct balance, the ground reflection, and whole-column energy against error bounds derived from the ordered rounding points. Coefficient budgets are exact, so rounding cannot conceal energy creation.

An ambiguous floating-point interval is resolved by an exact integer sum of the same physical residual. Each term has at most three FP64 operands, so a common scale $`2^{-3222}`$ and 100 64-bit words represent its bits and carries without loss. Comparing its magnitude with the unchanged outward error bound preserves equality and rejects any excess. Thirty-four rational-number checks cover subnormal products, large cancellation, carries, and equality or adjacent failure at a bound. This removes costly Decimal reconstruction while preserving the physical equations and limits.

The actual complete-stream report is retained locally as `.runtime/openifs/adding_ica_sw_source_7240564/exact-original-stream-science-review.json`. It resolved 8,512,520 columns with exact integers and no Decimal callbacks in 109.83 seconds. This is elapsed verification time, not a performance comparison. Accepted capture hashes are reused, with file identity, length and change times checked before and after the read. Native verification passed 36 protected critical calls, including no layers, odd widths, near-zero positive reflection denominators, signed zero, nonzero subnormal outputs and maximum supported dimensions. It also passed all 97,750 original captured pairs over 5,255,040,000 output bytes, with zero differences, unchanged inputs, zero FPCR and preserved ABI registers. The actual local report is `.runtime/openifs/adding_ica_sw_source_7240564/native-critical-and-captured-review.json`, with the two additional subnormal calls in `native-subnormal-edge-review.json`. The complete native capture check took 17.43 seconds as a verification run. The combined same-input live forecast and saved-file checks passed.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 97,750 actual calls over 5,255,040,000 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
