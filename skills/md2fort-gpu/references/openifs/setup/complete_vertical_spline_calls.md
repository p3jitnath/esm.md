# Complete vertical spline calls on the GPU

A spline joins short polynomial pieces at positions called knots. These three calls build the knots, calculate the basis weights and form cubic coefficients for the vertical coordinate. Every coordinate, weight and coefficient is dimensionless. Each complete call runs on the GPU through directly written PTX assembly. The physical inputs and the accepted numerical methods remain unchanged.

## Original interfaces

The application binary interface, or ABI, defines argument registers and the registers that a procedure must preserve. Each Arm entry receives the original addresses in registers x0 onwards. An owner is the complete allocated buffer that holds a control or an array. Controls use four aligned bytes; numerical values use eight aligned bytes. All caller owners remain mapped and disjoint under the original contract.

| Entry | Addresses in original order | Accepted shape | Scientific contract |
| --- | --- | --- | --- |
| `md2asm_vertical_spline_basis` | Order, value, basis count, knots, weights | Order 2–4, basis count from order to 24 | [Basis weights](../../../../md2fort/references/openifs/setup/spline_basis_contract.md) |
| `md2asm_vertical_spline_knots` | Order, basis count, level count, coordinates, knots | Order 2–4, both counts from order to 24, basis count minus order at most level count | [Knot positions](../../../../md2fort/references/openifs/setup/spline_knot_contract.md) |
| `md2asm_spline_piece_coefficients` | Control record, minimum interval, bounds, transform, knots, pieces, centres | Order 4, basis count 21–24, search and verbose controls zero | [Cubic coefficients](../../../../md2fort/references/openifs/setup/spline_piece_coefficient_contract.md) |

Basis inputs retain finite values and finite nondecreasing knots from zero to one, including the original endpoint and repeated-knot guards. The knot call retains finite level coordinates that strictly increase from zero to one. The coefficient call retains bounds of positive zero and one, a finite nonnegative minimum interval, and the original sorted, clamped knots, transform and finite-intermediate conditions. Negative zero remains accepted for the minimum interval.

Return zero commits the complete declared output. Return two rejects before changing the caller's output. The coefficient call also retains return three, which preserves the original partial coefficient writes and leaves centres unchanged after a basis-child rejection. These source returns remain separate from transport errors.

## GPU storage

One block with one thread performs each complete call, with zero dynamic shared memory. The Arm binding performs integer guards, copies and the GPU launch. It commits only the original output extent and retains the original ABI, x18, floating-point control and C error indicator.

Each launch receives a 16-byte vector of input and output addresses and a 64-byte context. The context uses revision one, sticky floating-point flags at byte 8, and a record address and capacity at bytes 48 and 56. Its 64-byte record stores input and output capacities at 0 and 8, zero mode and reserved words at 16–31, and two private counter address/capacity pairs at 32/40 and 48/56. Both counters occupy eight bytes and stay zero. Public mathematical-work counters remain unchanged.

The seven private owners are input, output, argument vector, context, record and the two counters. They must be non-null, aligned to eight bytes, bounded without address wrap and mutually disjoint. Every owner, launch shape, revision and reserved field is checked before numerical writes.

| Call | Private input | Private output | Arm frame and offsets |
| --- | --- | --- | --- |
| Basis | 240 bytes with order at 0, count at 4, value at 8 and 28 knots at 16 | 224 bytes with source status at 0 and 24 weights at 32 | 1024-byte frame, input 256, output 512, context 768, record 832, vector 896, counters 912/920 |
| Knots | 208 bytes with order, basis count and level count at 0/4/8, zero at 12 and 24 coordinates at 16 | 256 bytes with source status at 0 and 28 knots at 32 | 1024-byte frame, input 256, output 512, context 768, record 832, vector 896, counters 912/920 |
| Coefficients | 400 bytes with controls at 0, minimum interval at 16, bounds at 24, transform at 40, 28 knots at 168 and zero padding at 392 | 3296 bytes with source status at 0, 384 coefficients at 32 and 24 centres at 3104 | 4352-byte frame, input 320, output 768, context 4096, record 4160, vector 4224, counters 4240/4248 |

Unused input words and output words at 8, 16 and 24 are zero. Only the declared counts are copied to the caller. Basis transport errors are 27100 for launch or revision, 27101 for bounds or overlap and 27102 for mode or reserved data. Knots and coefficients use the corresponding 27200–27202 codes.

## Arithmetic and dependencies

FP64 uses 64 bits for each floating-point value. The Arm control register must be zero, which selects nearest-even rounding and gradual underflow. Each addition, subtraction, multiplication and division calls the existing qualified FP64 value/status helper and consumes the complete return immediately. Incoming flags remain set and new flags are added. Signed zeros and every original rounding point remain unchanged.

The basis call retains its increasing-order recurrence and increasing weight index. It evaluates a term only when the corresponding old weight is nonzero, and reads the old right neighbour before overwriting a weight. The original subtraction and endpoint test execute after the recurrence.

The knot call first writes the repeated boundary zeros and ones. It then retains the original percentile calculation and increasing interior-knot order. Integer conversions to FP64 are exact because their inputs are at most 25. The index conversion still truncates toward zero and adds an inexact flag exactly when the original conversion would. Endpoint copies retain their original bounds.

The coefficient call forms four sample positions, visits intervals and samples in source order, and calls a private copy of the qualified complete basis calculation. Each coefficient starts at positive zero and accumulates four separately rounded products in increasing sample order. Each centre adds three knots in order and divides by three. No product and sum are fused or reordered.

Link the three host sources and three PTX sources once. The only device dependencies are the existing qualified addition, subtraction, multiplication and division value/status functions. The coefficient entry contains its private basis body, so it does not depend on a second public kernel launch. The [shared CUDA runtime](../cuda_runtime.md) owns loading, launches and completion.

## Accepted checks and limits

The complete basis passes 245 genuine Fortran cases, the knot call passes 11 and the coefficient call passes 11, with exact owners, source returns and immediate status. The original independent mathematical checks remain valid. Focused controls cover the changed packed boundaries, read-only inputs, untouched regions, rejection paths and register obligations. Native instruction inspection confirms complete numerical return consumption and the frozen arithmetic.

A combined fixture using all three changes matches 43,984 archived CPU bytes, including all vertical payloads, the complete Geometry record, cloud-pressure output, guards and status. The knot change separately matches the complete 1,156,096-byte geometry fixture. These results qualify the components. Complete forecast agreement and quiet-node performance remain separate gates. Source versions, hashes, build commands and detailed records remain local.
