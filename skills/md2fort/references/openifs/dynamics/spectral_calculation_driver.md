# Spectral Calculation Driver Contract

Revision 1 freezes SPCM, TRMTOS and TRSTOM for the selected coarse OpenIFS 48.1.1 forecast. The [formulation](../../../../../formulations/openifs/dynamics/spectral_calculation_driver.md) groups the unchanged physical equations. Original sources are `arpifs/control/spcm.F90`, `arpifs/parallel/trmtos.F90` and `arpifs/parallel/trstom.F90`. Source versions, typed record layouts, frozen controls and detailed checks remain local.

## Method And Scope

The selected forecast uses configuration A, one process and one thread, with 19 atmospheric levels and 506 spectral words. It has 22 longitude modes and degrees through 21. The non-hydrostatic calculation and diagnostic rate storage are inactive. LIMPF is 1, LSIDG is 0 and LGRADSP is 1. The declared source and native routes share these exact controls and complete allocated coefficient tables.

SPCM prepares the implicit rotation correction, copies the level fields to the local work view, performs the coupled wave update, copies its fields back, completes the rotation correction, applies the selected spectral filter and applies horizontal diffusion. The original numerical order is retained. Its direct children are the accepted [SPCIMPFINIT](spcimpfinit.md), [SPCSI](spectral_semi_implicit_update.md), [SPCIMPFPOST](spcimpfpost.md), [SPFILT](spfilt.md) and [SPCHOR](spectral_horizontal_diffusion.md). Their equations, ordered operations, rounded constants and physical checks remain frozen.

TRMTOS and TRSTOM implement equation SCD-1 with integer loads and stores. For this one-process route, each present 19-by-506 field keeps its level and wave indices, and pressure keeps its 506 indices. Vorticity, divergence, temperature and the auxiliary rotation field are active. Unused non-hydrostatic fields, selected-field packs and aerosol packs are excluded. A present unused descriptor is preserved without reading its data. Optional absent addresses remain null.

The driver owns one 546,504-byte workspace. It holds a 506-value pressure copy, seven 19-by-506 arrays, a 506-value pressure work array and three one-value inactive diagnostic arrays. Every value uses the 64-bit floating-point representation, FP64. The driver allocates and frees this workspace and creates the array descriptors required by its children. Inactive uninitialised scratch is excluded from returned physical fields.

## Assembly Interface

The application binary interface, or ABI, states how calls pass arguments and preserve registers. `md2asm_spectral_calculation_driver_7358525` takes geometry, Model, the configuration character, the spectral record and GMV addresses in x0 through x4. The hidden character length arrives in x5 and must be 1. Its stack frame has 2,048 bytes.

`md2asm_spectral_level_to_column_7358525` retains TRMTOS's 28 ordinary addresses. `md2asm_spectral_column_to_level_7358525` retains TRSTOM's 29 addresses, including its final optional pressure-selection address. There is no hidden character length. The first eight addresses use x0 through x7, and the rest use consecutive eight-byte stack slots. Each body has a 512-byte stack frame.

Both copy interfaces start with geometry and two non-hydrostatic logical addresses. TRMTOS then takes the eleven level-view addresses, the corresponding eleven local-view addresses and three optional selection logical addresses. TRSTOM reverses those two field groups and adds the optional pressure logical address. The field order is vorticity, divergence, temperature, two pressure-difference fields, the non-hydrostatic field, constituents, pressure, the auxiliary rotation field and two selected-field packs. Unused groups have the exact null or retained inactive descriptors prescribed by the caller.

A GNU rank-two descriptor has 88 bytes. It records the data address, signed element offset, eight-byte element size, rank, strides and bounds. Every selected two-dimensional view is contiguous with first stride 1, second stride 19, 19 rows and 506 columns. Pressure is a contiguous 506-value rank-one view. Buffers are eight-byte aligned and have valid complete allocations. Copy source and destination are disjoint, and all record and table reads remain inside their complete owners. Descriptor bytes and unused output bytes remain unchanged.

An owner is a complete allocated buffer or object. Complete typed geometry and Model records supply field offsets and consumed controls. In particular, the source-typed full NPTRSV integer table at geometry descriptor offset 5,576 and RLAPDI FP64 table at offset 4,104 remain read-only. Their actual allocated bounds and all other accepted child table bounds remain part of the caller's input contract.

The bodies preserve x18, x19 through x30 and the required low 64 bits of d8 through d15. Stack alignment is 16 bytes. Numerical children use round-to-nearest with ties to even, gradual underflow and preserved signed zeros, with FPCR equal to zero. Contraction and reassociation are forbidden. The copy instructions preserve every bit and floating-point status. The verifier records FPCR, FPSR and errno immediately at return, before observation.

Numerical calls use private direct assembly entries. Source Model and field metadata, DR_HOOK profiling events and GSTATS events remain declared runtime services in this checkpoint. Allocation uses malloc and free. No original numerical routine supplies an omitted stage. The executable still requires the surrounding OpenIFS forecast and does not establish autonomous execution.

## Checks And Current Limit

R12 passes all 25 SPCM source-first/native calls over 117,642,025 complete owner bytes, with zero byte, raw status, ABI or stage-count failures. The seven direct stage totals are 550, 25, 25, 25, 550, 25 and 25 in the order listed above. The source uses the accepted original-only unfused SPCSI baseline. All ten saved files match the separately frozen corrected reference over 618,140 bytes.

The two copy bodies pass four protected-buffer cases using retained physical fields. The independent source identity map checks 155,848 values and 1,246,784 copied bytes. Inactive payloads and complete descriptors remain unchanged. Distinct preserved registers, x18 and raw status also pass. The unchanged children's independent physical and buffer-bound proofs are reused.

The complete geometry-table gate passes 50 read-only views over 5,200 bytes for NPTRSV and RLAPDI. All 48 declared owners, array descriptors and inactive bytes are included. These three accepted bodies add three main-phase routines, including one local calculation, and no weather routine. The unchanged child proofs are reused, and other forecast stages remain outside this contract.

## Build

Assemble each of the three self-contained sources with `gcc -c -fPIC -march=armv8-a+simd src/openifs/dynamics/NAME.S -o NAME.o`. Compile the accepted rotation preparation, rotation correction and filter with their documented private entry-name definitions, then link the accepted wave and diffusion children with the caller's frozen metadata and runtime. Exact build commands and source versions remain under ignored `.runtime/`. Publication preserves the accepted machine text and relocation meanings.
