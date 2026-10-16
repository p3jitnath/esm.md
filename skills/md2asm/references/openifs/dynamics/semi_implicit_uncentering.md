# Semi-Implicit Uncentering

This stage sets how the semi-implicit update weights the current and previous states. It follows the selected ECMWF, three-dimensional, hydrostatic branch of SUDYN, with semi-Lagrangian transport and two time levels. The first NAMDYN and NAMDYNA groups must already have been admitted as empty, so no user override is omitted.

## Source and Equations

The source is `arpifs/setup/sudyn.F90` lines 639, 653, 680, 1333–1348 and 1875–1890. The existing vertical setup owns the half-level pressure coefficients `VAH`, in pascals, and the finite-element flag `LVERTFE`. The source sets `VESL` to zero. It starts `XIDT` at 0.05 and changes it to zero when half of `VAH(1)` is below 100 Pa or when `LVERTFE` is true. These dimensionless factors determine the time weights.

```math
RBT=((1+VESL)\,BETADT)\,(1+XIDT), \qquad RBTS2=0.5\,RBT.
```

Each addition and multiplication has its own FP64 rounding point, in the order shown. The input `BETADT` is the existing dimensionless semi-implicit weight. On the current 19-level finite-element case, the source-derived outputs are `VESL = 0`, `XIDT = 0`, `RBT = 1` and `RBTS2 = 0.5`.

## Interface and Storage

`int md2asm_initialize_semi_implicit_uncentering(Geometry, geometry_capacity, MODEL, model_capacity, platform16)` receives its five arguments in `x0` through `x4`. Capacities are byte counts and must be at least 17,096 and 4,275,088. Both records must be aligned to eight bytes, have non-wrapping address ranges and be disjoint. The caller owns these records and their live, correctly typed vertical owners. The borrowed `platform16` record is four aligned 32-bit words for `NCONF`, `LECMWF`, `LR2D` and `LR3D`. Their admitted values are 1, 1, 0 and 1.

The original nonhydrostatic flag `LNHDYN` must be false, and the live semi-Lagrangian and two-time-level flags must both be true. Geometry contains borrowed `VAB` and `CVER` pointers at offsets 3240 and 3264. `VAH` has a unit-stride FP64 descriptor at `VAB + 128`, and its declared bounds must include index 1. Its consumed pressure must be finite and nonnegative. `BETADT` must be finite. The caller supplies the borrowed record and array capacities guaranteed by their earlier constructors.

The stage changes only 32 bytes in MODEL. `RBT` and `RBTS2` are at offsets 1567080 and 1567088. `VESL` and `XIDT` are at offsets 1568912 and 1568920. It does not allocate storage or call another routine. It preserves the stack, `x18` through `x30` and the callee-saved vector registers. It returns zero on success or two on an unsupported input, before changing MODEL.

Call this stage after the vertical setup and the source `BETADT` producer, and before the semi-implicit time-step consumers. The Arm floating-point control register must be zero, which selects round-to-nearest with ties to even and gradual underflow. No fused multiply-add or rearranged expression is used.

## Accepted Checks and Limits

Eight changed-source comparisons cover the actual 19-level finite-element inputs, a conventional grid, the exact 100 Pa branch boundary and both adjacent FP64 values, plus a negative-zero `BETADT` and both signs of zero pressure. They compare all 34,200,704 MODEL bytes and confirm unchanged Geometry. The native ABI mask is zero, and immediate floating-point control, status and errno match the original typed source segment. Twenty-four separate factor relations check the source choices and the two time weights. Fourteen critical invalid bounds, configuration and input cases refuse atomically. No model run was needed for these component checks.

The original Fortran segment is a verification reference only. The production stage is authored AArch64 assembly. Full saved-output agreement remains a separate forecast gate owned by the parent executable.
