# Turbulent Terrain-Drag Contract

Revision 1 freezes the complete original `vdftofdc` body for [small-hill drag](../../../../../formulations/openifs/physics/turbulent_terrain_drag.md). The original passes independent drag and energy checks before direct assembly generation.

## Ordered Calculations

Load the drag parameter `RTOFDALPHA` and separately multiply by the original stored `0.005`, `0.6`, `2.109` and derived `ZFACT1` constants. The source literals use default real precision before conversion to FP64. Keep their original bits, including `ZFACT1=0x1.7f28871d058fbp-20` and the exponent `-0x1.3333340000000p+0`. The derived constant is independently checked against its mathematical power-and-ratio expression. Divide 1500 and 5000 by the stored planetary scale to obtain the height scale and cutoff.

For each selected column, square the terrain variation, then multiply it by the completed parameter product. At each level, divide geopotential by gravity and select columns at or below the height cutoff. Recompute that same height for the numerical body, square each wind component separately, add them, apply the source speed floor and use the qualified hardware square root. Divide height by its scale, call the [opaque original POWER boundary](../power_math.md) with exponent 1.5, negate the result and call the accepted scalar EXP. Call POWER again on height with the exact widened source exponent. Multiply speed by the terrain coefficient, then by the exponential result, then by the height-power result.

After each level's calculation, clear every column in that output level, including columns outside the selected range, and write the selected coefficients. An empty selected range therefore returns a zero matrix. Preserve all source FP64 rounding dependencies, FPCR zero, gradual underflow and signed zeros. Solver operations have no fused arithmetic, reassociation, approximate division or reduced precision. POWER's separate primitive contract reproduces 20 original internal single-rounded steps with integers and no fused floating-point machine instruction. EXP and SQRT reuse their unchanged qualified routes.

## ABI and Domain

The Arm application binary interface, or ABI, passes ten addresses. Registers `x0` through `x7` address `YDVDF`, `KIDIA`, `KFDIA`, `KLON`, `KLEV`, `PUM1`, `PVM1` and `PGEOM1`. Caller stack offsets 0 and 8 address `PSIGFLT` and `PTOFDC`. Integer arguments occupy four bytes. Matrices use contiguous little-endian FP64 in Fortran order, with column index varying first. The terrain vector has one value per column, and the complete output has $`8KN`$ bytes.

Support zero to 4096 columns, zero to 1024 levels and valid selected indices. Input owners can share storage, while the complete output is disjoint from inputs and metadata. The 72-byte `TVDF` owner supplies `RTOFDALPHA` at offset 48. Frozen module globals supply gravity and planetary scale. Scalar pointers are valid and aligned to four bytes, while real owners align to eight bytes. An empty matrix or vector can have a zero address because no element is accessed.

Use finite drag parameters from zero to 100, gravity from 4.903325 to 19.6133 metres per second squared, and planetary scales from 0.5 to 2. Consumed terrain variation is finite and nonnegative, at most 10000 metres. Selected height is finite from 0.01 to ten million metres. Wind components consumed below the cutoff are finite with magnitude at most 200 metres per second. Values above the cutoff need no wind arithmetic.

The aligned fixed stack frame has 256 bytes and preserves `x19` through `x29`, the return address and `d8` through `d15`, while leaving `x18` and FPCR unchanged. Two additional column vectors use at most 65536 aligned stack bytes. The complete numerical body is direct AArch64, with no heap allocation or high-level solver helper.

## Acceptance

The unchanged original passes 30 protected cases, 84752 complete output bytes and 20422 independent physical relations. High-precision intervals check newly consumed POWER arguments and the final closed drag formula. Exact rational bounds carry rounding errors through solver arithmetic. A nonnegative coefficient removes horizontal kinetic energy when applied as drag. The checks include zero wind, flat terrain, signed zeros, subnormal terrain, cutoff neighbours, interior selected columns, shape limits and empty dimensions or ranges.

The unique POWER helper matches every newly consumed critical power operand, including the widened negative exponent, with zero bit differences. New native acceptance also requires the immutable original output corpus, independent physics, protected buffers, unchanged inputs, register obligations and zero differing complete output bytes. The native body and paired relay each pass all 30 protected cases and 84752 complete output bytes with zero differences. Six immediate register cases pass 41456 bytes and 10055 physical relations. Five invalid bounds reject before changing 360 shared output bytes. The paired relay checks the closed drag law and removal of wind energy on each actual call, then returns native bytes. Whole-forecast and performance gates remain separate.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vdftofdc | 2,150 | 7,843,200 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
