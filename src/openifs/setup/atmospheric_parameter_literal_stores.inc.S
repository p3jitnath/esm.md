/* Source literal assignments in their original order. */
 adr x9,.Latm_literal_values
 ldr x10,[x9,#0]
 str x10,[x0,#48] /* A0ML_AU 4.5_JPRB */
 ldr x10,[x9,#8]
 str x10,[x0,#56] /* A0ML_AT 5.0_JPRB */
 ldr x10,[x9,#16]
 str x10,[x0,#64] /* A0ML_BU 3.0_JPRB */
 ldr x10,[x9,#24]
 str x10,[x0,#72] /* A0ML_BT 0.8_JPRB */
 ldr x10,[x9,#32]
 str x10,[x0,#80] /* AERCS1 0.2726_JPRB */
 ldr x10,[x9,#40]
 str x10,[x0,#88] /* AERCS3 -0.4239_JPRB */
 ldr x10,[x9,#48]
 str x10,[x0,#96] /* AERCS5 0.3595_JPRB */
 ldr x10,[x9,#56]
 str x10,[x0,#112] /* ALMAV 300._JPRB */
 ldr x10,[x9,#64]
 str x10,[x0,#120] /* BEDIFV 0.05_JPRB */
 ldr x10,[x9,#72]
 str x10,[x0,#128] /* ECMNP 3000._JPRB */
 ldr x10,[x9,#80]
 str x10,[x0,#136] /* EDB 5._JPRB */
 ldr x10,[x9,#88]
 str x10,[x0,#144] /* EDC 5._JPRB */
 ldr x10,[x9,#96]
 str x10,[x0,#152] /* EDD 5._JPRB */
 ldr x10,[x9,#104]
 str x10,[x0,#2288] /* EDK 1.0_JPRB */
 ldr x10,[x9,#112]
 str x10,[x0,#1792] /* EFB_AZ0 0.2_JPRB */
 ldr x10,[x9,#120]
 str x10,[x0,#1800] /* EFB_UR 0.4545_JPRB */
 ldr x10,[x9,#128]
 str x10,[x0,#952] /* ETACUT 1.0_JPRB */
 ldr x10,[x9,#136]
 str x10,[x0,#160] /* EVAP 4.8E+06_JPRB */
 ldr x10,[x9,#144]
 str x10,[x0,#168] /* FONT 2.4E+04_JPRB */
 ldr x10,[x9,#152]
 str x10,[x0,#176] /* GALP 0.53_JPRB */
 ldr x10,[x9,#160]
 str x10,[x0,#184] /* GCISMIN 6.7E-05_JPRB */
 ldr x10,[x9,#168]
 str x10,[x0,#192] /* GEVAVF 6.7E-05_JPRB */
 ldr x10,[x9,#176]
 str x10,[x0,#200] /* GCCSV 0._JPRB */
 ldr x10,[x9,#184]
 str x10,[x0,#208] /* GCVADS 0.8_JPRB */
 ldr x10,[x9,#192]
 str x10,[x0,#1056] /* GCVALFA 4.5E-05_JPRB */
 ldr x10,[x9,#200]
 str x10,[x0,#216] /* GCVBETA 0.2_JPRB */
 ldr x10,[x9,#208]
 str x10,[x0,#224] /* GCVIMPT 0.0_JPRB */
 ldr x10,[x9,#216]
 str x10,[x0,#1128] /* GCVMLT 0.00016_JPRB */
 ldr x10,[x9,#224]
 str x10,[x0,#1112] /* GCVNU 2.5E-05_JPRB */
 ldr x10,[x9,#232]
 str x10,[x0,#1064] /* GCVPSI 0.5_JPRB */
 ldr x10,[x9,#240]
 str x10,[x0,#1072] /* GCVPSIE 0.0_JPRB */
 ldr x10,[x9,#248]
 str x10,[x0,#312] /* GDDEVA 0.25_JPRB */
 ldr x10,[x9,#256]
 str x10,[x0,#320] /* GDDSDE 0.5_JPRB */
 ldr x10,[x9,#264]
 str x10,[x0,#1160] /* GPBLHK0 0.25_JPRB */
 ldr x10,[x9,#272]
 str x10,[x0,#1168] /* GPBLHRA 4._JPRB */
 ldr x10,[x9,#280]
 str x10,[x0,#344] /* GRCVPP 1._JPRB */
 ldr x10,[x9,#288]
 str x10,[x0,#352] /* GWDAMP 0.6_JPRB */
 ldr x10,[x9,#296]
 str x10,[x0,#360] /* GWDBC 2._JPRB */
 ldr x10,[x9,#304]
 str x10,[x0,#368] /* GWDCCO 1._JPRB */
 ldr x10,[x9,#312]
 str x10,[x0,#376] /* GWDCD 6._JPRB */
 ldr x10,[x9,#320]
 str x10,[x0,#384] /* GWDLT 0._JPRB */
 ldr x10,[x9,#328]
 str x10,[x0,#392] /* GWDSE 3.5E-03_JPRB */
 ldr x10,[x9,#336]
 str x10,[x0,#400] /* GWDPROF 1._JPRB */
 ldr x10,[x9,#344]
 str x10,[x0,#408] /* GWDVALI 0._JPRB */
 ldr x10,[x9,#352]
 str x10,[x0,#416] /* HOBST 3._JPRB */
 ldr x10,[x9,#360]
 str x10,[x0,#424] /* HUCOE 2._JPRB */
 ldr x10,[x9,#368]
 str x10,[x0,#432] /* HUTIL 1.8_JPRB */
 ldr x10,[x9,#376]
 str x10,[x0,#440] /* HUTIL1 -0.6_JPRB */
 ldr x10,[x9,#384]
 str x10,[x0,#448] /* HUTIL2 1.1_JPRB */
 ldr x10,[x9,#392]
 str w10,[x0,#40] /* NPCLO1 1 */
 ldr x10,[x9,#400]
 str w10,[x0,#44] /* NPCLO2 1 */
 ldr x10,[x9,#408]
 str x10,[x0,#1096] /* QSSC 1600._JPRB */
 ldr x10,[x9,#416]
 str x10,[x0,#464] /* QSMODC 1._JPRB */
 ldr x10,[x9,#424]
 str x10,[x0,#456] /* QSMIN 1.E-4_JPRB */
 ldr x10,[x9,#432]
 str x10,[x0,#472] /* QSNEBC 26000._JPRB */
 ldr x10,[x9,#440]
 str x10,[x0,#480] /* QSNEBS 0.7_JPRB */
 ldr x10,[x9,#448]
 str x10,[x0,#488] /* QSSUSC 1._JPRB */
 ldr x10,[x9,#456]
 str x10,[x0,#496] /* QSSUSS 0.25_JPRB */
 ldr x10,[x9,#464]
 str x10,[x0,#504] /* QSSUSV 0._JPRB */
 ldr x10,[x9,#472]
 str x10,[x0,#512] /* QSUSXC 3.3E-05_JPRB */
 ldr x10,[x9,#480]
 str x10,[x0,#520] /* QSUSXS 3.3E-05_JPRB */
 ldr x10,[x9,#488]
 str x10,[x0,#616] /* RDECRD 2.E+04_JPRB */
 ldr x10,[x9,#496]
 str x10,[x0,#624] /* RDECRD1 1.E+04_JPRB */
 ldr x10,[x9,#504]
 str x10,[x0,#632] /* RDECRD2 2.E+04_JPRB */
 ldr x10,[x9,#512]
 str x10,[x0,#640] /* RDECRD3 0.30_JPRB */
 ldr x10,[x9,#520]
 str x10,[x0,#648] /* RDECRD4 0.45_JPRB */
 ldr x10,[x9,#528]
 str x10,[x0,#656] /* RDECRDRED 1._JPRB */
 ldr x10,[x9,#536]
 str x10,[x0,#688] /* RGELSFON 0.0125_JPRB */
 ldr x10,[x9,#544]
 str x10,[x0,#672] /* REVAPN 1._JPRB */
 ldr x10,[x9,#552]
 str x10,[x0,#528] /* RPHI0 0._JPRB */
 ldr x10,[x9,#560]
 str x10,[x0,#536] /* RPHIR 1750._JPRB */
 ldr x10,[x9,#568]
 str x10,[x0,#544] /* QXRAL 130._JPRB */
 ldr x10,[x9,#576]
 str x10,[x0,#552] /* QXRAL_ADJ 130._JPRB */
 ldr x10,[x9,#584]
 str x10,[x0,#592] /* QXRCDIL 0.5_JPRB */
 ldr x10,[x9,#592]
 str x10,[x0,#560] /* QXRDEL 0._JPRB */
 ldr x10,[x9,#600]
 str x10,[x0,#568] /* QXRHX 1._JPRB */
 ldr x10,[x9,#608]
 str x10,[x0,#576] /* QXRR 0.5_JPRB */
 ldr x10,[x9,#616]
 str x10,[x0,#584] /* QXRTGH 3.5_JPRB */
 ldr x10,[x9,#624]
 str x10,[x0,#600] /* RCIN 0._JPRB */
 ldr x10,[x9,#632]
 str x10,[x0,#608] /* RCVEVAP 0._JPRB */
 ldr x10,[x9,#640]
 str x10,[x0,#680] /* REVGSL 80._JPRB */
 ldr x10,[x9,#648]
 str x10,[x0,#1808] /* REFB_1 9.0_JPRB */
 ldr x10,[x9,#656]
 str x10,[x0,#1816] /* REFB_2 5.0_JPRB */
 ldr x10,[x9,#664]
 str x10,[x0,#1824] /* REFB_3 -11.0_JPRB */
 ldr x10,[x9,#672]
 str x10,[x0,#696] /* RFLCHCE 0._JPRB */
 ldr x10,[x9,#680]
 str x10,[x0,#704] /* RTCAPE 10800._JPRB */
 ldr x10,[x9,#688]
 str x10,[x0,#712] /* SCO -20._JPRB */
 ldr x10,[x9,#696]
 str x10,[x0,#720] /* SENSL 1._JPRB */
 ldr x10,[x9,#704]
 str x10,[x0,#728] /* SNNBCO 0._JPRB */
 ldr x10,[x9,#712]
 str x10,[x0,#736] /* SPNBCO 3000._JPRB */
 ldr x10,[x9,#720]
 str x10,[x0,#744] /* SXNBCO 0.5_JPRB */
 ldr x10,[x9,#728]
 str x10,[x0,#752] /* TCA 1._JPRB */
 ldr x10,[x9,#736]
 str x10,[x0,#760] /* TCT 1.E-4_JPRB */
 ldr x10,[x9,#744]
 str x10,[x0,#768] /* TCW 8.E-4_JPRB */
 ldr x10,[x9,#752]
 str x10,[x0,#776] /* TENTR 2.5E-06_JPRB */
 ldr x10,[x9,#760]
 str x10,[x0,#784] /* TENTRX 8.E-05_JPRB */
 ldr x10,[x9,#768]
 str x10,[x0,#800] /* TDDGP 0.8_JPRB */
 ldr x10,[x9,#776]
 str x10,[x0,#792] /* TUDGP 0.8_JPRB */
 ldr x10,[x9,#784]
 str x10,[x0,#808] /* TURB 1._JPRB */
 ldr x10,[x9,#792]
 str x10,[x0,#816] /* TVF 1._JPRB */
 ldr x10,[x9,#800]
 str x10,[x0,#0] /* TYM 0.92_JPRB */
 ldr x10,[x9,#808]
 str x10,[x0,#8] /* TYM 0.74_JPRB */
 ldr x10,[x9,#816]
 str x10,[x0,#16] /* TYM 16.6_JPRB */
 ldr x10,[x9,#824]
 str x10,[x0,#24] /* TYM 10.1_JPRB */
 ldr x10,[x9,#832]
 str x10,[x0,#32] /* TYM 0.08_JPRB */
 ldr x10,[x9,#840]
 str x10,[x0,#824] /* UHDIFV 8.E-04_JPRB */
 ldr x10,[x9,#848]
 str x10,[x0,#832] /* USDMLT 1.25E+04_JPRB */
 ldr x10,[x9,#856]
 str x10,[x0,#840] /* USUPRC 0.0_JPRB */
 ldr x10,[x9,#864]
 str x10,[x0,#848] /* USURIC 1.0_JPRB */
 ldr x10,[x9,#872]
 str x10,[x0,#1104] /* USURID 0.035_JPRB */
 ldr x10,[x9,#880]
 str x10,[x0,#1120] /* USURIDE 1.0_JPRB */
 ldr x10,[x9,#888]
 str x10,[x0,#1080] /* USURICE 0.5_JPRB */
 ldr x10,[x9,#896]
 str x10,[x0,#1088] /* USURICL 4._JPRB */
 ldr x10,[x9,#904]
 str x10,[x0,#1136] /* UTILGUST 0.125_JPRB */
 ldr x10,[x9,#912]
 str x10,[x0,#856] /* VCHRNK 0.021_JPRB */
 ldr x10,[x9,#920]
 str x10,[x0,#864] /* VKARMN 0.4_JPRB */
 ldr x10,[x9,#928]
 str x10,[x0,#872] /* VZ0CM 1.5E-04_JPRB */
 ldr x10,[x9,#936]
 str x10,[x0,#880] /* VZIUSTAR0 0._JPRB */
 ldr x10,[x9,#944]
 str x10,[x0,#888] /* XNBMAX 1._JPRB */
 ldr x10,[x9,#952]
 str x10,[x0,#992] /* AHCLPV 1000._JPRB */
 ldr x10,[x9,#960]
 str x10,[x0,#1000] /* RICRLM 0.5_JPRB */
 ldr x10,[x9,#968]
 str x10,[x0,#1144] /* RRGAMMA 0.8_JPRB */
 ldr x10,[x9,#976]
 str x10,[x0,#1152] /* RRSCALE 1.15E-4_JPRB */
 ldr x10,[x9,#984]
 str x10,[x0,#1016] /* XBLM 6.5_JPRB */
 ldr x10,[x9,#992]
 str x10,[x0,#2296] /* XKLM 1.0_JPRB */
 ldr x10,[x9,#1000]
 str x10,[x0,#1032] /* XMAXLM 3000._JPRB */
 ldr x10,[x9,#1008]
 str x10,[x0,#1024] /* XMINLM 500._JPRB */
 ldr x10,[x9,#1016]
 str x10,[x0,#1040] /* XWSALM 0.1_JPRB */
 ldr x10,[x9,#1024]
 str x10,[x0,#1048] /* XWSBLM 7.0_JPRB */
 ldr x10,[x9,#1032]
 str x10,[x0,#2272] /* RNEGAT -7.E-05_JPRB */
 ldr x10,[x9,#1040]
 str x10,[x0,#2280] /* RNLCURV 7.E+04_JPRB */
 ldr x10,[x9,#1048]
 str x10,[x0,#1176] /* WMXOV 1.0_JPRB */
 ldr x10,[x9,#1056]
 str x10,[x0,#2344] /* TRENTRV 1._JPRB */
 ldr x10,[x9,#1064]
 str x10,[x0,#2336] /* TENTRVL -1.0_JPRB */
 ldr x10,[x9,#1072]
 str x10,[x0,#2352] /* GCVGAMMA 20._JPRB */
 ldr x10,[x9,#1080]
 str w10,[x0,#2360] /* LKESC .FALSE. */
 ldr x10,[x9,#1088]
 str x10,[x0,#664] /* RDTFAC 0.5_JPRB */
 ldr x10,[x9,#1096]
 str x10,[x0,#664] /* RDTFAC 1.0_JPRB */
 ldr x10,[x9,#1104]
 str x10,[x0,#1296] /* RAUTEFR 1.E-03_JPRB */
 ldr x10,[x9,#1112]
 str x10,[x0,#1304] /* RRAUTCS 1.0_JPRB */
 ldr x10,[x9,#1120]
 str x10,[x0,#1312] /* RAUTEFS 1.E-03_JPRB */
 ldr x10,[x9,#1128]
 str x10,[x0,#1320] /* RAUTSBET 0.025_JPRB */
 ldr x10,[x9,#1136]
 str x10,[x0,#1336] /* RNINTR 8.E+06_JPRB */
 ldr x10,[x9,#1144]
 str x10,[x0,#1344] /* RNINTS 2.E+06_JPRB */
 ldr x10,[x9,#1152]
 str x10,[x0,#1352] /* RQLCR 2.E-04_JPRB */
 ldr x10,[x9,#1160]
 str x10,[x0,#1360] /* RSPCRR 0.0_JPRB */
 ldr x10,[x9,#1168]
 str x10,[x0,#1368] /* RQICRMAX 0.3E-04_JPRB */
 ldr x10,[x9,#1176]
 str x10,[x0,#1376] /* RQICRMIN 0.2E-06_JPRB */
 ldr x10,[x9,#1184]
 str x10,[x0,#1384] /* RQLCV 2.E-04_JPRB */
 ldr x10,[x9,#1192]
 str x10,[x0,#1392] /* RQICVMAX 0.3E-04_JPRB */
 ldr x10,[x9,#1200]
 str x10,[x0,#1400] /* RQICVMIN 0.2E-06_JPRB */
 ldr x10,[x9,#1208]
 str x10,[x0,#1408] /* RQICRT1 -80._JPRB */
 ldr x10,[x9,#1216]
 str x10,[x0,#1416] /* RQICRT2 30._JPRB */
 ldr x10,[x9,#1224]
 str x10,[x0,#1424] /* RQICRSN 0.5_JPRB */
 ldr x10,[x9,#1232]
 str x10,[x0,#1432] /* RQCRNS 0.03_JPRB */
 ldr x10,[x9,#1240]
 str x10,[x0,#1440] /* RACCEF 1._JPRB */
 ldr x10,[x9,#1248]
 str x10,[x0,#1448] /* RAGGEF 0.2_JPRB */
 ldr x10,[x9,#1256]
 str x10,[x0,#1456] /* RRIMEF 1._JPRB */
 ldr x10,[x9,#1264]
 str x10,[x0,#1328] /* REVASX 0.0_JPRB */
 ldr x10,[x9,#1272]
 str x10,[x0,#1464] /* RHCRIT1 0.5_JPRB */
 ldr x10,[x9,#1280]
 str x10,[x0,#1472] /* RHCRIT2 0.91_JPRB */
 ldr x10,[x9,#1288]
 str x10,[x0,#1480] /* RETAMIN 0.4_JPRB */
 ldr x10,[x9,#1296]
 str x10,[x0,#1488] /* RFACNSM 1.4_JPRB */
 ldr x10,[x9,#1304]
 str x10,[x0,#1496] /* TFVL 0.0_JPRB */
 ldr x10,[x9,#1312]
 str x10,[x0,#1504] /* TFVI 0.0_JPRB */
 ldr x10,[x9,#1320]
 str x10,[x0,#1512] /* TFVR 5.0_JPRB */
 ldr x10,[x9,#1328]
 str x10,[x0,#1520] /* TFVS 0.6_JPRB */
 ldr x10,[x9,#1336]
 str x10,[x0,#1528] /* GRHCMOD 0.3_JPRB */
 ldr x10,[x9,#1344]
 str x10,[x0,#1536] /* RHCEXPDX 0.3_JPRB */
 ldr x10,[x9,#1352]
 str x10,[x0,#104] /* ADJTAU 900._JPRB */
 ldr x10,[x9,#1360]
 str x10,[x0,#2488] /* RDPHIC 10000._JPRB */
 ldr x10,[x9,#1368]
 str x10,[x0,#2496] /* RWBF1 300._JPRB */
 ldr x10,[x9,#1376]
 str x10,[x0,#2504] /* RWBF2 4._JPRB */
 ldr x10,[x9,#1384]
 str x10,[x0,#2512] /* SCLESPR 248000._JPRB */
 ldr x10,[x9,#1392]
 str x10,[x0,#2520] /* SCLESPS 15500._JPRB */
 ldr x10,[x9,#1400]
 str x10,[x0,#2528] /* HUCRED 1.0_JPRB */
 ldr x10,[x9,#1408]
 str x10,[x0,#2536] /* HUCREDRA 0.0_JPRB */
 ldr x10,[x9,#1416]
 str x10,[x0,#2544] /* FSPRAIN 13.4_JPRB */
 ldr x10,[x9,#1424]
 str x10,[x0,#2552] /* EFFCOLL 6.7E-02_JPRB */
 ldr x10,[x9,#1432]
 str x10,[x0,#2560] /* RSMDNEBX 0.2_JPRB */
 ldr x10,[x9,#1440]
 str x10,[x0,#2568] /* RSMDTX 1.0_JPRB */
 ldr x10,[x9,#1448]
 str w10,[x0,#2576] /* NSMTPA 2 */
 ldr x10,[x9,#1456]
 str w10,[x0,#2580] /* NSMTPB 3 */
 ldr x10,[x9,#1464]
 str x10,[x0,#1832] /* TUDBU 0.5_JPRB */
 ldr x10,[x9,#1472]
 str x10,[x0,#1840] /* TDDBU 0.5_JPRB */
 ldr x10,[x9,#1480]
 str x10,[x0,#1848] /* TUDFR 0.0012_JPRB */
 ldr x10,[x9,#1488]
 str x10,[x0,#1856] /* TDDFR 0.0006_JPRB */
 ldr x10,[x9,#1496]
 str x10,[x0,#1864] /* GCVALMX 0.95_JPRB */
 ldr x10,[x9,#1504]
 str x10,[x0,#1008] /* RMULACVG 25._JPRB */
 ldr x10,[x9,#1512]
 str x10,[x0,#1880] /* GCVACHI 1.E9_JPRB */
 ldr x10,[x9,#1520]
 str x10,[x0,#1888] /* GCVBEE 0._JPRB */
 ldr x10,[x9,#1528]
 str x10,[x0,#1896] /* GCVEEX 1._JPRB */
 ldr x10,[x9,#1536]
 str x10,[x0,#1872] /* GCVTAUDE 900._JPRB */
 ldr x10,[x9,#1544]
 str x10,[x0,#1904] /* ECMNPI 3000._JPRB */
 ldr x10,[x9,#1552]
 str x10,[x0,#2024] /* GPEIPHI 0._JPRB */
 ldr x10,[x9,#1560]
 str x10,[x0,#2048] /* GENVSRH 0._JPRB */
 ldr x10,[x9,#1568]
 str x10,[x0,#2032] /* GPETAU 0._JPRB */
 ldr x10,[x9,#1576]
 str x10,[x0,#2040] /* GPEFDC 1._JPRB */
 ldr x10,[x9,#1584]
 str x10,[x0,#1912] /* GRRMINA 1.E-5_JPRB */
 ldr x10,[x9,#1592]
 str x10,[x0,#1920] /* GDDBETA 2.0_JPRB */
 ldr x10,[x9,#1600]
 str x10,[x0,#1928] /* GDDDP 10000._JPRB */
 ldr x10,[x9,#1608]
 str x10,[x0,#1936] /* GDDFXM 1.E+5_JPRB */
 ldr x10,[x9,#1616]
 str x10,[x0,#1952] /* GDDEVF 0.5_JPRB */
 ldr x10,[x9,#1624]
 str x10,[x0,#1944] /* GDDWPF 0._JPRB */
 ldr x10,[x9,#1632]
 str x10,[x0,#1960] /* TENTRD 1.E-4_JPRB */
 ldr x10,[x9,#1640]
 str x10,[x0,#1968] /* GDDALBU 1._JPIM */
 ldr x10,[x9,#1648]
 str x10,[x0,#1976] /* GDDFRAC 0.33_JPIM */
 ldr x10,[x9,#1656]
 str x10,[x0,#1984] /* GDDENDYMX 1.E-4_JPRB */
 ldr x10,[x9,#1664]
 str x10,[x0,#1992] /* GDDFP 4.398E-2_JPRB */
 ldr x10,[x9,#1672]
 str x10,[x0,#2000] /* GDDFP 0.75_JPRB */
 ldr x10,[x9,#1680]
 str x10,[x0,#2008] /* GDDFP 0._JPRB */
 ldr x10,[x9,#1688]
 str x10,[x0,#2016] /* GDDTAUSIG 0._JPRB */
 ldr x10,[x9,#1696]
 str x10,[x0,#328] /* GDDFREVS 0.5_JPRB */
 ldr x10,[x9,#1704]
 str x10,[x0,#336] /* GDDINHOM 2.0_JPRB */
 ldr x10,[x9,#1712]
 str x10,[x0,#2064] /* GCVALBU 0.9_JPRB */
 ldr x10,[x9,#1720]
 str x10,[x0,#2072] /* GCVENDY1 1.E-8_JPRB */
 ldr x10,[x9,#1728]
 str x10,[x0,#2080] /* GCVENDY2 5.E-5_JPRB */
 ldr x10,[x9,#1736]
 str x10,[x0,#2088] /* GCVENDYMX 1.E-4_JPRB */
 ldr x10,[x9,#1744]
 str x10,[x0,#2096] /* GCVIDPBAS 3.E-3_JPRB */
 ldr x10,[x9,#1752]
 str x10,[x0,#2104] /* GCVTAUSIG -1._JPRB */
 ldr x10,[x9,#1760]
 str x10,[x0,#2056] /* GCVKSKV 3._JPRB */
 ldr x10,[x9,#1768]
 str x10,[x0,#2200] /* GCVCATAU 1000._JPRB */
 ldr x10,[x9,#1776]
 str x10,[x0,#2208] /* GCATHRCAP 200._JPRB */
 ldr x10,[x9,#1784]
 str x10,[x0,#2216] /* GCATHRMOC -1._JPRB */
 ldr x10,[x9,#1792]
 str x10,[x0,#2224] /* GCATHRCND -1._JPRB */
 ldr x10,[x9,#1800]
 str x10,[x0,#2232] /* GCAOMCND 1._JPRB */
 ldr x10,[x9,#1808]
 str x10,[x0,#2136] /* GTRGKCK9 0.4_JPRB */
 ldr x10,[x9,#1816]
 str x10,[x0,#2112] /* GTRGDPMIX 6000._JPRB */
 ldr x10,[x9,#1824]
 str x10,[x0,#2120] /* GTRGDPHIMN 29340._JPRB */
 ldr x10,[x9,#1832]
 str x10,[x0,#2128] /* GTRGPUSLMN 30000._JPRB */
 ldr x10,[x9,#1840]
 str x10,[x0,#2144] /* GTRGAIN 2._JPRB */
 ldr x10,[x9,#1848]
 str x10,[x0,#2152] /* GTRTHRS 0.15_JPRB */
 ldr x10,[x9,#1856]
 str x10,[x0,#2160] /* GTRTHCK 5.E4_JPRB */
 ldr x10,[x9,#1864]
 str x10,[x0,#2168] /* GTRBRC 0.5_JPRB */
 ldr x10,[x9,#1872]
 str x10,[x0,#2176] /* GTRKGAIN 100._JPRB */
 ldr x10,[x9,#1880]
 str x10,[x0,#2184] /* GTRKTHRS 0.02_JPRB */
 ldr x10,[x9,#1888]
 str x10,[x0,#2192] /* GTRKTHCK 2000._JPRB */
 ldr x10,[x9,#1896]
 str w10,[x0,#2660] /* LGDDD .FALSE. */
 ldr x10,[x9,#1904]
 str w10,[x0,#2664] /* LCVNHD .FALSE. */
 ldr x10,[x9,#1912]
 str w10,[x0,#2668] /* LCVRESDYN .FALSE. */
 ldr x10,[x9,#1920]
 str w10,[x0,#3324] /* LCVDS .FALSE. */
 ldr x10,[x9,#1928]
 str w10,[x0,#2672] /* LCVMICC .FALSE. */
 ldr x10,[x9,#1936]
 str x10,[x0,#2680] /* GMUKEDD 0._JPRB */
 ldr x10,[x9,#1944]
 str x10,[x0,#2688] /* GNHDTAT 0.1_JPRB */
 ldr x10,[x9,#1952]
 str x10,[x0,#2696] /* GNHDSMOS 900._JPRB */
 ldr x10,[x9,#1960]
 str x10,[x0,#2704] /* GNHDSMOT 0.22_JPRB */
 ldr x10,[x9,#1968]
 str x10,[x0,#2712] /* GNHDEV 0._JPRB */
 ldr x10,[x9,#1976]
 str x10,[x0,#3240] /* GNHDTAU 0._JPRB */
 ldr x10,[x9,#1984]
 str w10,[x0,#3032] /* LCVEOD .FALSE. */
 ldr x10,[x9,#1992]
 str w10,[x0,#3384] /* LGPRONI1 .FALSE. */
 ldr x10,[x9,#2000]
 str w10,[x0,#3388] /* NPRONI 0 */
 ldr x10,[x9,#2008]
 str x10,[x0,#3392] /* GPRONI 1._JPRB */
 ldr x10,[x9,#2016]
 str w10,[x0,#2720] /* LGVVEX .FALSE. */
 ldr x10,[x9,#2024]
 str w10,[x0,#2728] /* NCVENTR 1 */
 ldr x10,[x9,#2032]
 str w10,[x0,#2732] /* NCVSIG 1 */
 ldr x10,[x9,#2040]
 str w10,[x0,#2736] /* NCVCLOS 1 */
 ldr x10,[x9,#2048]
 str w10,[x0,#2740] /* NCVQLI 1 */
 ldr x10,[x9,#2056]
 str x10,[x0,#2744] /* GCVENTRN 1.2E-4_JPRB */
 ldr x10,[x9,#2064]
 str x10,[x0,#2752] /* GCVENTRX 6.0E-4_JPRB */
 ldr x10,[x9,#2072]
 str x10,[x0,#2784] /* GCVENTR_MIN 0._JPRB */
 ldr x10,[x9,#2080]
 str x10,[x0,#2792] /* THPCMT -1._JPRB */
 ldr x10,[x9,#2088]
 str x10,[x0,#2824] /* GAEPS 1._JPRB */
 ldr x10,[x9,#2096]
 str x10,[x0,#2832] /* GCVEZ 1._JPRB */
 ldr x10,[x9,#2104]
 str x10,[x0,#2840] /* GCVTRMIN 10000._JPRB */
 ldr x10,[x9,#2112]
 str w10,[x0,#2848] /* LCVFEVV .FALSE. */
 ldr x10,[x9,#2120]
 str x10,[x0,#2856] /* GCVFEVV 0._JPRB */
 ldr x10,[x9,#2128]
 str x10,[x0,#2872] /* GCVTEXC 0._JPRB */
 ldr x10,[x9,#2136]
 str x10,[x0,#2880] /* GCVWEXC 0._JPRB */
 ldr x10,[x9,#2144]
 str x10,[x0,#3064] /* GFSURF 0._JPRB */
 ldr x10,[x9,#2152]
 str w10,[x0,#2888] /* LCVNAUV .TRUE. */
 ldr x10,[x9,#2160]
 str x10,[x0,#2896] /* GCVFRR 1._JPRB */
 ldr x10,[x9,#2168]
 str x10,[x0,#2904] /* GCVPNH 0._JPRB */
 ldr x10,[x9,#2176]
 str x10,[x0,#2912] /* GCVORGED 0._JPRB */
 ldr x10,[x9,#2184]
 str x10,[x0,#2928] /* GCVTAUREM 0._JPRB */
 ldr x10,[x9,#2192]
 str x10,[x0,#2936] /* GCLOEA 1._JPRB */
 ldr x10,[x9,#2200]
 str x10,[x0,#2944] /* GCLOEB 0._JPRB */
 ldr x10,[x9,#2208]
 str x10,[x0,#2952] /* GFRAE 0._JPRB */
 ldr x10,[x9,#2216]
 str x10,[x0,#2960] /* GCVADET 0._JPRB */
 ldr x10,[x9,#2224]
 str x10,[x0,#2968] /* GCVCINC 0.0_JPRB */
 ldr x10,[x9,#2232]
 str x10,[x0,#2976] /* GSDMIN 1.0E-3_JPRB */
 ldr x10,[x9,#2240]
 str x10,[x0,#3056] /* GCHI0 1._JPRB */
 ldr x10,[x9,#2248]
 str x10,[x0,#2984] /* GSDMAX 1.3E-3_JPRB */
 ldr x10,[x9,#2256]
 str x10,[x0,#2992] /* GALMIN 0.011_JPRB */
 ldr x10,[x9,#2264]
 str x10,[x0,#3000] /* GALMAX 0.030_JPRB */
 ldr x10,[x9,#2272]
 str x10,[x0,#3008] /* GSDAMIN 6.0E-4_JPRB */
 ldr x10,[x9,#2280]
 str x10,[x0,#3016] /* GSDAMAX 2.1E-3_JPRB */
 ldr x10,[x9,#2288]
 str x10,[x0,#3024] /* GEXPKD 2.0_JPRB */
 ldr x10,[x9,#2296]
 str x10,[x0,#3040] /* GREMIN 0.01_JPRB */
 ldr x10,[x9,#2304]
 str x10,[x0,#3048] /* GREMAX 1.0_JPRB */
 ldr x10,[x9,#2312]
 str x10,[x0,#3072] /* GSHELL 0._JPRB */
 ldr x10,[x9,#2320]
 str x10,[x0,#3168] /* GCVFNER 0._JPRB */
 ldr x10,[x9,#2328]
 str x10,[x0,#3176] /* GCVFNEO -5.0_JPRB */
 ldr x10,[x9,#2336]
 str x10,[x0,#3184] /* GCVFNEP1 30000._JPRB */
 ldr x10,[x9,#2344]
 str x10,[x0,#3192] /* GCVFNEP2 10000._JPRB */
 ldr x10,[x9,#2352]
 str x10,[x0,#3200] /* GRBCC 1.0_JPRB */
 ldr x10,[x9,#2360]
 str x10,[x0,#3288] /* GREDDI 1.0_JPRB */
 ldr x10,[x9,#2368]
 str x10,[x0,#3296] /* GREDDL 1.0_JPRB */
 ldr x10,[x9,#2376]
 str x10,[x0,#3304] /* GREDDR 1.0_JPRB */
 ldr x10,[x9,#2384]
 str x10,[x0,#3312] /* GREDDS 1.0_JPRB */
 ldr x10,[x9,#2392]
 str x10,[x0,#3328] /* GCVUV 1.0_JPRB */
 ldr x10,[x9,#2400]
 str x10,[x0,#3352] /* GCHECKMV_TMIN -200._JPRB */
 ldr x10,[x9,#2408]
 str x10,[x0,#3360] /* GCHECKMV_TMAX +200._JPRB */
 ldr x10,[x9,#2416]
 str x10,[x0,#3368] /* GCHECKMV_QVMIN -0.1_JPRB */
 ldr x10,[x9,#2424]
 str x10,[x0,#3376] /* GCHECKMV_QVMAX +0.2_JPRB */
 ldr x10,[x9,#2432]
 str x10,[x0,#3272] /* GCVRE 1._JPRB */
 ldr x10,[x9,#2440]
 str w10,[x0,#3280] /* LSBUO .FALSE. */
 ldr x10,[x9,#2448]
 str w10,[x0,#3320] /* LCVTADV .FALSE. */
 ldr x10,[x9,#2456]
 str x10,[x0,#3248] /* GRSO 100.0_JPRB */
 ldr x10,[x9,#2464]
 str x10,[x0,#3256] /* GRTH 1.0_JPRB */
 ldr x10,[x9,#2472]
 str x10,[x0,#3264] /* GRFCS 1.0_JPRB */
 ldr x10,[x9,#2480]
 str x10,[x0,#3080] /* GFRIC 4.2E-3_JPRB */
 ldr x10,[x9,#2488]
 str x10,[x0,#3088] /* GUDDD 0.25_JPRB */
 ldr x10,[x9,#2496]
 str x10,[x0,#3096] /* GSIGA 0.90_JPRB */
 ldr x10,[x9,#2504]
 str x10,[x0,#3104] /* GNHDSMOW 1800._JPRB */
 ldr x10,[x9,#2512]
 str x10,[x0,#3152] /* GSINHD 1800._JPRB */
 ldr x10,[x9,#2520]
 str x10,[x0,#3160] /* GSINHR 0._JPRB */
 ldr x10,[x9,#2528]
 str x10,[x0,#3112] /* GDEPTH 800._JPRB */
 ldr x10,[x9,#2536]
 str x10,[x0,#3120] /* GALTAU 1.9E-5_JPRB */
 ldr x10,[x9,#2544]
 str x10,[x0,#3128] /* GKEDDRE 6.98E-4_JPRB */
 ldr x10,[x9,#2552]
 str x10,[x0,#3136] /* GNHACC 0._JPRB */
 ldr x10,[x9,#2560]
 str x10,[x0,#3144] /* GTDCL 1._JPRB */
 ldr x10,[x9,#2568]
 str w10,[x0,#2864] /* LCVCONTAU .TRUE. */
 ldr x10,[x9,#2576]
 str w10,[x0,#2920] /* LCVIMPT .TRUE. */
 ldr x10,[x9,#2584]
 str w10,[x0,#2656] /* LADVLIM .TRUE. */
 ldr x10,[x9,#2592]
 str w10,[x0,#2724] /* LCVUVM .FALSE. */
 ldr x10,[x9,#2600]
 str x10,[x0,#2760] /* ADOE 1.0_JPRB */
 ldr x10,[x9,#2608]
 str x10,[x0,#2768] /* RFRAC_ENTR_N 1.E-5_JPRB */
 ldr x10,[x9,#2616]
 str x10,[x0,#2776] /* RFRAC_ENTR_X 1.1E-3_JPRB */
 ldr x10,[x9,#2624]
 str x10,[x0,#256] /* GCVTURB 5.0E-5_JPRB */
 ldr x10,[x9,#2632]
 str x10,[x0,#3400] /* RNEBCX 1._JPRB */
 ldr x10,[x9,#2640]
 str x10,[x0,#3216] /* GCVTSMO 0.5_JPRB */
 ldr x10,[x9,#2648]
 str x10,[x0,#3224] /* RKDX 300.E-06_JPRB */
 ldr x10,[x9,#2656]
 str w10,[x0,#3232] /* LCAPCIN .FALSE. */
 ldr x10,[x9,#2664]
 str w10,[x0,#3236] /* LCORSEDIM .FALSE. */
 ldr x10,[x9,#2672]
 str x10,[x0,#3208] /* GTOPDEPTH 4000._JPRB */
 ldr x10,[x9,#2680]
 str x10,[x0,#2240] /* NWEIGHT 1.0_JPRB */
 ldr x10,[x9,#2688]
 str x10,[x0,#2248] /* NCATAU 1000._JPRB */
 ldr x10,[x9,#2696]
 str x10,[x0,#2256] /* NCAPEMAX 0._JPRB */
 ldr x10,[x9,#2704]
 str x10,[x0,#2264] /* NCVGMAX 1.E-6_JPRB */
 ldr x10,[x9,#2712]
 str x10,[x0,#968] /* ADISE -0.5_JPRB */
 ldr x10,[x9,#2720]
 str x10,[x0,#960] /* ADISI 1.5_JPRB */
 ldr x10,[x9,#2728]
 str x10,[x0,#896] /* AECLS3 3.75_JPRB */
 ldr x10,[x9,#2736]
 str x10,[x0,#904] /* AECLS4 0.3_JPRB */
 ldr x10,[x9,#2744]
 str x10,[x0,#920] /* AKN 0.126_JPRB */
 ldr x10,[x9,#2752]
 str x10,[x0,#912] /* ALD 1.18_JPRB */
 ldr x10,[x9,#2760]
 str x10,[x0,#936] /* ALPHAE 2.7_JPRB */
 ldr x10,[x9,#2768]
 str x10,[x0,#928] /* ALPHAT 1.13_JPRB */
 ldr x10,[x9,#2776]
 str x10,[x0,#976] /* ECTMIN 1.E-6_JPRB */
 ldr x10,[x9,#2784]
 str x10,[x0,#984] /* ECTMAX 100._JPRB */
 ldr x10,[x9,#2792]
 str x10,[x0,#1264] /* UDECT 5._JPRB */
 ldr x10,[x9,#2800]
 str x10,[x0,#1288] /* USHEARM 1.E-04_JPRB */
 ldr x10,[x9,#2808]
 str x10,[x0,#1272] /* UPRETMIN 60000._JPRB */
 ldr x10,[x9,#2816]
 str x10,[x0,#1280] /* UPRETMAX 97500._JPRB */
 ldr x10,[x9,#2824]
 str x10,[x0,#1208] /* ARSCH 4._JPRB */
 ldr x10,[x9,#2832]
 str x10,[x0,#1216] /* ARSCQ 1.2_JPRB */
 ldr x10,[x9,#2840]
 str x10,[x0,#1184] /* ACBRPHIM 2.2_JPRB */
 ldr x10,[x9,#2848]
 str x10,[x0,#1192] /* ALMAVE 10._JPRB */
 ldr x10,[x9,#2856]
 str x10,[x0,#1200] /* ALMAVX 1000._JPRB */
 ldr x10,[x9,#2864]
 str x10,[x0,#1240] /* RICRET 0.195_JPRB */
 ldr x10,[x9,#2872]
 str x10,[x0,#2600] /* GCVHMIN 0.0_JPRB */
 ldr x10,[x9,#2880]
 str x10,[x0,#232] /* GCVOMGE 0.0_JPRB */
 ldr x10,[x9,#2888]
 str x10,[x0,#240] /* GCVOMGQ 0.0_JPRB */
 ldr x10,[x9,#2896]
 str x10,[x0,#248] /* GCVOMGS 0.0_JPRB */
 ldr x10,[x9,#2904]
 str x10,[x0,#264] /* GCVOMDPS 2000.0_JPRB */
 ldr x10,[x9,#2912]
 str x10,[x0,#272] /* GCVOMGSX 0.5_JPRB */
 ldr x10,[x9,#2920]
 str x10,[x0,#280] /* GCVRHMIN 0.5_JPRB */
 ldr x10,[x9,#2928]
 str x10,[x0,#288] /* GCVRHMAX 1.0_JPRB */
 ldr x10,[x9,#2936]
 str x10,[x0,#296] /* GCVOMCA -1.918_JPRB */
 ldr x10,[x9,#2944]
 str x10,[x0,#304] /* GCVOMCC 1.35_JPRB */
 ldr x10,[x9,#2952]
 str x10,[x0,#2584] /* RKFBTAU 0._JPRB */
 ldr x10,[x9,#2960]
 str x10,[x0,#2592] /* RKFBNBX 0.3_JPRB */
 ldr x10,[x9,#2968]
 str x10,[x0,#2320] /* AJBUMIN 0.005_JPRB */
 ldr x10,[x9,#2976]
 str x10,[x0,#2328] /* RCOFLM 0.085_JPRB */
 ldr x10,[x9,#2984]
 str x10,[x0,#2808] /* AJ1MEPS 0.99_JPRB */
 ldr x10,[x9,#2992]
 str x10,[x0,#2800] /* AJ1PEPS 10.0_JPRB */
 ldr x10,[x9,#3000]
 str w10,[x0,#2816] /* NAJITER 30 */
 ldr x10,[x9,#3008]
 str x10,[x0,#2304] /* AGRE1 0.16_JPRB */
 ldr x10,[x9,#3016]
 str x10,[x0,#2368] /* AGRE2 100._JPRB */
 ldr x10,[x9,#3024]
 str x10,[x0,#2376] /* AGREF 1._JPRB */
 ldr x10,[x9,#3032]
 str x10,[x0,#2312] /* AGRERICR 50._JPRB */
 ldr x10,[x9,#3040]
 str x10,[x0,#1544] /* NUPTKE 0.52_JPRB */
 ldr x10,[x9,#3048]
 str x10,[x0,#1552] /* TKEMULT 1.0_JPRB */
 ldr x10,[x9,#3056]
 str x10,[x0,#1560] /* C_EPSILON 0.871_JPRB */
 ldr x10,[x9,#3064]
 str x10,[x0,#1576] /* ETKE_CTHETA 1.0_JPRB */
 ldr x10,[x9,#3072]
 str x10,[x0,#1584] /* ETKE_RIFC_MAF 0.5_JPRB */
 ldr x10,[x9,#3080]
 str x10,[x0,#1592] /* ETKE_RIFC 0.186_JPRB */
 ldr x10,[x9,#3088]
 str x10,[x0,#1600] /* ETKE_R 0.367_JPRB */
 ldr x10,[x9,#3096]
 str x10,[x0,#1624] /* ETKE_LAM1 0.107_JPRB */
 ldr x10,[x9,#3104]
 str x10,[x0,#1632] /* ETKE_LAM2 0.00032_JPRB */
 ldr x10,[x9,#3112]
 str x10,[x0,#1640] /* ETKE_LAM3 0.0864_JPRB */
 ldr x10,[x9,#3120]
 str x10,[x0,#1648] /* ETKE_LAM4 0.1_JPRB */
 ldr x10,[x9,#3128]
 str x10,[x0,#1680] /* ENT_LAMBDA 5.87_JPRB */
 ldr x10,[x9,#3136]
 str x10,[x0,#1688] /* ETKE_CG01 1.0_JPRB */
 ldr x10,[x9,#3144]
 str x10,[x0,#1696] /* ETKE_CG02 1.0_JPRB */
 ldr x10,[x9,#3152]
 str x10,[x0,#1704] /* ETKE_CG03 1.0_JPRB */
 ldr x10,[x9,#3160]
 str x10,[x0,#1712] /* ETKE_BETA_EPS 0.02_JPRB */
 ldr x10,[x9,#3168]
 str x10,[x0,#1720] /* ETKE_GAMMA_EPS 3E-2_JPRB */
 ldr x10,[x9,#3176]
 str x10,[x0,#1728] /* ETKE_GAMD 2.0_JPRB */
 ldr x10,[x9,#3184]
 str x10,[x0,#1736] /* ETKE_TALPH 200.0_JPRB */
 ldr x10,[x9,#3192]
 str x10,[x0,#1744] /* ETKE_ALPH0 100.0_JPRB */
 ldr x10,[x9,#3200]
 str x10,[x0,#1752] /* ETKE_ENTRX 1E-3_JPRB */
 ldr x10,[x9,#3208]
 str x10,[x0,#1760] /* ETKE_ENTRN 1E-4_JPRB */
 ldr x10,[x9,#3216]
 str x10,[x0,#1768] /* ETKE_KLM 1.0_JPRB */
 ldr x10,[x9,#3224]
 str x10,[x0,#1776] /* ETKE_TAULM 1.0_JPRB */
 ldr x10,[x9,#3232]
 str x10,[x0,#1784] /* ETKE_MIN 1.0E-08_JPRB */
 ldr x10,[x9,#3240]
 str x10,[x0,#1568] /* C3TKEFREE 1.184_JPRB */
 ldr x10,[x9,#3248]
 str x10,[x0,#2384] /* ALFX 10.E-02_JPRB */
 ldr x10,[x9,#3256]
 str x10,[x0,#2392] /* ALFX_LR 0.04_JPRB */
 ldr x10,[x9,#3264]
 str x10,[x0,#2400] /* ALFX_HR 0.15_JPRB */
 ldr x10,[x9,#3272]
 str x10,[x0,#2608] /* GCVRESN 7.44E-6_JPRB */
 ldr x10,[x9,#3280]
 str x10,[x0,#2616] /* GCVRESX 6.00E-5_JPRB */
 ldr x10,[x9,#3288]
 str x10,[x0,#2624] /* GMIRH 0.98_JPRB */
 ldr x10,[x9,#3296]
 str x10,[x0,#3336] /* GCVGAW 0.7_JPRB */
 ldr x10,[x9,#3304]
 str x10,[x0,#3344] /* GCVGAX 0._JPRB */
 ldr x10,[x9,#3312]
 str x10,[x0,#2408] /* TCTC 5.0E-04_JPRB */
 ldr x10,[x9,#3320]
 str x10,[x0,#2416] /* TVFC 1._JPRB */
 ldr x10,[x9,#3328]
 str x10,[x0,#2424] /* GAMAP1 1.5_JPRB */
 ldr x10,[x9,#3336]
 str x10,[x0,#2432] /* RKDN 30.E-06_JPRB */
 ldr x10,[x9,#3344]
 str x10,[x0,#2440] /* VVN -2.0_JPRB */
 ldr x10,[x9,#3352]
 str x10,[x0,#2448] /* VVX -38.0_JPRB */
 ldr x10,[x9,#3360]
 str x10,[x0,#2456] /* FENTRT 2.5_JPRB */
 ldr x10,[x9,#3368]
 str x10,[x0,#2464] /* FQLIC 1.0_JPRB */
 ldr x10,[x9,#3376]
 str x10,[x0,#2472] /* FNEBC 7.0_JPRB */
 ldr x10,[x9,#3384]
 str x10,[x0,#2480] /* FEVAPC 4.0_JPRB */
 ldr x10,[x9,#3392]
 str x10,[x0,#2632] /* RLMLH1 0.4_JPRB */
 ldr x10,[x9,#3400]
 str x10,[x0,#2640] /* RPRTH 0.0_JPRB */
 ldr x10,[x9,#3408]
 str x10,[x0,#2648] /* RSMOOTHMELT 0.6 */
 ldr x10,[x9,#3416]
 str x10,[x0,#3424] /* REFLKUO 17558._JPRB */
 ldr x10,[x9,#3424]
 str x10,[x0,#3432] /* REFLCAPE 89558._JPRB */
 ldr x10,[x9,#3432]
 str x10,[x0,#3408] /* REFLRHC 150000._JPRB */
 ret
.section .rodata
.p2align 3
.Latm_literal_values:
 .quad 0x4012000000000000
 .quad 0x4014000000000000
 .quad 0x4008000000000000
 .quad 0x3fe999999999999a
 .quad 0x3fd172474538ef35
 .quad 0xbfdb212d77318fc5
 .quad 0x3fd7020c49ba5e35
 .quad 0x4072c00000000000
 .quad 0x3fa999999999999a
 .quad 0x40a7700000000000
 .quad 0x4014000000000000
 .quad 0x4014000000000000
 .quad 0x4014000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fc999999999999a
 .quad 0x3fdd16872b020c4a
 .quad 0x3ff0000000000000
 .quad 0x41524f8000000000
 .quad 0x40d7700000000000
 .quad 0x3fe0f5c28f5c28f6
 .quad 0x3f11904b3c3e74b0
 .quad 0x3f11904b3c3e74b0
 .quad 0x0000000000000000
 .quad 0x3fe999999999999a
 .quad 0x3f0797cc39ffd60f
 .quad 0x3fc999999999999a
 .quad 0x0000000000000000
 .quad 0x3f24f8b588e368f1
 .quad 0x3efa36e2eb1c432d
 .quad 0x3fe0000000000000
 .quad 0x0000000000000000
 .quad 0x3fd0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3fd0000000000000
 .quad 0x4010000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fe3333333333333
 .quad 0x4000000000000000
 .quad 0x3ff0000000000000
 .quad 0x4018000000000000
 .quad 0x0000000000000000
 .quad 0x3f6cac083126e979
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x4008000000000000
 .quad 0x4000000000000000
 .quad 0x3ffccccccccccccd
 .quad 0xbfe3333333333333
 .quad 0x3ff199999999999a
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x4099000000000000
 .quad 0x3ff0000000000000
 .quad 0x3f1a36e2eb1c432d
 .quad 0x40d9640000000000
 .quad 0x3fe6666666666666
 .quad 0x3ff0000000000000
 .quad 0x3fd0000000000000
 .quad 0x0000000000000000
 .quad 0x3f014d2f5dbb9cfa
 .quad 0x3f014d2f5dbb9cfa
 .quad 0x40d3880000000000
 .quad 0x40c3880000000000
 .quad 0x40d3880000000000
 .quad 0x3fd3333333333333
 .quad 0x3fdccccccccccccd
 .quad 0x3ff0000000000000
 .quad 0x3f8999999999999a
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x409b580000000000
 .quad 0x4060400000000000
 .quad 0x4060400000000000
 .quad 0x3fe0000000000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fe0000000000000
 .quad 0x400c000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x4054000000000000
 .quad 0x4022000000000000
 .quad 0x4014000000000000
 .quad 0xc026000000000000
 .quad 0x0000000000000000
 .quad 0x40c5180000000000
 .quad 0xc034000000000000
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x40a7700000000000
 .quad 0x3fe0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3f1a36e2eb1c432d
 .quad 0x3f4a36e2eb1c432d
 .quad 0x3ec4f8b588e368f1
 .quad 0x3f14f8b588e368f1
 .quad 0x3fe999999999999a
 .quad 0x3fe999999999999a
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fed70a3d70a3d71
 .quad 0x3fe7ae147ae147ae
 .quad 0x403099999999999a
 .quad 0x4024333333333333
 .quad 0x3fb47ae147ae147b
 .quad 0x3f4a36e2eb1c432d
 .quad 0x40c86a0000000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fa1eb851eb851ec
 .quad 0x3ff0000000000000
 .quad 0x3fe0000000000000
 .quad 0x4010000000000000
 .quad 0x3fc0000000000000
 .quad 0x3f95810624dd2f1b
 .quad 0x3fd999999999999a
 .quad 0x3f23a92a30553261
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x408f400000000000
 .quad 0x3fe0000000000000
 .quad 0x3fe999999999999a
 .quad 0x3f1e2584f4c6e6da
 .quad 0x401a000000000000
 .quad 0x3ff0000000000000
 .quad 0x40a7700000000000
 .quad 0x407f400000000000
 .quad 0x3fb999999999999a
 .quad 0x401c000000000000
 .quad 0xbf12599ed7c6fbd2
 .quad 0x40f1170000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0xbff0000000000000
 .quad 0x4034000000000000
 .quad 0x0000000000000000
 .quad 0x3fe0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3f50624dd2f1a9fc
 .quad 0x3ff0000000000000
 .quad 0x3f50624dd2f1a9fc
 .quad 0x3f9999999999999a
 .quad 0x415e848000000000
 .quad 0x413e848000000000
 .quad 0x3f2a36e2eb1c432d
 .quad 0x0000000000000000
 .quad 0x3eff75104d551d69
 .quad 0x3e8ad7f29abcaf48
 .quad 0x3f2a36e2eb1c432d
 .quad 0x3eff75104d551d69
 .quad 0x3e8ad7f29abcaf48
 .quad 0xc054000000000000
 .quad 0x403e000000000000
 .quad 0x3fe0000000000000
 .quad 0x3f9eb851eb851eb8
 .quad 0x3ff0000000000000
 .quad 0x3fc999999999999a
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x3fe0000000000000
 .quad 0x3fed1eb851eb851f
 .quad 0x3fd999999999999a
 .quad 0x3ff6666666666666
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x4014000000000000
 .quad 0x3fe3333333333333
 .quad 0x3fd3333333333333
 .quad 0x3fd3333333333333
 .quad 0x408c200000000000
 .quad 0x40c3880000000000
 .quad 0x4072c00000000000
 .quad 0x4010000000000000
 .quad 0x410e460000000000
 .quad 0x40ce460000000000
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x402acccccccccccd
 .quad 0x3fb126e978d4fdf4
 .quad 0x3fc999999999999a
 .quad 0x3ff0000000000000
 .quad 0x0000000000000002
 .quad 0x0000000000000003
 .quad 0x3fe0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3f53a92a30553261
 .quad 0x3f43a92a30553261
 .quad 0x3fee666666666666
 .quad 0x4039000000000000
 .quad 0x41cdcd6500000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x408c200000000000
 .quad 0x40a7700000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ee4f8b588e368f1
 .quad 0x4000000000000000
 .quad 0x40c3880000000000
 .quad 0x40f86a0000000000
 .quad 0x3fe0000000000000
 .quad 0x0000000000000000
 .quad 0x3f1a36e2eb1c432d
 .quad 0x3ff0000000000000
 .quad 0x3fd51eb860000000
 .quad 0x3f1a36e2eb1c432d
 .quad 0x3fa6848beb5b2d4d
 .quad 0x3fe8000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3fe0000000000000
 .quad 0x4000000000000000
 .quad 0x3feccccccccccccd
 .quad 0x3e45798ee2308c3a
 .quad 0x3f0a36e2eb1c432d
 .quad 0x3f1a36e2eb1c432d
 .quad 0x3f689374bc6a7efa
 .quad 0xbff0000000000000
 .quad 0x4008000000000000
 .quad 0x408f400000000000
 .quad 0x4069000000000000
 .quad 0xbff0000000000000
 .quad 0xbff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3fd999999999999a
 .quad 0x40b7700000000000
 .quad 0x40dca70000000000
 .quad 0x40dd4c0000000000
 .quad 0x4000000000000000
 .quad 0x3fc3333333333333
 .quad 0x40e86a0000000000
 .quad 0x3fe0000000000000
 .quad 0x4059000000000000
 .quad 0x3f947ae147ae147b
 .quad 0x409f400000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3fb999999999999a
 .quad 0x408c200000000000
 .quad 0x3fcc28f5c28f5c29
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x3f1f75104d551d69
 .quad 0x3f43a92a30553261
 .quad 0x0000000000000000
 .quad 0xbff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x40c3880000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000001
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x3f50624dd2f1a9fc
 .quad 0x3ff0000000000000
 .quad 0x3f554c985f06f694
 .quad 0x3f86872b020c49ba
 .quad 0x3f9eb851eb851eb8
 .quad 0x3f43a92a30553261
 .quad 0x3f613404ea4a8c15
 .quad 0x4000000000000000
 .quad 0x3f847ae147ae147b
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0xc014000000000000
 .quad 0x40dd4c0000000000
 .quad 0x40c3880000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0xc069000000000000
 .quad 0x4069000000000000
 .quad 0xbfb999999999999a
 .quad 0x3fc999999999999a
 .quad 0x3ff0000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x4059000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3f713404ea4a8c15
 .quad 0x3fd0000000000000
 .quad 0x3feccccccccccccd
 .quad 0x409c200000000000
 .quad 0x409c200000000000
 .quad 0x0000000000000000
 .quad 0x4089000000000000
 .quad 0x3ef3ec460ed80a18
 .quad 0x3f46df3f961804da
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x0000000000000001
 .quad 0x0000000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ee4f8b588e368f1
 .quad 0x3f5205bc01a36e2f
 .quad 0x3f0a36e2eb1c432d
 .quad 0x3ff0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3f33a92a30553261
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x40af400000000000
 .quad 0x3ff0000000000000
 .quad 0x408f400000000000
 .quad 0x0000000000000000
 .quad 0x3eb0c6f7a0b5ed8d
 .quad 0xbfe0000000000000
 .quad 0x3ff8000000000000
 .quad 0x400e000000000000
 .quad 0x3fd3333333333333
 .quad 0x3fc020c49ba5e354
 .quad 0x3ff2e147ae147ae1
 .quad 0x400599999999999a
 .quad 0x3ff2147ae147ae14
 .quad 0x3eb0c6f7a0b5ed8d
 .quad 0x4059000000000000
 .quad 0x4014000000000000
 .quad 0x3f1a36e2eb1c432d
 .quad 0x40ed4c0000000000
 .quad 0x40f7cdc000000000
 .quad 0x4010000000000000
 .quad 0x3ff3333333333333
 .quad 0x400199999999999a
 .quad 0x4024000000000000
 .quad 0x408f400000000000
 .quad 0x3fc8f5c28f5c28f6
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x0000000000000000
 .quad 0x409f400000000000
 .quad 0x3fe0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3ff0000000000000
 .quad 0xbffeb020c49ba5e3
 .quad 0x3ff599999999999a
 .quad 0x0000000000000000
 .quad 0x3fd3333333333333
 .quad 0x3f747ae147ae147b
 .quad 0x3fb5c28f5c28f5c3
 .quad 0x3fefae147ae147ae
 .quad 0x4024000000000000
 .quad 0x000000000000001e
 .quad 0x3fc47ae147ae147b
 .quad 0x4059000000000000
 .quad 0x3ff0000000000000
 .quad 0x4049000000000000
 .quad 0x3fe0a3d70a3d70a4
 .quad 0x3ff0000000000000
 .quad 0x3febdf3b645a1cac
 .quad 0x3ff0000000000000
 .quad 0x3fe0000000000000
 .quad 0x3fc7ced916872b02
 .quad 0x3fd77ced916872b0
 .quad 0x3fbb645a1cac0831
 .quad 0x3f34f8b588e368f1
 .quad 0x3fb61e4f765fd8ae
 .quad 0x3fb999999999999a
 .quad 0x40177ae147ae147b
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3f947ae147ae147b
 .quad 0x3f9eb851eb851eb8
 .quad 0x4000000000000000
 .quad 0x4069000000000000
 .quad 0x4059000000000000
 .quad 0x3f50624dd2f1a9fc
 .quad 0x3f1a36e2eb1c432d
 .quad 0x3ff0000000000000
 .quad 0x3ff0000000000000
 .quad 0x3e45798ee2308c3a
 .quad 0x3ff2f1a9fbe76c8b
 .quad 0x3fb999999999999a
 .quad 0x3fa47ae147ae147b
 .quad 0x3fc3333333333333
 .quad 0x3edf34a3a0ae8bc4
 .quad 0x3f0f75104d551d69
 .quad 0x3fef5c28f5c28f5c
 .quad 0x3fe6666666666666
 .quad 0x0000000000000000
 .quad 0x3f40624dd2f1a9fc
 .quad 0x3ff0000000000000
 .quad 0x3ff8000000000000
 .quad 0x3eff75104d551d69
 .quad 0xc000000000000000
 .quad 0xc043000000000000
 .quad 0x4004000000000000
 .quad 0x3ff0000000000000
 .quad 0x401c000000000000
 .quad 0x4010000000000000
 .quad 0x3fd999999999999a
 .quad 0x0000000000000000
 .quad 0x3fe3333340000000
 .quad 0x40d1258000000000
 .quad 0x40f5dd6000000000
 .quad 0x41024f8000000000
.text
