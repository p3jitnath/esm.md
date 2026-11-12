# Surface Carbon Exchange Contract

The physical input is [Surface Carbon Flux](../../../../../formulations/openifs/surface/surface_carbon_flux.md), revision 1. The complete SRFCOTWO leaf combines canopy uptake, soil respiration, methane, cell averages and daily vegetation records. It retains the original 39 arguments and all ten returned arrays. Its primary body is direct AArch64 assembly, with no numerical Fortran stage or calculation supplied by the driver.

## Frozen Calculation

Two vegetation classes use original tiles 4 and 6, with shaded snow on tile 7. Their class map is KVTTL(4) = 1 and KVTTL(6) = 2. The supplied configuration has four soil levels and two vegetation classes. Each output cell follows the original source dependencies.

Snow fraction comes from the shaded high-vegetation tile when high cover is positive, otherwise from the exposed snow tile when low cover is positive. Zero vegetation gives zero snow fraction. Clamp this fraction to the interval zero to one. The low canopy uses its uncovered fraction. The high canopy adds its shaded-snow and uncovered contributions in the source order. Gross uptake is clipped at zero, while the separate net input retains its original value.

Root water is the tile-major, then level-major sum of PWLIQ times the selected root fraction. It has no units. The water factor is the smaller of one and root water times inverse field capacity. With LEVGEN enabled, a positive soil index replaces the inverse capacity from its table. Soil index zero retains the earlier row's inverse capacity, which starts at zero. With LEVGEN disabled, every row uses the scalar capacity.

Mean temperature uses only the first two soil layers, with a zero initial sum, two additions and one division. Subtract the supplied freezing reference RTT. Let $`T`$ be this value in degrees Celsius. The separately rounded source expression is

```math
Q_{10}=\max\left(2.5665-0.05308T+0.00238TT-0.00004TTT,\ 0.0001\right).
```

Products retain their written left-to-right dependencies. The snow factor is $`1-c_s(1-\exp[-2\max(d_s,0)])`$, where $`c_s`$ is the clipped snow fraction and $`d_s`$ is snow depth in metres. Respiration multiplies the water factor by the selected reference rate, then by the temperature power, then by the snow factor. A separately calculated reference rate without the temperature power supplies methane.

Methane uses the supplied top-layer temperature, wetland fraction and latitude band, with thresholds at −25 and 25 degrees. Its original unqualified literal 273.15 first rounds to binary32, then converts to FP64. The exact threshold is 273.149993896484375 kelvin. The original zero-factor branches remain explicit.

Each ecosystem rate adds dark and soil respiration. The class carbon flux adds this rate to negative gross uptake. Cell averages begin at positive zero and add class 1 before class 2. Original negative products are retained for respiration and methane diagnostics. Daily assimilation adds net rate times the supplied time interval. The maximum record uses air density from pressure, air temperature and specific humidity, and becomes zero for zero cover or zero leaf area.

The scalar EXP boundary is the unchanged accepted Arm elementary-function library from [Pressure Mathematics](../pressure_math.md). POWER uses the unique original-compatible boundary from [Power Mathematics](../power_math.md). Their existing source and rounding proofs are reused. They supply elementary functions, and neither boundary supplies an omitted forecast stage. No generic direct EXP assembly is claimed.

## Interface And Storage

The application binary interface, or ABI, defines argument placement and preserved registers. AArch64 places the first eight pointers in x0 to x7 and the remaining 31 pointers in consecutive eight-byte stack slots. The body uses a 2,048-byte stack frame aligned to 16 bytes, preserves x19 to x29 and the return address, and saves platform register x18 around each external mathematical helper. It uses d0 to d3, leaving preserved floating-point registers unchanged. FPCR must be zero, and fresh FPSR and errno must equal the original result from the same entry state.

Let K be the supplied row count, L = 4 the soil-level count and J the tile count. Rows vary fastest. Supported K is 1 to 1,024 and J is 8 to 32. The active vegetation count remains two, while the supplied cover, leaf and return arrays may retain a third unused class. Each supported class extent is two or three, independently of the active count. Diagnostic planes use their supplied third stride, which is K times the diagnostic class extent. A requested interval can be empty. Ordinary GNU descriptors retain their complete bytes and contiguous strides, while their base address identifies the first supplied element. Integer values occupy four bytes and FP64 values occupy eight bytes. Descriptor owners and FP64 arrays need eight-byte alignment, while integer arrays need four-byte alignment.

| Arguments | Original Names | Storage And Meaning |
| --- | --- | --- |
| 0 to 4 | KIDIA, KFDIA, KLON, KLEVS, KTILES | Five four-byte scalars |
| 5 | KVEG | K by J integer vegetation types |
| 6 to 8 | KVTTL, KCO2TYP, KSOTY | Three rank-one integer descriptors and their complete arrays |
| 9 | PTSTEP | One FP64 time interval in seconds |
| 10 to 15 | PTMLEV, PQMLEV, PAPHMS, PCVT, PFRTI, PLAIVT | Three K-element arrays, K by 2 or 3 cover, K by J tile fraction and K by 2 or 3 leaf area |
| 16 | PWLIQ | K by 4 by J liquid-water values, supplied directly |
| 17 and 18 | PWSOIL, PTSOIL | K by 4 arrays, with PWSOIL unused and only the first two temperature layers consumed |
| 19 to 21 | PDSN, PFWET, PLAT | K-element snow depth, wetland fraction and latitude arrays |
| 22 to 24 | PANTI, PAGTI, PRDTI | K by J net uptake, gross uptake and dark respiration |
| 25 to 28 | YDCST, YDVEG, YDSOIL, YDAGS | Complete 128-byte, 776-byte, 2,416-byte and 2,344-byte parameter records |
| 29 and 30 | PANDAYVT, PANFMVT | Two updated K by 2 or 3 records, with only the first two classes changed |
| 31 to 37 | PAG, PRD, PAN, PRSOIL_STR, PRECO, PCO2FLUX, PCH4FLUX | Seven returned K-element flux arrays |
| 38 | PDHCO2S | K by 2 or 3 by at least 6 diagnostic planes, with only the first two classes in the first six planes changed |

The complete record layout comes from the frozen original modules. Four parameter arrays have fixed qualified bounds and offsets. A descriptor offset converts declared indices into the location of the stored value.

| Parameter | Record Offset | Bounds | Descriptor Offset | Complete Bytes |
| --- | --- | --- | --- | --- |
| RVROOTSA | TVEG + 136 | 1 to 4 by 0 to 20 | −1 | 672 |
| RVR0VT | TAGS + 2,128 | 0 to 20 by 1 to 2 | −21 | 336 |
| RVCH4QVT | TAGS + 2,216 | 0 to 20 | 0 | 168 |
| RWCAPM | TSOIL + 944 | 0 to 7 | 0 | 64 when LEVGEN is enabled |

Selected vegetation types are 0 to 20, and selected soil types are 0 to 7. Consumed physical inputs must be finite. Root and liquid-water fractions are between zero and one. Cover fractions are between zero and one and their total is at most one within the declared 64-epsilon input allowance. Selected capacities are positive, carbon parameters are nonnegative, and consumed soil temperatures are 150 to 400 kelvin. Unconsumed words, including unused parameter entries and the last two soil-temperature layers, retain their supplied bits.

SURFEXCDRIVER_CTL allocates ZCVT and ZLAIVT with three columns. VDFMAIN supplies the separate KVTYPES extent for the updated records and diagnostic classes. The complete owners include that supplied storage. Every unused third class and extra diagnostic plane retains its original bits. The input values of those unused classes are not interpreted.

All output arrays are disjoint from input owners and other output owners. Read-only input aliases are retained in the comparison shadow. Unsupported descriptors, source indices and selected shapes stop before native owner writes. The numerical body does not reinterpret unrelated record fields.

## Checks And Limits

The original source passed independent expanded-precision checks before emission. The isolated corpus covers canopy and snow branches, clipping, dry and frozen methane, fixed and varying capacity, the warm Q10 floor, daily records, latitude and photosynthetic pathways, full and partial forecast shapes, empty work and one column. Its first native comparison covered 38 protected placements and 59,248 returned bytes with zero differences. The unchanged numerical body reuses these proofs.

Focused completion checks cover helper-register preservation with a distinct nonzero x18 value, unused table values, soil-index-zero carry, the exact methane threshold, complete descriptor offsets and unsafe selected bounds. Thirty shared-owner invalid-input checks stop before any owner byte changes. The versioned caller correction covers extra input and output classes, the diagnostic third stride, partial work, one row and empty work. Twenty-five protected original/native/paired calls compare 70,840 complete returned bytes with zero differences and 7,905 independent relations. Its floating-point instruction and operand sequence is identical to the earlier body. Only integer layout guards and diagnostic addressing changed. A separate protected case uses the genuine captured carbon parameter tables in a synthetic 24-row field state. It qualifies those parameter values without claiming a complete genuine SRFCOTWO input packet.

Independent checks evaluate the canopy, water and snow factors, respiration and methane laws, cell flux balance, signs and daily records. The declared budget is 256 epsilon times the absolute uncancelled scale, with the predeclared Q10 power condition factor, plus 256 times the smallest positive FP64 value. This condition factor accounts for the sensitivity of a power to its temperature polynomial. No acceptance budget was increased during assembly development.

The live observer compares every complete returned and input owner on each call, including inactive rows, unused diagnostic planes, signed zeros and NaN payloads. It checks consumed domains and finite active returns every time. Independent 113-bit physical calculations run once per newly observed consumed branch and supported shape. It returns the native outputs and restores the native status. Source-shadow calls are recorded separately and must not change the native counter.

The coarse forecast passes 2,150 complete native calls and 9,494,400 returned bytes with zero differences. Its independent checks pass 411,680 physical relations across 554 distinct branch shapes. All ten saved files match across 618,140 bytes. The run uses exclusive allocation 7259755 on nid010824. Whole-forecast physics, autonomous execution and comparative speed remain unproved.
