# Runtime Operational Input State

The assembly input owner attaches initial weather data to the same Geometry, MODEL, FIELDS, configuration and partition that the setup factory created. Geometry describes the grid. MODEL stores configuration and physical constants. FIELDS stores field descriptions and their allocated arrays. This entry does not create a second model or reset completed physics setup.

## Interface And Lifetime

`md2asm_initialize_runtime_operational_input_state` takes six arguments in registers x0 through x5. They are the factory lease, its capacity in bytes, the spectral input path, the surface input path, the upper-air input path and a fresh eight-byte output slot. Paths are null-terminated strings. The factory capacity is at least 6144 bytes. Records and the output slot need eight-byte alignment and complete non-overlapping mapped storage. The entry returns an agreed status in w0 and preserves the Arm saved registers, x18 and the aligned stack. FPCR must be zero. Successful public file and transform calls retain their natural FPSR and errno observations.

A successful call publishes a 128-byte owning lease with phase 120. `md2asm_release_runtime_operational_input_state` takes the original output-slot address and capacity eight in x0 and x1. Weather borrowers must finish first. Release the late physics owner and complete radiation owner before releasing the input owner. Input release also releases the factory through its original creation slot, clears the canonical MODEL alias and nulls both output slots. A partial failed initialization retains its reached owners for the fatal process path. It cannot use the normal phase-120 finalizer or resume initialization.

## Source Order And Storage

The call establishes Lagrangian controls and the main interpolation halo, then creates forecast work, grid-motion fields and spectral fields. It loads spectral data, transforms orography, initializes the surface and grid-point fields, loads upper-air data, converts spectral virtual temperature and allocates the next-time fields. Public ecCodes decodes files and public TRANS performs transforms. Assembly owns the maps, placement, descriptions, storage and call order. Original OpenIFS routines, globals and constructors do not provide these stages. Formatted SPNORM diagnostics remain outside this route.

P is the block width, Q is the local point count, L is the layer count and B is the number of blocks, equal to ceil(Q/P). The current physical route supports P from 1 to 1024 and global L of 137. The accepted operational corpus is TCo1279 with 2560 rows and 6599680 global points. Its surface schema has 81 records. These file and provider limits remain explicit. Wider component bounds do not establish an all-resolution forecast.

The spectral constructor uses live public maps and local counts. Grid-motion field count follows the source flags, including LGRADSP, and is 14 for the accepted input. The upper-air reader uses a private copy of the canonical header with the forecast identity in its expected date fields. The complete canonical surface header remains unchanged. Source-unwritten array bodies and undefined padding remain unread.

## Accepted Check

One genuine 23-process run with one thread per process passed 161 calls through factory, radiation, late physics, all three actual input files and complete normal release. Complete source-shaped descriptions, map copies, defined values, zero planes, ABI and owner relations passed. All observed direct allocations were released, aliases cleared and MPI finalized. Four independent process censuses passed. This is an input lifetime result. It does not establish a complete weather registry, original whole-input byte agreement, a forecast trajectory or comparative performance.
