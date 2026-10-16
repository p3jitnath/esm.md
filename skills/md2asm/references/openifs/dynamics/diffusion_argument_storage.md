# Diffusion Argument Storage Contract

The source allocates two arrays that describe horizontal diffusion, which mixes nearby air columns. Even when this diffusion scheme is inactive, the grid-point caller passes their addresses to child routines. A real allocated array keeps each argument valid. This component follows the two allocation statements in OpenIFS 48.1.1 `arpifs/setup/sualdynb.F90` lines 172–173.

## Inputs And Interface

The application binary interface, or ABI, sets the argument registers and saved-register duties. `int md2asm_allocate_diffusion_argument_storage(Geometry, geometry_capacity, MODEL, model_capacity)` uses x0 through x3. Geometry holds grid sizes and needs at least 17,096 bytes. MODEL holds the model state and needs at least 4,275,088 bytes. Both complete records align to eight bytes, have nonwrapping address ranges and do not overlap.

The live grid size NGPTOT is the number of horizontal grid points, read from Geometry byte 7,376. Supported sizes are 1 through 1,048,576 points. The selected forecast has 2,048 points. The earlier owned SUDYNA setup must have established LSLHD false at MODEL byte 1,564,212. This logical control disables the optional diffusion scheme. Both incoming owner addresses must be null. FPCR, the Arm floating-point control register, is zero.

## Storage And Source Order

Allocate SLHDA first and SLHDD0 second. Each holds NGPTOT FP64 values, where FP64 means eight-byte floating-point storage. Their ordinary GNU rank-one descriptors start at MODEL bytes 1,565,872 and 1,565,968. Each descriptor occupies 64 bytes, with lower bound one, upper bound NGPTOT and unit element stride. The component writes the same complete descriptor fields as the source allocation. The array payloads remain unwritten. The conditional population in SUDYN is inactive because LSLHD is false, so no numerical diffusion calculation is added.

Call this component at the SUALDYNB storage stage after the saved departure-point allocation and before the first CPG grid-point call. The parent supplies the current live records. Neither captured addresses nor saved array data supply production inputs. Keep the qualified numerical children and all physical settings unchanged.

Publish both new descriptors only after both allocations succeed. If either allocation fails, free any temporary first owner and leave the entire MODEL unchanged. Return zero on success, one on allocation failure and two on an unsupported or invalid input. Admission failures perform no allocation and change no input byte.

## Release And Register Duties

`int md2asm_release_diffusion_argument_storage(MODEL, model_capacity)` uses x0 and x1 with the same MODEL bounds and alignment. Release SLHDD0 before SLHDA and clear only their two owner-address words. It accepts an empty, partial or complete set of owners created by this component and can be called again safely. Call it before MODEL is released, including after a later startup failure. The parent must keep both owners alive through all grid-point consumers.

Allocation uses a 256-byte frame and release uses a 48-byte frame, each aligned to 16 bytes. Preserve x18 through x29, the return address and the required low halves of v8 through v15. The component performs integer address and descriptor operations only. It calls ordinary malloc and free and supplies no original OpenIFS routine. Capture FPCR, FPSR and errno immediately after each successful source and native call for the status comparison.

## Accepted Checks And Limits

Three genuine source-fragment comparisons cover 1, 2,048 and 1,048,576 grid points. The complete MODEL records compare 12,825,264 bytes and complete array owners compare 16,810,000 bytes with zero differences after identifying each independently allocated owner. Nonzero payload preimages remain unchanged, and nonzero descriptor preimages match every source-defined byte. Raw FPCR, FPSR and errno agree, and the native saved-register mask is zero. Reverse release and repeated release pass.

Sixteen critical admission cases leave the complete inputs unchanged. Allocation failure at either malloc call leaves the complete MODEL unchanged and frees every temporary owner. These checks establish this storage component. They add no new physical equation and do not establish a complete autonomous forecast. Local records retain the source version, typed layout, direct build commands and detailed results.

Assemble with `gcc -c -fPIC -march=armv8.2-a src/openifs/setup/diffusion_argument_storage.S -o diffusion_argument_storage.o`, then link the parent and ordinary allocation library. The direct assembly source was authored from the typed interface and source storage statements.
