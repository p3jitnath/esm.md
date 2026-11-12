# Interpolation Boundary Values

LAVABO prepares work values at the two extra layers just outside the model column. An extra layer stores a boundary value for interpolation, which estimates values between stored points. This operation changes work buffers and performs no time update.

Revision 1 follows the [physical formulation](../../../../../formulations/openifs/dynamics/interpolation_boundary_values.md) and [direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/dynamics/interpolation_boundary_values.S). A buffer is a bounded region of memory that stores an array. FP64 stores a floating-point number in 64 bits. Positive zero is the zero representation with all bits clear. An alias is another view of the same memory.

For each selected work field $`X`$, let $`L`$ be the number of physical levels, with no physical unit. The reference boundary rule is

```math
X_0=0,\qquad X_{L+1}=0. \tag{P01}
```

The zeros have the units of their stored fields, including the accepted wind and transported-variable representations. They are values in interpolation work arrays, rather than new temperature or wind values at a physical model level.

The selected forecast has 24 rows per block, 19 physical levels and 463 PB1 columns. Active rows are 1 through 24, or 1 through 8 in the last block. A field uses a base column supplied by the complete model record. Its two boundary columns are the base and base+20. Each store must write the exact FP64 positive-zero bits, and every other PB1 byte must remain unchanged.

The application binary interface, or ABI, passes six addresses in registers `x0` through `x5`, in the order GEOMETRY, MODEL, KST, KPROF, LD2TLFF1 and PB1. It has no incoming stack arguments. Integer and logical scalars use four bytes, and work values use eight bytes. The native body uses a 448-byte frame with 16-byte stack alignment. It preserves `x18`, `x19` through `x29`, the return address, the low 64 bits of `d8` through `d15`, and the floating-point control register. The selected refined flag is false. The complete field metadata array YCOMP is embedded in MODEL. Each of its 2,163 declared elements has 368 bytes. Only the first NUMFLDS=8 elements select work fields. Retain the full MODEL/YCOMP alias and all complete ordinary owner bytes.

The source selects trajectory rotation components UR0, VR0, ZR0 and WR0, then current U9, V9 and T9 terms. ZR0 is present because LSLDP_CURV is true. The right-hand-side curvature flag is false, so its inactive Z9 and ZP9 map sentinels are not consumed. Advected scalar fields select their first work slot through MP_SL1 unless CSLINT is LAITVSPCQM followed by two spaces. The current U0/V0 and T0 slots are included because NWLAG and NTLAG are three. The continuity slot C9 is included because NVLAG is three.

Split physics is active, so UP9, VP9, TP9 and each LPHY field's MPSLP work slots are also zeroed. The selected Runge–Kutta, extra high-order split, nonhydrostatic and extra linear-term routes are inactive. Preserve their complete raw metadata without consuming their unused map values.

Before any write, validate every selected base and boundary column against the complete PB1 owner. Require valid active row bounds and the source-qualified field metadata positions. Native assembly must own column selection and every zero store, preserve x18 and the required saved registers, and retain the original profiling entry and exit when LHOOK is true. The caller supplies storage, while the direct assembly supplies every boundary calculation. An empty active row interval performs no boundary stores.

The source and direct calls pass both genuine row forms across 10,354,176 complete owner bytes and 1,408 independent positive-zero requirements, with zero differing bytes and exact immediate machine status. The byte total sums all declared views, including repeated bytes where views overlap. An explicit bridge preserves `x18` around the original Fortran call. A small check covers fresh and incoming status, both row forms and an empty row interval. Six unsupported controls or bounds fail before any buffer write. Isolated checks omit profiling because they lack the model runtime. The actual forecast passes 2,150 complete source/native calls across 11,130,739,200 complete owner bytes, with zero differing bytes and exact ABI and machine status. All 2,252,800 required stores write positive zero. The original profiling control remains enabled, and the direct body makes all 4,300 entry/exit calls. All ten saved files match across 618,140 bytes.

The primary route is directly written AArch64 assembly assembled by GNU gcc and linked as a shared object. It uses no compiler-generated numerical assembly, high-level numerical fallback, or driver-supplied stage. The public assembly contains its frozen typed positions, so it needs no private include file. The source shadow separately uses the qualified original Fortran body through an explicit x18-preserving bridge.
