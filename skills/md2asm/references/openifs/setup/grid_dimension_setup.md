# Grid Dimension Setup

This contract covers SUDIM for a global spherical forecast with LECMWF true and LELAM false. It reads the first NAMDIM group in fort.4, then computes horizontal grid sizes, spectral coefficient counts and vertical level counts. A spectral coefficient describes one wave in the global model. This setup changes integer metadata and does not change a physical equation.

## Inputs And Route

The raw entry receives a writable complete Geometry record, eleven 32-bit setup words, twelve 32-bit namelist values and a 12-bit presence mask. The setup words are LOPT_SCALAR, LREPRO4DVAR, the selected supersede flag, LIOLEVG, LR2D, NCONF, NUSMAX, NUDGL, NUDLON, NUCMAX and NUFLEV, in that order. A supersede flag of one means that the initial-file dimensions override the namelist where the source requires it. The namelist order is NDGLG, NDLON, NDGUXG, NDLUXG, NFLEVG, NIOLEVG, NVARMAX, NMSMAX, NSMAX, NCMAX, NPROMA and NSTENCILWIDE. All values are dimensionless integers.

The original entry accepts Geometry and the optional KSUPERSEDE pointer. It reads live scalar setup data and the actual fort.4 file, then calls only direct assembly and declared C file/allocation services. These live scalar inputs are a temporary compatibility boundary, not a complete autonomous model constructor. No original callable, constructor or type descriptor supplies a result.

The parser accepts case-insensitive group and field names, scalar signed decimal integers, comma or whitespace separators and exclamation comments. It selects the first line-leading NAMDIM group, as the retained source route does. Repeated fields use the last assigned value within that group. Unsupported names, expressions, array assignments, malformed groups and out-of-range integers are rejected before the geometry changes. Other groups and later duplicate groups do not supply values.

## Ordered Integer Update

The implementation follows source defaults, optional initial-file overrides, namelist assignments, horizontal corrections and vertical corrections in source order. NPROMA zero restores the CPU-dependent default. Its sign sets LOPTPROMA before the absolute value is stored. The spectral counts are NSEFRE=(NSMAX+1)^2, NSPECG=(NSMAX+1)(NSMAX+2)/2 and NSPEC2G=2*NSPECG. NDGNH=(NDGLG+1)/2 uses integer division. Extra latitude rows follow NSTENCILWIDE. Vertical counts obey the original input-file, LIOLEVG, LR2D and NCONF rules, followed by NFLSUL, NFLSA and NFLEN.

The supported domain uses canonical logical words, positive selected grid and level sizes, signed integers that do not overflow the declared updates, and a stencil from zero through JPSLWIDE=48. Grid and level sizes are bounded by 1,048,576 and NSMAX by 8,191. The parser still recognises the complete signed 32-bit integer range before these semantic checks. All complete source-written Geometry words must agree exactly. Every other byte retains its incoming value. There is no floating-point arithmetic, reduction, output repair or numerical fallback. The direct entry preserves the incoming floating-point control and status words.

## Interface And Acceptance

The raw interface uses x0 for Geometry, x1 for setup words, x2 for namelist values and w3 for the presence mask. It returns zero on success and two on an unsupported input. Geometry is at least 8-byte aligned and the integer buffers are at least 4-byte aligned. All buffers must cover their complete declared sizes and must not overlap. The implementation preserves the AArch64 callee-saved registers, x18 and the stack alignment. The original wrapper fails before a forecast on unsupported configuration rather than forwarding to Fortran.

Acceptance requires complete raw record comparison against the unchanged original SUDIM body, distinct incoming record patterns, original interface and status checks, buffer guards, parser cases and independent integer/grid identities. A combined forecast must then retain all 685 complete owners and all ten saved files with zero differing bytes. Original diagnostic log formatting is outside the canonical saved-output contract and does not supply forecast data. No acceptance or autonomy claim is made before those checks pass.

## Verification Record

The unchanged source body is arpifs/setup/sudim.F90. A separate Fortran control supplies only scalar setup inputs and a scratch namelist. It does not calculate dimensions for the assembly. The protected LREPRO4DVAR control word is set through its exported scalar address only in that verification process. Typed source queries establish complete Geometry size 17,096 bytes and every written member offset.

The raw source comparison passes 36 complete records, 615,456 bytes and 72 immediate ABI/status calls. Cases cover both incoming record patterns, file overrides, default and signed block sizes, the original single-level rules, zero spectral truncation and stencil edges. Independent sums check wave counts, while independent row lengths and vertical count identities check the derived layout. Three original-entry source comparisons pass another 51,288 complete bytes, six ABI/status calls and both forms of the optional argument. Eight parser cases include the actual 3,137-byte configuration file, with fourteen unsupported groups rejected before output mutation. Complete input files, readonly buffers, surrounding guards and source-unwritten Geometry bytes remain unchanged. Independent source review and the selected complete forecast comparison pass.

The raw prepared-value control removes its verification-only scratch-file error effect. A separate native-status control restores the entry error indicator immediately before the genuine source call, captures its immediate return and preserves that value through fixture cleanup. The source file-reading entry returns errno zero from seed 34, with unchanged FPCR/FPSR. The native wrapper now returns that measured source-success state. All three complete native input cases were checked again against this genuine boundary, while unchanged raw arithmetic checks were reused.

The [complete forecast comparison](../../../../../src/openifs/README.md#verification) passes for this selected route, with every final owner and saved file compared. Original startup and remaining runtime services still prevent an autonomous-executable claim.
