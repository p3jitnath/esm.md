# Atmospheric And Surface Planck Contracts

Revision 1.0 implements [P01 and P02](../../../../../formulations/openifs/physics/tabulated_planck_emission.md) from `radiation_ifs_rrtm::planck_function_atmos` and `radiation_ifs_rrtm::planck_function_surf` in `radiation/module/radiation_ifs_rrtm.F90`. A shared direct assembly body interpolates each band once for each column and face, then applies its spectral fractions. The unchanged global tables are model inputs, and the assembly supplies every interpolation and output stage.

## Ordered Arithmetic And Model Limits

RN means one FP64 operation rounded to nearest, with ties to even. The source folds `RN(RN(2*asin(1))*10000)` into `0x40deadfb4c5d390c`, with no run-time inverse-sine call. For each band, form `factor = RN(zfluxfac*delwave(b))`.

For 160 K through values below 339 K, take the one-based index `k = INT(RN(T-159))` and fraction `f = RN(T-INT(T))`, where INT truncates toward zero. At or above 339 K, set `k=180` and `f=RN(T-339)`. Below 160 K, set `k=1` and `f=+0`. Higher temperatures use linear extrapolation from the 339 K and 340 K nodes, while temperatures below 160 K use the 160 K emission. These are table approximations outside the stored range.

Read `L=totplnk(k,b)` and `H=totplnk(k+1,b)`, then store `RN(factor*RN(L+RN(f*RN(H-L))))`. Store each spectral output as `RN(band_value*PFRAC)`. Require FPCR zero, gradual underflow, signed zeros and finite supported inputs. Every operation rounds separately. Fused arithmetic, reassociation and approximate instructions are forbidden.

The surface uses the selected column's temperature and fractions. The atmosphere uses the final `nlev+1` temperature faces. With zero-based output face `j`, select one-based PFRAC layer `nlev+1-max(j,1)`. Thus the first two faces use layer `nlev`, followed by reversed remaining layers. Solver code 3 uses reordered band and point maps. Other codes retain ordinary spectral order.

## Arm Interface And Storage

The atmospheric ABI supplies INTEGER4 pointers for `nlev`, `istartcol` and `iendcol` in `x0` through `x2`, followed by configuration, thermodynamics, contiguous PFRAC and contiguous output in `x3` through `x6`. The surface ABI supplies start and end pointers in `x0` and `x1`, followed by configuration, a rank-one temperature descriptor, PFRAC and output in `x2` through `x5`. FP64 cells have eight aligned bytes, and owners, objects and scalar inputs are disjoint.

The frozen GNU configuration has 20040 bytes. Longwave solver code, point count and band count are at bytes 624, 20000 and 20008. Ordinary band, reordered point and reordered band descriptors begin at bytes 10608, 10736 and 10864. These INTEGER4 maps are contiguous and one-based. Band counts are from one to 16, and point counts are from one to 140. Empty column ranges produce no writes.

The 264-byte thermodynamics object stores its temperature descriptor at byte 88. Its allocated rank-two array is contiguous, with lower bounds one, column stride one and level stride equal to its full column count. Descriptors store the data pointer at byte zero, strides at bytes 40 and 64, and the second upper bound at byte 80. The caller supplies `nlev>=1`, enough faces and valid columns. Surface descriptors support signed and padded strides, with zero treated as one.

PFRAC uses Fortran order, with column first, 140 points second and model layer third when present. Its first cell belongs to `istartcol`. Output has point first, face second when present and selected column last. Compare every byte in that declared owner. Descriptors, tables, inputs and neighbours remain unchanged.

The aligned 352-byte frame includes 128 bytes for 16 band values. The body restores `x19` through `x30`, leaves callee-saved floating-point registers untouched and makes no external call. Original profiling runs in the local paired wrapper on a cloned owner, outside canonical output. Link against the unchanged model library for its two read-only global tables.

## Acceptance

Require zero differing output-owner bytes against the strict original. A separate higher-precision calculation uses `(1-f)*L+f*H`, multiplies by the frozen band factor and applies the fractions. Check positive and increasing tables, nonnegative emission and conservation of band energy. This verifies the changed interpolation and partition, without claiming a new validation of the historical table's absolute physical accuracy.

Protect endpoints and adjacent FP64 temperatures, the cold cap, high-temperature extrapolation, reordered points, atmospheric slices, signed surface descriptors, empty ranges and bounds. Configuration, maps, temperatures and fractions are read-only during numerical calls. Critical acceptance is separate from live forecast acceptance. Actual records remain local under `.agents/weather24h/two-stream/` and `.runtime/openifs/weather24h-two-stream/`.

## Accepted Forecast Calls

The 2026-10-10 combined forecast passed planck_function_atmos 6,400 calls, planck_function_surf 6,400 calls over 1,204,224,000 complete returned owner bytes, with zero differences. All ten saved files match over 618,140 bytes. The run used exclusive job 7240564 on nid010555, CPU 16 and local memory binding. Accepted child checks and unchanged arithmetic routes are reused. Whole-forecast independent physics, whole-process byte identity and comparative speed remain unproved.
