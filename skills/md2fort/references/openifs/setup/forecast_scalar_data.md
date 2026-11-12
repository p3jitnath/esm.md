# Selected Forecast Scalar State

This component owns 22 named scalar variables in one 112-byte assembly namespace. It supplies the selected one-process forecast state after the accepted forecast controls, loop metadata and inactive coupling setup are complete, and before the forecast first reads these variables. Original OpenIFS globals, objects and procedures are not production inputs. The source routines remain separate verification controls.

The ABI is `int md2asm_initialize_selected_forecast_scalar_data(text, bytes, views)`, with arguments in x0 through x2. Text contains one through 262144 mapped bytes. The 80-byte view table contains five address and capacity pairs, in this order: read-only forecast controls of 51512 bytes, read-only accepted loop namespace of 552 bytes, read-only TMCC of 7584 bytes, read-only process count of four bytes and writable scalar namespace of 112 bytes. The four large records and table align to eight bytes; the process count aligns to four bytes. Each complete range must be mapped, must not wrap and must be disjoint from every other range, the table and text. The output must be the unique `md2asm_owned_forecast_scalar_data` object. Success returns zero; unsupported inputs return two before any output store. The integer-only 208-byte frame preserves x18, all required saved registers, FPCR, FPSR and errno. It allocates no heap storage and calls only the accepted empty-group reader.

The accepted loop producer has already read the genuine first NAMPAR1 and required empty NAMVAR. Its completed owner mask at byte 544 is 15 and its final NOUTTYPE at byte 16 is 1. The forecast record supplies NCONF equal to one, LARPEGEF false, LELAM false, LECMWF true, LFDBOP false and a canonical LOLDPP logical value. The independent process count is 1. TMCC.CPLNG_ACTIVE at byte 7424 is false, so original CPL_CONFIG returns before it reads NAMCPLCFG and the declaration-defined CPL_NEMO_LIM remains false. This component requires the genuine first NAMPPVI to be empty and obtains LRPPUV_CALLITPQ from the live LOLDPP value. It does not repeat the already accepted NAMPAR1 scan.

The named declaration and source setup values are distinct from source-unwritten static storage. SUMP0 sets LSLDEBUG false. Its accepted NOUTTYPE 1 path leaves LFDBOP and LSPLITOUT false. PE2SET yields MY_REGION_EW 1 for the one-process decomposition. SUPPVI sets LNOTS_T and LRPPUV_CSTEXT false and copies LOLDPP into LRPPUV_CALLITPQ. The four trajectory switches have false declaration values and are reset false by the selected model-step entry. SETUP_VAR resets LTWGRA and LTWINC false, and the accepted empty NAMVAR leaves them false. SUJFH sets N_VMASS to −1 for the frozen GNU Arm build, where SUMPINI sets LOPT_RS6K false and NECSX is not defined. This uses the setup result rather than the earlier N_VMASS declaration value of zero.

RMDI, LTWBGV, LTWCGL, LSFCFLX, REXTLHF and REXTSHF have no source declaration initializer. Their original named symbols are correctly sized NOBITS objects, which receive zero from the operating-system loader. The selected forecast has no producer that changes those words before their retained reads. LTWBGV and LTWCGL describe analysis-only stages outside NCONF equal to one; external heat-flux forcing is disabled by LSFCFLX false, so its two zero flux words are inactive. These are explicit original process-initial zero preimages, not new physical constants or defaults for arbitrary local records. NIMP and NOUT are also original NOBITS words and RADINTG/RADINA explicitly reset both to zero before radiation diagnostics. The owned namespace starts with those same zero words and the selected diagnostics leave them zero. No original module image is copied into production.

The owned layout below counts bytes from the namespace base. Logical values and integers use four bytes; FP64 values use eight bytes. Empty alignment bytes belong to the new packed namespace and are zero. Every source-compatible symbol is an alias into this single writable process-lifetime object.

| Member | Offset | Bytes | Selected value |
| --- | ---: | ---: | --- |
| COUPLING.CPL_NEMO_LIM | 0 | 4 | false |
| YOERDU.NIMP | 4 | 4 | zero |
| YOERDU.NOUT | 8 | 4 | zero |
| YOMANCS.RMDI | 16 | 8 | original process zero |
| YOMMP0.LSLDEBUG | 24 | 4 | false |
| YOMMP0.LSPLITOUT | 28 | 4 | false |
| YOMMP0.MY_REGION_EW | 32 | 4 | one |
| YOMPPVI.LNOTS_T | 36 | 4 | false |
| YOMPPVI.LRPPUV_CALLITPQ | 40 | 4 | live LOLDPP |
| YOMPPVI.LRPPUV_CSTEXT | 44 | 4 | false |
| YOMTRAJ.LTRAJSAVE | 48 | 4 | false |
| YOMTRAJ.LTRAJSLAG | 52 | 4 | false |
| YOMTRAJ_OOPS.LTRAJSAVE_OOPS | 56 | 4 | false |
| YOMTRAJ_OOPS.LTRAJSLAG_OOPS | 60 | 4 | false |
| YOMVAR.LTWGRA | 64 | 4 | false |
| YOMVAR.LTWINC | 68 | 4 | false |
| YOMVAR.LTWBGV | 72 | 4 | original process zero |
| YOMVAR.LTWCGL | 76 | 4 | original process zero |
| YOMCT0.LSFCFLX | 80 | 4 | original process zero |
| YOMCT0.REXTLHF | 88 | 8 | original process zero |
| YOMCT0.REXTSHF | 96 | 8 | original process zero |
| YOMJFH.N_VMASS | 104 | 4 | minus one |

The focused gate calls the complete genuine SUMP0, SUPPVI, SUJFH and PE2SET with the actual live namelist text and source-owned fresh module storage. It compares all 112 owned bytes at both LOLDPP values, for 224 exact bytes and zero differences. All read-only inputs remain unchanged. Native ABI masks are zero and raw FPCR zero, FPSR 16 and errno 777 are preserved. The source I/O routines have their natural x18 and errno observations, which remain recorded separately. Four critical refusals cover process count, active coupling, short capacity and a nonempty NAMPPVI, with no output mutation. Existing numerical kernels and forecasts were not rerun.
