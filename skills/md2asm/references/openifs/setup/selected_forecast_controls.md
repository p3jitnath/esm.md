# Selected Forecast Control Initialisation

The producer owns the selected job configuration used by CNT4 and STEPO. It reads the first uppercase NAMARG, NAMCT0 and NAMRIP groups from bounded live text, then constructs every selected SUCT0-written value in a caller-owned namespace. It receives the actual initial-file date and seconds, the print level and NGRIBFILE as explicit upstream inputs. It calls no original OpenIFS routine and reads no original module data.

The application binary interface is `int md2asm_initialize_selected_forecast_controls(text, bytes, upstream, output, capacity)`. Registers x0 through x4 carry those arguments. Text has 1 through 262144 bytes. Upstream has 16 bytes: int32 date, seconds within the day, NPRINTLEV and NGRIBFILE. Date and seconds obey the accepted model-clock contract; print level is nonnegative and NGRIBFILE is zero or one. Upstream and output have eight-byte alignment. All complete ranges must be mapped, must not wrap and must be pairwise disjoint. Output has 51512 bytes. Return zero means success and two means unsupported input, with the output unchanged. The floating-point control register must be zero. The routine preserves the Arm callee-saved registers, x18, stack alignment and errno. Source clock arithmetic can set floating-point status flags.

The table below lists all 108 named outputs and their byte offsets. It contains every variable imported by SUCT0 from YOMCT0 except the dimension constant JPNPST, plus LTRAJNH and the SET_OBS_IN_FC result. It contains all 13 schedule arrays, each with indices 0 through 960 and four-byte integers. This is an explicit assembly layout, because the source module uses separate variables and has no derived-record layout. Character values have their source lengths. Only alignment gaps retain their incoming bytes. Source module members which SUCT0 does not assign, such as NSTEPINI and the single-column controls, are outside this namespace.

The first 51112 bytes hold the SUCT0 namespace. The next 40 bytes hold the accepted model-clock input record, and the final 360 bytes hold its output. The input record receives the actual upstream date and seconds, live TSTEP and CSTOP, source NFOST zero and source TSTEP_TRAJ minus one. Its four reserved bytes remain unchanged. The clock output retains exactly the bytes left unwritten by the accepted child. LASTRF must be false on entry, as in that child's contract. All other source-unwritten bytes retain their exact incoming values.

The selected SUARG input edge starts with its genuine defaults NCONF one, LECMWF true, experiment text 0123, LELAM false, NSUPERSEDE one and NFPSERVER zero. NAMARG supports NCONF one, LECMWF true and a quoted experiment identifier of at most four characters. Other NAMARG keys and configurations are rejected. This owns only the consumed SUARG configuration edge, not the complete SUARG routine, which also prepares geometry, file names and command-line inputs. NGRIBFILE and print level remain explicit upstream controls.

The complete selected SUCT0 order is source defaults, ECMWF defaults, live NAMCT0 read, selected final guards and SET_OBS_IN_FC. NAMCT0 supports the ten assignments present in the selected input: NFRSDI, N3DINI, LREFOUT, LFDBOP, NFRHIS, NFRPOS, NFPOS, NFRDHP, NFRDHFD and NUNDEFLD. It also accepts LSMSSIG false. N3DINI remains zero and LREFOUT remains false. Frequencies are positive integers through 999999; NFPOS is zero, one or two; NUNDEFLD is negative through minus one. LFDBOP can be false or true. Omitted values retain their source defaults. Selected optional assimilation, coupling, conservation, forcing, reference, limited-area and alternate-equation modes retain their source-disabled values. LOPDIS is true and LSMSSIG is false. The selected final LECFPOS value is true exactly when NFPOS is nonzero, and NCNTVAR is one because simulated observations are enabled.

NAMRIP requires live TSTEP and CSTOP assignments. The supported TSTEP is exactly 3600 seconds, written as 3600 with an optional decimal point and any trailing zeros. CSTOP contains lower-case t and one or two decimal digits selecting one through 25 steps, with optional trailing spaces inside its eight-character limit. These are the accepted clock-child bounds. Source defaults NSTART zero, NFOST zero and trajectory time step minus one remain explicit. This producer does not claim the complete SURIP derived object or the SUDEFO_TSTEP default producer.

Group markers follow source POSNAME selection: uppercase names begin after an ampersand in the first ten columns, as the first nonblank token on a line. Only the first matching group is read. Keys and logical values are case-insensitive; comma or whitespace separates assignments, exclamation marks begin line comments, and a slash closes a group. Unknown keys, unsupported values and incomplete groups are rejected. Duplicate supported assignments follow source order, so the last value in the first group wins. A duplicate later group is ignored.

The routine uses a 608-byte aligned private frame, with 96 additional bytes while its parser child runs. Its maximum private stack use is 704 bytes. It makes no heap allocation. It calls only the accepted `md2asm_initialize_model_clock` assembly child. The complete private clock copy lets it reject bad dates, stop strings and clock preimages without changing any caller output. The final namespace assignments contain integer and character data, so they introduce no new floating-point calculation. The accepted child retains its frozen FP64 calendar order.

The actual file selects NCONF one, experiment epc8, TSTEP 3600 seconds and stop text t25. It sets history and post-processing frequencies to six steps; grid-point and spectral diagnostics each use one step. NFPOS is two and LFDBOP is false. Optional source modes retain their selected disabled values. The table gives the complete actual output, including the source defaults for omitted keys. A frequency is a number of model steps between events. These records do not yet construct the event schedules used by MONIO_T.

The SUCT0 boundary precedes SUARG_DATETIME. In the source, an omitted NFRPOS remains minus one here, then SUARG_DATETIME supplies a later default. The selected live file supplies six, so this later correction leaves it unchanged. Other module members and other top-level control producers remain outside this component. This checkpoint owns the complete selected SUCT0 configuration, the consumed SUARG input edge and the live input connection to the accepted clock; it does not claim a complete SUARG, SURIP or autonomous forecast.

Four complete genuine SUCT0 calls and the connected source clock fields compare 206048 returned bytes with zero differences. The cases cover the actual file, omitted configuration defaults, duplicate assignments in source order, first matching groups, changed supported live values, leap-day input, nonzero incoming status flags and nonzero retained-byte preimages. The reference captures FPCR, FPSR and errno immediately after genuine SUCT0, before serialisation and cleanup. That boundary preserves incoming floating-point flags and returns errno zero through source namelist and diagnostic services. The direct component preserves caller errno 777 and has zero ABI masks. Its connected clock adds the source inexact flag, bit 16, when required.

There are 152 independent control checks across these cases, including 52 schedule-array checks. They check that the selected case uses the three-dimensional forecast, disables assimilation and optional coupling, retains diagnostic switches, uses simulated-observation control variables, and restricts post-processing exactly when required. Every source declaration size is checked independently through the genuine module declarations. All original providers are resolved to the separate verification libraries. These libraries do not enter production.

Fifty-five unsupported-input cases leave output, input and upstream buffers unchanged, with preserved status and ABI. Four successful inputs end at a protected page boundary and include the slash as the last readable byte, a marker in column ten, a ten-space blank line and a later ignored duplicate group. A separate assembly entry reads live fort.4 with Linux file calls, writes 51512 bytes and matches the complete source output. Its explicit fixture upstream values are the actual date 20041015, 43200 seconds, print level zero and NGRIBFILE zero. Clean-environment readelf, nm and ldd checks show no dynamic library or unresolved symbol. No forecast or performance run was made.

| Namespace offset | Bytes | Source member | Actual selected value |
| --- | --- | --- | --- |
| 0 | 3844 | NPOSTS | 961 zero int32 entries |
| 3844 | 3844 | NHISTS | 961 zero int32 entries |
| 7688 | 3844 | NGDITS | 961 zero int32 entries |
| 11532 | 3844 | NSDITS | 961 zero int32 entries |
| 15376 | 3844 | NDHFGTS | 961 zero int32 entries |
| 19220 | 3844 | NDHFZTS | 961 zero int32 entries |
| 23064 | 3844 | NDHFDTS | 961 zero int32 entries |
| 26908 | 3844 | NDHPTS | 961 zero int32 entries |
| 30752 | 3844 | NMASSCONS | 961 zero int32 entries |
| 34596 | 16 | CNMEXP | `epc8`, then spaces |
| 34612 | 128 | CFPNCF | `ncf927`, then spaces |
| 34740 | 4 | NOPT_MEMORY | 2 |
| 34744 | 120 | CNPPATH | spaces |
| 34864 | 120 | CFDIRLST | spaces |
| 34984 | 120 | CNDISPP | spaces |
| 35104 | 4 | NCONF | 1 |
| 35108 | 4 | NTASKS_CANARI | 1 |
| 35112 | 4 | NQUAD | 1 |
| 35116 | 4 | N2DINI | 1 |
| 35120 | 4 | NSPPR | 0 |
| 35124 | 4 | NFRPOS | 6 |
| 35128 | 4 | NFRHIS | 6 |
| 35132 | 4 | N3DINI | 0 |
| 35136 | 4 | NFRGDI | 1 |
| 35140 | 4 | NFRSDI | 1 |
| 35144 | 4 | NCNTVAR | 1 |
| 35148 | 4 | NFRDHFG | 4 |
| 35152 | 4 | NFRDHFZ | 4 |
| 35156 | 4 | NFRDHFD | 1 |
| 35160 | 4 | NFRDHP | 1 |
| 35164 | 4 | NFRCO | 0 |
| 35168 | 4 | NFRMASSCON | 999999 |
| 35172 | 4 | N6BINS | 6 |
| 35176 | 4 | LNF | 1 (true) |
| 35180 | 4 | LFDBOP | 0 (false) |
| 35184 | 4 | LARPEGEF | 0 (false) |
| 35188 | 4 | LSMSSIG | 0 (false) |
| 35192 | 25 | CMETER | `smsmeter`, then spaces |
| 35217 | 25 | CEVENT | `smsevent`, then spaces |
| 35244 | 4 | LARPEGEF_TRAJHR | 0 (false) |
| 35248 | 4 | LARPEGEF_TRAJBG | 0 (false) |
| 35252 | 4 | NFPOS | 2 |
| 35256 | 4 | LOPDIS | 1 (true) |
| 35260 | 4 | LCANARI | 0 (false) |
| 35264 | 4 | LOLDPP | 1 (true) |
| 35268 | 4 | LGUESS | 0 (false) |
| 35272 | 4 | LOBS | 0 (false) |
| 35276 | 4 | LOBSC1 | 0 (false) |
| 35280 | 4 | LOBSREF | 0 (false) |
| 35284 | 4 | LSIMOB | 1 (true) |
| 35288 | 4 | LELAM | 0 (false) |
| 35292 | 4 | LRPLANE | 0 (false) |
| 35296 | 4 | LFBDAP | 0 (false) |
| 35300 | 4 | LBACKG | 0 (false) |
| 35304 | 4 | LMINIM | 0 (false) |
| 35308 | 4 | LSCREEN | 0 (false) |
| 35312 | 4 | LREFOUT | 0 (false) |
| 35316 | 4 | LMONITORING | 0 (false) |
| 35320 | 120 | CSCRIPT_PPSERVER | `cnt3_wait`, then spaces |
| 35440 | 120 | CSCRIPT_LAMRTC | `atcp`, then spaces |
| 35560 | 4 | L_SCREEN_CALL | 1 (true) |
| 35564 | 4 | L_SPLIT_SCREEN | 0 (false) |
| 35568 | 4 | LINFLAT | 0 (false) |
| 35572 | 4 | LINFLP9 | 0 (false) |
| 35576 | 4 | LINFLF1 | 0 (false) |
| 35580 | 4 | LALLOPR | 0 (false) |
| 35584 | 4 | LREFGEN | 0 (false) |
| 35588 | 4 | LIFSTRAJ | 0 (false) |
| 35592 | 4 | LIFSMIN | 0 (false) |
| 35596 | 4 | LAROME | 0 (false) |
| 35600 | 4 | LECFPOS | 1 (true) |
| 35604 | 4 | NINTERPTRAJ | 1 |
| 35608 | 4 | NINTERPINCR | 1 |
| 35612 | 4 | LSCREEN_OPENMP | 1 (true) |
| 35616 | 4 | NFRCORM | 0 |
| 35620 | 4 | LSFORC | 0 (false) |
| 35624 | 4 | LSFORCS | 0 (false) |
| 35628 | 4 | LSPBSBAL | 0 (false) |
| 35632 | 3844 | NSFXHISTS | 961 zero int32 entries |
| 39476 | 4 | NFRSFXHIS | 1 |
| 39480 | 4 | LARPEGEF_RDGP_INIT | 0 (false) |
| 39484 | 4 | LARPEGEF_RDGP_TRAJHR | 0 (false) |
| 39488 | 4 | LARPEGEF_RDGP_TRAJBG | 0 (false) |
| 39492 | 4 | LCALLSFX | 1 (true) |
| 39496 | 4 | LSFXLSM | 0 (false) |
| 39500 | 4 | LR3D | 1 (true) |
| 39504 | 4 | LR2D | 0 (false) |
| 39508 | 4 | LRSHW | 0 (false) |
| 39512 | 4 | LRVEQ | 0 (false) |
| 39516 | 4 | LIOLEVG | 1 (true) |
| 39520 | 4 | LECMWF | 1 (true) |
| 39524 | 4 | LWRSPECA_GP | 0 (false) |
| 39528 | 4 | LSUSPECA_GP | 0 (false) |
| 39532 | 4 | LWRSPECA_GP_UV | 0 (false) |
| 39536 | 4 | LSUSPECA_GP_UV | 0 (false) |
| 39540 | 3844 | NHISTSMIN | 961 zero int32 entries |
| 43384 | 3844 | NSFXHISTSMIN | 961 zero int32 entries |
| 47228 | 3844 | NPOSTSMIN | 961 zero int32 entries |
| 51072 | 4 | LGRIB_API | 1 (true) |
| 51076 | 4 | NUNDEFLD | -99999 |
| 51080 | 4 | LCOUPLO4 | 0 (false) |
| 51084 | 4 | L4DVAR | 0 (false) |
| 51088 | 4 | L_OOPS | 0 (false) |
| 51092 | 4 | NITER_ADTEST | 1 |
| 51096 | 4 | LCONSERV | 0 (false) |
| 51100 | 4 | LCORWAT | 0 (false) |
| 51104 | 4 | LTRAJNH | 0 (false) |
| 51108 | 4 | L_OBS_IN_FC_CONFIG | 0 (false) |

Namespace alignment bytes 35242, 35243 retain their incoming values. The 40-byte clock input begins at 51112, and the 360-byte clock output begins at 51152. Their field bounds, source-unwritten bytes and ordered calendar arithmetic follow the [owned model clock contract](model_clock_initialization.md).
