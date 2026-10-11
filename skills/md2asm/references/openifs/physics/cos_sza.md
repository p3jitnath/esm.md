# Solar Zenith Angle

This contract defines complete `COS_SZA` calculations for the declared coarse-forecast domain. The [physical input](../../../../../formulations/openifs/physics/solar_zenith_angle.md) describes sunlight geometry. The direct entry is `md2asm_cos_sza` in [solar_zenith_angle.S](../../../../../src/openifs/physics/solar_zenith_angle.S). The original `arpifs/phys_ec/cos_sza.F90` selects separate model and radiation solar states and provides midpoint and time-averaged methods. A solar state gives the sine and cosine of declination and the solar phase at the interval's centre.

## Domain And Original Scientific Limit

Columns are numbered from 1. The declared block has 1–4,096 columns, with `1<=KSTART<=KCOL+1` and `0<=KEND<=KCOL`. An empty active range leaves the complete output owner unchanged. Logical arguments use the GNU values zero or one. Averaging requires `LCENTREDTIMESZA` to be true, a positive model time step and, for radiation averaging, a positive `NRADFR`. The averaged half-interval must be no greater than $`\pi/2`$ radians. The latitude sine is finite and lies in $`[-1,1]`$, longitude is finite and lies in $`[0,2\pi]`$, and the selected declination pair has nonnegative cosine and a squared norm within 32 FP64 rounding units of one. The selected phase lies in $`[-\pi/2,5\pi/2]`$ radians. Only the selected model or radiation numerical state is consumed.

The original method clips an averaging window to one daylight interval. Its complete physically supported domain therefore requires that an illuminated segment from an adjacent solar period does not intersect the window. This condition is checked before output is committed. Perpetual day and perpetual night need no clipping. A retained source witness for a long day at midnight returns half of the independent full-period model average. The original calculation and its bytes remain unchanged, and that window is outside this contract. The original-only coarse observer records 264 calls and 6,288 active columns with no excluded windows. Each native call still checks its own complete window before output writes.

FPCR must be zero. The consumed daily period is 86,400 seconds, and $`\pi`$ uses word `0x400921fb54442d18`. All complete elementary functions use accepted uniquely named original-rounding children. The bounded sine and cosine children support finite angles with magnitude at most $`2^{20}`$ radians. The declared phase, longitude and half-interval bounds place every sine or cosine operand within $`[-2\pi,5\pi/2]`$, which is inside the accepted elementary-function bound. No global mathematical function is replaced.

## Ordered Calculation

Let $`u=\sin\phi`$, $`c_\phi=R(\sqrt{R(1-R(u^2))})`$, $`s=\sin\delta`$, $`c=\cos\delta`$, and $`\lambda`$ be longitude. Let $`\tau`$ be the selected solar phase. Here $`R`$ means FP64 nearest-even rounding, and every ordinary operation below has a separate rounding. Form $`A=R(su)`$ and $`B=R(c c_\phi)`$. The model state uses `TRIP` values `RSIDEC`, `RCODEC` and `RWSOVR`. The radiation state uses `TERIP` values `RSIDECM`, `RCODECM` and `RWSOVRM`.

The midpoint method preserves the original expanded expression. It does not combine the two angles before applying cosine.

```math
p=R(R(R(c\cos\tau)c_\phi)\cos\lambda),\qquad
q=R(R(R(c\sin\tau)c_\phi)\sin\lambda),\qquad
\mu_0=\max(0,R(R(A-p)+q)).
```

For an averaged model step, form $`H=R(R(\mathrm{TSTEP}\,\pi)/\mathrm{RDAY})`$. For an averaged radiation step, first multiply `TSTEP` by the FP64 conversion of `NRADFR`, then multiply by $`\pi`$ and divide by `RDAY`, with one rounding at each operation. The unshifted start and end phases are $`R(\tau-H)`$ and $`R(\tau+H)`$.

The source's protected sunrise equation uses

```math
v=R\left(s/\max(c,10^{-12})\right),\qquad
q_s=R\left(R(-vu)/\max(c_\phi,10^{-12})\right).
```

If $`q_s>1`$, return positive zero. Otherwise, form the hour endpoints by adding longitude to each unshifted endpoint, then subtracting $`\pi`$ if $`R(\tau+\lambda)<R(2\pi)`$ or $`R(3\pi)`$ otherwise. If $`q_s\ge-1`$, compute sunset $`a=\arccos(q_s)`$. A window with end no greater than $`-a`$, or start no less than $`a`$, returns positive zero. Other endpoints are bounded individually to $`[-a,a]`$. The single-period scientific admission checks the original endpoints against $`a-2\pi`$ and $`2\pi-a`$ before clipping. The zero-sunlight degenerate case has no illuminated neighbouring segment.

Let $`h_1,h_2`$ be the resulting endpoints, $`D=R(h_2-h_1)`$ and $`S=R(\sin h_2-\sin h_1)`$. Model averaging returns

```math
\mu_0=R\left(R(R(AD)+R(BS))/R(2H)\right).
```

Radiation averaging returns $`R(A+R(R(BS)/D))`$ when $`D>10^{-8}`$ radians, and positive zero otherwise. This small-interval rule avoids an unreliable subtraction near the horizon. Its physical error is bounded by the change in sunlight over that short interval. Either averaged method replaces a strictly negative result with positive zero. A computed signed zero remains unchanged when this comparison is false.

## ABI And Storage

The original AArch64 entry takes ten addresses. Registers `x0..x7` contain `YDERAD`, `YDERIP`, `YDRIP`, `KSTART`, `KEND`, `KCOL`, `PGEMU` and `PGELAM`. The incoming stack contains the address of `LDRADIATIONTIMESTEP` followed by the address of `PMU0`. Integers and logicals occupy four bytes. The explicit FP64 arrays are contiguous, eight-byte aligned owners of `8*KCOL` bytes. Read-only owners may share storage, but the complete output owner must not overlap a read-only input.

The measured GNU types have sizes 2,040 bytes for `TERAD`, 48 for `TERIP` and 175,976 for `TRIP`. `TERAD` fields `NRADFR`, `LCENTREDTIMESZA` and `LAVERAGESZA` have byte offsets 12, 500 and 504. `TERIP` fields `RCODECM`, `RSIDECM` and `RWSOVRM` have offsets 0, 8 and 40. `TRIP` fields `RWSOVR`, `RCODEC`, `RSIDEC` and `TSTEP` have offsets 88, 104, 112 and 200.

The routine preserves `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR, with 16-byte stack alignment. A private result buffer allows all scalar, shape, angle and scientific-domain checks to finish before any caller-owned output is written. It then commits only active cells. The complete output encoding is the original little-endian `PMU0` owner, including untouched inactive cells. Zero differing bytes is the acceptance limit. Source profiling hooks do not supply any numerical stage and may remain enabled in the original control.

## Actual Checks

The source-first verifier passes 48 protected placements, 2,960 complete output bytes and 954 independent 110-digit periodic-sunlight relations. It covers both selected states, midpoint and averaged methods, polar day and night, sunrise, sunset, the short radiation interval and partial or empty blocks. All 416 inactive owner bytes and all read-only bytes remain unchanged. The independent check integrates positive sunlight over every relevant solar period, rather than reproducing the source's clipped calculation.

For an average, the frozen arithmetic uncertainty is $`128\epsilon\max(1,\lvert A\rvert+\lvert B\rvert)(1+1/\max(d,10^{-12}))`$, where $`\epsilon=2^{-52}`$ and $`d`$ is the relevant interval length. Midpoint checks use $`64\epsilon\max(1,\lvert A\rvert+\lvert B\rvert)`$. The very short radiation interval adds $`\lvert B\rvert10^{-8}`$ for its stated horizon approximation. These bounds are fixed before generation.

Local source versions, input words, measured layouts, the periodic-window witness and source results are retained in `.runtime/openifs/cos_sza_7240564/`. An original-only observer in the required forecast retry records 86 averaged model calls and 178 averaged radiation calls. Its largest half-interval is 0.1308996938995747 radians, its smallest single-period margin is 0.32683364903589052 radians and its declination norm error is at most 1.1102230246251565e-16. It preserves source outputs, FP status and errno. The paired forecast adapter repeats whole-owner comparison and independent periodic-sunlight relations for every genuine call. The complete native verifier passes the same 48 protected placements and 2,960 output bytes with zero differences. It retains 1,908 source and native independent relations, all 416 inactive bytes and every read-only byte. Two immediate ten-address ABI calls and two paired model/radiation calls compare 144 complete output bytes with zero differences. Eight new invalid-domain cases leave all 64 shared output bytes unchanged, including the retained adjacent-period witness. The emitted body contains no fused or approximate floating-point instruction. Actual assembly

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cos_sza | 6,450 | 1,238,400 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
