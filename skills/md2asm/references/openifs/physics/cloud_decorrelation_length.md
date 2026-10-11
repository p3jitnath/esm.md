# Cloud Decorrelation Length Contract

The [physical input](../../../../../formulations/openifs/physics/cloud_decorrelation_length.md) is revision 1.0. The complete direct entry is [cloud_overlap_decorr_len.S](../../../../../src/openifs/physics/cloud_overlap_decorr_len.S), replacing the original queued name `CLOUD_OVERLAP_DECORR_LEN` from `arpifs/phys_radi/cloud_overlap_decorr_len.F90`.

## Complete Calculation

Mode 0 fills the selected cloud-boundary and optional cloud-water vectors from `RDECORR_CF` and `RDECORR_CW`. If the optional ratio is present, it computes `RDECORR_CW/RDECORR_CF` even when the selected interval is empty. These lengths are in kilometres and their ratio is dimensionless.

Mode 1 computes the rounded factor $`180/RPI`$, multiplies each rounded ASIN result by that factor, takes its absolute value and subtracts `0.02759*latitude` from 2.899. Every other nonzero integer mode uses the smooth branch, including the original behaviour for values other than 2. It computes `0.75 + (2.149*cosine)*cosine`, preserving the two separately rounded multiplications. Both branches fill optional water lengths with a separately rounded `edge*0.5` and write the optional ratio 0.5.

ASIN recovers latitude from its sine, and COS returns the cosine of that recovered angle. All 32 configured sine-of-latitude words and their original rounded ASIN and COS-of-ASIN results reuse the complete [ice-radius latitude qualification](ice_particle_radius.md). The full grid is derived from the original SULEG, SUGAW, SULEGA, SUGEM2 and RADINTG setup, rather than a captured subset. Each active latitude is checked against that complete table before any output write. RPI must retain the frozen word `400921fb54442d18` in the latitude branches. Other grids require a new complete qualification.

The native body stores the selected rounded angle or cosine in a temporary vector while checking membership. It then performs the complete source length equations directly. The unchanged 120-digit primitive proof is reused. There is no general trigonometric call and no replacement of the source composite function by a square-root identity.

## Interface And Bounds

The application binary interface (ABI) defines how a caller passes values and which registers a function must preserve. Nine addresses follow the GNU Fortran AArch64 ABI. They are TECLD, KIDIA, KFDIA, KLON, sine of latitude, integer mode, required cloud-boundary output, optional cloud-water output and optional scalar ratio. The first eight use x0–x7 and the ratio address is on the incoming stack. A null optional address means that output is absent. Integer scalars own four bytes, vectors own `8*KLON` bytes and a present ratio owns eight bytes. FP64 vectors need eight-byte alignment. Inputs and mutable outputs must not overlap, and separate mutable outputs must not overlap.

TECLD owns 264 bytes. RDECORR_CF and RDECORR_CW are at byte offsets 136 and 144. The scalar global RPI owns eight bytes. Complete configuration and input owners remain read-only, while inactive output words retain their original bits. An unused latitude vector in constant mode can contain arbitrary NaN payloads.

The supported vector length is 1–2048. The selected interval must lie within the vector or be empty. Constant boundary length is positive and finite. A consumed constant water length is positive and finite. The native entry preserves x19–x29, the link register and stack alignment. It uses an aligned eight-byte temporary per column in a latitude branch, and no floating-point callee-saved register. FPCR must be zero, with separately rounded FP64 arithmetic, gradual underflow and preserved signed zero. No fused operation or reassociation is permitted.

## Acceptance

The original physical gate passes 50 protected placements, 81872 complete output bytes and 29864 independent length relations. It includes all mode branches, all optional-output combinations, complete latitude rows, empty intervals, one column, 2048 columns and arbitrary inactive or unused NaN words. The unchanged complete trigonometric proof is reused. The direct body passes the same 50 protected placements and 81872 bytes, with 59728 independent source/native relations. Four paired direct-entry calls compare 1336 bytes and check 393 live physical relations, with all 32 latitude bits exercised. Shared-output checks show that an unqualified coordinate or changed RPI stops before all 40 mutable output bytes. Output differences are zero, complete read-only owners remain unchanged, immediate ABI preservation passes and FPCR is zero. Genuine  Genuine forecast acceptance additionally requires every consumed latitude guard and unchanged saved output files.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cloud_overlap_decorr_len | 2,150 | 51,187,200 | Native private overlap child, compared complete cloud-parent owners and child proof |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
