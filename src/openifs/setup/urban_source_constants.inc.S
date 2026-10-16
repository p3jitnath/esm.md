/* Source literals and correctly rounded literal-only ATAN(1). */
.equ C_one,0
.quad 0x3ff0000000000000 /* one */
.equ C_two,8
.quad 0x4000000000000000 /* two */
.equ C_three,16
.quad 0x4008000000000000 /* three */
.equ C_four,24
.quad 0x4010000000000000 /* four */
.equ C_half,32
.quad 0x3fe0000000000000 /* half */
.equ C_minus_half,40
.quad 0xbfe0000000000000 /* minus_half */
.equ C_tenth,48
.quad 0x3fb999999999999a /* tenth */
.equ C_onehalf,56
.quad 0x3ff8000000000000 /* onehalf */
.equ C_onequarter,64
.quad 0x3ff4000000000000 /* onequarter */
.equ C_thousandth,72
.quad 0x3f50624dd2f1a9fc /* thousandth */
.equ C_tiny,80
.quad 0x3e7ad7f29abcaf48 /* tiny */
.equ C_disp,88
.quad 0x3ff6666666666666 /* disp */
.equ C_modw,96
.quad 0x4024000000000000 /* modw */
.equ C_roofheight,104
.quad 0x3ff199999999999a /* roofheight */
.equ C_heat_level,112
.quad 0x3ee4f8b588e368f1 /* heat_level */
.equ C_air_cp,120
.quad 0x408f680000000000 /* air_cp */
.equ C_atan_one,128
.quad 0x3fe921fb54442d18 /* atan_one */
.equ C_source_RCDG,136
.quad 0x3ff3333333333333 /* source_RCDG */
.equ C_source_RCDA,144
.quad 0x4011b851eb851eb8 /* source_RCDA */
.equ C_source_RCHIS,152
.quad 0x3fd3333333333333 /* source_RCHIS */
.equ C_source_RSBCONS,160
.quad 0x41c0e5dde0000000 /* source_RSBCONS */
.equ C_source_RGACC,168
.quad 0x40239eb851eb851f /* source_RGACC */
.equ C_source_RVKSQ,176
.quad 0x3fc47ae147ae147b /* source_RVKSQ */
.equ C_source_REXPDR,184
.quad 0x3fc3333333333333 /* source_REXPDR */
.equ C_source_RBUIZ0M,192
.quad 0x3f747ae147ae147b /* source_RBUIZ0M */
.equ C_source_RWALTHK,200
.quad 0x3fc3333333333333 /* source_RWALTHK */
.equ C_source_RROOTHK,208
.quad 0x3fc3333333333333 /* source_RROOTHK */
.equ C_source_RROATHK,216
.quad 0x3fc3333333333333 /* source_RROATHK */
.equ C_source_RWALALB,224
.quad 0x3fe3333333333333 /* source_RWALALB */
.equ C_source_RROOALB,232
.quad 0x3fc47ae147ae147b /* source_RROOALB */
.equ C_source_RROAALB,240
.quad 0x3fa999999999999a /* source_RROAALB */
.equ C_source_RWALEMIS,248
.quad 0x3feeb851eb851eb8 /* source_RWALEMIS */
.equ C_source_RROOEMIS,256
.quad 0x3feeb851eb851eb8 /* source_RROOEMIS */
.equ C_source_RROAEMIS,264
.quad 0x3fefae147ae147ae /* source_RROAEMIS */
.equ C_source_RWALVHC,272
.quad 0x4146e36000000000 /* source_RWALVHC */
.equ C_source_RROOVHC,280
.quad 0x413e848000000000 /* source_RROOVHC */
.equ C_source_RROAVHC,288
.quad 0x4146e36000000000 /* source_RROAVHC */
.equ C_source_RWALTC,296
.quad 0x4034000000000000 /* source_RWALTC */
.equ C_source_RROOTC,304
.quad 0x4024000000000000 /* source_RROOTC */
.equ C_source_RROATC,312
.quad 0x4034000000000000 /* source_RROATC */
.equ C_source_RHGT,320
.quad 0x4020000000000000 /* source_RHGT */
.equ C_source_RHWR,328
.quad 0x3fe0000000000000 /* source_RHWR */
.equ C_source_RWRR,336
.quad 0x3fe0000000000000 /* source_RWRR */
.equ C_source_RSOIEMIS,344
.quad 0x3fee666666666666 /* source_RSOIEMIS */
.equ C_source_RSOITMP,352
.quad 0x4071800000000000 /* source_RSOITMP */
.equ C_source_RSOITC,360
.quad 0x3fcc28f5c28f5c29 /* source_RSOITC */
.equ C_source_RSATSH,368
.quad 0x0000000000000000 /* source_RSATSH */
.equ C_source_RMODZ,376
.quad 0x4024000000000000 /* source_RMODZ */
.equ C_source_RAIRRHO,384
.quad 0x3ff399999999999a /* source_RAIRRHO */
.equ C_source_RURBALP,392
.quad 0x3fe87ae147ae147b /* source_RURBALP */
.equ C_source_RURBCON,400
.quad 0x3d6777cd49825ea5 /* source_RURBCON */
.equ C_source_RURBLAM,408
.quad 0x404199999999999a /* source_RURBLAM */
.equ C_source_RURBSAT,416
.quad 0x3fc3333333333333 /* source_RURBSAT */
.equ C_source_RURBSRES,424
.quad 0x3f50624dd2f1a9fc /* source_RURBSRES */
