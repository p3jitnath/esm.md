# Soil Temperature Step Contract

Revision 1 implements complete `SRFT_MOD::SRFT` from [Heat Flow In Soil](../../../../../formulations/openifs/surface/soil_temperature_step.md), ST-1. The direct entry `md2asm_srft` is in [soil_temperature_step.S](../../../../../src/openifs/surface/soil_temperature_step.S). Its private complete [soil column diffusion](soil_column_diffusion.md) child performs the tridiagonal solve.

## Physical And Numerical Method

First form surface shortwave and longwave sums over tiles 3, 4, 6 and 8, then add tile 10 when present. Form each turbulent term as sensible heat plus latent heat times evaporation, multiply by its tile fraction and add in source order. Add snow heat last. The original lake branch divides the non-snow sum by the admitted land fraction.

For phase-interior cells, form `q=RTF4*(T-RTF3)` and `f=0.5*(1-SIN(q))`. Freeze the original phase quartet to 274.16, 270.16 and 272.16 kelvin and nearest FP64 `pi/4` per kelvin. Values at or below the lower endpoint have `f=1`. Values at or above the upper endpoint have `f=0`.

Let `phi` denote soil water capacity and `w` supplied water fraction. Select scalar or table dry conductivity and saturated soil coefficient. Form `u=phi*(1-f)`, the water power `water^u`, the ice power `ice^(phi-u)` and their source-ordered product with the soil coefficient. The Kersten factor is an empirical water correction given by `RKERST2*LOG10(MAX(RKERST1,w*(1/phi)))+RKERST3`. Conductivity is dry conductivity plus this factor times the difference between saturated and dry conductivity. With table soil and `LESOILCOND` enabled, retain the original replacement graph, including `w/phi`, ice exponent `phi*f` and water exponent `phi*(1-f)`. Table soil may mix urban conductivity in layer one.

For layer thickness `h`, time step `dt` and original implicit weight `theta=RSIMP`, set each interlayer factor to `dt*theta*(lambda[k]+lambda[k+1])/(h[k]+h[k+1])`. Set layer capacity per area to `C[k]*h[k]`. The upper right-hand side is `dt*Q/(C[1]*h[1])`, with zero additional source below it. The accepted private child solves every active land layer. Recover `Tnew=Told*(1-1/theta)+Tprime`. Compute `TMST=1/dt` once, then form the upward top-layer transfer as `((Tprime[2]-Tprime[1])*factor[1])*TMST`, with both products rounded separately. All source diagnostic fields, inactive entries and padding retain their complete original values.

All ordinary FP64 operations round separately to nearest with ties to even, with FPCR zero and gradual underflow. The source-ordered scalar SIN, LOG10 and real-power routes are reused. No fused or approximate solver instruction is admitted.

## Domain And Interface

There are 24 addresses. Registers `x0..x7` hold first column, last column, column count, tile count, soil layer count, time step, old temperature descriptor and water descriptor. Stack addresses then hold soil type, tile fractions, sensible heat, evaporation, longwave, shortwave, snow heat, capacity, land mask, TCST, TSOIL, TFLAKE, TURB, new temperature, interlayer flux and diagnostics.

Support 1–4,096 columns, 2–512 layers, partial or empty ranges and 8–16 tiles. Lakes require tile nine. A GNU array descriptor stores the data address, dimensions and strides. A stride is the distance between neighbouring entries. Rank-one, rank-two and rank-three arrays have one, two and three dimensions. Their original signed element strides and dimensions cover every consumed column, layer, tile and diagnostic field. Empty diagnostics are admitted without accessing their absent owner. Nonempty diagnostics cover at least 15 fields. The source one-layer route reads an absent neighbour and is rejected.

Land temperatures lie in 100–500 kelvin. Water lies in `0..1`. Soil water capacity lies in `1/32..1`. Power bases lie in `0.1..10` and exponents in `0..1`. The logarithm floor lies in `2^-40..1`, so every LOG10 operand lies in `[2^-40,32]`. Every SIN operand has magnitude at most $`\pi/2`$. Consumed thickness, heat capacity and time step are positive and finite. Conductivity must remain positive and finite before the child runs. Surface fractions are finite in `0..1`. All derived values must be finite.

The original urban diagnostic field 10 adds evaporation without its latent-heat factor. Therefore enabled diagnostics with tile 10 require zero urban evaporation. Main soil heating retains the correct latent-heat factor for every admitted urban call. Diagnostic field 11 retains its original implicit-weight factor, and field 15 retains the original intermediate-temperature definition. Neither is silently replaced by a different physical quantity.

The original types have TCST 128, TSOIL 2,416, TFLAKE 856 and TURB 472 bytes. Rank-one, rank-two and rank-three descriptors have 64, 88 and 112 bytes. Four-byte logical masks use zero or one. Other integer scalars use four bytes. Real data and type owners are aligned to eight bytes. All output owners are separate from input owners, configurations and descriptor storage.

Canonical bytes comprise the complete new-temperature, interlayer-flux and nonempty diagnostic owners in increasing address order, using little-endian FP64. Raw copied temperatures in nonland columns preserve their payload bits. Other owners remain unchanged. The entry preserves `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR. Its stack stays aligned to 16 bytes. Source profiling is allowed.

## Evidence

Before generation, the complete original passes 24 protected placements over 3,884,096 output bytes and 23,120 independent 110-digit relations. Checks cover heat conservation in every layer and the full column, phase conductivity, surface-flux weighting, lake adjustment and the original diagnostic definitions. A focused review of archived output bytes checks another 3,072,080 inactive or padding bytes without repeating the original runs. The frozen error limit is `4096*epsilon*layers*uncancelled energy or flux scale`, with $`\epsilon=2^{-52}`$. Complete child, scalar maths and reused type metadata proofs remain unchanged. The complete native body passes the same 24 protected placements with zero differing bytes and 46,240 source and native physical relations. It preserves all 3,072,080 checked inactive or padding bytes. Immediate register checks and the paired adapter each pass two calls over 660,496 complete output bytes with zero differences. Two small adapter cases additionally cover absent diagnostics and an empty range. Thirteen new prewrite checks preserve 66,664 shared output bytes, and a negative diagnostic extent preserves another 5,128 bytes. The machine route calls only the accepted scalar maths and the complete private assembly child. These paired checks do not establish an autonomous assembly forecast. Records are local under `.runtime/openifs/soil_temperature_step_7240564/`.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srft_mod::srft | 2,150 | 26,832,000 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
