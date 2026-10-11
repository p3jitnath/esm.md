# Broadband Radiative Heating

The physical input is [radiative_heating.md](../../../../../formulations/openifs/physics/radiative_heating.md), revision 1. The direct body is [radheatn.S](../../../../../src/openifs/physics/radheatn.S). The original queued name is `radheatn` in `arpifs/phys_radi/radheatn.F90`. The retained genuine coarse forecast prints `NLWOUT=1` at `NODE.001_01` line 2297 and `LSPP=F` at line 2984 in the batch09-r15 run. Support both settings of the approximate thermal update and the Manners solar-angle update within this broadband domain.

## Complete Numerical Update

Use the supplied pressure levels directly. The method updates radiation between full radiation calls, then forms the energy entering and leaving each layer. Use FP64 in the source order, round each addition, subtraction, multiplication, division and square root separately, and keep the source's two multiplication steps for $`T_s^4`$. The true source constant for the downward response is `0.20000000298023224`, because the default-real literal `0.2` is promoted to FP64.

1. Compute the source curvature term `RRAE*(RRAE+2)` and the heating coefficient `(RG*RPLDARE)/RCPD`. The solar threshold is `100*2^-52`. If the current solar cosine meets this threshold, set the incident flux to `RII0*PMU0` and the direct-beam day flag to one. Otherwise, set both to positive zero.
2. With the approximate thermal update, form the upward surface change from the old net surface flux plus `PEMIS*(RSIGMA*T_s^4-PTRTHD)`. Multiply it by the exact response constant to form the downward change. At each half-level, add the downward change times `(d-d_top)/(1-d_top)` and subtract the upward change times the supplied derivative $`d`$. Without the update, copy the old net thermal flux. The one-band sum for downward radiation retains the source's addition to positive zero.
3. With the Manners update, calculate each curved-ray cosine from `RRAE/(sqrt(mu^2+RRAE*(RRAE+2))-mu)`. Below `10000*2^-52`, use `RRAE/sqrt(RRAE*(RRAE+2))`. Divide the old result by the current result. If the current cosine, old direct transmission and old downward transmission meet the stronger threshold, use the approved private power primitive to raise the old direct transmission to that ratio. Otherwise, keep the source zero correction and unit scaling. Do this for both cloud and clear sky.
4. Form the constant solar net-flux correction in the exact order `0.5*incident*(new_direct-old_direct)*old_net_surface/old_down_surface`. The downward surface scale is `1+0.5*(new_direct-old_direct)/old_down_surface`, and the direct scale is `new_direct/old_direct`. Multiply each stored solar transmission by the incident flux and add its net correction. Keep the source's positive surface floor `100*2^-52`, and form the two clear-sky boundary diagnostics.
5. For each layer, separately form the pressure difference and `1+RVTMP2*q`, multiply them, then divide the negative heating coefficient by their product. Multiply this factor by the difference of each net flux across the layer. Add the factor times the difference of the separately added total solar and thermal fluxes to the input temperature tendency. Keep the clear-sky heating rates based on their unmodified stored thermal fluxes and solar transmission.
6. Update the surface downward, direct, ultraviolet and photosynthetically active solar fluxes in their original multiplication order. Keep the orthogonal direct beam's day flag, solar irradiance, old direct transmission and direct scaling as four successive factors. Set sunshine duration to one when this beam is at least `RSUNDUR`, otherwise set it to positive zero. Keep every source-unused input bit and every inactive output word unchanged.

The complete body supports `NLWOUT=1` and `LSPP=false`. Reject a changed spectral or stochastic configuration before any output store. The different polymorphic spectral Planck method is outside this domain, and no numerical stage is delegated to the original solver. Use only the approved private `md2asm_pow_original_rounding_candidate` primitive for real powers. Its unchanged bit, status and independent accuracy proofs are reused.

The approximate thermal boundary holds reflected downward radiation fixed. If the estimated downward change is $`\Delta D`$, its difference from using the updated reflected flux is exactly $`(1-\epsilon)\Delta D`$ in real arithmetic. This gives a direct quantitative bound and tends to zero for a perfectly emitting surface or no temperature change. The surface derivative is one by its definition. Permit its interpolation rounding within 128 FP64 spacings of one, and include the resulting small boundary error in the independent check. Check that the estimated upward and downward radiances remain nonnegative. Keep this declared approximation separate from exact source/native byte agreement.

## Interface and Storage

The application binary interface (ABI) states how a caller passes values and which registers a routine must preserve. All 57 GNU Fortran arguments are ordinary addresses. Arguments 1 through 8 use `x0`–`x7`, and the remaining 49 addresses begin at the caller's stack pointer. The complete argument order is the original source order. The first five objects are `TERAD` at 2040 bytes, `TERDI` at 176 bytes, `TPHY2` at 160 bytes, `TPHY3` at 5376 bytes and `TSPP_CONFIG` at 3192 bytes. Their bytes are read-only in this body.

| Consumed object field | Offset in bytes |
| --- | --- |
| `TERAD%NLWOUT` | 76 |
| `TERAD%LAPPROXLWUPDATE` | 488 |
| `TERAD%LMANNERSSWUPDATE` | 496 |
| `TERDI%RRAE` and `RSUNDUR` | 0 and 8 |
| `TPHY2%TSPHY` | 8, source-unused after its load |
| `TPHY3%RII0` | 616 |
| `TSPP_CONFIG%LSPP` | 0 |

The next four arguments are four-byte `KIDIA`, `KFDIA`, `KLON` and `KLEV` scalars. Use contiguous column-first arrays, with `KLON` columns. A full-level field has `KLEV` levels, a half-level field has `KLEV+1` levels and a clear-sky boundary field has two levels. Admit `1<=KLON<=2048` and `1<=KLEV<=512`, cropped columns and an empty active interval. Pressure increases downward. Its difference and the moist heat capacity must be positive. Current and old solar cosines are finite and between minus one and one. Stored solar fractions are finite between zero and one, with direct transmission no greater than the corresponding downward transmission.

Require positive finite gravity, heat capacity, planet factor, Stefan–Boltzmann constant and curvature ratio. Humidity is finite and nonnegative. Active input temperature tendencies and stored thermal fluxes are finite. When the thermal update is active, require finite positive skin temperature, emissivity between zero and one, and derivatives between zero and one with the top derivative less than one and the surface derivative within 128 FP64 spacings of one. Those three inputs are not consumed when the update is off, so their unused NaN words are preserved.

The outputs are the input temperature tendency, four heating profiles, two all-sky net-flux profiles, two clear-sky boundary-flux arrays and thirteen surface or solar diagnostics. Every complete output owner is distinct from the input owners and other output owners. FP64 buffers and objects are eight-byte aligned, and scalar integers are four-byte aligned. Preserve `x19`–`x29`, the lower 64 bits of `v8`–`v15` and the 16-byte stack alignment. Profiling may be enabled. Verify FPCR zero, gradual underflow, signed zeros, source/native floating-point status and zero differing output bytes.

Keep nine one-column-length temporary rows for incident light, two thermal changes and six solar corrections or scales. Read adjacent completed flux levels directly when forming heating, so the older full sets of layer-flux temporary arrays are unnecessary. This retains all source rounding points and mutations while keeping storage proportional to the column count.

## Independent Gate

Use a 120-digit check of the physical laws and independently sum pressure-weighted heating over each column. The result must equal the top-minus-bottom net energy flux, including the declared tiny solar surface floor. Check cloud and clear sky separately, the temperature-tendency increment, the curved-ray Beer–Lambert change, the approximate thermal boundary, sunlight thresholds, sunshine duration, cropped and empty columns, small and maximum layer counts, complete input owners and source-unused missing words. Qualify only new consumed power inputs. Reuse unchanged primitive and metadata proofs.

The direct body passes 24 protected original/native calls with 475,152 complete output bytes, zero differences and 100,836 independent physical relations at 120-digit precision. Three focused boundary and signed-zero calls compare another 15,840 bytes, and 19 new power operands match the original bytes and floating-point status with an independent maximum error below 0.287 ulp. An ulp is the spacing between adjacent floating-point numbers. The complete paired relay passes six calls across both update flags, then three calls for the final boundary conditions, with exact fresh floating-point status and the required ABI. Three rejected configurations preserve 3,744 shared output bytes before any numerical store. Actual primary calls and raw saved forecast files remain required for final acceptance. No comparative timing is claimed.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| radheatn | 2,150 | 62,745,600 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
