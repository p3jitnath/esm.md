# Operational Forecast Schedule

This component decides which forecast and output stages must run. It preserves SUCT1 defaults, MONIO_T regular schedules and CNT4 call conditions. The selected one-hour forecast has eight 450-second updates and a closing visit at step 8. Live wave coupling requires grid-point collection during that closing visit.

`md2asm_initialize_operational_output_switches(text,text_bytes,configuration,output64)` uses x0 through x3. Text has at most 262,144 bytes, configuration has 67,616 bytes and output has 64 bytes. Its accepted bounded parser reads NAMCT1. The result contains thirteen four-byte switches in source order, followed by LRFILAF, LWRSPEC and four zero padding bytes. The switch order is N1POS, N1HIS, N1SDI, N1RES, N1SFXHIS, N1GDI, N1DHP, N1DHFG, N1DHFZ, N1DHFD, N1CFU, N1XFU and N1MASSCON. LRFILAF also requires live LARPEGEF.

`md2asm_select_operational_forecast_stage(configuration,MODEL,switches64,step,fullpos_eligible,output96)` uses x0 through x5. MODEL has 4,275,088 bytes. The separate current step lies from 0 through 8. MODEL.NSTART remains the initial step and must not be used as the current step. Output eligibility comes from the caller's owned output object. This component supports positive regular frequencies and empty explicit date lists.

The 96-byte result stores current and stop steps at bytes 0 and 4. Ten four-byte flags at bytes 8 through 47 select post-processing, history, surface history, grid norms, spectral norms, global diagnostics, zonal diagnostics, regional diagnostics, diagnostic printing and mass correction. FP64 time interval and event time are at bytes 48 and 56. The nine-character STEPO configuration is at byte 64. Output-active and collection-active flags are at bytes 80 and 84. Remaining bytes are zero. Event time preserves the separately rounded step-times-interval product and addition of 0.5 seconds.

Every event uses its live frequency and source enable condition. Surface history also requires LMSE. The four diagnostic schedules use source literal 1 with LSDDH and their own enable flag. A parsed diagnostic switch cannot replace that literal. Wave collection remains active at the closing visit, when the STEPO string is `0AAA00000`.

All record ranges are mapped, eight-byte aligned, nonwrapping and disjoint. Both entries return 0 on success or 2 before output mutation on refusal. They preserve x18, saved registers, FPCR, natural arithmetic flags and the system error value. FPCR must be zero. The switch constructor has a 176-byte aligned frame and calls only the accepted direct parser. The policy leaf has no frame or imports.

Thirty genuine original schedule calls and the complete switch record agree exactly. Varied source enable flags, all nine visits, raw status and atomic refusals pass. This accepts the schedule component. The output parent, complete time loop and forecast remain separate.
