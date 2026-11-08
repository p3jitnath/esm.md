# Operational forecast handoff

This record supports migration to a 64-bit x86 system. The generated CPU calculations use Fortran; the compiler generates assembly and machine code. The original OpenIFS Fortran remains the separate numerical reference. No x86 build or execution was performed here.

## State at handoff

| Item | Result |
| --- | --- |
| CPU source roles with compiled Fortran replacements | 1,203 / 1,203 |
| Accepted component byte checks | 471, within their recorded input limits |
| Step 0 numerical byte verification | Pending |
| Old CPU assembly archived | 1,203 files |
| Legacy bootstrap debug streams | Eight omitted by user instruction |
| x86 validation | Pending |

The [source corpus](src/openifs/source_layout.md) and [ordered catalog](src/openifs/source_catalog.json) distinguish selected sources, alternatives and five unresolved source mappings. Do not compile competing versions of a module together. Old CPU assembly is retained locally under `.archive/openifs_assembly/`, with original paths, sizes and hashes in `archive_manifest.json`. GPU and other-model assembly are retained.

The [small bootstrap](src/openifs/input/standalone_bootstrap/README.md) is the completed T21, 19-layer, one-process entry. A bootstrap loads inputs and starts the forecast. Its seven paths select spectral input, surface input, upper-air input, configuration, resource limits, journal prefix and data directory. It owns setup, the selected time loop, normal output and release. Its Fortran source compiles and links; its trajectory has not passed numerical comparison. The old twelve-path interface and private debug streams are retired.

The current verification target is step 0 only. The reference step completed, while comparison with the native Fortran remains pending. The larger operational case remains TCo1279, 137 layers and 32 processes. MPI, the Message Passing Interface, coordinates those processes. The latest reference uses four CPU nodes, eight processes per node and one numerical thread per process.

## Corrections to retain

The native parent omitted the existing physics-time producer and passed zero to physics setup. The corrected parent calls that producer, initializing 23 fields. All 32 observed native processes then received the source-defined one-second setup interval and progressed to radiation. The separate integration clock remains unchanged.

The saved radiation refusal is stage 15. Input selects albedo scheme 2; the previous adapter admitted only scheme 1. The [new radiation source](src/openifs/physics/radiation_configuration_albedo_schemes_one_and_two.f90) admits both and uses the original expression to select nearest or weighted spectral albedo. Coefficients and call order are unchanged. This change compiles and links; its numerical acceptance is pending.

The cloud-optics caller also supplied two readonly integer counts from inside the record that the child updates. The accepted child correctly refused the overlap. The caller now copies the counts into separate local integers before the call; the child guard and calculations are unchanged. The corrected [physics parent](src/openifs/physics/physics_work_and_forcing/native_clock_physics_setup/owned_ecmwf_physics_setup_native_clock_waves.f90) strictly compiles and links.

All 32 observed processes then completed the full physics setup with status zero, including radiation, cloud and tail setup. This bounded check intentionally stopped before weather calculation. It establishes the repaired initialization path, not step-0 byte agreement.

Retain three corrected source/provider identities: scientific setup `a67f2762`, radiation configuration `2874f27a` and physics parent `fb09903a`. The physics-parent published source is `92268f78`. The old observed executable `7e23530c` does not itself contain these changes. Rebuild the coherent source graph on x86; do not copy Arm binaries.

## x86 rebuild

Rebuild every module and external library with the target compiler. Do not reuse Arm executables, object files or compiler module files. An ABI is the compiler's binary calling convention. Array descriptors and derived-type layouts must come from a consistent build. The new bootstrap omits the unsafe eight-byte Arm floating-environment observer.

Local selected-source and build inventories are under `.runtime/openifs/fortran_port_20261107/verification8197119/portable_x86_handoff/`. They retain 31 unresolved build-output mappings explicitly. Recorded commands describe the Arm build: replace old directory prefixes and processor flags, retain strict arithmetic settings, and resolve dependencies before linking.

Dependencies include MPI, ecCodes, NetCDF, mesh and transform services, ecRad, BLAS, LAPACK and language runtimes. Preserve their declared operations, versions and thread settings. Keep operating-system bindings, including GNU libc error access, separate from portable physics.

Preserve FP64, nearest-even rounding, gradual underflow and signed zeros. Disable contraction, fused multiply-add, reassociation, approximate division and square root, and fast math. Retain the strict GNU Fortran options, including `-ffp-contract=off`. Equal source does not establish equal output across processors or mathematical libraries.

Keep resolution, strides and sizes in runtime metadata. Respect each entry's supported bounds. Rebuild for the architecture, not for each resolution. Derive core placement and memory policy from the new machine instead of copying the old core numbers or NUMA-domain list.

## Inputs and verification

Copy frozen inputs and required data, not symbolic links back to this machine. The matched-input record is `.runtime/openifs/fortran_port_20261107/forecast_comparison_revision1/root_shared_capture_revision1/matched_input_and_native_resource_freeze_revision1.json`. Case inventories are retained under `verification8197119/four_node_selective_heap/`. Preserve namelist and data bytes; keep large data and rebuilt dependencies outside Git.

The ordinary-RAM reference exceeded its memory limit even without a debugger. Individual original processes reached about 58–64 GB. These are observed values, not a full-forecast bound. Qualified selective file backing reduced fixed memory to roughly 200–241 GB per node. GB means one billion bytes. On x86, provide enough RAM or rebuild and qualify that storage service; its Arm shared object is not portable.

The first capture run stopped with 32 initial states but no completed-step checkpoint. The later direct reference completed step 0 at 16:44:45 UTC, entered step 1 and stopped at its preset deadline at 16:44:53. All 32 process identities are proved closed. The reference retains the declared leaf-carbon, soil and cloud corrections and strict mathematical-library providers in the frozen launch metadata.

The step-0 saved-output target is the three complete `+000000` files: ICMSH 2,221,466,600 bytes, ICMGG 932,239,944 bytes and ICMUA 2,086,488,208 bytes. Explicit close records and the original writer/flush/counter ordering place all three before the step-0 end. Compare every byte, with zero excluded bytes. File presence alone did not prove closure; ICMGG received late appended fields. The full reference forecast did not finish. Keep the frozen NSTOP=2 configuration while narrowing acceptance to step 0; NSTOP=0 selects different operation flags.

Next, run corrected native initialization and compare step 0 with the separate reference. Require zero differing complete saved-file bytes, with independent physical checks. The direct reference retained no raw post-step-0 checkpoint, so full-state byte verification still requires a fresh checkpoint; GRIB files do not replace that evidence. Reuse passed checks for unchanged calculations. Report the first differing stage, field, cell and bit pattern; do not round, mask or repair differences.

Byte comparison rules are reusable. Old debugger entry hooks use Arm register conventions and must be replaced or qualified for x86. Prefer compiler-declared recording interfaces.

## Formatting and final outcome

fprettify 0.3.7 processed 1,616 public CPU Fortran files: 1,375 changed, 241 already formatted and zero failures. All passed source-token preservation and formatter idempotence. Eighteen ordinary-comment groups were placed before continued headers; no numerical tokens changed. The receipt is `.runtime/formatting/FORMATTER_FROZEN_SOURCE_INVENTORY.json`. Preformat provenance is retained separately from formatted public-source hashes; relocation preserves source identities.

Reference step 0 completed; step 1 and the full forecast did not. Step-0 saved files are closed. Native saved-output and full-state byte verification remain pending. The exact step-0 evidence is retained under `verification8197119/step0_saved_output_scope/`. The portable build/input metadata export is `.agents/handoff/operational_x86_20261108/`; its README and index describe normalized path roots and unresolved mappings.

The user extended the wrap-up deadline to 18:00 UTC on 8 November 2026. The original four-node allocation is released. Successor job 8204865 owns two CPU nodes for a bounded corrected-initialization check and handoff work. Its cleanup starts at 17:44:28, cancellation is due at 17:49:28 and its scheduler end is 17:54:28. Finish all work, commit and push before 18:00 UTC. CPU sources are now grouped in 11 physical themes, with artificial porting and version suffixes removed. There are 1,283 active files, representing 1,270 distinct source byte sequences; 193 duplicate copies were consolidated and 138 superseded versions archived. Thirteen extension-specific build pairs preserve preprocessing defaults. Module and routine identifiers and numerical source bytes are unchanged. There is no fortran/ staging directory. GPU files remain in place.
