# Dry Layer Mass Contract

The physics input is [dry_layer_mass.md](../../../../../formulations/openifs/physics/dry_layer_mass.md), revision 1, equation P01. Preserve the original `radiation_thermodynamics::get_layer_mass` calculation and GNU Fortran 12 array interface.

## Calculation

Use FP64, which stores each real value in 64 bits. First round $`1/9.80665`$ to FP64. For each selected column and layer, subtract the top pressure from the bottom pressure, round that difference, then multiply it by the rounded reciprocal and round again. The assembly stores the reciprocal as its exact binary64 constant. Do not replace the multiplication with division or combine arithmetic operations.

The top and bottom pressures come from adjacent interfaces. Columns run from `istartcol` to `iendcol`, inclusive. Layers run from 1 to the second pressure dimension's upper bound minus 1. The pressure array has lower bounds of 1 and contiguous columns, as its original allocation specifies. An empty layer or column range writes no outputs.

## Interface and storage

`md2asm_openifs_get_layer_mass` uses the Arm application binary interface, the rules that callers and functions share. Registers x0, x1, x2 and x3 point to the Fortran class wrapper, INTEGER4 first column, INTEGER4 last column and output array descriptor. The class wrapper's first pointer addresses its data. Its first 88 bytes describe the pressure array.

A GNU Fortran descriptor stores its data pointer at byte 0, element offset at byte 8, first element stride at byte 40, first lower and upper bounds at bytes 48 and 56, second stride at byte 64, and second lower and upper bounds at bytes 72 and 80. Strides count FP64 elements. The output starts at its data pointer, with dummy indices starting at 1. Its zero first-stride metadata means a stride of 1, matching the original. Positive and negative output strides are supported when their addresses lie inside the caller's buffer.

The caller supplies disjoint pressure and output storage, valid column bounds, enough output cells and naturally aligned pointers. The routine reads only the selected pressure interfaces and writes only the selected mass cells. It uses caller-saved registers x0–x16 and d0–d2, leaves callee-saved registers unchanged, and neither uses a stack frame nor calls another function. Profiling hooks are outside this numerical interface.

## Output and acceptance

Each selected output cell contains its unmodified FP64 bits. Keep column-major storage and retain bytes outside the selected cells. Execute with floating-point control register FPCR equal to zero, using nearest-even rounding and gradual underflow. Reject every output-byte difference against the unchanged strict original.

A small verifier checks single and multiple columns, empty ranges, partial column ranges, one and many layers, output strides, unchanged inputs and buffer guards. Independent exact rational arithmetic checks P01 with the original two rounding points and the reciprocal's rounding. The 720 critical calls compare 516,384 complete owner bytes with zero differences and check 28,050 physical cells. Nonnegative mass and exact pressure-to-mass arithmetic provide physical checks. The paired preload separately passes all 720 calls, including 422,784 output-span bytes. The same-input paired forecast passed and this routine is included in the accepted count. Comparative timing is not yet available.

## Accepted forecast calls

The 2026-10-10 combined forecast on exclusive job 7240564, nid010555, CPU 16 with local memory binding passed 6,400 actual calls over 7,782,400 compared returned bytes, with zero differences. All ten saved forecast files match over 618,140 bytes. Earlier accepted verification is reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
