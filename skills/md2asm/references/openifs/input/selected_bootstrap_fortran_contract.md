# Selected Fortran Bootstrap Contract

Revision 1 preserves the selected forecast mathematics and retires the eight private diagnostic streams under an explicit user instruction. The physical model and its ordered numerical children are unchanged. The Fortran entry replaces the process startup and orchestration role of standalone_initial_bootstrap.

The supported case is T21/L19 with 2,048 horizontal points, a padded row pitch of 24, 86 row blocks and one MPI process. The original input begins on 15 October 2004. The existing controller performs one initial weather call and 24 one-hour updates. Constructors derive array sizes from the live input and retain their selected-case admission limits. This contract does not claim another resolution or process count.

The program takes seven paths: spectral input, surface input, upper-air input, fort.4 configuration, resource namelist, journal prefix and data directory. The separate resource namelist changes byte ceilings and memory-node placement only. The program owns scientific startup, input loading, all numerical stages, normal weather output and source-order release. An original OpenIFS numerical routine or verification wrapper must not supply a missing stage.

The selected startup runs the accepted native SUPHY2 producer before SUPHEC. SUPHY2 sets the setup physics interval TSPHY to 1, and the existing time-update producer owns later interval changes. All other numerical child calls retain their source order and frozen arithmetic.

Use FP64, nearest-even rounding and gradual underflow. Disable fused multiply-add, contraction, reassociation, approximate division and square root, reduced precision and fast-math. The compiler owns processor instructions and native descriptors. Public MPI, OpenMP, file, mesh, transform, mathematical and language-runtime interfaces remain external. Recompile the full source graph on each architecture.

The required outputs are the normal ICMSHepc8+HHHHHH and ICMUAepc8+HHHHHH files at hours 0, 6, 12, 18 and 24, where HHHHHH has six decimal digits. Their expected ten-file total in the frozen selected reference is 618,140 bytes. Preserve field order, packing and deterministic metadata. Require zero differing bytes against the separate OpenIFS Fortran reference before numerical acceptance or performance measurement.

The former spectral three-dimensional, spectral two-dimensional, upper-air, metadata, surface, vertical, physics and setup diagnostic streams are omitted. Their private binary layouts, raw AArch64 status words and appended history section are not requirements of this Fortran route. This retirement does not remove numerical state owners or calculation stages.

The source and [source manifest](../../../../../src/openifs/input/standalone_bootstrap/source_manifest.json) are published under src/openifs/input/standalone_bootstrap. Six changed units passed strict Arm compilation, and their complete selected executable linked with unchanged numerical helpers. Complete forecast comparison and x86 compilation remain pending. Retain the existing independent physical checks and perform exact state and normal-output comparison before claiming acceptance.
