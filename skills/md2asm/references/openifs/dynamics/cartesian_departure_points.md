# Cartesian Departure Points Contract

This contract covers the complete selected `LARMES_XYZ` Cartesian route. It uses the unchanged source interface and accepted interpolation children. The source-first gate checks seventeen complete calls against independent 120-digit constant-wind sphere geometry, with 4,368 physical relations and 109,896 frozen output bytes. Scientific checks use an analytic constant-velocity solution and admissible vertical positions. They do not use the generated assembly as their reference.

## Inputs And Scope

The twenty-four original pointer arguments remain in source order. Integers and logical values occupy four bytes and real values occupy eight bytes. The first eight pointers use `x0` through `x7` and the other sixteen arrive on the stack. `NPROMA` is the fastest array dimension. Accepted shapes have 1 through 1,024 columns, 4 through 256 levels, cropped or empty active columns, and 2 through 16 trajectory iterations. The caller supplies complete aligned declared owners, with distinct output views and no overlap with consumed input views. An output view may lie inside an otherwise shared larger caller owner and the accepted GNU Fortran descriptor layout. New consumed fields are measured by a storage-only Fortran probe in `layout.json`, which supplies no numerical calculation.

The selected sphere accepts either value of `LRHS_CURV`, with `LSLDP_XYZ` and `LSLDP_CURV` set to true, `LFINDVSEP` set to false, and the accepted LARCINA model flags and descriptors. Vertical WENO winds are disabled with `LSLTVWENO` false. The shared `md2asm_laitri_weno` alias forwards its unchanged 22-address interface to the accepted `laitri_weno_` assembly entry, including for field-interpolation callers. Accepted linear and high-order wind interpolation children remain assembly. The actual retained forecast used the linear child. Wind components are finite and remain below the source's soft warning limit. The reporting flag `LRPRSLTRJ` may be false or true. Profiling and formatted warning text are outside the canonical saved forecast state. The native body computes both trajectory-bound counters and every selected numerical reporting calculation in source order.

## Complete Update

Form the source constants in order. Compute twice pi, half the time interval, full-level top and bottom positions, and the convex combinations of full and half levels that set the admissible vertical interval. Evaluate the source's two squared wind limits and the two maxima of squared horizontal wind components. Reject an unsupported wind domain before changing caller state.

A saved departure point is active when `LSLDP_SAVE` is true and the global time-step index is at least one. Copy its longitude and latitude into the departure coordinates. Use its vertical position when full predictor-corrector mode is active, with `LPC_FULL` true, `LPC_CHEAP` false and `NCURRENT_ITER` positive, or when earlier and current vertical velocities have a positive product. Otherwise use the first-order vertical predictor. Without an active saved point, subtract the full time interval times each arrival wind component from the arrival Cartesian position, then compute its two angles and the first-order vertical predictor.

For iterations two through `NITMP`, the routine owns and passes all private interpolation weights, temporary vertical and Cartesian-z winds, counters and index storage to the unchanged accepted LARCINA calculation. It then subtracts half the time interval times the sum of the interpolated and arrival winds from the arrival position. It computes the resulting longitude and latitude and applies the same midpoint update to the vertical position. Clamp that position to the supplied admissible interval. On the last iteration, update the source's top and bottom crossing counters with nearest-integer rounding, with ties away from zero. Copy the final vertical wind to `PWF` when `LSLDIA` is true. Save all three final departure coordinates when `LSLDP_SAVE` is true.

## Tangent-Wind Rotation

When `LRHS_CURV` is false, the routine transfers tangent-wind components between the arrival and departure positions. Let $`\phi_d`$ and $`\lambda_d`$ be the departure latitude and longitude in radians. The supplied arrival longitude is $`\lambda_a`$, and its stored latitude sine and cosine are $`\mu_a`$ and $`c_a`$. Read the complete selected `GELAM`, `GEMU` and `GSQM2` owners. Call the qualified sine and cosine helpers separately, in the original order, for departure latitude and the separately rounded longitude difference.

```math
s_d=\sin\phi_d,\qquad c_d=\cos\phi_d,\qquad
s_\delta=\sin(\lambda_a-\lambda_d),\qquad
c_\delta=\cos(\lambda_a-\lambda_d).
```

Each following product, sum, subtraction and division has its own FP64 rounding point. Products with three factors proceed from left to right. These dimensionless terms describe the relative directions of the two tangent bases.

```math
Q_{11}=c_\delta,\qquad Q_{12}=s_ds_\delta,\qquad
Q_{21}=(-\mu_a)s_\delta,
```

```math
Q_{22}=c_ac_d+(\mu_as_d)c_\delta,\qquad
Q_{33}=\mu_as_d+(c_ac_d)c_\delta.
```

Store the following two transfer values in the original `M_RQX` and `M_RQY` coordinate planes before saving the departure position.

```math
p=\frac{Q_{11}+Q_{22}}{1+Q_{33}},\qquad
q=\frac{Q_{12}-Q_{21}}{1+Q_{33}}.
```

Independent 120-digit checks construct Cartesian radial, east and north basis vectors and use their dot products to determine the transfer. They also check $`p^2+q^2`$ against one, with the declared allowance for the supplied rounded arrival basis. The original source and native rotation agree exactly for both hemispheres, longitude quadrants, signed zero, saved points and empty intervals. Protected cropped intervals preserve the original ABI and inactive bytes. The complete genuine original call also passes 1,368 independent basis relations. Its native caller replay matches all sixteen returned owners over 382,440 bytes, with unchanged status and errno. The normal paired relay confirms one completed private trajectory stage and zero differing returned bytes. The saved forecast gate remains required for admission.

When a top or bottom crossing counter is nonzero and `LRPRSLTRJ` is true, traverse every vertical wind value in source order for its maximum. Then call the qualified inverse cosine on the selected `CSGEOM%RCOLON` value and the qualified inverse sine on `GSGEOM%GEMU`, multiplying each angle by 180 and dividing separately by the original pi. These complete numerical reporting stages preserve status. Their text is diagnostic output. Focused above-atmosphere and underground cases witness both reporting branches and match all returned bytes, ABI, status and errno. The reporting counter used for this private check supplies no forecast calculation.

## Ordered Arithmetic

Every primary physical multiplication, addition, subtraction, division and square root is a separate FP64 operation with its original source rounding point. The squared Cartesian norm is formed as the rounded sum of rounded x and y squares, followed by the rounded z square. The ratio passed to inverse sine is the separately rounded z component divided by the separately rounded square root. Longitude uses the original two-component ATAN2 route. Its source normalisation is the rounded expression `(0.5-SIGN(0.5,longitude))*twice_pi+longitude`, preserving signed-zero behaviour. No physical expression is contracted or reassociated.

The exact original-compatible SIN, COS, ASIN, ACOS and ATAN2 helpers are atomic mathematical primitives with previously qualified source algorithms. Their internal integer product-sum child returns one correctly rounded result for an exact product plus addend. This one-rounding scope belongs only to those original math helpers and does not permit fused arithmetic in physical updates. The direct integer assembly child reuses the accepted rational proof and status corpus. Neither helper uses a C numerical dependency, compiler-generated assembly, an approximate instruction or a global math override.

## Owners, ABI And Acceptance

Compare every byte of all twelve caller output owners, including every index plane, saved point, unused coordinate plane and inactive column. Keep geometry, model, time-control, semi-Lagrangian metadata, arrival fields, earlier vertical wind and all their declared read-only pointees unchanged. Internal work arrays are owned and released by the assembly routine. The verification driver supplies only frozen inputs and compares returns. It supplies no omitted numerical stage.

Use FPCR zero, round to nearest with ties to even, gradual underflow and preserved signed zeros. Preserve `x18`, `x19` through `x29`, the low 64 bits of `v8` through `v15`, the stack pointer and its sixteen-byte alignment, FPCR and inherited errno. Preserve sticky FPSR bits and match source-raised numerical bits. Unsupported controls or numerical domains reject. Native acceptance needs the one protected-buffer byte, physical, status and ABI gate. Genuine model-call comparison and exact saved forecast files remain the parent's next acceptance gate. This private preparation does not add a completed weather routine or establish an autonomous forecast.

The [basic input](../../../../../formulations/openifs/dynamics/cartesian_departure_points.md) and [direct source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/dynamics/cartesian_departure_points.S) retain the original LARMES_XYZ interface. The qualified [direction angle](../support/direction_angle_original_rounding.md), [inverse sine](../support/asin_original_rounding.md) and [integer rounding child](../support/rounded_product_sum.md) complete its mathematical route. The unchanged [LARCINA contract](larcina.md) fixes all interpolation children.

## Actual Forecast Acceptance

The combined coarse forecast uses exclusive allocation 7259755 on nid010824. These actual assembly calls have zero differing bytes. A compared array contains the complete storage supplied by its caller. Private child counts exclude original comparison calls.

| Original routine | Actual calls | Compared bytes | Scope |
| --- | ---: | ---: | --- |
| larmes_xyz | 2,150 | 822,246,000 | Private trajectory calls and complete parent arrays |

All ten saved files match across 618,140 bytes. Accepted critical physics and interface checks are reused. Independent physics for the whole forecast, whole-process byte agreement, autonomous execution and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
