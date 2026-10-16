# Owned Complete Initial State

Revision 4 is a selected T21 initialization executable in AArch64 assembly. T21 has a largest spectral wave index of 21. The model has 2,048 horizontal points, 19 atmospheric levels and 86 blocks of 24 rows. The last block has eight physical points and sixteen padding rows. Assembly owns process entry, live configuration, storage, vertical calculations, all initial loading, state output and release. This checkpoint does not advance a forecast.

The command takes ten zero-terminated path arguments in this order. The first four are the actual spectral initial file, grid initial file, upper-air initial file and live fort.4 text. The six output paths are spectral 3D, spectral 2D, upper-air, complete metadata, complete surface state and complete vertical state. The input files are ICMSHepc8INIT, ICMGGepc8INIT and ICMGGepc8INIUA. Assembly reads one through 262,144 namelist bytes through Linux openat, read and close, using an extra byte to detect an overlong file. No saved model-state packet is an input.

## Initialization Order

The accepted header reader establishes the grid, levels, dates and actual A/B pressure coefficients. The owned vertical context constructs its 27 numerical buffers and defines its reference pressure VP00 as 101325 Pa. Physical constants come from their own 520-byte producer. The complete vertical calculation receives the live VP00 word at context byte 20,320 and pi from the constants. These two pressure names have different roles, so the separate 100000 Pa constant RATM is not the vertical reference. The vertical calculation fills all 28 owners, including its new RDERB buffer, and produces dimensionless bounds zero and one.

TDYNA is the dynamics control record, TEPHY holds switches for physical processes, and GFL stores grid-field definitions. The complete 456-byte TDYNA producer reads the live empty NAMDYNA group. Its grid inputs come from the actual header, while its finite-element and derivative controls come from the owned vertical configuration. Its LSLAG word selects the TEPHY physics route, and its LSPRT word supplies the complete grid-field configuration. The selected LUVPOUT input is false. TEPHY reads the live NAEPHY group and must produce counts `{2,0,0,0,0}` and true LEPHYS, LEPCLD and LSLPHY before the selected GFL route starts. The complete 1,359,136-byte GFL namespace remains at GCONF byte 184, with all internal aliases tied to that persistent storage.

The owned clock uses the actual header date and time, a 3600-second step, stop text `t25`, zero NFOST and default trajectory step minus one second. Its NSTOP, the header level count and detected file code supply the remaining GFL controls. Full clock namelist selection remains separate work. The spectral and upper-air readers then fill their owned numerical buffers. Complete surface startup constructs all seventy metadata owners and thirty-four numerical owners, applies source defaults over allocated rows, decodes the actual grid file and places physical values in source order. All initialization succeeds before the first output file opens.

Every outer record starts under its declared owned zero-storage policy. Numerical allocation bytes that the original source leaves untouched retain their actual incoming storage. In particular, 348,288 surface bytes and sixteen vertical I/O-owner bytes await later producers. They must be established before a forecast consumes them. Production adds no allocation fill. Complete source comparisons use explicitly matched incoming storage and include every byte. The verification allocation adapter acts before an owner is returned and is absent from the ordinary executable.

## Output And Interfaces

The three initial-field files contain 230,736 spectral 3D bytes, 8,096 spectral 2D bytes and 2,509,824 upper-air bytes in the accepted field order. The metadata file retains the earlier 1,557,568-byte envelope and appends the following owned records. Offsets are bytes from the beginning of that file, and integers use the selected little-endian format.

| Record | Offset | Bytes |
| --- | ---: | ---: |
| Complete TDYNA | 1,557,568 | 456 |
| Dynamics input controls | 1,558,024 | 32 |
| Vertical reference pressure and pi | 1,558,056 | 16 |
| Vertical bounds | 1,558,072 | 16 |
| Bound-output addresses | 1,558,088 | 16 |
| Physics input controls | 1,558,104 | 8 |

The earlier envelope stores GCONF, TEPHY, its count outputs, constants, field effects, immediate GFL status, clock state, clock inputs and GFL controls. Its complete layout stays frozen. The new total is 1,558,112 bytes. Metadata and state streams are verification outputs only. They retain raw live addresses and incoming source-unwritten bytes, so they are not portable restart files or canonical forecast files.

The surface stream uses the [complete surface format](../output/surface_state_stream_writing.md), with 9,350,128 bytes and 104 owners. The vertical stream starts with `VS28OWN1`, then the complete 20,400-byte context and 28 records containing the live 64-bit address, logical byte extent and complete owner payload. Its total is 43,616 bytes. Owner order is the existing 27-owner context order followed by RDERB. Every initialized numerical value remains a literal byte comparison. Actual allocation addresses use explicit owner identity and byte-offset correspondence only.

The application binary interface (ABI) defines argument locations and preserved registers. The floating-point control register (FPCR) selects arithmetic rules, while the floating-point status register (FPSR) records numerical events such as rounding. The `_start` entry uses libc process startup and calls assembly main through the standard argc/argv interface. Main has a 112-byte aligned frame. The text reader uses 64 bytes, the state-file adapter 48 bytes and the private vertical writer 80 bytes. Each child retains its own declared ABI, complete buffer bounds, alignment and register obligations. The parent preserves x18 and all saved registers, requires FPCR zero and retains the frozen FP64 order. GFL status is captured immediately at its return. Its actual input case returns FPCR zero, FPSR sixteen and errno zero without forced status values.

Cleanup releases the surface numerical owners before surface metadata. It releases the additional RDERB buffer before the original 27-owner vertical context, and retains the existing spectral and upper-air release rules. Existing input and setup error classes remain. The new vertical, dynamics and surface stages use bases 232, 236 and 240 plus child status. Vertical and surface stream writes use bases 244 and 248. Main returns that integer status, and the operating system exposes its low eight bits. A failed write can leave earlier complete files or a partial current file. No numerical fallback is present.

## Acceptance And Limits

The complete changed entry matches 2,748,656 initial-field bytes from retained genuine controls. A separate process maps genuine SUGFL1, SUGFL2 and SUGFL3 at the actual production namespace address and matches all 1,359,136 bytes, including pointers and natural status. The complete TDYNA record matches all 456 genuine source bytes. Source controls also match all 9,348,456 surface record and owner bytes, 22,760 vertical numerical bytes, 20,400 context bytes and sixteen bound bytes. These checks total 13,499,880 complete bytes with zero differences. Only real owner addresses use their declared correspondence. No numerical value is rounded, masked or repaired.

The ordinary allocation executable and separate matched-preimage executable both complete using only a PATH environment variable. The new dynamics rejection occurs after vertical acquisition and before all output. A failed surface stream write returns through cleanup and leaves the later vertical file absent. Existing child bounds, allocation-failure, status, ABI and independent physical checks are reused. Complete cleanup call order has a separate source review. There is no claim of a new runtime heap-count measurement.

The final ELF link contains 85 direct assembly objects. Its production library closure contains libc, ecCodes and its codec dependencies, with no OpenIFS library, harness or Fortran runtime. The separate source controls may use original libraries for verification. Full geometry, remaining model configuration and the autonomous time loop still need integration. No forecast, original-body credit, performance comparison or optimization is claimed by this input checkpoint.

The [vertical graph](../setup/owned_vertical_system_contract.md), [dynamics controls](../setup/selected_dynamics_controls.md), [surface startup](../setup/owned_surface_state_startup.md) and [complete grid-field configuration](../setup/selected_grid_field_configuration.md) define the reused children. Local records retain build commands, fixed layouts and actual check results.
