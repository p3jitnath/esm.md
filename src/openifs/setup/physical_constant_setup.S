/* Owned selected physical constants, revision 1.
 * Contract: skills/md2asm/references/openifs/setup/physical_constant_setup.md.
 * x0 writable record, x1 capacity. The record remains caller-owned.
 * Source equations are emitted directly, without original module storage. */
.arch armv8.2-a
.equ O_RPI,0
.equ O_RCLUM,8
.equ O_RHPLA,16
.equ O_RKBOL,24
.equ O_RNAVO,32
.equ O_RDAY,40
.equ O_RDAYI,48
.equ O_RHOUR,56
.equ O_REA,64
.equ O_REPSM,72
.equ O_RSIYEA,80
.equ O_RSIDAY,88
.equ O_ROMEGA,96
.equ O_RA,104
.equ O_RG,112
.equ O_R1SA,120
.equ O_DEG2RAD,128
.equ O_RSIGMA,136
.equ O_RI0,144
.equ O_R,152
.equ O_RMD,160
.equ O_RMV,168
.equ O_RMO3,176
.equ O_RD,184
.equ O_RV,192
.equ O_RCPD,200
.equ O_RCPV,208
.equ O_RCVD,216
.equ O_RCVV,224
.equ O_RKAPPA,232
.equ O_RETV,240
.equ O_RMCO2,248
.equ O_RMCH4,256
.equ O_RMN2O,264
.equ O_RMCO,272
.equ O_RMHCHO,280
.equ O_RMNO2,288
.equ O_RMSO2,296
.equ O_RMSO4,304
.equ O_RMCFC11,312
.equ O_RMCFC12,320
.equ O_RMHCFC22,328
.equ O_RMCCL4,336
.equ O_RCW,344
.equ O_RCS,352
.equ O_RATM,360
.equ O_RTT,368
.equ O_RLVTT,376
.equ O_RLSTT,384
.equ O_RLVZER,392
.equ O_RLSZER,400
.equ O_RLMLT,408
.equ O_RDT,416
.equ O_RESTT,424
.equ O_RGAMW,432
.equ O_RBETW,440
.equ O_RALPW,448
.equ O_RGAMS,456
.equ O_RBETS,464
.equ O_RALPS,472
.equ O_RALPD,480
.equ O_RBETD,488
.equ O_RGAMD,496
.equ O_RSNAN,504
.macro K reg,name
 adrp x9,.Lc_\name
 ldr \reg,[x9,:lo12:.Lc_\name]
.endm
.macro V reg,name
 ldr \reg,[x19,#O_\name]
.endm
.macro S reg,name
 str \reg,[x19,#O_\name]
.endm
.text
.p2align 4
.global md2asm_initialize_physical_constants
.type md2asm_initialize_physical_constants,%function
md2asm_initialize_physical_constants:
 cbz x0,.Lconstants_reject
 tst x0,#7
 b.ne .Lconstants_reject
 cmp x1,#520
 b.lo .Lconstants_reject
 adds x9,x0,#520
 b.cs .Lconstants_reject
 mrs x9,fpcr
 cbnz x9,.Lconstants_reject
 sub sp,sp,#32
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x0
 K d0,RPI
 S d0,RPI
 K d0,RCLUM
 S d0,RCLUM
 K d0,RHPLA
 S d0,RHPLA
 K d0,RKBOL
 S d0,RKBOL
 K d0,RNAVO
 S d0,RNAVO
 K d0,RDAYI
 S d0,RDAYI
 K d0,RDAY
 S d0,RDAY
 K d0,RHOUR
 S d0,RHOUR
 K d0,REA
 S d0,REA
 K d0,REPSM
 S d0,REPSM
 /* Astronomical time scales, with source left-to-right rounding. */
 K d0,daysyear
 V d1,RDAY
 fmul d0,d0,d1
 K d2,two
 fmul d0,d0,d2
 V d3,RPI
 fmul d0,d0,d3
 K d2,yearangle
 fdiv d0,d0,d2
 S d0,RSIYEA
 fdiv d2,d1,d0
 K d3,one
 fadd d2,d3,d2
 fdiv d0,d1,d2
 S d0,RSIDAY
 V d1,RPI
 K d2,two
 fmul d1,d2,d1
 fdiv d0,d1,d0
 S d0,ROMEGA
 K d0,RA
 S d0,RA
 K d0,RG
 S d0,RG
 K d0,one
 V d1,RA
 fdiv d0,d0,d1
 S d0,R1SA
 V d0,RPI
 K d1,deg
 fdiv d0,d0,d1
 S d0,DEG2RAD
 /* Stefan-Boltzmann constant. Integer powers have explicit products. */
 V d0,RPI
 fmul d1,d0,d0
 fmul d1,d1,d1
 fmul d1,d1,d0
 K d2,two
 fmul d1,d2,d1
 V d2,RKBOL
 V d3,RHPLA
 fdiv d3,d2,d3
 fmul d4,d3,d3
 fmul d3,d4,d3
 fmul d1,d1,d3
 fmul d1,d1,d2
 V d2,RCLUM
 fmul d2,d2,d2
 K d3,fifteen
 fmul d2,d3,d2
 fdiv d0,d1,d2
 S d0,RSIGMA
 K d0,RI0
 S d0,RI0
 V d0,RNAVO
 V d1,RKBOL
 fmul d0,d0,d1
 S d0,R
 K d0,RMD
 S d0,RMD
 K d0,RMV
 S d0,RMV
 K d0,RMO3
 S d0,RMO3
 K d0,thousand
 V d1,R
 fmul d0,d0,d1
 V d1,RMD
 fdiv d1,d0,d1
 S d1,RD
 V d2,RMV
 fdiv d0,d0,d2
 S d0,RV
 K d2,threehalf
 fmul d2,d2,d1
 S d2,RCPD
 fsub d3,d2,d1
 S d3,RCVD
 K d3,four
 fmul d3,d3,d0
 S d3,RCPV
 fsub d4,d3,d0
 S d4,RCVV
 fdiv d4,d1,d2
 S d4,RKAPPA
 fdiv d0,d0,d1
 K d1,one
 fsub d0,d0,d1
 S d0,RETV
 K d0,RMCO2
 S d0,RMCO2
 K d0,RMCH4
 S d0,RMCH4
 K d0,RMN2O
 S d0,RMN2O
 K d0,RMCO
 S d0,RMCO
 K d0,RMHCHO
 S d0,RMHCHO
 K d0,RMNO2
 S d0,RMNO2
 K d0,RMSO2
 S d0,RMSO2
 K d0,RMSO4
 S d0,RMSO4
 K d0,RMCFC11
 S d0,RMCFC11
 K d0,RMCFC12
 S d0,RMCFC12
 K d0,RMHCFC22
 S d0,RMHCFC22
 K d0,RMCCL4
 S d0,RMCCL4
 K d0,RCW
 S d0,RCW
 K d0,RCS
 S d0,RCS
 K d0,RTT
 S d0,RTT
 K d0,RDT
 S d0,RDT
 K d0,RLVTT
 S d0,RLVTT
 K d0,RLSTT
 S d0,RLSTT
 V d0,RCW
 V d1,RCPV
 fsub d0,d0,d1
 V d2,RTT
 fmul d0,d2,d0
 V d3,RLVTT
 fadd d0,d3,d0
 S d0,RLVZER
 V d0,RCS
 fsub d0,d0,d1
 fmul d0,d2,d0
 V d4,RLSTT
 fadd d0,d4,d0
 S d0,RLSZER
 fsub d0,d4,d3
 S d0,RLMLT
 K d0,RATM
 S d0,RATM
 K d0,RESTT
 S d0,RESTT
 V d0,RCW
 V d1,RCPV
 fsub d0,d0,d1
 V d2,RV
 fdiv d0,d0,d2
 S d0,RGAMW
 V d1,RLVTT
 fdiv d1,d1,d2
 V d2,RTT
 fmul d0,d0,d2
 fadd d0,d1,d0
 S d0,RBETW
 V d0,RESTT
 bl md2asm_log_positive_normal
 S d0,RALPW
 V d1,RBETW
 V d2,RTT
 fdiv d1,d1,d2
 fadd d0,d0,d1
 S d0,RALPW
 V d0,RTT
 bl md2asm_log_positive_normal
 V d1,RGAMW
 fmul d0,d1,d0
 V d1,RALPW
 fadd d0,d1,d0
 S d0,RALPW
 V d0,RCS
 V d1,RCPV
 fsub d0,d0,d1
 V d2,RV
 fdiv d0,d0,d2
 S d0,RGAMS
 V d1,RLSTT
 fdiv d1,d1,d2
 V d2,RTT
 fmul d0,d0,d2
 fadd d0,d1,d0
 S d0,RBETS
 V d0,RESTT
 bl md2asm_log_positive_normal
 S d0,RALPS
 V d1,RBETS
 V d2,RTT
 fdiv d1,d1,d2
 fadd d0,d0,d1
 S d0,RALPS
 V d0,RTT
 bl md2asm_log_positive_normal
 V d1,RGAMS
 fmul d0,d1,d0
 V d1,RALPS
 fadd d0,d1,d0
 S d0,RALPS
 V d0,RGAMS
 V d1,RGAMW
 fsub d0,d0,d1
 S d0,RGAMD
 V d0,RBETS
 V d1,RBETW
 fsub d0,d0,d1
 S d0,RBETD
 V d0,RALPS
 V d1,RALPW
 fsub d0,d0,d1
 S d0,RALPD
 mov x9,#0x7ff4
 lsl x9,x9,#48
 str x9,[x19,#O_RSNAN]
 mov w9,#1
 str w9,[x19,#512]
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#32
 ret
.Lconstants_reject:
 mov w0,#2
 ret
.size md2asm_initialize_physical_constants,.-md2asm_initialize_physical_constants
.section .rodata
.p2align 3
.Lc_RPI: .quad 0x400921fb54442d18
.Lc_RCLUM: .quad 0x41b1de784a000000
.Lc_RHPLA: .quad 0x390b860d52d96191
.Lc_RKBOL: .quad 0x3b30b0edf6c91c1b
.Lc_RNAVO: .quad 0x44dfe18461be0ec2
.Lc_RDAY: .quad 0x40f5180000000000
.Lc_RDAYI: .quad 0x40f5180000000000
.Lc_RHOUR: .quad 0x40ac200000000000
.Lc_REA: .quad 0x42416a5d2bd80000
.Lc_REPSM: .quad 0x3fda2e9468017119
.Lc_RA: .quad 0x41584de740000000
.Lc_RG: .quad 0x40239d013a92a305
.Lc_RI0: .quad 0x4095580000000000
.Lc_RMD: .quad 0x403cf6e2eb1c432d
.Lc_RMV: .quad 0x403203eab367a0f9
.Lc_RMO3: .quad 0x4047ff41f212d773
.Lc_RMCO2: .quad 0x404601374bc6a7f0
.Lc_RMCH4: .quad 0x40300a3d70a3d70a
.Lc_RMN2O: .quad 0x404601a9fbe76c8b
.Lc_RMCO: .quad 0x403c028f5c28f5c3
.Lc_RMHCHO: .quad 0x403e07ae147ae148
.Lc_RMNO2: .quad 0x40470147ae147ae1
.Lc_RMSO2: .quad 0x40500395810624dd
.Lc_RMSO4: .quad 0x40580353f7ced917
.Lc_RMCFC11: .quad 0x40612bcb923a29c7
.Lc_RMCFC12: .quad 0x405e3a7ef9db22d1
.Lc_RMHCFC22: .quad 0x40559e04189374bc
.Lc_RMCCL4: .quad 0x40633a5604189375
.Lc_RCW: .quad 0x40b07a0000000000
.Lc_RCS: .quad 0x40a0740000000000
.Lc_RTT: .quad 0x4071128f5c28f5c3
.Lc_RDT: .quad 0x4027a3d70a3d70a4
.Lc_RLVTT: .quad 0x4143146000000000
.Lc_RLSTT: .quad 0x4145a02200000000
.Lc_RATM: .quad 0x40f86a0000000000
.Lc_RESTT: .quad 0x4083191eb851eb85
.Lc_one: .quad 0x3ff0000000000000
.Lc_two: .quad 0x4000000000000000
.Lc_four: .quad 0x4010000000000000
.Lc_threehalf: .quad 0x400c000000000000
.Lc_thousand: .quad 0x408f400000000000
.Lc_daysyear: .quad 0x4076d40000000000
.Lc_yearangle: .quad 0x401921deacc92147
.Lc_deg: .quad 0x4066800000000000
.Lc_fifteen: .quad 0x402e000000000000
.section .note.GNU-stack,"",%progbits
