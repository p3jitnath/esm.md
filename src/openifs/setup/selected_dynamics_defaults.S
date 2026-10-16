/* Complete selected TDYNA defaults and hydrostatic integer index maps.
 * x0: writable aligned TDYNA[456]. Return0/2 before any rejected store.
 * Source-unwritten padding is preserved. No calls, FP arithmetic or frame.
 * Contract: skills/md2asm/references/openifs/setup/selected_dynamics_controls.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_default_selected_dynamics_controls
.type md2asm_default_selected_dynamics_controls,%function
md2asm_default_selected_dynamics_controls:
 cbz x0,.Ldynamics_defaults_bad
 tst x0,#7
 b.ne .Ldynamics_defaults_bad
 adds x9,x0,#456
 b.cs .Ldynamics_defaults_bad
 mrs x9,fpcr
 cbnz x9,.Ldynamics_defaults_bad
 mov w9,#1
 mov w10,#0
 /* LNHEE */
 str w10,[x0,#0]
 /* LNHQE */
 str w10,[x0,#4]
 /* LNHDYN */
 str w10,[x0,#8]
 /* LSACC */
 str w10,[x0,#12]
 /* LSPRT */
 str w9,[x0,#16]
 /* LTWOTL */
 str w9,[x0,#20]
 /* LSLAG */
 str w9,[x0,#24]
 /* NPDVAR */
 movz w11,#2
 str w11,[x0,#28]
 /* NVDVAR */
 movz w11,#3
 str w11,[x0,#32]
 /* ND4SYS */
 movz w11,#2
 str w11,[x0,#36]
 /* LNHX */
 str w10,[x0,#40]
 /* LNHXDER */
 str w10,[x0,#44]
 /* LGWADV */
 str w10,[x0,#48]
 /* NGWADVSI */
 str w9,[x0,#52]
 /* LRDBBC */
 str w10,[x0,#56]
 /* LSI_NHEE */
 str w10,[x0,#60]
 /* LNHQE_C2 */
 str w10,[x0,#64]
 /* LNHQE_SIHYD */
 str w10,[x0,#68]
 /* LNHEE_SVDLAPL_FIRST */
 str w10,[x0,#72]
 /* LSLHD */
 str w10,[x0,#76]
 /* LSLHD_W */
 str w10,[x0,#80]
 /* LSLHD_T */
 str w10,[x0,#84]
 /* LSLHD_SPD */
 str w10,[x0,#88]
 /* LSLHD_SVD */
 str w10,[x0,#92]
 /* LSLHD_GFL */
 str w10,[x0,#96]
 /* LSLHD_OLD */
 str w10,[x0,#100]
 /* LSLHD_STATIC */
 str w10,[x0,#104]
 /* LSLHDQUAD */
 str w10,[x0,#108]
 /* SLHDKMIN */
 str x10,[x0,#112]
 /* SLHDKMAX */
 movz x11,#0
 movk x11,#16408,lsl#48
 str x11,[x0,#120]
 /* SLHDKREF */
 movz x11,#0
 movk x11,#14336,lsl#32
 movk x11,#49295,lsl#48
 str x11,[x0,#128]
 /* SLHDEPSH */
 str x10,[x0,#136]
 /* SLHDEPSV */
 str x10,[x0,#144]
 /* LSLVF */
 str w9,[x0,#152]
 /* SLVFEPS */
 movz x11,#5243
 movk x11,#18350,lsl#16
 movk x11,#31457,lsl#32
 movk x11,#16244,lsl#48
 str x11,[x0,#160]
 /* P_SLVF_BOT */
 str x10,[x0,#168]
 /* SLVFMIN */
 movz x11,#39322
 movk x11,#39321,lsl#16
 movk x11,#39321,lsl#32
 movk x11,#16313,lsl#48
 str x11,[x0,#176]
 /* SLVFTR */
 movz x11,#17197
 movk x11,#60188,lsl#16
 movk x11,#14050,lsl#32
 movk x11,#16154,lsl#48
 str x11,[x0,#184]
 /* P_SLVF_TR */
 movz x11,#0
 movk x11,#49152,lsl#32
 movk x11,#16498,lsl#48
 str x11,[x0,#192]
 /* LGRADSP */
 str w9,[x0,#200]
 /* LPGFSF */
 str w10,[x0,#204]
 /* LPGREUSE */
 str w10,[x0,#208]
 /* L3DTURB */
 str w10,[x0,#212]
 /* LSLDIA */
 str w10,[x0,#216]
 /* LRPRSLTRJ */
 str w9,[x0,#220]
 /* LRALTVDISP */
 str w10,[x0,#224]
 /* LVSPLIP */
 str w10,[x0,#228]
 /* LRHSVWENO */
 str w9,[x0,#232]
 /* LCOMAD */
 str w10,[x0,#236]
 /* LCOMADH */
 str w10,[x0,#240]
 /* LCOMADV */
 str w10,[x0,#244]
 /* LCOMAD_W */
 str w10,[x0,#248]
 /* LCOMAD_T */
 str w10,[x0,#252]
 /* LCOMAD_SPD */
 str w10,[x0,#256]
 /* LCOMAD_SVD */
 str w10,[x0,#260]
 /* LCOMAD_SP */
 str w10,[x0,#264]
 /* LCOMAD_GFL */
 str w10,[x0,#268]
 /* LNESCT */
 str w10,[x0,#272]
 /* LNESCV */
 str w10,[x0,#276]
 /* LNESC */
 str w10,[x0,#280]
 /* LSETTLST */
 str w9,[x0,#284]
 /* LSETTLSV */
 str w9,[x0,#288]
 /* LSETTLS */
 str w9,[x0,#292]
 /* LELTRA */
 str w10,[x0,#296]
 /* LSLINLC2 */
 str w10,[x0,#300]
 /* LSLINL */
 str w10,[x0,#304]
 /* LHOISLT */
 str w10,[x0,#308]
 /* HOISLTV */
 str x10,[x0,#312]
 /* HOISLTH */
 str x10,[x0,#320]
 /* LSLTVWENO */
 str w10,[x0,#328]
 /* LRUBC */
 str w10,[x0,#332]
 /* LPC_FULL */
 str w10,[x0,#336]
 /* LPC_CHEAP */
 str w10,[x0,#340]
 /* LPC_CHEAP2 */
 str w10,[x0,#344]
 /* LMIXETTLS */
 str w10,[x0,#348]
 /* LMIXETTLS_PRINT */
 str w10,[x0,#352]
 /* RMIXNL_TRH */
 movz x11,#0
 movk x11,#16352,lsl#48
 str x11,[x0,#360]
 /* L_RDRY_VD */
 str w9,[x0,#368]
 /* SLHDKREF after empty NAMDYNA */
 str x10,[x0,#128]
 /* YYTTND%M_TNDU */
 str w9,[x0,#372]
 /* YYTTND%M_TNDV */
 movz w11,#2
 str w11,[x0,#376]
 /* YYTTND%M_TNDU_NOC */
 movz w11,#3
 str w11,[x0,#380]
 /* YYTTND%M_TNDV_NOC */
 movz w11,#4
 str w11,[x0,#384]
 /* YYTTND%M_TNDT */
 movz w11,#5
 str w11,[x0,#388]
 /* YYTTND%M_TNDPD */
 str w9,[x0,#392]
 /* YYTTND%M_TNDVD */
 str w9,[x0,#396]
 /* YYTTND%M_TNDGW */
 str w9,[x0,#400]
 /* YYTTND%NDIM */
 movz w11,#5
 str w11,[x0,#404]
 /* YYTGMVT95%M_U */
 str w9,[x0,#408]
 /* YYTGMVT95%M_V */
 movz w11,#2
 str w11,[x0,#412]
 /* YYTGMVT95%M_T */
 movz w11,#3
 str w11,[x0,#416]
 /* YYTGMVT95%M_DIV */
 str w9,[x0,#420]
 /* YYTGMVT95%M_SPD */
 str w9,[x0,#424]
 /* YYTGMVT95%M_SVD */
 str w9,[x0,#428]
 /* YYTGMVT95%NDIM */
 movz w11,#3
 str w11,[x0,#432]
 /* YYTGFLT95%M_Q */
 str w9,[x0,#436]
 /* YYTGFLT95%M_L */
 movz w11,#2
 str w11,[x0,#440]
 /* YYTGFLT95%M_I */
 movz w11,#3
 str w11,[x0,#444]
 /* YYTGFLT95%NDIM */
 movz w11,#3
 str w11,[x0,#448]
 mov w0,#0
 ret
.Ldynamics_defaults_bad:
 mov w0,#2
 ret
.size md2asm_default_selected_dynamics_controls,.-md2asm_default_selected_dynamics_controls
.section .note.GNU-stack,"",%progbits
