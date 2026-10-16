# Standalone Initial Input Bootstrap

Revision 2 implements selected T21 spectral and upper-air input stages in assembly. It is an initialisation checkpoint and does not run a forecast. The assembly process starts without an OpenIFS executable, script, module data owner, constructor or callable. OpenIFS is only a separate verification reference. Linux process services, the C library and the ecCodes GRIB decoder are declared external services.

## Inputs And Owned Storage

The command accepts the original spectral GRIB file, the original grid-point GRIB header file, the upper-air GRIB file and three output paths. The spectral header must report truncation 21 and 19 vertical layers. The grid header must report 32 latitude rows and 64 longitude columns. Both headers must agree on their date, time and forecast step. Truncation limits the number of spherical harmonics, which describe a field as waves on a sphere. The spectral file has 506 stored real coefficients for each field and layer. The grid-point header supplies the corresponding physical-grid metadata. Its numerical payload is not loaded at this checkpoint.

The assembly owns a 5,232-byte header record, a 20,400-byte vertical context, complete selected spectral-field and grid-point contexts and a 1,556,112-byte configuration record. It computes and loads the vertical coordinate through the qualified direct children. It constructs every spectral allocation through the complete selected direct constructor, including integer maps and empty-field owners. No captured model-state packet or original module record is an input. Only the selected configuration members needed by the spectral loader are initialised here. The remaining geometry and model members are not a complete forecast configuration.

The loader uses three three-dimensional fields with GRIB codes 138, 155 and 130, followed by two two-dimensional fields with codes 152 and 129. They represent vorticity, divergence, temperature, logarithmic surface pressure and surface geopotential. It uses eight grid-point tracer controls with incoming-read settings 0, 0, 1, -1, -1, 1, 1 and 1. All eight belong to the grid-point input route and do not request a spectral-to-grid conversion. These selected settings match the frozen forecast configuration. The upper-air fields are loaded through the owned TGFL path. Surface input and complete field-configuration maps remain later stages.

The [header reader](initial_model_file_headers.md), [vertical constructor](../setup/vertical_coordinate_setup.md), [owned vertical context](../setup/vertical_startup_context.md), [spectral constructor](../setup/spectral_field_storage.md) and [spectral loader](spectral_initial_state_loading.md) specify the complete child interfaces and numerical checks.

The [owned upper-air parent](owned_upper_air_initial_state.md) constructs TGFL, sets exactly the source-preserved incoming padding and loads its complete GFL allocation. Its configuration association uses caller-owned storage inside the model configuration record. Only currently consumed fields are constructed; future forecast consumers must wait for the complete field-map producers.

## Arithmetic And Output

The child contracts preserve the accepted FP64 operation order. The floating-point control register must contain zero at entry, which selects round-to-nearest with ties to even, gradual underflow and disabled exception traps on this target. The process checks this value before numerical work. It does not clear or conceal arithmetic status. The three files contain all 230,736 three-dimensional spectral bytes, all 8,096 two-dimensional spectral bytes and all 2,509,824 upper-air owner bytes in their existing little-endian storage order. Output writing uses assembly Linux open, write and close calls, including short writes and interrupted calls. Output is a checkpoint for comparison and is not a forecast product.

The 5,232-byte header record begins with zeroed owned storage. Its reserved and inactive bytes retain that new namespace policy. The accepted header fixture used other incoming byte patterns, so complete-record agreement with that fixture is not claimed. All defined header values and the independently checked hybrid pressures retain their accepted child evidence.

## Interface And Bounds

The assembly entry receives the Linux initial stack and uses the standard C process-start service to call its assembly main function. Main receives an argument count and an argument-vector pointer according to the AArch64 application binary interface. It requires exactly six path arguments. Arguments must be valid C strings and retain the child reader limits. All three inputs must exist and must be distinct from the output paths. Output paths must be distinct. The caller must select writable output paths because successful writes replace existing files.

Main saves x18 and all used callee-saved registers in a 112-byte, 16-byte-aligned frame. The file writer saves its used callee-saved registers in a 64-byte, 16-byte-aligned frame. Every owned context is released after success or failure. A failed process returns a nonzero code and can leave a partially written output file. Invalid input is rejected before output writing.

## Acceptance

Build only the assembly sources and qualified assembly children with the assembler and linker. Start the resulting executable with LD_PRELOAD and LD_LIBRARY_PATH removed. Inspect its complete dynamic-library closure and undefined symbols to establish that no OpenIFS or Fortran runtime participates. Compare all three complete output files directly with the accepted separate reference, requiring zero differing bytes. Exercise an invalid path and a rejected header before publishing this checkpoint. Reuse the children’s independent physical, buffer, numerical-status and ABI checks for unchanged code. Obtain a source and ABI review of the new parent. A successful input checkpoint adds no original-routine credit and does not establish autonomous forecasting or performance.

## Completed Checkpoint

The assembly process starts at its own `_start`, reads the three original GRIB inputs, constructs its own vertical, complete selected spectral and grid-point storage, loads the complete initial fields and writes all three complete numerical owners. All 2,748,656 output bytes agree with the retained separate reference. The new argument-count and missing-upper-air checks reject before any output is created. The unchanged header, missing-file and writer branches retain their earlier focused rejection checks. Independent source and ABI review passes, and all production children have their separate critical checks. No original-routine credit is added.

The executable links only ecCodes and libc directly. Its declared decoder dependencies also load libm, ecCodes in-memory definitions, libaec compression and the Linux dynamic loader. It imports no OpenIFS callable or module data and loads no Fortran runtime, Atlas, MPI or model library. LD_PRELOAD and LD_LIBRARY_PATH are absent from the checked production process. These results establish an autonomous initial spectral and upper-air input stage. Surface input, complete field metadata, full model and geometry construction, transforms, runtime ownership and a complete forecast remain unfinished.

## Build And Run

Use GNU GCC 12.3 as the assembler driver and link only the listed assembly files. Set `esm_eccodes_dir` to the directory containing the qualified ecCodes 2.28.1 C library. The example writes local binaries and output outside Git. Run it through srun in the required owned exclusive allocation.

```bash
mkdir -p .runtime/openifs/standalone_initial
esm_eccodes_dir=/path/to/ecCodes/lib
gcc -nostartfiles -no-pie -Wl,-z,defs \
  src/openifs/input/standalone_initial_bootstrap.S \
  src/openifs/input/initial_model_file_headers.S \
  src/openifs/input/spectral_initial_state_loading.S \
  src/openifs/input/owned_upper_air_initial_state.S \
  src/openifs/input/upper_air_initial_state_loading.S \
  src/openifs/input/upper_air_initial_state_placement.S \
  src/openifs/setup/grid_point_field_storage.S \
  src/openifs/setup/grid_point_field_context.S \
  src/openifs/input/initial_spectral_field_reader.S \
  src/openifs/input/spectral_initial_state_placement.S \
  src/openifs/setup/vertical_startup_context.S \
  src/openifs/setup/vertical_coordinate_setup.S \
  src/openifs/setup/vertical_configuration.S \
  src/openifs/setup/hybrid_coordinate_owners.S \
  src/openifs/setup/hybrid_coordinate_defaults.S \
  src/openifs/setup/default_hybrid_coefficient_tables.S \
  src/openifs/setup/spectral_field_storage.S \
  src/openifs/setup/serial_spectral_wave_distribution.S \
  src/openifs/setup/spectral_field_context.S \
  -L"$esm_eccodes_dir" -Wl,-rpath,"$esm_eccodes_dir" -leccodes \
  -o .runtime/openifs/standalone_initial/initial_bootstrap
env -u LD_PRELOAD -u LD_LIBRARY_PATH \
  .runtime/openifs/standalone_initial/initial_bootstrap \
  /path/to/ICMSHepc8INIT /path/to/ICMGGepc8INIT /path/to/ICMGGepc8INIUA \
  .runtime/openifs/standalone_initial/three_dimensional.bin \
  .runtime/openifs/standalone_initial/two_dimensional.bin \
  .runtime/openifs/standalone_initial/upper_air.bin
```
