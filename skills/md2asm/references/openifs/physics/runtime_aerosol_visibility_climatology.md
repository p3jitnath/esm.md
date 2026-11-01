# Runtime aerosol and ozone climatology for visibility

This [direct AArch64 calculation](../../../../../src/openifs/physics/runtime_aerosol_visibility_climatology.S) extends the live column and level counts of original `RADACA`. It uses the prescribed aerosol columns and cumulative profiles, interpolates their horizontal climate tables, and forms layer aerosol masses and ozone amounts. It shares the [aerosol and ozone physics](../../../../../formulations/openifs/radiation/aerosol_and_ozone_layer_amounts.md); this entry returns aerosol layer mass before division by air-layer mass. The existing fixed-size entry remains available.

Let $`P`$ be the allocated column count and $`L`$ the level count. The runtime entry `md2asm_runtime_aerosol_visibility_climatology` admits $`1\le P\le128`$ and $`1\le L\le137`$. First must be 1, and last is from 1 through $`P`$. A partial final block is supported. The original Legendre helper writes its temporary basis from the first column, while later source reads use the absolute column index. This source limitation excludes a shifted first column from the accepted range. Empty intervals are also outside this entry's range.

The application binary interface, or ABI, preserves the first 23 original address arguments. The first eight use `x0` through `x7`. Later addresses use successive eight-byte incoming stack words, starting at byte 0. Argument 24 is the runtime context at incoming stack byte 120. FP64 means a 64-bit floating-point value. Array shapes below have their column index varying fastest.

| Arguments | Original names and meaning | Complete storage |
| --- | --- | --- |
| 1–3 | `YDEAERD`, `YDERAD`, `YDRIP`: typed coefficient records | 4232, 2040 and 175976 bytes |
| 4–7 | `KIDIA`, `KFDIA`, `KLON`, `KLEV`: first, last, $`P`$ and $`L`$ | Four int32 values, four bytes each |
| 8 | `PAPRS`: boundary pressure, pascals; level bounds 0 through $`L`$ | $`8P(L+1)`$ bytes |
| 9–12 | `PGELAM`, `PSIN`, `PCLON`, `PSLON`: longitude in radians and dimensionless sine/cosine values | $`8P`$ bytes each |
| 13 | `PTH`: boundary temperature, kelvin; $`L+1`$ rows | $`8P(L+1)`$ bytes |
| 14 | `PAER`: six dimensionless optical-depth fields, shape $`(P,6,L)`$ | $`48PL`$ bytes |
| 15 | `PAERO`: twelve aerosol layer masses, kilograms per square metre, shape $`(P,L,12)`$ | $`96PL`$ bytes |
| 16 | `POZON`: pressure-weighted ozone layer amount, pascals, shape $`(P,L)`$ | $`8PL`$ bytes |
| 17 | `PAERSIG`: original surface diagnostic; its physical unit remains unclosed | $`8P`$ bytes |
| 18–23 | `PODTO`, `PODSS`, `PODDU`, `PODOM`, `PODBC`, `PODSU`: dimensionless total and species column optical depths | $`8P`$ bytes each |
| 24 | Read-only runtime context | 16 bytes |

The context contains the physical-constant owner address and a profiling-policy address. The physical owner has 520 bytes, a ready int32 equal to one at byte 512, the frozen pi word at byte 0, and positive finite gravity at byte 112. The 16-byte policy contains a pointer to a zero int32 and a reserved zero word. Scalar addresses and the flag align to four bytes. All other addresses align to eight bytes. Every complete owner remains valid until return, and every span must avoid address overflow. The ten output spans must be mutually disjoint and disjoint from every consumed input, record, descriptor payload, context and control owner. Read-only inputs may share storage.

Each of the nine vertical profiles contains $`L+1`$ FP64 values. The last level reads the next boundary value, so 20 values cover only the older 19-level shape. GNU Fortran descriptors must describe contiguous rank-one FP64 storage with bounds 1 through $`L+1`$, unit stride and offset minus one.

| Record | Profile names and descriptor byte offsets |
| --- | --- |
| `YDEAERD` | `CVDAES` 0, `CVDAEL` 64, `CVDAEU` 128, `CVDAED` 192 |
| `YDERAD` | `CVDAESS` 1480, `CVDAEDU` 1544, `CVDAEOM` 1608, `CVDAEBC` 1672, `CVDAESU` 1736 |

Eleven current climate tables retain their physical 120-by-61 grid. Their descriptors require rank-two FP64 storage, one-based bounds, strides 1 and 120, and offset minus 121. The selected `YDERAD` controls are `NAERMACC` equal to 1, dimensions 61 latitudes, 120 longitudes and 12 species, `LHVOLCA` false, `LNEWAER` true and `LAERADJDU` false. Original-type metadata establishes these positions and names; a saved field label alone is insufficient.

Inputs use the original unrotated, unstretched grid. Active longitudes are finite, from zero up to but excluding twice pi; latitude sine and longitude sine/cosine are finite and within minus one through one. Boundary pressures are nonnegative and strictly increasing. Boundary temperatures are positive and finite. The profile exponent is finite, from zero through 64, and the optical-depth floor is finite and nonnegative. Coefficients and climate tables retain their declared physical-input domain.

The ordered interpolation, harmonic sums, pressure threshold of 999 Pa, integer powers, divisions and square roots remain unchanged. The complete twelve-species mass span is reset to positive zero, including inactive columns, as the source requires. Other outputs preserve inactive words. All level indices and workspace sizes come from live dimensions. The source surface equation is preserved without assigning it an independently established inverse-length unit. The later CLIMAER aerosol conversion has a separate dimensional limitation.

The floating-point control register must be zero, with nearest-even rounding, gradual underflow and signed zeros preserved. Fused multiply-add, contraction, reassociation and approximate arithmetic remain forbidden. The routine uses a 6144-byte frame plus $`512P`$ bytes of private column work, at most 71,680 bytes before called-service frames. It allocates no heap storage. Accepted direct assembly provides the Legendre basis and original-rounding sine and power services. Success returns zero; admission refusal returns two before an output write. The entry preserves `x18`, saved registers, stack alignment and the control register, while retaining natural floating-point flags, errno and three child-call counters. Original Fortran has no defined integer return; its raw state is recorded separately.

Five pairs compared 479,248 complete output bytes with zero differences: 17 columns and 137 levels with last 16, 9 columns and 5 levels, the earlier 24-by-19 shape, one column and one level, and 128 columns and 2 levels with last 127. Complete borrowed records, inputs, payloads, controls, inactive values and buffer guards were also checked. Twenty-seven admission refusals preserved complete known states. Immediate native status, ABI, floating-point and errno checks passed, and actual original, native and mathematical call targets were qualified before entry.

Saved outputs passed 122,616 independent relations for mass, ozone, optical-depth floors, column integrals, profiles and source surface diagnostics. The verifier uses a separate 120-digit Legendre polynomial and balance calculation. It preserves an exact constant-cell interpolation identity and leaves the declared error bands unchanged. No solver replay was needed for that verifier correction. Independent result review and exact controller, process and group closure passed without signals.

This interface and range extension adds no original-routine body to the completion count. The controlled component profiles do not establish operational setup ownership. The production profile connection, CLIMAER parent, active visibility branch and full forecast require their own joined acceptance. Detailed inputs, source versions, failed verifier attempts, raw states and exact binding records remain local.
