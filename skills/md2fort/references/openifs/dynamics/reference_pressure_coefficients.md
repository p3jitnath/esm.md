# Reference Pressure Coefficients

This component builds the fixed reference atmosphere used by the semi-implicit time update. That update treats fast pressure waves through a linear operator. Its pressure weights describe the reference atmosphere rather than the current weather. The physical units are pascals, Pa, for pressure, kelvin, K, for temperature and square metres per square second for geopotential.

The source is OpenIFS 48.1.1. Selected SUDYN assignments choose the reference state. The first seven SUALDYN allocation statements provide its arrays. SUSI section 1.1 then calls GPHPRE and fills the complete pressure coefficients. This component preserves those source calculations. The subsequent matrix and vertical-mode calculations are separate stages and remain required.

## Live Inputs And Source Selection

The caller supplies complete owned Geometry and MODEL records, containing at least 17,096 and 4,275,088 bytes. Both align to eight bytes, have nonwrapping address ranges and do not overlap. NFLEVG at Geometry byte 5,224 is the number of vertical levels, supported from one through 255. The actual forecast has 19 levels. All borrowed arrays and fixed-size input views are mapped for their complete declared extents, have the required alignment and remain disjoint from mutable outputs.

The earlier owned vertical setup supplies a genuine TVAB record at Geometry pointer slot 3,240 and a TCVER record at slot 3,264. Their coefficient arrays, descriptor rules and numerical limits follow the accepted GPHPRE contract. TVAB holds hybrid pressure coefficients, which combine a fixed pressure term with a fraction of surface pressure. TCVER selects the vertical method. The source coefficient descriptors remain read-only throughout this component. The existing owned dynamics-map producer supplies the GPHPRE field map `[1,2,3,4,5,6,7,7]` and its seven-field count. The child reads the existing owned TOPPRES, RD and RCVD constants through their named bindings.

The platform input contains four int32 values NCONF, LECMWF, LR2D and LR3D, with selected values `[1,1,0,1]`. Separate borrowed inputs point to the owned RD value and the owned LELAM logical value, which is false. RD is the dry-air gas constant in joules per kilogram per kelvin. It must equal the constant supplied to GPHPRE. The live dynamics producer supplies LSLAG and LTWOTL true and LNHDYN false. These flags select the global hydrostatic, semi-Lagrangian, two-time-level route. The earlier successful empty first NAMDYN and NAMDYNA admission is required, so their source defaults have no unhandled override. NSTOP at MODEL byte 1,359,332 is positive. This makes the source NSTOP-or-LDFI condition true without reading LDFI.

## Three Assembly Stages

The application binary interface, or ABI, defines argument registers and saved-register duties. `int md2asm_initialize_reference_atmosphere_controls(Geometry, geometry_capacity, MODEL, model_capacity, platform16, RD_pointer, LELAM_pointer)` uses x0 through x6. Platform and LELAM align to four bytes, and RD aligns to eight bytes. RD and RSTRET, the dimensionless grid-stretch factor at Geometry byte 7,512, are finite and positive. VAH contains level one and has a finite nonnegative value there. TCVER LVERTFE is a canonical zero or one.

The control stage preserves the original test of half VAH at level one against 100 Pa. It selects SITR 350 K when this pressure is below the threshold or finite elements are active, and 300 K otherwise. SIPR is 100,000 Pa on both admitted branches. It sets SITRA equal to SITR, NOPT_SITRA zero and VNORM 0.04 from the ECMWF source branch. It computes SIRPRG as the separately rounded RD times SITR and SIRPRN as one divided by SIPR. LSIDG uses the original stretched-grid test with threshold 100 times the smallest normal FP64 number, the admitted NCONF and positive NSTOP. LESIDG receives the source false assignment for a global domain. A stretched-grid result can be true, in which case the later source-selected Helmholtz setup remains required.

`int md2asm_allocate_reference_pressure_coefficients(Geometry, geometry_capacity, MODEL, model_capacity)` uses x0 through x3. All seven incoming owner addresses must be null. An owner is the complete allocated array. Allocate each array in the source order shown below, with eight-byte FP64 values. Build ordinary GNU rank-one descriptors, with unit element stride. Publish all seven descriptors only after every allocation succeeds. If allocation fails, free the temporary owners in reverse order and preserve the complete MODEL. Every acquired payload byte remains unwritten until the calculation stage.

| Array | MODEL descriptor byte | Bounds | Meaning and units |
| --- | ---: | --- | --- |
| SIALPH | 1,567,192 | 1 through levels | Local pressure coefficient, dimensionless |
| SILNPR | 1,567,256 | 1 through levels | Pressure logarithm coefficient, dimensionless |
| SIDELP | 1,567,320 | 1 through levels | Reference layer pressure weight, Pa |
| SIRDEL | 1,567,384 | 1 through levels | Inverse layer pressure weight, inverse Pa |
| SITLAH | 1,567,448 | 0 through levels | Boundary reference pressure, Pa |
| SITLAF | 1,567,512 | 1 through levels | Effective full-level pressure, Pa |
| SIDPHI | 1,567,576 | 1 through levels | Reference geopotential weight, square metres per square second |

`int md2asm_initialize_reference_pressure_coefficients(Geometry, geometry_capacity, MODEL, model_capacity, RD_pointer)` uses x0 through x4. It borrows the seven live owners, their exact admitted shapes and positive finite SITR and SIPR. The owner payloads, both records, input coefficient owners and private scratch do not overlap. Its private scratch holds the one-column half pressures, full pressures and seven GPHPRE fields. Set only the bottom half pressure to SIPR, then call the unchanged accepted direct GPHPRE entry with one column and the original optional outputs present.

The first increasing-level loop copies SIDELP, SIRDEL, SILNPR and SIALPH from the corresponding GPHPRE fields, and copies each lower boundary pressure into SITLAH. The second loop sets SITLAF to SIDELP divided by SILNPR, then forms SIDPHI as RD times SITR followed by multiplication by SILNPR, with a separate rounding after each multiplication. Finally copy the top pressure into SITLAH at level zero. Preserve the two source loops and every output bit. Reuse the accepted GPHPRE independent pressure checks, rather than replacing a supplied pressure weight with a different formula.

The parent order is reference controls, these seven SUALDYN owners, the later matrix owners, these SUSI pressure coefficients, and then the remaining SUSI matrix and vertical-mode calculations. Keep every owner alive through its forecast consumers. This explicit split allows the parent to retain source order without a new orchestration layer.

## Release, Status And Registers

`int md2asm_release_reference_pressure_coefficients(MODEL, model_capacity)` uses x0 and x1 with the same MODEL bounds and alignment. It frees SIDPHI through SIALPH in reverse allocation order and clears only their seven owner-address words. It accepts empty or completed storage and can be called again safely. Release later matrix owners before these earlier pressure owners, then release MODEL after all its consumers stop.

Return zero means success, one means allocation failure, and two means an unsupported input before mutation. The allocation stage is transactional. A failure to acquire the calculation scratch leaves the complete MODEL and all seven payloads unchanged. Existing accepted GPHPRE allocation behaviour remains its child contract. The controls stage uses no frame, allocation uses 192 bytes, calculation uses 160 bytes and release uses 48 bytes. All frames align to 16 bytes. Preserve x18 through x29, the return address and the required low halves of v8 through v15. Use FPCR zero, nearest rounding with ties to even, gradual underflow and signed zeros. Do not fuse, reassociate or reduce precision. The only production calls are accepted direct GPHPRE, malloc and free.

## Accepted Checks And Limits

The genuine source gate compares all three stages on the actual 19-level finite-element input, a three-level conventional input and a 255-level input. A focused extra comparison covers the one-level minimum. It compares complete MODEL records and every complete coefficient owner at each stage, with zero differing bytes after identifying corresponding allocation addresses. Nonzero descriptor and payload preimages remain part of the comparison. Immediate FPCR, FPSR and errno agree, and all native saved-register masks are zero. Source compiler x18 differences remain explicit in the local records. Reverse and repeated release pass.

Four focused source comparisons cover both neighbours and the exact 100 Pa threshold, the overriding finite-element flag and both directions away from an unstretched grid. Thirteen critical refusals leave complete inputs unchanged. Forced failure at each of the seven owner allocations and at the calculation scratch allocation preserves every existing output byte and frees each temporary owner. Finite positive pressure checks and an independent 80-digit isothermal hydrostatic calculation supplement the unchanged child pressure proof. These establish the named control, storage and pressure stage. They do not establish the remaining SUSI matrices or a complete autonomous forecast.

Assemble with `gcc -c -fPIC src/openifs/setup/reference_pressure_coefficients.S -o reference_pressure_coefficients.o`, then link the accepted direct pressure child, its existing owned constant bindings and ordinary allocation services. Local records retain the exact source versions, typed layout, independent checks, build commands and complete comparison results.
