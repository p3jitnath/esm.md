/* Contract: skills/md2asm/references/openifs/radiation/selected_radiation_setup.md. */
/* New record birth stores from named original source declarations.
 * x0 final owned MODEL, x1 capacity at least 4275088. Return0 success,2 refusal.
 * Call once before radiation setup. Every other byte and every live pointer remains.
 * Integer-only leaf preserves x18, callee-saved registers, FPCR, FPSR and errno.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_radiation_record_defaults
.type md2asm_initialize_radiation_record_defaults,%function
md2asm_initialize_radiation_record_defaults:
 cbz x0,.Ldefaults_bad
 tst x0,#7
 b.ne .Ldefaults_bad
 movz x9,#15248
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Ldefaults_bad
 adds x9,x0,x9
 b.cs .Ldefaults_bad
 /* TERAD.CGHGCLIMFILE from arpifs/module/yoerad.F90:132-134 */
 movz x9,#36576
 movk x9,#24,lsl#16
 add x9,x0,x9
 movz x10,#8224
 movk x10,#8224,lsl#16
 movk x10,#8224,lsl#32
 movk x10,#8224,lsl#48
 mov x11,#32
.Lfield0:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield0
 /* TERAD.CGHGTIMESERIESFILE from arpifs/module/yoerad.F90:132-134 */
 movz x9,#36832
 movk x9,#24,lsl#16
 add x9,x0,x9
 movz x10,#8224
 movk x10,#8224,lsl#16
 movk x10,#8224,lsl#32
 movk x10,#8224,lsl#48
 mov x11,#32
.Lfield1:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield1
 /* TERAD.CSOLARIRRADIANCEFILE from arpifs/module/yoerad.F90:132-134 */
 movz x9,#37088
 movk x9,#24,lsl#16
 add x9,x0,x9
 movz x10,#8224
 movk x10,#8224,lsl#16
 movk x10,#8224,lsl#32
 movk x10,#8224,lsl#48
 mov x11,#32
.Lfield2:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield2
 /* TECMIP.NCURRYR from arpifs/module/yoecmip.F90:77 */
 movz x9,#16408
 movk x9,#21,lsl#16
 add x9,x0,x9
 movz w10,#65535
 movk w10,#65535,lsl#16
 str w10,[x9]
 /* TEOZOC.COZQC from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#49120
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#21
.Lfield4:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield4
 /* TEOZOC.COZQS from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#49288
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#15
.Lfield5:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield5
 /* TEOZOC.COZHC from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#49408
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#21
.Lfield6:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield6
 /* TEOZOC.COZHS from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#49576
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#15
.Lfield7:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield7
 /* TEOZOC.RSINC from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#49696
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#64
.Lfield8:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield8
 /* TEOZOC.ROZT from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#50208
 movk x9,#20,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#3904
.Lfield9:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield9
 /* TEOZOC.RPROC from arpifs/module/yoeozoc.F90:27-34 */
 movz x9,#15904
 movk x9,#21,lsl#16
 add x9,x0,x9
 movz x10,#65535
 movk x10,#65535,lsl#16
 movk x10,#65535,lsl#32
 movk x10,#65519,lsl#48
 mov x11,#61
.Lfield10:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lfield10
 /* RI.CVER from arpifs/module/eint_mod.F90:42 */
 movz x9,#59336
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#22616
 movk w10,#0,lsl#16
 strh w10,[x9]
 /* RI.NSLGROUP from arpifs/module/eint_mod.F90:45 */
 movz x9,#59340
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NASLB1 from arpifs/module/eint_mod.F90:108 */
 movz x9,#60352
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NASLB1_TRUE from arpifs/module/eint_mod.F90:112 */
 movz x9,#60356
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLPAD from arpifs/module/eint_mod.F90:116 */
 movz x9,#60360
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.LSLT_ARRAYS_INIT from arpifs/module/eint_mod.F90:119 */
 movz x9,#60364
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.LSLONDEM from arpifs/module/eint_mod.F90:122 */
 movz x9,#60368
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.LSLONDEM_ACTIVE from arpifs/module/eint_mod.F90:125 */
 movz x9,#60372
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NUNUSEDHALO from arpifs/module/eint_mod.F90:129 */
 movz x9,#60376
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#16959
 movk w10,#15,lsl#16
 str w10,[x9]
 /* RI.DISTUNUSEDHALO from arpifs/module/eint_mod.F90:133 */
 movz x9,#60384
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz x10,#0
 movk x10,#0,lsl#16
 movk x10,#33918,lsl#32
 movk x10,#16686,lsl#48
 str x10,[x9]
 /* RI.NSLPROCS from arpifs/module/eint_mod.F90:144 */
 movz x9,#60672
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLRPT from arpifs/module/eint_mod.F90:148 */
 movz x9,#60676
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLSPT from arpifs/module/eint_mod.F90:152 */
 movz x9,#60680
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLWIDEN from arpifs/module/eint_mod.F90:156 */
 movz x9,#60684
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLWIDES from arpifs/module/eint_mod.F90:157 */
 movz x9,#60688
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLWIDEE from arpifs/module/eint_mod.F90:158 */
 movz x9,#60692
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLWIDEW from arpifs/module/eint_mod.F90:159 */
 movz x9,#60696
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NSLWIDE from arpifs/module/eint_mod.F90:162 */
 movz x9,#60700
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGLG from arpifs/module/eint_mod.F90:179 */
 movz x9,#60984
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDLON from arpifs/module/eint_mod.F90:180 */
 movz x9,#60988
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGSAG from arpifs/module/eint_mod.F90:181 */
 movz x9,#60992
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGENG from arpifs/module/eint_mod.F90:182 */
 movz x9,#60996
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGSAL from arpifs/module/eint_mod.F90:183 */
 movz x9,#61000
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGENL from arpifs/module/eint_mod.F90:184 */
 movz x9,#61004
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGSAH from arpifs/module/eint_mod.F90:185 */
 movz x9,#61008
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGENH from arpifs/module/eint_mod.F90:186 */
 movz x9,#61012
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NGPTOT from arpifs/module/eint_mod.F90:187 */
 movz x9,#61016
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGUXL from arpifs/module/eint_mod.F90:188 */
 movz x9,#61020
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDLUNG from arpifs/module/eint_mod.F90:189 */
 movz x9,#61024
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDLUXG from arpifs/module/eint_mod.F90:190 */
 movz x9,#61028
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGUNG from arpifs/module/eint_mod.F90:191 */
 movz x9,#61032
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGUXG from arpifs/module/eint_mod.F90:192 */
 movz x9,#61036
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDSUR1 from arpifs/module/eint_mod.F90:193 */
 movz x9,#61040
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDLSUR from arpifs/module/eint_mod.F90:194 */
 movz x9,#61044
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NDGSUR from arpifs/module/eint_mod.F90:195 */
 movz x9,#61048
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NPTRFLOFF from arpifs/module/eint_mod.F90:196 */
 movz x9,#61052
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.NFRSTLOFF from arpifs/module/eint_mod.F90:197 */
 movz x9,#61056
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.MYFRSTACTLAT from arpifs/module/eint_mod.F90:198 */
 movz x9,#61060
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RI.MYLSTACTLAT from arpifs/module/eint_mod.F90:199 */
 movz x9,#61064
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.CVER from arpifs/module/eint_mod.F90:42 */
 movz x9,#61136
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#22616
 movk w10,#0,lsl#16
 strh w10,[x9]
 /* RO.NSLGROUP from arpifs/module/eint_mod.F90:45 */
 movz x9,#61140
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NASLB1 from arpifs/module/eint_mod.F90:108 */
 movz x9,#62152
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NASLB1_TRUE from arpifs/module/eint_mod.F90:112 */
 movz x9,#62156
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLPAD from arpifs/module/eint_mod.F90:116 */
 movz x9,#62160
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.LSLT_ARRAYS_INIT from arpifs/module/eint_mod.F90:119 */
 movz x9,#62164
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.LSLONDEM from arpifs/module/eint_mod.F90:122 */
 movz x9,#62168
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.LSLONDEM_ACTIVE from arpifs/module/eint_mod.F90:125 */
 movz x9,#62172
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NUNUSEDHALO from arpifs/module/eint_mod.F90:129 */
 movz x9,#62176
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#16959
 movk w10,#15,lsl#16
 str w10,[x9]
 /* RO.DISTUNUSEDHALO from arpifs/module/eint_mod.F90:133 */
 movz x9,#62184
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz x10,#0
 movk x10,#0,lsl#16
 movk x10,#33918,lsl#32
 movk x10,#16686,lsl#48
 str x10,[x9]
 /* RO.NSLPROCS from arpifs/module/eint_mod.F90:144 */
 movz x9,#62472
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLRPT from arpifs/module/eint_mod.F90:148 */
 movz x9,#62476
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLSPT from arpifs/module/eint_mod.F90:152 */
 movz x9,#62480
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLWIDEN from arpifs/module/eint_mod.F90:156 */
 movz x9,#62484
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLWIDES from arpifs/module/eint_mod.F90:157 */
 movz x9,#62488
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLWIDEE from arpifs/module/eint_mod.F90:158 */
 movz x9,#62492
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLWIDEW from arpifs/module/eint_mod.F90:159 */
 movz x9,#62496
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NSLWIDE from arpifs/module/eint_mod.F90:162 */
 movz x9,#62500
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGLG from arpifs/module/eint_mod.F90:179 */
 movz x9,#62784
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDLON from arpifs/module/eint_mod.F90:180 */
 movz x9,#62788
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGSAG from arpifs/module/eint_mod.F90:181 */
 movz x9,#62792
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGENG from arpifs/module/eint_mod.F90:182 */
 movz x9,#62796
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGSAL from arpifs/module/eint_mod.F90:183 */
 movz x9,#62800
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGENL from arpifs/module/eint_mod.F90:184 */
 movz x9,#62804
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGSAH from arpifs/module/eint_mod.F90:185 */
 movz x9,#62808
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGENH from arpifs/module/eint_mod.F90:186 */
 movz x9,#62812
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NGPTOT from arpifs/module/eint_mod.F90:187 */
 movz x9,#62816
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGUXL from arpifs/module/eint_mod.F90:188 */
 movz x9,#62820
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDLUNG from arpifs/module/eint_mod.F90:189 */
 movz x9,#62824
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDLUXG from arpifs/module/eint_mod.F90:190 */
 movz x9,#62828
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGUNG from arpifs/module/eint_mod.F90:191 */
 movz x9,#62832
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGUXG from arpifs/module/eint_mod.F90:192 */
 movz x9,#62836
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDSUR1 from arpifs/module/eint_mod.F90:193 */
 movz x9,#62840
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDLSUR from arpifs/module/eint_mod.F90:194 */
 movz x9,#62844
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NDGSUR from arpifs/module/eint_mod.F90:195 */
 movz x9,#62848
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NPTRFLOFF from arpifs/module/eint_mod.F90:196 */
 movz x9,#62852
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.NFRSTLOFF from arpifs/module/eint_mod.F90:197 */
 movz x9,#62856
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.MYFRSTACTLAT from arpifs/module/eint_mod.F90:198 */
 movz x9,#62860
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 /* RO.MYLSTACTLAT from arpifs/module/eint_mod.F90:199 */
 movz x9,#62864
 movk x9,#62,lsl#16
 add x9,x0,x9
 movz w10,#0
 movk w10,#0,lsl#16
 str w10,[x9]
 mov w0,#0
 ret
.Ldefaults_bad:
 mov w0,#2
 ret
.size md2asm_initialize_radiation_record_defaults,.-md2asm_initialize_radiation_record_defaults
.section .note.GNU-stack,"",%progbits
