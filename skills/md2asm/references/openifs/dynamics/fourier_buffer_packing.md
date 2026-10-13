# Fourier Buffer Packing Contract

Revision 1 freezes FOURIER_IN_MOD::FOURIER_IN and FOURIER_OUT_MOD::FOURIER_OUT for the selected coarse OpenIFS 48.1.1 forecast. The [formulation](../../../../../formulations/openifs/dynamics/fourier_buffer_packing.md) states the unchanged coefficient identity. Original sources are `contrib/ectrans/src/trans/internal/fourier_in_mod.F90` and `fourier_out_mod.F90`. Their source copies, typed layout and pre-emission freeze remain local.

## Method And Scope

Input packing copies the shared Fourier buffer into a local field matrix. Output packing copies that matrix into the next shared buffer. A complex coefficient has two FP64 words, one real and one imaginary. FP64 is the 64-bit floating-point representation. Integer load and store instructions copy these words without arithmetic, preserving signed zero and every other bit pattern.

The supported route has one processor set, 32 latitude rows and wave numbers zero through 21. The field count is positive and at most 136. The matrix has contiguous fields in its first dimension, a positive column stride and one-based bounds. Its complete allocation and the complete shared-buffer allocation must be valid, eight-byte aligned and large enough for every selected word. Input and output allocations are distinct. All distribution tables remain read-only.

Let $`K`$ be the field count, $`k`$ the local latitude index and $`m`$ the wave number. The global latitude index is $`D.\mathrm{NPTRLS}(1)+k-1`$. The largest selected wave comes from $`G.\mathrm{NMEN}`$ at that global latitude. The local real column is $`j=2m+1+D.\mathrm{NSTAGTF}(k)`$ and the imaginary column is $`j+1`$.

The source tables select a buffer block $`b=D.\mathrm{MSTABF}(D.\mathrm{NPROCM}(m))`$. Its word offset is $`s=2K[D.\mathrm{NSTAGT0B}(b)+D.\mathrm{NPNTGTB0}(m,k)]`$ for input packing. Output packing uses NSTAGT1B in the same expression. Field $`f`$ uses buffer words $`s+2f-1`$ and $`s+2f`$. The assembly follows the original mode and field order and leaves every other word unchanged.

## Assembly Interface

The application binary interface, or ABI, states how routines pass arguments and preserve registers. The entries are `md2asm_fourier_in_7358525` and `md2asm_fourier_out_7358525`. Three ordinary addresses arrive in x0, x1 and x2. They identify the local matrix descriptor, the signed 32-bit field count and the signed 32-bit latitude. There is no hidden character length.

The matrix descriptor is an 88-byte GNU Fortran rank-two record. It holds the data pointer at byte 0, signed element offset at byte 8, element size at byte 16, rank at byte 28 and span at byte 32. Dimension records at bytes 40 and 64 each contain signed 64-bit stride, lower bound and upper bound values. Address calculations retain the stored offset and source subscripts. Scalar integers have four-byte alignment.

The module pointers `__tpm_distr_MOD_d` and `__tpm_geometry_MOD_g` identify complete distribution and geometry records of 2,584 and 208 bytes. The selected `__tpm_distr_MOD_mysetw` value is 1. Shared rank-one descriptors are `__tpm_trans_MOD_foubuf` for input and `__tpm_trans_MOD_foubuf_in` for output. These descriptor and index offsets are fixed by the original typed layout.

| Record | Descriptor | Byte offset |
| --- | --- | ---: |
| Distribution | NPROCM | 240 |
| Distribution | MSTABF | 1696 |
| Distribution | NSTAGT0B | 1264 |
| Distribution | NSTAGT1B | 1328 |
| Distribution | NPNTGTB0 | 1392 |
| Distribution | NPTRLS | 1200 |
| Distribution | NSTAGTF | 1000 |
| Geometry | NMEN | 64 |

The assembly checks consumed descriptor types, bounds and table subscripts before each copy. Its 256-byte aligned stack frame saves x18, x30 and the used registers x19 through x28. It leaves x29 and d8 through d15 unchanged. It preserves the floating-point control register, FPCR, the floating-point status register, FPSR, and errno. FPCR is zero in the accepted route. No floating-point instruction, numerical child or high-level numerical fallback supplies the transfer.

The direct body was written as AArch64 assembly and built with an assembler and linker. The published source embeds the eight required layout constants so it needs no extra include file. This publication preserves the accepted machine instructions. `md2asm_fourier_packing_count_get` reports private completed-call counts, which remain outside model output.

## Accepted Checks

The matched 24-hour coarse forecast checks the first actual field-count and latitude tuple for each entry. Input packing passes 192 complete source-first/native pairs over 306,441,984 compared bytes. Output packing passes 160 pairs over 252,005,504 bytes. Each pair compares the full local and shared allocations, descriptors, scalar arguments, distribution record, geometry record and all consumed index-table allocations. Unoccupied and unused words remain in the comparison. Repeated calls with an already-checked tuple retain the original reference route in this verification run.

Before either routine runs, the verifier reconstructs the expected complete destination from the independent source table map. Its 581,504 word-copy relations pass for both the original and assembly paths. Source read-only owners, source and native raw status, saved registers, x18, buffer indices and one completed native call are checked separately. All report zero differences or failures.

All ten saved forecast files match the separately frozen corrected Fortran reference across 618,140 bytes. This accepts the two transfer bodies within the declared route. They add two main-phase storage routines and no weather calculation. Other forecast stages remain in Fortran. Whole-process byte identity, autonomous execution and whole-forecast speed are not established by this checkpoint.

## Build

Assemble the self-contained source with `gcc -fPIC -c src/openifs/dynamics/fourier_buffer_packing.S -o fourier_buffer_packing.o`. Link its object with the caller's frozen transform metadata and runtime. Detailed commands, source versions, the R8 reports and complete saved-file gate remain under ignored `.runtime/`. Compilation and checks use the owned exclusive node.
