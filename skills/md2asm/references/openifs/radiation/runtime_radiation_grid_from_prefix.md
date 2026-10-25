# Runtime radiation controls to grid shape

This component publishes the early radiation interpolation controls into their actual MODEL members, resets two later counters in source order, and calls the unchanged computed-grid constructor. It connects the accepted [early radiation prefix](runtime_radiation_control_prefix.md) to [computed grid shape](radiation_grid_shape.md). It stops after selected source statements through line 1501, before `SETUP_TRANS` at line 1503. It adds no floating-point arithmetic or numerical provider.

A namespace is an owned record that stores scalar values used by several calculations. RI and RO name the two original interpolation records. A halo contains extra grid cells used during interpolation. The early prefix returns a 744-byte namespace separately from MODEL. The new publisher connects twelve four-byte words in that record to the corresponding MODEL members. It copies the eight north, south, west and east halo widths, which are zero, and the two true LSLONDEM choices. These ten values come from original SUECRAD assignments 491–498 and 923–924. It then sets both NASLB1 words to zero in MODEL and the namespace, following original statements 1326–1327. It does not copy radiation point counts or later fields. The independent typed layout keeps west and east distinct.

The application binary interface, or ABI, defines arguments and register rules. `md2asm_publish_runtime_radiation_interpolation_controls` receives MODEL, MODEL capacity, namespace and namespace capacity in x0 through x3. MODEL requires 4,275,088 bytes and the namespace requires 744 bytes. Both complete spans must be live, mapped, aligned to eight bytes, nonwrapping and separate. The caller retains both owners. Before writing, the publisher checks those address bounds, the ten source-selected values, actual LERADI true, NRADINT two or three and LECOMPGRID true. Incoming NASLB1 words are not read. Success returns zero; refusal returns two before any public write. This leaf uses no stack or external call. It preserves x18, all callee-saved registers, the floating-point control and status registers, and errno.

| Member | Namespace byte | MODEL byte |
| --- | --- | --- |
| RI NSLWIDEN |688|4123916|
| RI NSLWIDES |692|4123920|
| RI NSLWIDEW |696|4123928|
| RI NSLWIDEE |700|4123924|
| RI LSLONDEM |704|4123600|
| RI NASLB1 |708|4123584|
| RO NSLWIDEN |712|4125716|
| RO NSLWIDES |716|4125720|
| RO NSLWIDEW |720|4125728|
| RO NSLWIDEE |724|4125724|
| RO LSLONDEM |728|4125400|
| RO NASLB1 |732|4125384|

`md2asm_create_runtime_radiation_grid_from_prefix` receives Geometry, Geometry capacity, MODEL, MODEL capacity, namespace and namespace capacity in x0 through x5. Geometry requires 20,400 bytes. Its complete span and the two output spans must be live, mapped, aligned, nonwrapping and separate. These are raw caller prerequisites. The wrapper first calls the publisher, then forwards the same Geometry and MODEL to the unchanged grid constructor. Its 80-byte frame preserves x18, saved registers and sixteen-byte stack alignment. The unchanged child adds 112 stack bytes, excluding library work. The floating-point control register FPCR must be zero. No timestep is consumed and no resolution is compiled into either new entry.

The grid child's existing bounds and allocation rules remain unchanged. It reads live NDGLG and NSMAX from Geometry, and the produced NRADINT, NRADRES and LECOMPGRID from MODEL. The actual header/SUDIM producer supplies NDGLG 2560 at Geometry byte 4872 and NSMAX 1279 at byte 5172. The accepted prefix supplies NRADINT 3, NRADRES 0 and LECOMPGRID true. The unchanged source default table therefore selects NRADRES 799 and 800 radiation rows. NRGRI owns 3,200 bytes; NLOENG owns 3,216 bytes, including the four polar rows. `md2asm_release_runtime_radiation_grid_shape(MODEL,capacity)` releases NLOENG before NRGRI and clears their bases. Both owners stay live until release.

A publisher refusal leaves both records unchanged. After publication succeeds, its twelve MODEL words and two namespace reset words remain published even if the grid child refuses or cannot allocate. The wrapper forwards the child's zero, one or two result. The child's own atomic allocation rollback is unchanged. There is no whole-wrapper atomicity promise. The caller must retain or discard this partly advanced state according to the declared source order.

The checked input route uses accepted MODEL, FIELDS, configuration, vertical/SUDIM, physical and dynamical constructors with actual headers and namelist text. It calls the accepted early prefix on five actual MODEL subrecords plus the separate namespace and climate record. The actual ozone and configuration address proofs remain those of that prefix. No driver patches a MODEL control or invents a horizontal field. The Geometry owner is sufficient for the consumed scalar metadata; it is not a completed horizontal loaded-weather owner. The three Planck allocations, climate selection, configuration, FIELDS, dynamical record and every borrowed input remain live and unchanged during the bridge and grid stages. Grid owners are released before Planck and factory owners.

The independent verification helper uses original typed MODEL member assignments for all twelve words, followed by the exact unchanged selected shape source. Its two extra namespace stores encode the original typed NASLB1 values for comparison; these stores are verification-only metadata encoding. They do not supply a production stage. The source helper and build are frozen before the first new call. The original main Fortran executable is unchanged, and no earlier prefix or Planck scientific bank is replayed.

Two actual source/native composition pairs pass, with the namespace at opposite protected placements. Each route checks 17,114,672 complete MODEL, namespace, grid payload and released MODEL bytes. Only the two new owner base words receive typed address correspondence, after all 6,416 payload bytes agree in each case. Every other MODEL byte is also constrained to the exact source-declared mutable windows. Independent integer checks pass 3,340 relations across both routes, including row lengths, symmetry, total size, polar copies and the twelve scalar relations. Unchanged child mathematical and allocation-failure proofs are reused.

Source and native create and release return zero with ABI mask zero, FPCR zero, FPSR 24 and errno 777. No status is masked. Two additional full-MODEL endpoint fixtures check the new stores without claiming another actual producer. Seventeen focused publisher refusals preserve every public byte. One wrapper witness makes the unchanged child refuse and proves that all earlier scalar publications persist, both new owner bases stay null, and raw status is preserved. All grid, Planck and factory owners close.

The gate enforces 8 GiB address space, 4 GiB resident memory, 8 GiB node/job memory and 240/255-second process/controller deadlines, with 0.2-second sampling. One GiB is 2 to the power 30 bytes. These are enforcement limits; no analytic public-library memory bound or timing comparison is claimed. Both new public objects reproduce the qualified objects exactly; existing default, prefix, shape and numerical objects remain unchanged.

This component does not call the public transform or execute a four-rank setup. Later transform inquiry, Gaussian and point fields, halo/interpolation communication, radiation coefficients, aerosol/climate/ecRad setup and the complete SUECRAD caller remain separate. It does not accept complete CALLPAR, loaded-weather physics or a forecast.
