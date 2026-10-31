# Typed wave field selection

The adapter selects the original EC_PHYS wave fields from nine source-defined owner records and calls the [accepted numerical child](wave_surface_fields.md). An owner record contains field metadata and addresses whose storage remains valid during the call. It performs no floating-point calculation. The application binary interface (ABI) specifies the registers and memory used for the call. Its entry is `md2asm_prepare_runtime_wave_surface_fields(DIMENSION, MODEL, TSURF, AUX, T, Q, SURF_AND_MORE, FLUX, physical)`. The first eight pointers use x0 through x7 and physical uses the first eight-byte incoming stack word. In argument order, the complete mapped owner sizes are 192, 4275088, 18224, 1992, 728, 728, 13680, 5064 and 520 bytes. Each owner is eight-byte aligned and remains live through the call. Existing legitimate read-only aliases remain allowed, and writable fields retain the original Fortran alias obligations.

The adapter first validates FPCR zero and the Model owner. A false LWCOU returns zero without inspecting other owner payloads. A true value is canonical one. P is the number of allocated horizontal columns, L is the number of vertical levels, and first and last are the inclusive active column indices. They are read from DIMENSION byte offsets 12, 48, 0 and 4, respectively. P is from 1 through 128, L is from 6 through 137, and the nonempty active interval lies inside columns 1 through P. NATMFLX is 1, 2, 3, and neutral/current controls are canonical logical words. The Model member offsets and all typed handles use the independently compiled original type query.

A GNU rank-two descriptor has 88 bytes. Data at byte 0 and signed element offset at byte 8 retain their original meaning. Element size at byte 16 and span at byte 32 are 8 bytes, rank byte 28 is 2 and type byte 29 is 3. Dimension strides are at bytes 40 and 64, lower bounds at bytes 48 and 72 and upper bounds at bytes 56 and 80. The original typed pointers are CONTIGUOUS, so consecutive array elements have adjacent addresses. First stride must equal one, and the second stride must equal upper1 minus lower1 plus one with checked signed arithmetic. Arbitrary admitted lower bounds remain explicit. Checked signed products and sums derive the complete declared first/last element addresses and the selected logical view. Column one uses data+8*(offset+stride1+selected_second*stride2), with byte stride8*stride1. Every multiplication, addition and address conversion rejects overflow. The view must fit the complete declared span. The separate accepted numerical child retains its own wider byte-stride support. This typed entry does not claim a noncontiguous original owner. The caller guarantees this declared backing allocation is mapped and owned.

The source ocean tile is 1. Bottom pressure, temperature, humidity and moisture/heat fluxes select L. Other fields use MP, the signed 32-bit member index stored in the original 64-byte typed handle. Conditional stress, neutral-wind, current and roughness metadata remain unread when the numerical child does not consume their views. The sea-ice backing view is valid, while its payload is read only at source sea points. All required views pass before the numerical child can write, and all unselected table rows remain zero.

The adapter has a 768-byte private frame, including the 432-byte view table. It allocates no heap memory. It preserves x18, all saved general registers, the required saved floating-point registers and the sixteen-byte stack alignment. Integer metadata checks do not change FPCR, FPSR or errno. The accepted child retains natural arithmetic status. Return zero completes the selected wave stage or its false route, and return two refuses checked metadata before any public store.

The critical gate compares the complete typed owners, actual backing arrays, inactive columns and padding with a separate original-source typed Fortran branch. It covers actual bottom L137, another admitted level, shifted columns, odd P, live MP choices and descriptor lower bounds/spacing. It reuses accepted arithmetic checks, protects the owner and backing-array edges, and checks the immediate ABI status, unread owners on the false route and descriptor/handle refusals before any write. No complete caller or forecast is accepted by this adapter contract.

## Exact field selection

SURF in this table means SURF_AND_MORE. Each descriptor offset is measured from the named raw owner. L and the ocean tile 1 are direct second-dimension indices. A numeric TSURF handle offset selects a pointer in TSURF; the signed member index is the first word of its 64-byte target. The last table column uses that member index, not the handle offset itself. The raw owners are forwarded directly from the complete-physics driver, with no additional class-object indirection.

| Child row | Owner | Descriptor byte offset | Second-dimension selector |
| --- | --- | --- | --- |
| 0 | AUX | 448 | L |
| 1 | T | 416 | L |
| 2 | Q | 328 | L |
| 3 | SURF | 10240 | ocean tile 1 |
| 4 | SURF | 10328 | ocean tile 1 |
| 5 | SURF | 9168 | member from TSURF handle at byte 15688 |
| 6 | SURF | 9168 | member from TSURF handle at byte 15696 |
| 7 | SURF | 9168 | member from TSURF handle at byte 15704 |
| 8 | SURF | 9168 | member from TSURF handle at byte 15712 |
| 9 | SURF | 9168 | member from TSURF handle at byte 15720 |
| 10 | SURF | 9168 | member from TSURF handle at byte 15728 |
| 11 | SURF | 9168 | member from TSURF handle at byte 15736 |
| 12 | SURF | 9168 | member from TSURF handle at byte 15744 |
| 13 | SURF | 8992 | member from TSURF handle at byte 14368 |
| 14 | SURF | 8992 | member from TSURF handle at byte 14376 |
| 15 | SURF | 8728 | member from TSURF handle at byte 9176 |
| 16 | SURF | 8728 | member from TSURF handle at byte 9184 |
| 17 | SURF | 8992 | member from TSURF handle at byte 13384 |
| 18 | FLUX | 352 | L |
| 19 | FLUX | 616 | L |
| 20 | SURF | 8728 | member from TSURF handle at byte 8992 |
| 21 | SURF | 8728 | member from TSURF handle at byte 9168 |
| 22 | SURF | 8728 | member from TSURF handle at byte 9152 |

## Component evidence

Three original-source/native pairs cover P24/L19, P17/L137 and P9/L137, including shifted active intervals, live member indices and nondefault lower bounds. All 232000 complete backing-array bytes match, and 25898784 owner and handle bytes remain unchanged. The gate checks 182 independent selection and physical relations, thirteen metadata refusals before any write, and the false route without reading unrelated owners. Return status, FPCR, natural FPSR and errno match, and the native entry preserves its ABI obligations. These checks accept the typed adapter component; the complete EC_PHYS caller, weather/main storage lifetime and operational forecast remain pending. Detailed records remain local.
