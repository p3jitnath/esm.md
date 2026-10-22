# Operational Spectral Field Placement

This component copies decoded wave coefficients into the model arrays for 137 atmospheric layers and truncation 1279. A spectral coefficient is one stored wave value. The input has 413 records, each with 1,639,680 FP64 words. FP64 means IEEE binary64. Its order is logarithmic surface pressure, then vorticity, divergence and temperature for each layer, then orography. There is no humidity tail. The [reader](initial_spectral_field_reader.md) and [owned constructor](../setup/spectral_field_storage.md) are separate stages. Use their canonical field order, 138, 155, 130 and 152, 129, when connecting these arrays. The original smaller [placement](spectral_initial_state_placement.md) remains unchanged.

For zero-based layer $`l`$, field $`f`$, coefficient $`c`$ and surface slot $`s`$, the record and destination word positions are

```math
r=1+3l+f,\qquad w_3=l+137(c+1639680f),\qquad w_2=c+1639680s.
```

Their ranges are $`0\leq l<137`$, $`0\leq f<3`$, $`0\leq c<1639680`$ and $`0\leq s<2`$. Records 0 and 412 fill the two surface slots. Vorticity and divergence use inverse seconds, temperature uses kelvin, logarithmic pressure is dimensionless and orography geopotential uses square metres per square second. Each assignment copies all 64 bits without changing units or coefficient normalization.

## Interface And Bounds

The entry md2asm_place_operational_spectral_fields takes values, values_bytes, metadata, metadata_bytes, pspec3, pspec3_bytes, pspec2 and pspec2_bytes in registers x0 through x7. Capacities are unsigned 64-bit byte counts, and metadata has three signed 64-bit words per record, parameter identifier, layer and value count. The four pointers are nonnull, eight-byte aligned and mapped for their complete extents.

| Buffer | Fixed extent in bytes | Layout |
| --- | ---: | --- |
| values | 5,417,502,720 | coefficient then record |
| metadata | 9,912 | parameter, layer, count for each record |
| pspec3 | 5,391,267,840 | layer then coefficient then field |
| pspec2 | 26,234,880 | coefficient then surface slot |

Inputs may overlap each other. Each output is disjoint from both complete inputs and the other output. Larger tails stay unchanged. Before any store, validate pointers, alignment, capacities, unsigned address wrap, output overlap and every metadata row. Required rows are (152,1), then (138,l),(155,l),(130,l) for layers 1 through 137, then (129,0), each with count 1,639,680. Return zero after complete placement, one for a buffer refusal and two for a metadata mismatch. Refusal changes no owner bytes.

The leaf uses no stack, child call or external service. It preserves x18 through x30, all vector registers, FPCR, FPSR and errno. FPCR controls floating-point arithmetic, while FPSR records numerical events. Integer copies leave both unchanged. Sizes and addresses use 64-bit registers, including the 5,404,385,280-byte final input-record offset and 3,594,178,560-byte third-field offset. Field, layer and coefficient loop order is unchanged, followed by the two surface copies. The instruction target is Armv8.2-A.

## Source Correspondence And Checks

The separate metadata-driven Fortran control retains SPEC_IN's original whole-row assignments, PSPEC3(ILOCLV,:,IFF)=ZSPECG(:,IIFLD) and PSPEC2(:,IFF)=ZSPECG(:,IIFLD), with the operational dimensions and heap inputs. The selected serial distribution preserves coefficient order. SPNORM reads these values for diagnostics and does not normalize them.

One complete finite bit-pattern corpus, including positive and negative zero, gives zero differing bytes across all 5,417,502,720 output bytes. Every input value is checked, and both inputs are read-only during calls. Independent index checks cover all 677,187,840 output words. All 278,856 guard and padding bytes remain intact. Three native ABI/status calls pass with zero masks, including a one-byte-short values capacity and a wrong final metadata count, both with complete no-write agreement. The original reference's x18 change is recorded separately. FPCR zero, incoming FPSR 24 and errno 777 are preserved. The native library has no external dependency. This qualifies placement only, with no field-loading caller, initial model state, geometry, complete forecast or performance claim.
