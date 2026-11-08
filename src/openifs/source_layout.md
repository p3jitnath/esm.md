# OpenIFS Source Layout

The generated CPU Fortran sources are grouped by physical theme under this directory. The [ordered source catalog](source_catalog.json) records 1203 compiled historical source-file counterparts and 471 scoped component checks. The current forecast target is step 0. Zero of one requested complete Fortran steps have passed byte comparison with the separate OpenIFS reference. Source compilation, formatting and file layout do not establish numerical acceptance.

The layout retains 1283 active source files with 1270 distinct byte sequences. It consolidates 193 identical copies and preserves 13 extension-specific build pairs. The 138 superseded source versions remain locally under .archive/openifs_fortran_alternatives/, with their original bytes, hashes and replacement mapping. Unique components remain published even when the current forecast does not call them. All 830 rows in the retained selected build inventory still resolve to active files. Five historical source-to-family associations remain explicit gaps in the catalog.

The main folders are dynamics, convection, input, output, physics, radiation, setup, spectral_transforms, support, surface and transport. Their subfolders describe a physical calculation, stored state or build purpose. A few supported interfaces need separate files, such as fixed-grid and runtime-grid readers, standard and extended file paths, or borrowed albedo vectors and owned coupling state. Their module and routine names remain unchanged, so each build must select the matching interface and its callers. Compiling every active variant together can define a module more than once.

The [standalone bootstrap](input/standalone_bootstrap/README.md) is a separate ten-unit aggregate for its declared one-process, nineteen-level input. Its source and strict build are complete. Its seven arguments replace the older twelve-path diagnostic interface. The operational production and observation graphs retain their own supported dimensions and process counts.

The user omitted eight private debug outputs: the three raw field files, legacy metadata, SS104OW1, VS28OWN1, PH21REC1 and SETUPR61 with its R19 append. These formats are omitted rather than verified. Normal forecast GRIB output and the required state-byte comparison remain in scope. The replaced CPU assembly is archived under .archive/openifs_assembly/, with its original repository-relative paths; it is not an input to a new Fortran build.

To follow a historical source identifier, read its source_family entry, then resolve each origin through source_files. An active row gives published_path; a superseded row gives archive_path. The source_relocations list records every old public path, its new location and the unchanged content hash. Local evidence and separate comparison sources are not active solver files. OPENIFS_SOURCE_ROOT denotes a separately supplied OpenIFS source checkout when a reference or public interface source remains external.

## Rebuild For Another Processor

Rebuild the Fortran sources and every required library interface with the target compiler. A compiler module file, whose name ends in .mod, describes that compiler's types and interfaces. Object files and shared libraries contain machine code. None of these files can be transferred from the Arm build as an x86 replacement.

Preserve filename extension case and the recorded preprocessing settings. GNU Fortran normally preprocesses .F90 files, while .f90 files need an explicit preprocessing option when they contain directives. The layout retains both extension-specific paths for identical source bytes when the retained builds used different defaults. Carry each selected build's macro definitions and include paths to the target compiler.

Keep target options separate from arithmetic options. The recorded Arm build uses processor options such as -mcpu=neoverse-v2 and -ffixed-x18; select suitable target options when rebuilding. Retain the frozen arithmetic requirements, including separate multiplication and addition, ordered FP64 calculations, nearest-even rounding and gradual underflow. The recorded GNU arithmetic options include -ffp-contract=off, -fno-fast-math, -fprotect-parens and -frounding-math.

Build each selected module in a fresh module-output directory and rebuild its dependants with that same interface revision. Rebuild the required MPI, transform, file-format, mathematical and radiation interfaces for the target. The separate build inventory records current source inputs and unresolved build mappings. It does not claim a completed x86 build.

The new standalone entry uses Fortran IEEE facilities and does not read processor registers. Its retired two-word fegetenv observer is not linked. Some sources retain GNU libc interfaces such as __errno_location; these operating-system interfaces need a matching runtime. The optional memory-backing service and local debugger adapters also need target-specific qualification. Arm register names in local capture tools are not an x86 calling convention.

Select both current generated corrections listed in the catalog: the physics-time producer parent and the radiation albedo-scheme correction. They are strict compiled source candidates. Their numerical acceptance remains pending.

Freeze the target's input bytes, configuration, providers, arithmetic and field encoding before comparison with the separately built OpenIFS reference. Compare defined states and saved outputs directly with zero differing bytes. Keep numerical acceptance separate from source compilation, formatting and file packaging, then measure performance only after the required comparisons pass.
