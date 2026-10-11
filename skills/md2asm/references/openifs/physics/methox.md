# METHOX local humidity tendency

Revision 2 implements every equation and selected cell in the [physical note](../../../../../formulations/openifs/physics/methane_humidity_tendency.md). The original interface is `METHOX(KIDIA,KFDIA,KLON,KLEV,PQ,PTENQ,PAP)` in `arpifs/phys_ec/methox.F90`. The separate original `SUMETHOX` initializes the parameter module; this leaf reads its values and does not change them.

## Rates and pressure laws

The oxidation time in model days is 100 when `p <= RPTOPOX`. Above that pressure it is `100*(1+RALPHA1*log(p/RPTOPOX)^4/log(RPBOTOX/p))`. This source is active only when `p < RPBOTOX` and `q < RQLIM`.

The photolysis time is 3 model days when `p <= RPTOPPH`. Otherwise the pressure angle is `theta=(RPI*log(p/RPBOTPH))/RLOGPPH`, the exponential argument is `z=RALPHA2-RALPHA3*(1+cos(theta))`, and the time is `1/(exp(z)-0.01)`. This sink is active only when `p < RPBOTPH`. Multiplication by `RDAYI` converts each time to seconds. The source adds `(RQLIM-q)/tau1` to positive zero; the sink then subtracts `q/tau2`. Both full time calculations are retained, including very large intermediate times near the lower photolysis boundary.

All alpha coefficients and logarithmic ratios are dimensionless; the angle is in radians and each pressure parameter is in Pa. The original default coefficients are recorded with their exact FP64 words locally. They set `RALPHA1=19*log(10)/log(20)^4`, `RALPHA2=log(1/3+0.01)`, `RALPHA3=(log(100)+RALPHA2)/2` and `RLOGPPH=log(0.1/20)`. Rounded setup coefficients can place the ideal zero sink at 20 Pa slightly below zero. Independent rate bounds include its measured rounding interval, while the output retains every original bit.

## Consumed input domain

`KLON` is from 0 to 4096 and `KLEV` is from 0 to 512. `KIDIA` is from 1 to `KLON+1` and `KFDIA` is from 0 to `KLON`. An empty level or selected range changes no array. Selected pressure is finite from 0 to 200,000 Pa. Humidity consumed by either reaction is finite from 0 to 0.1 kg/kg. A finite negative temporary humidity is accepted only when both pressure branches are inactive; positive values keep the same upper limit. Skipped input cells can contain unrelated bit patterns because the solver does not read them.

CALLPAR can supply a temporary humidity formed from the state and its accumulated tendency. For a negative value, the nonnegative relaxation limit makes the oxidation humidity comparison true, so both rates are inactive exactly when pressure is at or above both bottom cutoffs. The result is positive zero, and the input humidity bits are unchanged. This admission does not treat negative water mass as a physical state or qualify a negative value consumed by either reaction.

The common comparison parameters `RPBOTOX` and `RPBOTPH` are finite from 1e-12 to 200,000 Pa; `RQLIM` is finite from 0 to 0.1 kg/kg. An active reaction consumes `RDAYI` from 1 to 1e6 s/day and a positive top pressure from 1e-12 Pa up to its strictly greater bottom pressure. Only the oxidation transition consumes finite `RALPHA1` from 0 to 1e6. Only the photolysis transition consumes `RPI` from 0 to 4, `RLOGPPH` from -64 to -0.001, `RALPHA2` from -64 to 64 and `RALPHA3` from 0 to 64. Its minimum exponential argument must be at least `log(0.01)` within a 256-epsilon coefficient rounding interval, so the ideal sink is nonnegative within that interval. Unused parameters need not satisfy a branch that does not run.

For the consumed photolysis transition, `1e-12 < p < RPBOTPH <= 200000`. Thus `p/RPBOTPH > 5e-18`, the absolute logarithm is below 40, and the absolute angle is below 160,001 radians after a rounding margin. This is inside the private cosine limit `2^20` radians. The live guard checks the actual ordered angle before either output call. No calendar input is present in this routine.

## Ordered arithmetic and complete storage

Every scalar operation uses separately rounded FP64 with FPCR zero, including gradual underflow and signed zeros. The source has a real exponent 4 and calls POWER on the rounded logarithm. The private accepted original-compatible POWER boundary retains that call and its internal single-rounding route. Each displayed source expression preserves its parentheses and original order. LOG and EXP reuse the qualified primary route `libpressure-math.so`. COS uses `md2asm_cos_original_rounding` and its accepted integer single-rounding child. There is no new global math override, fused instruction, reassociation or approximate operation.

The three arrays contain `KLON*KLEV` contiguous eight-byte words in Fortran order, with columns first. The solver initializes and updates exactly columns `KIDIA:KFDIA` at every level. Canonical output is the complete little-endian `PTENQ` owner in that order, including untouched columns. Output does not overlap either input, the four scalar arguments or the read-only parameter words. Inputs and module parameters are read-only.

## Native interface and live pairing

`md2asm_methox` accepts seven addresses in `x0:x6`, with four signed 32-bit integers and three eight-byte-aligned FP64 owners. The caller supplies the valid physical domain and disjoint buffers. The entry checks shape and FPCR before writes. Its 192-byte frame preserves `x19:x29`, the low 64 bits of `d8:d15` and the return address, with 16-byte stack alignment. It does not use `x18`.

The paired adapter validates consumed settings and complete ownership before writes, clones the full output owner for the unchanged original, and runs native on the caller output. It compares all output bytes and unchanged input/scalar/global bits, checks the native ABI immediately, and checks independent source/sink rates. The independent sink-rate interval is computed before multiplication by humidity, so zero humidity cannot enlarge or remove that rate check. Angle-rounding error enters the rate budget through the cosine slope bound, which is at most one. Fresh numeric status matches in an unprofiled call. Original DR_HOOK timer status is recorded separately when profiling is enabled; all incoming, source and native status bits are retained.

## Evidence and limits

Before assembly emission the original gate passes 18 protected start/end calls over 8,480 complete output bytes and 2,874 independent relations at 120 digits. It includes both reactions, constant and transition times, all four cutoff neighbours, high humidity, zero and tiny pressure, skipped columns and empty ranges. Four new consumed cosine pairs match original bits, fresh status and errno; their largest independent error is below 0.122 ULP. The accepted complete cosine and POWER proofs are reused. The complete native gate repeats those 18 protected calls with zero differing bytes, exact fresh numeric status and immediate ABI checks. Nine focused paired calls compare 16,781,688 complete output bytes with zero differences, including the maximum owner, every cutoff and humidity combination, large bounded angles, unused coefficients, signed zero and real MPI/DR_HOOK profiling. There are 3,503 independent rate and bound relations at 120 digits in those focused calls; 2,096,703 separate relations check preserved skipped words. Fourteen live and eight native invalid-input cases reject before writes. Two focused calls from /tmp prove library loading and zero or tiny humidity near a very large photolysis time; the measured nonzero denominator and exact underflow/inexact status are retained. The source has 2,764 physical relations plus 110 preserved-word checks. Profiling contributes inexact status to a skipped source call while native contributes none; this timer effect is diagnostic and every sticky bit is retained. Forecast reachability and timing remain separate acceptance steps.

Revision 2 changes only the paired admission of an unused negative temporary value. The first actual negative packet has shape 24 by 19, one negative cell at column 1 and level 19, pressure 98,385.67412841512 Pa, and captured bottom cutoffs 10,000 Pa and 20 Pa. Both source branches are inactive at that cell. Three focused source, native and paired calls compare 3,984 complete output bytes with zero differences and 1,068 independent zero-rate, rate and bound relations at 120 digits. They include the complete captured owner, inactive cutoff equality, finite negative extremes, unused coefficient NaNs, protected input ends and unchanged positive-zero output. Four new cases reject consumed negative or nonfinite humidity before writes. The captured owner also passes from /tmp with fresh numeric FPSR 16 in source and native, immediate native ABI checks, FPCR zero and unchanged input, scalar and parameter bits. All previous active arithmetic, numerical-child, profiling, edge and shape proofs are reused; the assembly and frozen native library are unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| methox | 2,150 | 7,843,200 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
