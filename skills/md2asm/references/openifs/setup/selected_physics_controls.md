# Selected physics controls

`md2asm_initialize_selected_physics_controls` builds the selected 448-byte TEPHY record. TEPHY holds the switches that choose the physical schemes. Assembly writes the source defaults, reads the first NAEPHY group from the live input text, applies the source consistency rules and derives five grid-field counts. It receives no original MODEL record or OpenIFS module state.

| Argument | Meaning |
| --- | --- |
| x0 | Read-only input text |
| x1 | Text length from 1 to 262,144 bytes |
| x2 | Writable TEPHY record with 8-byte alignment |
| x3 | Record capacity of at least 448 bytes |
| x4 | Two read-only four-byte logicals, LSLAG and LUVPOUT, with 8-byte alignment |
| x5 | Five writable four-byte counts with 4-byte alignment |

The caller supplies valid complete buffers. A logical is integer 0 or 1. LSLAG selects the upstream semi-Lagrangian dynamics, which follows moving air parcels, and LUVPOUT requests extra wind output. Each output range must be disjoint from the input ranges and the other output. Input ranges can overlap each other. Checked address additions must not wrap. Return 0 means success. Return 2 means rejection before any output byte changes.

This component follows ECMWF mode with configuration NCONF 1, Meteo-France physics disabled, Held–Suarez forcing disabled and wave coupling disabled. These are selected upstream conditions, not values inferred from a saved forecast. The caller must establish them. The dynamics producer supplies LSLAG, while the configured grid-field output flag supplies LUVPOUT. Other physical records changed by SU0PHY remain separate work.

The 97 member assignments follow `arpifs/setup/su0phy.F90`, including its ECMWF overrides at lines 1463–1521. The default helper preserves LECLIM10D, LFPOS_EC_PHYS, LFPOS_ACC_RESET, YSURF and the padding at bytes 212–215 because SU0PHY does not define those bytes. The enclosing owned record must establish its initial storage policy. YSURF is a pointer slot whose later producer owns the pointed-to surface configuration.

The bounded text reader accepts NALBEDOSCHEME, LEPHYS, LSLPHY, LERADI, LELAIV, LEO3CH, LESNML and NSNMLWS. It supports the actual input file, an empty group, comments beginning with `!`, comma or space separators, mixed-case keys and logical values, and integer values 0–2 with an optional plus sign. The group marker must use the exact uppercase name NAEPHY and be the first nonblank token within the first ten columns. The first accepted NAEPHY group is used, so the later empty duplicate in the actual file does not erase its assignments. Missing groups, incomplete tokens, unknown keys and unsupported values are rejected. Other namelist groups belong to their own producers.

After reading, the parent applies SU0PHY lines 1748–1796. Disabling physics clears LAGPHY, LSLPHY and LEPCLD. Disabling the upstream semi-Lagrangian dynamics clears LSLPHY. Disabling LAGPHY clears LERADIMPL. LEOCLA is cleared because the selected route has no Stokes drift. The count order is NNOGW, NEDRP, NFSD, NUVP and NAEROUT. These follow twice LEGWWMS, twice LDIAGTURB_EC, LRAD_CLOUD_INHOMOG, LUVPOUT and zero. The actual case produces `{2, 0, 0, 0, 0}`. No physical calculation is replaced by a captured value.

All real defaults use the source FP64 literal bits. The helpers perform integer loads, stores and parsing only. FPCR must be zero, selecting round-to-nearest with ties to even and gradual underflow. The complete graph preserves FPSR, errno, x18, the required callee-saved registers and 16-byte stack alignment. The parent uses 576 stack bytes and the nested reader uses 544 more. There are no external calls, undefined symbols or dynamic-library requirements.

Six complete original SU0PHY reference calls compare every returned record and count byte with zero differences, covering the actual file, source defaults, disabled semi-Lagrangian dynamics, disabled physics, comments, alternate supported values and a lowercase group that the source skips. These compare 2,688 record bytes and 120 count bytes through twelve immediate ABI/status probes. Thirty critical input rejections preserve every destination byte and status. Independent checks cover the count equations, source-unwritten members, padding, source literal bits and switch consistency. The original diagnostic and namelist I/O route clears errno and clobbers x18 in these reference calls. Those observed effects are recorded separately from the assembly utility, which preserves its incoming status and x18. This is a physics-control component check, not an autonomous forecast or retirement of the full SU0PHY body.
