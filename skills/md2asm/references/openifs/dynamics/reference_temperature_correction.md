# Reference Temperature Correction

This stage prepares the temperature correction used by the vertical transport equations. It follows the original SUDYN controls, the three SUALDYN allocations and the complete SURCORDI calculation. The first NAMDYN and NAMDYNA groups must already have been admitted as empty, so the selected source defaults do not replace a user override.

## Physical Meaning and Source

A hybrid pressure coordinate writes pressure as $`p=A+Bp_s`$, where $`A`$ is in pascals, $`B`$ is dimensionless and $`p_s`$ is surface pressure in pascals. The existing vertical setup owns the interface coefficients VAH and VBH. SURCORDI uses their arithmetic means at layer centres and the interface values at layer boundaries.

```math
\alpha=-\frac{RDTDZ1\,RD}{RG},\qquad T(p)=RTSUR\left(\frac{p}{VP00}\right)^\alpha.
```

Here RD is the gas constant for dry air in J/(kg K), RG is gravitational acceleration in m/s², RDTDZ1 is the temperature gradient in K/m, RTSUR is reference surface temperature in kelvins and VP00 is reference surface pressure in pascals. The correction is the reference temperature response to a change in the logarithm of surface pressure.

```math
\frac{\partial T}{\partial\ln p_s}=B\,\alpha\,T\,\frac{VP00}{p},\qquad p_s=VP00.
```

RCORDIF stores this response at layer centres, and RCORDIH stores it at layer interfaces. RCORDIH(0) is positive zero. RCORDIT retains the centre response only when the reference temperature is strictly greater than RTTROP, the tropopause temperature in kelvins. Otherwise it is positive zero. For one level, the original source writes only RCORDIT(1)=1 and leaves both other arrays unchanged.

The controls come from `arpifs/setup/sudyn.F90` lines 655, 843–845 and 1313–1326. The selected semi-Lagrangian route sets RCMSLP0, RINTOPT and RRINTOPT to one. The allocation order is RCORDIT, RCORDIH and RCORDIF in `arpifs/setup/sualdyn.F90` lines 129–134. The complete computational block is in `arpifs/setup/surcordi.F90`, called from SUDYN after its semi-implicit setup. Each addition, multiplication and division retains its original FP64 rounding point. Powers use the already qualified `md2asm_pow_original_rounding_candidate` assembly entry with base and exponent in d0 and d1.

## Interfaces and Storage

All interfaces return a 32-bit status in w0. Zero means success, one means allocation failure and two means an unsupported input. Capacities are bytes. The caller owns the mapped records and their live array storage and must retain them until release. Geometry and MODEL must be aligned to eight bytes, disjoint, non-wrapping and at least 17,096 and 4,275,088 bytes. The supported number of vertical levels is 1 through 255. The Arm floating-point control register must be zero.

| Assembly entry | Arguments in x0 onwards | Purpose |
| --- | --- | --- |
| `md2asm_initialize_temperature_correction_controls` | MODEL, MODEL capacity, platform16 | Write the three source controls after namelist admission. |
| `md2asm_allocate_reference_temperature_correction` | Geometry, Geometry capacity, MODEL, MODEL capacity | Allocate the three source owners, then publish all descriptors together. |
| `md2asm_initialize_reference_temperature_correction` | Geometry, Geometry capacity, MODEL, MODEL capacity, constants48, constants capacity | Perform the complete source temperature calculation. |
| `md2asm_release_reference_temperature_correction` | MODEL, MODEL capacity | Release the owners in reverse order and clear their base pointers. |

The aligned platform16 input has four 32-bit words for NCONF, LECMWF, LR2D and LR3D with admitted values 1, 1, 0 and 1. The live TDYNA LSLAG flag must be true. The aligned constants48 view contains six FP64 words in the order RD, RG, VP00, RDTDZ1, RTSUR and RTTROP. Production packs them from its named owned constant producers, without copying captured scientific data. Constants must be finite, and all except RDTDZ1 must be positive.

| MODEL member | Byte offset | Bounds or value |
| --- | --- | --- |
| RCORDIT | 1566736 | Unit-stride FP64 owner with indices 1 through n. |
| RCORDIH | 1566800 | Unit-stride FP64 owner with indices 0 through n. |
| RCORDIF | 1566864 | Unit-stride FP64 owner with indices 1 through n. |
| RCMSLP0 | 1569048 | FP64 one on the admitted source route. |
| RINTOPT | 1569104 | FP64 one after the admitted source default. |
| RRINTOPT | 1569112 | FP64 reciprocal of RINTOPT. |

The descriptors use the queried GNU Fortran rank-one layout, an eight-byte element and span, unit stride and the stated lower and upper bounds. Allocation requires all three base pointers to be null. Ordinary malloc preserves the source-unwritten allocation payload. A failed allocation frees earlier temporary owners and leaves MODEL unchanged. Release is safe after partial setup and when repeated. The caller must pass owners created by this allocator when releasing them.

For more than one level, Geometry points to its live vertical-coordinate record at byte 3240. That record owns VBH at byte 64 and VAH at byte 128, each a contiguous FP64 array with indices zero through n. Coefficients must be finite and nonnegative with positive zero, and each consumed interface after the top must have a positive A or B coefficient. The caller supplies the mapped owner extents guaranteed by its earlier constructors. For one level the numerical entry does not read either hybrid-coordinate owner.

The control entry is a leaf. Allocation uses a 112-byte frame, calculation uses a 240-byte frame and release uses a 48-byte frame. Every entry preserves x18, the required callee-saved integer registers, the low 64 bits of d8 through d15 and a 16-byte aligned stack. The only external production calls are malloc, free and the accepted direct assembly power entry. No original OpenIFS routine supplies this stage.

## Accepted Checks and Limits

The unchanged typed source fragments and the complete original SURCORDI computational block pass at 1, 3, 19 and 255 levels. The 19-level case uses the retained actual hybrid-coordinate inputs. Complete source and native records agree across 51,301,056 MODEL bytes and 13,408 owner bytes, including nonzero preimages in the source-unwritten one-level owners. The native ABI mask is zero, and immediate FPCR, FPSR and errno agree with the source after each stage. Release and repeated release pass.

An independent check derives the temperature response with 96-digit decimal arithmetic. It checks 837 physical and one-level storage relations, including warm and cold layers. Its largest residual on these profiles is below 0.0013 of the declared roundoff-scaled tolerance. Three additional source comparisons cover the strict tropopause tie and its two adjacent FP64 values. All three allocation-failure positions roll back correctly, fifteen critical invalid inputs refuse without mutation and five consumed input or output arrays end immediately before an unreadable page.

The true selected startup constants also pass a separate 19-level source and physical check with RD = 287.0596736665907 J/(kg K), RG = 9.80665 m/s², VP00 = 101325 Pa, RDTDZ1 = −0.0065 K/m, RTSUR = 288.15 K and RTTROP = 216.64999999999998 K. These values come from the retained qualified standard-atmosphere producer inputs and outputs. This additional check compares 12,825,264 MODEL bytes and 928 owner bytes, with exact immediate status and 58 independent temperature-response relations. The earlier generic profiles use VP00 = 100000 Pa, so their input scope is distinct. Production always reads the named live constant aliases.

The original source states that this arithmetic-mean correction is fully consistent with its conventional vertical choice with LVERTFE false, NDLNPR zero and LAPRXPK true. It is not completely consistent with the other choices, including the selected finite-element route. This component preserves that original approximation and its limit. The Fortran reference and verification tools remain local. Full saved-output agreement is a separate forecast gate owned by the parent executable.
