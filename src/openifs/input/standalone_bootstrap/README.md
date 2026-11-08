# Selected Fortran Forecast Bootstrap

This program owns the selected T21/L19 forecast. T21 keeps spherical patterns up to degree 21, and L19 uses 19 atmospheric layers. The case has 2,048 horizontal points and one process. Its controller performs the initial weather call and 24 one-hour updates. The program creates the scientific state, loads the four inputs, runs the existing numerical stages and releases their storage.

The command takes seven paths in this order:

    selected_forecast SPECTRAL SURFACE UPPER_AIR CONFIGURATION RESOURCE_LIMITS JOURNAL_PREFIX DATA_DIRECTORY

The first three inputs are the original spectral, surface and upper-air GRIB files. CONFIGURATION is fort.4. RESOURCE_LIMITS is the separate memory namelist described below. JOURNAL_PREFIX names the local input-admission records. DATA_DIRECTORY contains the ifsdata directory. The working directory also supplies the selected climate file ICMCLepc8INIT. Use one MPI process and OMP_NUM_THREADS=1. The existing runtime configuration selects the normal weather-output names.

The eight old private diagnostic streams were retired by an explicit user instruction. The program does not write their spectral, upper-air, metadata, surface, vertical, physics or setup files, and it does not append their R19 history section. Their twelve-path command interface and raw AArch64 floating-status record are outside this route. The normal forecast outputs remain owned by the numerical time loop.

The resource namelist sets byte ceilings and allowed Linux memory-node numbers. It does not set physical parameters, array dimensions or time steps. The existing input owners derive their sizes from live metadata and check fresh physical and process-group memory limits. Memory-node numbers and capacities must describe the target machine; they are not processor-register or private-record offsets.

[The source manifest](source_manifest.json) gives the ten source units, their order and their hashes. Six units are new or changed joins. Geometry, field loading, the 25-call controller and release reuse their existing Fortran source. Build the existing numerical modules first, then compile these units in manifest order. An MPI-enabled Fortran compiler, OpenMP and the declared public input, mesh, transform, linear-algebra and mathematical libraries are required. Use the strict portable flags in the manifest. Keep processor-specific flags outside the source, and rebuild every module and library for the target architecture.

The source uses native Fortran owners and compiler-generated process startup. Its initial floating-point check uses standard Fortran IEEE facilities. No inline Arm instructions, private Arm byte layout or eight-byte C floating-environment record are used by this bootstrap route.

Before formatting, all six changed units compiled with the retained strict Arm compiler settings, and the complete executable linked. A complete forecast comparison has not been performed for this new entry. No x86 compilation or execution is claimed. The [solver contract](../../../../skills/md2asm/references/openifs/input/selected_bootstrap_fortran_contract.md) records the numerical and output requirements.

The published CPU Fortran was formatted with fprettify 0.3.7. The formatting pass preserved compiler tokens and passed idempotence checks. The source manifest keeps both formatted hashes and the earlier build-source hashes. Formatting adds no numerical acceptance and was not followed by a forecast run.
