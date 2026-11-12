# Departure Coordinate And Field Contract

Numerical revision 1 preserves the original LARCINA argument order and selected spherical Cartesian forecast mode. The physical input is [departure_point_fields.md](../../../../../formulations/openifs/dynamics/departure_point_fields.md). Retained queue evidence records 2,150 actual LARMES_XYZ calls and 6,450 LARCINA calls. This mode is forecast-reachable; the complete autonomous forecast remains unfinished.

## Complete Selected Calculation

Keep FP64, the 64-bit floating-point format, with Arm FPCR zero, nearest rounding, signed zeros and gradual underflow. Round each multiply, add, subtract and divide separately. Forbid fused arithmetic, reassociation and approximate instructions.

Preserve the source factors $`2R_{\mathrm{STRET}}`$, $`2R_{\mathrm{PI}}`$ and $`R_{\mathrm{PI}}/2`$. The Cartesian trajectory has already supplied longitude and latitude, so the source skips LARCHE. LASCAW generates all coordinate brackets, addresses, boundary indicators and interpolation weights. Reuse its complete accepted latitude, longitude and vertical children and its independent physical proof.

Keep the source control order. For KTIP one, select trilinear weights or high-order trajectory weights, with WENO when its original switch is true. For KTIP two, spline has precedence over WENO, then cubic or Hermite weights. KTIP three keeps the source adjoint selector and zero horizontal selector. Optional trajectory-field interpolation is admitted for KTIP one. Its WENO branch has precedence over high-order interpolation, then trilinear interpolation. Interpolate all four source components because this mode retains curvature. Extra vertical smoothing is disabled, so PWFSM stays unchanged.

All selected equations and numerical children are inside the assembly route. The driver only checks the interface, clones complete owners, observes physics and compares returned bytes. It supplies no numerical stage and makes no global math override.

## Supported Storage

Support one process, one through 1024 columns, four through 256 levels, valid cropped or empty column intervals, KTIP one through three, KHVI zero or one and limiter codes zero through three. Use the original spherical Cartesian and curvature flags, one weight family, no split-physics slot, and no horizontal diffusion, turbulence or correction. The heat-diffusion setting may be either logical value because this route does not consume it; a source-first focused check covers the ECMWF default value true. Reject plane, other trajectory schemes, vertical smoothing, requested vertical-separation search and unsupported controls before writes. These limits concern the selected complete model route.

Columns vary fastest. Keep complete PLSCAW and PRSCAW owners, all four horizontal index planes, vertical and boundary indices, and every selected wind output. The measured read-only records have 17,096 geometry bytes, 13,232 model-dynamics bytes and 1,800 semi-Lagrangian bytes. Their descriptors, which hold addresses and array bounds, use the measured element types, contiguous strides, canonical origins and element spans. Descriptors and consumed pointees stay unchanged. Vertical-coordinate and control records have 320 and 216 bytes.

Each original weight selector names a checked window inside its whole parent owner. Preserve permitted internal window overlap and the source order. Whole writable owners are disjoint from other owners and consumed inputs. Consumed real values are finite and satisfy the unchanged LASCAW and interpolation domains. Check coefficient descriptors only when the selected child consumes them. In this model, diffusion and turbulence tables are unused; other coefficient families follow the original interpolation and regular-grid controls. An unused descriptor may have a null data address, while every consumed owner remains required. Unused kappa and wind arguments may be one-word source dummies; do not read a nominal full field when its branch does not consume it. Geographic PSCO and KROT are unused here. KDEP, PWFSM, vertical-separation words and inactive field bytes stay unchanged.

## Arm Interface And Checks

The application binary interface, ABI, defines argument and register rules. The normal entry is larcina_ and the private entry is md2asm_larcina_7240564. Both reach the same complete native body. Forty-four pointers follow the original order. The first eight arrive in x0 through x7 and the other 36 occupy the incoming stack. Integers and logical words have four bytes; real words have eight. Keep 16-byte stack alignment and preserve x18, x19 through x29, the low 64 bits of v8 through v15, FPCR and errno.

Before numerical emission, ten protected original-first cases pass 387,840 complete bytes and 6,866 independent relations. They cover weight routes 101 through 106, all three wind interpolation choices, the adjoint selector, a single column, cropped and empty intervals, read-only metadata and complete inactive storage. Independent exact-rational weight checks and constant-field preservation reuse the accepted complete children.

The direct native body passes 20 protected cases at two buffer placements, with 775,680 complete bytes, zero differences and 13,732 independent relations. Its immediate ABI and fresh numerical status agree with the original. Eight focused live pairs cover all three wind choices, spline weights, empty intervals, the retained 24-column and 19-level shape, profiling and an alternate working directory. These pairs compare 592,320 complete bytes with zero differences and check 13,164 independent live relations. Source-first inactive heat-setting checks add 91,008 original bytes and 1,360 independent relations; four native and paired calls add 182,016 bytes and 2,720 relations. Three further source-first cases check null data addresses in unconsumed coefficient descriptors, with 137,392 original bytes and 2,388 independent relations. Six native and paired calls pass 274,784 complete bytes and 4,776 relations with these same inactive descriptors. Normal-entry, descriptor-origin, element-type and span checks reuse the unchanged numerical proofs. Twenty-six shared-owner rejection cases confirm that unsupported controls and storage fail before writes.

Require zero differing complete output bytes; do not round, mask or normalize values. Canonical calls compare fresh numerical status exactly. Profiled calls record native numerical status separately from source hook arithmetic, preserve incoming and source status, and return native bytes. The relay uses MD2ASM_LARCINA_REPORT and records genuine private parent and child calls. Full-forecast acceptance and timing remain separate.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete arrays and records compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| larcina | 6,450 | 2,121,757,600 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
