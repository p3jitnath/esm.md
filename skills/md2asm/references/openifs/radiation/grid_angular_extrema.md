# Runtime Grid Angular Extrema

This SUECRAD component converts complete latitude and longitude fields from radians to degrees and finds their limits. Radiation setup uses these limits to choose its surrounding interpolation region, called a halo. This component returns four angular limits. The later source calculation must still turn them into integer halo widths.

The direct [assembly](../../../../../src/openifs/radiation/runtime_grid_angular_extrema.S) retains the source FP64 operations for every point

```math
\phi_d=((\phi/\pi)\,2)\,90,\qquad
\lambda_d=((\lambda-\pi)/\pi)\,180+180.
```

Each operation rounds separately. The output contains minimum latitude, maximum latitude, minimum longitude and maximum longitude, in degrees. Equal values retain the first encountered value, including its signed-zero bit. Strict comparisons implement that source rule.

The ABI uses x0,x1 for the complete latitude and longitude FP64 arrays, x2 for their common point count, x3 for the live 520-byte physical record, x4 for its capacity, x5 for the 32-byte output and x6 for output capacity. All inputs are mapped, stable, nonwrapping and eight-byte aligned. Output is disjoint from both arrays and the physical record. Count ranges from 1 through 268435456. RPI at physical-record offset 0 supplies pi and lies in [3,4). Latitude is finite within plus or minus RPI/2, and longitude is finite within 0 through 2RPI. FPCR must be zero.

All input values and output bounds are checked before publication. Return 0 means success and 2 means an atomic refusal. The leaf uses caller-saved integer and FP registers, preserves x18 and all required saved registers, and has no stack, allocation, external call or original OpenIFS dependency. Numerical flags and errno retain their natural values.

The same original selected-source binary and corrected direct object agree on 192 output bytes and 144 raw-state bytes across six cases. These cover the complete 1,649,920-point model grid, 800-row and 32-row radiation regions, angular boundaries and both mixed signed-zero orders. Each route passes 3,627,878 finite-input and high-precision endpoint relations, including 24 independent 90-digit extrema checks. Six nominal native register checks, 11 atomic refusals, borrowed-input preservation and guards pass. The declared incoming state returns natural FPCR 0, FPSR 24 and errno 777.

Complete model coordinate owners were sought at their exact offsets in accepted saved Geometry streams. Radiation inputs reuse accepted coordinate outputs. No upstream producer or saved source bank is replayed. Production must bind live coordinate and physical owners. Halo-width rounding, SUECRAD, RADDRV and the full operational forecast remain separate.
