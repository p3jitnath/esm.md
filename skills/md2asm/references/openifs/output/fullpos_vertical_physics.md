# Fullpos vertical physics

These four assembly entries implement GPPVO, PPLTETA, PPLTP and the selected ECMWF branch of GPRH. They calculate potential temperature, potential vorticity, pressure on requested theta or vorticity levels, and relative humidity for forecast output. Potential temperature is the temperature that an air parcel would have at a reference pressure. Potential vorticity combines air rotation with the vertical and horizontal change in potential temperature.

The source equations and operation order are retained. Pressure is in pascals, temperature and potential temperature are in kelvin, relative humidity is a dimensionless fraction, and potential vorticity is in kelvin square metres per kilogram per second. The entries use separate binary64 operations without fused multiply-add or reassociation. The caller supplies FPCR zero, which selects rounding to nearest with ties to even and gradual underflow. Public `pow`, `log` and `exp` resolve to the same GLIBC 2.29 providers as the selected original controls. Their natural floating-point status and `errno` are retained.

## Shared storage rules

Let $`P`$ be the full row pitch and $`L`$ the number of model levels. A field has $`P L`$ binary64 values in level-major order. The row index changes first. Scalar integers and logical values are four bytes. Scalar real values are eight bytes. Every supplied span must be mapped, aligned to its element size, large enough for its full declared shape, and free from address overflow. Outputs must be separate from inputs and from each other. Only rows from `start` through `end`, inclusive and one-based, are written. All other output bytes remain unchanged.

The assembled width bound is $`1 \le P \le 32769`$. GPPVO, PPLTETA and PPLTP support $`2 \le L \le 512`$. GPRH supports $`1 \le L \le 512`$. The caller must establish finite source inputs, positive pressure and temperature, and valid source search profiles and saturation denominators. These bounds describe the interface. Numerical acceptance covers only the profiles below.

Each entry preserves the AArch64 callee-saved registers, the platform register `x18`, and stack alignment. Scalar refusal returns 2 before output writes. GPPVO and PPLTP return 1 if their one private allocation fails and preserve all output preimages. Success returns 0. The false profiling flag is an explicit borrowed input. No original OpenIFS routine, global variable or constructor supplies a production stage.

## Interfaces

| Entry | Original address arguments in order | Appended input |
| --- | --- | --- |
| `md2asm_runtime_potential_temperature_and_vorticity` | `VAB512, P, start, end, L, pressure, inverse_dp, kappa, coriolis, vorticity, U, V, T, T_m, T_l, surface_p_m, surface_p_l, out_PV, out_theta` | Argument 20 is a 24-byte context at incoming stack offset 88. Its words are physical constants 520-byte pointer, private byte budget, and false profiling flag pointer. |
| `md2asm_runtime_theta_level_pressure` | `P, start, end, L, pressure, theta, target_theta, out_pressure, out_log_pressure` | Argument 10 is the false profiling flag pointer at incoming stack offset 8. |
| `md2asm_runtime_pv_level_pressure` | `cap_pressure, iterations, isopv, P, start, end, L, pressure, PV, target_PV, folding_enabled, coriolis, out_pressure, out_log_pressure, out_folding` | Argument 16 is a 16-byte context at incoming stack offset 56. Its words are false profiling flag pointer and private byte budget. |
| `md2asm_runtime_output_relative_humidity` | `water_molar, P, start, end, L, RH_max, RH_min, Q, T, pressure, out_saturation, out_RH, optional_sonntag` | Argument 14 is a 32-byte context at incoming stack offset 40. Its words are physical constants 520-byte pointer, thermal constants 1920-byte pointer, false profiling flag pointer, and true ECMWF flag pointer. |

Arguments 1 through 8 use `x0` through `x7`. Later arguments use consecutive eight-byte stack slots. The humidity entry requires false `water_molar` and absent or false `optional_sonntag`. The caller supplies ordered finite relative-humidity limits. The accepted fixture uses zero and one.

GPPVO reads the genuine rank-one REAL8 `VBH` descriptor at `VAB512+64`, with lower bound zero and upper bound at least $`L`$. It uses gravity at physical offset 112 and reference pressure at offset 360. Its seven private real fields require $`56 P L`$ bytes within a supplied budget no greater than one GiB. The stack frame is 512 bytes. PPLTETA uses no heap and has a 128-byte frame. PPLTP requires $`8 P L`$ private bytes within a budget no greater than 256 MiB and has a 384-byte frame. GPRH uses a 384-byte frame and no heap.

PPLTETA retains the strict theta comparison and its original boundary copies. When the selected level is the final model level, it copies the bottom pressure, even when a continuous linear profile would cross between the last two levels. Interior interpolation retains the source denominator threshold $`10^{-10}`$.

PPLTP retains the sign of the Coriolis parameter, including negative zero. The iteration count is one through three. Each search must contain at least that many levels, and each column must reach its pressure cap. The folding route requires a valid below-target level before the last level, so its original following search stays within the supplied field. The distinct source cap and interpolation indices are retained. A false folding flag leaves every folding output byte unchanged.

GPRH borrows genuine thermal constants at offsets 0, 8, 16, 24, 32, 112, 136 and 152. It uses the virtual-temperature constant and freezing temperature at physical offsets 240 and 368. It retains the mixed water and ice saturation calculation, publishes the complete active saturation row, and then applies the source relative-humidity limits.

## Component acceptance

The finite gate passed 54 original and assembly calls. It compared 184,880 complete returned bytes with zero differences. Profiles were $`P=1,L=3`$ with all rows, $`P=17,L=137`$ with rows 2 through 16, and $`P=24,L=137`$ with rows 3 through 22. They cover both vertical boundaries, nonzero horizontal temperature and pressure terms, both hemispheres and negative-zero Coriolis, three theta targets, single and repeated PV searches, folding, dry air and mixed-phase humidity. Six assembly refusals cover two tight budgets, two allocation failures, invalid width and an unsupported humidity policy. Input guards, complete output padding, ABI registers, FPCR, natural FPSR, `errno`, source namespace restoration and allocator-slot restoration passed.

Independent saved analysis passed 21,379 physical relations using 110-digit decimal arithmetic. It checks all three potential-vorticity terms, potential temperature, affine pressure relations within their source interpolation domain, pressure logarithms, mixed saturation, bounded relative humidity, dry positive zero and folding outputs. The first analysis omitted the three-level theta bottom-copy rule. Its failure and original script remain archived. A named saved-only revision applies that source boundary before the independent affine identity. It changes no numerical result, tolerance or implementation.

The numerical process used one thread with no MPI, a 30-second child limit, a 45-second controller limit, two GiB address space and a 512 MiB resident-memory limit. It completed in 0.385 seconds and sampled 45.5 MB peak resident memory. These are component resource observations, not forecast performance measurements. Complete POS, VPOS, ALLFPOS, FULLPOS_DRV, output files, other shapes and a full forecast remain outside this acceptance.
