/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2fort-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/physical_constant_setup.S
 */
// Original contract: skills/md2fort/references/openifs/setup/physical_constant_setup.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
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
 adrp x9,.Lc_RPI
 ldr d0,[x9,:lo12:.Lc_RPI]
 str d0,[x19,#O_RPI]
 adrp x9,.Lc_RCLUM
 ldr d0,[x9,:lo12:.Lc_RCLUM]
 str d0,[x19,#O_RCLUM]
 adrp x9,.Lc_RHPLA
 ldr d0,[x9,:lo12:.Lc_RHPLA]
 str d0,[x19,#O_RHPLA]
 adrp x9,.Lc_RKBOL
 ldr d0,[x9,:lo12:.Lc_RKBOL]
 str d0,[x19,#O_RKBOL]
 adrp x9,.Lc_RNAVO
 ldr d0,[x9,:lo12:.Lc_RNAVO]
 str d0,[x19,#O_RNAVO]
 adrp x9,.Lc_RDAYI
 ldr d0,[x9,:lo12:.Lc_RDAYI]
 str d0,[x19,#O_RDAYI]
 adrp x9,.Lc_RDAY
 ldr d0,[x9,:lo12:.Lc_RDAY]
 str d0,[x19,#O_RDAY]
 adrp x9,.Lc_RHOUR
 ldr d0,[x9,:lo12:.Lc_RHOUR]
 str d0,[x19,#O_RHOUR]
 adrp x9,.Lc_REA
 ldr d0,[x9,:lo12:.Lc_REA]
 str d0,[x19,#O_REA]
 adrp x9,.Lc_REPSM
 ldr d0,[x9,:lo12:.Lc_REPSM]
 str d0,[x19,#O_REPSM]
 adrp x9,.Lc_daysyear
 ldr d0,[x9,:lo12:.Lc_daysyear]
 ldr d1,[x19,#O_RDAY]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 adrp x9,.Lc_two
 ldr d2,[x9,:lo12:.Lc_two]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 ldr d3,[x19,#O_RPI]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d3
 adrp x9,.Lc_yearangle
 ldr d2,[x9,:lo12:.Lc_yearangle]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 str d0,[x19,#O_RSIYEA]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d2,destination,d1,real,x16,0,d0
 adrp x9,.Lc_one
 ldr d3,[x9,:lo12:.Lc_one]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d2,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d2
 str d0,[x19,#O_RSIDAY]
 ldr d1,[x19,#O_RPI]
 adrp x9,.Lc_two
 ldr d2,[x9,:lo12:.Lc_two]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d2,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d0
 str d0,[x19,#O_ROMEGA]
 adrp x9,.Lc_RA
 ldr d0,[x9,:lo12:.Lc_RA]
 str d0,[x19,#O_RA]
 adrp x9,.Lc_RG
 ldr d0,[x9,:lo12:.Lc_RG]
 str d0,[x19,#O_RG]
 adrp x9,.Lc_one
 ldr d0,[x9,:lo12:.Lc_one]
 ldr d1,[x19,#O_RA]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_R1SA]
 ldr d0,[x19,#O_RPI]
 adrp x9,.Lc_deg
 ldr d1,[x9,:lo12:.Lc_deg]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_DEG2RAD]
 ldr d0,[x19,#O_RPI]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d0,real,x16,0,d0
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d0
 adrp x9,.Lc_two
 ldr d2,[x9,:lo12:.Lc_two]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d2,real,x16,0,d1
 ldr d2,[x19,#O_RKBOL]
 ldr d3,[x19,#O_RHPLA]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d3,destination,d2,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d4,destination,d3,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d4,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d3
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d1,destination,d1,real,x16,0,d2
 ldr d2,[x19,#O_RCLUM]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d2,real,x16,0,d2
 adrp x9,.Lc_fifteen
 ldr d3,[x9,:lo12:.Lc_fifteen]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d3,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d1,real,x16,0,d2
 str d0,[x19,#O_RSIGMA]
 adrp x9,.Lc_RI0
 ldr d0,[x9,:lo12:.Lc_RI0]
 str d0,[x19,#O_RI0]
 ldr d0,[x19,#O_RNAVO]
 ldr d1,[x19,#O_RKBOL]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_R]
 adrp x9,.Lc_RMD
 ldr d0,[x9,:lo12:.Lc_RMD]
 str d0,[x19,#O_RMD]
 adrp x9,.Lc_RMV
 ldr d0,[x9,:lo12:.Lc_RMV]
 str d0,[x19,#O_RMV]
 adrp x9,.Lc_RMO3
 ldr d0,[x9,:lo12:.Lc_RMO3]
 str d0,[x19,#O_RMO3]
 adrp x9,.Lc_thousand
 ldr d0,[x9,:lo12:.Lc_thousand]
 ldr d1,[x19,#O_R]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 ldr d1,[x19,#O_RMD]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d0,real,x16,0,d1
 str d1,[x19,#O_RD]
 ldr d2,[x19,#O_RMV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 str d0,[x19,#O_RV]
 adrp x9,.Lc_threehalf
 ldr d2,[x9,:lo12:.Lc_threehalf]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d2,destination,d2,real,x16,0,d1
 str d2,[x19,#O_RCPD]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d3,destination,d2,real,x16,0,d1
 str d3,[x19,#O_RCVD]
 adrp x9,.Lc_four
 ldr d3,[x9,:lo12:.Lc_four]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d3,destination,d3,real,x16,0,d0
 str d3,[x19,#O_RCPV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d4,destination,d3,real,x16,0,d0
 str d4,[x19,#O_RCVV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d4,destination,d1,real,x16,0,d2
 str d4,[x19,#O_RKAPPA]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d1
 adrp x9,.Lc_one
 ldr d1,[x9,:lo12:.Lc_one]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RETV]
 adrp x9,.Lc_RMCO2
 ldr d0,[x9,:lo12:.Lc_RMCO2]
 str d0,[x19,#O_RMCO2]
 adrp x9,.Lc_RMCH4
 ldr d0,[x9,:lo12:.Lc_RMCH4]
 str d0,[x19,#O_RMCH4]
 adrp x9,.Lc_RMN2O
 ldr d0,[x9,:lo12:.Lc_RMN2O]
 str d0,[x19,#O_RMN2O]
 adrp x9,.Lc_RMCO
 ldr d0,[x9,:lo12:.Lc_RMCO]
 str d0,[x19,#O_RMCO]
 adrp x9,.Lc_RMHCHO
 ldr d0,[x9,:lo12:.Lc_RMHCHO]
 str d0,[x19,#O_RMHCHO]
 adrp x9,.Lc_RMNO2
 ldr d0,[x9,:lo12:.Lc_RMNO2]
 str d0,[x19,#O_RMNO2]
 adrp x9,.Lc_RMSO2
 ldr d0,[x9,:lo12:.Lc_RMSO2]
 str d0,[x19,#O_RMSO2]
 adrp x9,.Lc_RMSO4
 ldr d0,[x9,:lo12:.Lc_RMSO4]
 str d0,[x19,#O_RMSO4]
 adrp x9,.Lc_RMCFC11
 ldr d0,[x9,:lo12:.Lc_RMCFC11]
 str d0,[x19,#O_RMCFC11]
 adrp x9,.Lc_RMCFC12
 ldr d0,[x9,:lo12:.Lc_RMCFC12]
 str d0,[x19,#O_RMCFC12]
 adrp x9,.Lc_RMHCFC22
 ldr d0,[x9,:lo12:.Lc_RMHCFC22]
 str d0,[x19,#O_RMHCFC22]
 adrp x9,.Lc_RMCCL4
 ldr d0,[x9,:lo12:.Lc_RMCCL4]
 str d0,[x19,#O_RMCCL4]
 adrp x9,.Lc_RCW
 ldr d0,[x9,:lo12:.Lc_RCW]
 str d0,[x19,#O_RCW]
 adrp x9,.Lc_RCS
 ldr d0,[x9,:lo12:.Lc_RCS]
 str d0,[x19,#O_RCS]
 adrp x9,.Lc_RTT
 ldr d0,[x9,:lo12:.Lc_RTT]
 str d0,[x19,#O_RTT]
 adrp x9,.Lc_RDT
 ldr d0,[x9,:lo12:.Lc_RDT]
 str d0,[x19,#O_RDT]
 adrp x9,.Lc_RLVTT
 ldr d0,[x9,:lo12:.Lc_RLVTT]
 str d0,[x19,#O_RLVTT]
 adrp x9,.Lc_RLSTT
 ldr d0,[x9,:lo12:.Lc_RLSTT]
 str d0,[x19,#O_RLSTT]
 ldr d0,[x19,#O_RCW]
 ldr d1,[x19,#O_RCPV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 ldr d2,[x19,#O_RTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d2,real,x16,0,d0
 ldr d3,[x19,#O_RLVTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d3,real,x16,0,d0
 str d0,[x19,#O_RLVZER]
 ldr d0,[x19,#O_RCS]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d2,real,x16,0,d0
 ldr d4,[x19,#O_RLSTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d4,real,x16,0,d0
 str d0,[x19,#O_RLSZER]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d4,real,x16,0,d3
 str d0,[x19,#O_RLMLT]
 adrp x9,.Lc_RATM
 ldr d0,[x9,:lo12:.Lc_RATM]
 str d0,[x19,#O_RATM]
 adrp x9,.Lc_RESTT
 ldr d0,[x9,:lo12:.Lc_RESTT]
 str d0,[x19,#O_RESTT]
 ldr d0,[x19,#O_RCW]
 ldr d1,[x19,#O_RCPV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 ldr d2,[x19,#O_RV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 str d0,[x19,#O_RGAMW]
 ldr d1,[x19,#O_RLVTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
 ldr d2,[x19,#O_RTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[x19,#O_RBETW]
 ldr d0,[x19,#O_RESTT]
 bl md2asm_log_positive_normal
 str d0,[x19,#O_RALPW]
 ldr d1,[x19,#O_RBETW]
 ldr d2,[x19,#O_RTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RALPW]
 ldr d0,[x19,#O_RTT]
 bl md2asm_log_positive_normal
 ldr d1,[x19,#O_RGAMW]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[x19,#O_RALPW]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[x19,#O_RALPW]
 ldr d0,[x19,#O_RCS]
 ldr d1,[x19,#O_RCPV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 ldr d2,[x19,#O_RV]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d0,destination,d0,real,x16,0,d2
 str d0,[x19,#O_RGAMS]
 ldr d1,[x19,#O_RLSTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
 ldr d2,[x19,#O_RTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[x19,#O_RBETS]
 ldr d0,[x19,#O_RESTT]
 bl md2asm_log_positive_normal
 str d0,[x19,#O_RALPS]
 ldr d1,[x19,#O_RBETS]
 ldr d2,[x19,#O_RTT]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,3,d1,destination,d1,real,x16,0,d2
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RALPS]
 ldr d0,[x19,#O_RTT]
 bl md2asm_log_positive_normal
 ldr d1,[x19,#O_RGAMS]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d1,real,x16,0,d0
 ldr d1,[x19,#O_RALPS]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 str d0,[x19,#O_RALPS]
 ldr d0,[x19,#O_RGAMS]
 ldr d1,[x19,#O_RGAMW]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RGAMD]
 ldr d0,[x19,#O_RBETS]
 ldr d1,[x19,#O_RBETW]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RBETD]
 ldr d0,[x19,#O_RALPS]
 ldr d1,[x19,#O_RALPW]
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 str d0,[x19,#O_RALPD]
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
.Lc_RPI:
 .quad 0x400921fb54442d18
.Lc_RCLUM:
 .quad 0x41b1de784a000000
.Lc_RHPLA:
 .quad 0x390b860d52d96191
.Lc_RKBOL:
 .quad 0x3b30b0edf6c91c1b
.Lc_RNAVO:
 .quad 0x44dfe18461be0ec2
.Lc_RDAY:
 .quad 0x40f5180000000000
.Lc_RDAYI:
 .quad 0x40f5180000000000
.Lc_RHOUR:
 .quad 0x40ac200000000000
.Lc_REA:
 .quad 0x42416a5d2bd80000
.Lc_REPSM:
 .quad 0x3fda2e9468017119
.Lc_RA:
 .quad 0x41584de740000000
.Lc_RG:
 .quad 0x40239d013a92a305
.Lc_RI0:
 .quad 0x4095580000000000
.Lc_RMD:
 .quad 0x403cf6e2eb1c432d
.Lc_RMV:
 .quad 0x403203eab367a0f9
.Lc_RMO3:
 .quad 0x4047ff41f212d773
.Lc_RMCO2:
 .quad 0x404601374bc6a7f0
.Lc_RMCH4:
 .quad 0x40300a3d70a3d70a
.Lc_RMN2O:
 .quad 0x404601a9fbe76c8b
.Lc_RMCO:
 .quad 0x403c028f5c28f5c3
.Lc_RMHCHO:
 .quad 0x403e07ae147ae148
.Lc_RMNO2:
 .quad 0x40470147ae147ae1
.Lc_RMSO2:
 .quad 0x40500395810624dd
.Lc_RMSO4:
 .quad 0x40580353f7ced917
.Lc_RMCFC11:
 .quad 0x40612bcb923a29c7
.Lc_RMCFC12:
 .quad 0x405e3a7ef9db22d1
.Lc_RMHCFC22:
 .quad 0x40559e04189374bc
.Lc_RMCCL4:
 .quad 0x40633a5604189375
.Lc_RCW:
 .quad 0x40b07a0000000000
.Lc_RCS:
 .quad 0x40a0740000000000
.Lc_RTT:
 .quad 0x4071128f5c28f5c3
.Lc_RDT:
 .quad 0x4027a3d70a3d70a4
.Lc_RLVTT:
 .quad 0x4143146000000000
.Lc_RLSTT:
 .quad 0x4145a02200000000
.Lc_RATM:
 .quad 0x40f86a0000000000
.Lc_RESTT:
 .quad 0x4083191eb851eb85
.Lc_one:
 .quad 0x3ff0000000000000
.Lc_two:
 .quad 0x4000000000000000
.Lc_four:
 .quad 0x4010000000000000
.Lc_threehalf:
 .quad 0x400c000000000000
.Lc_thousand:
 .quad 0x408f400000000000
.Lc_daysyear:
 .quad 0x4076d40000000000
.Lc_yearangle:
 .quad 0x401921deacc92147
.Lc_deg:
 .quad 0x4066800000000000
.Lc_fifteen:
 .quad 0x402e000000000000
.section .note.GNU-stack,"",%progbits
