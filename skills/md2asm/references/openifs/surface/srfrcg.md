# Soil Heat Capacity Contract

This contract implements complete `SRFRCG_MOD::SRFRCG` from [soil heat capacity](../../../../../formulations/openifs/surface/soil_heat_capacity.md). The direct entry `md2asm_srfrcg` is in [soil_heat_capacity.S](../../../../../src/openifs/surface/soil_heat_capacity.S).

## Inputs And Domain

There are 1–4,096 columns and 1–512 soil layers, with a partial or empty active range. Tile count lies in `1..16`. GNU assumed-shape arrays have their original descriptor, which stores the data address, dimensions and strides. A stride is the distance between neighbouring entries, measured in elements. Arrays admit nonzero positive or negative column and layer strides. Their complete declared data owners must be allocated, and output rows cannot overlap each other.

Land and sea-ice masks use four-byte GNU zero or one. Land temperature is finite in `100..500` kelvin. Consumed vegetation and urban fractions lie in `0..1`, and the two vegetation fractions sum to at most one. Soil water capacity lies in `0..1`. Latent heat and water density are finite and positive, with bounds `1e9` joules per kilogram and `1e6` kilograms per cubic metre. Consumed ordinary heat capacities are finite in `1..1e12` joules per cubic metre per kelvin.

The complete default phase parameters are frozen to `RTF1=274.16`, `RTF2=270.16`, `RTF3=272.16` kelvin and the nearest FP64 `RTF4=pi/4` in inverse kelvin. These are the original SUSSOIL construction. Every active phase cosine operand has magnitude at most $`\pi/2`$, within the accepted unique cosine helper domain. Changing the physical phase interval requires a new contract.

With `LEVGEN` enabled, consumed soil types must lie in the intersection of both allocated table bounds. The tables retain their original lower bounds and strides. With that switch disabled, scalar soil capacity and water-holding capacity supply every land column. Masked atmospheric and cover payloads remain unused. Urban cover and its capacity are consumed only when tile count exceeds nine.

## Complete Ordered Update

All ordinary FP64 operations round separately to nearest with ties to even. FPCR is zero, with gradual underflow. There are no fused or approximate solver operations. For strict phase-interior land cells, form the separately rounded angle and derivative

```math
q=\mathrm{RTF4}(T-\mathrm{RTF3}),\qquad
D=-0.5\,\mathrm{RTF4}\cos(q).
```

At either endpoint and outside the open interval, $`D=0`$. The unique cosine helper retains original scalar rounding. The source first adds both vegetation fractions, then multiplies their sum by the selected water-holding capacity. Each land layer then uses

```math
C=C_0-\mathrm{RLMLT}\,\mathrm{RHOH2O}\,w\,D.
```

The products keep their written left-to-right source dependency. In an urban top layer, $`C_0`$ first becomes the original sum of soil capacity times `(1-PCUR)` and urban capacity times `PCUR`. Land takes precedence when both masks are true. A sea-ice column receives `RRCSICE` in layer one and positive zero in every other layer. Ocean columns receive positive zero in every layer. Inactive entries and padding remain untouched. No driver supplies a phase or capacity calculation.

## ABI And Storage

There are 16 address arguments. Registers `x0..x7` hold `KIDIA`, `KFDIA`, `KLON`, `KTILES`, `KLEVS`, `LDLAND`, `LDSICE` and `PTSAM1M`. Stack arguments hold `KSOTY`, `PCVL`, `PCVH`, `PCUR`, `YDCST`, `YDSOIL`, `YDURB` and `PCTSA`. Scalar integers and logical data use four bytes. Real data, descriptors and type owners require eight-byte alignment. Rank-one descriptors have 64 bytes and rank-two descriptors have 88 bytes.

Accepted type sizes are TCST 128, TSOIL 2,416 and TURB 472 bytes, with `RLMLT=64`. The focused probe measures `LEVGEN=440`, `RRCSICE=424`, `RRCSOIL=8`, `RWCAP=128`, `RTF1..4=208,216,224,232` and `RURBVHC=408`. Soil table descriptors lie at `RWCAPM=944` and `RRCSOILM=1520`. GNU descriptor type codes are integer one, logical two and FP64 real three.

Canonical output is the complete allocated `PCTSA` data owner in increasing memory-address order, using little-endian FP64. It includes inactive entries and stride padding. The descriptor and every other owner remain unchanged. Output data must be separate from read-only input data, descriptors, configuration and consumed tables. The entry preserves `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR, with 16-byte stack alignment. Source profiling may remain enabled.

## Evidence

Before generation, the original passes 24 protected placements over 242,752 output bytes and 18,690 independent 110-digit relations. All 167,968 inactive or padding bytes remain unchanged. Cases cover scalar and table soils, all surface masks, urban mixing, phase endpoints and neighbours, signed column and layer strides, partial blocks and empty blocks. Independent checks use latent heat, the phase derivative and its integrated frozen-water fraction. The bound is `256*epsilon*(ordinary capacity+latent magnitude)`, with $`\epsilon=2^{-52}`$. Unchanged cosine proof is reused. The complete native body passes the same 24 protected placements with zero differing bytes over all 242,752 output bytes and 37,380 source-and-native physical relations. Immediate 16-address ABI and paired routes each pass two cases over 41,232 bytes. Eight invalid inputs preserve 2,368 shared output bytes before rejection. The paired report is written after every complete return while preserving floating-point status and the error indicator.  Local records are under `.runtime/openifs/soil_heat_capacity_7240564/`.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfrcg_mod::srfrcg | 2,150 | 1,651,200 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).
