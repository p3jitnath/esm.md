# Coupled Surface Flux Accumulation

This direct assembly child implements the numerical update in the original OpenIFS `CUMCOE` routine. It adds the current surface fluxes to persistent totals. A flux is a quantity that crosses a unit area in one second, so multiplication by the time step gives the change in the total for that step. The [assembly source](../../../../../src/openifs/physics/coupled_surface_flux_accumulation.S) contains the complete calculation and calls no external routine.

## Physical Update

Let $`h`$ be the time step in seconds, $`F`$ the current flux, and $`A`$ its accumulated total. Each selected cell uses this update:

```math
A_{\mathrm{new}}=A_{\mathrm{old}}+hF.
```

Stress inputs have units of newtons per square metre, and their totals have units of newton seconds per square metre. Heat inputs have units of watts per square metre, and their totals have units of joules per square metre. Precipitation, moisture and runoff inputs have units of kilograms per square metre per second, and their totals have units of kilograms per square metre. The selected surface-time-update interface defines runoff in these mass-flux units. This child preserves the source signs and performs no unit conversion or spatial integration.

The following table gives the write order within each cell. A descriptor is a record that gives an array's address, shape and stride. Its index in the table starts at zero. For a sum with several terms, evaluate additions from left to right before multiplying by $`h`$ and adding the old total.

| Order | Descriptor index | Total | Flux $`F`$ in original argument names |
| --- | ---: | --- | --- |
| 1 | 0 | STRSU | PSTRTU |
| 2 | 1 | STRSV | PSTRTV |
| 3 | 5 | RUIST | PRUISS + PRUISP |
| 4 | 9 | FHUML | PFPLCL + PFPLSL |
| 5 | 10 | FHUMN | PFPLCN + PFPLSN |
| 6 | 3 | FRSOS, column 1 | PFRSO |
| 7 | 6 | FCHLL, column 1 | PFCLL |
| 8 | 7 | FCHLN, column 1 | PFCLN |
| 9 | 8 | FCHSS, column 1 | PFCS |
| 10 | 2 | FCHAS, column 1 | PFRTH + PFCLL + PFCLN + PFCS |
| 11 | 4 | FHUMS, column 1 | PFPLCL + PFPLCN + PFPLSL + PFPLSN + PDIFTQ |

Use FP64, which stores each floating-point value in 64 bits. Each addition and multiplication rounds separately to nearest, with ties to even. Preserve signed zeros and gradual underflow, which retains values smaller than the smallest normal floating-point number. The assembly uses separate `FADD` and `FMUL` instructions. It performs no fused operation, division or square root. The floating-point control register, FPCR, must be zero before entry.

## Arguments And Bounds

The entry is `md2asm_accumulate_runtime_coupled_surface_fluxes`. Its application binary interface, or ABI, passes the following addresses in Arm registers.

| Register | Complete readable span | Meaning |
| --- | ---: | --- |
| x0 | 2176 bytes | Genuine coupled-field owner from `md2asm_initialize_runtime_surface_coupling_diagnostics` |
| x1 | 8 bytes | One FP64 time step $`h`$ |
| x2 | 16 bytes | Four signed 32-bit integers: `[P, first, last, global_start]` |
| x3 | 112 bytes | Fourteen 64-bit input-array addresses |

The owner, time step and address bank require eight-byte alignment. The integer record requires four-byte alignment. Each input array has at least $`P`$ consecutive FP64 values and requires eight-byte alignment. The address-bank order is PSTRTU, PSTRTV, PFRTH, PFRSO, PFCLL, PFCLN, PFCS, PDIFTQ, PFPLCL, PFPLCN, PFPLSL, PFPLSN, PRUISS and PRUISP. These arrays may share storage with each other. They must be separate from the output payload.

The block width $`P`$ is in 1 to 128. The selected local cell indices satisfy $`1\leq\mathrm{first}\leq P+1`$ and $`0\leq\mathrm{last}\leq P`$. The positive integer `global_start` maps local index $`j`$ to cell $`\mathrm{global\_start}-1+j`$. Every selected cell in the owned field must be in 1 to $`Q`$, where $`Q`$ is the owner's cell count. When `first` exceeds `last`, the loop is empty and changes no output. The time step is finite and in 0 to 21600 seconds; either signed zero is supported.

## Owned Storage

The owner stores the payload address at byte 0, payload size at byte 8, ready value 1 at byte 16, cell count $`Q`$ at byte 24 and column count $`T`$ at byte 32. These are 64-bit integer words. The cell count is in 1 to $`2^{31}-1`$, and the genuine initializer supports $`T`$ in 1 to 33. The initializer also requires its payload to fit the supplied positive budget, which is at most 64 GiB. These storage bounds do not establish support for every external Geometry producer or forecast resolution. The payload contains $`8Q(19+6T)`$ bytes. The initializer owns its allocation and release; this accumulation child allocates and releases nothing.

There are 23 descriptors at owner byte $`128+88i`$, for index $`i`$ from 0 to 22. Each descriptor starts with the address of its first physical FP64 element. Their order is STRSU, STRSV, FCHAS, FRSOS, FHUMS, RUIST, FCHLL, FCHLN, FCHSS, FHUML, FHUMN, FRLDS, QWPRO, TMAX2, TMIN2, HSNOW, TSUR2, TSTS, TSFL, XPUQ, XPVQ, FCRFTH and FCRFSO. Descriptors 2, 3, 4, 6, 7 and 8 have shape $`Q\times T`$. Descriptors 21 and 22 have shape $`Q\times2`$, with second-dimension lower bound zero. The other descriptors have $`Q`$ elements. The first dimension always has lower bound one and unit stride. Multidimensional arrays store the first dimension consecutively.

The genuine initializer supplies separate output fields and immutable descriptor metadata. Before its first write, this child checks the payload-size formula, the complete first-column span of each of its eleven destinations, every complete input span and integer address overflow. The owner, time step, bounds record and address bank must also be separate from the payload. All argument storage remains readable for the call, and the payload remains writable. These storage obligations include mapped memory; an integer address check alone does not establish that memory is mapped.

## Return And Preserved State

Return value 0 means success. Return value 2 means an admission refusal before any public write or floating-point calculation. The entry preserves x18, x19 through x30, the low 64 bits of v8 through v15, stack alignment, FPCR and the system error value `errno`. It uses a 96-byte stack frame and Armv8.2-A instructions. Normal arithmetic adds its exception flags to the incoming floating-point status register, FPSR. Empty updates and refusals preserve FPSR.

Only the eleven selected totals change. Other fields, unselected cells, input arrays and owner metadata retain every bit. Comparisons use complete little-endian FP64 payload bytes in the owner's physical layout, without rounding or masking the stored outputs.

## Verification And Limits

Six original/native component pairs compare 456432 complete payload bytes with zero differences. They cover an odd block, a shifted partial block, repeated accumulation, width 128, an empty interval and a negative-zero time step. They include subnormal inputs, all 23 arrays, unused columns and unselected cells. Immediate floating-point status, `errno`, saved registers, input bytes and owner metadata are checked. Independent high-precision rate-times-duration relations pass for 1936 selected totals, with a bound that includes every rounded sum and update.

Three malformed owner or destination cases refuse the call before a payload change and preserve the required immediate status. Fifteen additional refusals cover invalid block and output-cell ranges, negative or nonfinite duration, a duration above the admitted limit, wrong FPCR, and overlapping, misaligned or overflowing input spans. These additional checks compare the complete owner, payload, inputs and controls and require every byte and immediate status value to remain unchanged.

The original Fortran control is compiled separately with expression contraction, reassociation and fast-math disabled. It is used only for verification. Production callers must supply the genuine owner for its complete lifetime and select the correct surface views after post-physics calculations. Those caller and lifetime checks, the operational forecast and complete saved-output agreement remain separate requirements. This component result does not establish their acceptance or a forecast performance result.
