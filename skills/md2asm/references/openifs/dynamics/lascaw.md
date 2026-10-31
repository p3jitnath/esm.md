# LASCAW Departure Weight Contract

Numerical revision 1.0 freezes the complete one-process parent from the original LASCAW source. Its physical input is [departure_point_weights.md](../../../../../formulations/openifs/dynamics/departure_point_weights.md). Coordinate lookup, weight generation, correction, smoothing and boundaries remain inside the assembly route. The accepted numerical children are [CLA](lascaw_cla.md), [CLO](lascaw_clo.md) and [VINTW](lascaw_vintw.md).

## Calculation And Ordering

Let K be width, N be levels, C=KN be cells and R be the latitude-table length. Rows vary fastest. FP64 means a 64-bit floating-point value. Round each operation separately. FPCR, the Arm control register, is zero. Preserve signed zeros and gradual underflow. Forbid fused arithmetic, reassociation and approximate instructions.

Find each latitude pair with original truncation and the signed-half rule. Preserve epsilon, 100 times the smallest normal FP64 value, in the common latitude calculation. The two-dimensional cubic path then replaces its distance without epsilon. Longitude truncates the scaled angle and uses the supplied integer remapping table with its full descriptor strides.

Find the three-dimensional vertical pair with KVAUT and the rounded lookup scale. Advance it once only when the original positive-distance condition holds. Store original fractional and correction distances, all four horizontal parent indices and separate level-specific indices.

| KWIS | Complete parent route |
| --- | --- |
| 101 | Trilinear distances and four horizontal indices. |
| 102 and 103 | Cubic coordinates, correction and all three weight children. |
| 104 | Cubic route plus Hermite value and derivative weights. |
| 105 | Cubic route plus supplied spline polynomials. |
| 106 | Cubic route plus three WENO candidate windows. |
| 201 | Bilinear distances and two central horizontal indices. |
| 202 and 203 | Two-dimensional cubic coordinates and horizontal children. |

Construct each stored cubic latitude weight from three separately rounded distances and a supplied reciprocal denominator. The local table has row, coefficient and level order. Correction replaces central distances with their original scaled values and rounded half-gap terms, then forms the same triple products.

Keep original flags for diffusion, quadratic weights, old linear weights, heat, turbulence, high-order trajectory weights and vertical filtering. Generate separate heat families first. Each horizontal slot calls complete CLA and CLO. The split-physics slot has complete temporary latitude and longitude families. Turbulence has three complete temporary planes. Update the midpoint option's vertical quadratic selector after horizontal calls.

WENO visits windows three, two and one. Preserve shifted indices, KNOWENO updates, original fractional distances and a positive-zero minimum. Uniform-grid central, lower and upper combination weights are below.

```math
c_1=0.10(2+d)(3-d),\qquad
c_2=0.05(2+d)(1+d),\qquad
c_3=0.05(2-d)(3-d).
```

The general grid uses supplied gamma coefficients and separately rounded two-distance products. Its boundary combination weights stay unchanged. Candidate interpolation and smoothing follow VINTW.

Hermite value weights are below. Preserve the original one-sided boundary derivative projection and half-weight interior projection.

```math
H_1=(1-d)^2(1+2d),\quad H_2=d^2(3-2d),\quad
H_3=d(1-d)^2,\quad H_4=-d^2(1-d).
```

For splines, delta is the difference from the first central vertical node. Evaluate each supplied polynomial in its original nested order. Coefficient e multiplies delta in the innermost term.

```math
w=a+\delta\left(b+\delta\left(c+\delta e\right)\right).
```

## Supported Domain And Storage

NPROC must be one. Reject other values before outputs because the original two-process correction path has a proven incomplete communication mask. This limit does not repair or accept that configuration.

Support 0 through 1024 rows, 2 through 256 levels and valid selected intervals. Empty intervals preserve every output byte. Latitude stencils and longitude indices lie inside supplied tables. Vertical nodes increase, selected positions lie in the chosen pairs, and the lookup table needs at most one advance. Consumed mathematical values are finite and obey the unchanged child error and overflow limits.

KDIMK is one through three. Three-dimensional turbulence requires three. WENO requires three coefficient windows and at least four levels. Hermite requires KHVI one. Exclude diffusion without quadratic or old linear weights because original child locals are undefined. Apply this guard to selected split-physics slots. Unused bytes stay opaque.

Seventy-eight ordinary argument pointers follow the original source order. Integer and logical words have four bytes. Real words have eight. Proven GNU Fortran object layouts are TVSPLIP 264 bytes, SL_STRUCT 1800 bytes and TDYNA 456 bytes. Keep complete objects and pointees unchanged for one process. Preserve complete remapping and spline descriptors.

| Buffer family | Complete extent in words |
| --- | --- |
| Positions, kappa, correction factors and scalar distances | C per family. |
| Latitude main, correction and filtered weights | 3C times KDIMK. Heat has 3C. |
| Longitude distances and horizontal indices | 4C. |
| Longitude main, correction and filtered weights | 6C times KDIMK. Heat has 6C. |
| Vertical pair indices and WENO shifts | C integers per family. |
| WENO combination weights | 3C. |
| Vertical main and filter weights | 3C times KWENO. Other triples have 3C. |
| Spline weights | 4C. |
| Hermite derivative and value weights | 4C times KHVI squared and 4C times KHVI. |

Output families are disjoint from each other and consumed inputs. Inputs may share read-only storage. Integer alignment is four bytes and real alignment is eight. Temporary arrays provide complete planes for actual calls. No external driver supplies mathematics.

## Arm Interface And Verification

The application binary interface, ABI, defines argument and register rules. Eight pointers arrive in x0 through x7. Seventy more occupy incoming stack bytes zero through 552. Preserve the stack pointer, x18, x19 through x29, low 64 bits of v8 through v15 and FPCR. The 1600-byte frame stores complete pointers and outgoing child arguments. Allocate complete temporary families once and release them before return.

Before assembly emission, the original one-process body passed 68 protected cases, 3866416 complete output bytes and 86786 new physical relations. Checks cover coordinate brackets, complete integer addresses, Hermite endpoints and slopes, spline partition and degree-zero through degree-five WENO composition. Reuse unchanged child proofs. Retain the earlier two-process mask failure locally.

Compare complete arguments PDLAT through PHVW, including inactive rows, unused families and neighbour WENO windows. Require zero differing bytes. Check complete metadata, buffer bounds and ABI. Exact-rational physical checks use a conservative rounding budget for the parent operation count and up to six coordinate factors. The direct parent passed 136 protected calls, 7732832 complete output bytes with zero differences and 173572 new physical relations. All calls passed the immediate ABI check. Six unsupported-domain probes exited with status 116 and preserved all 635600 shared buffer bytes. The complete paired relay passed all 68 cases across 3866416 returned bytes and 4742816 unchanged input bytes. No comparative timing is claimed.

The forecast relay retains the accepted original metadata scope for CLA and VINTW. It checks the genuine strict-library LASCAW entry separately and permits a scope route only through its explicitly qualified path. Native calls private accepted child objects. The relay checks complete original and native parent weights independently, including WENO coefficients derived from six-node interpolation, with the unchanged node-gap rounding budget. It returns native bytes and reports complete output differences.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| lascaw | 6,450 | 1,764,720,000 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
