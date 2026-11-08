# Mountain Wave Setup Contract

This contract implements complete `GWSETUP` from the [mountain-wave formulation](../../../../../formulations/openifs/physics/mountain_wave_setup.md). The direct entry is `md2asm_gwsetup` in [mountain_wave_setup.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/mountain_wave_setup.S). It prepares density, stability, projected wind and layer indices for mountain-wave drag. It does not yet apply a wind tendency.

## Domain

The block has 1–4,096 explicit columns and 6–512 levels, numbered downwards. Full-level fields have shape `(columns,levels)`. Pressure faces have shape `(columns,levels+1)` and source indices `0..levels`. The six half-level output fields use indices `1..levels+1`. Columns change fastest in memory. The active range has `1<=first<=columns+1` and `0<=last<=columns` and can be empty. Logical masks use GNU integers zero or one.

The shared constants are finite, with `1e-6<=RG<=1000`, `1<=RD<=1e5` and `RD<RCPD<=1e6` in their stated physical units. Safeguards are finite, with `1e-30<=GSSEC<=1e6` and `0<GRCRIT,GFRCRIT<=1e6`. The shape safeguard has `1e-12<=GTSEC<=1`, the wind safeguard has `1e-12<=GVSEC<=1000` and `NKTOPG` lies in `floor(levels/3)..levels`. Active shape ratios are finite and lie in `0..1`, before the source minimum is applied. Wave-active temperature lies in `100..500` kelvin, wind components have magnitude at most 1,000 metres per second, mountain orientation lies in $`[-2\pi,2\pi]`$ radians and mountain height variation is finite and nonnegative. Full pressures lie in `1e-3..1e8` pascals, increase downwards and lie between their enclosing faces. Faces lie in `0..1e8` pascals and increase downwards. Geopotential has magnitude at most `1e9` square metres per second squared and does not increase downwards. Mountain height variation is at most `1e7` metres. These broad bounds keep every consumed scalar-maths operand finite.

The derived mean-layer indices satisfy `1<=b<l<=levels` after every source crossing and cap rule. This condition is checked before caller writes. `NKTOPG=levels` is admitted when its derived interval is valid. A source interval extending to `levels+1` has no valid full-level input and is outside this contract. Masked columns do not consume unused atmospheric or mountain-direction payloads.

## Complete Ordered Method

Each ordinary FP64 operation rounds separately to nearest with ties to even. Each column keeps the source vertical traversal and sum order. Constants `1/RD`, `RG*RG/RCPD` and `1/(2*RG)` preserve their separate operations. A private index buffer allows complete domain checks before caller writes. One reusable column scratch area holds pressure differences, square roots of stability and full-level wind projections.

The method initialises five level indices, clamps `PGAMMA` by `GTSEC`, clears the low wind and dimensionless height, clears six half-level fields and leakiness, and sets Richardson values to 9,999. `PD1`, `PD2` and `PDMOD` remain untouched in masked columns. Four separate downward scans compare adjacent-level mean height with 4, 3, 2 and 1 times mountain height variation. Each scan begins with a false flag below the bottom and records its last change. The 4-height and 2-height indices are capped by `NKTOPG` before the source mean-interval rules.

For level $`j=2,\ldots,n`$, let $`\Delta p=p_j-p_{j-1}`$. The density and stability are

```math
\rho_j=\frac{2p_{j-1/2}}{R_d(T_j+T_{j-1})},\qquad
S_j=\max\left(\frac{2g^2}{c_p(T_j+T_{j-1})}
\left[1-\frac{c_p\rho_j(T_j-T_{j-1})}{\Delta p}\right],\mathrm{GSSEC}\right).
```

Mean density and stability use increasing-level pressure-weighted sums over `b+1..l`. The mean-stability numerator applies `MAX(...,GSSEC)` after each increment, before division by the full-pressure interval. This safeguard stays at that stage. The resulting ground mean is positive and need not be at least `GSSEC`.

Low wind uses decreasing-level sums over `b..l`, weighted by face-pressure differences. Its norm has a `GVSEC` floor. For an $`x`$ wind component in `[-GVSEC,GVSEC)`, the source adds `2*GVSEC` before forming its direction with the unique original-rounding arctangent. Mountain orientation minus this angle gives $`\psi`$. With the clamped shape ratio $`\gamma`$, form

```math
B=1-0.18\gamma-0.04\gamma^2,\qquad C=0.48\gamma+0.3\gamma^2,
```

```math
d_1=B-(B-C)\sin^2\psi,\qquad
d_2=(B-C)\sin\psi\cos\psi,\qquad d=\sqrt{d_1^2+d_2^2}.
```

Each full-level wind is projected into this mountain direction. Half-level projections use source pressure interpolation and a `GVSEC` floor. The last qualifying critical-level assignment is kept. Richardson values use the stability and projected-wind difference with the source wind and `GRCRIT` floors.

Increasing levels `2..n-1` integrate dimensionless mountain height. The first selected layer uses its lower half, and later layers use the mean of neighbouring stability-to-density ratios. The first `GFRCRIT` crossing selects the blocking level. A separate decreasing scan above that level forms the mixing-height integral and keeps its first crossing of 1.5. The final breaking level is bounded by the 4-height index.

At or below the blocking level, the method also records regularised wind direction and leakiness

```math
L_j=\sqrt{\frac{\max(1,\overline{\Phi}_{\mathrm{block}})-\max(1,\Phi_j)}
{\max(1,\Phi_j)+\max(1,hg)}}.
```

Here $`\Phi`$ is geopotential, and $`\overline{\Phi}_{\mathrm{block}}`$ is the mean around the blocking face. Nonincreasing input geometry keeps the root argument nonnegative. All boundary and untouched masked values preserve their encoding.

## ABI And Outputs

The entry takes 33 addresses. Registers `x0..x7` contain `YDEGWD`, `KIDIA`, `KFDIA`, `KLON`, `KLEV`, `LDGWD`, `KKCRITH` and `KCRIT`. The incoming stack contains the remaining addresses in source order. Integers and logicals occupy four bytes. Real owners are contiguous, eight-byte-aligned FP64 arrays. Output owners are separate from each other and read-only inputs. `PGAMMA` is the single read/write input array.

Measured GNU `TEGWD` size is 96 bytes. Consumed offsets are `NKTOPG=0`, `GFRCRIT=16`, `GRCRIT=24`, `GSSEC=48`, `GTSEC=56` and `GVSEC=64`. The routine preserves `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR, with 16-byte stack alignment. FPCR is zero.

The 19 complete outputs are five integer index arrays, six half-level real fields, full-level leakiness, both low winds, `PGAMMA`, dimensionless height and three direction-factor arrays. Their total encoding has `columns*(56*levels+124)` bytes. Inactive columns and masked direction-factor bytes remain unchanged. Zero differing bytes is required. Profiling may remain enabled in the original shadow.

Every arctangent operand is finite under the positive wind safeguard. Orientation minus arctangent has magnitude less than eight radians, so the accepted bounded sine and cosine children cover every angle. Private children reproduce original scalar rounding without replacing global maths.

## Source Evidence

Before generation, the original passes 24 protected placements over 841,360 complete output bytes and 42,130 independent 110-digit relations. Cases cover 6, 19, 32 and 512 levels, partial and empty blocks, masked columns, wind signs, direction and stability safeguards, valid `NKTOPG=levels`, blocking and breaking thresholds and geometric ties. All 281,872 inactive bytes and read-only owners remain unchanged.

Independent checks use ideal-gas density, buoyancy stability, pressure-weighted wind, rotated mountain geometry, projected-wind shear, complete height integrals and leakiness. Their frozen bound is `2048*epsilon*term scale*sum length`, where $`\epsilon=2^{-52}`$. Physical height comparisons use `64*epsilon*max(abs(height),abs(threshold),1)`. Frozen separate source rounding resolves a tie, and the independent height must admit that choice. Local evidence is under `.runtime/openifs/gwsetup_source_7240564/`. The direct body passes the same 24 protected placements with zero differing bytes across all 841,360 output bytes and 84,260 source-and-native independent relations. Its immediate 33-address ABI and paired shadow each pass two cases over 5,940 bytes. Eight invalid inputs are rejected before any output write. A separate all-masked case preserves unused NaN payloads and passes the original, native and paired routes over 7,664 bytes per route. The paired report is written after every complete call while preserving the native floating-point status and error indicator.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| gwsetup | 2,150 | 23,942,400 | Native private wave-setup child, complete drag-parent owners and unchanged child proof |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).
