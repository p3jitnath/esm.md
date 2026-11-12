# Runtime Physics Work Shape Counts

A shape count states the number of array elements along one direction. This small binding stage reads the eight counts passed to seven self-owned physics work records in `EC_PHYS_DRV`, lines 419–427. It writes no weather value, constructs no work record and performs no radiation arithmetic. Every count is a dimensionless signed int32 value.

The application binary interface, or ABI, is `int md2asm_bind_runtime_physics_work_shape_counts(output32, Geometry20400, MODEL4275088, TSURF18224, dimensions192, configuration67616)`, using x0 through x5. Each number is the complete byte extent of that mapped record. All six addresses are nonnull and eight-byte aligned, each complete extent is nonwrapping, and all six complete spans are pairwise disjoint. Every input is read-only and remains live through the call. The output can contain arbitrary bytes before entry.

| Output byte | Count | Actual source | Source byte | Expected current value |
| ---: | --- | --- | ---: | ---: |
| 0 | NLEV | Geometry YRDIMV NFLEVG | 5,224 | 137 |
| 4 | NLEVS | TSURF YSP_SBD NLEVS | 5,888 | 4 |
| 8 | NACTAERO | MODEL YRML_GFL NACTAERO | 304 | 0 |
| 12 | NPAERODIAG | YOE_AERODIAG source parameter | original line 24 | 8 |
| 16 | NLEVSN | MODEL YRML_PHY_G YRDPHY NCSNEC | 1,577,392 | 5 |
| 20 | NTILES | MODEL YRML_PHY_G YRDPHY NTILES | 1,577,396 | 9 |
| 24 | NTSW | MODEL YRML_PHY_RAD YRERAD NTSW | 1,608,808 | 14 |
| 28 | NLWEMISS | MODEL YRML_PHY_RAD YRERAD NLWEMISS | 1,608,800 | 2 |

The native code copies the seven live source words and supplies only the original `NPAERODIAG=8` parameter. The other expected values identify the current input route; they are not replacement literals. All seven live counts must be nonnegative signed int32 values. This leaf does not add counts, multiply allocation extents or reserve storage. Its caller must check every later sum, product, field extent and simultaneous memory requirement before constructing a work record.

Configuration byte 0 must name MODEL, byte 16 must name Geometry, and MODEL byte 8 must name that same Geometry. Configuration byte 8 names the live FIELDS owner, and TSURF must equal that address plus 4,512 without address wrap. Configuration byte 24 must hold the accepted marker `0x47314346`, and its LECMWF word at byte 40,104 must equal one. The actual FIELDS owner and its operational TSURF metadata must have been constructed at their final addresses by the accepted producers. The complete dimension record comes from the same owners; its NLEV, NLEVS, NLEVSN and NTILES words at bytes 48, 20, 64 and 24 must equal the four source words above. Equal scalar words alone do not construct an owner or prove that arbitrary storage is mapped.

The source count producers run first. Genuine completed distributed Geometry and the accepted operational surface metadata provide vertical and soil counts. The accepted MODEL SUDIMF1 stage provides snow and tile counts. Its accepted configuration and GFL stage provide NACTAERO, whose selected original SUGFL1 assignment is zero. The unchanged runtime early-SUECRAD prefix writes the actual MODEL TERAD NTSW and NLWEMISS words. The separate TTYP_SURF parameter namespace is a different owner and cannot replace these MODEL reads. Source SUECRAD selects NTSW fourteen with LRAY false and NLWEMISS two with NEMISSSCHEME zero. Keep the three prefix Planck owners live through the planned shape consumers, then release them through the accepted Planck service before MODEL release.

Return zero means that all eight output words were written. Return two means that a span, alignment, owner association, marker, selected control, signed count or dimension agreement was refused before any write. On refusal, all 32 incoming output bytes remain unchanged. Every input byte remains unchanged on both routes. The direct entry is an integer leaf with no frame, allocation, external call, constructor, method table, original OpenIFS dependency or floating-point instruction. It preserves x18 through x30, all vector registers, stack alignment, FPCR, FPSR and errno. Caller-saved integer registers and integer flags are scratch.

The first four words feed FLUX_TYPE. The four words at output byte 16 feed SURF_AND_MORE_LOCAL_TYPE. NLEV also feeds AUX_DIAG_TYPE, AUX_DIAG_LOCAL_TYPE and PERTURB_LOCAL_TYPE. DDH_SURF_TYPE reads the actual dimension record directly, and KEYS_LOCAL_TYPE needs no shape argument. The seven-record caller owns source order, actual P and B, persistence, every one of the 173 field shapes, complete memory admission, views, failure cleanup and normal release.

The admitted genuine four-process gate compared all 32 output bytes with an independent read of the actual seven source words and the original parameter. Both incoming FPSR zero and 24 pass on every rank, giving eight source/native pairs and 256 bytes per route with zero differences. Immediate native ABI masks are zero, FPCR and FPSR are preserved, and errno remains 777. Wrapping Geometry and inconsistent mapped dimension records refuse before output mutation. The complete seven-record caller then uses these exact counts for creation, first and final views, and release. All three Planck owners remain live through the consumers and retire before MODEL.

The source/interface and loaded-provider peers pass, and the public source assembles to the complete qualified object. Raw 32-byte outputs, complete dimension records and typed owner addresses are retained. Complete Geometry, MODEL, FIELDS and partition inputs were preservation-checked in process and are not separately archived. The unchanged upstream physical and numerical banks are reused. This child accepts no complete weather routine, EC_PHYS order, CALLPAR or forecast.
