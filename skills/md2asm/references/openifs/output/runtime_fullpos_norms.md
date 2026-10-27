# Runtime Fullpos Norms

Fullpos prepares model fields for output. A norm summarises a field through values such as its mean, minimum and maximum. These four direct AArch64 entries retain FPSPNORMS, FPGPNORM, EXTFPF and EXTFPNORM for one model domain. Public MPI moves data between processes, while FIAT and ECTRANS provide the selected communication and transform services. No original OpenIFS routine or global supplies a production calculation.

## Interface And Storage

The application binary interface, or ABI, follows AArch64 Linux. Incoming stack offsets below are in bytes, before the entry creates its private frame. Each appended context occupies 128 bytes.

| Entry | Original address arguments | Incoming hidden character lengths | Incoming context |
| --- | ---: | --- | ---: |
| `md2asm_runtime_fullpos_spectral_norms` | 9 | 8, 16, 24 | 32 |
| `md2asm_runtime_fullpos_grid_norms` | 15 | 56, 64, 72, 80 | 88 |
| `md2asm_runtime_extract_fullpos_fields` | 13 | None | 40 |
| `md2asm_runtime_extract_fullpos_norms` | 13 | None | 40 |

Domain names have 32 bytes, prefixes have 8 and field names have 12. The context borrows the live 4,096-byte partition at offset 40, the false profiling flag at 80 and a positive remaining byte budget at 96, at most 64 GiB. One GiB is 1,073,741,824 bytes. Context offset 120 remains owned by packing. Every input and output span must stay mapped, separate and live through return. A GNU array descriptor stores its buffer address, bounds and strides, which give the spacing between elements. These interfaces require the declared dense descriptors and complete point maps.

The supported process count is 1 to 65,536, spectral degree is 1 to 8,191, field count is 1 to 65,536 and grid block width is 1 to 1,024. The positive global point count fits a signed 32-bit integer. A process can have zero local points or zero fields. Each global point must occur exactly once in the complete map. There is one domain and each field names it. Non-surface fields supply uppercase P, V, T or S configuration and their levels. The physical all-surface grid route can omit both levels and configuration.

The controllers reserve 1,632 bytes for their frame and largest private helper. Field extraction reserves 896 bytes plus its staged global fields, peer send and receive buffers, and coverage bitset. Norm extraction reserves 1,152 bytes plus global fields, byte masks, reciprocal counts, peer triples and master staging. It subtracts these live bytes before passing the remaining budget to field extraction. Complete buffer sizes come from the live point and field counts. External-library storage and stacks remain covered by the separate process resource limits.

## Calculations And Results

FP64 means 64-bit floating point. Field extraction retains every FP64 bit through source field-major packing and global-point placement in a deterministic MPI peer ring. Norms select values different from the largest finite FP64 missing marker. They form every reciprocal count before the sums, then sum each field in ascending global-point order and multiply by its reciprocal. Separate ordered minimum and maximum passes preserve the source handling of NaNs, infinities, signed zero and equal values. A NaN has no ordinary numerical order. Field-owner triples reach the source master in process order. Communication does not replace these calculations with a different reduction.

The spectral controller applies the source epsilon threshold before level conversion. The grid controller converts each non-surface level before its absolute-value thresholds. V multiplies by 10,000,000 before the original nearest-integer conversion. Raw and adjusted values remain separate. Entries preserve x18, saved Arm registers, 16-byte stack alignment and FPCR, the floating-point control register. FPSR, which records numerical events, and the service error indicator retain their natural effects.

The 80-byte `md2asm_runtime_fullpos_norm_results` owner keeps a cookie at 0, borrowed partition at 8, spectral pointer, byte count and field count at 16, 24 and 32, and grid pointer, byte count, domain count and field count at 40, 48, 56 and 60. One-based rank, process count and generation occupy 64, 68 and 72. Only rank 1 owns numerical payloads. Spectral storage contains raw then adjusted means, 16 bytes per field. Grid storage contains raw mean, minimum and maximum planes followed by their adjusted planes, 48 bytes per field. A successful replacement publishes after common status agreement and then releases its previous same-kind payload. A failed call preserves the previous owner.

`md2asm_release_runtime_fullpos_norm_results(context128)` checks the live partition, frees both payloads and clears the owner before partition teardown. Repeated release is permitted. Return 0 succeeds, 1 reports allocation refusal and 2 reports invalid metadata. A public MPI transport failure terminates the enclosing forecast.

## Accepted Checks And Limits

One component check accepted 145 observations at process counts 1 and 4, using a small genuine T21 public resolution, 7 mapped global points, block widths 1, 2 and 1,024, partial blocks, empty local owners and 5, 8 or 1 grid fields. All 87,664 compared output bytes and 55 immediate source and assembly status pairs agree. The check retained 593 independent mapping, arithmetic and ownership relations. Cases cover missing values, mixed and all NaNs, infinities, signed zero, epsilon thresholds, result replacement, release and budget refusals. Saved registers, buffer guards and process cleanup pass. This evidence accepts the component, while the complete output path, other numerical resolutions and full forecast remain separate requirements.
