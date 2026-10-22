# Operational grid field configuration

`md2asm_initialize_operational_grid_field_configuration(gfl, constants, text, text_bytes, controls, effects)` constructs the complete declared grid-field namespace for 137 vertical layers. A namespace is a record of field descriptions, options, names and links; it does not contain weather values. The source boundary is the selected `SUGFL1`, `SUDEFO_GFLATTR`, `SUCTRL_GFLATTR`, `SUGFL2` and `SUGFL3` path. The existing [19-layer entry](selected_grid_field_configuration.md) remains unchanged.

The application binary interface (ABI) uses Arm registers x0 through x5 in the argument order above. `gfl` is a fresh, zero-filled, writable 1,359,136-byte allocation. `constants` is the qualified read-only 520-byte physical-constant record. `text` contains 1–262,144 exact input bytes. `controls` contains nine read-only four-byte integers, and `effects` contains ten writable four-byte integers. All starts except text have eight-byte alignment. The caller supplies complete mapped buffers. Every complete address range must avoid wrap; each writable range must be disjoint from the inputs and the other output. Read-only inputs may overlap each other. All five ranges and seven output-overlap pairs are checked before controls are read or public output is changed.

| Control position | Required value | Meaning |
| --- | --- | --- |
| 1 | 137 | Vertical layers |
| 2 | 0 | Supplementary layers |
| 3 | Positive signed int32 | Explicit stopping-step count, `NSTOP` |
| 4 | 1 | GRIB file-format code |
| 5 | 1 | `LSPRT` |
| 6 | 0 | `LTRAJHR` |
| 7 | 1 | Configuration code `NCONF` |
| 8 | 1 | ECMWF mode, `LECMWF` |
| 9 | 1 | Ozone chemistry prerequisite, `LEO3CH` |

The selected source reads `NSTOP` only through eight positive-count predicates. Any positive signed int32 therefore takes the same configuration branches; this child does not choose a forecast duration. The domain also retains the qualified source settings `LSLAG`, `LTWOTL`, `LRHSVWENO`, `LEPHYS`, `LSLPHY` and `LEPCLD` true, with inactive limited-area, forcing, two-dimensional, plane, digital-filter and composition branches. The non-orographic gravity-wave count is two; other transported chemistry, greenhouse-gas and aerosol counts remain zero. `LEO3CH` true requires the ozone grid-point profile to be active.

The entry constructs the nine [default profiles](selected_grid_field_profile_defaults.md), applies the first supported [NAMGFL group](selected_grid_field_namelist.md), checks ozone activity and rain/snow input request 1, then calls [nine-field registration](operational_grid_field_registration.md). It completes the namespace through [operational inactive defaults](operational_inactive_grid_defaults.md). These inactive stores occupy disjoint slots, so their source bit copies can follow registration. All complete profile, component, association, map, scalar, pointer and inactive bytes are outputs. Each returned pointer refers to this persistent record. No original global, captured namespace image or temporary profile address supplies production state.

The ten effect words are `LVSPLIP`, `LSPLTHOIGFL`, `NSV_CHEMBEG`, `NSV_CHEMEND`, `NSV_DSTBEG`, `NSV_DSTEND`, `NSV_DSTDEPBEG`, `NSV_DSTDEPEND`, `NSV_AERBEG` and `NSV_AEREND`, in that order. All are zero in the declared domain. The complete 40-byte output is owned by the caller. The assembly uses integer metadata operations, a 2,416-byte aligned frame and a 5,104-byte maximum direct nested stack bound. It preserves x18, x19–x29, required SIMD registers, SP alignment, FPCR, FPSR and errno. FPCR must be zero, selecting round-to-nearest with ties to even and gradual underflow. Return 0 means success, 2 is a checked no-write refusal, and 3 is an unexpected child rejection after construction starts; discard the record after return 3. The graph needs only qualified direct assembly children, with no allocator, original library, libc or Fortran runtime.

Four genuine-source and direct cases used the same safe record address in separate processes, with `NSTOP` 192 and 576 and two incoming flag profiles. All 5,436,544 namespace bytes and 160 effect bytes match exactly, including raw pointers. The qualified constant producer naturally supplied final FPCR/FPSR/errno states 0/16/0 and 0/24/0; status was captured without replacing it with expected values. All six native ABI observations have zero masks. Two refusals cover zero `NSTOP` and inactive ozone, with complete outputs unchanged. Inputs, guards and native bytes outside the namespace remain unchanged; 48 control/effect relations pass. The separate source x18 exception remains recorded. Eager symbol binding precedes status seeding. The original inactive-helper rejection and its minimal nine-field correction remain in the local records.

Existing complete metadata, literal-kind and scientific evidence for unchanged children is reused. The source reference records and frees its separate `YAERO_DESC(1)` allocation before reusing the enclosing record. This assembly child does not construct other chemistry, composition or radiation owners, reproduce file-I/O or console output, claim a complete `SUGFL1` body, admit a parent or run a forecast. Detailed source, build, failure and acceptance records remain under `.runtime/`.
