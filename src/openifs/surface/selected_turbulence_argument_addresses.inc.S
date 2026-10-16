 // 0: YDMODEL = YDMODEL
 ARG x0,1
 PUTARG x0,0
 // 1: CDCONF = CLCONF
 SPADDR x0,4000
 PUTARG x0,1
 // 2: KIDIA = KDIM%KIDIA
 ARG x0,2
 ADDR x0,x0,0
 PUTARG x0,2
 // 3: KFDIA = KDIM%KFDIA
 ARG x0,2
 ADDR x0,x0,4
 PUTARG x0,3
 // 4: KLON = KDIM%KLON
 ARG x0,2
 ADDR x0,x0,12
 PUTARG x0,4
 // 5: KLEV = KDIM%KLEV
 ARG x0,2
 ADDR x0,x0,48
 PUTARG x0,5
 // 6: KLEVS = KDIM%KLEVS
 ARG x0,2
 ADDR x0,x0,20
 PUTARG x0,6
 // 7: KTILES = KDIM%KTILES
 ARG x0,2
 ADDR x0,x0,24
 PUTARG x0,7
 // 8: KVTYPES = IKVTYPES
 SPADDR x0,4016
 PUTARG x0,8
 // 9: KDIAG = IDIAG
 SPADDR x0,4020
 PUTARG x0,9
 // 10: KTRAC = GEMSL%ITRAC, a pointer to one integer.
 ARG x0,9
 ADDR x0,x0,0
 ldr x0,[x0]
 PUTARG x0,10
 // 11: KCHEM = GEMSL%ICHEM
 ARG x0,9
 ADDR x0,x0,72
 ldr x0,[x0]
 PUTARG x0,11
 // 12: KAERO = GEMSL%IAERO
 ARG x0,9
 ADDR x0,x0,8
 ldr x0,[x0]
 PUTARG x0,12
 // 13: KLEVSN = KDIM%KLEVSN
 ARG x0,2
 ADDR x0,x0,64
 PUTARG x0,13
 // 14: KLEVI = KDIM%KLEVI
 ARG x0,2
 ADDR x0,x0,56
 PUTARG x0,14
 // 15: KDHVTLS = KDIM%KDHVTLS
 ARG x0,2
 ADDR x0,x0,68
 PUTARG x0,15
 // 16: KDHFTLS = KDIM%KDHFTLS
 ARG x0,2
 ADDR x0,x0,72
 PUTARG x0,16
 // 17: KDHVTSS = KDIM%KDHVTSS
 ARG x0,2
 ADDR x0,x0,76
 PUTARG x0,17
 // 18: KDHFTSS = KDIM%KDHFTSS
 ARG x0,2
 ADDR x0,x0,80
 PUTARG x0,18
 // 19: KDHVTTS = KDIM%KDHVTTS
 ARG x0,2
 ADDR x0,x0,84
 PUTARG x0,19
 // 20: KDHFTTS = KDIM%KDHFTTS
 ARG x0,2
 ADDR x0,x0,88
 PUTARG x0,20
 // 21: KDHVTIS = KDIM%KDHVTIS
 ARG x0,2
 ADDR x0,x0,92
 PUTARG x0,21
 // 22: KDHFTIS = KDIM%KDHFTIS
 ARG x0,2
 ADDR x0,x0,96
 PUTARG x0,22
 // 23: KDHVCO2S = IKDHVCO2S
 SPADDR x0,4024
 PUTARG x0,23
 // 24: KDHFCO2S = IKDHFCO2S
 SPADDR x0,4028
 PUTARG x0,24
 // 25: KDHVVEGS = IKDHVVEGS
 SPADDR x0,4032
 PUTARG x0,25
 // 26: KDHFVEGS = IKDHFVEGS
 SPADDR x0,4036
 PUTARG x0,26
 // 27: PTSPHY = TSPHY
 ARG x0,1
 ADDR x0,x0,4150016
 PUTARG x0,27
 // 28: KTVL = PSURF%ITVL
 ARG x0,10
 ADDR x0,x0,12184
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#4
 bl .Lsl_raw
 PUTARG x0,28
 // 29: KCO2TYP = PSURF%ICO2TYP
 ARG x0,10
 ADDR x0,x0,12248
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#4
 bl .Lsl_raw
 PUTARG x0,29
 // 30: KTVH = PSURF%ITVH
 ARG x0,10
 ADDR x0,x0,12120
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#4
 bl .Lsl_raw
 PUTARG x0,30
 // 31: PCVL = PSURF%PCVL
 ARG x0,10
 ADDR x0,x0,12376
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,31
 // 32: PCVH = PSURF%PCVH
 ARG x0,10
 ADDR x0,x0,12440
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,32
 // 33: PCUR = PSURF%PCUR
 ARG x0,10
 ADDR x0,x0,12504
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,33
 // 34: PLAIL = PSURF%PLAIL
 ARG x0,10
 ADDR x0,x0,12632
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,34
 // 35: PLAIH = PSURF%PLAIH
 ARG x0,10
 ADDR x0,x0,12696
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,35
 // 36: PFWET = PSURF%PSD_VF(:,YSD_VF%YFWET%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9120,0
 SPADDR x0,6144
 bl .Lsl_column2
 SPADDR x0,6144
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,36
 // 37: PSNS = PSURF%PSP_SG(:,:,YSP_SG%YF%MP9)
 ARG x1,10
 ADDR x1,x1,9256
 ARG x12,0
 FIELD w2,x12,6232,8
 SPADDR x0,6256
 bl .Lsl_plane3
 SPADDR x0,6256
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#64]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,37
 // 38: PRSN = PSURF%PSP_SG(:,:,YSP_SG%YR%MP9)
 ARG x1,10
 ADDR x1,x1,9256
 ARG x12,0
 FIELD w2,x12,6248,8
 SPADDR x0,6368
 bl .Lsl_plane3
 SPADDR x0,6368
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#64]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,38
 // 39: PMU0 = PAUX%PMU0
 ARG x0,3
 ADDR x0,x0,1296
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,39
 // 40: PSIGFLT = SURFL%ZHSDFOR
 ARG x0,11
 ADDR x0,x0,368
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,40
 // 41: PUM1 = state%u
 ARG x0,4
 ADDR x0,x0,32
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,41
 // 42: PVM1 = state%v
 ARG x0,4
 ADDR x0,x0,120
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,42
 // 43: PTM1 = state%T
 ARG x0,4
 ADDR x0,x0,208
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,43
 // 44: PQM1 = state%q
 ARG x0,4
 ADDR x0,x0,384
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,44
 // 45: PTKE1 = state%tke
 ARG x0,4
 ADDR x0,x0,560
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,45
 // 46: PLM1 = state%cld(:,:,NCLDQL)
 ARG x1,4
 ADDR x1,x1,1000
 mov x2,#1
 SPADDR x0,6480
 bl .Lsl_plane3
 SPADDR x0,6480
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,46
 // 47: PIM1 = state%cld(:,:,NCLDQI)
 ARG x1,4
 ADDR x1,x1,1000
 mov x2,#2
 SPADDR x0,6592
 bl .Lsl_plane3
 SPADDR x0,6592
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,47
 // 48: PAM1 = state%a
 ARG x0,4
 ADDR x0,x0,472
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,48
 // 49: PCM1 = GEMSL%ZCEN
 ARG x0,9
 ADDR x0,x0,224
 ldr x0,[x0]
 PUTARG x0,49
 // 50: PAPHM1 = PAUX%PAPRS
 ARG x0,3
 ADDR x0,x0,360
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,50
 // 51: PAPM1 = PAUX%PAPRSF
 ARG x0,3
 ADDR x0,x0,448
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,51
 // 52: PGEOM1 = PAUX%PGEOM1
 ARG x0,3
 ADDR x0,x0,184
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,52
 // 53: PGEOH = PAUX%PGEOMH
 ARG x0,3
 ADDR x0,x0,272
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,53
 // 54: PGELAT = PAUX%PGELAT
 ARG x0,3
 ADDR x0,x0,1040
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,54
 // 55: PTSKM1M = PSURF%PSP_RR(:,YSP_RR%YT%MP9)
 ARG x1,10
 ADDR x1,x1,8464
 ARG x12,0
 FIELD w2,x12,6808,8
 SPADDR x0,6704
 bl .Lsl_column2
 SPADDR x0,6704
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,55
 // 56: PTSAM1M = PSURF%PSP_SB(:,:,YSP_SB%YT%MP9)
 ARG x1,10
 ADDR x1,x1,9480
 ARG x12,0
 FIELD w2,x12,5944,8
 SPADDR x0,6816
 bl .Lsl_plane3
 SPADDR x0,6816
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#20]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,56
 // 57: PWSAM1M = PSURF%PSP_SB(:,:,YSP_SB%YQ%MP9)
 ARG x1,10
 ADDR x1,x1,9480
 ARG x12,0
 FIELD w2,x12,5952,8
 SPADDR x0,6928
 bl .Lsl_plane3
 SPADDR x0,6928
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#20]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,57
 // 58: PSSRFL = FLUX%PFRSO(:,KDIM%KLEV)
 ARG x1,12
 ADDR x1,x1,1848
 ARG x12,2
 ldrsw x2,[x12,#48]
 SPADDR x0,7040
 bl .Lsl_column2
 SPADDR x0,7040
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,58
 // 59: PSLRFL = FLUX%PFRTH(:,KDIM%KLEV)
 ARG x1,12
 ADDR x1,x1,1936
 ARG x12,2
 ldrsw x2,[x12,#48]
 SPADDR x0,7152
 bl .Lsl_column2
 SPADDR x0,7152
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,59
 // 60: PEMIS = PSURF%PEMIS
 ARG x0,10
 ADDR x0,x0,10680
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,60
 // 61: PHRLW = PRAD%PHRLW
 ARG x0,6
 ADDR x0,x0,2056
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,61
 // 62: PHRSW = PRAD%PHRSW
 ARG x0,6
 ADDR x0,x0,1968
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,62
 // 63: PTSNOW = PSURF%PSP_SG(:,:,YSP_SG%YT%MP9)
 ARG x1,10
 ADDR x1,x1,9256
 ARG x12,0
 FIELD w2,x12,6256,8
 SPADDR x0,7264
 bl .Lsl_plane3
 SPADDR x0,7264
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#64]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,63
 // 64: PTICE = PSURF%PSP_SB(:,:,YSP_SB%YTL%MP9)
 ARG x1,10
 ADDR x1,x1,9480
 ARG x12,0
 FIELD w2,x12,5960,8
 SPADDR x0,7376
 bl .Lsl_plane3
 SPADDR x0,7376
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,64
 // 65: PHLICE = PSURF%PSP_SL(:,YSP_SL%YLICD%MP9)
 ARG x1,10
 ADDR x1,x1,8376
 ARG x12,0
 FIELD w2,x12,6552,8
 SPADDR x0,7488
 bl .Lsl_column2
 SPADDR x0,7488
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,65
 // 66: PTLICE = PSURF%PSP_SL(:,YSP_SL%YLICT%MP9)
 ARG x1,10
 ADDR x1,x1,8376
 ARG x12,0
 FIELD w2,x12,6512,8
 SPADDR x0,7600
 bl .Lsl_column2
 SPADDR x0,7600
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,66
 // 67: PTLWML = PSURF%PSP_SL(:,YSP_SL%YLMLT%MP9)
 ARG x1,10
 ADDR x1,x1,8376
 ARG x12,0
 FIELD w2,x12,6520,8
 SPADDR x0,7712
 bl .Lsl_column2
 SPADDR x0,7712
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,67
 // 68: PSST = PSURF%PSD_VF(:,YSD_VF%YSST%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9048,0
 SPADDR x0,7824
 bl .Lsl_column2
 SPADDR x0,7824
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,68
 // 69: KSOTY = PSURF%ISOTY
 ARG x0,10
 ADDR x0,x0,12312
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#4
 bl .Lsl_raw
 PUTARG x0,69
 // 70: PFRTI = SURFL%ZFRTI
 ARG x0,11
 ADDR x0,x0,1096
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,70
 // 71: PALBTI = SURFL%ZALBTI
 ARG x0,11
 ADDR x0,x0,1184
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,71
 // 72: PWLMX = SURFL%ZWLMX
 ARG x0,11
 ADDR x0,x0,752
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,72
 // 73: PCHAR = PSURF%PSD_WS(:,YSD_WS%YCHAR%MP)
 ARG x1,10
 ADDR x1,x1,8640
 ARG x12,0
 FIELD w2,x12,15376,0
 SPADDR x0,7936
 bl .Lsl_column2
 SPADDR x0,7936
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,73
 // 74: PCHARHQ = PSURF%PSD_WS(:,YSD_WS%YCHARHQ%MP)
 ARG x1,10
 ADDR x1,x1,8640
 ARG x12,0
 FIELD w2,x12,15384,0
 SPADDR x0,8048
 bl .Lsl_inactive_surface_column2
 SPADDR x0,8048
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,74
 // 75: PUCURR = PSURF%PSD_VF(:,YSD_VF%YUCUR%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9176,0
 SPADDR x0,8160
 bl .Lsl_column2
 SPADDR x0,8160
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,75
 // 76: PVCURR = PSURF%PSD_VF(:,YSD_VF%YVCUR%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9184,0
 SPADDR x0,8272
 bl .Lsl_column2
 SPADDR x0,8272
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,76
 // 77: PUSTOKES = PSURF%PSD_WS(:,YSD_WS%YUSTOKES%MP)
 ARG x1,10
 ADDR x1,x1,8640
 ARG x12,0
 FIELD w2,x12,15392,0
 SPADDR x0,8384
 bl .Lsl_inactive_surface_column2
 SPADDR x0,8384
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,77
 // 78: PVSTOKES = PSURF%PSD_WS(:,YSD_WS%YVSTOKES%MP)
 ARG x1,10
 ADDR x1,x1,8640
 ARG x12,0
 FIELD w2,x12,15400,0
 SPADDR x0,8496
 bl .Lsl_inactive_surface_column2
 SPADDR x0,8496
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,78
 // 79: PTSKRAD = AUXL%ZTSKRAD
 ARG x0,8
 ADDR x0,x0,648
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,79
 // 80: PCFLX = GEMSL%ZCFLX
 ARG x0,9
 ADDR x0,x0,560
 ldr x0,[x0]
 PUTARG x0,80
 // 81: PDDVLC = GEMSL%ZDDVLC
 ARG x0,9
 ADDR x0,x0,648
 ldr x0,[x0]
 PUTARG x0,81
 // 82: PSOTEU = AUXL%ZSOTEU
 ARG x0,8
 ADDR x0,x0,976
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,82
 // 83: PSOTEV = AUXL%ZSOTEV
 ARG x0,8
 ADDR x0,x0,1064
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,83
 // 84: PSOBETA = AUXL%ZSOBETA
 ARG x0,8
 ADDR x0,x0,1152
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,84
 // 85: PTHKICE = SURFL%ZTHKICE
 ARG x0,11
 ADDR x0,x0,496
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,85
 // 86: PSNTICE = SURFL%ZSNTICE
 ARG x0,11
 ADDR x0,x0,560
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,86
 // 87: PGP2DSPP = ZGP2DSPP
 ldr x0,[sp,#4104]
 PUTARG x0,87
 // 88: LSICOUP = LNEMOSICOUP
 ARG x0,1
 ADDR x0,x0,1562992
 PUTARG x0,88
 // 89: PZ0M = GEMSL%ZAZ0M
 ARG x0,9
 ADDR x0,x0,2336
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,89
 // 90: PZ0H = GEMSL%ZAZ0H
 ARG x0,9
 ADDR x0,x0,2400
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,90
 // 91: PVDIS = PDIAG%PVDIS
 ARG x0,13
 ADDR x0,x0,816
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,91
 // 92: PVDISG = PDIAG%PVDISG
 ARG x0,13
 ADDR x0,x0,880
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,92
 // 93: PDISGW3D = PERTL%ZDISSGW
 ARG x0,14
 ADDR x0,x0,216
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,93
 // 94: PAHFLEV = FLUX%PFTLHEV
 ARG x0,12
 ADDR x0,x0,4280
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,94
 // 95: PAHFLSB = FLUX%PFTLHSB
 ARG x0,12
 ADDR x0,x0,4344
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,95
 // 96: PFWSB = FLUX%PFWSB
 ARG x0,12
 ADDR x0,x0,4024
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,96
 // 97: PU10M = PSURF%PSD_VD(:,YSD_VD%Y10U%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,12768,0
 SPADDR x0,8608
 bl .Lsl_column2
 SPADDR x0,8608
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,97
 // 98: PV10M = PSURF%PSD_VD(:,YSD_VD%Y10V%MP )
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,12776,0
 SPADDR x0,8720
 bl .Lsl_column2
 SPADDR x0,8720
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,98
 // 99: PT2M = PSURF%PSD_VD(:,YSD_VD%Y2T%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,12784,0
 SPADDR x0,8832
 bl .Lsl_column2
 SPADDR x0,8832
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,99
 // 100: PD2M = PSURF%PSD_VD(:,YSD_VD%Y2D%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,12792,0
 SPADDR x0,8944
 bl .Lsl_column2
 SPADDR x0,8944
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,100
 // 101: PQ2M = PSURF%PSD_VD(:,YSD_VD%Y2SH%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,12800,0
 SPADDR x0,9056
 bl .Lsl_column2
 SPADDR x0,9056
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,101
 // 102: PZINV = PDIAG%ZINV
 ARG x0,13
 ADDR x0,x0,2208
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,102
 // 103: PBLH = PSURF%PSD_VD(:,YSD_VD%YBLH%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13504,0
 SPADDR x0,9168
 bl .Lsl_column2
 SPADDR x0,9168
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,103
 // 104: PEIS = PDIAG%ZEIS
 ARG x0,13
 ADDR x0,x0,2144
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,104
 // 105: P10NU = PSURF%PSD_VD(:,YSD_VD%Y10NU%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,14368,0
 SPADDR x0,9280
 bl .Lsl_column2
 SPADDR x0,9280
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,105
 // 106: P10NV = PSURF%PSD_VD(:,YSD_VD%Y10NV%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,14376,0
 SPADDR x0,9392
 bl .Lsl_column2
 SPADDR x0,9392
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,106
 // 107: PUST = PSURF%PSD_VD(:,YSD_VD%YZUST%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,14360,0
 SPADDR x0,9504
 bl .Lsl_column2
 SPADDR x0,9504
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,107
 // 108: PSSRFLTI = SURFL%ZFRSOTI
 ARG x0,11
 ADDR x0,x0,1272
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,108
 // 109: PEVAPSNW = SURFL%ZEVAPSNW
 ARG x0,11
 ADDR x0,x0,1032
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,109
 // 110: PEVAPMU = ZEVAPMU
 ldr x0,[sp,#4056]
 PUTARG x0,110
 // 111: PEXDIAG = ZEXDIAG
 ldr x0,[sp,#4088]
 PUTARG x0,111
 // 112: PGUST = PDIAG%PI10FG
 ARG x0,13
 ADDR x0,x0,1072
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,112
 // 113: PI10FGCV = PSURF%PSD_VD(:,YSD_VD%Y10FGCV%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13864,0
 SPADDR x0,9616
 bl .Lsl_column2
 SPADDR x0,9616
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,113
 // 114: KPBLTYPE = PDIAG%IPBLTYPE
 ARG x0,13
 ADDR x0,x0,2552
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#4
 bl .Lsl_raw
 PUTARG x0,114
 // 115: PTE0 = tendency%T
 ARG x0,5
 ADDR x0,x0,208
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,115
 // 116: PQE0 = tendency%q
 ARG x0,5
 ADDR x0,x0,384
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,116
 // 117: PLE0 = tendency%cld(:,:,NCLDQL)
 ARG x1,5
 ADDR x1,x1,1000
 mov x2,#1
 SPADDR x0,9728
 bl .Lsl_plane3
 SPADDR x0,9728
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,117
 // 118: PIE0 = tendency%cld(:,:,NCLDQI)
 ARG x1,5
 ADDR x1,x1,1000
 mov x2,#2
 SPADDR x0,9840
 bl .Lsl_plane3
 SPADDR x0,9840
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,118
 // 119: PAE0 = tendency%a
 ARG x0,5
 ADDR x0,x0,472
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,119
 // 120: PVOM0 = tendency%u
 ARG x0,5
 ADDR x0,x0,32
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,120
 // 121: PVOL0 = tendency%v
 ARG x0,5
 ADDR x0,x0,120
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,121
 // 122: PTE = tendency_loc%T
 ARG x0,17
 ADDR x0,x0,208
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,122
 // 123: PQE = tendency_loc%q
 ARG x0,17
 ADDR x0,x0,384
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,123
 // 124: PLE = tendency_loc%cld(:,:,NCLDQL)
 ARG x1,17
 ADDR x1,x1,1000
 mov x2,#1
 SPADDR x0,9952
 bl .Lsl_plane3
 SPADDR x0,9952
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,124
 // 125: PIE = tendency_loc%cld(:,:,NCLDQI)
 ARG x1,17
 ADDR x1,x1,1000
 mov x2,#2
 SPADDR x0,10064
 bl .Lsl_plane3
 SPADDR x0,10064
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,125
 // 126: PAE = tendency_loc%a
 ARG x0,17
 ADDR x0,x0,472
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,126
 // 127: PVOM = tendency_loc%u
 ARG x0,17
 ADDR x0,x0,32
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,127
 // 128: PVOL = tendency_loc%v
 ARG x0,17
 ADDR x0,x0,120
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,128
 // 129: PTKEE = tendency_loc%tke
 ARG x0,17
 ADDR x0,x0,560
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,129
 // 130: PTENC = GEMSL%ZTENC
 ARG x0,9
 ADDR x0,x0,336
 ldr x0,[x0]
 PUTARG x0,130
 // 131: PTSKE1 = PSURF%PTLE1
 ARG x0,10
 ADDR x0,x0,11376
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,131
 // 132: PUSTRTI = PSURF%PUSTRTI
 ARG x0,10
 ADDR x0,x0,10240
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,132
 // 133: PVSTRTI = PSURF%PVSTRTI
 ARG x0,10
 ADDR x0,x0,10328
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,133
 // 134: PAHFSTI = PSURF%PAHFSTI
 ARG x0,10
 ADDR x0,x0,10416
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,134
 // 135: PEVAPTI = PSURF%PEVAPTI
 ARG x0,10
 ADDR x0,x0,10504
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,135
 // 136: PTSKTI = PSURF%PTSKTI
 ARG x0,10
 ADDR x0,x0,10592
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,136
 // 137: PAHFTRTI = SURFL%ZAHFTRTI
 ARG x0,11
 ADDR x0,x0,1360
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,137
 // 138: PANDAYVT = SURFL%ZANDAYVT
 ARG x0,11
 ADDR x0,x0,1624
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#2
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,138
 // 139: PANFMVT = SURFL%ZANFMVT
 ARG x0,11
 ADDR x0,x0,1712
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#2
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,139
 // 140: PDIFTS = FLUX%PDIFTS
 ARG x0,12
 ADDR x0,x0,616
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,140
 // 141: PDIFTQ = FLUX%PDIFTQ
 ARG x0,12
 ADDR x0,x0,352
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,141
 // 142: PDIFTL = FLUX%PDIFTL
 ARG x0,12
 ADDR x0,x0,528
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,142
 // 143: PDIFTI = FLUX%PDIFTI
 ARG x0,12
 ADDR x0,x0,440
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,143
 // 144: PSTRTU = FLUX%PSTRTU
 ARG x0,12
 ADDR x0,x0,2376
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,144
 // 145: PSTRTV = FLUX%PSTRTV
 ARG x0,12
 ADDR x0,x0,2464
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,145
 // 146: PTOFDU = FLUX%PTOFDU
 ARG x0,12
 ADDR x0,x0,3704
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,146
 // 147: PTOFDV = FLUX%PTOFDV
 ARG x0,12
 ADDR x0,x0,3768
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,147
 // 148: PSTRSOU = FLUX%PSTRDU
 ARG x0,12
 ADDR x0,x0,2200
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,148
 // 149: PSTRSOV = FLUX%PSTRDV
 ARG x0,12
 ADDR x0,x0,2288
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 add x2,x2,#1
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,149
 // 150: PKH = PDIAG%PKH_VDF
 ARG x0,13
 ADDR x0,x0,1880
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,150
 // 151: PKM = PDIAG%PKM_VDF
 ARG x0,13
 ADDR x0,x0,1968
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,151
 // 152: PRI = PDIAG%ZRI
 ARG x0,13
 ADDR x0,x0,2056
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#48]
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,152
 // 153: PAN = ZAN
 ldr x0,[sp,#4064]
 PUTARG x0,153
 // 154: PAG = PSURF%PSD_VD(:,YSD_VD%YIGPP%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13144,0
 SPADDR x0,10176
 bl .Lsl_column2
 SPADDR x0,10176
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,154
 // 155: PRD = ZRD
 ldr x0,[sp,#4072]
 PUTARG x0,155
 // 156: PRSOIL_STR = ZRSOIL_STR
 ldr x0,[sp,#4080]
 PUTARG x0,156
 // 157: PRECO = PSURF%PSD_VD(:,YSD_VD%YIREC%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13152,0
 SPADDR x0,10288
 bl .Lsl_column2
 SPADDR x0,10288
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,157
 // 158: PCO2FLUX = PSURF%PSD_VD(:,YSD_VD%YINEE%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13136,0
 SPADDR x0,10400
 bl .Lsl_column2
 SPADDR x0,10400
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,158
 // 159: PCH4FLUX = PSURF%PSD_VD(:,YSD_VD%YICH4%MP)
 ARG x1,10
 ADDR x1,x1,8992
 ARG x12,0
 FIELD w2,x12,13160,0
 SPADDR x0,10512
 bl .Lsl_column2
 SPADDR x0,10512
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,159
 // 160: PCFLXO = GEMSL%ZCFLXO
 ARG x0,9
 ADDR x0,x0,824
 ldr x0,[x0]
 PUTARG x0,160
 // 161: PDHTLS = PDDHS%PDHTLS
 ARG x0,16
 ADDR x0,x0,0
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#24]
 ARG x15,2
 ldrsw x3,[x15,#68]
 ARG x15,2
 ldrsw x14,[x15,#72]
 add x3,x3,x14
 mov x4,#8
 bl .Lsl_raw3
 PUTARG x0,161
 // 162: PDHTSS = PDDHS%PDHTSS
 ARG x0,16
 ADDR x0,x0,112
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#64]
 ARG x15,2
 ldrsw x3,[x15,#76]
 ARG x15,2
 ldrsw x14,[x15,#80]
 add x3,x3,x14
 mov x4,#8
 bl .Lsl_raw3
 PUTARG x0,162
 // 163: PDHTTS = PDDHS%PDHTTS
 ARG x0,16
 ADDR x0,x0,224
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#20]
 ARG x15,2
 ldrsw x3,[x15,#84]
 ARG x15,2
 ldrsw x14,[x15,#88]
 add x3,x3,x14
 mov x4,#8
 bl .Lsl_raw3
 PUTARG x0,163
 // 164: PDHTIS = PDDHS%PDHTIS
 ARG x0,16
 ADDR x0,x0,336
 ARG x15,2
 ldrsw x1,[x15,#12]
 ARG x15,2
 ldrsw x2,[x15,#56]
 ARG x15,2
 ldrsw x3,[x15,#92]
 ARG x15,2
 ldrsw x14,[x15,#96]
 add x3,x3,x14
 mov x4,#8
 bl .Lsl_raw3
 PUTARG x0,164
 // 165: PDHCO2S = ZDHCO2S
 ldr x0,[sp,#4096]
 PUTARG x0,165
 // 166: PDHVEGS = SURFL%ZDHVEGS
 ARG x0,11
 ADDR x0,x0,1800
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#2
 mov x3,#7
 mov x14,#1
 add x3,x3,x14
 mov x4,#8
 bl .Lsl_raw3
 PUTARG x0,166
 // 167: PCGPP = PSURF%PSD_VF(:,YSD_VF%YCGPP%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9200,0
 SPADDR x0,10624
 bl .Lsl_column2
 SPADDR x0,10624
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,167
 // 168: PCREC = PSURF%PSD_VF(:,YSD_VF%YCREC%MP)
 ARG x1,10
 ADDR x1,x1,8728
 ARG x12,0
 FIELD w2,x12,9208,0
 SPADDR x0,10736
 bl .Lsl_column2
 SPADDR x0,10736
 ARG x15,2
 ldrsw x1,[x15,#12]
 mov x2,#0
 mov x3,#8
 bl .Lsl_raw
 PUTARG x0,168
