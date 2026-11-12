# Spline Coordinate And Polynomial Helpers

These six children implement the source arithmetic in `arpifs/module/suvfe_hlp.F90`. They convert a sampled local coordinate to a vertical coordinate, choose a sample position, and multiply, integrate, differentiate or evaluate a polynomial. A polynomial is a sum of coefficient times integer powers of a variable. A coefficient array stores the constant term first. Coordinates and the selected vertical polynomials are dimensionless. The selected spline setup uses orders two through four; integration and product arrays can have more coefficients.

## Raw Interfaces

Every scalar and raw array argument is an address under the Arm procedure call standard. Integer scalars are int32 values with four-byte alignment, and real scalars and arrays are FP64 values with eight-byte alignment. The caller owns mapped, correctly sized buffers and supplies disjoint inputs and outputs. No descriptor, class object, original module variable or original callable is consumed. The leaves use only caller-saved registers, preserve x18 and have no private stack, allocation or external call. Unsupported dimensions are caller errors; these arithmetic leaves do not validate them.

| Entry | Arguments in order | Result and bounds |
| --- | --- | --- |
| `md2asm_spline_coordinate_from_local` | minimum, maximum, local value | d0 returns `minimum+local*(maximum-minimum)`. All three scalars are finite. |
| `md2asm_spline_sample_position` | count, index, bounds[2] | d0 returns a sample between the explicit lower and upper bounds. `2<=count<=9`, `1<=index<=count`; bounds are finite and increasing. |
| `md2asm_spline_polynomial_evaluate` | count, coefficients[count], value | d0 returns the polynomial value. `2<=count<=9`; inputs are finite. |
| `md2asm_spline_polynomial_derivative` | count, coefficients[count], output_count, derivative[count-1] | Writes all output coefficients. `2<=count<=9`, output_count=count-1. |
| `md2asm_spline_polynomial_integral` | count, coefficients[count], constant, output_count, integral[count+1] | Writes the supplied constant then all integrated coefficients. `1<=count<=9`, output_count=count+1. |
| `md2asm_spline_polynomial_product` | first_count, first[first_count], second_count, second[second_count], output_count, product[output_count] | Writes every requested product coefficient, including positive zero beyond the product degree. Each input count is one through nine and output_count is one through 18. |

## Ordered Arithmetic

The coordinate conversion performs one subtraction, one multiplication and one addition. The sample calculation first divides `index-1` by `count-1`, then subtracts the explicit bounds, multiplies and adds the lower bound. No source rounded intermediate is replaced by a stored table.

Evaluation starts with the highest coefficient and works downwards, using one multiplication and one addition per coefficient. This is the same operation order as the source's reversed scratch array and synthetic division. Differentiation multiplies coefficient i by its integer power. Integration divides each coefficient by the next power after copying the constant unchanged. Integer-to-FP64 conversions are exact in the supported range. The product starts each coefficient at positive zero and accumulates valid products in increasing index of the first input, matching source convolution order. Each multiplication, addition, subtraction and division rounds separately. Fused operations, reassociation and approximate division are forbidden.

FPCR is zero, with round-to-nearest, ties to even and gradual underflow. Incoming FPSR bits remain set; the numerical operations may set more bits. No external call changes errno. Source diagnostics and profiling are excluded from this raw calculation scope. Separate unchanged source expressions form the Fortran control, with sample bounds made explicit only in its verification interface. Critical source comparisons cover actual knot-derived coordinates, spline coefficient magnitudes, cancellation, signed zeros, nonunit intervals, polynomial degree changes and complete output guards. Independent exact rational arithmetic checks polynomial identities and coordinate maps. Whole caller and forecast acceptance remain pending.
