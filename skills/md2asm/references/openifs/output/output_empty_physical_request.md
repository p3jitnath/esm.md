# Empty physical output request allocation

The direct entry `md2asm_allocate_empty_physical_request` implements the zero-field branch of `ALLOCATE_FPRQPHY` from `arpifs/module/type_fprqphys.F90`. It receives a genuine GNU Fortran 12 `TRQFP` record of 744 bytes in x0 and a domain count from 1 through 8 by value in w1. The eight selected allocatable components must be unallocated. It sets NFIELDG to zero and allocates ICOD, IGRIB, LLSURF, CLNAME, CLPREF, IVEC, IDOM and IDMP in that source order. Each owner has zero logical payload bytes and uses one byte of allocated backing. ZLEV, IVSETG, IVLOCG, NFIELDL and all other record bytes remain unchanged.

Each associated descriptor is complete: its source element length, type, rank, span, lower bounds, upper bounds, strides and offset are written. Rank-one bounds are 1:0. IDMP has shape `(domains,0)`, lower bounds `(1,1)`, strides `(1,domains)` in elements and offset `-1-domains`. Character element lengths are 12 for CLNAME and 8 for CLPREF; integer and logical element lengths are 4 bytes. No payload value is supplied or read.

The entry uses a 144-byte aligned stack frame and preserves x18, the saved integer registers, FPCR, FPSR and errno. It calls only libc malloc and the errno-slot service. There is no floating-point calculation or original Fortran call. Allocation failure or an unsupported argument exits with raw status 116. The serial integer getter `md2asm_empty_physical_request_count_get(void)` returns completed allocations. This child is composed locally into the auxiliary service; it adds no standalone original public alias.

Three source comparisons use domains 1, 2 and 8, complete 744-byte records and six source/direct ABI probes. The comparison changes only the identities of the eight newly allocated owner pointers. All 2,232 remaining record bytes agree, with saved-register masks zero and raw FPCR/FPSR/errno preserved. The original typed control remains verification only. The selected complete forecast check passes.

The [complete forecast check](../../../../../src/openifs/README.md#verification) passes for the selected route. Its declared upstream data and branch limits remain in force.
