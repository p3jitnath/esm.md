# Snow-Density Solver Contract

This contract covers the complete original SRFSN_RSN_MOD::SRFSN_RSN calculation for [snow density](../../../../../formulations/openifs/surface/snow_density.md). It updates each layer through snowfall, pressure, changes in ice crystals, retained water and wind. The physical inputs are fixed before direct assembly generation.

## Complete Update and Arithmetic

All values use FP64, which stores each number in 64 bits. Each multiplication, addition, subtraction and division rounds separately. FPCR is zero, so rounding uses the nearest value with ties to even and preserves very small numbers. The solver uses the accepted strict EXP route, hardware square root and the uniquely named [original-rounding POWER helper](../power_math.md). It preserves the original quarter-power call for $`(u^2+v^2)^{1/4}`$.

The source evaluates $`\epsilon=10\times10^{-15}`$ as FP64 bits `0x3d06849b86a12b9c`. This value is slightly above the nearest binary representation of $`10^{-14}`$. It bounds denominators and selects nonempty layers. The time step $`\Delta t`$ is positive and measured in seconds.

For each snow-covered column, SN-RHO-01 gives fresh density. The fresh mass is $`m_f=\Delta t\,F_s`$, where $`F_s`$ is snowfall in kilograms per square metre per second. SN-RHO-02 uses the denominator $`\max(\epsilon,m_f/\rho_f+m/\rho)`$. Other layers begin with their incoming density.

Let $`A`$ be the accumulated snow mass above the current layer and $`B`$ be the carried wind integral. Both begin at zero. The following equations define the source rates. The calibration coefficients come from the read-only soil context, and their exponential arguments are dimensionless.

```math
\begin{aligned}
g_m&=a_m\left[1-\max\left(0,\frac{\rho-\rho_{\min}}{b_m}\right)\right],\\
g_w&=1-a_w\max\left(\epsilon,\exp(-b_w U)\right)+g_m,\\
d&=\frac{m}{\max(\epsilon,\rho)},\\
r_o&=\frac{(A+m/2)g}{a_o\exp\left[b_o(T_f-T_s)+c_o\rho\right]},\\
r_m&=a_d\exp\left[-b_d(T_f-T_s)-c_{d,k}\max(0,\rho-\rho_d)\right],\\
r_w&=\frac{\max(0,w_{\mathrm{new}}-w_{\mathrm{old}})}
{\Delta t\,\max(\epsilon,m)},\\
B_{\mathrm{new}}&=B+d(b_\tau-g_w),\\
f_\tau&=\max(0,g_w)\max\left(\epsilon,\exp(-a_\tau B_{\mathrm{new}})\right),\\
\tau&=\frac{172800}{\max(\epsilon,f_\tau)},\\
r_c&=\max\left(0,\frac{\rho_c-\rho}{\tau}\right).
\end{aligned}
```

Here $`g`$ is gravity in metres per second squared, $`T_f`$ is the freezing reference temperature and $`T_s`$ is layer temperature, both in kelvin. The water masses $`w_{\mathrm{old}}`$ and $`w_{\mathrm{new}}`$ use kilograms per square metre. The layer coefficient $`c_{d,k}`$ varies with depth. The scale 172800 is two days in seconds.

A layer with $`m>\epsilon`$ receives the following ordered update. The rates are added from left to right, each product rounds before the next product, and the two density increments are added separately.

```math
\rho^*=\rho_{\mathrm{start}}+
\left[\rho_{\mathrm{start}}\left((r_o+r_m)+r_w\right)\right]\Delta t+
r_c\Delta t.
```

The source then applies a 500 kg m⁻³ upper limit and the configured lower limit. It adds the current mass to $`A`$ and carries $`B_{\mathrm{new}}`$ to the next layer. Empty layers skip these rates. The final output applies the lower limit to every layer.

The original final store uses the working density array. It overwrites an earlier store that applied RHOMAXSN_NEW, so that parameter does not affect the returned values. The earlier 500 kg m⁻³ limit still applies to nonempty updated layers. The complete source leaves PDHTSS unchanged. The assembly preserves both observable behaviours, including the full diagnostic owner.

## Interface, Bounds and Storage

The application binary interface, or ABI, defines how the caller passes arguments and which registers the routine preserves. There are nineteen argument addresses in original order. The first eight use x0 to x7, and the remaining eleven use the incoming stack.

| Argument group | Order and contents |
| --- | --- |
| Selection | First column, last column, column count, layer count and time step |
| Input arrays | No-snow mask, old density, snow mass, layer temperature, old liquid water, new liquid water, snowfall, u wind, v wind and surface temperature |
| Contexts | TSOIL with 2416 bytes, then TCST with 128 bytes |
| Output arrays | Density matrix, then the unchanged diagnostic array |

A GNU array descriptor contains a buffer address, element size, rank, bounds and strides. The stride is the distance between adjacent logical elements. Vectors have one dimension, density and state matrices have two, and PDHTSS has three. Matrices use column then layer order. Supported array views include positive, negative and padded strides whose complete owners remain within declared bounds. Real values and descriptors need eight-byte alignment, while integer and logical values need four-byte alignment.

The declared domain has 1 to 4096 columns and 1 to 512 layers. The active interval may be empty. The time step is finite and positive. Consumed densities lie between the positive configured lower limit and 500 kg m⁻³. Snow and water masses and snowfall are nonnegative. Consumed temperatures, winds and calibration values are finite, and every denominator and exponential route stays in its declared physical domain. The no-snow flag has a valid logical representation.

When a snow-covered column is active, the soil context contains a genuine contiguous layer-coefficient allocation. Its bounds include every used layer, and its descriptor is at byte offset 1896. A snow-free column does not consume that allocation or its snow-state values. The unused PDHTSS descriptor may have zero extents. The full context and coefficient owner are read-only. Output owners must be separate from input owners and from one another. The caller checks these conditions before the first write.

The 576-byte stack frame has sixteen-byte alignment. The routine preserves x18, x19 to x29, the return address, and the low 64 bits of d8 to d15. Scalar math calls have the same ABI and keep these registers. No driver performs a numerical stage.

## Critical Acceptance and Output Bytes

The original control passes eleven protected calls across singleton and maximum supported dimensions, negative and padded strides, partial and empty intervals, zero wind, snow-free cells and the exact mass threshold. An independent 90-digit calculation checks 25,831 mass-volume, nonnegative-rate and density relations. Four new quarter-power inputs match the qualified helper and an independent 110-digit reference.

The canonical byte stream concatenates the complete density owner and complete PDHTSS owner for each fixed input case. It retains inactive cells, padding, signed zeros and incoming diagnostic bytes. The original record contains 331,728 bytes. Native acceptance requires zero different bytes, protected input preservation, the same physical checks, immediate ABI checks and prewrite rejection of invalid interfaces. The high-precision density tolerance is $`2\times10^{-12}(|\rho|+1)`$ in kilograms per cubic metre.

The direct assembly passes all 331,728 canonical bytes and 25,831 independent physical relations. Four immediate ABI cases preserve 20,800 returned bytes and all required registers. Six focused paired calls pass 21,608 returned owner bytes, including an empty diagnostic view and unused nonfinite snow inputs in a snow-free column. Two invalid calls are rejected before writing 6,304 shared output bytes. The direct object contains no fused or approximate arithmetic instructions. An additional enabled-profiling pair passes 3,152 complete owner bytes with zero differences and FPCR zero. The source shadow retains its original profiling calls. A paired actual forecast and its saved files remain required before publication acceptance. Whole-forecast physical verification and performance claims remain outside this routine gate.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfsn_rsn_mod::srfsn_rsn | 2,150 | 33,024,000 | complete_density_and_unchanged_diagnostic_owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
