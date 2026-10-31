# LDFOU2 Fourier Wind Scaling

Revision 1 freezes the complete $`\texttt{LDFOU2\_MOD::LDFOU2}`$ body from the original source. The physical input is [fourier_wind_scaling.md](../../../../../formulations/openifs/dynamics/fourier_wind_scaling.md). The assembly is [ldfou2.S](../../../../../src/openifs/dynamics/ldfou2.S). There is no numerical child call.

## Selected Update

Let $`N`$ be the northern latitude count, $`M`$ the wave number and $`U`$ the number of wind-field pairs. The precomputed map $`n(M)`$ gives the latitude count for that wave. Select $`j=\max(N-n(M)+1,1),\ldots,N`$ and rows $`i=1,\ldots,4U`$. At each selected cell, return $`\operatorname{RN}_{64}(A_{ij}r_j)`$ and $`\operatorname{RN}_{64}(S_{ij}r_j)`$. Here RN64 means one rounding to the 64-bit floating-point format. There is no reduction, division or latitude-factor calculation in this body. The unchanged caller supplies every factor, as defined by SULEG's $`1/\cos\theta/a`$ construction.

Support $`0\le M,U\le1024`$, $`0\le N\le4096`$ and $`0\le n(M)\le N`$. Consumed wind values are finite. Each consumed factor is positive and finite, and each product is finite. Global allocated vectors have unit stride and include the selected indices. The two output views have separate storage, positive row and column strides, and sufficient declared rows and latitudes. A column starts after the preceding column's complete declared rows. Empty selections change no array bytes. Inactive values may be nonfinite because the body does not consume them.

## ABI and Storage

The application binary interface, or ABI, defines the arguments and registers used by a call. Export `__ldfou2_mod_MOD_ldfou2`. Registers x0 and x1 hold addresses of four-byte integers KM and KF_UV. Registers x2 and x3 hold GNU 12.3 rank-two descriptors for PAIA and PSIA. A descriptor is an 88-byte record containing an array address, strides and bounds. Each assumed-shape dummy begins at descriptor.data and uses row and column strides. Caller lower bounds and the descriptor offset do not change that dummy origin.

| Metadata | Complete size, bytes | Consumed member offset, bytes |
| --- | --- | --- |
| TPM_DIM R | 56 | NDGNH 28 |
| TPM_GEOMETRY G | 208 | NDGLU descriptor 128 |
| TPM_FIELDS F | 728 | RACTHE descriptor 280 |

R, G and F are exported typed pointers. Their allocated vector descriptors use data plus descriptor.offset plus the original logical index. Each real value occupies eight bytes and has eight-byte alignment. Complete owner spans include stride padding and all inactive cells. Keep every byte outside the selected cells unchanged.

The leaf uses caller-saved integer and vector registers. It leaves x18 unused, preserves x19 through x29 and the low 64 bits of v8 through v15, and leaves SP unchanged and aligned to 16 bytes. Its unsupported-contract path exits with status 116 before an output write. Buffer capacities and nonoverlapping owners remain caller obligations checked by the paired relay.

## Arithmetic and Evidence

Require FPCR zero before and after the call. This selects round-to-nearest with ties to even, gradual underflow and the declared target's floating-point state. Keep signed zeros and separate FP64 products. Forbid fused arithmetic, reassociation, reduced precision and approximate operations. Four independent contiguous rows use two-value NEON vectors. Positive nonunit row strides use the scalar path. Vector lanes share a factor and never combine values.

The unchanged original passed 90 protected prefix and suffix cases, 1369984 complete output bytes and 213696 independent scale, inverse-scale and sign relations. The direct native body passed the same cases and bytes with zero differences. Cases include empty fields and latitudes, partial latitude selection, padded and nonunit-stride views, caller lower bounds, signed zeros, subnormal values and rounding boundaries.

The complete paired relay also passed all 90 cases and 1369984 returned bytes with zero differences. It snapshots the complete immutable metadata, clones both complete output owners for the original, executes assembly on the real owners and returns assembly bytes. Its independent product residual uses 113-bit Arm long double because an FP64 product has at most 106 significand bits. The raw exact comparison remains the acceptance gate. No speed comparison is claimed. All source controls, verifier code, build commands, immutable identities and reports remain locally in .runtime/openifs/ldfou2_source_7240564/.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| ldfou2_mod::ldfou2 | 1,342 | 28,655,616 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
