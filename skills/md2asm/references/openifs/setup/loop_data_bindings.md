# Selected forecast-loop data bindings

This component supplies twenty remaining original-compatible data names from explicit owned startup producers. It does not call the forecast loop or an original OpenIFS routine. The selected serial ECMWF configuration has NCONF 1, LELAM false, LARPEGEF false and LGRADSP true. These live controls are checked rather than inferred from an executable label. External mathematical, transform and system APIs remain permitted.

The frozen interface is `int md2asm_initialize_selected_loop_data(table96)`. Six pointer/capacity pairs contain the complete vertical context 20400, the live transform-control record 304, complete forecast controls 51512, TDYNA 456, TRIP 175976 and the original text of 1–262144 bytes. Each word-bearing record has eight-byte alignment and a complete mapped nonwrapping span. All views and the output owner are disjoint. The routine writes one static 552-byte namespace, `md2asm_owned_loop_data`, whose original GNU data aliases share the same bytes. Return 0 succeeds, return 1 reports allocation failure and return 2 refuses before output mutation. Allocation failure releases private owners before returning. The scratch workspace may change. FPCR must be zero; saved registers, x18 and stack alignment are preserved.

The producer copies MYSETV and NPRTRV from transform bytes 28 and 20, respectively. Source SUMPINI assigns NPRTRN=NPRTRV, so that exact live value supplies NPRTRN. NPROMATR comes from transform byte 64. NPROC, MYPROC and grouping must all describe the supported single process. VP00 is copied from the live vertical-context byte 20320 and must be finite and positive. These copies do not invent new defaults or read original module data.

The first original NAMPAR1 is read with literal uppercase group matching in columns 1–10 and case-insensitive member keys. The selected finite keys are LSPLIT, NFLDIN, NSTRIN, NSTROUT and NOUTTYPE, with the actual values true, 0, 1, 0, 1. The live parsed NOUTTYPE is stored. Source SUMP0 initially assigns minus one for LARPEGEF false; the actual group supplies one, and the later source LFDBOP correction retains one. Other values or keys remain unsupported rather than being silently ignored.

The source-selected false words are LEJK from SU0YOMB’s non-LAM branch, LGWDIAGS_ON from SETUP_GWDIAG, LIAU from SUIAU, LNUDG from the explicitly disabled IFS_INIT branch, LRLXG from SURLX, LECV and LMODERR from SETUP_VAR, and LVAREPS from SUVAREPS. NRSACCFRQ is zero from SUPP. The first NAMGWDIAG, NAMIAU, NAMRLX, NAMVAR, NAMVAREPS and NAMPPC groups must be empty, matching the actual selected text. The single RESTART character receives its declared source value `0`. These are named source assignments, not generic all-zero initialization.

Source YOMSP declares two rank-two FP64 pointers with explicit NULL initialization. The actual selected TDYNA.LGRADSP is true, so selected SUALSPA allocates and zeroes SPVOR_FLT and SPDIV_FLT as 19-by-506 FP64 arrays and SPUB_FLT/SPVB_FLT as 19-value FP64 arrays. The producer reads and checks live NFLSUR at Geometry 5236, NFLEVL 5228 and NSPEC2 at 5200, then constructs all four owners privately through the accepted raw storage child. Only complete success commits their descriptors and ownership mask. Four source-created payloads total 154128 bytes. Fresh bases and ownership must be zero; disabling the actual selected branch is unsupported. Release frees only these four owners in reverse order, clears their bases and mask, and is idempotent. No numerical filtering is claimed.

Selected SURES writes all 41 NRESTS integers to zero, reads the first empty NAMRES, then computes NFRRES from the source 48 hour default using live TRIP.TSTEP. Its ordered expression is `(48*3600+0.5)/TSTEP`, followed by truncation to the source 32-bit integer. The producer retains these rounding points and allows no fused operation. The supported timestep is finite and between 1 and 86400 seconds, so the resulting source integer frequency is positive and representable. Informational source printing remains omitted; raw arithmetic flags and errno are retained without adjustment.

The namespace offsets are fixed below. Bytes 45–47 and 412–415 are reserved and preserved. Every other listed span is fully source-written, copied from a named live producer or source-described descriptor metadata. Namespace storage starts unready; initialization must finish before the loop reads any alias. The loop may later update its owned NOUTTYPE or RESTART word through the same original-compatible name.

| Offset | Field | Bytes |
| ---: | --- | ---: |
| 0 | LEJK | 4 |
| 4 | LGWDIAGS_ON | 4 |
| 8 | LIAU | 4 |
| 12 | MYSETV | 4 |
| 16 | NOUTTYPE | 4 |
| 20 | NPRTRN | 4 |
| 24 | NPRTRV | 4 |
| 28 | LNUDG | 4 |
| 32 | NRSACCFRQ | 4 |
| 36 | NFRRES | 4 |
| 40 | LRLXG | 4 |
| 44 | RESTART | 1 |
| 48 | NPROMATR | 4 |
| 52 | LECV | 4 |
| 56 | LMODERR | 4 |
| 60 | LVAREPS | 4 |
| 64 | VP00 | 8 |
| 72 | SPVOR_FLT descriptor | 88 |
| 160 | SPDIV_FLT descriptor | 88 |
| 248 | NRESTS(0:40) | 164 |
| 416 | SPUB_FLT descriptor | 64 |
| 480 | SPVB_FLT descriptor | 64 |
| 544 | Owned allocation mask | 8 |

Existing qualified producers remain separate: NPROC and LOCEDELAY use the process/shared-control binding packet; LSCMEC uses the complete SUPHEC runtime namespace; NFPPHY and MFPPHY use the source FULLPOS_DRV backup producer after its actual field-request record is ready. This component must not overwrite those outputs or replace their source call order. Source and ABI checks pass for the new selected scalar stores, live copies, exact restart conversion, complete live descriptors and atomic input refusals. No unchanged physics suite or forecast is part of this checkpoint.

Four source profiles pass over 618720 complete record and owner bytes. Three base profiles cover timesteps 3600, 600.5 and 86400 seconds and distinct incoming record patterns. One new group case places a lowercase nonempty NAMPAR1 before the actual uppercase group and agrees with genuine POSNAM selection. The full original SUMP0, SURES and SUALSPA procedures provide the numerical and owner reference. Nine other control fields use exact named source-assignment fragments under the checked selected branch. No complete SETUP_VAR, SUPP or other enclosing-parent credit is claimed for those fragments. Native initialization, release and repeated release ABI masks are zero. FPCR and FPSR agree with the genuine procedures; source informational I/O ends errno zero while quiet native calls retain incoming 777. No status is forced.

Thirty-six atomic input refusals and all four malloc failures pass. Failed private allocations are freed and the namespace stays unchanged. A standalone assembly `_start` fixture emits 154680 complete record and owner bytes, releases the four owners and returns zero with libc as its sole dependency. It is an explicit component fixture, not a production startup stage. All twenty requested names and the two additional source-required SPUB_FLT and SPVB_FLT aliases are actual ELF OBJECTs at the declared owned addresses. Production uses directly authored assembly and accepted assembly storage and empty-group children.
